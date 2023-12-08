//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI
import SwiftData

struct Dashboard: View {
    @Environment(\.editMode) private var editMode
    
    @State private var showingAddHabit = false
    
    @Query(sort: [
        SortDescriptor(\Habit.order),
        SortDescriptor(\Habit.createdAt, order: .reverse)
    ]) var habits: [Habit]

    var body: some View {
        NavigationView {
            VStack {
                if habits.isEmpty {
                    VStack {
                        Spacer()
                        EmptyState() { showingAddHabit = true } // TODO: make it a simple + button
                        .padding()
                        Spacer()
                        Spacer()
                    }.padding(.horizontal)
                } else {
                    List {
                        ForEach(habits) { habit in
                            DashboardItem(habit: habit, toggleEntry: { toggleEntry(for: $0, on: $1) } )
                                .background(
                                    NavigationLink("", destination: HabitView(habit: habit)).opacity(0)
                                )
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    #warning ("fix this")
//                                    Button(habit.hasEntry(for: Date.now) ? "Untick" : "Tick") {
//                                        toggleEntry(for: habit, on: Date.now)
//                                    }.tint(.blue)
                                }
                        }
                        .onMove {  reorderElements(source: $0, destination: $1) }
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !habits.isEmpty {
                        Button {
                            showingAddHabit = true
                        } label: {
                            Label("Add new habit", systemImage: "plus")
                                .labelStyle(IconOnlyLabelStyle())
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
        }
    }
    
    private func toggleEntry(for habit: Habit, on date: Date) {
        // TODO:
    }
    
    private func reorderElements(source: IndexSet, destination: Int) -> Void {
        // TODO:
    }
}

#Preview {
    Dashboard()
}
