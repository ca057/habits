//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI
import SwiftData

struct Dashboard: View {
    @Environment(\.editMode) private var editMode
    @Environment(\.calendar) private var calendar
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddHabit = false
    @State private var showingSettings = false

    @Query(Habit.sortedWithEntries) var habits: [Habit]
    
    var showUntil: Date

    var body: some View {
        NavigationView {
            VStack {
                if habits.isEmpty {
                    VStack {
                        Spacer()
                        Spacer()
                        
                        Button {
                            showingAddHabit = true
                        } label: {
                            Label("Add new habit", systemImage: "plus")
                                .labelStyle(.iconOnly)
                                .font(.title)
                        }
                        .padding()
                        
                        Spacer()
                        Spacer()
                        Spacer()
                    }.padding(.horizontal)
                } else {
                    List {
                        ForEach(habits) { habit in
                            DashboardItem(showUntil: showUntil, forHabit: habit, toggleEntry: { toggleEntry(for: $0, on: $1) } )
                                .background(
                                    NavigationLink("", destination: LazyView(HabitView(id: habit.id))).opacity(0)
                                )
                        }
                        .onMove {  reorderElements(source: $0, destination: $1) }
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !habits.isEmpty {
                        Button {
                            showingAddHabit = true
                        } label: {
                            Label("Add new habit", systemImage: "plus")
                                .labelStyle(IconOnlyLabelStyle())
                        }
                        .tint(Color(UIColor.label))
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                            .labelStyle(.iconOnly)
                    }
                    .tint(Color(UIColor.label))
                }
            }
            .sheet(isPresented: $showingAddHabit) { AddHabitView() }
            .sheet(isPresented: $showingSettings) { Settings() }
        }
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

#Preview("empty state") {
    Dashboard(showUntil: Date.now)
}

#Preview("default") {
    do {
        let previewer = try Previewer()
        
        return Dashboard(showUntil: Date.now)
            .modelContainer(previewer.container)
    } catch {
        return Text("error creating preview: \(error.localizedDescription)")
    }
}

#Preview("empty state (dark)") {
    Dashboard(showUntil: Date.now)
        .preferredColorScheme(.dark)
}

#Preview("default (dark)") {
    do {
        let previewer = try Previewer()
        
        return Dashboard(showUntil: Date.now)
            .modelContainer(previewer.container)
            .preferredColorScheme(.dark)
    } catch {
        return Text("error creating preview: \(error.localizedDescription)")
    }
}
