//
//  TunerConductor.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/24/24.
//

import AudioKit
import AudioKitEX
import Foundation
import SoundpipeAudioKit

// Data structure to contain the pitch and amplitude data that is read in from the mic
struct TunerData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
}

class TunerConductor: ObservableObject, HasAudioEngine {
    @Published var data = TunerData()
    
    let engine = AudioEngine()
    let initialDevice: Device
    
    let mic: AudioEngine.InputNode
    let tappableNodeA: Fader
    let tappableNodeB: Fader
    let tappableNodeC: Fader
    let silence: Fader
    
    var tracker: PitchTap!
        
    init() {
        guard let input = engine.input else { fatalError() }
        
        guard let device = engine.inputDevice else  { fatalError() }
        
        initialDevice = device
        
        mic = input
        tappableNodeA = Fader(mic)
        tappableNodeB = Fader(tappableNodeA)
        tappableNodeC = Fader(tappableNodeB)
        silence = Fader(tappableNodeC, gain: 0)
        engine.output = silence
        
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.update(pitch[0], amp[0])
            }
        }
        tracker.start()
    }
    
    func update(_ pitch: AUValue, _ amp: AUValue) {
        // Reduces sensitivity to background noise to prevent random / fluctuating data.
        guard amp > 0.1 else {
            data.pitch = 0
            return
        }
        
        data.pitch = pitch
        data.amplitude = amp
    }
}
