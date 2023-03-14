//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI

struct Dashboard: View {
    @StateObject private var viewModel = ViewModel()
    @Environment(\.editMode) private var editMode

    var body: some View {
        NavigationView {
            Group {
                if viewModel.habits.isEmpty {
                    VStack {
                        Spacer()
                        EmptyState() {
                            viewModel.showingAddHabit = true
                        }
                        .padding()
                        Spacer()
                        Spacer()
                    }.padding(.horizontal)
                } else {
                    VStack {
                        List {
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
                            .onMove {  viewModel.reorderElements(source: $0, destination: $1) }
                            .onDelete { _ in }
                        }
//                        AddHabitButton {
//                            viewModel.showingAddHabit = true
//                        }
                    }
                }
            }
            .alert("Delete habit?", isPresented: $viewModel.showingDeleteHabitConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteHabit()
                }
            }
            .navigationTitle(Text("Your habits"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.habits.isEmpty {
                        EditButton()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.habits.isEmpty {
                        Button {
                            viewModel.showingAddHabit = true
                        } label: {
                            Label("Add new habit", systemImage: "plus")
                                .labelStyle(IconOnlyLabelStyle())
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddHabit) {
                AddHabitView()
            }
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
    }
}

