//
//  DashboardItem.swift
//  habits
//
//  Created by Christian Ost on 24.03.22.
//

import SwiftUI

struct DayElement: View {
    let day: Date
    let formattedDay: String
    let isInWeekend: Bool
    let selected: Bool
    let color: Color
    
    let onEntrySelect: (Date) -> Void
    
    var body: some View {
        Button(action: {
            onEntrySelect(day)
        }, label: {
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
        .buttonStyle(BorderlessButtonStyle())
        .foregroundColor(.primary)
    }
    
    init(day: Date, selected: Bool, color: Color, onEntrySelect: @escaping (Date) -> Void) {
        self.day = day
        self.formattedDay = "\(Calendar.current.dateComponents([.day], from: day).day ?? 0)"
        self.isInWeekend = Calendar.current.isDateInWeekend(day)
        self.selected = selected
        self.color = color
        self.onEntrySelect = onEntrySelect
    }
}

private extension Date {
    func getDayWithDistance(by value: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: value, to: self)!
    }
}

let elementCount = 7

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
                ForEach(0..<elementCount, id: \.self) { index in
                    DayElement(
                        day: now.getDayWithDistance(by: index - (elementCount - 1)),
                        selected: false,
                        color: .orange,
                        onEntrySelect: { viewModel.addEntry(for: habit, date: $0)}
                    )
                }
            }
            
            Text("Entries: \(habit.entry?.count ?? 0)")
        }
        .padding(.vertical)
    }
}
