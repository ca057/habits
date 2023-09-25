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
            minimumRows: 2,
            header: { Header() },
            incRowsButton: { action in Button("show more", action: action) },
            decRowsButton: { action in Button("show less", action: action) }
        ) { rowIndex in
            let monthYearForIndex = getYearAndMonthFor(rowIndex)

            Month(year: monthYearForIndex.year, month: monthYearForIndex.month)
        }
            .padding(.vertical)
            .border(.blue)
    }
    
    private func getYearAndMonthFor(_ index: Int) -> (year: Int, month: Int) {
        let offset = 12 - month
        
        let monthForRow = 12 - ((index + offset) % 12)
        let yearForRow = year - Int(floor(Double((index + offset) / 12)))
        
        return (year: yearForRow, month: monthForRow)
    }
}

extension HistoryView {
    private struct Header: View {
        var body: some View {
            VStack {
                Divider()
                HStack(spacing: 0) {
                    ForEach(0..<CalendarUtils.shared.weekDays.count, id: \.self) { index in
                        Text(CalendarUtils.shared.weekDays[index])
                            .fontDesign(.monospaced)
                            .fontWeight(index < 5 ? .bold : .regular)
                            .frame(maxWidth: .infinity)
                    }
                }
                Divider()
            }
        }
    }
}

fileprivate struct Month: View {
    var year: Int
    var month: Int
    
    var monthStr: String {
        CalendarUtils.shared.months[month - 1]
    }
    
    // TODO: move it out of here
    var yearFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ""
        
        return formatter
    }
    
    var yearStr: String {
        yearFormatter.string(from: NSNumber(value: year))!
    }
    
    private var weekNumbers: [Int] {
        let lastWeekStartOfMonth = Date(
            fromString: "\(yearStr)-\(monthStr)",
            format: Date.DateFormatType.isoYearMonth
        )?.adjust(for: .endOfMonth, calendar: CalendarUtils.shared.calendar)?.adjust(for: .startOfWeek, calendar: CalendarUtils.shared.calendar)
        
        guard let lastWeekStartOfMonth else { return [] }

        var currentConsideredWeek = lastWeekStartOfMonth
        var weekNumbers = [Int]()
        
        while true {
            let lastConsideredWeekNumber = currentConsideredWeek.component(.week)
            
            guard let lastConsideredWeekNumber else { break }
            
            weekNumbers.append(lastConsideredWeekNumber)
            
            guard let nextWeekToConsider = currentConsideredWeek
                .offset(.week, value: -1)?
                .adjust(for: .endOfWeek, calendar: CalendarUtils.shared.calendar) else { break }
            
            if currentConsideredWeek.compare(.isSameMonth(as: nextWeekToConsider)) {
                currentConsideredWeek = nextWeekToConsider
            } else {
                break
            }
        }
        
        return weekNumbers
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(monthStr) \(yearStr)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline)
                .fontDesign(.rounded)
            Grid {
                ForEach(weekNumbers, id: \.self) { weekNumber in
                    GridRow {
                        Text("\(weekNumber)")
                        // TODO: one cell per day of the week
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func getDaysInWeek(_ weekNumber: Int) -> [Date?] {
        return []
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            HistoryView()
                .padding()
        }
    }
}
