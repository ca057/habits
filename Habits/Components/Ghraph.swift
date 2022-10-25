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
    
    var weeks: Int {
        var distance = Double(to.since(from, in: .day) ?? 0) / 7
        distance.round(.up)
        return Int(distance)
    }
    // FIXME: make this dependent on the language and ensure it’s synced with the used calendar
    var weekDays = ["M", "T", "W", "T", "F", "S", "S"]

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
                let nextDate = to.adjust(for: .startOfWeek)?.offset(.week, value: index * -1)
                
                let endOfWeek = nextDate?.adjust(for: .endOfWeek) ?? Date.now
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
