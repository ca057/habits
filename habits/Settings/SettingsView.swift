//
//  SettingsView.swift
//  habits
//
//  Created by Christian Ost on 18.02.22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismissView
    
    var body: some View {
        NavigationView {
            Form {
                Text("habits")
                ForEach(0..<12, id: \.self) {
                    Text("\($0)")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Close") {
                    dismissView()
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
