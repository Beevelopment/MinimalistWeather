//
//  WeatherCollectionViewCell.swift
//  minimalistweather
//
//  Created by Carl Henningsson on 2019-07-27.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    let dayLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Suturday"
        lbl.font = UIFont(name: GILL_SANS, size: 30)!
        lbl.textColor = .black
        
        return lbl
    }()
    
    let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "22 Oct, 2018"
        lbl.font = UIFont(name: GILL_SANS, size: 12)!
        lbl.textColor = .black
        
        return lbl
    }()
    
    let tempetureLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "24°"
        lbl.font = UIFont(name: GILL_SANS, size: 30)!
        lbl.textColor = .black
        
        return lbl
    }()
    
    let weatherImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        
        return imgView
    }()
    
    private func setupColors() {
        dayLabel.textColor = Themes.currentTheme.textColor
        dateLabel.textColor = Themes.currentTheme.textColor
        tempetureLabel.textColor = Themes.currentTheme.textColor
        weatherImageView.tintColor = Themes.currentTheme.textColor
    }
    
    func setupCell(forecast: ForecastModel) {
        setupColors()
        backgroundColor = .clear
        
        let margin = frame.width / 10
        let imgSize = frame.height / 10 * 8
        
        let unixConvertedDate = Date(timeIntervalSince1970: forecast.date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeStyle = .none
        dayLabel.text = unixConvertedDate.dayOfTheWeek()
        
        let date = Date(timeIntervalSince1970: forecast.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"
        let result = formatter.string(from: date)
        dateLabel.text = result
        
        if !temporaryPrefix {
            tempetureLabel.text = "\(Int(forecast.currentTemp))°C"
        } else {
            tempetureLabel.text = "\(Int(forecast.currentTemp))°F"
        }
        
        let weatherTypes = [rainImgOne, rainImgTwo, rainImgThree, thunderStormImgOne, thunderStormImgTwo, cloudsImgOne, cloudImgTwo, clearImgOne, snowImgOne, mistImgOne]
        let weatherTypesImages = ["rainImgOne", "rainImgTwo", "rainImgThree", "thunderStormImgOne", "thunderStormImgTwo", "cloudsImgOne", "cloudImgTwo", "clearImgOne", "snowImgOne", "mistImgOne"]
        
        for weatherType in weatherTypes {
            let index = weatherTypes.firstIndex(of: weatherType)
            if weatherType.contains(forecast.weatherType.lowercased()) {
                weatherImageView.image = UIImage(named: weatherTypesImages[index!])?.withRenderingMode(.alwaysTemplate)
            }
        }
        
        [dayLabel, dateLabel, weatherImageView, tempetureLabel].forEach {( addSubview($0) )}
        
        _ = dayLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: margin, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = dateLabel.anchor(nil, left: dayLabel.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = weatherImageView.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: margin, widthConstant: imgSize, heightConstant: imgSize)
        _ = tempetureLabel.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: weatherImageView.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: margin / 2, widthConstant: 0, heightConstant: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
