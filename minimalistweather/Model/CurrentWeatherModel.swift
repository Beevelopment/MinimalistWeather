//
//  CurrentWeatherModel.swift
//  minimalistweather
//
//  Created by Carl Henningsson on 10/21/18.
//  Copyright © 2018 Carl Henningsson. All rights reserved.
//

import UIKit
import Alamofire

class CurrentWeatherModel {
    private var _cityName: String!
    private var _weatherType: String!
    private var _currentTemp: Double!
    private var _minTemp: Double!
    private var _maxTemp: Double!
    private var _sunRise: Double!
    private var _sunSet: Double!
    
    var cityName: String {
        if _cityName == nil {
            _cityName = ""
        }
        return _cityName
    }
    var weatherType: String {
        if _weatherType == nil {
            _weatherType = ""
        }
        return _weatherType
    }
    var currentTemp: Double {
        if _currentTemp == nil {
            _currentTemp = 0.0
        }
        return _currentTemp
    }
    var minTemp: Double {
        if _minTemp == nil {
            _minTemp = 0.0
        }
        return _minTemp
    }
    var maxTemp: Double {
        if _maxTemp == nil {
            _maxTemp = 0.0
        }
        return _maxTemp
    }
    var sunRise: Double {
        if _sunRise == nil {
            _sunRise = 0.0
        }
        return _sunRise
    }
    var sunSet: Double {
        if _sunSet == nil {
            _sunSet = 0.0
        }
        return _sunSet
    }
    
    func downloadWeatherDetails(url: String, completed: @escaping DownloadComplete) {
        guard let url = URL(string: url) else { return }
        Alamofire.request(url).responseJSON { response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                
//                city name
                guard let name = dict["name"] as? String else { return }
                self._cityName = name.capitalized
                
//                weather type
                guard let weather = dict["weather"] as? [Dictionary<String, AnyObject>] else { return }
                guard let main = weather[0]["description"] as? String else { return }
                self._weatherType = main.lowercased()
                
//                current temp
                guard let mainDict = dict["main"] as? Dictionary<String, AnyObject> else { return }
                guard let currentTemp = mainDict["temp"] as? Double else { return }
                guard let minTemp = mainDict["temp_min"] as? Double else { return }
                guard let maxTemp = mainDict["temp_max"] as? Double else { return }
                
                if let temp = userSuitDefaults?.bool(forKey: "isFahrenheit") {
                    if temp == true {
                        self._currentTemp = kelvinToFahrenheit(kelvin: currentTemp)
                        self._minTemp = kelvinToFahrenheit(kelvin: minTemp)
                        self._maxTemp = kelvinToFahrenheit(kelvin: maxTemp)
                    } else if temporaryPrefix == false {
                        self._currentTemp = kelvinToCelsius(kelvin: currentTemp)
                        self._minTemp = kelvinToCelsius(kelvin: minTemp)
                        self._maxTemp = kelvinToCelsius(kelvin: maxTemp)
                    }
                }
                
//                Sun Rise and Sun Set
                guard let sys = dict["sys"] as? Dictionary<String, AnyObject> else { return }
                guard let sunRise = sys["sunrise"] as? Double else { return }
                guard let sunSet = sys["sunset"] as? Double else { return }
                self._sunRise = sunRise
                self._sunSet = sunSet
            }
            completed()
        }
    }
}
