//
//  TodayViewController.swift
//  WeatherWidget
//
//  Created by Carl Henningsson on 2019-05-21.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import CoreLocation

class TodayViewController: UIViewController, NCWidgetProviding {
    
    let currentWeatherModel = CurrentWeatherModel()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    let image: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    
    let location: UILabel = {
        let loc = UILabel()
        loc.font = UIFont(name: GILL_SANS, size: 28)!
        loc.textAlignment = .center
        loc.adjustsFontSizeToFitWidth = true
        
        return loc
    }()
    
    let weather: UILabel = {
        let w = UILabel()
        w.font = UIFont(name: GILL_SANS_LIGHT, size: 18)!
        w.textAlignment = .center
        w.adjustsFontSizeToFitWidth = true
        
        return w
    }()
    
    let temperatur: UILabel = {
        let c = UILabel()
        c.font = UIFont(name: GILL_SANS, size: 28)!
        
        return c
    }()
    
    let container = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMainApp)))
    }
    
    @objc func openMainApp() {
        let minimalistURL = "Minimalist://"
        extensionContext?.open(URL(string: minimalistURL)! , completionHandler: nil)
    }
    
    func setupView() {
        let margin = view.frame.width / 20
        let containerWidth = view.frame.width - 80
        
        [image, container, temperatur].forEach({view.addSubview($0)})
        [location, weather].forEach({container.addSubview($0)})
        _ = image.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, topConstant: 0, leftConstant: margin, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        _ = container.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 50 + margin, bottomConstant: 0, rightConstant: 50 + margin, widthConstant: containerWidth, heightConstant: view.frame.height)
        _ = location.anchor(container.topAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, topConstant: margin, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = weather.anchor(location.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = temperatur.anchor(view.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: margin, leftConstant: 0, bottomConstant: margin, rightConstant: margin, widthConstant: 0, heightConstant: 0)
    }
    
    func updateCurrentWeatherUI() {
        let degrees = currentWeatherModel.currentTemp
        
        if let temp = userSuitDefaults?.object(forKey: "isFahrenheit") as? Bool {
            if !temp {
                temperatur.text = "\(Int(degrees))°C"
            } else {
                temperatur.text = "\(Int(degrees))°F"
            }
        }

        location.text = currentWeatherModel.cityName
        weather.text = currentWeatherModel.weatherType.capitalized
        
        let weatherTypes = [rainImgOne, rainImgTwo, rainImgThree, thunderStormImgOne, thunderStormImgTwo, cloudsImgOne, cloudImgTwo, clearImgOne, snowImgOne, mistImgOne]
        let weatherTypesImages = ["rainImgOne", "rainImgTwo", "rainImgThree", "thunderStormImgOne", "thunderStormImgTwo", "cloudsImgOne", "cloudImgTwo", "clearImgOne", "snowImgOne", "mistImgOne"]
        
        for weatherType in weatherTypes {
            let index = weatherTypes.firstIndex(of: weatherType)
            if weatherType.contains(currentWeatherModel.weatherType.lowercased()) {
                image.image = UIImage(named: weatherTypesImages[index!])
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        currentLocation = locationManager.location
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        
        let COORDINATE_URL = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(API_KEY)"
        currentWeatherModel.downloadWeatherDetails(url: COORDINATE_URL) {
            self.updateCurrentWeatherUI()
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
}
