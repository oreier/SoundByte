const expect = window.chai.expect;

//We can't just compare two objects for equality, because vexflow objects are deeply nested, often circularly, and all have unique id's
//stripping these id's off either takes too long or too much memory (iterative vs recursive), so we just check the relevant fields here

//compare two sets of StemmableNotes[], returned either by score.notes() or our assembleNotes() function
export function compareStemmableNotes(expected, actual) {
    expect(expected.length).to.equal(actual.length); //if it fails, it will stop here
    for (let i = 0; i < expected.length; i++) {
        if (expected.beam) {
            compareStemmableNotes(expected.beam.notes, actual.beam.notes);
        }
        expect(expected[i].clef).to.equal(actual[i].clef);
        expect(expected[i].keys).to.deep.equal(actual[i].keys);
        expect(expected[i].noteType).to.equal(actual[i].noteType);
        expect(expected[i].stem_direction).to.equal(actual[i].stem_direction);
        expect(expected[i].ticks).to.deep.equal(actual[i].ticks);
        expect(expected[i].duration).to.equal(actual[i].duration);

        expect(expected[i].modifiers.length).to.equal(actual[i].modifiers.length);
        for(let j = 0; j < expected[i].modifiers.length; j++) {
            expect(expected[i].modifiers[j].attrs.type).to.equal(actual[i].modifiers[j].attrs.type);
        }
    }
}