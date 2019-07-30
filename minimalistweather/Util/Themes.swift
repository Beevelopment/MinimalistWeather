//
//  Themes.swift
//  minimalistweather
//
//  Created by Carl Henningsson on 2019-07-26.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

protocol ThemeProtocol {
    var backgroundColor: UIColor { get }
    var textColor: UIColor { get }
    var shadowColor: UIColor { get }
    var themeIdentifier: String { get }
}

class Themes {
    static var currentTheme: ThemeProtocol = WhiteTheme()
    static var whiteTheme = WhiteTheme()
    static var darkModeTheme = DarkModeTheme()
    static var greenTheme = GreenTheme()
    static var lightPinkTheme = LightPinkTheme()
    static var darkPinkTheme = DarkPinkTheme()
    static var darkPurpleTheme = DarkPurpleTheme()
    static var marineBlueTheme = MarineBlueTheme()
//    static var greyTheme = GreyTheme()
}

class WhiteTheme: ThemeProtocol {
    var backgroundColor: UIColor = .white
    var textColor: UIColor = .black
    var shadowColor: UIColor = .black
    var themeIdentifier: String = "white"
}

class DarkModeTheme: ThemeProtocol {
    var backgroundColor: UIColor = UIColor(red: 41 / 255, green: 41 / 255, blue: 41 / 255, alpha: 1)
    var textColor: UIColor = .white
    var shadowColor: UIColor = .black
    var themeIdentifier: String = "darkMode"
}

class GreenTheme: ThemeProtocol {
    var backgroundColor: UIColor = UIColor(red: 143 / 255, green: 185 / 255, blue: 171 / 255, alpha: 1)
    var textColor: UIColor = .white
    var shadowColor: UIColor = .black
    var themeIdentifier: String = "green"
}

class LightPinkTheme: ThemeProtocol {
    var backgroundColor: UIColor = UIColor(red: 252 / 255, green: 208 / 255, blue: 186 / 255, alpha: 1)
    var textColor: UIColor = .darkGray
    var shadowColor: UIColor = .black
    var themeIdentifier: String = "lightPink"
}

class DarkPinkTheme: ThemeProtocol {
    var backgroundColor: UIColor = UIColor(red: 241 / 255, green: 130 / 255, blue: 141 / 255, alpha: 1)
    var textColor: UIColor = .white
    var shadowColor: UIColor = .black
    var themeIdentifier: String = "darkPink"
}

class DarkPurpleTheme: ThemeProtocol {
    var backgroundColor: UIColor = UIColor(red: 118 / 255, green: 93 / 255, blue: 105 / 255, alpha: 1)
    var textColor: UIColor = .white
    var shadowColor: UIColor = .black
    var themeIdentifier: String = "darkPurple"
}

class MarineBlueTheme: ThemeProtocol {
    var backgroundColor: UIColor = UIColor(red: 71 / 255, green: 92 / 255, blue: 122 / 255, alpha: 1)
    var textColor: UIColor = .white
    var shadowColor: UIColor = .black
    var themeIdentifier: String = "marineBlue"
}

//class GreyTheme: ThemeProtocol {
//    var backgroundColor: UIColor = UIColor(red: 77 / 255, green: 94 / 255, blue: 114 / 255, alpha: 1)
//    var textColor: UIColor = .white
//    var shadowColor: UIColor = .black
//    var themeIdentifier: String = "grey"
//}
