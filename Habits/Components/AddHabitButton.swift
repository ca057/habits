//
//  AddHabitButton.swift
//  Habits
//
//  Created by Christian Ost on 25.02.23.
//

import SwiftUI

struct AddHabitButton: View {
    var onPress: () -> Void
    
    private var bg = Color.accentColor

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
        .background(bg)
        .cornerRadius(20)
    }
    
    init(withSparkle: Bool = false, onPress: @escaping () -> Void) {
        self.onPress = onPress
        if withSparkle {
            // TODO: implement this properly
            bg = .purple
        }
    }
}

struct AddHabitButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AddHabitButton() { }
            AddHabitButton(withSparkle: true) { }
        }
    }
}
