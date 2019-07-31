//
//  CurrentWeatherHeader.swift
//  minimalistweather
//
//  Created by Carl Henningsson on 2019-07-27.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

protocol CollectionViewHeaderDelegate {
    func updateUI(cell: CurrentWeatherHeader)
}

class CurrentWeatherHeader: UICollectionReusableView {
    
    var delegate: CollectionViewHeaderDelegate?
    
    let updateUIButton: UIButton = {
        let updateBtn = UIButton(type: .system)
        updateBtn.setImage(UIImage(named: "update-arrow")?.withRenderingMode(.alwaysTemplate), for: .normal)
        updateBtn.tintColor = .black
        updateBtn.addTarget(self, action: #selector(updateButtonAction), for: .touchUpInside)
        
        return updateBtn
    }()

    let weatherIcon: UIImageView = {
        let weatherImg = UIImageView()
        weatherImg.contentMode = .scaleAspectFit

        return weatherImg
    }()

    let tempetureLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: GILL_SANS_SEMIBOLD, size: 70)!
        lbl.textAlignment = .right
        lbl.adjustsFontSizeToFitWidth = true

        return lbl
    }()

    let locationLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont(name: GILL_SANS_BOLD, size: 21)!
        lbl.adjustsFontSizeToFitWidth = true

        return lbl
    }()

    let weatherTypeLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = UIFont(name: GILL_SANS_BOLD, size: 21)!
        lbl.adjustsFontSizeToFitWidth = true

        return lbl
    }()
    
    let maxTempLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont(name: GILL_SANS_LIGHT, size: 21)!
        
        return lbl
    }()
    
    let minTempLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont(name: GILL_SANS_LIGHT, size: 21)!
        
        return lbl
    }()
    
    let sunRiseLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont(name: GILL_SANS_LIGHT, size: 21)!
        
        return lbl
    }()
    
    let sunSetLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont(name: GILL_SANS_LIGHT, size: 21)!
        
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeader()
    }
    
    @objc private func updateButtonAction() {
        delegate?.updateUI(cell: self)
    }
    
    private func setupColors() {
        backgroundColor = Themes.currentTheme.backgroundColor
        updateUIButton.tintColor = Themes.currentTheme.textColor
        weatherIcon.tintColor = Themes.currentTheme.textColor
        tempetureLabel.textColor = Themes.currentTheme.textColor
        locationLabel.textColor = Themes.currentTheme.textColor
        weatherTypeLabel.textColor = Themes.currentTheme.textColor
        maxTempLabel.textColor = Themes.currentTheme.textColor
        minTempLabel.textColor = Themes.currentTheme.textColor
        sunRiseLabel.textColor = Themes.currentTheme.textColor
        sunSetLabel.textColor = Themes.currentTheme.textColor
    }
    
    func updateCurrentWeatherUI(currentWeather: CurrentWeatherModel, temp: Bool) {
        setupColors()
        
        let degrees = currentWeather.currentTemp
        if !temp {
            tempetureLabel.text = "\(Int(degrees))°C"
            maxTempLabel.text = "Max: \(Int(currentWeather.maxTemp))°C"
            minTempLabel.text = "Min: \(Int(currentWeather.minTemp))°C"
        } else {
            tempetureLabel.text = "\(Int(degrees))°F"
            maxTempLabel.text = "Max: \(Int(currentWeather.maxTemp))°F"
            minTempLabel.text = "Min: \(Int(currentWeather.minTemp))°F"
        }
        
        let sunRiseTimestamp = Date(timeIntervalSince1970: currentWeather.sunRise)
        let sunSetTimestamp = Date(timeIntervalSince1970: currentWeather.sunSet)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:MM"
        
        let sunRiseString = dateFormatter.string(from: sunRiseTimestamp)
        let sunSetString = dateFormatter.string(from: sunSetTimestamp)
        
        sunRiseLabel.text = "Sunrise: \(sunRiseString)"
        sunSetLabel.text = "Sunset: \(sunSetString)"

        locationLabel.text = currentWeather.cityName
        weatherTypeLabel.text = currentWeather.weatherType.capitalized

        let weatherTypes = [rainImgOne, rainImgTwo, rainImgThree, thunderStormImgOne, thunderStormImgTwo, cloudsImgOne, cloudImgTwo, clearImgOne, snowImgOne, mistImgOne]
        let weatherTypesImages = ["rainImgOne", "rainImgTwo", "rainImgThree", "thunderStormImgOne", "thunderStormImgTwo", "cloudsImgOne", "cloudImgTwo", "clearImgOne", "snowImgOne", "mistImgOne"]

        for weatherType in weatherTypes {
            let index = weatherTypes.firstIndex(of: weatherType)
            if weatherType.contains(currentWeather.weatherType.lowercased()) {
                weatherIcon.image = UIImage(named: weatherTypesImages[index!])?.withRenderingMode(.alwaysTemplate)
            }
        }
    }

    func setupHeader() {
        let margin = frame.width / 10
        let imageSize = margin * 4
        let tempSize = margin * 3
        let halfView = frame.width / 2

        [updateUIButton, weatherIcon, tempetureLabel, locationLabel, weatherTypeLabel, maxTempLabel, minTempLabel, sunRiseLabel, sunSetLabel].forEach { addSubview($0) }

        _ = updateUIButton.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 28, heightConstant: 28)
        _ = weatherIcon.anchor(topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: margin / 2, leftConstant: 0, bottomConstant: 0, rightConstant: margin, widthConstant: imageSize, heightConstant: imageSize)
        _ = tempetureLabel.anchor(weatherIcon.topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: margin / 2, leftConstant: margin, bottomConstant: 0, rightConstant: 0, widthConstant: tempSize, heightConstant: imageSize)
        _ = locationLabel.anchor(weatherIcon.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: margin, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: (halfView - margin / 2) - 20, heightConstant: 0)
        _ = weatherTypeLabel.anchor(weatherIcon.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: margin, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: (halfView - margin / 2) - 20, heightConstant: 0)
        _ = maxTempLabel.anchor(locationLabel.bottomAnchor, left: locationLabel.leftAnchor, bottom: nil, right: nil, topConstant: margin / 2, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = minTempLabel.anchor(maxTempLabel.topAnchor, left: nil, bottom: nil, right: weatherTypeLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        _ = sunRiseLabel.anchor(maxTempLabel.bottomAnchor, left: maxTempLabel.leftAnchor, bottom: nil, right: nil, topConstant: margin / 4, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = sunSetLabel.anchor(sunRiseLabel.topAnchor, left: nil, bottom: nil, right: minTempLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
