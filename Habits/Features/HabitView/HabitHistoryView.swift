//
//  HabitHistoryView.swift
//  Habits
//
//  Created by Christian Ost on 25.10.23.
//

import SwiftUI

struct HabitHistoryView: View {
    @Environment(\.dismiss) private var dismissView
    
    var body: some View {
        NavigationView {
            // TODO: pass in initial months to render
            HistoryView() { date in
                Text("\(date.toString(format: .custom("d")) ?? "")")
                    .monospacedDigit()
                    .foregroundStyle(date.compare(.isWeekend) ? .secondary : .primary)
            }
            .padding(.vertical)
            .ignoresSafeArea(edges: .bottom)
            .navigationBarTitle("History", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", action: { dismissView() })
                        .buttonStyle(CircularButtonStyle(title: "Close", systemName: "xmark.circle.fill"))
                }
            }
        }
    }
}

#Preview {
    HabitHistoryView()
}
