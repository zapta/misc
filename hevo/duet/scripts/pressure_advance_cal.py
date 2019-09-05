#!/usr/bin/python

# Downloaded from a link at https://forum.duet3d.com/topic/6698/pressure-advance-calibration/1

# extrusion parameters (mm)
extrusion_width   = 0.4
layer_height      = 0.08
base_layer_height = 0.2
filament_diameter = 1.75

# print speeds (mm/s)
travel_speed      = 150
first_layer_speed =  20
slow_speed        =   5
fast_speed        =  70

# calibration object dimensions (mm)
layers        = 100
object_width  = 90
num_patterns  =  4
pattern_width =  5

# pressure advance gradient (s)
pressure_advance_max = 2
pressure_advance_min = 1

# center of print bed (mm)
offset_x = 150
offset_y = 150

layer0_z = layer_height


from math import *


def extrusion_volume_to_length(volume):
    return volume / (filament_diameter * filament_diameter * 3.14159 * 0.25)

def extrusion_for_length(length):
    return extrusion_volume_to_length(length * extrusion_width * layer_height)

curr_x = offset_x
curr_y = offset_y
curr_z = layer0_z

def up():
    global curr_z
    curr_z += layer_height
    print("G1 Z%.3f" % curr_z)

def line(x,y,speed):
    length = sqrt(x**2 + y**2)
    global curr_x, curr_y
    curr_x += x
    curr_y += y
    if speed > 0:
        print("G1 X%.3f Y%.3f E%.4f F%.0f" % (curr_x, curr_y, extrusion_for_length(length), speed * 60))
    else:
        print("G1 X%.3f Y%.3f F%.0f" % (curr_x, curr_y, travel_speed * 60))

def goto(x,y):
    global curr_x, curr_y
    curr_x = x + offset_x
    curr_y = y + offset_y
    print("G1 X%.3f Y%.3f" %(curr_x, curr_y))

# main
print("G21 ; set units to millimeters")
print("G90 ; use absolute coordinates")
print("M83 ; use relative distances for extrusion")
print("")

print("G1 X%.3f Y%.3f Z%.3f F%.0f ; go to starting point"
    % (curr_x, curr_y, curr_z, travel_speed * 60))
print("")

print("; Base")
line(-object_width/2,0,0)

saved_layer_height = layer_height;
layer_height = base_layer_height

for l in range(2):
    #print("xyz: ", l, " ", layer_height)
    for offset_i in range(5):
        offset = offset_i * extrusion_width
        line(object_width+offset,0,first_layer_speed)
        line(0,extrusion_width+offset*2,first_layer_speed)
        line(-object_width-offset*2,0,first_layer_speed)
        line(0,-extrusion_width-offset*2,first_layer_speed)
        line(offset,0,first_layer_speed)
        line(0,-extrusion_width,0)
    if (l == 1):
      layer_height = saved_layer_height
    up()
    goto(-object_width/2,0)

segment = (object_width*1.0) / num_patterns
space = segment - pattern_width

for l in range(layers):
    
    pressure_advance = (l / (layers * 1.0)) * (pressure_advance_max-pressure_advance_min) + pressure_advance_min;
    
    print("; layer %d, pressure advance: %.3f" %(l, pressure_advance))
    
    print("M572 D0 S%.3f" % pressure_advance)
    
    for i in range(num_patterns):
        line(space/2, 0, fast_speed)
        line(pattern_width, 0, slow_speed)
        line(space/2, 0, fast_speed)
    
    line(0,extrusion_width,fast_speed)

    for i in range(num_patterns):
        line(-space/2, 0, fast_speed)
        line(-pattern_width, 0, slow_speed)
        line(-space/2, 0, fast_speed)
    
    line(0,-extrusion_width,fast_speed)
    up()


