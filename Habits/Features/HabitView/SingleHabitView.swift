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

fileprivate struct SingleHabitViewContent: View {
    @Environment(\.calendar) private var calendar

    var habit: Habit
    var entries: [Entry]
    
    @State private var year = Date.now
    private var achievedOfYear: [Date] {
        entries.reduce(into: [Date]()) { res, e in
            if e.date.compare(.isSameYear(as: year)) {
                res.append(e.date)
            }
        }
    }

    private var countOfDays: Int {
        guard let startOfYear = year.adjust(for: .startOfYear),
              let endOfToday = year.adjust(for: year.compare(.isThisYear) ? .endOfDay : .endOfYear)
        else { return 0 }
        
        return Int(ceil(Double(calendar.dateComponents([.hour], from: startOfYear, to: endOfToday).hour ?? 0) / 24))
    }
    private var achievedPercentage: Double {
        (Double(achievedOfYear.count) / Double(countOfDays) * 100).rounded() / 100
    }


    var body: some View {
        ZStack(alignment: .top) {
            // TODO: introduce background
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(UIColor.systemBackground), location: 0),
                    Gradient.Stop(color: Color(UIColor.systemBackground), location: 0.5),
                    Gradient.Stop(color: Color(UIColor.tertiarySystemGroupedBackground), location: 0.5),
                    Gradient.Stop(color: Color(UIColor.tertiarySystemGroupedBackground), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea(.all, edges: .bottom)

            ScrollView {
                VStack(alignment: .leading) {
                    VStack {
                        // TODO: inline the overview, make a switch to the histogramm perspective
                        FrequencyAchievementOverview(
                            .daily,
                            year: year,
                            achieved: achievedOfYear,
                            color: habit.asColour.toColor()
                        )
                        .padding(.bottom)
                        
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
                            
                            Button {
                                year = Date.now
                            } label: {
                                Label(
                                    title: { Text(year.component(.year)?.description ?? "").monospaced() },
                                    icon: { EmptyView() }
                                ).labelStyle(.titleOnly)
                            }
                            .foregroundStyle(.primary)
                            
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
                    }
                    .padding([.horizontal, .bottom])
                    .background(.background)

                    VStack(alignment: .leading) {
                        Text("Statistics for \(year.component(.year)?.description ?? "")")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        HStack(alignment: .top) {
                            Text("Score")
                            
                            Spacer()

                            VStack(alignment: .trailing) {
                                Text(achievedPercentage.formatted(.percent))
                                    .monospacedDigit()
                                Text("\(achievedOfYear.count)/\(countOfDays) days")
                                    .font(.subheadline)
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(UIColor.tertiarySystemGroupedBackground))
            }
        }
    }
}

struct SingleHabitView: View {
    private var id: UUID
    
    @Query private var queriedHabits: [Habit]
    private var habit: Habit? { queriedHabits.first }
    @Query private var entries: [Entry]
    
    @State private var showingSettings = false
    
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
        .sheet(isPresented: $showingSettings) {
            if let habit = habit {
                NavigationStack {
                    SingleHabitSettingsView(habit: habit)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .reactOnDayChange()
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

        return NavigationStack {
            SingleHabitView(id: previewer.habits[0].id)
        }
        .tint(.primary)
        .modelContainer(previewer.container)
    } catch {
        return Text("failed to create preview: \(error.localizedDescription)")
    }
}
