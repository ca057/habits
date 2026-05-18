//
//  LTLabeledContentStyle.swift
//  Habits
//
//  Created by Christian Ost on 01.07.24.
//

import SwiftUI

struct LTLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            configuration.label
                .font(.footnote)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
            
            configuration.content
                .textFieldStyle(LTTextFieldStyle())
        }
    }
}

#Preview {
    VStack(spacing: 4) {
        LabeledContent("foo foo") {
            TextField("foo", text: Binding.constant(""))
        }.labeledContentStyle(LTLabeledContentStyle())
    }
    .padding(.horizontal)
}
