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
    
    var body: some View {
        Button(action: {
            print(day.description)
        }, label: {
            Text(formattedDay)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical)
                .background(isInWeekend ? .gray : .orange)
                .clipShape(Capsule())
        })
        .buttonStyle(BorderlessButtonStyle())
        .foregroundColor(.primary)
    }
    
    init(day: Date) {
        self.day = day
        self.formattedDay = "\(Calendar.current.dateComponents([.day], from: day).day ?? 0)"
        self.isInWeekend = Calendar.current.isDateInWeekend(day)
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
                    DayElement(day: now.getDayWithDistance(by: index - (elementCount - 1)))
                }
            }
        }
        .padding(.vertical)
    }
}
