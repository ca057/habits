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
    var color: Color
    
    @State private var animatedWidth: Double
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: animatedWidth, height: .infinity)
            .onChange(of: width, initial: true) {
                withAnimation {
                    animatedWidth = width
                }
            }
    }
    
    init(width: Double, color: Color) {
        self.width = width
        self.color = color
        self.animatedWidth = width
    }
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
                            ProgressBarElement(width: geo.size.width * bar.progress, color: bar.color).tag(bar.id)
                        }
                    }
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

                ProgressBar(bars: [Bar("1", progress: progress)], trackColor: .brown, height: 32)

                HStack(spacing: 4) {
                    Button("-", action: {
                        progress = Double.maximum(0, progress - 0.1)
                    }).buttonStyle(.bordered)

                    Button("+", action: {
                        progress = Double.minimum(1, progress + 0.1)
                    }).buttonStyle(.bordered)
                }

                ProgressBar(bars:
                                [
                                    Bar("elapsedYear", progress: 0.3, color: .gray),
                                    Bar("progress", progress: progress)
                                ],
                            trackColor: .brown,
                            height: 32
                )

                Spacer()
            }.padding(20)
        }
    }

    return Container()
}
