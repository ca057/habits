//
//  UIColor.swift
//  Habits
//
//  Created by Christian Ost on 05.07.22.
//

import SwiftUI

extension UIColor {
    // credits to https://stackoverflow.com/a/30713456/5857439
    var hsba: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h: h, s: s, b: b, a: a)
    }
}
