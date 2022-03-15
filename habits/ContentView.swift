//
//  ContentView.swift
//  habits
//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI

struct ContentView: View {
    @State private var showingSettings = false
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationView {
            DashboardView()
            .navigationTitle("habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Label("Add new habit", systemImage: "plus")
                            .labelStyle(IconOnlyLabelStyle())
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
