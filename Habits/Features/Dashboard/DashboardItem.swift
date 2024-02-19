//
//  DashboardItem.swift
//  habits
//
//  Created by Christian Ost on 24.03.22.
//

import SwiftData
import SwiftUI

struct DayElement: View {
    let date: Date
    let formattedDay: String
    let isInWeekend: Bool
    let selected: Bool
    let color: Color
    let onEntrySelect: (Date) -> Void
    let width: CGFloat
    
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
            return color == Color.primary ? Color.gray : color
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
                    Pill(color: fillColor, width: width, filled: .constant(selected))
//                    RoundedRectangle(cornerRadius: .infinity)
//                        .fill(selected ? fillColor : .clear)
//                        .grayscale(grayScale)
                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: .infinity)
//                        .stroke(fillColor, lineWidth: 4)
//                        .grayscale(grayScale)
//                )
                .lineLimit(1)
        })
        .buttonStyle(BorderlessButtonStyle())
        .foregroundColor(.primary)
    }
    
    init(_ date: Date, selected: Bool, color: Color, onEntrySelect: @escaping (Date) -> Void, width: CGFloat) {
        self.date = date
        self.formattedDay = "\(Calendar.current.dateComponents([.day], from: date).day ?? 0)"
        self.isInWeekend = Calendar.current.isDateInWeekend(date)
        self.selected = selected
        self.color = color
        self.onEntrySelect = onEntrySelect
        self.width = width
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
    var now: Date
    var habit: Habit
    var toggleEntry: (Habit, Date) -> Void
    
    @Query private var entries: [Entry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(habit.name)
                .font(.title)
                .bold()
                .padding(.bottom)
                .lineLimit(1)
            
            GeometryReader { geometry in
                let itemWidth = (geometry.size.width - CGFloat((elementDisplayCount - 1) * 8)) / CGFloat(elementDisplayCount)
                HStack(spacing: 8) {
                    ForEach(0..<elementDisplayCount, id: \.self) { index in
                        let date = now.getDayWithDistance(by: index - (elementDisplayCount - 1))

                        DayElement(
                            date,
                            selected: hasEntry(for: date),
                            color: Colour(rawValue: habit.colour)?.toColor() ?? Colour.base.toColor(),
                            onEntrySelect: { toggleEntry(habit, $0)},
                            width: itemWidth
                        )
                    }
                }
            }
        }
        .padding(.vertical)
    }
    
    init(showUntil now: Date, forHabit habit: Habit, toggleEntry: @escaping (Habit, Date) -> Void) {
        let habitModelId = habit.persistentModelID

        var descriptor = FetchDescriptor<Entry>(
            // TODO: limit based on date?
            predicate: #Predicate<Entry> { $0.habit?.persistentModelID == habitModelId },
            sortBy: [SortDescriptor(\Entry.date, order: .reverse)]
        )
        descriptor.fetchLimit = elementDisplayCount
        
        _entries = Query(descriptor)

        self.now = now
        self.habit = habit
        self.toggleEntry = toggleEntry
    }
    
    private func hasEntry(for date: Date) -> Bool {
        entries.contains { entry in CalendarUtils.shared.calendar.isDate(entry.date, inSameDayAs: date) }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, configurations: config)
    
    let habit = Habit(
        colour: Colour.green.toLabel(),
        createdAt: Date.now,
        id: UUID(),
        name: "preview",
        order: 0
    )
    
    container.mainContext.insert(habit)
    
    for i in 1..<10 {
        let entry = Entry(date: Date().adjust(day: i * Int.random(in: 1..<5)) ?? Date(), habit: habit)
        container.mainContext.insert(entry)
    }
    
    @MainActor
    func toggleEntry(for habit: Habit, on date: Date) {
        if let entry = habit.entry.first(where: { entry in CalendarUtils.shared.calendar.isDate(entry.date, inSameDayAs: date) }) {
            container.mainContext.delete(entry)
            try? container.mainContext.save()
        } else {
            let entry = Entry(date: date, habit: habit)
            container.mainContext.insert(entry)
        }
    }
    
    return DashboardItem(
            showUntil: Date.now,
            forHabit: habit,
            toggleEntry: { toggleEntry(for: $0, on: $1) }
        )
        .padding()
        .modelContainer(container)
}
