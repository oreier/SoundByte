//data structures to store info from the MusicXML file

export class Song {
    constructor(clef, time_sig, key_sig, total_beats, measures) {
        this.clef = clef; //"treble", "bass", etc.
        this.time_sig = time_sig; //"4/4", "6/8", etc.
        this.key_sig = key_sig;
        this.total_beats = total_beats
        this.measures = measures;
    }
}

export class Measure {
    constructor(time_sig, key_sig, note_groups, slur_indices, is_repeat_start, is_repeat_end, lyrics, grace_notes, measure_rests, hairpins, dynamics, measure_number) {
        this.time_sig = time_sig;
        this.key_sig = key_sig; //"Fb", "Dm", etc.
        this.note_groups = note_groups;
        this.slur_indices = slur_indices; //array of [from, to]'s
        this.is_repeat_start = is_repeat_start;
        this.is_repeat_end = is_repeat_end;
        this.lyrics = lyrics;
        this.grace_notes = grace_notes;
        this.measure_rests = measure_rests; //0 for regular measure, nonzero for that amount of full measure rests
        this.hairpins = hairpins;
        this.dynamics = dynamics;
        this.measure_number = measure_number;
    }
}

export class NoteGroup {
    constructor(notes, is_beamed, is_tuplet) {
        this.notes = notes; //string of notes, ready to be passed to score.notes()
        this.is_beamed = is_beamed;
        this.is_tuplet = is_tuplet;
    }
}

export class Text {
    constructor(text, duration, notes_in_tuplet) {
        this.text = text;
        this.duration = duration; //"q", "w", "8", etc.
        this.notes_in_tuplet = notes_in_tuplet;
    }
}

export class GraceNote{
    constructor(keys, duration, index) {
        this.keys = keys; //['a/4'], etc.
        this.duration = duration; //"q", "w", "8", etc.
        this.index = index;
    }
}

export class Hairpin{
    constructor(start_index, end_index, type) {
        this.start_index = start_index;
        this.end_index = end_index;
        this.type = type; //1 for crescendo, 2 for decrescendo  
    }
}