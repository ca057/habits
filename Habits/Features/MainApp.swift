//
//  App.swift
//  Habits
//
//  Created by Christian Ost on 29.03.23.
//

import SwiftUI

struct MainApp: View {
    var body: some View {
        TabView {
            FastRowThing()
                .tabItem {
                    Label("Habits", systemImage: "checklist")
                }
            
            Settings()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

struct MainApp_Previews: PreviewProvider {
    static var previews: some View {
        MainApp()
    }
}
