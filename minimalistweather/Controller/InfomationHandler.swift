//
//  InfomationHandler.swift
//  minimalistweather
//
//  Created by Carl Henningsson on 2019-05-21.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

class InformationHandler: NSObject {
    
    var weaterController: WeatherController?
    
    let blackView: UIView = {
        let b = UIView()
        b.backgroundColor = UIColor(white: 0, alpha: 0.5)
        b.alpha = 0
        
        return b
    }()
    
    let container: UIView = {
        let c = UIView()
        c.backgroundColor = .white
        c.layer.cornerRadius = 10
        c.layer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
        c.layer.shadowOpacity = 0.5
        c.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        c.layer.shadowRadius = 15
        
        return c
    }()
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = .black
        lbl.font = UIFont(name: GILL_SANS, size: 21)!
        lbl.numberOfLines = 0
        lbl.text = "Double tap the screen to change between Celsius and Fahrenheit."
        
        return lbl
    }()
    
    let button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Ok", for: .normal)
        btn.titleLabel?.font = UIFont(name: GILL_SANS_BOLD, size: 32)!
        btn.setTitleColor(.black, for: .normal)
        
        return btn
    }()
    
    private func setupColors() {
        container.backgroundColor = Themes.currentTheme.backgroundColor
        label.textColor = Themes.currentTheme.textColor
        button.setTitleColor(Themes.currentTheme.textColor, for: .normal)
    }
    
    func showInfoHandler() {
        setupColors()
        
        if let window = UIApplication.shared.keyWindow {
            button.addTarget(self, action: #selector(dismissInfoHandler), for: .touchUpInside)
            
            let margin = window.frame.width / 10
            
            [blackView, container].forEach({ window.addSubview($0) })
            [label, button].forEach({ container.addSubview($0) })
            
            _ = blackView.anchor(window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            
            container.frame = CGRect(x: margin, y: window.frame.height, width: margin * 8, height: margin * 5)
            _ = label.anchor(container.topAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, topConstant: margin / 2, leftConstant: margin / 2, bottomConstant: 0, rightConstant: margin / 2, widthConstant: 0, heightConstant: 0)
            _ = button.anchor(label.bottomAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: margin / 2, leftConstant: margin / 2, bottomConstant: margin / 2, rightConstant: margin / 2, widthConstant: 0, heightConstant: 35)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.blackView.alpha = 1
                self.container.frame = CGRect(x: margin, y: window.frame.height / 2 - margin * 2.5, width: margin * 8, height: margin * 5)
            }, completion: nil)
        }
    }
    
    @objc func dismissInfoHandler() {
        if let window = UIApplication.shared.keyWindow {
            let margin = window.frame.width / 10
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.blackView.alpha = 0
                self.container.frame = CGRect(x: margin, y: window.frame.height, width: margin * 8, height: margin * 5)
            }, completion: nil)
        }
    }
}
