//
//  App.swift
//  Habits
//
//  Created by Christian Ost on 29.03.23.
//

import SwiftUI
import SwiftData

struct MainApp: View {
    private let dayChangedPublisher = NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
    
    @State private var today = Date.now

    var body: some View {
        Dashboard(showUntil: today)
            .onReceive(dayChangedPublisher, perform: { _ in today = Date.now })
    }
}
