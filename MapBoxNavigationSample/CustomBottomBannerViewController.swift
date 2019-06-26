//
//  CustomBottomBannerViewController.swift
//  MapBoxNavigationSample
//
//  Created by FMI-PC-LT-32 on 4/16/19.
//  Copyright © 2019 FMI-PC-LT-32. All rights reserved.
//

import UIKit
import MapboxCoreNavigation
import MapboxDirections
import CoreLocation
import MapboxNavigation


protocol MapDelegate: class {
    func recenterMap()
}

class CustomBottomBannerViewController: UIViewController, NavigationComponent {

    var text: String?
    
    var mapDelegate: MapDelegate?
   
    @IBOutlet weak var labelInfo: UILabel!
    
    @IBAction func recenterMap(_ sender: Any) {
        guard mapDelegate != nil else {
            print("NO DELEGATE SET")
            return
        }
        print("RECENTER MAP CLICKED")
        mapDelegate?.recenterMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelInfo.text = "Custom banner"
    }
   
}
