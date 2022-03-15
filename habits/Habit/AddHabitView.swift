//
//  AddHabitView.swift
//  habits
//
//  Created by Christian Ost on 18.02.22.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismissView
    
    var body: some View {
        NavigationView {
            Form {
                Text("Name")
            }
            .navigationTitle("Add habit")
            .toolbar {
                Button("Save") {
                    dismissView()
                }
            }
        }
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView()
    }
}
