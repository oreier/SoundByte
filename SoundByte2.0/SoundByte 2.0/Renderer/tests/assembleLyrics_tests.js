const expect = window.chai.expect;

import * as Vex from 'https://cdn.jsdelivr.net/npm/vexflow@4.2.2/build/esm/entry/vexflow.js';
import * as Renderer from '../src/renderer.js';
import * as Types from '../src/customTypes.js';

//used to test assembleLyrics()
function compareLyrics(expected, actual) {
    expect(expected.length).to.equal(actual.length);

    for(let i = 0; i < expected.length; i++) {
        expect(expected[i].duration).to.equal(actual[i].duration);
        expect(expected[i].line).to.equal(actual[i].line);
        expect(expected[i].text).to.equal(actual[i].text);
        var expectedTicks = expected[i].ticks.numerator / expected[i].ticks.denominator;
        var actualTicks = actual[i].ticks.numerator / actual[i].ticks.denominator;
        expect(expectedTicks).to.equal(actualTicks);
    }
}

describe('assembleLyrics() tests', () => {
    it('null input', () => {
      expect(Renderer.assembleLyrics(null)).to.equal(null);
    });
    it('blank lyrics', () => {
      var lyric = new Types.Text('', 'q', 0);

      var text = new Vex.TextNote({
        text: '',
        duration: 'q',
        line: Renderer.lyricLine
      }).setJustification(Vex.TextNote.Justification.CENTER);
      var expected = [text, text, text, text];

      var actual = Renderer.assembleLyrics([lyric, lyric, lyric, lyric]);

      compareLyrics(expected, actual);
    });
    it('basic quarter notes', () => {
      var lyric1 = new Types.Text('do', 'q', 0);
      var lyric2 = new Types.Text('re', 'q', 0);
      var lyric3 = new Types.Text('mi', 'q', 0);
      var lyric4 = new Types.Text('fa', 'q', 0);

      var _do = new Vex.TextNote({ //do is not allowed, and I wanted them all to match :(
        text: 'do',
        duration: 'q',
        line: Renderer.lyricLine
      });
      var _re = new Vex.TextNote({
        text: 're',
        duration: 'q',
        line: Renderer.lyricLine
      });
      var _mi = new Vex.TextNote({
        text: 'mi',
        duration: 'q',
        line: Renderer.lyricLine
      });
      var _fa = new Vex.TextNote({
        text: 'fa',
        duration: 'q',
        line: Renderer.lyricLine
      });

      var expected = [_do, _re, _mi, _fa];
      var actual = Renderer.assembleLyrics([lyric1, lyric2, lyric3, lyric4]);

      compareLyrics(expected, actual);
    });
    it('mixed rhythms', () => {
      var lyric1 = new Types.Text('do', 'q', 0);
      var lyric2 = new Types.Text('re', 'q', 0);
      var lyric3 = new Types.Text('mi', '8', 0);
      var lyric4 = new Types.Text('fa', '8', 0);
      var lyric5 = new Types.Text('so', '8', 0);
      var lyric6 = new Types.Text('la', '8', 0);

      var _do = new Vex.TextNote({
        text: 'do',
        duration: 'q',
        line: Renderer.lyricLine
      });
      var _re = new Vex.TextNote({
        text: 're',
        duration: 'q',
        line: Renderer.lyricLine
      });
      var _mi = new Vex.TextNote({
        text: 'mi',
        duration: '8',
        line: Renderer.lyricLine
      });
      var _fa = new Vex.TextNote({
        text: 'fa',
        duration: '8',
        line: Renderer.lyricLine
      });
      var _so = new Vex.TextNote({
        text: 'so',
        duration: '8',
        line: Renderer.lyricLine
      });
      var _la = new Vex.TextNote({
        text: 'la',
        duration: '8',
        line: Renderer.lyricLine
      });

      var expected = [_do, _re, _mi, _fa, _so, _la];
      var actual = Renderer.assembleLyrics([lyric1, lyric2, lyric3, lyric4, lyric5, lyric6]);

      compareLyrics(expected, actual);  
    });
    it('tuplets', () => {
      var lyric1 = new Types.Text("la", '8', 3);
      var lyric2 = new Types.Text("di", '8', 3);
      var lyric3 = new Types.Text("da", '8', 3);
      var lyric4 = new Types.Text('day', 'q', 0);

      var multiplier = new Vex.Fraction(2, 3);

      var text1 = new Vex.TextNote({
        text: "la",
        duration: "8",
        line: Renderer.lyricLine
      }).setJustification(Vex.TextNote.Justification.Center);
      text1.applyTickMultiplier(multiplier);

      var text2 = new Vex.TextNote({
        text: 'di',
        duration: '8',
        line: Renderer.lyricLine
      }).setJustification(Vex.TextNote.Justification.Center);
      text2.applyTickMultiplier(multiplier);

      var text3 = new Vex.TextNote({
        text: 'da',
        duration: '8',
        line: Renderer.lyricLine
      }).setJustification(Vex.TextNote.Justification.Center);
      text3.applyTickMultiplier(multiplier);

      var text4 = new Vex.TextNote({
        text: 'day',
        duration: 'q',
        line: Renderer.lyricLine
      }).setJustification(Vex.TextNote.Justification.Center);

      var expected = [text1, text2, text3, text4];
      var actual = Renderer.assembleLyrics([lyric1, lyric2, lyric3, lyric4]);

      compareLyrics(expected, actual);
    });
    it('dotted rhythms', () => {
      var lyric1 = new Types.Text('la', 'q', 0);
      var lyric2 = new Types.Text('di', 'q.', 0);
      var lyric3 = new Types.Text('da', '8', 0);

      var text1 = new Vex.TextNote({
        text: 'la',
        duration: 'q',
        line: Renderer.lyricLine
      });

      var text2 = new Vex.TextNote({
        text: 'la',
        duration: 'q',
        line: Renderer.lyricLine
      });

      var text3 = new Vex.TextNote({
        text: 'di',
        duration: 'q',
        line: Renderer.lyricLine
      });
      text3.applyTickMultiplier(new Vex.Fraction(1.5, 1));

      var text4 = new Vex.TextNote({
        text: 'da',
        duration: '8',
        line: Renderer.lyricLine
      });

      var expected = [text1, text2, text3, text4];
      var actual = Renderer.assembleLyrics([lyric1, lyric1, lyric2, lyric3]);

      compareLyrics(expected, actual);
    });
    it('error handling', () => {
      var lyric = new Types.Text(1, "cat", 0);
      expect(Renderer.assembleLyrics([lyric])).to.equal(null);
    });
  });