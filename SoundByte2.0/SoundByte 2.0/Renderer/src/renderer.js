/*
The functions to actually render the music
*/

//import necessary VexFlow / EasyScore types
import * as Vex from 'https://cdn.jsdelivr.net/npm/vexflow@4.2.2/build/esm/entry/vexflow.js';

//VexFlow Objects
export var vf;
export var score;

//variables to keep track of the current state
export var currentX = 10; //where the next measure will be rendered
export var pixelsPerBeat = 150; //the next three are arbitrarily hardcoded, modify to the desired format
export var lyricLine = 11;
export var hairpinShift = -110;

//for grading purposes
export var pitches = [];
var timeStep = 0.02;
var tempo = 120;
var beatsToQuantity = (1 / tempo) * (60 / 1) * (1 / timeStep); //convert beats to number of entries in pitches array
var previousIndex = 0; //used to keep track of the current index for smoothing out half indices

//unfortunately needed to reset between tests (exports are read only)
export function reset(newX) {
    currentX = newX;
    pitches = [];
}

//create values for vf and score
export function initialize(numBeats) {
    vf = new Vex.Factory({ renderer: { elementId: "output", width: pixelsPerBeat * numBeats + 15, height: 150 } });
    score = vf.EasyScore();
}

//turn a measure"s contents into a renderable StemmableNote[] array
//take each chunk, add it's respective characteristics (tuplet, beam, etc.) and concatenate it to the overall notes to be renderred
export function assembleNotes(note_groups) {
    if(!note_groups) { throw new Error("note_groups are null"); } //no try catch, since no notes is too problematic

    var notes = score.notes("");
    note_groups.forEach(function (note_group) {
        if (note_group.is_tuplet) {
            notes = notes.concat(score.tuplet(score.beam(score.notes(note_group.notes), { autoStem: true }), { ratioed: false })); //no ratio over tuplets, like 5:2
        }
        else if (note_group.is_beamed) {
            notes = notes.concat(score.beam(score.notes(note_group.notes), { autoStem: true })); //autoStem so beams go right direction
        } else {
            notes = notes.concat(score.notes(note_group.notes));
        }
    });

    return notes;
}

//construct an array of Lyrics so we can create a voice in assembleMeasure()
export function assembleLyrics(lyrics) {
    try {
        if(!lyrics) { throw new Error("lyrics are null"); }

        var assembled_lyrics = [];
        lyrics.forEach(function (lyric) {

            //lyrics cannot have dotted rhythms by default, we have to manually update the ticks
            //durations are given to us in the same format as regular notes, so we have to extract any dots
            var duration;
            var dotIndex = lyric.duration.indexOf('.');
            if(dotIndex < 0) { duration = lyric.duration; } //if no dots, just use the given duration
            else { duration = lyric.duration.substring(0, dotIndex); } //if dots, grab everything but the dots ('q', '8', '32', etc.)

            var text = new Vex.TextNote({
                text: lyric.text,
                duration: duration, 
                line: lyricLine //vertical placement, higher number = lower on screen
            }).setJustification(Vex.TextNote.Justification.CENTER);

            if(lyric.notes_in_tuplet != 0) { //adjust tick duration to match tuplet   
                text.applyTickMultiplier(2, lyric.notes_in_tuplet); 
            }

            if(dotIndex > 0) { //adjust tick duration to account for any dots
                var numDots = lyric.duration.substring(dotIndex, lyric.duration.length).length;
                var numerator = 2 - Math.pow(0.5, numDots); //sum the geometric series to find multiplier, i.e. 1 dot = 1, 2 dots = 1.5, 3 is 1.75...
                text.applyTickMultiplier(numerator, 1);
            }

            assembled_lyrics.push(text);
        });

        return assembled_lyrics;
    }
    catch (error) {
        console.log(error);
        return null;
    }
}

//construct an array to be turned into a voice for the dynamics, very similar to assembling lyrics
export function assembleDynamics(dynamics) {
    if (!dynamics) { return null; } //dynamics can be null, no need to throw an error

    try {
        var assembledDynamics = [];
        dynamics.forEach(function (dynamic) {

            //dynamics, like lyrics cannot have dotted rhythms by default, we have to manually update the ticks
            //durations are given to us in the same format as regular notes, so we have to extract any dots
            var duration;
            var dotIndex = dynamic.duration.indexOf('.');
            if(dotIndex < 0) { duration = dynamic.duration; } //no dots, so use given duration
            else { duration = dynamic.duration.substring(0, dotIndex); } //dots, so only grab base duration

            var text = new Vex.TextDynamics({
                text: dynamic.text,
                duration: duration
            });

            if(dynamic.notes_in_tuplet != 0) { //handle tupleted rhythms
                text.applyTickMultiplier(2, dynamic.notes_in_tuplet);
            }

            if(dotIndex > 0) { //handle dotted rhythms
                var numDots = dynamic.duration.substring(dotIndex, dynamic.duration.length).length;
                var numerator = 2 - Math.pow(0.5, numDots);
                text.applyTickMultiplier(numerator, 1);
            }

            assembledDynamics.push(text);
        });

        return assembledDynamics;
    }
    catch (error) {
        console.log(error);
        return null;
    }
}

//actually construct the measure with all it's modifiers
export function assembleMeasure(song, measure) {
    //handle null input
    if (!song) { throw new Error("song is null"); } //this one is too problematic to continue
    if (!measure) { throw new Error("measure is null"); } 

    try {
        //grab information to render voices
        var notes = null;
        if(measure.measure_rests == 0) {
            notes = assembleNotes(measure.note_groups);
        }
        var lyrics = assembleLyrics(measure.lyrics);
        var dynamics = assembleDynamics(measure.dynamics);

        //set the system width based on number of beats (if no time signature visible, error)
        var calculatedWidth = pixelsPerBeat;
        if (measure.time_sig) { calculatedWidth *= measure.time_sig[0]; } //multiply by number of beats in the measure
        else if (song.time_sig) { calculatedWidth *= song.time_sig[0]; } //or grab whatever the current time signture is
        else { throw new Error("no time signature available"); }
        if (measure.measure_rests != 0) { calculatedWidth *= measure.measure_rests; }

        //handle whole measure rests (centering, must be 4/4 but not display time sig)
        var isWholeRest = false;
        var internalTimeSig = measure.time_sig;
        if (notes && notes.length == 1 && notes[0].duration == 'w' && notes[0].noteType == 'r') {
            notes[0].x_shift = calculatedWidth / 2 - 11.4; //center rest (11.4 is the width of the whole rest glyph)
            internalTimeSig = '4/4'; //whole rests only work properly in 4/4
            isWholeRest = true; //so we can keep track of needing to display the time signature or not
        }

        //construct the voices
        var assembledVoices = [];
        var voiceOptions = { time: (internalTimeSig == null) ? song.time_sig : internalTimeSig } //if measure.time_sig is null, we default to the current time signature, stored in song
        if (notes && notes.length != 0) { assembledVoices.push(score.voice(notes, voiceOptions)); }
        if (lyrics && lyrics.length != 0) { assembledVoices.push(score.voice(lyrics, voiceOptions)); }
        if (dynamics && dynamics.length != 0) { assembledVoices.push(score.voice(dynamics, voiceOptions)); }

        //make system and attach stave + voices
        var system = vf.System({ width: calculatedWidth, x: currentX });
        const stave = system.addStave({
            voices: assembledVoices
        });

        currentX += system.options.width; //update where we render the next measure

        addStaveModifiers(stave, song, measure);
        assembleGraceNotes(measure.grace_notes, notes);

        //grab slurs/ties (stored back in the list they're indexed from for easy access later when drawing)
        if (measure.slur_indices) {
            for (let i = 0; i < measure.slur_indices.length; i++) {
                measure.slur_indices[i] = assembleSlur(notes, measure.slur_indices[i][0], measure.slur_indices[i][1]);
            }
        }

        //grab hairpins, same as slurs
        if (measure.hairpins) {
            for (let i = 0; i < measure.hairpins.length; i++) {
                measure.hairpins[i] = assembleHairpin(notes, measure.hairpins[i]);
            }
        }

        //add to the list of pitches for comparing against user's pitch later
        storePitches(song, measure, notes, isWholeRest);

        return system;
    }
    catch (error) {
        console.error("Error at measure: " + measure.measure_number);
        console.log(error);
        return null;
    }
}

//add to pitches for grading purposes
//The app saves the user's pitch at a regular interval, defined here in timeStep. While rendering a song we construct a similar array
//of the target pitches, adding notes multiple times depending on their duration for easy comparison later.
//no try catch because if done improperly, this messes up grading
function storePitches(song, measure, notes, isWholeRest) {
    if (song.key_sig == null) { throw new Error("song.key_sig is null"); } //song key sig should be set to measure key sig by now, if not, we have a problem, and cannot do grading

    var key = new Vex.KeyManager(song.key_sig).scaleMap; //maps note values to accidentals based on key signature

    if (notes && notes.length != 0) {
        notes.forEach(function (note) { 
            var noteValue = note.keys[0].split('/')[0];
            var octave = note.keys[0].split('/')[1];

            if (noteValue.length == 1) {
                noteValue = key[noteValue]; //if there are no accidentals, apply any accidentals from key signature
            }
            else {
                key[noteValue[0]] = noteValue; //if there are accidentals, update internal key signature so the accidental persists for the rest of the measure
            }

            //swap out accidental symbols to match the grader's format (note that javascript strings are immutable)
            for (let i = 1; i < noteValue.length; i++) {
                switch (noteValue[i]) { 
                    case 'n':
                        noteValue = noteValue.substring(0, i) + noteValue.substring(i + 1, noteValue.length);
                        break;
                    case '#':
                        noteValue = noteValue.substring(0, i) + '♯' + noteValue.substring(i + 1, noteValue.length);
                        break;
                    case 'b':
                        noteValue = noteValue.substring(0, i) + '♭' + noteValue.substring(i + 1, noteValue.length);
                        break;
                }
            }

            var pitch = { note: noteValue.toUpperCase(), octave: parseInt(octave) }; //the form needed in Swift for the grader

            if (note.noteType == 'r') { //0's will indicate rests
                pitch.note = '0';
            }

            var wholeTicks = 16384; //ticks for a whole note
            var ticksPerBeat = wholeTicks / song.time_sig[2]; // (whole) * (timeSigNum / timeSigDen) = ticks in the measure, divide by timeSigNum (the number of beats) to get ticks/beat
            var noteTicks = note.ticks.numerator / note.ticks.denominator;

            var beats;
            if (isWholeRest) { 
                beats = song.time_sig[0]; //since the ticks will be stuck at a whole note in 4/4 otherwise
            }
            else {
                beats = noteTicks / ticksPerBeat; //using the ticks, calculate the number of beats the note takes up
            }

            var numPitches = beats * beatsToQuantity; //convert from beats to number of entries in the pitches array

            //clamp the number of times added so even if individual notes are off (from being added 0.5 times for instance)
            //we still have the right number of items within 1 index. 
            var roundedNumPitches = Math.ceil(previousIndex + numPitches) - Math.ceil(previousIndex);
            previousIndex += numPitches;

            for (let i = 0; i < roundedNumPitches; i++) {
                pitches.push(pitch);
            }
        });
    }
    else if (measure.measure_rests != 0) { //handle multimeasure rests (rests are considered '0's in the grader)
        var beats = measure.measure_rests * song.time_sig[0];
        var numPitches = beats * beatsToQuantity;
        previousIndex += numPitches;

        var pitch = { note: '0', octave: 0 };

        for (let i = 0; i < numPitches; i++) {
            pitches.push(pitch);
        }
    }
}

//attach modifiers like time signature, key signature, measure number, repeats, and full measure rests
function addStaveModifiers(stave, song, measure) {
    if(!stave) { throw new Error("stave is null"); } //we've already checked song and measure

    stave.setMeasure(measure.measure_number)

    //hand time/key changes and the formatting along with them as well as initial rendering of clef
    if (measure.time_sig) {
        stave.addTimeSignature(measure.time_sig);
        song.time_sig = measure.time_sig;
    }
    if (measure.key_sig) {
        stave.addModifier(new Vex.Barline((stave.keySignature == measure.key_sig) ? Vex.BarlineType.NONE : Vex.BarlineType.SINGLE)); //add another barline to indicate key change
        stave.addKeySignature(measure.key_sig);
        song.key_sig = measure.key_sig;
    }
    if (measure.measure_number == 1 && song.clef) {
        stave.addClef(song.clef);
    }
    if (measure.is_repeat_start) {
        stave.setBegBarType(Vex.BarlineType.REPEAT_BEGIN);
    }
    if (measure.is_repeat_end) {
        stave.setEndBarType(Vex.BarlineType.REPEAT_END);
    }
    if (measure.measure_rests != 0) {
        var rest = vf.MultiMeasureRest({ number_of_measures: measure.measure_rests });
        rest.setStave(stave);
    }
    if(Math.abs(vf.context.width - currentX) < 10) { //add final barline once we get close enough
        stave.setEndBarType(Vex.BarlineType.END);
    }
}

//attach any grace notes to their respective notes from the measure
export function assembleGraceNotes(grace_notes, notes) {
    if (!grace_notes || !notes) { return null; }

    try {
        grace_notes.forEach(function (grace_note) {
            if (grace_note.index < 0 || grace_note.index >= notes.length) { throw new Error("invalid grace note index"); }

            var pitch = grace_note.keys[0].split('/')[0]; //keys will be in form "pitch/octave"

            var grace = new Vex.GraceNote({
                keys: grace_note.keys,
                duration: grace_note.duration,
                slash: true
            });

            if(pitch.length > 1) { //regardless of the key, we have to manually add the accidentals if any
                grace.addModifier(new Vex.Accidental(pitch.substring(1, pitch.length)));
            }

            var group = new Vex.GraceNoteGroup([grace], true);

            notes[grace_note.index].addModifier(group);
        });
    }
    catch (error) {
        console.log(error);
        return null;
    }
}

//create and format a slur, has functionality for ties across bars
export function assembleSlur(notes, startIndex, endIndex) {
    try { //slurs are non essential, so we catch it here
        if (!notes) { return null; } 
        if (startIndex < 0 || startIndex >= notes.length) { throw new Error("invalid curve indices"); } //or invalid indices
        if (endIndex < 0 || endIndex >= notes.length) { throw new Error("invalid curve indices"); }
        if (startIndex == endIndex) { throw new Error("curve indices cannot be the same"); } //or same index

        if (startIndex > endIndex && endIndex != null) { //make sure starting and ending indices are in correct order
            var temp = startIndex;
            startIndex = endIndex;
            endIndex = temp;
        }

        var endNote;

        if (!endIndex) { //this indicates a tie to the next bar
            var split_note = notes[startIndex].keys[0].split("/"); 
            endNote = score.notes(split_note[0] + split_note[1] + "/w")[0]; //invisible note, same pitch, whole note
            endNote.setStyle({ fillStyle: 'transparent', strokeStyle: 'transparent' });

            const dummy = vf.System({ x: currentX }); //dummy bar to sit behind next bar
            dummy.addStave({
                voices: [score.voice([endNote])],
                options: {
                    right_bar: false
                }
            });
            vf.draw();
        }
        else {
            endNote = notes[endIndex];
        }

        //find the note that's furthest vertically from the other notes so we can adjust the y_shift accordingly
        var furthestDist = 0;
        for (let i = 0; i < notes.length; i++) {
            if (Math.abs(notes[i].getYs() - notes[startIndex].getYs()) > Math.abs(furthestDist)) {
                furthestDist = notes[i].getYs() - notes[startIndex].getYs();
            }
        }

        //create the slur itself
        var slur = new Vex.Curve(notes[startIndex], endNote, { //most unhappy with this code, not for cleanliness but some slurs just look funky
            cps: [
                { x: 0, y: (((endIndex) ? endIndex : notes.length) - startIndex) * 5 }, //these are points on a bezier curve probably need to take furthestDist into account
                { x: 0, y: (((endIndex) ? endIndex : notes.length) - startIndex) * 5 }, //x is always zero, but we shift the y higher to fit more notes easier
            ],
            //shift to accomodate all notes under the slur. stem_direction is 1 for up, -1 for down, 
            y_shift: (notes[startIndex].stem_direction * furthestDist > 0) ? Math.abs(furthestDist) : 10,
        });

        //attach needed rendering context so we can draw it later
        slur.setContext(vf.getContext());
        return slur;
    }
    catch (error) {
        console.log(error);
        return null;
    }
}

//create crescendo/decrescendo, similar to slurs, just attach the start and endpoint plus the type
export function assembleHairpin(notes, hairpin) {
    if (!hairpin || !notes) { return null; }

    try {
        var staveHairpin;
        staveHairpin = new Vex.StaveHairpin({
            first_note: notes[hairpin.start_index],
            last_note: notes[hairpin.end_index]
        }, hairpin.type); //1 for crescendo, 2 for decrescendo

        staveHairpin.render_options.y_shift = hairpinShift; //render above the stave, negative moves it higher

        staveHairpin.setContext(vf.getContext()); //save current context so we can draw it later
        return staveHairpin;
    }
    catch (error) {
        console.log(error);
        return null;
    }
}

//assemble each measure one at a time, then draw each one
export function renderSong(song) {

    initialize(song.total_beats); //initialize renderer with dynamic width

    song.measures.forEach(function (measure) { //iteratively render each measure and it's features
        try {
            if (measure) {
                assembleMeasure(song, measure);
                vf.draw();
                measure.slur_indices.forEach(function (slur) { //annoyingly all slurs must be drawn after a vf.draw() call
                    if (slur) { slur.draw(); } //these slurs are no longer indices, assembleSlur replaces them with the actual Curves
                });
                measure.hairpins.forEach(function (hairpin) {
                    if (hairpin) { hairpin.draw(); } //same here, this is an actual StaveHairpin now
                });
            }
        }
        catch (error) {
            console.log(error);

            //reset vf so the error doesn't persist
            vf.systems = [];
            vf.renderQ = [];
            vf.staves = [];
            vf.voices = [];
        }
    });
}
