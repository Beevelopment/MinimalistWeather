//
//  MessagesViewController.swift
//  Minimalist iMessage
//
//  Created by Carl Henningsson on 2019-05-29.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import Messages
import CoreLocation
import AudioToolbox
import Alamofire

class MessagesViewController: MSMessagesAppViewController, UITableViewDelegate, UITableViewDataSource {
    let currentWeatherModel = CurrentWeatherModel()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Minimalist Weather iMessage"
        lbl.textAlignment = .center
        lbl.font = UIFont(name: GILL_SANS, size: 21)!
        lbl.adjustsFontSizeToFitWidth = true
        
        return lbl
    }()
    
    let currentWeatherButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .white
        btn.setTitle("Send Current Weather", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont(name: GILL_SANS, size: 16)!
        btn.layer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
        btn.layer.shadowOpacity = 0.075
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        btn.layer.shadowRadius = 5
        btn.isUserInteractionEnabled = true
        btn.addTarget(self, action: #selector(updateMessage), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.delegate = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        
        return tv
    }()
    
    let layout = MSMessageTemplateLayout()
    let message = MSMessage()
    
    let cellId = "cellID"
    var forecasts = [ForecastModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        tableView.register(WeatherCell.self, forCellReuseIdentifier: cellId)
    }
    
    func coordinateURL(forecast: Bool) -> String {
        currentLocation = locationManager.location
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        
        if forecast {
            return "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(lat)&lon=\(lat)&cnt=10&appid=\(API_KEY)"
        } else {
            return "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(API_KEY)"
        }
    }
    
    func downloadForecast() {
        guard let url = URL(string: coordinateURL(forecast: true)) else { return }
        forecasts = []
        Alamofire.request(url).responseJSON { response in
            let result = response.result
            if let dict = result.value as? Dictionary<String, AnyObject> {
                guard let list = dict["list"] as? [Dictionary<String, AnyObject>] else { return }
                for object in list {
                    let forecast = ForecastModel(weatherDict: object)
                    self.forecasts.append(forecast)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func updateMessage() {
        AudioServicesPlaySystemSound(1519)
        
        let location = currentWeatherModel.cityName
        let weatherType = currentWeatherModel.weatherType
        let temperatur = Int(currentWeatherModel.currentTemp)
        
        layout.caption = "My current weather in \(location) is \(weatherType) and the temperature is \(temperatur) degrees"
        layout.image = getImage(string: currentWeatherModel.weatherType)
    
        message.layout = layout
        activeConversation?.insert(message, completionHandler: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let forecast = forecasts[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? WeatherCell else { return WeatherCell() }
        cell.setupCell(forecast: forecast)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let forecast = forecasts[indexPath.row]
        let location = currentWeatherModel.cityName
        let weatherType = forecast.weatherType
        let temperatur = Int(currentWeatherModel.currentTemp)
        
        let date = Date(timeIntervalSince1970: forecast.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"
        let result = formatter.string(from: date)
        
        layout.caption = "On \(result) the weather in \(location) should be \(weatherType) and the temperature should be \(temperatur) degrees"
        layout.image = getImage(string: forecast.weatherType)
        
        message.layout = layout
        activeConversation?.insert(message, completionHandler: nil)
        
        dismiss()
    }
    
    func getImage(string: String) -> UIImage {
        let weatherTypes = [rainImgOne, rainImgTwo, rainImgThree, thunderStormImgOne, thunderStormImgTwo, cloudsImgOne, cloudImgTwo, clearImgOne, snowImgOne, mistImgOne]
        let weatherTypesImages = ["rainImgOne", "rainImgTwo", "rainImgThree", "thunderStormImgOne", "thunderStormImgTwo", "cloudsImgOne", "cloudImgTwo", "clearImgOne", "snowImgOne", "mistImgOne"]
        
        for weatherType in weatherTypes {
            let index = weatherTypes.firstIndex(of: weatherType)
            if weatherType.contains(string.lowercased()) {
                return UIImage(named: weatherTypesImages[index!])!
            }
        }
        return UIImage(named: "")!
    }
    
//    override func willBecomeActive(with conversation: MSConversation) {
//        currentWeatherModel.downloadWeatherDetails(url: coordinateURL(forecast: false)) {}
//        downloadForecast()
//    }

    override func viewDidAppear(_ animated: Bool) {
        currentWeatherModel.downloadWeatherDetails(url: coordinateURL(forecast: false)) {}
        downloadForecast()
    }
    
    func setupView() {
        let margin = view.frame.width / 10
        
        currentWeatherButton.layer.cornerRadius = margin * 0.75
        
        [titleLabel, currentWeatherButton, tableView].forEach {( view.addSubview($0) )}
        _ = titleLabel.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: margin / 2, leftConstant: margin / 2, bottomConstant: 0, rightConstant: margin / 2, widthConstant:0, heightConstant:0)
        _ = currentWeatherButton.anchor(titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: margin / 2, leftConstant: margin, bottomConstant: 0, rightConstant: margin, widthConstant: margin * 8, heightConstant: margin * 1.5)
        _ = tableView.anchor(currentWeatherButton.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: margin, leftConstant: 0, bottomConstant: margin / 2, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}
