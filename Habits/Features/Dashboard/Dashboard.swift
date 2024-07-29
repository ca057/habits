//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI
import SwiftData

struct EntryElement: View {
    var body: some View {
        VStack {
            Circle()
            Text("foo")
        }
    }
}

struct HabitRow: View {
    var habit: Habit

    var body: some View {
        VStack {
            Text(habit.name)
        }
    }
    
    init(for habit: Habit) {
        self.habit = habit
    }
}

struct Dashboard: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddHabit = false
    @State private var showingSettings = false

    @Query(Habit.sortedWithEntries) var habits: [Habit]
    
    var showUntil: Date

    var body: some View {
        VStack {
            if habits.isEmpty {
                VStack {
                    Spacer()

                    Button {
                        showingAddHabit = true
                    } label: {
                        Label("New habit", systemImage: "plus")
                            .font(.headline)
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.primary)
                    .padding()
                    
                    Spacer()
                    Spacer()
                }.padding(.horizontal)
            } else {
                List {
                    ForEach(habits) { habit in
                        HabitRow(for: habit)
//                        DashboardItem(showUntil: showUntil, forHabit: habit, toggleEntry: { toggleEntry(for: $0, on: $1) } )
//                            .background(NavigationLink("", value: habit).opacity(0))
                    }
                    .onMove {  reorderElements(source: $0, destination: $1) }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingAddHabit = true
                } label: {
                    Label("New habit", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .sheet(isPresented: $showingAddHabit) { AddHabitView() }
        .sheet(isPresented: $showingSettings) { Settings() }
    }
    
    private func toggleEntry(for habit: Habit, on date: Date) {
        if let entry = habit.entry.first(where: { entry in calendar.isDate(entry.date, inSameDayAs: date) }) {
            modelContext.delete(entry)
            try? modelContext.save()
        } else {
            let entry = Entry(date: date, habit: habit)
            modelContext.insert(entry)
        }
    }
    
    private func reorderElements(source: IndexSet, destination: Int) -> Void {
        var habitsCopy = habits
        
        habitsCopy.move(fromOffsets: source, toOffset: destination)
        for index in 0..<habitsCopy.count {
            habitsCopy[index].order = Int16(index)
        }
        
        try? modelContext.save()
    }
}

#Preview("default") {
    do {
        let previewer = try Previewer()
        
        return NavigationStack {
            Dashboard(showUntil: Date.now)
                .modelContainer(previewer.container)
        }
    } catch {
        return Text("error creating preview: \(error.localizedDescription)")
    }
}

#Preview("empty state") {
    NavigationStack {
        Dashboard(showUntil: Date.now)
    }
}

#Preview("empty state (dark)") {
    NavigationStack {
        Dashboard(showUntil: Date.now)
            .preferredColorScheme(.dark)
    }
}

#Preview("default (dark)") {
    do {
        let previewer = try Previewer()
        
        return NavigationStack {
            Dashboard(showUntil: Date.now)
                .modelContainer(previewer.container)
                .preferredColorScheme(.dark)
        }
    } catch {
        return Text("error creating preview: \(error.localizedDescription)")
    }
}
