const expect = window.chai.expect;

import * as Vex from 'https://cdn.jsdelivr.net/npm/vexflow@4.2.2/build/esm/entry/vexflow.js';
import * as Renderer from '../src/renderer.js';
import * as Types from '../src/customTypes.js';

function compareHairpins(expected, actual) {
    expect(expected.hairpin).to.equal(actual.hairpin);
    expect(expected.notes).to.eql(actual.notes);
    expect(expected.render_options).to.eql(actual.render_options);
}

describe('assembleHairpin() test', () => {
    it('null input', () => {
        var notes = Renderer.score.notes('a4/q, a4, a4, a4');
        var hairpin = new Types.Hairpin(0, 3, 1);

        expect(Renderer.assembleHairpin(notes, null)).to.equal(null);
        expect(Renderer.assembleHairpin(null, hairpin)).to.equal(null);
    });
    it('crescendo', () => {
        var notes = Renderer.score.notes('a4/q, a4, a4, a4');
        var hairpin = new Types.Hairpin(0, 3, 1);

        var expected = new Vex.StaveHairpin({first_note: notes[0], last_note: notes[3]}, 1);
        expected.render_options.y_shift = Renderer.hairpinShift;
        var actual = Renderer.assembleHairpin(notes, hairpin);

        compareHairpins(expected, actual);
    });
    it('decrescendo', () => {
        var notes = Renderer.score.notes('a4/q, a4, a4, a4');
        var hairpin = new Types.Hairpin(0, 3, 2);

        var expected = new Vex.StaveHairpin({first_note: notes[0], last_note: notes[3]}, 2);
        expected.render_options.y_shift = Renderer.hairpinShift;
        var actual = Renderer.assembleHairpin(notes, hairpin);

        compareHairpins(expected, actual);
    });
    it('error handling', () => {
        var notes = Renderer.score.notes('a4/q, a4, a4, a4');
        var hairpin = new Types.Hairpin(0, 3, 1);
        var hairpin2 = new Types.Hairpin(-1, 5, notes);

        expect(Renderer.assembleHairpin(4, hairpin)).to.equal(null);
        expect(Renderer.assembleHairpin(notes, hairpin2)).to.equal(null);
    });
});