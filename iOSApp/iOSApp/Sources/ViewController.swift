//
//  ViewController.swift
//  iOSApp
//
//  Created by Oliver Paray on 9/8/19.
//  Copyright © 2019 Oliver Paray. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let manager = DATAManager.shared
    
    @IBOutlet weak var latitudeField: UILabel!
    @IBOutlet weak var longitudeField: UILabel!
    @IBOutlet weak var xAccelField: UILabel!
    @IBOutlet weak var yAccelField: UILabel!
    @IBOutlet weak var zAccelField: UILabel!
    @IBOutlet weak var weatherView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

