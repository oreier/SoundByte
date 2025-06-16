const expect = window.chai.expect;

import * as Vex from 'https://cdn.jsdelivr.net/npm/vexflow@4.2.2/build/esm/entry/vexflow.js';
import * as Renderer from '../src/renderer.js';
import * as Helpers from './testHelpers.js';

//used to test Renderer.assembleSlurs()
function compareSlurs(expected, actual) {
  Helpers.compareStemmableNotes(expected.from, actual.from);
  Helpers.compareStemmableNotes(expected.to, actual.to);

  expect(expected.render_options.cps).to.eql(actual.render_options.cps);
  expect(expected.render_options.y_shift).to.equal(actual.render_options.y_shift);
}

describe('assembleSlurs() tests', () => {
    it('null input', () => {
      var start = 0;
      var end = 1;
      expect(Renderer.assembleSlur(null, start, end)).to.equal(null);
    });
    it('same start/end', () => {
      const notes = Renderer.score.notes('a4/q, a4, a4, a4, a4, a4, a4');
      expect(Renderer.assembleSlur(notes, 0, 0)).to.equal(null);
      expect(Renderer.assembleSlur(notes, 1, 1)).to.equal(null);
      expect(Renderer.assembleSlur(notes, 6, 6)).to.equal(null);
    });
    it('reverse indeces', () => {
      const notes = Renderer.score.notes('a4/q, a4/q, a4/q, a4/q');
      const system = Renderer.vf.System();
      system.addStave({
        voices: [Renderer.score.voice(notes)]
      });

      var forward = Renderer.assembleSlur(notes, 0, 3);
      var backward = Renderer.assembleSlur(notes, 3, 0);

      expect(forward).to.not.equal(null);
      expect(backward).to.not.equal(null);

      compareSlurs(forward, backward);
    });
    it('invalid indices', () => {
      const notes = Renderer.score.notes('a4/q, a4/q, a4/q, a4/q');
      const system = Renderer.vf.System();
      system.addStave({
        voices: [Renderer.score.voice(notes)]
      });

      expect(Renderer.assembleSlur(notes, -1, 0)).to.equal(null);
      expect(Renderer.assembleSlur(notes, 0, -1)).to.equal(null);
      expect(Renderer.assembleSlur(notes, 5, 0)).to.equal(null);
      expect(Renderer.assembleSlur(notes, 0, 5)).to.equal(null);
    });
    it('basic quarter notes, full slur', () => {
      const notes = Renderer.score.notes('a4/q, a4/q, a4/q, a4/q');
      const system = Renderer.vf.System();
      system.addStave({
        voices: [Renderer.score.voice(notes)]
      });
      var expected = new Vex.Curve(notes[0], notes[3], {
        cps: [
          { x: 0, y: 15 },
          { x: 0, y: 15 }
        ],
        y_shift: 10
      });

      var actual = Renderer.assembleSlur(notes, 0, 3);

      compareSlurs(expected, actual);
    });
    it('basic quarter notes, incomplete slur', () => {
      const notes = Renderer.score.notes('a4/q, a4/q, a4/q, a4/q');
      const system = Renderer.vf.System();
      system.addStave({
        voices: [Renderer.score.voice(notes)]
      });
      var expected = new Vex.Curve(notes[0], notes[2], {
        cps: [
          { x: 0, y: 10 },
          { x: 0, y: 10 }
        ],
        y_shift: 10
      });

      var actual = Renderer.assembleSlur(notes, 0, 2);

      compareSlurs(expected, actual);
    });
    it('tie', () => {
      const notes = Renderer.score.notes('a4/q, a4/q, a4/q, a4/q');
      const system = Renderer.vf.System();
      system.addStave({
        voices: [Renderer.score.voice(notes)]
      });
      var expected = new Vex.Curve(notes[1], notes[2], {
        cps: [
          { x: 0, y: 5 },
          { x: 0, y: 5 }
        ],
        y_shift: 10
      });

      var actual = Renderer.assembleSlur(notes, 1, 2);

      compareSlurs(expected, actual);
    });
    it('beamed notes, high middle', () => {
      const notes = Renderer.score.beam(Renderer.score.notes('a4/8, g5/8, a4/8, a4/8'), { autoStem: true }).concat(Renderer.score.notes('a4/q, a4/q'));
      const system = Renderer.vf.System();
      system.addStave({
        voices: [Renderer.score.voice(notes)]
      });
      var expected = new Vex.Curve(notes[0], notes[3], {
        cps: [
          { x: 0, y: 15 },
          { x: 0, y: 15 }
        ],
        y_shift: 30
      });

      var actual = Renderer.assembleSlur(notes, 0, 3);

      compareSlurs(expected, actual);
    });
    it('beamed notes, low middle', () => {
      const notes = Renderer.score.beam(Renderer.score.notes('a4/8, a3/8, a4/8, a4/8'), { autoStem: true }).concat(Renderer.score.notes('a4/q, a4/q'));
      const system = Renderer.vf.System();
      system.addStave({
        voices: [Renderer.score.voice(notes)]
      });
      var expected = new Vex.Curve(notes[0], notes[3], {
        cps: [
          { x: 0, y: 15 },
          { x: 0, y: 15 }
        ],
        y_shift: 35
      });

      var actual = Renderer.assembleSlur(notes, 0, 3);

      compareSlurs(expected, actual);
    });
  });