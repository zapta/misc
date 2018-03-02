// Copyright 2017 Arthur Davis (thingiverse.com/artdavis)
// This file is licensed under a Creative Commons Attribution 4.0
// International License.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
// An egg model with a profile that is represented mathematically
// and can be arbitrarily scaled. By itself this probably
// won't print very well but it is suitable as a reference
// or starting point for egg shape based projects.
// For instance: http://www.thingiverse.com/thing:2228825

// Optimize view for Makerbot Customizer:
// preview[view:south east, tilt:side]

// Length of the Egg
egg_length = 62; // [10:2:200]
// Number of steps to sample the half profile of the egg
steps = 100; // [50:5:300]

/* [Hidden] */
// Special variables for facets/arcs
$fn = 48;

// Egg profile computing function
function egg(x, l)= 0.9*l*pow(1-x/l, 2/3)*sqrt(1-pow(1-x/l, 2/3));

// Create egg profile
module egg_profile(length=egg_length, offset=0, steps=steps) {
    ss = length / (steps-1); // step size
    v1 = [for (x=[0:ss:length]) [egg(x, length), x + offset]];
    // Make absolute sure the last point brings the profile
    // back to the axis
    v2 = concat(v1, [[0, length + offset]]);
    // Close the loop
    v3 = concat(v2, [[0, offset]]);
        polygon(points = v3);
}

// Create a solid egg part
module solid_egg(length=egg_length, offset=0, steps=steps) {
    rotate_extrude(convexity = 10) {
        egg_profile(length=length, offset=offset, steps=steps);
    }
}

solid_egg(length=egg_length, offset=0, steps=steps);
