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

import sys
import re
import math
import os

probeSpacing = 20   		# set your required probe point spacing for M557

def main(fname):
	print("Starting Mesh Calculations")

	try:
		_Slic3rFile = open(fname, encoding='utf-8')
	except TypeError:
		try:
			_Slic3rFile = open(fname)
		except:
			print("Open file exception. Exiting.")
			error()
	except FileNotFoundError:
		print('File not found. Exiting.')
		error()

	lines = _Slic3rFile.readlines()
	_Slic3rFile.close()

	linesNew = calcBed(lines)

	_Slic3rFile = open(fname, "r+")
	_Slic3rFile.seek(0)
	_Slic3rFile.truncate()
	for element in linesNew:
		_Slic3rFile.write(element)
	_Slic3rFile.close()

	return

def error():
	# remove the next 2 lines to close console automatically
	print("Press Enter to close")
	input()
	sys.exit()

def calcBed(lines):
	bounds = findBounds(lines)
	bed = findBed()

	for axis in bounds:
		if bounds[axis]['max'] - bounds[axis]['min'] < bed[axis]:
			print(f'Success: {axis} mesh is smaller than bed')

		else:
			print('Error: Mesh is larger than bed. Exiting.')
			error()

		for limit in bounds[axis]:
			if limit == 'min':
				if (bed[axis]) - bounds[axis][limit] > 0:
					print(f'Success: {axis} {limit} coordinate is on the bed.')
				else:
					print(f'Error: {axis} {limit} coordinate is off the bed. Exiting.')
					error()

			if limit == 'max':
				if (bed[axis]) - bounds[axis][limit] > 0:
					print(f'Success: {axis} {limit} coordinate is on the bed.')
				else:
					print(f'Error: {axis} {limit} coordinate is off the bed. Exiting.')
					error()
	return fillGrid(bounds, lines)

def findBed():
	bed = {
		'X': 0,
		'Y': 0,
	}

	bedCorners = os.environ.get("SLIC3R_BED_SHAPE")
	maxXY = bedCorners.split(',')[2].split('x')
	bed['X'] = int(maxXY[0])
	bed['Y'] = int(maxXY[1])
	print(bed)

	return bed

def findBounds(lines):
	bounds = {
		'X': {'min': 9999, 'max': 0},
		'Y': {'min': 9999, 'max': 0},
	}

	parsing = False
	for line in lines:
		if "move to next layer (0)" in line:
			parsing = True
			continue
		elif "move to next layer (1)" in line:
			break

		if parsing:
			# Get coordinates on this line
			for match in re.findall(r'([YX])([\d.]+)\s', line):
				# Get axis letter
				axis = match[0]

				# Skip axes we don't care about
				if axis not in bounds:
					continue

				# Parse parameter value
				value = float(match[1])

				# Update bounds
				bounds[axis]['min'] = math.floor(min(bounds[axis]['min'], value))
				bounds[axis]['max'] = math.ceil(max(bounds[axis]['max'], value))

	# make sure the bounds are at least 2 x Probe Point Spacing, for small prints.
	# also, make sure that the maximum amount of points isn't exceeded.
	if parsing:
		global probeSpacing

		for axis in bounds:
			spacing = (bounds[axis]['max'] - bounds[axis]['min'])/2
			if spacing < probeSpacing:
				probeSpacing = spacing

	print("Bounds are: " + str(bounds))
	return bounds


def fillGrid(bounds, lines):
	#Check the quantity of points - cannot exceed 21points per axis, otherwise will throw error and ruin print by not running a mesh
	X_points=(bounds['X']['max']-bounds['X']['min'])/probeSpacing
	Y_points=(bounds['Y']['max']-bounds['Y']['min'])/probeSpacing
	if X_points>21 or Y_points>21:
		Points=True
		#basically, if its over 21, just use 21, if not, round up, keeping roughly the same spacing for the non-affected axis
		if X_points>21: X_points = 21
		else: X_points = math.ceil(X_points)
		if Y_points>21: Y_points=21
		else:Y_points = math.ceil(Y_points)
		print('With your required print footprint, you\'ll exceed 21 points on either axis, changing to point based. Your new point grid is {}:{} points'.format(X_points,Y_points))

	else:
		Points=False

	if Points == True:
		# Fill in the level command template
		gridNew = 'M557 X{}:{} Y{}:{} P{}:{}'.format(bounds['X']['min'], bounds['X']['max'],bounds['Y']['min'], bounds['Y']['max'], X_points, Y_points)
	else:
		# Fill in the level command template
		gridNew = 'M557 X{}:{} Y{}:{} S{}'.format(bounds['X']['min'], bounds['X']['max'],bounds['Y']['min'], bounds['Y']['max'], probeSpacing)

	# Replace M557 command in GCODE
	linesNew = []
	for line in lines:
		if line.startswith('M557'):
			linesNew.append(re.sub(r'^M557 X\d+:\d+ Y\d+:\d+ S\d+', gridNew, line, flags=re.MULTILINE))
			print('New M557: ' + linesNew[-1])
		else:
			linesNew.append(line)
	return linesNew

if __name__ == '__main__':
	if sys.argv[1]:
		main(fname = sys.argv[1])
	else:
		print('Error: Proper Slic3r post processing command is python3')
		error()