//
//  Pill.swift
//  Habits
//
//  Created by Christian Ost on 24.12.23.
//

import SwiftUI

struct Pill: View {
    var color: Color
    var filled = true
    var size = 1
    
    private var width: CGFloat {
        CGFloat(size * 24)
    }
    private var height: CGFloat {
        CGFloat(size * 32)
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
    }
}

#Preview("light mode") {
    VStack(spacing: 16) {
        HStack {
            Pill(color: .purple)
            
            Pill(color: .green, size: 2)
            
            Pill(color: .yellow, size: 3)
            
            HStack {
                Pill(color: .purple)
                
                Pill(color: .green, size: 2)
                
                Pill(color: .yellow, size: 3)
            }
            .padding()
            .background(Color.gray)
        }
        
        HStack {
            Pill(color: .purple, filled: false)
            
            Pill(color: .green, filled: false, size: 2)
            
            Pill(color: .yellow, filled: false, size: 3)
            
            HStack {
                Pill(color: .purple, filled: false)
                
                Pill(color: .green, filled: false, size: 2)
                
                Pill(color: .yellow, filled: false, size: 3)
            }
            .padding()
            .background(Color.gray)
        }
    }
    .padding()
    .preferredColorScheme(.light)
}

#Preview("dark mode") {
    HStack(spacing: 8) {
        Pill(color: .blue)
        
        Pill(color: .green, size: 2)
        
        Pill(color: .yellow, size: 3)
    }
    .preferredColorScheme(.dark)
}
