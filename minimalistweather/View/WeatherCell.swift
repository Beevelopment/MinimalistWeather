//
//  WeatherCell.swift
//  minimalistweather
//
//  Created by Carl Henningsson on 10/21/18.
//  Copyright © 2018 Carl Henningsson. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setupCell(forecast: ForecastModel) {
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
        
        print("Carl: \(forecast.weatherType)")
        
        tempetureLabel.text = "\(Int(forecast.currentTemp))°"
        
        var imageName: String!
        
        if rainImgOne.contains(forecast.weatherType.lowercased()) {
            imageName = "rainImgOne"
            weatherImageView.image = UIImage(named: imageName)
        } else if rainImgTwo.contains(forecast.weatherType.lowercased()) {
            imageName = "rainImgTwo"
            weatherImageView.image = UIImage(named: imageName)
        } else if rainImgThree.contains(forecast.weatherType.lowercased()) {
            imageName = "rainImgThree"
            weatherImageView.image = UIImage(named: imageName)
        } else if thunderStormImgOne.contains(forecast.weatherType.lowercased()) {
            imageName = "thunderStormImgOne"
            weatherImageView.image = UIImage(named: imageName)
        } else if thunderStormImgTwo.contains(forecast.weatherType.lowercased()) {
            imageName = "thunderStormImgTwo"
            weatherImageView.image = UIImage(named: imageName)
        } else if cloudsImgOne.contains(forecast.weatherType.lowercased()) {
            imageName = "cloudsImgOne"
            weatherImageView.image = UIImage(named: imageName)
        } else if cloudImgTwo.contains(forecast.weatherType.lowercased()) {
            imageName = "cloudImgTwo"
            weatherImageView.image = UIImage(named: imageName)
        } else if snowImgOne.contains(forecast.weatherType.lowercased()) {
            imageName = "snowImgOne"
            weatherImageView.image = UIImage(named: imageName)
        } else if mistImgOne.contains(forecast.weatherType.lowercased()) {
            imageName = "mistImgOne"
            weatherImageView.image = UIImage(named: imageName)
        } else if clearImgOne.contains(forecast.weatherType.lowercased()) {
            imageName = "clearImgOne"
            weatherImageView.image = UIImage(named: imageName)
        }
        
        addSubview(dayLabel)
        addSubview(dateLabel)
        addSubview(weatherImageView)
        addSubview(tempetureLabel)
        
        _ = dayLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: margin, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = dateLabel.anchor(nil, left: dayLabel.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = weatherImageView.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: margin, widthConstant: imgSize, heightConstant: imgSize)
        _ = tempetureLabel.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: weatherImageView.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: margin / 2, widthConstant: 0, heightConstant: 0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
