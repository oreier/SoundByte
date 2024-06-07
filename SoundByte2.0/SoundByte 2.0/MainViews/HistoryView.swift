//
//  HistoryView.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/7/24.
//

import SwiftUI

struct HistoryView: View {
    @State private var position: Int?
    @State private var scrollPosition: CGPoint = .zero
    
    let totalHistory: [(pitch: Double, color: Color)]
    let shiftBy: Double
    let spacing: Spacing
    
    var coordinates: [CGPoint] = []
    var colors: [Color] = []
    
    @State var scrollMax = 0.0
    @State var yCoordinateIndex: Int
    
    // initializer for the history scroll feature sets up the coordinates of the history line
    init(display totalHistory: [(pitch: Double, color: Color)], shift: Double, spacing: Spacing) {
        self.totalHistory = totalHistory
        self.shiftBy = shift
        self.spacing = spacing
        
        self.yCoordinateIndex = self.totalHistory.count - 1

        calculateCoordinates()
    }
    
    // builds the history scroll view
    var body: some View {
        
        // scroll view for displaying the history line
        ScrollView(.horizontal, showsIndicators: false) {
            
            // zstack displays the history path
            ZStack(alignment: .leading) {
                HistoryPath(coordinates: coordinates, colors: colors, xStart: spacing.indicatorX)
                    .frame(width: Double(totalHistory.count) * shiftBy)
//                    .border(.blue, width: 15.0) // helps visualize how the scroll view works
            }
            // sets the size of the zstack
            .frame(width: (spacing.indicatorX - spacing.endOfAccidentals) + (Double(totalHistory.count) * shiftBy), alignment: .trailing)
//            .border(.red, width: 10) // helps visualize how the scroll view works
            
            // helps get the scroll position of the view
            .background(GeometryReader { proxy in
                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).origin)
            })
            
            // helps get the scroll position of the view
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                self.scrollPosition = value
                yCoordinateIndex = updateYCoordinate()
            }
        }
        .coordinateSpace(name: "scroll")
        
        // sets the size of the scroll view to be the area between the pitch indicator and the key signature
        .frame(width: (spacing.indicatorX - spacing.endOfAccidentals), height: spacing.spaceHeight)
//        .border(.black, width: 5) // helps visualize how the scroll view works
        
        // defaults scrolling from the right side of the view to the left
        .defaultScrollAnchor(.trailing)
        
        // overlays a pitch indicator onto the scroll view to show the pitch at the current element being scrolled through
        .overlay() {
            if totalHistory.count > 0 {
                PitchIndicator(x: (spacing.indicatorX - spacing.endOfAccidentals), y: coordinates[yCoordinateIndex].y)
            }
        }
        
        .onAppear() {
            scrollMax = abs(scrollPosition.x)
        }
    }
    
    // caculates the coordinates to generate the history line
    mutating func calculateCoordinates() {
        for i in totalHistory.indices {
            coordinates.append(CGPoint(x: Double(i) * shiftBy, y: totalHistory[i].pitch))
            colors.append(totalHistory[i].color)
        }
    }
    
    func updateYCoordinate() -> Int {
        // if we have scrolled passed the line to the left, return the first element in the array
        if scrollPosition.x > 0 {
            return 0
        }
        
        let percentScroll = abs(scrollPosition.x) / scrollMax
        var yCoordinateIndex = totalHistory.count - 1
        
        if scrollMax != 0.0 {
            yCoordinateIndex = Int(round(percentScroll * Double(coordinates.count-1)))
        }
        
        if yCoordinateIndex > totalHistory.count - 1 {
            yCoordinateIndex = totalHistory.count - 1
        }
        
        return yCoordinateIndex
    }
}

// detects the position of the scrolling
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

#Preview {
    GeometryReader { proxy in
        HistoryView(display: [(114.96, .red), (125.40, .blue), (298.70, .green),
                              (220.02, .red), (201.85, .blue), (275.93, .green),
                              (199.46, .red), (223.60, .blue), (158.92, .green),
                              (239.87, .red), (131.29, .blue), (275.57, .green),
                              (270.98, .red), (191.62, .blue), (153.23, .green),
                              (231.03, .red), (219.13, .blue), (139.99, .green),
                              (145.43, .red), (106.84, .blue), (164.02, .green),
                              (249.58, .red), (266.86, .blue), (226.40, .green),
                              (112.79, .red), (290.84, .blue), (112.82, .green),
                              (190.13, .red), (227.48, .blue), (104.34, .green),
                              (110.13, .red), (130.18, .blue), (117.98, .green),
                              (248.15, .red), (206.22, .blue), (141.95, .green),
                              (221.08, .red), (229.40, .blue), (207.06, .green),
                              (237.87, .red), (257.43, .blue), (264.01, .green),
                              (151.14, .red), (231.02, .blue), (133.94, .green),
                              (165.56, .red), (217.79, .blue), (184.22, .green),
                              (143.24, .red), (280.33, .blue), (117.43, .green),
                              (122.16, .red), (156.28, .blue), (244.26, .green),
                              (194.94, .red), (218.32, .blue), (279.45, .green),
                              (264.62, .red), (145.06, .blue), (145.51, .green),
                              (101.40, .red), (173.98, .blue), (173.21, .green),
                              (107.65, .red), (253.05, .blue), (172.21, .green),
                              (265.21, .red), (103.93, .blue), (125.70, .green),
                              (279.86, .red), (233.32, .blue), (170.68, .green),
                              (219.67, .red), (160.32, .blue), (120.37, .green),
                              (202.99, .red), (250.87, .blue), (221.30, .green),
                              (290.04, .red), (234.33, .blue), (205.92, .green),
                              (132.04, .red), (132.61, .blue), (156.88, .green),
                              (246.09, .red), (284.63, .blue), (269.17, .green),
                              (219.76, .red), (177.96, .blue), (198.47, .green),
                              (238.22, .red), (177.30, .blue), (192.63, .green),
                              (110.36, .red), (195.49, .blue), (184.63, .green),
                              (234.14, .red), (208.85, .blue), (196.14, .green),
                              (130.54, .red)],
                    shift: 10.0,
                    spacing: Spacing(width: proxy.size.width, height: proxy.size.height))
    }
}

//[(114.96, .red), (125.40, .blue), (298.70, .green),
//                      (220.02, .red), (201.85, .blue), (275.93, .green),
//                      (199.46, .red), (223.60, .blue), (158.92, .green),
//                      (239.87, .red), (131.29, .blue), (275.57, .green),
//                      (270.98, .red), (191.62, .blue), (153.23, .green),
//                      (231.03, .red), (219.13, .blue), (139.99, .green),
//                      (145.43, .red), (106.84, .blue), (164.02, .green),
//                      (249.58, .red), (266.86, .blue), (226.40, .green),
//                      (112.79, .red), (290.84, .blue), (112.82, .green),
//                      (190.13, .red), (227.48, .blue), (104.34, .green),
//                      (110.13, .red), (130.18, .blue), (117.98, .green),
//                      (248.15, .red), (206.22, .blue), (141.95, .green),
//                      (221.08, .red), (229.40, .blue), (207.06, .green),
//                      (237.87, .red), (257.43, .blue), (264.01, .green),
//                      (151.14, .red), (231.02, .blue), (133.94, .green),
//                      (165.56, .red), (217.79, .blue), (184.22, .green),
//                      (143.24, .red), (280.33, .blue), (117.43, .green),
//                      (122.16, .red), (156.28, .blue), (244.26, .green),
//                      (194.94, .red), (218.32, .blue), (279.45, .green),
//                      (264.62, .red), (145.06, .blue), (145.51, .green),
//                      (101.40, .red), (173.98, .blue), (173.21, .green),
//                      (107.65, .red), (253.05, .blue), (172.21, .green),
//                      (265.21, .red), (103.93, .blue), (125.70, .green),
//                      (279.86, .red), (233.32, .blue), (170.68, .green),
//                      (219.67, .red), (160.32, .blue), (120.37, .green),
//                      (202.99, .red), (250.87, .blue), (221.30, .green),
//                      (290.04, .red), (234.33, .blue), (205.92, .green),
//                      (132.04, .red), (132.61, .blue), (156.88, .green),
//                      (246.09, .red), (284.63, .blue), (269.17, .green),
//                      (219.76, .red), (177.96, .blue), (198.47, .green),
//                      (238.22, .red), (177.30, .blue), (192.63, .green),
//                      (110.36, .red), (195.49, .blue), (184.63, .green),
//                      (234.14, .red), (208.85, .blue), (196.14, .green),
//                      (130.54, .red)]
