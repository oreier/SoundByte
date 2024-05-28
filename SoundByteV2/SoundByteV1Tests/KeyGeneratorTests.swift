//
//  KeyGeneratorTests.swift
//  SoundByteV1Tests
//
//  Created by Jack Durfee on 5/24/24.
//

import XCTest
@testable import SoundByteV1

final class KeyGeneratorTests: XCTest {

    func testCorrectKey() {
        var generator = KeyGenerator()
        
        generator.data = KeyData(note: "C", accidental: "♮", degree: "M")
        
        XCTAssertEqual(generator.generateKey().count, 2)
    }
}
