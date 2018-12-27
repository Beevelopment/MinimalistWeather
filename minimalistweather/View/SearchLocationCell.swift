//
//  SearchLocationCell.swift
//  minimalistweather
//
//  Created by Carl Henningsson on 12/27/18.
//  Copyright © 2018 Carl Henningsson. All rights reserved.
//

import UIKit

class SearchLocationCell: UITableViewCell {
    
    let location: UILabel = {
        let location = UILabel()
        location.font = UIFont(name: GILL_SANS, size: 18)!
        location.textColor = .black
        
        return location
    }()
    
    let divider: UIView = {
        let d = UIView()
        d.backgroundColor = UIColor(white: 0, alpha: 0.2)
        
        return d
    }()
    
    func setupCell(locationText: String) {
        backgroundColor = .white
        
        location.text = locationText
        
        addSubview(location)
        addSubview(divider)
        
        _ = location.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = divider.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: -0.5, rightConstant: 20, widthConstant: 0, heightConstant: 1)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
