//
//  ColorPicker.swift
//  Habits
//
//  Created by Christian Ost on 04.07.22.
//

import SwiftUI

enum Colour: String, CaseIterable, Identifiable {
    case base
    case orange
    case blue
    case green
    case red
    case yellow
    case mint
    case purple
    
    var id: Colour { self }
}

extension Colour {
    static var allCasesSorted: [Colour] {
        get {
            Colour.allCases.sorted(by: {
                UIColor($0.toColor()).hsba.h < UIColor($1.toColor()).hsba.h
            })
        }
    }
    static func fromRawValue(_ rawValue: String?) -> Colour {
        guard let result = mappingDict[rawValue ?? ""] else {
            return mappingDict["base"]!.0
        }
        return result.0
    }

    static private var mappingDict: [Colour.RawValue : (Colour, Color, String)] = [
        "base": (Colour.base, Color.primary, "primary colour"),
        "purple": (Colour.purple, Color.purple, "purple"),
        "mint": (Colour.mint, Color.mint, "mint"),
        "yellow": (Colour.yellow, Color.yellow, "yellow"),
        "red": (Colour.red, Color.red, "red"),
        "green": (Colour.green, Color.green, "green"),
        "blue": (Colour.blue, Color.blue, "blue"),
        "orange": (Colour.orange, Color.orange, "orange")
    ]
    static private func mapFromRawValue(_ rawValue: String?) -> (Colour, Color, String) {
        guard let result = mappingDict[rawValue ?? "base"] else {
            return mappingDict["base"]!
        }
        return result
    }
    
    init?(rawValue: String?) {
        self = Colour.mapFromRawValue(rawValue).0
    }
    
    func toColor() -> Color {
        return Colour.mapFromRawValue(self.rawValue).1
    }
    
    func toLabel() -> String {
        return Colour.mapFromRawValue(self.rawValue).2
    }
}

private struct ColourPickerButton: View {
    var colour: Colour
    @Binding var selected: Bool
    var perform: (Colour) -> Void
    private var color: Color {
        colour.toColor()
    }

    var body: some View {
        Button(action: {
            perform(colour)
        }) {
            // TODO: make this size dynamic
            Pill(color: color, filled: $selected)
        }
        .buttonStyle(BorderlessButtonStyle())
        .accessibilityLabel(colour.toLabel())
        .frame(maxWidth: .infinity)
    }
}



struct ColourPicker: View {
    var colours: [Colour]
    @Binding var selection: Colour

    var body: some View {
        HStack(spacing: 4) {
            ForEach(colours, id: \.self) { colour in
                ColourPickerButton(
                    colour: colour,
                    selected: Binding(get: { selection == colour }, set: { _ in }),
                    perform: { selection = $0 }
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("light mode") {
    ColourPicker(
        colours: Colour.allCasesSorted,
        selection: .constant(Colour.allCasesSorted[0])
    ).preferredColorScheme(.light)
}

#Preview("dark mode") {
    ColourPicker(
        colours: Colour.allCasesSorted,
        selection: .constant(Colour.allCasesSorted[0])
    ).preferredColorScheme(.dark)
}
