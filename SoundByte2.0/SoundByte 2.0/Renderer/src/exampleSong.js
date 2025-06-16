/*
Sandbox to experiment with new features and check visuals
*/

//import our custom types and functions
import * as Types from './customTypes.js';
import * as Renderer from './renderer.js';

//example song
var notes1 = new Types.NoteGroup("en5/q, b4/q", false, false); //notes, isBeamed, isTuplet
var notes2 = new Types.NoteGroup("a4/8, g4/8, f4/8, e4/8", true, false);
var notes3 = new Types.NoteGroup("g4/8, a4/8, g4/8", true, true);
var notes4 = new Types.NoteGroup("a4/q, a4/q, b4/q/r", false, false);
var notes5 = new Types.NoteGroup("a5/8, g#5/8, f#5/8, e5/8", true, false);
var notes6 = new Types.NoteGroup("a4/h....., a4/64", false, false);
var notes7 = new Types.NoteGroup("e5/8., bb4/16", true, false);
var notes8 = new Types.NoteGroup("a4/16, a4/16, a4/8", true, false);
var notes9 = new Types.NoteGroup("a4/q, a4/q, a4/q", false, false);
var notes10 = new Types.NoteGroup("a4/8, g5/8, a4/8, a4/8", true, false);
var notes11 = new Types.NoteGroup("a4/8, a3/8, a4/8, a4/8", true, false);
var notes13 = new Types.NoteGroup('b4/w/r', false, false);

var lyric1 = new Types.Text('do', 'q', 0);
var lyric2 = new Types.Text('re', 'q', 0);
var lyric3 = new Types.Text('mi', '8', 0);
var lyric4 = new Types.Text('fa', '8', 0);
var lyric5 = new Types.Text('so', '8', 0);
var lyric6 = new Types.Text('la', '8', 0);
var lyric7 = new Types.Text('la', '8', 3);
var lyric8 = new Types.Text('la', '8.', 0);
var lyric9 = new Types.Text('di', '16', 0);
var lyric10 = new Types.Text('do', 'h.....', 0);
var lyric11 = new Types.Text('re', '64', 0);

var grace_note = new Types.GraceNote(['b/4'], '8', 0);
var grace_note2 = new Types.GraceNote(['b/4'], '8', 1);

var hairpin = new Types.Hairpin(1, 4, 1);
var hairpin2 = new Types.Hairpin(0, 5, 2);

var dynamic1 = new Types.Text('pp', 'q', 0);
var dynamic2 = new Types.Text('p', 'q', 0);
var dynamic3 = new Types.Text('f', 'q', 0);
var dynamic4 = new Types.Text('ff', 'q', 0);
var dynamic5 = new Types.Text('sfz', '8', 3);
var dynamic6 = new Types.Text('p', 'h.....', 0);
var dynamic7 = new Types.Text('f', '64', 0);

var measure1 = new Types.Measure("4/4", "Db", [notes1, notes2], [[2, 5]], false, false, [lyric1, lyric2, lyric3, lyric4, lyric5, lyric6], [], 0, [], [], 1); //time_sig, key_sig, note_groups[], slurIndices[], measure_number
var measure2 = new Types.Measure("5/4", null, [notes1, notes4], [], true, false, [], [], 0, [], [], 2);
var measure3 = new Types.Measure(null, null, [notes1, notes4], [], false, true, [], [], 0, [], [], 3);
var measure4 = new Types.Measure("4/4", null, [notes1, notes5], [[0, 1]], false, false, [], [], 0, [hairpin2], [], 4);
var measure5 = new Types.Measure(null, "F", [notes4, notes3], [[0, 1]], false, false, [], [], 0, [], [dynamic1, dynamic2, dynamic3, dynamic4], 5);
var measure6 = new Types.Measure(null, null, [notes6], [], false, false, [lyric10, lyric11], [grace_note, grace_note2], 0, [], [dynamic6, dynamic7], 6);
var measure7 = new Types.Measure(null, null, [notes7, notes4], [[0, 1]], false, false, [lyric8, lyric9, lyric1, lyric1, lyric1], [grace_note], 0, [], [], 7);
var measure8 = new Types.Measure(null, null, [notes8, notes9], [], false, false, [], [], 0, [], [], 8);
var measure9 = new Types.Measure(null, null, [notes10, notes1], [[0,3]], false, false, [], [], 0, [], [], 9);
var measure10 = new Types.Measure(null, null, [notes11, notes1], [[0, 3]], false, false, [], [], 0, [], [], 10);
var measure14 = new Types.Measure(null, null, [notes11, notes1], [[0, 3]], false, false, [], [], 0, [], [], 14);
var measure15 = new Types.Measure(null, null, [], [], false, false, [], [], 4, [], [], 15);
var measure16 = new Types.Measure(null, null, [notes8, notes9], [[5, null]], false, false, [], [], 0, [hairpin], [], 16);
var measure17 = new Types.Measure(null, null, [notes4, notes3], [], false, false, [], [], 0, [], [], 17);
var measure18 = new Types.Measure("5/4", null, [notes1, notes4], [], false, false, [], [], 0, [], [], 18);
var measure19 = new Types.Measure(null, null, [notes13], [], false, false, [], [], 0, [], [], 19);
var measure20 = new Types.Measure('4/4', null, [notes4, notes3], [], false, false, [], [], 0, [], [], 20);
var measure21 = new Types.Measure('1/4', null, [notes3], [], false, false, [lyric7, lyric7, lyric7], [], 0, [], [dynamic5, dynamic5, dynamic5], 21);

//code to see how errors are handled
// var dots = new Types.NoteGroup('a4/h  ..', false, false);
// var short = new Types.NoteGroup('a4/8', false, false);
// var measure21 = new Types.Measure(null, null, [dots, short], [], false, false, [], [grace_note], 0, [], [], 21);
//var notes12 = new Types.NoteGroup("balderdash", true); //for errors
//var lyric7 = new Lyric(1, lyric6); //for errors
//var error = new Types.Measure(null, null, ["notes12"], [], false, false, [], [], 0, [], 11);
// var error2 = new Types.Measure(null, null, [notes1], [], false, false, [], [], 0, [], 12);
// var error3 = new Types.Measure(null, null, [notes11, notes1], [[0, 3]], false, false, [4], [], 0, [], 13);
// var errorSong = new Types.Song("treble", measure1.time_sig, [measure1, measure2, measure3, measure4, measure5, measure6, measure7, measure8, measure9, measure10, error, error2, error3, measure14, measure15, measure16, null]); //clef, time_sig, measures

var song = new Types.Song("treble", measure1.time_sig, measure1.key_sig, 85, [measure1, measure2, measure3, measure4, measure5, measure6, measure7, measure8, 
measure9, measure10, measure14, measure15, measure16, measure17, measure18, measure19, measure20, measure21]); 



//render song
Renderer.renderSong(song);

console.log(Renderer.pitches);