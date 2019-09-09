//
//  ViewController.swift
//  iOSApp
//
//  Created by Oliver Paray on 9/8/19.
//  Copyright © 2019 Oliver Paray. All rights reserved.
//

import UIKit

class ViewController: UIViewController,DATAManagerDelegate {
        
    //MARK: Outlets
    @IBOutlet weak var latitudeField: UILabel!
    @IBOutlet weak var longitudeField: UILabel!
    @IBOutlet weak var xAccelField: UILabel!
    @IBOutlet weak var yAccelField: UILabel!
    @IBOutlet weak var zAccelField: UILabel!
    @IBOutlet weak var weatherView: UITextView!
    
    //MARK: Properties
    var manager = DATAManager.sharedInstance()
    var instructionText: String?

    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        instructionText = self.weatherView.text
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.latitudeField.layer.borderColor = UIColor.black.cgColor
        self.longitudeField.layer.borderColor = UIColor.black.cgColor
    }
    
    //MARK: Actions

    @IBAction func buttonPressed(sender: UIButton){
        guard let title = sender.titleLabel, let text = title.text else {
            return
        }
        
        if text == "Start" {
            sender.setTitle("Stop", for: .normal)
            manager.start()
        } else {
            sender.setTitle("Start", for: .normal)
            weatherView.text = instructionText
            manager.stop()
        }
    }

    func located(onLat latitude: Double, andLong longitude: Double) {
        latitudeField.text = "\(latitude)"
        longitudeField.text = "\(longitude)"
    }
    
    func acceleratedOn(x: Double, andOnY y: Double, andOnZ z: Double) {
        xAccelField.text = "\(x)"
        yAccelField.text = "\(y)"
        zAccelField.text = "\(z)"
    }
    
    func received(_ data: Data) {
        guard let jsonString = String(data: data, encoding: .utf8) else {
            return
        }
        DispatchQueue.main.async {
            self.weatherView.text = jsonString
        }
    }
}

