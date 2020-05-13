#!/usr/bin/python
"""
  Slic3r post-processing script for RepRap firmware printers which dynamically defines the mesh grid dimensions (M557) based on the print dimensions.
{1}
Usage:
{1}
  Slic3r Settings:
  In Print Settings > Output Options
  1. turn no "Verbose G-code"
  2. in "Post-processing scripts" type the full path to python and the full path to this script
  e.g. <Python Path>\python.exe  <Script Path>\meshcalc.py;
{1}
  In Printer Settings > Custom G-code > Start G-code
  Make sure the start g-code contains the M557 command, and that you probe the bed and load the compensation map,  e.g.
  M557 X10:290 Y10:290 S20	; Setup default grid
  G29							; Mesh bed probe
  G29 S1						; Load compensation map

  Script Settings
  probeSpacing = 20 - change this to the preferred probe point spacing in M557

  Note: The minimum X and Y of the probed area is limited to 2 times the probeSpacing.
  This is so that prints with a small footprint will have a minimum 3x3 probe mesh
{1}
Args:
{1}
  Path: The path parameter will be provided by Slic3r.
{1}
Requirements:
{1}
  The latest version of Python.
  Note that I use this on windows and haven't tried it on any other platform.
  Also this script assumes that the bed origin (0,0) is NOT the centre of the bed. Go ahead and modify this script as required.
{1}
Credit:
{1}
  Based on code originally posted by CCS86 on https://forum.duet3d.com/topic/15302/cura-script-to-automatically-probe-only-printed-area?_=1587348242875.
  and maybe 90% or more is code posted by MWOLTER on the same thread.
  Thank you both.
"""

# Based on a python program posted on the Duet's forums by user CCS86: 
# https://forum.duet3d.com/topic/15302/cura-script-to-automatically-probe-only-printed-area?_=1589348772496

# TODO: cleanup file description
# TODO: replace consts with flags (see argparse)
# TODO: clean code.
# TODO: make sure it supports also prints of a single layer
# TODO: select better layer markers

# Prusaslicer's variables are listed here.
# https://github.com/prusa3d/PrusaSlicer/wiki/Slic3r-placeholders-(a-copy-of-the-mauk.cc-page)

import sys
import re
import math
from enum import Enum
import copy


# Print an error message and abort.
def fatal_error(message):
    print('Fatal error: ' + message)
    input()
    sys.exit(1)


# Represents a closed interval [min, max]
class Span:
    def __init__(self, min_value, max_value):
        self.min_value = min_value
        self.max_value = max_value
        self.__check()

    # Call after mutations that may break the invariant.
    def __check(self):
        if self.min_value > self.max_value:
            fatal_error(f'Invalid span: {self}')

    # If needed, expand the span to include given value.
    def expand_to_include(self, value):
        if value < self.min_value:
            self.min_value = value
        elif value > self.max_value:
            self.max_value = value

    # Does the close span contains a value?
    def contains_value(self, val):
        return self.min_value <= val <= self.max_value

    # Does the span include another span?
    def contains_span(self, other_span):
        return self.contains_value(other_span.min_value) and self.contains_value(other_span.max_value)

    # Truncate the span to to included in another span.
    def clip_to(self, other_span):
        self.min_value = max(self.min_value, other_span.min_value)
        self.max_value = min(self.max_value, other_span.max_value)
        self.__check()

    # Force the span to be on int boundaries. Cannot shrink.
    def round(self):
        self.min_value = math.floor(self.min_value)
        self.max_value = math.ceil(self.max_value)
        self.__check()

    # Expand the span on both sides by given value.
    def expand_by(self, margin):
        self.min_value -= margin
        self.max_value += margin
        self.__check()

    def __repr__(self):
        return f'min: {self.min_value}, max: {self.max_value}'


# Represents a closed 2D rectangle as two spans, for
# X and Y respectively.
class Rect:
    def __init__(self, x_span, y_span):
        self.x_span = copy.deepcopy(x_span)
        self.y_span = copy.deepcopy(y_span)

    # Does this rectangle contains another rectangle.
    def contains_rect(self, other_rect):
        # print(f'containsRect() called *****')
        return (self.x_span.contains_span(other_rect.x_span) and
                self.y_span.contains_span(other_rect.y_span))

    # Clip the rectangle to fit in another rectangle.
    def clip_to(self, other_rect):
        self.x_span.clip_to(other_rect.x_span)
        self.y_span.clip_to(other_rect.y_span)

    # Force the rectangle to be on int boundaries. Can only expand.
    def round(self):
        self.x_span.round()
        self.y_span.round()

    # Expand the rectangle on all sides by a given margine
    def expand_by(self, margin):
        self.x_span.expand_by(margin)
        self.y_span.expand_by(margin)

    def __repr__(self):
        return f'x_span: {self.x_span}, y_span: {self.y_span}'


# Desire mesh spacing.
DESIRED_SPACING = 35

# Min mesh points in each of X and Y directions.
MIN_POINTS = 2

# Max mesh points in each of X and Y directions.
MAX_POINTS = 7

# Mesh the object print area expanded all around by this margin.
MARGIN = 10

# The printable area of my printer.
PRINTABLE = Rect(
    x_span=Span(0, 280),
    y_span=Span(0, 280))

# The meshable area of my printer.
MESHABLE = Rect(
    x_span=Span(30, 280),
    y_span=Span(30, 280))


# Enum to represent gcode file parsing states.
class ParsingState(Enum):
    WAITING_FOR_LAYER1 = 1
    IN_LAYER1 = 2
    LAYER1_DONE = 3


def main(fname):
    print(f'PRINTABLE area: {PRINTABLE}')
    print(f'MESHABLE area: {MESHABLE}')

    print(f'Opening gcode file: {fname}')
    gcode_file = open(fname, encoding='utf-8')

    # Read file as a list of lines. End-of-lines chars are stripped out.
    original_lines = gcode_file.read().splitlines()
    gcode_file.close()
    print(f'Read {len(original_lines)} lines')

    # Extract from gcode lines a bounding rectangle of first layer.
    print_area = extract_first_layer_print_area(original_lines)
    print(f'printArea: {print_area}')
    if not PRINTABLE.contains_rect(print_area):
        fatal_error(f'Print area {print_area} is outsise of printable area: {PRINTABLE}')

    # Compute mesh area
    mesh_area = copy.deepcopy(print_area)
    mesh_area.expand_by(MARGIN)
    mesh_area.clip_to(MESHABLE)
    mesh_area.round()

    # Compute M577 command to issue.
    mesh_gcode_command = compute_m557_command(mesh_area)

    # Create a list of output lines.
    modified_lines = replace_lines(original_lines, mesh_gcode_command)

    # Overwrite the file with the new lines.
    gcode_file = open(fname, "w")
    for modified_line in modified_lines:
        gcode_file.write(modified_line)
        gcode_file.write('\n')
    gcode_file.close()

    return


# Scan the input gcode lines and extract the bounding Rect of first layer.
def extract_first_layer_print_area(lines):
    spans = {'X': None, 'Y': None}

    state = ParsingState.WAITING_FOR_LAYER1
    print(f'Parsing state = {state}')
    for line in lines:
        # If start of first layer
        if "xxx before layer 0" in line:
            print(line)
            if state != ParsingState.WAITING_FOR_LAYER1:
                fatal_error(f'Unexpected state [1]: {state}')
            state = ParsingState.IN_LAYER1
            print(f'Parsing state = {state}')
            continue

        # If end of first layer
        if "xxx before layer 1" in line:
            print(line)
            if state != ParsingState.IN_LAYER1:
                fatal_error(f'Unexpected state [2]: {state}')
            state = ParsingState.LAYER1_DONE
            print(f'Parsing state = {state}')
            break

        # We can only about first layer gcode.
        if state != ParsingState.IN_LAYER1:
            continue

        # Get coordinates on this line
        # TODO: should we restrict this to move operations?
        for match in re.findall(r'([YX])([\d.]+)\s', line):
            # Get axis letter, e.g. 'X', 'Y', 'Z'.
            axis = match[0]

            # Skip axes we don't care about
            if axis not in spans.keys():
                continue

            # Parse axis numeric value
            value = float(match[1])

            # Expand the span of this axis
            if spans[axis] is None:
                spans[axis] = Span(value, value)
            else:
                spans[axis].expand_to_include(value)

    # Check expected final parsing stete
    if state != ParsingState.LAYER1_DONE:
        fatal_error(f'Unexpected state [3]: {state}')

    # Make sure we had both X and Y values.
    if spans['X'] is None or spans['Y'] is None:
        fatal_error(f'Failed to extract print range: {spans}')

    rect = Rect(spans['X'], spans['Y'])
    rect.round()  # Force int values.

    print(f'First layer print areas: {rect}')
    return rect


# Given an X or Y mesh span, return the number of mesh points.
def span_to_mesh_point_count(span):
    return max(MIN_POINTS,
               1 + round((span.max_value - span.min_value) / DESIRED_SPACING))


# Returns a gcode command to insert
def compute_m557_command(mesh_area):
    # Conpute number of mesh points for X, Y respectivly.
    x_points = span_to_mesh_point_count(mesh_area.x_span)
    y_points = span_to_mesh_point_count(mesh_area.y_span)
    print(f'Will use {x_points} x {y_points} mesh points')

    return 'M557 X{}:{} Y{}:{} P{}:{}'.format(
        mesh_area.x_span.min_value,
        mesh_area.x_span.max_value,
        mesh_area.y_span.min_value,
        mesh_area.y_span.max_value,
        x_points,
        y_points)


# Given list of original lines an mesh command to insert, return the
# list of output lines.
def replace_lines(original_lines, mesh_gcode):
    modified_lines = []
    for original_line in original_lines:
        if original_line.startswith('M557'):
            modified_lines.extend([
                "; Replaced marker: " + original_line,
                mesh_gcode,
                "; End marker"
            ])
            print(f'Marker: {original_line}')
            print(f'Inserted: {mesh_gcode}')
        else:
            modified_lines.append(original_line)
    return modified_lines


if __name__ == '__main__':
    if sys.argv[1]:
        main(fname=sys.argv[1])
    else:
        fatal_error('Missing gcode file name argument')
