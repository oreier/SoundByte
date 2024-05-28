//
//  InputDevicePicker.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/24/24.
//

import AudioKit
import SwiftUI

struct InputDevicePicker: View {
    @State var device: Device
    
    var body: some View {
        Picker("Input: \(device.deviceID)", selection: $device) {
            ForEach(getDevices(), id: \.self) {
                Text($0.deviceID)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: device) {
            setInputDevice(to: device)
        }
    }
    
    func getDevices() -> [Device] {
        AudioEngine.inputDevices.compactMap { $0 }
    }
    
    func setInputDevice(to device: Device) {
        do {
            try AudioEngine.setInputDevice(device)
        } catch let err {
            print(err)
        }
    }
}
