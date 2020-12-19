; After layer change. Heat tower setting for layer [layer_num]/[layer_z]mm
{if layer_z<=5}
M104 S230
{elsif layer_z<=10}
M104 S225
{elsif layer_z<=15}
M104 S220
{elsif layer_z<=20}
M104 S215
{elsif layer_z<=25}
M104 S210
{elsif layer_z<=30}
M104 S205
{elsif layer_z<=35}
M104 S200
{elsif layer_z<=40}
M104 S195
{elsif layer_z<=45}
M104 S190
{elsif layer_z<=50}
M104 S185
{else}
M104 S180
{endif}
