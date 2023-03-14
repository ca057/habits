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
    
    @Environment(\.colorScheme) var colorScheme
    
    private var selectedForegroundColor: Color {
        if color == Color.primary {
            #if os(macOS)
            return Color(NSColor.windowBackgroundColor)
            #else
            return Color(UIColor.systemBackground)
            #endif
        }
        return Color.primary
    }
    private var fillColor: Color {
        if isInWeekend {
            return color == Color.primary ? Color.gray :color
        }
        return color
    }
    private var grayScale: Double {
        isInWeekend ? 0.75 : 0
    }
    
    var body: some View {
        Button(action: handlePress, label: {
            Text(formattedDay)
                .foregroundColor(selected ? selectedForegroundColor : Color.primary)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 4)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: .infinity)
                        .fill(selected ? fillColor : .clear)
                        .grayscale(grayScale)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: .infinity)
                        .stroke(fillColor, lineWidth: 4)
                        .grayscale(grayScale)
                )
                .lineLimit(1)
        })
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
    
    func handlePress() {
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
    
    @ObservedObject private var viewModel = ViewModel()
    
    private let now = Date.now
    private let today = Calendar.current.dateComponents([.day], from: Date.now)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(habit.name ?? "N/A")
                .font(.title)
                .bold()
                .padding(.bottom)
                .lineLimit(1)
                        
            HStack(spacing: 8) {
                ForEach(0..<elementDisplayCount, id: \.self) { index in
                    let date = now.getDayWithDistance(by: index - (elementDisplayCount - 1))

                    DayElement(
                        date,
                        selected: habit.hasEntry(for: date),
                        color: Colour(rawValue: habit.colour)?.toColor() ?? Colour.base.toColor(),
                        onEntrySelect: { viewModel.toggleEntry(for: habit, date: $0)}
                    )
                }
            }
        }
        .padding(.vertical)
    }
}

extension DashboardItem {
    @MainActor final class ViewModel: ObservableObject {
        private var habitsStorage: HabitsStorage = .shared
        
        func toggleEntry(for habit: Habit, date: Date) {
            self.habitsStorage.toggleEntry(for: habit, date: date)
        }
    }
}
