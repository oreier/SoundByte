//
//  TunerConductor.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/31/24.
//

import AudioKit
import AudioKitEX
import Foundation
import SoundpipeAudioKit

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
    
    let smoothingFactor: Float = 0.5
    var smoothedPitch: Float = 0.0
    
    let targetInputGain: Float = 0.15
    var currentInputGain: Float = 1.0
        
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
        
        mic.volume = currentInputGain
        
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.update(pitch[0], amp[0])
            }
        }
        tracker.start()
    }
    
    func update(_ pitch: AUValue, _ amp: AUValue) {
        // Reduces sensitivity to background noise to prevent random / fluctuating data.
        guard amp > 0.075 else {
            data.pitch = 0
            return
        }
        
        mic.volume = targetInputGain
        
        smoothedPitch = smoothingFactor * smoothedPitch + (1.0 - smoothingFactor) * pitch
        
        data.pitch = smoothedPitch
        data.amplitude = amp
    }
}
