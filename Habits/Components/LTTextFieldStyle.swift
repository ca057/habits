//
//  LTTextFieldStyle.swift
//  Habits
//
//  Created by Christian Ost on 20.05.24.
//

import SwiftUI

struct LTTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.secondary.opacity(0.125))
            .cornerRadius(4)
            .tint(.primary)
    }
}

#Preview {
    VStack(spacing: 4) {
        TextField("foo", text: Binding.constant(""))
            .textFieldStyle(LTTextFieldStyle())        
    }
    .padding(.horizontal)
}
