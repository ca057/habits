//
//  ProgressBar.swift
//  Habits
//
//  Created by Christian Ost on 12.09.24.
//

import SwiftUI

struct Bar: Identifiable {
    var id = UUID()

    var progress: Double
    var color = Color.black
    
    // TODO: add a11y info
}

struct ProgressBar: View {
    var bars: [Bar]
    var trackColor = Color.secondary
    var height = CGFloat(4)
    
    var body: some View {
        Rectangle()
            .fill(trackColor)
            .frame(width: nil, height: height)
            .overlay(alignment: .leading) {
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        ForEach(bars) { bar in
                            Rectangle()
                                .fill(bar.color)
                                .frame(width: bar.progress * geo.size.width, height: height)
                        }
                    }
                }
            }
        
        // TODO: animation
    }
}


#Preview {
    VStack(spacing: 4) {
        
        ProgressBar(bars: [Bar(progress: 0.3)], trackColor: .brown, height: 32)
        ProgressBar(bars: [Bar(progress: 0.3), Bar(progress: 0.1, color: .gray)], trackColor: .brown, height: 32)
        ProgressBar(bars: [Bar(progress: 0.5)], height: 16)
        ProgressBar(bars: [Bar(progress: 0.75)], height: 8)
        ProgressBar(bars: [Bar(progress: 1)])
        
    }.padding(20)
}
