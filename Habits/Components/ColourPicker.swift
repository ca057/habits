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

struct ColourPicker: View {
    var colours: [Colour]
    @Binding var selection: Colour

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 4) {
                let itemWidth = (geometry.size.width - CGFloat((colours.count - 1) * 4)) / CGFloat(colours.count)

                ForEach(colours, id: \.self) { colour in
                    Button(action: { selection = colour }) {
                        Pill(
                            color: colour.toColor(),
                            width: itemWidth,
                            filled: Binding(get: { selection == colour }, set: { _ in })
                        )
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .accessibilityLabel(colour.toLabel())
                }
            }
        }
    }
}

#Preview {
    struct Container: View {
        @State var colorScheme = ColorScheme.light
        @State var selected = Colour.allCasesSorted[0]

        var body: some View {
            VStack(spacing: 32) {
                Spacer().frame(height: .infinity)

                VStack {
                    ColourPicker(colours: Colour.allCasesSorted, selection: $selected)
                    
                    Button("switch to \(colorScheme == .dark ? "light" : "dark")") {
                        colorScheme = colorScheme == .dark ? .light : .dark
                    }
                }
                Spacer().frame(height: .infinity)
            }
            .padding()
            .preferredColorScheme(colorScheme)
        }
    }
    
    return Container()
}
