//
//  ExpandableRows.swift
//  Habits
//
//  Created by Christian Ost on 10.09.23.
//

import SwiftUI

struct ExpandableRows<Header: View, Row: View, IncDecLabel: View>: View {
    @State private var rows: Int
    
    @ViewBuilder let header: () -> Header
    @ViewBuilder let rowRenderer: (Int) -> Row
    @ViewBuilder let incRowsButton: (@escaping () -> Void) -> Button<IncDecLabel>
    @ViewBuilder let decRowsButton: (@escaping () -> Void) -> Button<IncDecLabel>
    
    let increment: Int
    let maximumRows: Int
    let minimumRows: Int
    
    var body: some View {
        VStack {
            header()
            ForEach(0..<rows, id: \.self) {
                rowRenderer($0)
            }
            HStack {
                incRowsButton({
                    rows = min(rows + increment, maximumRows)
                })
                .disabled(rows == maximumRows)
                decRowsButton({
                    rows = max(rows - increment, minimumRows)
                })
                .disabled(rows == minimumRows)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    init(
        minimumRows: Int = 0,
        maximumRows: Int = Int.max,
        increment: Int = 10,
        header: @escaping () -> Header = { EmptyView() },
        @ViewBuilder incRowsButton: @escaping (@escaping () -> Void) -> Button<IncDecLabel> = { action in
            Button("show more", action: action)
        },
        @ViewBuilder decRowsButton: @escaping (@escaping () -> Void) -> Button<IncDecLabel> = { action in
            Button("show less", action: action)
        },
        @ViewBuilder rowRenderer: @escaping (Int) -> Row
    ) {
        self.minimumRows = max(minimumRows, 0)
        self.rows = self.minimumRows
        self.maximumRows = min(maximumRows, Int.max)
        self.increment = increment
        
        self.header = header
        self.incRowsButton = incRowsButton
        self.decRowsButton = decRowsButton
        self.rowRenderer = rowRenderer
    }
}

struct ExpandableRows_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableRows(
            minimumRows: 0,
            header: { Text("header") }
        ) { rowIndex in
            Text("row \(rowIndex)")
        }
    }
}
