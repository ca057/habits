//
//  Pill.swift
//  Habits
//
//  Created by Christian Ost on 24.12.23.
//

import SwiftUI

struct Pill: View {
    var color: Color
    @Binding var filled: Bool
    var size = 1
    
    private var width: CGFloat {
        CGFloat(size * 24)
    }
    private var heightMultiplier: Double {
        Double(1) + (0.05 * (Double(size) - 1))
    }
    private var height: CGFloat {
        CGFloat(floor(Double(size) * 32 * heightMultiplier))
    }
    
    private let radius = CGFloat(8)
    
    var body: some View {
        Color.white
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: width * 2 / 3, style: .continuous)
                    .fill(color)
                    .blur(radius: radius.scaled(by: Double(size)))
                    .frame(width: 2 * width, height: 2 * height)
                    .offset(x: -(width / 2) + (radius / 2), y: height / 2 - (radius / 2))
            )
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: .infinity))
            .mask(
                ZStack {
                    RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                        .strokeBorder(.black, lineWidth: width * 0.125)
                        .frame(width: width, height: height)
                    
                    RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                        .frame(width: width, height: height)
                        .scaleEffect(filled ? 1 : 0)
                        .animation(.easeIn(duration: 0.125), value: filled)
                }

            )
    }
}

#Preview("pill") {
    struct Container: View {
        @State var filled = false
        @State var colorScheme = ColorScheme.light

        var body: some View {
            VStack(spacing: 32) {
                HStack {
                    Pill(color: .purple, filled: $filled)
                    
                    Pill(color: .green, filled: $filled, size: 2)
                    
                    Pill(color: .yellow, filled: $filled, size: 3)
                    
                    HStack {
                        Pill(color: .purple, filled: $filled)
                        
                        Pill(color: .green, filled: $filled, size: 2)
                        
                        Pill(color: .yellow, filled: $filled, size: 3)
                    }
                    .padding()
                    .background(Color.gray)
                }
                
                Button("switch to \(filled ? "not " : "")filled") {
                    filled.toggle()
                }
                
                Button("switch to \(colorScheme == .dark ? "light" : "dark")") {
                    colorScheme = colorScheme == .dark ? .light : .dark
                }
            }
            .padding()
            .preferredColorScheme(colorScheme)
        }
    }

    return Container()
}
