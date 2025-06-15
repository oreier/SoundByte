//
//  StartView.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 5/16/25.
//
//  This is the view for the main menu that uses the RootView modes to change what views are visualized on screen
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    // UI state flags
    @State private var showImportOptions = false
    @State private var showPyodide = false
    @State private var pythonCodeToRun = ""
    
    // File importing state
    @State private var showFileImporter = false
    @State private var selectedFileData: Data? = nil

    @State var isLearning: Bool = false

    // Load a Python script from the app bundle
    func loadPythonScript(filename: String) -> String? {
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: "py") else {
            print("Failed to find \(filename).py")
            return nil
        }
        return try? String(contentsOf: fileURL)
    }

    // Callback closures passed in from parent view
    var onRecordTap: () -> Void
    var onTunerTap: () -> Void
    var onLearningTap: () -> Void

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                VStack {
                    // Top toolbar with import, learning, and tuner controls
                    HStack {
                        Button {
                            withAnimation {
                                showImportOptions.toggle()
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }

                        Spacer()

                        Button {
                            isLearning.toggle()
                            onLearningTap()
                        } label: {
                            Label("Toggle Learning Mode", systemImage: isLearning ? "brain.fill" : "brain")
                                .labelStyle(.iconOnly)
                        }

                        Spacer()

                        Button {
                            onTunerTap()
                        } label: {
                            Image(systemName: "waveform")
                        }
                    }
                    .padding()

                    Spacer()

                    // Large red record button
                    Button {
                        onRecordTap()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 150, height: 150)
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()

                    // Navigation buttons for Library and History
                    HStack(spacing: 40) {
                        NavigationLink(destination: LibraryView()) {
                            VStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                                    .shadow(radius: 4)
                                Image(systemName: "books.vertical")
                                Text("Library")
                            }
                        }

                        NavigationLink(destination: HistoryView()) {
                            VStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                                    .shadow(radius: 4)
                                Image(systemName: "clock.arrow.circlepath")
                                Text("History")
                            }
                        }
                    }
                    .padding()

                    Spacer()
                }
                .padding()

                // Dropdown menu for import options
                if showImportOptions {
                    VStack(alignment: .leading, spacing: 10) {
                        Button("Import Sheet Music") {
                            loadBundledMXL(named: "take_me_to_church")
                            showImportOptions = false
                        }
                        Button("Import Backtrack Audio") {
                            loadBundledMXL(named: "take_me_to_church")
                            showImportOptions = false
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                    .offset(x: 16, y: 70)
                }
            }
        }
        // iOS file importer for loading external .mxl files
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let fileURL = urls.first {
                    if fileURL.startAccessingSecurityScopedResource() {
                        defer { fileURL.stopAccessingSecurityScopedResource() }
                        do {
                            selectedFileData = try Data(contentsOf: fileURL)
                            preparePythonCodeWithMXL()
                        } catch {
                            print("Failed to read selected file data: \(error.localizedDescription)")
                        }
                    } else {
                        print("Couldn't access the security scoped resource.")
                    }
                }
            case .failure(let error):
                print("File import failed:", error.localizedDescription)
            }
        }

        // Full-screen modal for running Python in WebView (Pyodide)
        .fullScreenCover(isPresented: $showPyodide) {
            VStack {
                Text("Loading Python…")

                Button("Dismiss") {
                    showPyodide = false
                }

                WebView(
                    htmlFile: "pyodide",               // Loads local Pyodide HTML
                    pythonCode: pythonCodeToRun,       // Injects dynamic code
                    onOutput: { output in
                        print("Python output:", output)
                    },
                    onFinished: {
                        print("Python runtime finished executing.")
                        showPyodide = false
                    }
                )
            }
        }
    }

    // Encode MXL data as base64 and inject it into a Python script
    func preparePythonCodeWithMXL() {
        guard let mxlData = selectedFileData else { return }
        let base64MXL = mxlData.base64EncodedString()

        let testScript = """
        import base64
        print("Received base64 length:", \(base64MXL.count))
        """
        pythonCodeToRun = testScript
        showPyodide = true
    }

    // Load a .mxl file bundled with the app (used instead of file importer)
    func loadBundledMXL(named filename: String) {
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: "mxl") else {
            print("Failed to find \(filename).mxl in bundle")
            return
        }
        do {
            selectedFileData = try Data(contentsOf: fileURL)
            preparePythonCodeWithMXL()
        } catch {
            print("Failed to load data from bundle: \(error.localizedDescription)")
        }
    }
}


/* fileImporter and uploadFileToServer functions for running parser with server method
 .fileImporter(
             isPresented: $showFileImporter,
             allowedContentTypes: [.audio, .pdf, .plainText], // Adjust types as needed
             allowsMultipleSelection: false
         ) { result in
             switch result {
             case .success(let urls):
                 if let fileURL = urls.first {
                     selectedFileURL = fileURL
                     uploadFileToServer(fileURL: fileURL, type: "sheet music")
                 }
             case .failure(let error):
                 print("File import failed:", error.localizedDescription)
             }
         }
     }

     func uploadFileToServer(fileURL: URL, type: String) {
         guard let serverURL = URL(string: "http://IP address:8000/upload") else { return } // Replace with your IP address

         var request = URLRequest(url: serverURL)
         request.httpMethod = "POST"

         let boundary = UUID().uuidString
         request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

         var body = Data()
         let filename = fileURL.lastPathComponent
         let mimeType = "application/octet-stream"

         body.append("--\(boundary)\r\n".data(using: .utf8)!)
         body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
         body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)

         if let fileData = try? Data(contentsOf: fileURL) {
             body.append(fileData)
         }

         body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

         request.httpBody = body

         URLSession.shared.dataTask(with: request) { data, response, error in
             if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let result = json["result"] as? String {
                 print("\(type.capitalized) upload result:", result)
             } else {
                 print("Upload failed:", error?.localizedDescription ?? "Unknown error")
             }
         }.resume()
     }
 */
