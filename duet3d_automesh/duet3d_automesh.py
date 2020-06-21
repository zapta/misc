#!/usr/bin/python
"""
  A Python3 script for per-print selective mesh bed leveling for Duet3d and PrusaSlicer.

  The script process the generated gcode file, determine the bounding area of the first layer and
  insert a M557 gcode command to set mesh bed leveling for that area only.

  Setting up:
  1. Make sure your computer has python3 installed.
  2. In your PrusaSlicer, set the Post-processing-scripts in the Plater | Output Options tab to:
     python3 path-to-this-script.
  3. In the the Start G-Code setting of yoru slicer add the following lines (preferably after 
     turning on the bed and nozzle heaters and waiting for them to reach their target temps)
     ; For automesh
     M557 TBD  ; parameters will be set automatically
     G28  ;home
     G29  ;mesh
  4. In the Before layer change setting of your slicer insert the line
     ; Automesh: begin layer [layer_num]
  5. In the Post processing script section of your slicer add a command to invoke the
     script:
     <path to your python3> <path_to_the_duet3d_automesh.py file>
  6. Slice a model and save it's gcode to a file. This will invoke the script
     which will set the M577 command to have the proper mesh parameters. 
  7. Open the gcode file with an editor and verify that the M577 command 
     indeed has the proper parameters.
  8. Send the gcode file for printing and verify that it mesh the print area
     before the first layer is printed.   
"""

# Based on a python program posted on the Duet's forums by user CCS86: 
# https://forum.duet3d.com/topic/15302/cura-script-to-automatically-probe-only-printed-area?_=1589348772496

# TODO: make sure it works well also with a single layer prints.

# Prusaslicer's variables are listed here.
# https://github.com/prusa3d/PrusaSlicer/wiki/Slic3r-placeholders-(a-copy-of-the-mauk.cc-page)

import argparse
import copy
import math
import re
import sys

from enum import Enum

parser = argparse.ArgumentParser()

parser.add_argument('--meshable',
                    default="30:280,30:280",
                    help='Bed meshable area x1:x2,y1:y2')

parser.add_argument('--margin', type=int,
                    default=10,
                    help='Expand area to mesh around by this value ')

parser.add_argument('--spacing', type=int,
                    default=40,
                    help='Desired mesh spacing.')

parser.add_argument('--min_points', type=int, choices=range(2, 50),
                    default=3,
                    help='Minimum number of mesh points in each direction.')

parser.add_argument('--max_points', type=int, choices=range(2, 50),
                    default=10,
                    help='Maximum number of mesh points in each direction.')

parser.add_argument('--first_layer_start',
                    default="Automesh: begin layer 0",
                    help='Beginning of first layer gcode marker')

parser.add_argument('--first_layer_end',
                    default="Automesh: begin layer 1",
                    help='End of first layer gcode marker')

# Positional arg. Verified in main() to be required.
parser.add_argument('file_path', default="")

args = parser.parse_args()


# Prints an error message and aborts.
def fatal_error(message):
    raise Exception('Fatal error: ' + message)


# Represents a closed interval [min, max].
class Span:
    def __init__(self, min_value, max_value):
        self.min_value = min_value
        self.max_value = max_value
        self.__check()

    # Construct from a string. E.g. "10:320.3"
    @staticmethod
    def from_string(s):
        match = re.fullmatch(r'([-]?[\d.-]+):([-]?[\d.-]+)', s)
        if not match:
            fatal_error(f'Invalid range string format: "{s}"')
        # TODO: detect numeric exeption and call fatal_error.
        return Span(float(match[1]), float(match[2]))

    # Call after mutations that may break the invariant.
    def __check(self):
        if self.min_value > self.max_value:
            fatal_error(f'Invalid range value: {self}')

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
        return f'{self.min_value}:{self.max_value}'


# Represents a closed 2D rectangle as two spans, one for X and Y respectively.
class Rect:
    def __init__(self, x_span, y_span):
        self.x_span = copy.deepcopy(x_span)
        self.y_span = copy.deepcopy(y_span)

    # Construct from a string. E.g. "10:320.3,0:280"
    @staticmethod
    def from_string(s):
        match = re.fullmatch(r'([^,]+),([^,]+)', s)
        if not match:
            fatal_error(f'Invalid area string format: "{s}"')
        return Rect(Span.from_string(match[1]), Span.from_string(match[2]))

    # Does this rectangle contains another rectangle.
    def contains_rect(self, other_rect):
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
        return f'{self.x_span},{self.y_span}'


# The meshable area of my printer.
MESHABLE_AREA = Rect.from_string(args.meshable)


# Enum to represent gcode file parsing states.
class ParsingState(Enum):
    WAITING_FOR_LAYER1 = 1
    IN_LAYER1 = 2
    LAYER1_DONE = 3


def main():
    fname = args.file_path
    if not fname:
        fatal_error("Missing gcode file path argument")

    if args.min_points > args.max_points:
        fatal_error("--min_points can't be higher than --max_points")

    print(f'MESHABLE area: {MESHABLE_AREA}')

    print(f'Opening gcode file: {fname}')
    gcode_file = open(fname, encoding='utf-8')

    # Read file as a list of lines. End-of-lines chars are stripped out.
    original_lines = gcode_file.read().splitlines()
    gcode_file.close()
    print(f'Read {len(original_lines)} lines')

    # Extract from gcode lines a bounding rectangle of first layer.
    print_area = extract_first_layer_print_area(original_lines)
    print(f'printArea: {print_area}')

    # Compute mesh area
    mesh_area = copy.deepcopy(print_area)
    mesh_area.expand_by(args.margin)
    mesh_area.clip_to(MESHABLE_AREA)
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
        if args.first_layer_start in line:
            print(line)
            if state != ParsingState.WAITING_FOR_LAYER1:
                fatal_error(f'Unexpected state [1]: {state}')
            state = ParsingState.IN_LAYER1
            print(f'Parsing state = {state}')
            continue

        # If end of first layer
        if args.first_layer_end in line:
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
        for match in re.findall(r'([YX])([-]?[\d.]+)\s', line):
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
    n = 1 + round((span.max_value - span.min_value) / args.spacing)
    return max(args.min_points, min(args.max_points, n))


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
    # We keep the M73 remaining time lines so we can restore the display after
    # a temp change.
    remaining_time_lines = []
    modified_lines = []
    for original_line in original_lines:
        # Time marker, e.g. E.g. M73 P27 R16
        match = re.fullmatch(r'M73 P([\d]+) R([\d]+)', original_line)
        if match:
            # percents = int(match[1])
            minutes_left = int(match[2])
            hh = math.floor(minutes_left / 60)
            mm = minutes_left % 60
            modified_lines.append('; ' + original_line)
            remaining_time_lines = [
                ';--- Display M73 remaining time',
                f'M140 R-{hh}',  # Bed standby field
                f'G10 P0 R-{mm}',  # Extruder standby field
                ';---'
            ]
            modified_lines.extend(remaining_time_lines)
            continue

        # If changing extruder or bed temperature, it may overwrite
        # the standby fields so restore remaining time display.
        if original_line.startswith('M104') or original_line.startswith('M140'):
            modified_lines.append(original_line)
            # This does nothing before the first M73.
            modified_lines.extend(remaining_time_lines)
            continue

        # M577 mesh insertion.
        if original_line.startswith('M557'):
            modified_lines.extend([
                "; Replaced marker: " + original_line,
                mesh_gcode,
                "; End marker"
            ])
            print(f'Marker: {original_line}')
            print(f'Inserted: {mesh_gcode}')
            continue

        # Regular line. Just pass it as is.
        modified_lines.append(original_line)
    return modified_lines


main()
