//
//  HistoryView.swift
//  Habits
//
//  Created by Christian Ost on 16.09.23.
//

import SwiftUI

struct HistoryView: View {
    // TODO: make it work at midnight
    private var today = Date()
    private var year: Int {
        CalendarUtils.shared.calendar.component(.year, from: today)
    }
    private var month: Int {
        CalendarUtils.shared.calendar.component(.month, from: today)
    }
    private var calendarWeek: Int {
        CalendarUtils.shared.calendar.component(.weekOfYear, from: today)
    }

    var body: some View {
        ExpandableRows(
            minimumRows: 24,
            header: { Header() },
            incRowsButton: { action in Button("show more", action: action) },
            decRowsButton: { action in Button("show less", action: action) }
        ) { rowIndex in
            let monthYearForIndex = getYearAndMonthFor(rowIndex)

            Month(year: monthYearForIndex.year, month: monthYearForIndex.month)
        }.background(.blue.opacity(0.1))
    }
    
    private func getYearAndMonthFor(_ index: Int) -> RowDateInfo {
        let offset = 12 - month
        
        let monthForRow = 12 - ((index + offset) % 12)
        let yearForRow = year - Int(floor(Double((index + offset) / 12)))
        
        return RowDateInfo(year: yearForRow, month: monthForRow)
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
    
    private struct Month: View {
        var year: Int
        var month: Int

        var body: some View {
            HStack {
                Text("\(year) \(String(month).padding(leftTo: 2, withPad: "0", startingAt: 0))")
                    .monospacedDigit()
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .border(.black)
        }
    }
    
    private struct RowDateInfo {
        let year: Int
        let month: Int
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .padding()
    }
}
