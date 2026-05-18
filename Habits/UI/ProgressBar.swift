//
//  ProgressBar.swift
//  Habits
//
//  Created by Christian Ost on 12.09.24.
//

import SwiftUI

struct Bar: Identifiable {
    var id: String
    var progress: Double
    var color = Color.black

    init(_ name: String, progress: Double, color: Color = Color.black) {
        self.id = name
        self.progress = progress
        self.color = color
    }
}

fileprivate struct ProgressBarElement: View {
    var width: Double
    var height: Double
    var color: Color
    
    @State private var animatedWidth: Double
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: animatedWidth, height: height)
            .onChange(of: width, initial: true) {
                withAnimation {
                    animatedWidth = width
                }
            }
    }
    
    init(width: Double, height: Double, color: Color) {
        self.width = width
        self.height = height
        self.color = color
        self.animatedWidth = width
    }
}

struct ProgressBar: View {
    var progress: Double
    var color = Color.black
    var trackColor = Color.secondary
    var height = CGFloat(4)

    var body: some View {
        Rectangle()
            .fill(trackColor)
            .frame(width: nil, height: height)
            .overlay(alignment: .leading) {
                GeometryReader { geo in
                    ProgressBarElement(width: geo.size.width * progress, height: height, color: color)
                }
            }
            .clipped()
            
    }
}


#Preview {
    struct Container: View {
        @State private var progress = 0.3

        var body: some View {
            VStack(spacing: 4) {
                Spacer()

                ProgressBar(progress: progress, color: .blue, trackColor: .brown, height: 32)

                HStack(spacing: 4) {
                    Button("-", action: {
                        progress = Double.maximum(0, progress - 0.1)
                    }).buttonStyle(.bordered)

                    Button("+", action: {
                        progress = Double.minimum(1, progress + 0.1)
                    }).buttonStyle(.bordered)
                }

                Spacer()
            }.padding(20)
        }
    }

    return Container()
}
