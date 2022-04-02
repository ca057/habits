//
//  ContentView.swift
//  habits
//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI

struct ContentView: View {    
    @State private var hackyRefreshId = UUID() // FIXME: how can I get rid of that?
    
    @State private var showingSettings = false
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationView {
            DashboardView()
                .id(hackyRefreshId)
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
                .onChange(of: showingSettings, perform: recreateHackyRefreshId)
                .onChange(of: showingAddHabit, perform: recreateHackyRefreshId)
        }
    }
    
    func recreateHackyRefreshId(showingSheet: Bool) {
        if showingSheet {
            return
        }
        hackyRefreshId = UUID()
    }
}
