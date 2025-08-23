//
//  EntryItem.swift
//  Habits
//
//  Created by Christian Ost on 09.08.25.
//

import SwiftUI

struct EntryItem: View {
    var count: Int = 0
    var color = Color.primary
    var secondaryColor = Color.secondary
    var size: CGFloat = 12
    var highlighted = false
    
    var body: some View {
        RoundedRectangle(cornerSize: CGSize(width: 2, height: 2))
            .frame(width: size - 4, height: size - 4)
            .foregroundStyle(count > 0 ? color : secondaryColor)
            .overlay {
                if highlighted {
                    Rectangle()
                        .stroke(Color.primary, lineWidth: 2)
                        .fill(.clear)
                        .frame(width: size + 2, height: size + 2)
                }
            }
            .frame(width: size, height: size)
    }
    
    init(count: Int = 0, color: SwiftUICore.Color = Color.primary, secondaryColor: Color = Color.secondary, highlighted: Bool = false, size: CGFloat = CGFloat(32)) {
        self.count = count
        self.color = color
        self.secondaryColor = secondaryColor
        self.highlighted = highlighted
        self.size = size
    }
}

#Preview {
    EntryItem()
    EntryItem(count: 1)
    EntryItem(count: 0, color: .green, secondaryColor: .green.mix(with: .white, by: 0.5))
    EntryItem(count: 1, color: .green, secondaryColor: .green.opacity(0.5))
    EntryItem(highlighted: true)
    EntryItem(count: 1, highlighted: true)
    EntryItem(count: 1, color: .blue, highlighted: true)
}
