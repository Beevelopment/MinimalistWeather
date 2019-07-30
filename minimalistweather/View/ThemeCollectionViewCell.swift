//
//  ThemeCollectionViewCell.swift
//  minimalistweather
//
//  Created by Carl Henningsson on 2019-07-26.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

class ThemeCollectionViewCell: UICollectionViewCell {
    
    let circleView: UIView = {
        let cv = UIView()
        cv.layer.cornerRadius = 25
        cv.layer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
        cv.layer.shadowOpacity = 0.5
        cv.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        cv.layer.shadowRadius = 5
        
        return cv
    }()
    
    let imageView: UIImageView = {
        let img = UIImageView()
        
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setupCell(color: UIColor, imageName: String) {
        circleView.backgroundColor = color
        imageView.image = UIImage(named: imageName)
        
        [circleView].forEach { addSubview($0) }
        circleView.addSubview(imageView)
        _ = circleView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        _ = imageView.anchor(circleView.topAnchor, left: circleView.leftAnchor, bottom: circleView.bottomAnchor, right: circleView.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 10, rightConstant: 10, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
