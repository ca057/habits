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
            VStack {
                List {
                    
                }
                
                Button {
                    showingAddHabit = true
                } label: {
                    Label("Add new habit", systemImage: "plus.square.on.square")
                        .labelStyle(IconOnlyLabelStyle())
                }
                .padding()
            }
            .navigationTitle("habits")
            .toolbar {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
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
