//
//  Calendar.swift
//  Habits
//
//  Created by Christian Ost on 04.12.23.
//

import Foundation

extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        // copied from https://gist.github.com/mecid/f8859ea4bdbd02cf5d440d58e936faec

        var dates: [Date] = []
        dates.append(interval.start)
        
        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
        return dates
    }
}
