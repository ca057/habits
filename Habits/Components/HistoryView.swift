//
//  HistoryView.swift
//  Habits
//
//  Created by Christian Ost on 16.09.23.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        ExpandableRows(
            minimumRows: 4,
            header: { Header() }
        ) { rowIndex in
            Week(calendarWeek: rowIndex)
        }.background(.blue.opacity(0.1))
    }
}

extension HistoryView {
    private struct Header: View {
        var body: some View {
            HStack(spacing: 0) {
                Spacer()
                    .frame(maxWidth: .infinity)
                ForEach(0..<CalendarUtils.shared.weekDays.count, id: \.self) { index in
                    Text(CalendarUtils.shared.weekDays[index])
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                        // TODO: find a better style here
                        .fontWeight(index < 5 ? .regular : .bold)
                        .frame(maxWidth: .infinity)
                        .border(.black)
                }
            }
        }
    }
    
    private struct Week: View {
        var calendarWeek: Int
        var body: some View {
            Text("Week: \(calendarWeek)")
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
