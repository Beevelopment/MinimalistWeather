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
import Lottie
import AudioToolbox
import DeviceKit

class WeatherController: UIViewController, UITextFieldDelegate, MKLocalSearchCompleterDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let searchButton: UIButton = {
        let searchBtn = UIButton(type: .system)
        searchBtn.setImage(UIImage(named: "search")?.withRenderingMode(.alwaysTemplate), for: .normal)
        searchBtn.widthAnchor.constraint(equalToConstant: 28).isActive = true
        searchBtn.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        return searchBtn
    }()
    
    let updateUIButton: UIButton = {
        let updateBtn = UIButton(type: .system)
        updateBtn.setImage(UIImage(named: "update-arrow")?.withRenderingMode(.alwaysTemplate), for: .normal)
        updateBtn.tintColor = .black
        updateBtn.addTarget(self, action: #selector(refreshButton), for: .touchUpInside)
        
        return updateBtn
    }()
    
    let gpsButton: UIButton = {
        let gpsBtn = UIButton(type: .system)
        gpsBtn.setImage(UIImage(named: "gps")?.withRenderingMode(.alwaysTemplate), for: .normal)
        gpsBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        gpsBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
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
    
    lazy var weatherCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.contentInset.bottom = 70
        
        return cv
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
    
    let loadAnimation: AnimationView = {
        let load = AnimationView(name: "weatherAnimation")
        load.loopMode = .loop
        load.isHidden = true
        
        return load
    }()
    
    let informationButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .white
        btn.setTitle("?", for: .normal)
        btn.titleLabel?.font = UIFont(name: GILL_SANS, size: 25)!
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 25
        btn.layer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        btn.layer.shadowRadius = 5
        btn.addTarget(self, action: #selector(infoButton), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var themeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 3
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        
        return cv
    }()
    
    let titleView = UIView()

    let reachability = Reachability()!
    
    let cellId = "cellID"
    let headerId = "headerId"
    let cityCellId = "cityCellID"
    let currentWeatherModel = CurrentWeatherModel()
    var forecasts = [ForecastModel]()
    
    let locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    var currentLocation: CLLocation!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResult = [MKLocalSearchCompletion]()
    
    var LAT: Double?
    var LON: Double?
    
    lazy var informationHandler: InformationHandler = {
        let info = InformationHandler()
        info.weaterController = self
        
        return info
    }()
    
    let themeCollectionViewId = "themeCollectionViewId"
    let themeColors: [UIColor] = {
        
        let button = UIColor.white
        let green = Themes.greenTheme.backgroundColor
        let white = Themes.whiteTheme.backgroundColor
        let lightPink = Themes.lightPinkTheme.backgroundColor
        let darkPink = Themes.darkPinkTheme.backgroundColor
        let darkPurple = Themes.darkPurpleTheme.backgroundColor
        let marineBlue = Themes.marineBlueTheme.backgroundColor
        let darkMode = Themes.darkModeTheme.backgroundColor
        
        let colorArray = [button, green, white, lightPink, darkPink, darkPurple, marineBlue, darkMode]
        
        return colorArray
    }()
    
    var isExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        temporaryPrefix = userSuitDefaults!.bool(forKey: "isFahrenheit")
        setupTheme()
        searchCompleter.delegate = self
        
        setupNetworkNotification()
        locationSetup()
        setupView()
        
        registerCells()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeTemp))
        tapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func registerCells() {
        weatherCollectionView.register(CurrentWeatherHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        weatherCollectionView.register(WeatherCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        cityTableView.register(SearchLocationCell.self, forCellReuseIdentifier: cityCellId)
        themeCollectionView.register(ThemeCollectionViewCell.self, forCellWithReuseIdentifier: themeCollectionViewId)
    }
    
    private func locationSetup() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        configureLocationService()
    }
    
    @objc private func changeTemp() {
        if !temporaryPrefix {
            userSuitDefaults!.set(true, forKey: "isFahrenheit")
            userSuitDefaults!.synchronize()
            temporaryPrefix = true
            updateWeatherData(LAT: LAT!, LON: LON!, temp: temporaryPrefix)
        } else {
            userSuitDefaults!.set(false, forKey: "isFahrenheit")
            userSuitDefaults!.synchronize()
            temporaryPrefix = false
            updateWeatherData(LAT: LAT!, LON: LON!, temp: temporaryPrefix)
        }
    }
    
    @objc fileprivate func infoButton() {
        informationHandler.showInfoHandler()
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
                if let response = response?.mapItems {
                    for mapItem in response {
                        let latitude = mapItem.placemark.coordinate.latitude
                        let longitude = mapItem.placemark.coordinate.longitude
                        
                        self.LAT = latitude
                        self.LON = longitude
                        
                        self.updateWeatherData(LAT: latitude, LON: longitude, temp: temporaryPrefix)
                    }
                }
            }
            self.dismissSearch()
        }
    }
    
    @objc func updateCurrentLocation() {
        currentLocation = locationManager.location
        LAT = currentLocation.coordinate.latitude
        LON = currentLocation.coordinate.longitude

        updateWeatherData(LAT: LAT!, LON: LON!, temp: temporaryPrefix)
    }
    
    func updateWeatherData(LAT: Double, LON: Double, temp: Bool) {
        let COORDINATE_URL = "http://api.openweathermap.org/data/2.5/weather?lat=\(LAT)&lon=\(LON)&appid=\(API_KEY)"
        let COORDINATE_FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(LAT)&lon=\(LON)&cnt=10&appid=\(API_KEY)"
        
        currentWeatherModel.downloadWeatherDetails(url: COORDINATE_URL) {
            self.downloadForecast(url: COORDINATE_FORECAST_URL) {
                if self.loadAnimation.isAnimationPlaying {
                    self.stopLoadAnimation()
                }
            }
        }
    }
    
    @objc func getUserLocation() {
        vibrate()
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            updateCurrentLocation()
        } else {
            configureLocationService()
            alertNotification(titel: "Location access denied", message: "To get current and relevant weather information in your area please allow location when in use.")
        }
    }
    
    @objc func refreshButton() {
        vibrate()
        updateWeatherData(LAT: LAT!, LON: LON!, temp: temporaryPrefix)
    }
    
    private func startLoadAnimation() {
        loadAnimation.isHidden = false
        loadAnimation.play()
    }
    
    private func stopLoadAnimation() {
        loadAnimation.stop()
        loadAnimation.isHidden = true
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
                self.weatherCollectionView.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let search = searchResult[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cityCellId, for: indexPath) as? SearchLocationCell else { return SearchLocationCell() }
        cell.setupCell(locationText: search.title)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cityTableView {
            startLoadAnimation()
            
            let selectedLocation = indexPath.row
            let city = searchResult[selectedLocation]
            searchForCity(cityName: city)
        }
    }
    
    private func setupTheme() {
        if let currentTheme = currentThemeDefault as? String {
            if currentTheme == "white" {
                Themes.currentTheme = WhiteTheme()
            } else if currentTheme == "lightPink" {
                Themes.currentTheme = LightPinkTheme()
            } else if currentTheme == "darkPink" {
                Themes.currentTheme = DarkPinkTheme()
            } else if currentTheme == "darkPurple" {
                Themes.currentTheme = DarkPurpleTheme()
            } else if currentTheme == "marineBlue" {
                Themes.currentTheme = MarineBlueTheme()
            } else if currentTheme == "darkMode" {
                Themes.currentTheme = DarkModeTheme()
            }
        }
    }
    
    private func setupColors() {
        view.backgroundColor = Themes.currentTheme.backgroundColor
        weatherCollectionView.backgroundColor = Themes.currentTheme.backgroundColor
        searchButton.tintColor = Themes.currentTheme.textColor
        gpsButton.tintColor = Themes.currentTheme.textColor
        updateUIButton.tintColor = Themes.currentTheme.textColor
        searchField.textColor = Themes.currentTheme.textColor
        cityTableView.backgroundColor = Themes.currentTheme.backgroundColor
        date.textColor = Themes.currentTheme.textColor
        informationButton.backgroundColor = Themes.currentTheme.backgroundColor
        informationButton.setTitleColor(Themes.currentTheme.textColor, for: .normal)
        
        weatherCollectionView.reloadData()
    }

    private func setupView() {
        setupColors()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissSearch))
        blackView.addGestureRecognizer(tapGestureRecognizer)
        
        let halfView = view.frame.width / 2
        
        [weatherCollectionView, updateUIButton, informationButton, themeCollectionView, blackView, cityTableView, loadAnimation].forEach({ view.addSubview($0) })

        _ = updateUIButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 28, heightConstant: 28)
        _ = weatherCollectionView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 0)
        _ = informationButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 20, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        themeCollectionView.frame = CGRect(x: view.frame.width - 90, y: view.frame.height - 70, width: 90, height: 70)
        _ = blackView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = cityTableView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 200)
        
        loadAnimation.frame = CGRect(x: view.frame.midX - halfView / 2, y: view.frame.midY - halfView / 2, width: halfView, height: halfView)
        
        startLoadAnimation()
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
        gpsButton.addTarget(self, action: #selector(getUserLocation), for: .touchUpInside)
        
    }
    
//    Network handeling
    
    private func setupNetworkNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("Carl: could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Carl: Reachable via WiFi")
        case .cellular:
            print("Carl: Reachable via Cellular")
        case .none:
            print("Carl: Network not reachable")
            alertNotification(titel: "Lost Connection", message: "To get current and accurate weather data you need to be connected to the internet. Please check your internet connection.")
        }
    }
    
    func alertNotification(titel: String, message: String) {
        let alert = UIAlertController(title: titel, message: message, preferredStyle: .alert)
        let actionAlert = UIAlertAction(title: "Go To Settings", style: .default) { action in
            guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingURL) {
                UIApplication.shared.open(settingURL, completionHandler: { (sucess) in
                    print("Carl: setting opened sucessfully")
                })
            }
        }
        
        alert.addAction(actionAlert)
        present(alert, animated: true, completion: nil)
    }
    
    func vibrate() {
        AudioServicesPlaySystemSound(1519)
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
            alertNotification(titel: "Location access denied", message: "To get current and relevant weather information in your area please allow location when in use.")
            break
        case .authorizedWhenInUse:
            updateCurrentLocation()
            break
        case .authorizedAlways:
            updateCurrentLocation()
            break
        case .notDetermined:
            break
        default:
            print("Error")
            break
        }
    }
}

extension WeatherController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == weatherCollectionView {
            if let header = weatherCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as? CurrentWeatherHeader {
                header.updateCurrentWeatherUI(currentWeather: currentWeatherModel, temp: temporaryPrefix)
                return header
            }
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == weatherCollectionView {
            if Device.allXSeriesDevices.contains(Device.current) {
                return CGSize(width: view.frame.width, height: view.frame.height * 0.45)
            } else {
                 return CGSize(width: view.frame.width, height: view.frame.height * 0.55)
            }
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == themeCollectionView {
            return themeColors.count
        } else if collectionView == weatherCollectionView {
            return forecasts.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = indexPath.item
        
        if collectionView == themeCollectionView {
            let color = themeColors[item]
            if let cell = themeCollectionView.dequeueReusableCell(withReuseIdentifier: themeCollectionViewId, for: indexPath) as? ThemeCollectionViewCell {
                if indexPath.item == 0 {
                    cell.setupCell(color: color, imageName: "pantone")
                } else {
                    cell.setupCell(color: color, imageName: "")
                }
                return cell
            }
        } else if collectionView == weatherCollectionView {
            let forcast = forecasts[item]
            if let cell = weatherCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? WeatherCollectionViewCell {
                cell.setupCell(forecast: forcast)
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == themeCollectionView {
            return CGSize(width: 50, height: 50)
        } else if collectionView == weatherCollectionView {
            return CGSize(width: weatherCollectionView.frame.width, height: 60)
        } else {
            return CGSize(width: 60, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == themeCollectionView {
            let cellHeight: CGFloat = CGFloat(themeColors.count * 50)
            let spacingHeight: CGFloat = CGFloat((themeColors.count - 1) * 3)
            let cvHeight: CGFloat = cellHeight + spacingHeight

            if indexPath.item == 0 {
                if isExpanded {
                    isExpanded = false
                    UIView.animate(withDuration: 0.5) {
                        self.themeCollectionView.frame = CGRect(x: self.view.frame.width - 90, y: self.view.frame.height - 70, width: 90, height: cvHeight + 20)
                    }
                } else {
                    isExpanded = true
                    UIView.animate(withDuration: 0.5) {
                        self.themeCollectionView.frame = CGRect(x: self.view.frame.width - 90, y: self.view.frame.height - cvHeight - 20, width: 90, height: cvHeight + 20)
                    }
                }
            } else {
                if indexPath.item == 1 {
                    Themes.currentTheme = GreenTheme()
                    UserDefaults.standard.set(Themes.greenTheme.themeIdentifier, forKey: "Theme")
                } else if indexPath.item == 2 {
                    Themes.currentTheme = WhiteTheme()
                    UserDefaults.standard.set(Themes.whiteTheme.themeIdentifier, forKey: "Theme")
                } else if indexPath.item == 3 {
                    Themes.currentTheme = LightPinkTheme()
                    UserDefaults.standard.set(Themes.lightPinkTheme.themeIdentifier, forKey: "Theme")
                } else if indexPath.item == 4 {
                    Themes.currentTheme = DarkPinkTheme()
                    UserDefaults.standard.set(Themes.darkPinkTheme.themeIdentifier, forKey: "Theme")
                } else if indexPath.item == 5 {
                    Themes.currentTheme = DarkPurpleTheme()
                    UserDefaults.standard.set(Themes.darkPurpleTheme.themeIdentifier, forKey: "Theme")
                } else if indexPath.item == 6 {
                    Themes.currentTheme = MarineBlueTheme()
                    UserDefaults.standard.set(Themes.marineBlueTheme.themeIdentifier, forKey: "Theme")
                } else if indexPath.item == 7 {
                    Themes.currentTheme = DarkModeTheme()
                    UserDefaults.standard.set(Themes.darkModeTheme.themeIdentifier, forKey: "Theme")
                }
                
                setupColors()
                isExpanded = false
                UIView.animate(withDuration: 0.5) {
                    self.themeCollectionView.frame = CGRect(x: self.view.frame.width - 90, y: self.view.frame.height - 70, width: 90, height: cvHeight + 20)
                }
            }
        }
    }
}
