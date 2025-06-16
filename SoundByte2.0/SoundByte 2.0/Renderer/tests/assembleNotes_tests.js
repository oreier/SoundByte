const expect = window.chai.expect;

import * as Renderer from '../src/renderer.js';
import * as Types from '../src/customTypes.js';
import * as Helpers from './testHelpers.js';

describe('assembleNotes() tests', () => {
    it('null input', () => {
      expect(() => Renderer.assembleNotes(null)).to.throw("note_groups are null");
    });
    it('empty input', () => {

      var expected = Renderer.score.notes('');

      var actual = Renderer.assembleNotes([]);

      Helpers.compareStemmableNotes(expected, actual);
    });
    it('basic quarter notes', () => {
      var note_group = new Types.NoteGroup('a4/q, a4/q, a4/q, a4/q', false, false);

      var expected = Renderer.score.notes("a4/q, a4, a4, a4");
      var actual = Renderer.assembleNotes([note_group]);

      Helpers.compareStemmableNotes(expected, actual);
    });
    it('all beamed', () => {
      var note_group = new Types.NoteGroup('b4/8, b4/8, b4/8, b4/8', true, false);

      var expected = Renderer.score.beam(Renderer.score.notes('b4/8, b4, b4, b4'), { autoStem: true });
      var actual = Renderer.assembleNotes([note_group]);

      Helpers.compareStemmableNotes(expected, actual);
    });
    it('partially beamed', () => {
      var note_group1 = new Types.NoteGroup('e5/q, e5/q', false, false);
      var note_group2 = new Types.NoteGroup('bb4/8, bb4/8, bb4/8, bb4/8', true, false);

      var expected = Renderer.score.notes('e5/q, e5').concat(Renderer.score.beam(Renderer.score.notes('bb4/8, bb4, bb4, bb4'), { autoStem: true }));
      var actual = Renderer.assembleNotes([note_group1, note_group2]);

      Helpers.compareStemmableNotes(expected, actual);
    });
    it('partially beamed, different rhythms', () => {
      var note_group1 = new Types.NoteGroup("e5/8., bb4/16", true, false);
      var note_group2 = new Types.NoteGroup("a4/q, a4/q, b4/q/r", false, false);

      var expected = Renderer.score.beam(Renderer.score.notes('e5/8., bb4/16'), { autoStem: true }).concat(Renderer.score.notes('a4/q, a4, b4/q/r'));
      var actual = Renderer.assembleNotes([note_group1, note_group2]);

      Helpers.compareStemmableNotes(expected, actual);
    });
    it('stem directions under beam', () => {
      var note_group1 = new Types.NoteGroup('g5/8, a4, a4, a4', true, false);
      var note_group2 = new Types.NoteGroup('a4/q, a4');

      var expected = Renderer.score.beam(Renderer.score.notes('g5/8, a4, a4, a4'), { autoStem: true }).concat(Renderer.score.notes('a4/q, a4'));
      var actual = Renderer.assembleNotes([note_group1, note_group2]);

      Helpers.compareStemmableNotes(expected, actual);
    });
    it('triplets', () => {
      var note_group1 = new Types.NoteGroup('c#5/q, c#5/q, c#5/q', false, false);
      var note_group2 = new Types.NoteGroup('b4/8, b4/8, b4/8', false, true);

      var expected = Renderer.score.notes('c#5/q, c#5, c#5').concat(Renderer.score.tuplet(Renderer.score.beam(Renderer.score.notes('b4/8, b4, b4'), { autoStem: true })));
      var actual = Renderer.assembleNotes([note_group1, note_group2]);

      Helpers.compareStemmableNotes(expected, actual);
    });
    it('rests', () => {
      var note_group = new Types.NoteGroup('c5/q/r, c5/q/r, c5/q/r, c5/q/r', false, false);

      var expected = Renderer.score.notes('c5/q/r, c5/q/r, c5/q/r, c5/q/r');
      var actual = Renderer.assembleNotes([note_group]);

      Helpers.compareStemmableNotes(expected, actual);
    });
    it('multiple beams, tuplets, rhythms', () => {
      var note_group1 = new Types.NoteGroup('a4/q, a4/q, a4/q', false, false);
      var note_group2 = new Types.NoteGroup('bb4/8, bb4/8, bb4/8, bb4/8', true, false);
      var note_group3 = new Types.NoteGroup('c4/8., c5/16', true, false);
      var note_group4 = new Types.NoteGroup('a4/q, a4/8', false, false);
      var note_group5 = new Types.NoteGroup('a4/8, a4/8, a4/8, a4/8, a4/8', true, true);

      var expected = Renderer.score.notes('a4/q, a4/q, a4/q')
        .concat(Renderer.score.beam(Renderer.score.notes('bb4/8, bb4/8, bb4/8, bb4/8'), { autoStem: true }))
        .concat(Renderer.score.beam(Renderer.score.notes('c4/8., c5/16'), { autoStem: true }))
        .concat(Renderer.score.notes('a4/q, a4/8'))
        .concat(Renderer.score.tuplet(Renderer.score.beam(Renderer.score.notes('a4/8, a4/8, a4/8, a4/8, a4/8')), { autoStem: true }));
      var actual = Renderer.assembleNotes([note_group1, note_group2, note_group3, note_group4, note_group5]);

      Helpers.compareStemmableNotes(expected, actual);
    });
    it('error handling', () => {
      var note_group = new Types.NoteGroup("pizza", true, false);
      expect(() => Renderer.assembleNotes([note_group])).to.throw();
    });
  });

mocha.run();
Renderer.initialize(8000);