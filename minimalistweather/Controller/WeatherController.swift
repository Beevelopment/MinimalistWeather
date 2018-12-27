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
import MapKit

class WeatherController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MKLocalSearchCompleterDelegate {
    
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
    
    lazy var searchField: UITextField = {
        let search = UITextField()
        search.placeholder = "Search for City"
        search.textAlignment = .center
        search.layer.borderColor = UIColor(white: 0, alpha: 0.5).cgColor
        search.layer.borderWidth = 0.5
        search.layer.cornerRadius = 5
        search.alpha = 0
        search.delegate = self
        search.returnKeyType = .search
        
        return search
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
    
    lazy var weatherTableView: UITableView = {
        let tb = UITableView()
        tb.dataSource = self
        tb.delegate = self
        tb.backgroundColor = .clear
        tb.separatorStyle = .none
        tb.allowsSelection = false
        
        return tb
    }()
    
    lazy var cityTableView: UITableView = {
        let tb = UITableView()
        tb.dataSource = self
        tb.delegate = self
        tb.backgroundColor = .clear
        tb.separatorStyle = .none
        tb.allowsSelection = true
        tb.showsVerticalScrollIndicator = false
        tb.isHidden = true
        
        return tb
    }()
    
    let blackView: UIView = {
        let b = UIView()
        b.backgroundColor = UIColor(white: 0, alpha: 0.5)
        b.alpha = 0
        
        return b
    }()
    
    let date: UILabel = {
        let date = UILabel()
        date.font = UIFont(name: GILL_SANS, size: 21)!
        date.textAlignment = .center
        
        return date
    }()

    let titleView = UIView()

    let cellId = "cellID"
    let cityCellId = "cityCellID"
    let currentWeatherModel = CurrentWeatherModel()
    var forecasts = [ForecastModel]()
    
    let locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    var currentLocation: CLLocation!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResult = [MKLocalSearchCompletion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        searchCompleter.delegate = self
        
        configureLocationService()
        
        setupView()
        
        weatherTableView.register(WeatherCell.self, forCellReuseIdentifier: cellId)
        cityTableView.register(SearchLocationCell.self, forCellReuseIdentifier: cityCellId)
    }
    
    @objc func searchButtonAction() {
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        date.removeFromSuperview()
        
        searchField.frame = titleView.bounds
        titleView.addSubview(searchField)
        navigationItem.titleView = titleView
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.searchField.alpha = 1
            self.blackView.alpha = 1
        }, completion: nil)
        
        searchField.becomeFirstResponder()
    }
    
    @objc func dismissSearch() {
        searchField.resignFirstResponder()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.cityTableView.isHidden = true
            self.searchField.alpha = 0
            self.blackView.alpha = 0
        }, completion: nil)
        
        searchField.removeFromSuperview()
        
        date.frame = titleView.bounds
        titleView.addSubview(date)
        navigationItem.titleView = titleView
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResult = completer.results
        if searchResult.count > 0 {
            cityTableView.isHidden = false
            cityTableView.reloadData()
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchCompleter.filterType = .locationsOnly
        searchCompleter.queryFragment = searchField.text!
        completerDidUpdateResults(searchCompleter)
        
        if textField.text == "" {
            searchResult = []
            cityTableView.reloadData()
        }
    }
    
    func searchForCity(cityName: MKLocalSearchCompletion) {
        dismissSearch()
        
        let searchRequest = MKLocalSearch.Request(completion: cityName)
        let activateSearch = MKLocalSearch(request: searchRequest)
        
        activateSearch.start { (response, error) in
            if error != nil {
                print("carl: \(String(describing: error))")
            } else {
                let latitude = response!.boundingRegion.center.latitude
                let longitude = response!.boundingRegion.center.longitude

                Location.sharedInstance.LAT = latitude
                Location.sharedInstance.LON = longitude

                self.updateWeatherData(LAT: latitude, LON: longitude)
            }
            self.dismissSearch()
        }
    }
    
    @objc func updateCurrentLocation() {
        currentLocation = locationManager.location
        let LAT = currentLocation.coordinate.latitude
        let LON = currentLocation.coordinate.longitude

        updateWeatherData(LAT: LAT, LON: LON)
    }
    
    func updateWeatherData(LAT: Double, LON: Double) {
        let COORDINATE_URL = "http://api.openweathermap.org/data/2.5/weather?lat=\(LAT)&lon=\(LON)&appid=\(API_KEY)"
        let COORDINATE_FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(LAT)&lon=\(LON)&cnt=10&appid=\(API_KEY)"
        
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
                self.weatherTableView.reloadData()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == weatherTableView {
            return forecasts.count
        } else if tableView == cityTableView {
            return searchResult.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == weatherTableView {
            let forecast = forecasts[indexPath.row]
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? WeatherCell else { return WeatherCell() }
            cell.setupCell(forecast: forecast)
            return cell
        } else if tableView == cityTableView {
            let search = searchResult[indexPath.row]
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cityCellId, for: indexPath) as? SearchLocationCell else { return SearchLocationCell() }
            cell.setupCell(locationText: search.title)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == weatherTableView {
            return 60
        } else if tableView == cityTableView {
            return 40
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cityTableView {
            let selectedLocation = indexPath.row
            let city = searchResult[selectedLocation]
            searchForCity(cityName: city)
        }
    }

    private func setupView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissSearch))
        blackView.addGestureRecognizer(tapGestureRecognizer)
        
        let margin = view.frame.width / 10
        let imageSize = margin * 4
        let tempSize = margin * 3
        let halfView = view.frame.width / 2
        
        view.addSubview(backgroundImage)
        view.addSubview(weatherIcon)
        view.addSubview(tempetureLabel)
        view.addSubview(locationLabel)
        view.addSubview(weatherTypeLabel)
        view.addSubview(weatherTableView)
        view.addSubview(blackView)
        view.addSubview(cityTableView)
        
        _ = backgroundImage.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = weatherIcon.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: margin / 2, leftConstant: 0, bottomConstant: 0, rightConstant: margin, widthConstant: imageSize, heightConstant: imageSize)
        _ = tempetureLabel.anchor(weatherIcon.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: margin / 2, leftConstant: margin, bottomConstant: 0, rightConstant: 0, widthConstant: tempSize, heightConstant: imageSize)
        _ = locationLabel.anchor(weatherIcon.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: margin, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: halfView, heightConstant: 0)
        _ = weatherTypeLabel.anchor(weatherIcon.bottomAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: margin, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: halfView, heightConstant: 0)
        _ = weatherTableView.anchor(locationLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: margin * 1.5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = blackView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = cityTableView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 200)
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .black
        
        //place title
        titleView.frame = CGRect(x: 60, y: 0, width: view.frame.width - 120, height: 35)
        date.text = getTodaysDate()
        
        date.frame = titleView.bounds
        titleView.addSubview(date)
        navigationItem.titleView = titleView
        
        //place buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchButton)
        searchButton.addTarget(self, action: #selector(searchButtonAction), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: gpsButton)
        gpsButton.addTarget(self, action: #selector(updateCurrentLocation), for: .touchUpInside)
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

