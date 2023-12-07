//
//  Button.swift
//  Habits
//
//  Created by Christian Ost on 18.09.23.
//

import SwiftUI

struct CircularButtonStyle: ButtonStyle {
    var title: String
    var systemName: String

    func makeBody(configuration: Configuration) -> some View {
        Label(
            title: { Text(title) },
            icon: {
                Image(systemName: systemName)
                    .symbolRenderingMode(.hierarchical)
                    .font(.title2)
                    .foregroundColor(.secondary.opacity(configuration.isPressed ? 0.8 : 1))
            }
        )
    }
}

struct TertiaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.bordered)
            .modifier(TertiaryTextFormat())
            .tint(.black)
    }
}

extension Button {
    func tertiary() -> some View {
        modifier(TertiaryButtonStyle())
    }
}

struct Button_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            Button("press me", action: {} )
                .tertiary()
            Button("foo", action: {})
                .buttonStyle(CircularButtonStyle(title: "", systemName: "xmark.circle.fill"))
        }
    }
}
