//
//  ArchivedHabitsView.swift
//  Habits
//
//  Created by Christian Ost on 05.09.24.
//

import SwiftUI
import SwiftData

struct ArchivedHabits: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(Habit.archivedHabits) private var archivedHabits: [Habit]
    
    @State private var habitToDelete: Habit? = nil

    var body: some View {
        if archivedHabits.count == 0 {
            ZStack(alignment: .topLeading) {
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("You don’t have any archived habits yet.")
                }
                .padding(.horizontal)
            }
        } else {
            Form {
                Section {
                    ForEach(archivedHabits) { archivedHabit in
                        VStack(alignment: .leading) {
                            Text(archivedHabit.name)
                            Text("archived on \(archivedHabit.archivedAt?.formatted(date: .long, time: .omitted) ?? "")")
                                .font(.caption)
                        }
                        .contextMenu {
                            Button("Unarchive", action: {
                                archivedHabit.archivedAt = nil
                            })
                            Button("Delete forever", role: .destructive, action: {
                                habitToDelete = archivedHabit
                            })
                        }
                    }
                } footer: {
                    Text("Long press to unarchive a habit or delete it forever.")
                }
            }
            .confirmationDialog(
                "Confirm deletion",
                isPresented: Binding(
                    get: { habitToDelete != nil },
                    set: { newValue,_ in habitToDelete = newValue ? habitToDelete : nil }
                ),
                actions: {
                    Button("Delete forever", role: .destructive, action: {
                        if let habitToDelete = habitToDelete {
                            modelContext.delete(habitToDelete)
                        }
                    })
                    Button("Cancel", role: .cancel, action: { habitToDelete = nil })
                },
                message: { Text("Do you really want to delete \(habitToDelete?.name ?? "")? This action cannot be undone.") }
            )
        }
    }
}

struct ArchivedHabitsView: View {
    var body: some View {
        ArchivedHabits()
            .navigationTitle("Archived Habits")
    }
}

#Preview("empty state") {
    NavigationStack {
        ArchivedHabitsView()
    }
}

#Preview("with archived habits") {
    do {
        let previewer = try Previewer()

        return NavigationStack {
            ArchivedHabitsView()
        }
        .modelContainer(previewer.container)
        .tint(.primary)
    } catch {
        return Text("error creating preview: \(error.localizedDescription)")
    }
    
}
