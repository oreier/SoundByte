//
//  StartView.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 5/16/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @State private var showImportOptions = false
    @State private var showPyodide = false
    @State private var pythonCodeToRun = ""
    // @State private var showFileImporter = false
    // @State private var selectedFileURL: URL?
    
    // New states for file importing and data
    @State private var showFileImporter = false
    @State private var selectedFileData: Data? = nil
    
    @State var isLearning: Bool = false

    func loadPythonScript(filename: String) -> String? {
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: "py") else {
            print("Failed to find \(filename).py")
            return nil
        }
        return try? String(contentsOf: fileURL)
    }
    
    var onRecordTap: () -> Void
    var onTunerTap: () -> Void
    var onLearningTap: () -> Void

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                VStack {
                    // Top bar
                    HStack {
                        Button {
                            withAnimation {
                                showImportOptions.toggle()
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 25))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Button {
                            isLearning.toggle()
                            onLearningTap()
                        } label: {
                            Label("Toggle Learning Mode", systemImage: isLearning ? "brain.fill" : "brain")
                                .labelStyle(.iconOnly)
                                .foregroundColor(isLearning ? .blue : .primary)
                                .font(.system(size: 40))
                        }

                        Spacer()

                        Button {
                            onTunerTap()
                        } label: {
                            Image(systemName: "waveform")
                                .font(.system(size: 25))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()

                    Spacer()

                    // Record Button
                    Button {
                        onRecordTap()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 150, height: 150)
                                .shadow(radius: 10)
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 40))
                        }
                    }
                    .padding()

                    // Library and History
                    HStack(spacing: 40) {
                        NavigationLink(destination: LibraryView()) {
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 60, height: 60)
                                        .shadow(radius: 4)
                                    Image(systemName: "books.vertical")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(.black)
                                }
                                Text("Library")
                                    .foregroundColor(.primary)
                            }
                        }

                        NavigationLink(destination: HistoryView()) {
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 60, height: 60)
                                        .shadow(radius: 4)
                                    Image(systemName: "clock.arrow.circlepath")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(.black)
                                }
                                Text("History")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding()

                    Spacer()
                }
                .padding()

                // Dropdown menu
                if showImportOptions {
                    VStack(alignment: .leading, spacing: 10) {
                        Button("Import Sheet Music") {
                            // Instead of showing file importer, load bundled MXL
                            loadBundledMXL(named: "take_me_to_church")
                            showImportOptions = false
                        }
                        Button("Import Backtrack Audio") {
                            // Instead of running a simple print, also load bundled MXL
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
        // File importer for .mxl files (treated as data)
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
        .fullScreenCover(isPresented: $showPyodide) {
            VStack {
                Text("Loading Python…") // Dummy UI while debugging
                    .padding()

                Button("Dismiss") {
                    showPyodide = false
                }
                .padding()

                WebView(
                    htmlFile: "pyodide",
                    pythonCode: pythonCodeToRun,
                    onOutput: { output in
                        print("Python output:", output)
                        // Uncomment below if you want to auto-dismiss after output:
                        // showPyodide = false
                    },
                    onFinished: {
                        print("Python runtime finished executing.")
                        // Auto-dismiss here if you want
                        showPyodide = false
                    }
                )
            }
        }
    }
    
    // Prepare the Python code to run with the MXL data injected as base64
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
    
    // New helper to load bundled .mxl file instead of using fileImporter
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

/*
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
         guard let serverURL = URL(string: "http://127.0.0.1:8000/upload") else { return } // Replace with your IP

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
