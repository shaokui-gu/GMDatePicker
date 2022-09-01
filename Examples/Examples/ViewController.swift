//
//  ViewController.swift
//  Examples
//
//  Created by 谷少魁 on 2022/9/1.
//

import UIKit
import GMDatePicker

class ViewController: UIViewController {

    let datePicker = GMDatePicker(.lunar)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(datePicker)
    }


}

