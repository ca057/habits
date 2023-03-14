//
//  EmptyState.swift
//  Habits
//
//  Created by Christian Ost on 06.03.23.
//

import SwiftUI

let copies = [
    "Wow, such empty!", // thanks Reddit
    "When you don’t track a habit, you can’t fail building it!"
]

struct EmptyState: View {
    var onPress: () -> Void
    var body: some View {
        VStack {
            Text(copies.randomElement() ?? copies[0])
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding()
            
            AddHabitButton() {
                onPress()
            }
        }
    }
    
    init(onPress: @escaping () -> Void) {
        self.onPress = onPress
    }
}

struct EmptyState_Previews: PreviewProvider {
    static var previews: some View {
        EmptyState() {}
    }
}
