//
//  View.swift
//  Habits
//
//  Created by Christian Ost on 02.09.24.
//

import SwiftUI

struct OnDayChangeNotifier: ViewModifier {
    private let dayChangedPublisher = NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
    
    @State private var today = Date.now
    
    var perform: ((Date) -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onReceive(dayChangedPublisher, perform: { _ in
                today = Date.now
                
                if let perform = perform {
                    perform(today)
                }
            })
    }
}

extension View {
    func reactOnDayChange(perform: ((Date) -> Void)? = nil) -> some View {
        modifier(OnDayChangeNotifier(perform: perform))
    }
}
