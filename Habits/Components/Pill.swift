//
//  Pill.swift
//  Habits
//
//  Created by Christian Ost on 24.12.23.
//

import SwiftUI

struct Pill: View {
    var color: Color
    var size = 1
    
    private var width: CGFloat {
        CGFloat(size * 24)
    }
    private var height: CGFloat {
        CGFloat(size * 32)
    }

    var body: some View {
        Color.white
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: width * 2 / 3, style: .continuous)
                    .fill(color)
                    .blur(radius: CGFloat(8 * size))
                    .frame(width: 2 * width, height: 2 * height)
                    .offset(x: -(width / 2) + 4, y: height / 2 - 4)
            )
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: .infinity))
    }
}

#Preview("light mode") {
    HStack(spacing: 8) {
        Pill(color: .purple)

        Pill(color: .green, size: 2)
        
        Pill(color: .yellow, size: 3)
    }
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
