//
//  Button.swift
//  Habits
//
//  Created by Christian Ost on 18.09.23.
//

import SwiftUI

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
        Button("press me", action: {} )
            .tertiary()
    }
}
