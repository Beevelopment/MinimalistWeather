//
//  Constants.swift
//  minimalistweather
//
//  Created by Carl Henningsson on 10/21/18.
//  Copyright © 2018 Carl Henningsson. All rights reserved.
//

import Foundation
import UIKit

typealias DownloadComplete = () -> ()

let API_KEY = "a6dacec67af42488b5bcbe45e8c75e06"

let rainImgOne = ["proximity moderate rain", "heavy intensity rain", "moderate rain"]
let rainImgTwo = ["proximity shower rain", "light intensity shower rain"]
let rainImgThree = ["light intensity drizzle", "light rain"]
let thunderStormImgOne = ["proximity thunderstrorm", "thunderstorm"]
let thunderStormImgTwo = ["thunderstorm with light rain", "thunderstorm with rain"]
let cloudsImgOne = ["broken clouds", "overcast clouds"]
let cloudImgTwo = ["few clouds", "scattered clouds"]
let clearImgOne = ["sky is clear", "clear sky"]
let snowImgOne = ["light snow", "light shower sleet", "snow"]
let mistImgOne = ["mist", "smoke", "haze", "dust", "fog", "sand"]

//Fonts
let GILL_SANS_ITALIC = "GillSans-Italic"
let GILL_SANS_BOLD = "GillSans-Bold"
let GILL_SANS_BOLD_ITALIC = "GillSans-BoldItalic"
let GILL_SANS_LIGHT_ITALIC = "GillSans-LightItalic"
let GILL_SANS_LIGHT = "GillSans-Light"
let GILL_SANS_SEMIBOLD = "GillSans-SemiBold"
let GILL_SANS_SEMIBOLD_ITALIC = "GillSans-SemiBoldItalic"
let GILL_SANS_ULTRABOLD = "GillSans-UltraBold"
let GILL_SANS = "GillSans"

var temporaryPrefix = false
let isFahrenheit = UserDefaults.standard.bool(forKey: "isFahrenheit")
let userSuitDefaults = UserDefaults(suiteName: "group.com.hc.weatherwidget")

let currentThemeDefault = UserDefaults.standard.object(forKey: "Theme")
