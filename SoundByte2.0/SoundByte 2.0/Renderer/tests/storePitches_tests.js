const expect = window.chai.expect;

import * as Vex from 'https://cdn.jsdelivr.net/npm/vexflow@4.2.2/build/esm/entry/vexflow.js';
import * as Renderer from '../src/renderer.js';
import * as Types from '../src/customTypes.js';



describe('storePitches() tests', () => {
    beforeEach(() => {
        Renderer.reset(10);
    })
    it('empty input', () => {
        var song = new Types.Song('bass', '4/4', 'Db', 0, []);
        Renderer.renderSong(song);

        var expected = [];
        expect(expected).to.eql(Renderer.pitches);
    });
    it('multimeasure rests', () => {
        var measure = new Types.Measure('5/4', 'Db', [], [], false, false, [], [], 2, [], [], 0);
        var song = new Types.Song('treble', measure.time_sig, measure.key_sig, 10, [measure]);
        Renderer.renderSong(song);

        var note = { note: "0", octave: 0 };
        var expected = [];
        for(let i = 0; i < 250; i++) {
            expected.push(note);
        }

        expect(expected).to.eql(Renderer.pitches);
    });
    it('key signature', () => {
        var notes = new Types.NoteGroup('b4/q, e4, a4, d4');
        var measure = new Types.Measure('4/4', 'Eb', [notes], [], false, false, [], [], 0, [], [], 0); //bb, eb, ab
        var song = new Types.Song('treble', measure.time_sig, measure.key_sig, 4, [measure]);
        Renderer.renderSong(song);

        var expected = [];

        var note = { note: 'B♭', octave: 4 };
        for(let i = 0; i < 25; i++) {
            expected.push(note);
        }
        note = { note: 'E♭', octave: 4 };
        for(let i = 0; i < 25; i++) {
            expected.push(note);
        }
        note = { note: 'A♭', octave: 4 };
        for(let i = 0; i < 25; i++) {
            expected.push(note);
        }
        var note = { note: 'D', octave: 4 };
        for(let i = 0; i < 25; i++) {
            expected.push(note);
        }

        expect(expected).to.eql(Renderer.pitches);
    });
    it('accidentals', () => {
        var notes = new Types.NoteGroup('en4/q, a4, a4, e4');
        var measure = new Types.Measure('4/4', 'Eb', [notes], [], false, false, [], [], 0, [], [], 0); //bb, eb, ab
        var song = new Types.Song('treble', measure.time_sig, measure.key_sig, 4, [measure]);

        Renderer.renderSong(song);

        var expected = [];

        var note = { note: 'E', octave: 4 };
        for(let i = 0; i < 25; i++) {
            expected.push(note);
        }
        note = { note: 'A♭', octave: 4 };
        for(let i = 0; i < 25; i++) {
            expected.push(note);
        }
        note = { note: 'A♭', octave: 4 };
        for(let i = 0; i < 25; i++) {
            expected.push(note);
        }
        var note = { note: 'E', octave: 4 };
        for(let i = 0; i < 25; i++) {
            expected.push(note);
        }

        expect(expected).to.eql(Renderer.pitches);
    });
});