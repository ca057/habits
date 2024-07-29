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
                .background(Pill(fillColor, filled: .constant(selected)))
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
                .font(.title2)
                .padding(.bottom, 4)
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
    do {
        let previewer = try Previewer()
        
        return DashboardItem(
                showUntil: Date.now,
                forHabit: previewer.habits[0],
                toggleEntry: { _, __ in }
            )
            .padding()
            .modelContainer(previewer.container)
    } catch {
        return Text("error creating preview: \(error.localizedDescription)")
    }
    
}
