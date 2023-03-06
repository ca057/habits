//
//  AddHabitButton.swift
//  Habits
//
//  Created by Christian Ost on 25.02.23.
//

import SwiftUI

struct AddHabitButton: View {
    var onPress: () -> Void

    var body: some View {
        Button {
            onPress()
        } label: {
            HStack {
                Image(systemName: "goforward.plus")
                    .foregroundColor(.white)
                Text("Add new habit")
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.accentColor)
        .cornerRadius(20)
    }
    
    init(onPress: @escaping () -> Void) {
        self.onPress = onPress
    }
}

struct AddHabitButton_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitButton() { }
    }
}
