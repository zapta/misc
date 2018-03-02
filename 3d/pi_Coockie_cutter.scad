echo ("Copyright 2017 Nevit Dilmen");
echo ("Creative Commons Attribution Share Alike");

Letter = "π";
Extrude = 15;
Size = 60;
mirror ([1,0,0]) {
linear_extrude (Extrude){
difference () {
offset (0.3)
resize([0,Size,0], auto=true) 
text (Letter, font=":style=bold");
resize([0,Size,0], auto=true) 
text (Letter, font=":style=bold");
}}

linear_extrude (1.5){
difference () {
offset (5)
resize([0,Size,0], auto=true) 
text (Letter, font=":style=bold");
resize([0,Size,0], auto=true) 
text (Letter, font=":style=bold");
}
}
}