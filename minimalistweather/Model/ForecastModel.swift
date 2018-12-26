//
//  ForecastModel.swift
//  minimalistweather
//
//  Created by Carl Henningsson on 10/21/18.
//  Copyright © 2018 Carl Henningsson. All rights reserved.
//

import Foundation

class ForecastModel {
    
    private var _weatherType: String!
    private var _currentTemp: Double!
    private var _date: Double!
    
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
    var date: Double {
        if _date == nil {
            _date = 0
        }
        return _date
    }
    
    init(weatherDict: Dictionary<String, AnyObject>) {
        guard let temp = weatherDict["temp"] as? Dictionary<String, AnyObject> else { return }
        guard let day = temp["day"] as? Double else { return }
        self._currentTemp = round(day - 273.15)
        
        guard let weatherType = weatherDict["weather"] as? [Dictionary<String, AnyObject>] else { return }
        guard let main = weatherType[0]["description"] as? String else { return }
        self._weatherType = main.lowercased()
        
        guard let date = weatherDict["dt"] as? Double else { return }
        self._date = date
    }
}
