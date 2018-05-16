//
//  ViewController.swift
//  YHSlider
//
//  Created by baiwei－mac on 2018/5/15.
//  Copyright © 2018年 YuHua. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var slider : YHSlider!
    var label : UILabel!
    var ob : NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let slider = YHSlider(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: view.frame.width))
        slider.titleArray = Array(5...30)
        slider.currentValue = 5.9
        slider.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        self.slider = slider
        view.addSubview(slider)
        
        label = UILabel(frame: CGRect(x: 0, y: 20+view.frame.width, width: view.frame.width, height: view.frame.width))
        label.font = UIFont.systemFont(ofSize: 100, weight: .heavy)
        label.textAlignment = .center
        label.text = String(Int(slider.currentValue!))
        label.textColor = .green
        view.addSubview(label)
        
        slider.valueChange = { [weak self] value in
            self?.label.text = String(Int(value))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

