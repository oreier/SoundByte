const expect = window.chai.expect;

import * as Vex from 'https://cdn.jsdelivr.net/npm/vexflow@4.2.2/build/esm/entry/vexflow.js';
import * as Renderer from '../src/renderer.js';
import * as Types from '../src/customTypes.js';
import * as Helpers from './testHelpers.js';

describe('assembleGraceNotes() tests', () => {
    it('null input', () => {
      var grace = new Types.GraceNote(['a/4'], '8', 2);
      var grace_notes = [grace];
      var notes = Renderer.score.notes('a4/q, a4/q, a4/q, a4/q');
      expect(Renderer.assembleGraceNotes(grace_notes, null)).to.equal(null);
      expect(Renderer.assembleGraceNotes(null, notes)).to.equal(null);
      expect(Renderer.assembleGraceNotes(null, null)).to.equal(null);
    });
    it('invalid index', () => {
      var grace_note1 = new Types.GraceNote(['a/4'], '8', 5);
      var grace_note2 = new Types.GraceNote(['a/4'], 'q', -1);
      var notes = Renderer.score.notes('a4/q, a4, a4, a4');
      var test_notes = notes;

      Renderer.assembleGraceNotes([grace_note1], notes);
      Helpers.compareStemmableNotes(notes, test_notes);

      Renderer.assembleGraceNotes([grace_note2], notes);
      Helpers.compareStemmableNotes(notes, test_notes);
    });
    it('basic grace note', () => {
      var grace_note = new Types.GraceNote(['a/4'], '8', 2);
      var notes = Renderer.score.notes('a4/q, a4, a4, a4');
      var test_notes = notes;

      var grace = new Vex.GraceNote({
        keys: ['a/4'],
        duration: '8',
        slash: true
      });
      var group = new Vex.GraceNoteGroup([grace], true);
      test_notes[2].addModifier(group);

      Renderer.assembleGraceNotes([grace_note], notes);
      Helpers.compareStemmableNotes(notes, test_notes);
    });
  });