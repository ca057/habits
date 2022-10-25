//
//  Ghraph.swift
//  Habits
//
//  Created by Christian Ost on 05.07.22.
//

import SwiftUI
import DateHelper

struct Row<Content>: View where Content: View {
    var start: Date
    @ViewBuilder var cell: (Date?) -> Content

    var body: some View {
        ForEach(0..<7) { index in
            let date = start.offset(.day, value: index)
            VStack {
                cell(date)
                    .frame(maxWidth: .infinity)
                    .opacity(date?.compare(.isInTheFuture) ?? false ? 0.25 : 1)
            }
        }
    }
}

struct Ghraph<Content>: View where Content: View {
    var from: Date
    var to: Date
    @ViewBuilder var cell: (Date?) -> Content
    
    var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2
        return c
    }
    
    var weeks: Int {
        var distance = Double(to.since(from, in: .day) ?? 0) / 7
        distance.round(.up)
        return Int(distance)
    }
    
    var weekDays: [String] {
        var day = Date().adjust(for: .startOfWeek, calendar: calendar)
        var wd = [String]()
        for _ in 0...6 {
            wd.append(
                day?.toString(
                    format: .custom("EEEEE"),
                    locale: Locale(identifier: Locale.current.languageCode ?? "en")
                ) ?? ""
            )
            day = day?.offset(.day, value: 1)
        }
        return wd
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                    .frame(maxWidth: .infinity)
                ForEach(weekDays, id: \.self) {
                    Text($0)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom)
            
            ForEach(0..<weeks, id: \.self) { index in
                let nextDate = to.adjust(for: .startOfWeek, calendar: calendar)?.offset(.week, value: index * -1)
                
                let endOfWeek = nextDate?.adjust(for: .endOfWeek, calendar: calendar) ?? Date.now
                let hasMonthChange: Bool = !(nextDate?.compare(.isSameMonth(as: endOfWeek)) ?? true)
                let startIsFirstDayOfMonth: Bool = nextDate?.component(.day) == 1

                HStack {
                    Text(hasMonthChange || startIsFirstDayOfMonth
                         ? endOfWeek.toString(format: .custom("MMM"))?.description ?? ""
                         : ""
                    )
                    .rotationEffect(.degrees(-45))
                    .frame(maxWidth: .infinity)
                    Row(start: nextDate ?? to, cell: cell).frame(maxWidth: .infinity)
                }
            }
        }.frame(maxWidth: .infinity)
    }
}

struct Ghraph_Previews: PreviewProvider {
    static var previews: some View {
        Ghraph(
            from: Date.now.advanced(by: 60 * 60 * 24 * 65 * -1),
            to: Date.now
        ) { date in
            RoundedRectangle(cornerRadius: .infinity)
                .stroke(.cyan)
//                .fill(.crown)
                
//            Text(String(date?.component(.day) ?? 0))
        }
    }
}
