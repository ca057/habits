//
//  SingleHabitSettingsView.swift
//  Habits
//
//  Created by Christian Ost on 11.05.24.
//

import SwiftUI

struct SingleHabitSettingsView: View {
    @Environment(\.dismiss) private var dismissView
    @Environment(\.navigation) private var navigation
    @Environment(\.modelContext) private var modelContext
    
    var habit: Habit
    
    @State private var name = ""
    
    @State private var showingDeleteConfirmation = false
    @State private var showingArchiveConfirmation = false
    @State private var showingCloseConfirmation = false
    
    private var isDirty: Bool {
        name != habit.name
    }

    var body: some View {
        VStack {
            Form {
                Section("Details") {
                    LabeledContent("Name") {
                        TextField("Name", text: $name)
                    }.labeledContentStyle(LTLabeledContentStyle())
                }

                Section("Colour") {
                    ColourPicker(colours: Colour.allCasesSorted, selection: Bindable(habit).asColour)
                        .frame(minHeight: 32)
                        .padding(.vertical, 8)
                }
                
                Section("Danger Zone") {
                    Button(action: { showingArchiveConfirmation = true }) {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Archive habit")
                                Text("This habit will not be shown on home and excluded from all analysis. You can unarchive it in the main settings.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "archivebox")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }

                    Button(action: { showingDeleteConfirmation = true }) {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Delete habit")
                            }
                        } icon: {
                            Image(systemName: "trash")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Settings (\(name))")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel", action: { attemptCloseView() })
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: { saveChanges() })
                    .disabled(!isDirty)
                    .fontWeight(isDirty ? .bold : .regular)
            }
        }
        .confirmationDialog("Confirm deletion",
               isPresented: $showingDeleteConfirmation,
               actions: {
                    Group {
                        Button("Cancel", role: .cancel, action: {})
                        Button("Delete", role: .destructive, action: deleteHabit)
                    }
                },
               message: { Text("Do you really want to delete “\(name)”? This action cannot be undone.") }
        )
        .confirmationDialog(
            "Discard changes",
            isPresented: $showingCloseConfirmation,
            actions: {
                Group {
                    Button("Cancel", role: .cancel, action: {})
                    Button("Discard", role: .destructive, action: { dismissView() })
                }
            },
            message: { Text("Do you want to discard the changes you made?") }
        )
        .confirmationDialog(
            "Archive habit",
            isPresented: $showingArchiveConfirmation,
            actions: {
                Group {
                    Button("Archive", role: .destructive, action: archiveHabit)
                    Button("Cancel", role: .cancel, action: {})
                }
            }
        )
        .onAppear {
            name = habit.name
        }
    }

    private func deleteHabit() {
        dismissView()
        navigation.path = NavigationPath()

        modelContext.delete(habit)
        try? modelContext.save()
    }
    
    private func archiveHabit() {
        dismissView()

        navigation.path = NavigationPath()
        habit.archivedAt = Date.now
    }
    
    private func attemptCloseView() {
        if isDirty {
            showingCloseConfirmation = true
        } else {
            dismissView()
        }
    }
    
    private func saveChanges() {
        habit.name = name
        
        dismissView()
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        return NavigationStack {
            SingleHabitSettingsView(habit: previewer.habits[0])
        }
        .modelContainer(previewer.container)
        .tint(.primary)
    } catch {
        return Text("failed to create preview: \(error.localizedDescription)")
    }

}
