//
//  Button.swift
//  Habits
//
//  Created by Christian Ost on 18.09.23.
//

import SwiftUI

struct TertiaryTextFormat: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fontDesign(.monospaced)
    }
}
