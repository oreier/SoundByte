const expect = window.chai.expect;

import * as Vex from 'https://cdn.jsdelivr.net/npm/vexflow@4.2.2/build/esm/entry/vexflow.js';
import * as Renderer from '../src/renderer.js';
import * as Types from '../src/customTypes.js';
import * as Helpers from './testHelpers.js';

//compare two vf.System()'s, used to test assembleMeasure() output
function compareSystems(expected, actual) {
  expect(expected.options.width).to.equal(actual.options.width);
  expect(expected.options.x).to.equal(actual.options.x);
  expect(expected.options.y).to.equal(actual.options.y);

  expect(expected.partStaveInfos.length).to.equal(actual.partStaveInfos.length);
  for (let i = 0; i < expected.partStaveInfos.length; i++) {
    expect(expected.partStaveInfos[i].options).to.eql(actual.partStaveInfos[i].options);
  }

  expect(expected.partStaves.length).to.equal(actual.partStaves.length);
  for (let i = 0; i < expected.partStaves.length; i++) {
    expect(expected.partStaves[i].clef).to.equal(actual.partStaves[i].clef);
    expect(expected.partStaves[i].measure).to.equal(actual.partStaves[i].measure);

    compareSystemModifiers(expected.partStaves[i].modifiers, actual.partStaves[i].modifiers);
  }

  compareSystemVoices(expected.partVoices, actual.partVoices);
}

//when rendering a Types.measure, it generates a voice, we have to ensure they match
function compareSystemVoices(expected, actual) {
  expect(expected.length).to.equal(actual.length);
  for (let i = 0; i < expected.length; i++) {
    expect(expected[i].time).to.eql(actual[i].time);
    Helpers.compareStemmableNotes(expected[i].tickables, actual[i].tickables);
  }
}

//when rendering a Types.measure, the resulting system has a few modifiers, time, key, etc. we need to compare
function compareSystemModifiers(expected, actual) {
  expect(expected.length).to.equal(actual.length);
  for (let j = 0; j < expected.length; j++) {
    expect(expected[j].attrs.type).to.equal(actual[j].attrs.type);
    switch (expected[j].attrs.type) {
      case 'TimeSignature':
        expect(expected[j].timeSpec).to.equal(actual[j].timeSpec);
        break;
      case 'KeySignature':
        expect(expected[j].keySpec).to.equal(actual[j].keySpec);
        break;
      case 'Vex.Barline':
        expect(expected[j].position).to.equal(actual[j].position);
        break;
    }
  }
}

describe('assembleMeasure() tests', () => {

  //hooks here, before, beforeeach, after, aftereach
  beforeEach(function () { //will run before each it()
    Renderer.reset(10);
  });

  it('null input', () => {
    var measure = new Types.Measure(null, null, [], false, false, [], [], 0, [], [], 1);
    var song = new Types.Song(null, null, 'C', 0, [measure]);
    expect(() => Renderer.assembleMeasure(song, null)).to.throw("measure is null");
    expect(() => Renderer.assembleMeasure(null, measure)).to.throw("song is null");
    expect(() => Renderer.assembleMeasure(null, null)).to.throw("song is null");
  });
  it('empty input', () => {
    var measure = new Types.Measure(null, null, [], null, false, false, [], [], 0, [], [], 20);
    var song = new Types.Song(null, null, 'C', 0, [measure]);

    expect(Renderer.assembleMeasure(song, measure)).to.equal(null);

    measure = new Types.Measure('4/4', null, [], null, false, false, [], [], 0, [], [], 20);
    song = new Types.Song(null, null, 'C', 0, [measure]);

    var width = Renderer.pixelsPerBeat * 4;
    var expected = Renderer.vf.System({ width: width });
    expected.addStave({
      voices: []
    }).setMeasure(20).addTimeSignature("4/4");

    var actual = Renderer.assembleMeasure(song, measure);

    compareSystems(expected, actual);
  });
  it('width', () => {
    var measure1 = new Types.Measure('4/4', null, [], [], false, false, [], [], 0, [], [], 1);
    var measure2 = new Types.Measure('5/4', null, [], [], false, false, [], [], 0, [], [], 1);
    var measure3 = new Types.Measure('6/8', null, [], [], false, false, [], [], 0, [], [], 1);
    var measure4 = new Types.Measure('4/4', null, [], [], false, false, [], [], 3, [], [], 1);
    var measure5 = new Types.Measure(null, null, [], [], false, false, [], [], 0, [], [], 1);
    var song = new Types.Song(null, '7/8', 'C', 19, [measure1, measure2, measure3, measure4]);

    var expected1 = Renderer.vf.System({width: Renderer.pixelsPerBeat * 4, x: 10});
    expected1.addStave({
      voices: []
    }).setMeasure(1).addTimeSignature('4/4');

    var expected2 = Renderer.vf.System({width: Renderer.pixelsPerBeat * 5, x: expected1.options.x + expected1.options.width});
    expected2.addStave({
      voices: []
    }).setMeasure(1).addTimeSignature('5/4');

    var expected3 = Renderer.vf.System({width: Renderer.pixelsPerBeat * 6, x: expected2.options.x + expected2.options.width});
    expected3.addStave({
      voices: []
    }).setMeasure(1).addTimeSignature('6/8');

    var expected4 = Renderer.vf.System({width: Renderer.pixelsPerBeat * 12, x: expected3.options.x + expected3.options.width});
    expected4.addStave({
      voices: []
    }).setMeasure(1).addTimeSignature('4/4');

    var expected5 = Renderer.vf.System({width: Renderer.pixelsPerBeat * 4, x: expected4.options.x + expected4.options.width});
    expected5.addStave({
      voices: []
    }).setMeasure(1);

    var actual1 = Renderer.assembleMeasure(song, measure1);
    var actual2 = Renderer.assembleMeasure(song, measure2);
    var actual3 = Renderer.assembleMeasure(song, measure3);
    var actual4 = Renderer.assembleMeasure(song, measure4);
    var actual5 = Renderer.assembleMeasure(song, measure5);

    compareSystems(expected1, actual1);
    compareSystems(expected2, actual2);
    compareSystems(expected3, actual3);
    compareSystems(expected4, actual4);
    compareSystems(expected5, actual5);
  });
  it('time signature', () => {
    var measure = new Types.Measure('6/8', null, [], null, false, false, [], [], 0, [], [], 1);
    var song = new Types.Song(null, measure.time_sig, 'C', 6, [measure]);

    var width = Renderer.pixelsPerBeat * 6;
    var expected = Renderer.vf.System({ width: width });
    expected.addStave({
      voices: []
    }).setMeasure(1).addTimeSignature('6/8');

    var actual = Renderer.assembleMeasure(song, measure);

    compareSystems(expected, actual);
  });
  it('key signature', () => {
    var measure = new Types.Measure('4/4', 'Db', [], null, false, false, [], [], 0, [], [], 1);
    var song = new Types.Song(null, null, 'C', 0, [measure]);

    var width = Renderer.pixelsPerBeat * 4;
    var expected = Renderer.vf.System({ width: width });
    expected.addStave({
      voices: []
    }).setMeasure(1).addTimeSignature('4/4').addModifier(new Vex.Barline(Vex.BarlineType.NONE)).addKeySignature('Db');

    var actual = Renderer.assembleMeasure(song, measure);

    compareSystems(expected, actual);
  });
  it('key change', () => {
    var measure1 = new Types.Measure('4/4', 'Db', [], null, false, false, [], [], 0, [], [], 0);
    var measure2 = new Types.Measure(null, 'C', [], null, false, false, [], [], 0, [], [], 0);
    var song = new Types.Song(null, null, 'C', 0, [measure1, measure2]);

    var width = Renderer.pixelsPerBeat * 4;
    var expected1 = Renderer.vf.System({ width: width });
    expected1.addStave({
      voices: []
    }).setMeasure(0).addTimeSignature('4/4').addModifier(new Vex.Barline(Vex.BarlineType.NONE)).addKeySignature('Db');

    var expected2 = Renderer.vf.System({ width: width, x: 10 + width });
    expected2.addStave({
      voices: []
    }).setMeasure(0).addModifier(new Vex.Barline(Vex.BarlineType.SINGLE)).addKeySignature('C');

    var actual1 = Renderer.assembleMeasure(song, measure1);
    var actual2 = Renderer.assembleMeasure(song, measure2);

    compareSystems(expected1, actual1);
    compareSystems(expected2, actual2);

  });
  it('clef', () => {
    var measure = new Types.Measure('4/4', null, [], null, false, false, [], [], 0, [], [], 1);
    var song = new Types.Song("treble", null, 'C', 0, [measure]);

    var width = Renderer.pixelsPerBeat * 4;
    var expected = Renderer.vf.System({ width: width });
    expected.addStave({
      voices: []
    }).setMeasure(1).addTimeSignature('4/4').addClef("treble");

    var actual = Renderer.assembleMeasure(song, measure);

    compareSystems(expected, actual);
  });
  it('clef, time signature, key signature', () => {
    var measure = new Types.Measure('5/4', 'C#', [], null, false, false, [], [], 0, [], [], 1);
    var song = new Types.Song('treble', measure.time_sig, 'C', 5, [measure]);

    var width = Renderer.pixelsPerBeat * 5;
    var expected = Renderer.vf.System({ width: width });
    expected.addStave({
      voices: []
    }).setMeasure(1).addTimeSignature(measure.time_sig).addModifier(new Vex.Barline(Vex.BarlineType.NONE)).addKeySignature(measure.key_sig).addClef(song.clef);

    var actual = Renderer.assembleMeasure(song, measure);

    compareSystems(expected, actual);
  });
  it('x position', () => {
    var measure1 = new Types.Measure('4/4', null, [], null, false, false, [], [], 0, [], [], 1);
    var measure2 = new Types.Measure(null, null, [], null, false, false, [], [], 0, [], [], 2);
    var measure3 = new Types.Measure(null, null, [], null, false, false, [], [], 0, [], [], 3);
    var song = new Types.Song('treble', measure1.time_sig, 'C', 12, [measure1, measure2, measure3]);

    var width = Renderer.pixelsPerBeat * 4;
    var expected = Renderer.vf.System({ width: width, x: 10 +  (2 * width) });
    expected.addStave({
      voices: []
    }).setMeasure(3);

    expect(Renderer.assembleMeasure(song, measure1)).to.not.equal(null); //will have a width with info
    expect(Renderer.assembleMeasure(song, measure2)).to.not.equal(null); //will have a regular width

    var actual = Renderer.assembleMeasure(song, measure3);

    compareSystems(expected, actual);
  });
  it('basic notes', () => {
    var note_group = new Types.NoteGroup('a4/q, a4/q, a4/q, a4/q', false, false);
    var measure = new Types.Measure(null, null, [note_group], null, false, false, [], [], 0, [], [], 0);
    var song = new Types.Song(null, '4/4', 'C', 0, [measure]);

    var width = Renderer.pixelsPerBeat * 4;
    var expected = Renderer.vf.System({ width: width });
    expected.addStave({
      voices: [Renderer.score.voice(Renderer.score.notes('a4/q, a4/q, a4/q, a4/q'))]
    }).setMeasure(0);

    var actual = Renderer.assembleMeasure(song, measure);

    compareSystems(expected, actual);
  });
  it('clef, time, key, notes', () => {
    var note_group = new Types.NoteGroup("a5/8, g#5/8, f#5/8, e5/8", true, false);
    var measure = new Types.Measure('5/4', 'C#', [note_group], null, false, false, [], [], 0, [], [], 1);
    var song = new Types.Song('treble', measure.time_sig, 'C', 5, [measure]);

    var width = Renderer.pixelsPerBeat * 5;
    var expected = Renderer.vf.System({ width: width });
    expected.addStave({
      voices: [Renderer.score.voice(Renderer.score.beam(Renderer.score.notes("a5/8, g#5/8, f#5/8, e5/8")), { time: measure.time_sig })]
    }).setMeasure(1).addTimeSignature(measure.time_sig).addModifier(new Vex.Barline(Vex.BarlineType.NONE)).addKeySignature(measure.key_sig).addClef(song.clef);

    var actual = Renderer.assembleMeasure(song, measure);

    compareSystems(expected, actual);
  });
  it('repeats', () => {
    var note_group1 = new Types.NoteGroup('a4/q, a4/q, a4/q, a4/q', false, false);
    var note_group2 = new Types.NoteGroup('a4/8, b4/8, c5/8, d5/8', true, false);
    var note_group3 = new Types.NoteGroup('a4/q, a4/q', false, false);

    var measure1 = new Types.Measure('4/4', 'C', [note_group1], [], true, false, [], [], 0, [], [], 1);
    var measure2 = new Types.Measure(null, null, [note_group2, note_group3], [[0, 3]], false, true, [], [], 0, [], [], 2);
    var song = new Types.Song("treble", '4/4', 'C', 8, [measure1, measure2]);

    var width = Renderer.pixelsPerBeat * 4;
    var expected1 = Renderer.vf.System({ width: width });
    expected1.addStave({
      voices: [Renderer.score.voice(Renderer.score.notes('a4/q, a4/q, a4/q, a4/q'), { time: '4/4' })]
    }).setMeasure(1).addTimeSignature('4/4').addModifier(new Vex.Barline(Vex.BarlineType.NONE)).addKeySignature('C').addClef('treble')
      .setBegBarType(Vex.BarlineType.REPEAT_BEGIN);

    var expected2 = Renderer.vf.System({ width: width, x: 10 + width });
    expected2.addStave({
      voices: [Renderer.score.voice(Renderer.score.beam(Renderer.score.notes('a4/8, b4/8, c5/8, d5/8'), { autoStem: true }).concat(Renderer.score.notes('a4/q, a4/q')), { time: '4/4' })]
    }).setMeasure(2).setBegBarType(Vex.BarlineType.REPEAT_END);

    var actual1 = Renderer.assembleMeasure(song, measure1);
    var actual2 = Renderer.assembleMeasure(song, measure2);

    compareSystems(expected1, actual1);
    compareSystems(expected2, actual2);
  });
  it('grace notes', () => {
    var notes1 = new Types.NoteGroup('a4/q, a4, a4, a4', false, false);
    var grace_note = new Types.GraceNote(['b/4'], '8', 2);
    var measure = new Types.Measure(null, null, [notes1], [], false, false, [], [grace_note], 0, [], [], 1);
    var song = new Types.Song(null, '4/4', 'C', 0, [measure]);

    var width = Renderer.pixelsPerBeat * 4;
    var expected = Renderer.vf.System({ width: width });
    expected.addStave({
      voices: [Renderer.score.voice(Renderer.score.notes('a4/q, a4, a4, a4'), { time: '4/4' })]
    }).setMeasure(1);

    var grace = new Vex.GraceNote({
      keys: ['a/4'],
      duration: '8',
      slash: true
    });
    var group = new Vex.GraceNoteGroup([grace], true);
    expected.partVoices[0].tickables[2].addModifier(group);

    var actual = Renderer.assembleMeasure(song, measure);

    compareSystems(expected, actual);
  });
  it('example song 1', () => {
    var notes1 = new Types.NoteGroup("e5/q, b4/q", false, false);
    var notes2 = new Types.NoteGroup("a4/8, g4/8, f4/8, e4/8", true, false);
    var notes3 = new Types.NoteGroup("g4/8, a4/8, g4/8", true, true);
    var notes4 = new Types.NoteGroup("a4/q, a4/q, b4/q/r", false, false);
    var notes5 = new Types.NoteGroup("a5/8, g#5/8, f#5/8, e5/8", true, false);
    var notes6 = new Types.NoteGroup("a4/h....., a4/64", false, false);
    var notes7 = new Types.NoteGroup("e5/8., bb4/16", true, false);

    var measure1 = new Types.Measure("4/4", "Db", [notes1, notes2], null, false, false, [], [], 0, [], [], 1);
    var measure2 = new Types.Measure("5/4", null, [notes1, notes4], null, false, false, [], [], 0, [], [], 2);
    var measure3 = new Types.Measure(null, null, [notes1, notes4], null, false, false, [], [], 0, [], [], 3);
    var measure4 = new Types.Measure("4/4", null, [notes1, notes5], null, false, false, [], [], 0, [], [], 4);
    var measure5 = new Types.Measure(null, "F", [notes4, notes3], null, false, false, [], [], 0, [], [], 5);
    var measure6 = new Types.Measure(null, null, [notes6], null, false, false, [], [], 0, [], [], 6);
    var measure7 = new Types.Measure(null, null, [notes7, notes4], null, false, false, [], [], 0, [], [], 7)

    var song = new Types.Song("treble", measure1.time_sig, 'F', 30, [measure1, measure2, measure3, measure4, measure5, measure6, measure7]);

    var width1 = Renderer.pixelsPerBeat * 4;
    var width2 = Renderer.pixelsPerBeat * 5;
    var expected1 = Renderer.vf.System({ width: width1 });
    expected1.addStave({
      voices: [Renderer.score.voice(Renderer.score.notes("e5/q, b4/q").concat(Renderer.score.beam(Renderer.score.notes("a4/8, g4/8, f4/8, e4/8"))), { time: '4/4' })]
    }).setMeasure(1).addTimeSignature('4/4').addModifier(new Vex.Barline(Vex.BarlineType.NONE)).addKeySignature('Db').addClef('treble');

    var expected2 = Renderer.vf.System({ width: width2, x: 10 + width1 });
    expected2.addStave({
      voices: [Renderer.score.voice(Renderer.score.notes("e5/q, b4/q").concat(Renderer.score.notes('a4/q, a4/q, b4/q/r')), { time: '5/4' })]
    }).setMeasure(2).addTimeSignature('5/4');

    var expected3 = Renderer.vf.System({ width: width2, x: 10 + width1 + width2 });
    expected3.addStave({
      voices: [Renderer.score.voice(Renderer.score.notes("e5/q, b4/q").concat(Renderer.score.notes('a4/q, a4/q, b4/q/r')), { time: '5/4' })]
    }).setMeasure(3);

    var expected4 = Renderer.vf.System({ width: width1, x: 10 + 2 * (width2) + width1 });
    expected4.addStave({
      voices: [Renderer.score.voice(Renderer.score.notes("e5/q, b4/q").concat(Renderer.score.beam(Renderer.score.notes("a5/8, g#5/8, f#5/8, e5/8"))), { time: '4/4' })]
    }).setMeasure(4).addTimeSignature('4/4');

    var expected5 = Renderer.vf.System({ width: width1, x: 10 + 2 * (width1) + 2 * (width2) });
    expected5.addStave({
      voices: [Renderer.score.voice(Renderer.score.notes("a4/q, a4/q, b4/q/r").concat(Renderer.score.tuplet(Renderer.score.beam(Renderer.score.notes("g4/8, a4/8, g4/8")), { ratioed: false })), { time: '4/4' })]
    }).setMeasure(5).addModifier(new Vex.Barline(Vex.BarlineType.SINGLE)).addKeySignature('F');

    var expected6 = Renderer.vf.System({ width: width1, x: 10 + 3 * (width1) + 2 * (width2) });
    expected6.addStave({
      voices: [Renderer.score.voice(Renderer.score.notes("a4/h....., a4/64"), { time: '4/4' })]
    }).setMeasure(6);

    var expected7 = Renderer.vf.System({ width: width1, x: 10 + 4 * (width1) + 2 * (width2) });
    expected7.addStave({
      voices: [Renderer.score.voice(Renderer.score.notes("e5/8., bb4/16").concat(Renderer.score.notes('a4/q, a4/q, b4/q/r')), { time: '4/4' })]
    }).setMeasure(7);

    var actual1 = Renderer.assembleMeasure(song, measure1);
    var actual2 = Renderer.assembleMeasure(song, measure2);
    var actual3 = Renderer.assembleMeasure(song, measure3);
    var actual4 = Renderer.assembleMeasure(song, measure4);
    var actual5 = Renderer.assembleMeasure(song, measure5);
    var actual6 = Renderer.assembleMeasure(song, measure6);
    var actual7 = Renderer.assembleMeasure(song, measure7);

    compareSystems(expected1, actual1);
    compareSystems(expected2, actual2);
    compareSystems(expected3, actual3);
    compareSystems(expected4, actual4);
    compareSystems(expected5, actual5);
    compareSystems(expected6, actual6);
    compareSystems(expected7, actual7);
  });
});