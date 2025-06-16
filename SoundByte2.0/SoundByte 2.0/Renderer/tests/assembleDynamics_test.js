const expect = window.chai.expect;

import * as Vex from 'https://cdn.jsdelivr.net/npm/vexflow@4.2.2/build/esm/entry/vexflow.js';
import * as Renderer from '../src/renderer.js';
import * as Types from '../src/customTypes.js';

function compareDynamics(expected, actual) {
    expect(expected.length).to.equal(actual.length);
    for(let i = 0; i < expected.length; i++) {
        expect(expected[i].duration).to.equal(actual[i].duration);
        expect(expected[i].sequence).to.equal(actual[i].sequence);
        var expectedTicks = expected[i].ticks.numerator / expected[i].ticks.denominator;
        var actualTicks = actual[i].ticks.numerator / actual[i].ticks.denominator;
        expect(expectedTicks).to.equal(actualTicks);
    }
}

describe('assembleDynamics() tests', () => {
    it('null input', () => {
        expect(Renderer.assembleDynamics(null)).to.equal(null);
    });
    it('blank dynamics', () => {
        var dynamic = new Types.Text('', 'w', 0);

        var blank = new Vex.TextDynamics({
            text: '',
            duration: 'w'
        });
        var expected = [blank];
        
        var actual = Renderer.assembleDynamics([dynamic]);

        compareDynamics(expected, actual);
    });
    it('piano', () => {
        var dynamic = new Types.Text('p', 'w', 0);

        var blank = new Vex.TextDynamics({
            text: 'p',
            duration: 'w'
        });
        var expected = [blank];
        
        var actual = Renderer.assembleDynamics([dynamic]);

        compareDynamics(expected, actual);
    });
    it('forte', () => {
        var dynamic = new Types.Text('f', 'w', 0);

        var blank = new Vex.TextDynamics({
            text: 'f',
            duration: 'w'
        });
        var expected = [blank];
        
        var actual = Renderer.assembleDynamics([dynamic]);

        compareDynamics(expected, actual);
    });
    it('basic quarter notes', () => {
        var dynamic1 = new Types.Text('pp', 'q', 0);
        var dynamic2 = new Types.Text('p', 'q', 0);
        var dynamic3 = new Types.Text('f', 'q', 0);
        var dynamic4 = new Types.Text('ff', 'q', 0);

        var pianissimo = new Vex.TextDynamics({
            text: 'pp',
            duration: 'q'
        });
        var piano = new Vex.TextDynamics({
            text: 'p',
            duration: 'q'
        });
        var forte = new Vex.TextDynamics({
            text: 'f',
            duration: 'q'
        });
        var fortissimo = new Vex.TextDynamics({
            text: 'ff',
            duration: 'q'
        });

        var expected = [pianissimo, piano, forte, fortissimo];
        
        var actual = Renderer.assembleDynamics([dynamic1, dynamic2, dynamic3, dynamic4]);

        compareDynamics(expected, actual);
    });
    it('mixed rhythms', () => {
        var dynamic1 = new Types.Text('pp', 'q', 0);
        var dynamic2 = new Types.Text('p', 'q', 0);
        var dynamic3 = new Types.Text('f', '8', 0);
        var dynamic4 = new Types.Text('ff', '8', 0);
        var dynamic5 = new Types.Text('', 'h', 0);

        var pianissimo = new Vex.TextDynamics({
            text: 'pp',
            duration: 'q'
        });
        var piano = new Vex.TextDynamics({
            text: 'p',
            duration: 'q'
        });
        var forte = new Vex.TextDynamics({
            text: 'f',
            duration: '8'
        });
        var fortissimo = new Vex.TextDynamics({
            text: 'ff',
            duration: '8'
        });
        var blank = new Vex.TextDynamics({
            text: '',
            duration: 'h'
        });

        var expected = [pianissimo, piano, forte, fortissimo, blank];
        
        var actual = Renderer.assembleDynamics([dynamic1, dynamic2, dynamic3, dynamic4, dynamic5]);

        compareDynamics(expected, actual);
    });
    it('tuplets', () => {
        var dynamic1 = new Types.Text('p', '8', 3);
        var dynamic2 = new Types.Text('f', '8', 3);
        var dynamic3 = new Types.Text('sfz', '8', 3);
        var dynamic4 = new Types.Text('ff', 'q', 0);

        var multiplier = new Vex.Fraction(2, 3);

        var text1 = new Vex.TextDynamics({
            text: 'p',
            duration: '8'
        });
        text1.applyTickMultiplier(multiplier);

        var text2 = new Vex.TextDynamics({
            text: 'f',
            duration: '8'
        });
        text2.applyTickMultiplier(multiplier);

        var text3 = new Vex.TextDynamics({
            text: 'sfz',
            duration: '8'
        });
        text3.applyTickMultiplier(multiplier);

        var text4 = new Vex.TextDynamics({
            text: 'ff',
            duration: 'q'
        });

        var expected = [text1, text2, text3, text4];
        var actual = Renderer.assembleDynamics([dynamic1, dynamic2, dynamic3, dynamic4]);

        compareDynamics(expected, actual);
    });
    it('dotted rhythms', () => {
        var dynamic1 = new Types.Text('p', 'q', 0);
        var dynamic2 = new Types.Text('f', 'q.', 0);
        var dynamic3 = new Types.Text('sfz', '8', 0);

        var text1 = new Vex.TextDynamics({
            text: 'p',
            duration: 'q'
        });

        var text2 = new Vex.TextDynamics({
            text: 'p',
            duration: 'q'
        });

        var text3 = new Vex.TextDynamics({
            text: 'f',
            duration: 'q'
        });
        text3.applyTickMultiplier(new Vex.Fraction(1.5, 1));

        var text4 = new Vex.TextDynamics({
            text: 'sfz',
            duration: '8'
        });

        var expected = [text1, text2, text3, text4];
        var actual = Renderer.assembleDynamics([dynamic1, dynamic1, dynamic2, dynamic3]);

        compareDynamics(expected, actual);
    });
    it('bad input: incorrect external type', () => {
        var dynamic = ["dynamic"];
        expect(Renderer.assembleDynamics(dynamic)).to.equal(null);
    });
    it('bad input: incorrect internal type', () => {
        var dynamic = new Types.Text(4, "pizza", 0);
        expect(Renderer.assembleDynamics([dynamic])).to.equal(null);
    });
});