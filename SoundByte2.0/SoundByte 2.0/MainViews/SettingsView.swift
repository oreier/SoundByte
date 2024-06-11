//
//  SettingsView.swift
//  SoundByte 2.0
//
//  Created by Delaney Lim (Student) on 6/3/24.
//

import SwiftUI
import AudioKit

enum ClefType: String {
    case treble = "Treble Clef"
    case octave = "Octave Clef"
    case bass = "Bass Clef"
}

// stores all of the user set preferences
class UserSettings: ObservableObject {
    // clef settings
    @Published var clef: ClefType
    @Published var clefIndex: Int
    
    // mode settings
    @Published var isMajor: Bool
    @Published var modeIndex: Int
    
    // key settings
    @Published var key: Key
    @Published var keyIndex: Int
    
    // graph settings
    @Published var isNoteNamesDisplayed: Bool
    
    // initializer sets all user settings to the data stored by the app
    init() {
        let defaults = UserDefaults.standard
        
        // clef settings
        if let clefTypeRawValue = defaults.string(forKey: "clefType"), let clefType = ClefType(rawValue: clefTypeRawValue) {
            self.clef = clefType
        } else {
            self.clef = .treble // default to treble clef if not set
        }
        self.clefIndex = defaults.integer(forKey: "selectedClefIndex")
        
        // mode settings
        if defaults.value(forKey: "isMajor") == nil { // if there isn't a value for the isMajor setting, default to true
            defaults.set(true, forKey: "isMajor")
        }
        self.isMajor = defaults.bool(forKey: "isMajor")
        self.modeIndex = defaults.integer(forKey: "selectedModeIndex")
        
        // key settings
        if let keyData = defaults.data(forKey: "key") { // set key to user set value if there is one
            do { // try decoding the key
                let decoder = JSONDecoder()
                self.key = try decoder.decode(Key.self, from: keyData)
            } catch { // otherwise set key to default value
                self.key = KeyGenerator().data
                print("Error: error with loading key from storage")
            }
        } else { // if there is no key data, set key to default value
            self.key = KeyGenerator().data
        }
        self.keyIndex = defaults.integer(forKey: "selectedKeyIndex")
        
        // graph settings
        self.isNoteNamesDisplayed = defaults.bool(forKey: "noteNamesEnabled")
    }
}

struct SettingsView: View {
    @ObservedObject var userSettings: UserSettings
//    @State var device: Device
    
    // state variables for tracking number of accidentals in a key
    @State var numSharps = 0
    @State var numFlats = 0
    
    // selections available to the user
    let clefTypes: [ClefType] = [.treble, .octave, .bass]
    let modeType = ["Major", "Minor"]
    let keysMajor = ["C", "G", "D", "A", "E", "B", "F#", "C#","Cb", "Gb", "Db", "Ab", "Eb", "Bb", "F"]
    let keysMinor = ["Am", "Em", "Bm", "F#m", "C#m", "G#m", "D#m", "A#m", "Abm", "Ebm", "Bbm", "Fm", "Cm", "Gm", "Dm"]
    
    // images of key signatures that is set based off the selected octave
    var keySignatures: [String] {
        switch userSettings.clef {
        case .treble:
            return ["C_treble", 
                    "G_treble",
                    "D_treble",
                    "A_treble",
                    "E_treble",
                    "B_treble",
                    "F_sharp_treble",
                    "C_sharp_treble",
                    "C_flat_treble",
                    "G_flat_treble",
                    "D_flat_treble",
                    "A_flat_treble",
                    "E_flat_treble",
                    "B_flat_treble",
                    "F_treble"]
        case .octave:
            return ["C_tenor", 
                    "G_tenor",
                    "D_tenor",
                    "A_tenor",
                    "E_tenor",
                    "B_tenor",
                    "F_sharp_tenor",
                    "C_sharp_tenor",
                    "C_flat_tenor",
                    "G_flat_tenor",
                    "D_flat_tenor",
                    "A_flat_tenor",
                    "E_flat_tenor",
                    "B_flat_tenor",
                    "F_tenor"]
        case .bass:
            return ["C_bass", 
                    "G_bass", 
                    "D_bass",
                    "A_bass",
                    "E_bass", 
                    "B_bass",
                    "F_sharp_bass",
                    "C_sharp_bass",
                    "C_flat_bass",
                    "G_flat_bass",
                    "D_flat_bass",
                    "A_flat_bass",
                    "E_flat_bass",
                    "B_flat_bass",
                    "F_bass"]
        }
    }
    
    // builds the view of the settings page
    var body: some View {
        
        // set as a navigation view so that it can be navigated to from the visualizer view
        NavigationView {
            
            // form creates a generic settings style page
            Form {
                
                // first section allows user to select the key they want to sing in
                Section(header: Text("Musical Key")) {
                    
                    // picker for selecting clef
                    Picker(selection: $userSettings.clefIndex, label: Text("Clef")) {
                        ForEach(clefTypes.indices, id: \.self) { index in
                            Text(clefTypes[index].rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: userSettings.clefIndex) {
                        userSettings.clef = clefTypes[userSettings.clefIndex]
                    }
                    
                    // picker for selecting mode
                    Picker(selection: $userSettings.modeIndex, label: Text("Mode")) {
                        ForEach(modeType.indices, id: \.self) { index in
                            Text(modeType[index])
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    .padding()
                    .onChange(of: userSettings.modeIndex) {
                        userSettings.isMajor = (userSettings.modeIndex == 0) ? true : false
                    }
                    
                    // hstack displays picker for selecting key and key signature photo
                    HStack {
                        
                        // displays the image of the current key and clef
                        Image(keySignatures[userSettings.keyIndex])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300)
                            .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                        
                        Spacer() // spacer used to center picker for the key
                        
                        // picker for selecting the key
                        Picker(selection: $userSettings.keyIndex, label: Text("Key")) {
                            ForEach(0 ..< (userSettings.isMajor ? keysMajor.count : keysMinor.count), id: \.self) { index in
                                Text(userSettings.isMajor ? keysMajor[index] : keysMinor[index])
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .padding()
                        .onChange(of: userSettings.keyIndex) {
                            updateSharpsFlats()
                            saveKey()
                        }
                        
                        Spacer() // spacer used to center picker for the key
                    }
                }
                
                // second section allows the user to change the appearance of the graph
//                Section(header: Text("Graph")) {
//                    
//                    // toggle for settings note names
//                    Toggle(isOn: $userSettings.isNoteNamesDisplayed) {
//                        Text("Show Note Names")
//                    }
//                }
                
                // third section allows the user to change the input device
//                Section(header: Text("Input Device")) {
//                
//                    // picker for the input device
//                    Picker("Input:", selection: $device) {
//                        ForEach(getDevices(), id: \.self) {
//                            Text($0.deviceID)
//                        }
//                    }
//                    .pickerStyle(MenuPickerStyle())
//                    .padding()
//                    .onChange(of: device) {
//                        setInputDevice(to: device)
//                    }
//                }
            }
            .navigationBarTitle("Settings")
        }
        .onDisappear() {
            saveSettings()
        }
    }
    
    // saves all of the settings the user has set
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(userSettings.clef.rawValue, forKey: "clefType")
        defaults.set(userSettings.clefIndex, forKey: "selectedClefIndex")
        defaults.set(userSettings.isMajor, forKey: "isMajor")
        defaults.set(userSettings.modeIndex, forKey: "selectedModeIndex")
        defaults.set(userSettings.keyIndex, forKey: "selectedKeyIndex")
        defaults.set(userSettings.isNoteNamesDisplayed, forKey: "noteNamesEnabled")
    }
    
    // updates the number of sharps or flats based off the selected key
    func updateSharpsFlats() {
        let sharpsFlatsMajor: [String: (Int, Int)] = [
            "C": (0, 0),
            "G": (1, 0),
            "D": (2, 0),
            "A": (3, 0),
            "E": (4, 0),
            "B": (5, 0),
            "F#": (6, 0),
            "C#": (7, 0),
            "Cb": (0, 7),
            "Gb": (0, 6),
            "Db": (0, 5),
            "Ab": (0, 4),
            "Eb": (0, 3),
            "Bb": (0, 2),
            "F": (0, 1)
        ]
        
        let sharpsFlatsMinor: [String: (Int, Int)] = [
            "Am": (0, 0), 
            "Em": (1, 0),
            "Bm": (2, 0),
            "F#m": (3, 0),
            "C#m": (4, 0),
            "G#m": (5, 0),
            "D#m": (6, 0),
            "A#m": (7, 0),
            "Abm": (0, 7),
            "Ebm": (0, 6),
            "Bbm": (0, 5),
            "Fm": (0, 4),
            "Cm": (0, 3), 
            "Gm": (0, 2),
            "Dm": (0, 1)
        ]
        
        // gets the key the user has selected
        let sharpsFlats = userSettings.isMajor ? sharpsFlatsMajor : sharpsFlatsMinor
        let selectedKey = userSettings.isMajor ? keysMajor[userSettings.keyIndex] : keysMinor[userSettings.keyIndex]
        
        // updates the number of sharps and flats for the selected key
        (numSharps, numFlats) = sharpsFlats[selectedKey]!
    }
    
    // saves the key into the settings
    func saveKey() {
        // generate the key based off the number of sharps or flats
        var keyGenerator = KeyGenerator()
        if numSharps > 0 {
            keyGenerator = KeyGenerator(numSharps: numSharps, isMajor: userSettings.isMajor)
        } else if numFlats > 0 {
            keyGenerator = KeyGenerator(numFlats: numFlats, isMajor: userSettings.isMajor)
        }
        
        // update the user settings with the selected key
        userSettings.key = keyGenerator.data
        
        // save the settings so that when the app is closed and then opened the saved key can be loaded
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(userSettings.key)
            UserDefaults.standard.set(data, forKey: "key")
        } catch {
            print("Error with saving key: \(error)")
        }
    }
    
    // gets all of the available audio devices
    func getDevices() -> [Device] {
        AudioEngine.inputDevices.compactMap { $0 }
    }
    
    // sets the input device to the audio engine
    func setInputDevice(to device: Device) {
        do {
            try AudioEngine.setInputDevice(device)
        } catch let err {
            print(err)
        }
    }
}

//#Preview {
//    SettingsView(userSettings: UserSettings())
//}
