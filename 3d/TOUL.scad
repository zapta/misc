/*
TOUL: The OpenScad Usefull Library
==================================

This file aims to provide a set of functions for vectors, strings and number operations.

Author: Nathanaël Jourdane
Email: nathanael@jourdane.net
Date: december 30, 2015
License: Creative Commons CC-BY (Attribution)
thingiverse: http://www.thingiverse.com/thing:1237203

Requires OpenScad 2015.03 or sup.

I love implementing these recursive functions! :3
If you need a generic function that doesn't exists in OpenScad, or if you find
a bug in these ones, feel free to ask me. ;-)

An other string library: http://www.thingiverse.com/thing:526023

#### Instructions ####

Copy-paste the function(s) you need from TOUL.scad into your .scad file;

OR:

Place TOUL.scad in your local OpenSCAD folder under `/libraries`.
On Windows, this folder should default to `Documents/OpenSCAD/libraries`.
Then import TOUL.scad with the following line of code:

	include TOUL.scad

*/

/**************
*** Vectors ***
**************/

/**** new_vector ****

[vect] new_vector(`len`, `[val]`)
Returns a vector with `len` elements initialised to the `val` value.

Arguments:
- [int] `len`: The length of the vector.
- [any type] `val`: The values filled in the vector *(0 by default)*.

Usage:
echo(new_vector(5)); // [0, 0, 0, 0, 0]
echo(new_vector(3, "a")); // ["a", "a", "a"]
*/
function new_vector(n, val=0, v=[]) =
	n == 0 ? v :
	new_vector(n-1, val, concat(v, val));

/**** getval ****

[any type] getval(`v`, `key`)

Returns the value corresponding to the key `key` by searching in `v`, a vector of [key, value], or returns -1 if not found.

Arguments:
- [vect] `v`: A vector of [key, value] (aka a dictionnary).
- `key`: The key to search.

Usage:
dic = [["a", 12], ["b", 42], ["c", 29]];
echo(getval(dic, "b")); // 42
echo(getval(dic, "x")); // undef
*/
function getval(v, key, i=0) =
	key == v[i][0] ? v[i][1] :
	i>len(v) ? undef :
	getval(v, key, i+1);

/**************
*** Strings ***
**************/

/**** strcat ****

[str] strcat(`v`, `[sep]`)
Returns a string of a concatenated vector of substrings `v`, with an optionnaly
separator `sep` between each.
See also: split()

Arguments:
- [vect] `v`: The vector of string to concatenate.
- [str] `sep` (optional): A separator which will added between each substrings ("" by default).

Usage:
v = ["OpenScad", "is", "a", "free", "CAD", "software."];
echo(strcat(v)); // "OpenScadisafreeCADsoftware."
echo(strcat(v, " ")); // "OpenScad is a free CAD software."
*/
function strcat(v, sep="", str="", i=0, j=0) =
	i == len(v) ? str :
	j == len(v[i])-1 ? strcat(v, sep,
		str(str, v[i][j], i == len(v)-1 ? "" : sep),   i+1, 0) :
	strcat(v, sep, str(str, v[i][j]), i, j+1);

/**** split ****

[vect] split(`str`, `[sep]`)
Returns a vector of substrings by cutting the string `str` each time where `sep` appears.
See also: strcat(), str2vec()

Arguments:
- [str] `str`: The original string.
- [char] `sep`: The separator who cuts the string (" " by default).

Usage:
str = "OpenScad is a free CAD software.";
echo(split(str)); // ["OpenScad", "is", "a", "free", "CAD", "software."]
echo(split(str)[3]); // "free"
echo(split("foo;bar;baz", ";")); // ["foo", "bar", "baz"]
*/
function split(str, sep=" ", i=0, word="", v=[]) =
	i == len(str) ? concat(v, word) :
	str[i] == sep ? split(str, sep, i+1, "", concat(v, word)) :
	split(str, sep, i+1, str(word, str[i]), v);

/**** str2vec ****

[vect] str2vec(`str`)
Returns a vector of chars, corresponding to the string `str`.
See also: split()

Arguments:
- [str] `str`: The original string.

Usage:
echo(str2vec("foo")); // ["f", "o", "o"] 
*/
function str2vec(str, v=[], i=0) =
	i == len(str) ? v :
	str2vec(str, concat(v, str[i]), i+1);

/**** substr ****

[str] substr(`str`, `[pos]`, `[len]`)
Returns a substring of a string.

Arguments:
- [str] `str`: The original string.
- [int] `pos` (optional): The substring position (0 by default).
- [int] `len` (optional): The substring length (string length by default).

Usage:
str = "OpenScad is a free CAD software.";
echo(substr(str, 12)); // "a free CAD software."
echo(substr(str, 12, 10)); // "a free CAD"
echo(substr(str, len=8)); // or substr(str, 0, 8); // "OpenScad"
*/
function substr(str, pos=0, len=-1, substr="") =
	len == 0 ? substr :
	len == -1 ? substr(str, pos, len(str)-pos, substr) :
	substr(str, pos+1, len-1, str(substr, str[pos]));

/**** fillstr ****

[str] fillstr(`substring`, `nb_occ`)
Returns a string filled with a set of `substring`s, `nb_occ` times.

Arguments:
- [str] `str`: The substring to copy several times.
- [int] `nb_occ`: The number of occurence of the substring.

Usage:
echo(fillstr("6", 3)); // ECHO: "666"
echo(fillstr("hey", 3)); // ECHO: "heyheyhey"
*/
function fillstr(fill, nb_occ, str="") =
	nb_occ == 0 ? str :
	fillstr(fill, nb_occ-1, str(str, fill));

/**************
*** Numbers ***
**************/

/**** dec2bin ****

[vect] dec2bin(num [,len])
Returns a vector of booleans corresponding to the binary value of the num `num`.

Arguments:
- [int] `num`: The number to convert.
- [int] `len` (optional): The vector length. If specified, fill the most significant bits with 0.

Usage:
echo(dec2bin(42)); // [1, 0, 1, 0, 1, 0]
echo(dec2bin(42, 8)); // [0, 0, 1, 0, 1, 0, 1, 0]
*/
function dec2bin(num, len=-1, v=[]) =
	len(v) == len || (num == 0 && len == -1) ? v :
	num == 0 && len != -1 ? dec2bin(0, len, concat(0, v)) :
	dec2bin(floor(num/2), len, concat(num%2, v));

/**** atoi ****

[int] atoi(`str`, `[base]`)
Returns the numerical form of a string `str`.

Arguments:
- [str] `str`: The string to converts (representing a number).
- [int] `base` (optional): The base conversion of the number
		(2 for binay, 10 for decimal (default), 16 for hexadecimal).

Usage:
echo(atoi("491585")); // 491585
echo(atoi("-15")); // -15
echo(atoi("01110", 2)); // 14
echo(atoi("D5A4", 16)); // 54692
echo(atoi("-5") + atoi("10") + 5); // 10
*/
function atoi(str, base=10, i=0, nb=0) =
	i == len(str) ? (str[0] == "-" ? -nb : nb) :
	i == 0 && str[0] == "-" ? atoi(str, base, 1) :
	atoi(str, base, i + 1,
		nb + search(str[i], "0123456789ABCDEF")[0] * pow(base, len(str) - i - 1));