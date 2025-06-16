//
//  HistoryView.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 5/22/25.
//
//  Hard coded and disconnected history section for the app
//

import SwiftUI

struct HistoryView: View {
    let images = ["A_bass", "B_bass"]

    private let columnsCount = 3

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: columnsCount)

        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(images, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("History")
    }
}

#Preview {
    HistoryView()
}
