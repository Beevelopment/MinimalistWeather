//
//  WeatherController.swift
//  minimalistweather
//
//  Created by Carl Henningsson on 10/21/18.
//  Copyright © 2018 Carl Henningsson. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class WeatherController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let backgroundImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "bg")
        
        return img
    }()
    
    let searchButton: UIButton = {
        let searchBtn = UIButton(type: .system)
        searchBtn.setImage(#imageLiteral(resourceName: "search"), for: .normal)
        searchBtn.widthAnchor.constraint(equalToConstant: 25).isActive = true
        searchBtn.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        return searchBtn
    }()
    
    let gpsButton: UIButton = {
        let gpsBtn = UIButton(type: .system)
        gpsBtn.setImage(#imageLiteral(resourceName: "paper-plane"), for: .normal)
        gpsBtn.widthAnchor.constraint(equalToConstant: 25).isActive = true
        gpsBtn.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        return gpsBtn
    }()
    
    let weatherIcon: UIImageView = {
        let weatherImg = UIImageView()
        weatherImg.contentMode = .scaleAspectFit
        
        return weatherImg
    }()
    
    let tempetureLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: GILL_SANS_SEMIBOLD, size: 70)!
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        
        return lbl
    }()
    
    let locationLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = .black
        lbl.font = UIFont(name: GILL_SANS, size: 21)!
        
        return lbl
    }()
    
    let weatherTypeLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = .black
        lbl.font = UIFont(name: GILL_SANS, size: 21)!
        
        return lbl
    }()
    
    lazy var tableView: UITableView = {
        let tb = UITableView()
        tb.dataSource = self
        tb.delegate = self
        tb.backgroundColor = .clear
        tb.separatorStyle = .none
        tb.allowsSelection = false
        
        return tb
    }()

    let cellId = "cellID"
    let currentWeatherModel = CurrentWeatherModel()
    var forecasts = [ForecastModel]()
    
    let locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        configureLocationService()
        
        setupView()
        
        tableView.register(WeatherCell.self, forCellReuseIdentifier: cellId)
    }
    
    @objc func searchButtonAction() {
        print("Carl: Function is working")
    }
    
    func updateCurrentLocation() {
        currentLocation = locationManager.location
        Location.sharedInstance.LAT = currentLocation.coordinate.latitude
        Location.sharedInstance.LON = currentLocation.coordinate.longitude
        
        updateWeatherData()
    }
    
    func updateWeatherData() {
        currentWeatherModel.downloadWeatherDetails(url: COORDINATE_URL) {
            self.downloadForecast(url: COORDINATE_FORECAST_URL) {
                self.updateCurrentWeatherUI()
            }
        }
    }
    
    func downloadForecast(url: String, completed: @escaping DownloadComplete) {
        guard let url = URL(string: url) else { return }
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
            completed()
        }
    }
    
    private func getTodaysDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "d MMM, yyyy"
        
        let result = formatter.string(from: date)
        
        return result
    }
    
    func updateCurrentWeatherUI() {
        tempetureLabel.text = "\(Int(currentWeatherModel.currentTemp))°"
        locationLabel.text = currentWeatherModel.cityName
        weatherTypeLabel.text = currentWeatherModel.weatherType.capitalized
        var imageName: String!
        
        if rainImgOne.contains(currentWeatherModel.weatherType.lowercased()) {
            imageName = "rainImgOne"
            weatherIcon.image = UIImage(named: imageName)
        } else if rainImgTwo.contains(currentWeatherModel.weatherType.lowercased()) {
            imageName = "rainImgTwo"
            weatherIcon.image = UIImage(named: imageName)
        } else if rainImgThree.contains(currentWeatherModel.weatherType.lowercased()) {
            imageName = "rainImgThree"
            weatherIcon.image = UIImage(named: imageName)
        } else if thunderStormImgOne.contains(currentWeatherModel.weatherType.lowercased()) {
            imageName = "thunderStormImgOne"
            weatherIcon.image = UIImage(named: imageName)
        } else if thunderStormImgTwo.contains(currentWeatherModel.weatherType.lowercased()) {
            imageName = "thunderStormImgTwo"
            weatherIcon.image = UIImage(named: imageName)
        } else if cloudsImgOne.contains(currentWeatherModel.weatherType.lowercased()) {
            imageName = "cloudsImgOne"
            weatherIcon.image = UIImage(named: imageName)
        } else if cloudImgTwo.contains(currentWeatherModel.weatherType.lowercased()) {
            imageName = "cloudImgTwo"
            weatherIcon.image = UIImage(named: imageName)
        } else if snowImgOne.contains(currentWeatherModel.weatherType.lowercased()) {
            imageName = "snowImgOne"
            weatherIcon.image = UIImage(named: imageName)
        } else if mistImgOne.contains(currentWeatherModel.weatherType.lowercased()) {
            imageName = "mistImgOne"
            weatherIcon.image = UIImage(named: imageName)
        } else if clearImgOne.contains(currentWeatherModel.weatherType.lowercased()) {
            imageName = "clearImgOne"
            weatherIcon.image = UIImage(named: imageName)
        }
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

    private func setupView() {
        let margin = view.frame.width / 10
        let imageSize = margin * 4
        let tempSize = margin * 3
        let halfView = view.frame.width / 2
        
        view.addSubview(backgroundImage)
        view.addSubview(weatherIcon)
        view.addSubview(tempetureLabel)
        view.addSubview(locationLabel)
        view.addSubview(weatherTypeLabel)
        view.addSubview(tableView)
        
        _ = backgroundImage.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = weatherIcon.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: margin / 2, leftConstant: 0, bottomConstant: 0, rightConstant: margin, widthConstant: imageSize, heightConstant: imageSize)
        _ = tempetureLabel.anchor(weatherIcon.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: margin / 2, leftConstant: margin, bottomConstant: 0, rightConstant: 0, widthConstant: tempSize, heightConstant: imageSize)
        _ = locationLabel.anchor(weatherIcon.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: margin, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: halfView, heightConstant: 0)
        _ = weatherTypeLabel.anchor(weatherIcon.bottomAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: margin, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: halfView, heightConstant: 0)
        _ = tableView.anchor(locationLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: margin * 1.5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .black
        
        //place title
        title = getTodaysDate()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: GILL_SANS, size: 21)!]
        
        //place buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchButton)
        searchButton.addTarget(self, action: #selector(searchButtonAction), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: gpsButton)
    }
}

extension WeatherController: CLLocationManagerDelegate {
    func configureLocationService() {
        if authorizationStatus == .authorizedWhenInUse {
            return
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .restricted, .denied:
            print("Carl: denied")
            break
        case .authorizedWhenInUse:
            updateCurrentLocation()
            break
        case .authorizedAlways:
            updateCurrentLocation()
            break
        case .notDetermined:
            break
        }
    }
}

