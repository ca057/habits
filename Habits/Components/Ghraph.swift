//
//  Ghraph.swift
//  Habits
//
//  Created by Christian Ost on 05.07.22.
//

import SwiftUI

let weekdays = [
    "Monday",
    "Tuesday"
]

struct Ghraph: View {
    var from: Date
    var to: Date
    
    var weeks: Int {
        var interval = to.timeIntervalSince(from) / 60 / 60 / 24 / 7
        interval.round(.up)
        return Int(interval)
    }
    
    let formatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = .init(identifier: Locale.current.languageCode ?? "en")
        return fmt
    }()

    var body: some View {
        VStack {
            Text(from.formatted())
//            Text(from.adjust(for: .startOfWeek)?.formatted() ?? "")
            Text(from.formatted())
            Text(to.formatted())
            
        
            Text(String(weeks))
            HStack {
                ForEach(formatter.veryShortWeekdaySymbols, id: \.self) {
                    Text($0)
                }
            }
            ForEach(0..<weeks, id: \.self) { index in
                Text(String(index))
            }
        }
    }
}

struct Ghraph_Previews: PreviewProvider {
    static var previews: some View {
        Ghraph(
            from: Date.now.advanced(by: 60 * 60 * 24 * 64 * -1),
            to: Date.now
        )
    }
}
