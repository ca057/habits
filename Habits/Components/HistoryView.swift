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
            minimumRows: 2,
            header: { Header() }
        ) { rowIndex in
            Week(calendarWeek: rowIndex)
        }
    }
}

extension HistoryView {
    private struct Header: View {
        var body: some View {
            Text("Header")
        }
    }
    
    private struct Week: View {
        var calendarWeek: Int
        var body: some View {
            Text("Week \(calendarWeek)")
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
