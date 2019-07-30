//
//  WidgetCurrentWeatherModel.swift
//  WeatherWidget
//
//  Created by Carl Henningsson on 2019-05-21.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

//import UIKit
//import Alamofire
//
//class WidgetCurrentWeatherModel {
//    private var _cityName: String!
//    private var _weatherType: String!
//    private var _currentTemp: Double!
//    
//    var cityName: String {
//        if _cityName == nil {
//            _cityName = ""
//        }
//        return _cityName
//    }
//    var weatherType: String {
//        if _weatherType == nil {
//            _weatherType = ""
//        }
//        return _weatherType
//    }
//    var currentTemp: Double {
//        if _currentTemp == nil {
//            _currentTemp = 0.0
//        }
//        return _currentTemp
//    }
//    
//    func downloadWeatherDetails(url: String, completed: @escaping DownloadComplete) {
//        guard let url = URL(string: url) else { return }
//        print("Carl: Url: \(url)")
//        Alamofire.request(url).responseJSON { response in
//            let result = response.result
//            
//            if let dict = result.value as? Dictionary<String, AnyObject> {
//                //                city name
//                guard let name = dict["name"] as? String else { return }
//                self._cityName = name.capitalized
//                print("Carl: weather city \(name)")
//                
//                //                weather type
//                guard let weather = dict["weather"] as? [Dictionary<String, AnyObject>] else { return }
//                guard let main = weather[0]["description"] as? String else { return }
//                self._weatherType = main.lowercased()
//                
//                print("Carl: weather main \(main)")
//                //                current temp
//                guard let mainDict = dict["main"] as? Dictionary<String, AnyObject> else { return }
//                guard let currentTemp = mainDict["temp"] as? Double else { return }
//                self._currentTemp = round(currentTemp)
//            }
//            completed()
//        }
//    }
//}
