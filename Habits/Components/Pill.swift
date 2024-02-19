//
//  Pill.swift
//  Habits
//
//  Created by Christian Ost on 24.12.23.
//

import SwiftUI

struct Pill: View {
    var color: Color
    var width: CGFloat
    var height: CGFloat
    @Binding var filled: Bool
    
    private let radius = CGFloat(8)
    private let duration = 0.15
    
    var body: some View {
        Color.white
            .overlay(
                RoundedRectangle(cornerRadius: width * 2 / 3, style: .continuous)
                    .fill(color)
                    .blur(radius: radius.scaled(by: 1.5))
                    .frame(width: 2 * width, height: 2 * height)
                    .offset(x: -(width / 2) + (radius / 2), y: height / 2 - (radius / 2))
            )
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: .infinity))
            .mask(
                ZStack {
                    RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                        .strokeBorder(.black, lineWidth: max(4, width * 0.125))
                        .frame(width: width, height: height)
                    
                    RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                        .frame(width: width, height: height)
                        .scaleEffect(filled ? 1 : 0)
                        .animation(.easeOut(duration: duration), value: filled)
                }
            )
            .phaseAnimator([false, true], trigger: filled) { content, phase in
                content.scaleEffect(filled && phase ? 1.05 : 1)
            } animation: { phase in
                    .spring(duration: duration, bounce: 0.7)
            }
    }
    
    init(color: Color, width: CGFloat, filled: Binding<Bool>) {
        self.color = color
        self.width = width
        self.height = CGFloat(floor(Double(width) * (1 + 1/3)))
        self._filled = filled
    }
    init(color: Color, width: CGFloat, height: CGFloat, filled: Binding<Bool>) {
        self.color = color
        self.width = width
        self.height = height
        self._filled = filled
    }
}

#Preview("pill") {
    struct Container: View {
        @State var filled = false
        @State var colorScheme = ColorScheme.light

        var body: some View {
            VStack(spacing: 32) {
                HStack {
                    Pill(color: .purple, width: 24, filled: $filled)
                    
                    Pill(color: .green, width: 48, filled: $filled)
                    
                    Pill(color: .yellow, width: 72, filled: $filled)
                    
                    HStack {
                        Pill(color: .purple, width: 24, filled: $filled)
                        
                        Pill(color: .green, width: 48, filled: $filled)
                        
                        Pill(color: .yellow, width: 72, filled: $filled)
                    }
                    .padding()
                    .background(Color.gray)
                }
                .onTapGesture {
                    filled.toggle()
                }

                HStack {
                    Pill(color: .purple, width: 16, height: 24, filled: $filled)
                    
                    Pill(color: .green, width: 32, height: 48, filled: $filled)
                    
                    Pill(color: .yellow, width: 48, height: 72, filled: $filled)
                    
                    HStack {
                        Pill(color: .purple, width: 16, height: 24, filled: $filled)
                        
                        Pill(color: .green, width: 32, height: 48, filled: $filled)
                        
                        Pill(color: .yellow, width: 48, height: 72, filled: $filled)
                    }
                    .padding()
                    .background(Color.gray)
                }
                .onTapGesture {
                    filled.toggle()
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
