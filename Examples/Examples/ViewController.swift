//
//  ViewController.swift
//  Examples
//
//  Created by 谷少魁 on 2022/9/1.
//

import UIKit
import GMDatePicker

class ViewController: UIViewController {

    let datePicker = GMDatePicker(Date(), type: .lunar, enableNoYear: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let width:CGFloat = 320
        let x = (self.view.bounds.size.width - width) / 2
        datePicker.frame = CGRect(x: x, y: 200, width: width, height: 200)
        view.addSubview(datePicker)
    }


}

