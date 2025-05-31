//
//  EntryDayView.swift
//  Habits
//
//  Created by Christian Ost on 17.09.24.
//

import SwiftUI

struct EntryDayView: View {
    @Environment(\.calendar) private var calendar
    
    var day: Date
    var isAchieved: Bool
    var color: Color
    var size: CGFloat
    
    var body: some View {
        Circle()
            .frame(width: size , height: size)
            .foregroundStyle(isAchieved ? color : .secondary)
            .opacity(calendar.isDateInWeekend(day) ? 0.5 : 1)
            .overlay {
                if calendar.isDateInToday(day) {
                    Circle()
                        .stroke(Color.primary, lineWidth: 2)
                        .fill(.clear)
                        .frame(width: 16, height: 16)
                }
            }
    }
    
    init(for day: Date, isAchieved: Bool, color: Color, size: CGFloat) {
        self.day = day
        self.isAchieved = isAchieved
        self.color = color
        self.size = size
    }
}

#Preview {
    VStack(spacing: 16) {
        EntryDayView(for: Date.now, isAchieved: false, color: .green, size: CGFloat(4))
        
        EntryDayView(for: Date.now, isAchieved: true, color: .green, size: CGFloat(12))
                
        EntryDayView(for: Date.now.adjust(for: .yesterday)!, isAchieved: false, color: .green, size: CGFloat(4))
        
        EntryDayView(for: Date.now.adjust(for: .yesterday)!, isAchieved: true, color: .green, size: CGFloat(12))
    }
}
