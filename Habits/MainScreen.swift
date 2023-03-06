//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = ViewModel()
    @Environment(\.editMode) private var editMode

    var body: some View {
        NavigationView {
            List {
                if viewModel.habits.isEmpty {
                    Text("No habits yet - go and create one!")
                } else {
                    ForEach(viewModel.habits) { habit in
                        DashboardItem(habit: habit)
                            .background(
                                NavigationLink("", destination: HabitView(habit)).opacity(0)
                            )
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(habit.hasEntry(for: Date.now) ? "Untick" : "Tick") {
                                    viewModel.toggleLatestEntry(for: habit)
                                }.tint(.blue)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    viewModel.requestToDelete(habit)
                                }
                            }
                    }
                    .onMove(perform: viewModel.reorderElements)
                    .onDelete { _ in }
                }
            }
            .alert("Delete habit?", isPresented: $viewModel.showingDeleteHabitConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteHabit()
                }
            }
            .navigationTitle(Text("habits"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddHabit = true
                    } label: {
                        Label("Add new habit", systemImage: "plus")
                            .labelStyle(IconOnlyLabelStyle())
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddHabit) {
                AddHabitView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

