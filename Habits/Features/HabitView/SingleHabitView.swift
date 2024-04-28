//
//  SingleHabitView.swift
//  Habits
//
//  Created by Christian Ost on 25.04.24.
//

import SwiftUI
import SwiftData

fileprivate struct NotFoundSingleHabitView: View {
    var body: some View {
        Text("Whoopsie, somehow no details could be found :/\n\nPlease try opening the habit again and drop me a message if it persists.")
            .multilineTextAlignment(.center)
            .monospaced()
            .foregroundStyle(.yellow)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundStyle(.gray)
            }
            .padding()
    }
}

// TODO: is there better way to do this?!
let currentYear = 2024

fileprivate struct SingleHabitViewContent: View {
    @Environment(\.calendar) private var calendar

    var habit: Habit
    var entries: [Entry]
    
    @State private var year = Date.now.adjust(for: .startOfYear) ?? Date.now
    private var achievedOfYear: [Date] {
        entries.reduce(into: [Date]()) { res, e in
            if e.date.compare(.isSameYear(as: year)) {
                res.append(e.date)
            }
        }
    }

    // TODO: make this an external thingy
    private var countOfDays: Int {
        guard let startOfYear = year.adjust(for: .startOfYear),
              let endOfToday = year.adjust(for: year.compare(.isThisYear) ? .endOfDay : .endOfYear)
        else { return 0 }
        
        let hours = calendar.dateComponents([.hour], from: startOfYear, to: endOfToday).hour
        
        return Int(ceil(Double(hours ?? 0) / 24))
    }
    private var achievedPercentage: Double {
        (Double(achievedOfYear.count) / Double(countOfDays) * 100).rounded() / 100
    }


    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                FrequencyAchievementOverview(
                    .daily,
                    year: year,
                    achieved: achievedOfYear,
                    color: habit.asColour.toColor()
                )
                HStack {
                    Button {
                        year = year.offset(.year, value: -1) ?? Date.now
                    } label: {
                        Label(
                            title: { Text("Show previous year") },
                            icon: { Image(systemName: "arrow.backward") }
                        ).labelStyle(.iconOnly)
                    }
                    .disabled(year.component(.year) ?? 0 <= 0)
                    .foregroundStyle(year.component(.year) ?? 0 <= 0 ? .gray : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(year.component(.year)?.description ?? "").monospaced()
                    
                    Button {
                        year = year.offset(.year, value: 1) ?? Date.now
                    } label: {
                        Label(
                            title: { Text("Show next year") },
                            icon: { Image(systemName: "arrow.forward") }
                        ).labelStyle(.iconOnly)
                    }
                    .disabled(year.compare(.isThisYear))
                    .foregroundStyle(year.compare(.isThisYear) ? .gray : .primary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.bottom)

                Text("\(achievedOfYear.count)").fontDesign(.rounded) +
                Text(" out of ") +
                Text("\(countOfDays)").fontDesign(.rounded) +
                Text(" days ") +
                Text("(\(achievedPercentage.formatted(.percent)))").fontDesign(.rounded).fontWeight(.bold)
            }
            .padding()
            .padding(.horizontal)
        }
    }
}

struct SingleHabitView: View {
    private var id: UUID
    
    @Query private var queriedHabits: [Habit]
    private var habit: Habit? { queriedHabits.first }
    @Query private var entries: [Entry]
    
    var body: some View {
        Group {
            if let habit = habit {
                SingleHabitViewContent(habit: habit, entries: entries)
            } else {
                NotFoundSingleHabitView()
            }
        }
        .navigationTitle(habit?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    init(id: UUID) {
        self.id = id
        
        _queriedHabits = Query(filter: #Predicate { $0.id == id })
        _entries = Query(
            filter: #Predicate<Entry> { $0.habit?.id == id },
            sort: [SortDescriptor(\Entry.date, order: .reverse)]
        )
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        return SingleHabitView(id: previewer.habit.id)
            .modelContainer(previewer.container)
    } catch {
        return Text("failed to create preview: \(error.localizedDescription)")
    }
}
