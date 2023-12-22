//
//  LazyView.swift
//  Habits
//
//  Created by Christian Ost on 22.12.23.
//

import SwiftUI

// from https://gist.github.com/chriseidhof/d2fcafb53843df343fe07f3c0dac41d5
struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

#Preview {
    LazyView(Text("laaazy"))
}
