//
//  DashboardItem.swift
//  habits
//
//  Created by Christian Ost on 24.03.22.
//

import SwiftUI

struct DayElement: View {
    let date: Date
    let formattedDay: String
    let isInWeekend: Bool
    let selected: Bool
    let color: Color
    
    let onEntrySelect: (Date) -> Void
    
    var body: some View {
        Button(action: {}, label: {
            Text(formattedDay)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 4)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: .infinity)
                        .fill(selected ? color : .clear)
                        .grayscale(isInWeekend ? 0.75 : 0)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: .infinity)
                        .stroke(color, lineWidth: 4)
                        .grayscale(isInWeekend ? 0.75 : 0)
                )
        })
        .simultaneousGesture(LongPressGesture().onEnded(handleLongPress))
        .buttonStyle(BorderlessButtonStyle())
        .foregroundColor(.primary)
    }
    
    init(_ date: Date, selected: Bool, color: Color, onEntrySelect: @escaping (Date) -> Void) {
        self.date = date
        self.formattedDay = "\(Calendar.current.dateComponents([.day], from: date).day ?? 0)"
        self.isInWeekend = Calendar.current.isDateInWeekend(date)
        self.selected = selected
        self.color = color
        self.onEntrySelect = onEntrySelect
    }
    
    func handleLongPress(_: Any) {
        onEntrySelect(date)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

private extension Date {
    func getDayWithDistance(by value: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: value, to: self)!
    }
}

let elementDisplayCount = 7

struct DashboardItem: View {
    var habit: Habit
    
    let viewModel = DashboardItemViewModel()
    let now = Date.now
    let today = Calendar.current.dateComponents([.day], from: Date.now)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(habit.name ?? "N/A")
                .font(.title)
                .bold()
            Text("Started on \(habit.createdAt?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")")
                .font(.caption)
                .padding(.bottom)
                        
            HStack(spacing: 8) {
                ForEach(0..<elementDisplayCount, id: \.self) { index in
                    let date = now.getDayWithDistance(by: index - (elementDisplayCount - 1))

                    DayElement(
                        date,
                        selected: habit.hasEntry(for: date),
                        color: .orange,
                        onEntrySelect: { viewModel.toggleEntry(for: habit, date: $0)}
                    )
                }
            }
        }
        .padding(.vertical)
    }
}
