//
//  LTTextFieldStyle.swift
//  Habits
//
//  Created by Christian Ost on 20.05.24.
//

import SwiftUI

struct LTTextFieldStyle: TextFieldStyle {
    var label: String?
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if let label = label {
                Text(label)
                    .font(.footnote)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
            }
            
            configuration
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(.secondary.opacity(0.125))
                .cornerRadius(4)
                .tint(.primary)
        }
    }
}
