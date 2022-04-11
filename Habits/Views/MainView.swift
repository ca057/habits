//
//  ContentView.swift
//  habits
//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var viewModel = MainViewModel()

    var body: some View {
        NavigationView {
            DashboardView()
                .navigationTitle("habits")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            viewModel.showingSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
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
                .sheet(isPresented: $viewModel.showingSettings) {
                    SettingsView()
                }
                .sheet(isPresented: $viewModel.showingAddHabit) {
                    AddHabitView()
                }
        }
    }
}
