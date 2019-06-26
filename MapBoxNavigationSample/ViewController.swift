//
//  ViewController.swift
//  MapBoxNavigationSample
//
//  Created by FMI-PC-LT-32 on 1/8/19.
//  Copyright © 2019 FMI-PC-LT-32. All rights reserved.
//

import UIKit
import MapboxDirections
import MapboxNavigation
import MapboxCoreNavigation


class ViewController: UIViewController {

    
    @IBOutlet weak var label: UILabel!
    
    var mapShown: Bool = false
    
    let clLocationManager = CLLocationManager()
    
    var currentLocation: CLLocation!
    
    /* Pickup coordinate */
    fileprivate let pickUpLat = 27.710672
    fileprivate let pickUpLong = 85.319066
    
    /* Drop off coordinate */
    fileprivate let dropOffLat = 27.699684
    fileprivate let dropOffLong = 85.300005
    
    var mapNavigationViewController: NavigationViewController!
    
    @IBOutlet weak var buttonNavigation: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupLocationManager()
    }

    @IBAction func startNavigation(_ sender: Any) {
        clLocationManager.startUpdatingLocation()
        buttonNavigation.isHidden = true
    }
    
}


extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard locations.count > 0 else {
            return
        }
        
        currentLocation = locations.first
        
        clLocationManager.stopUpdatingLocation()
     
        if !mapShown {
            showNavigationMap()
            mapShown = !mapShown
        }
    }
}


private extension ViewController {
    
    func setupLocationManager() {
        
        clLocationManager.requestAlwaysAuthorization()
        clLocationManager.requestWhenInUseAuthorization()
        
        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func showNavigationMap() {
        
        let origin = Waypoint(coordinate: currentLocation.coordinate, name: "Your Location")
        
        let pickUpCoordinate = CLLocationCoordinate2D(latitude: Double(pickUpLat), longitude: Double(pickUpLong))
        
        let dropOffCoordinate = CLLocationCoordinate2D(latitude: Double(dropOffLat), longitude: Double(dropOffLong))
        
        let pickUpLocation = Waypoint(coordinate: pickUpCoordinate, name: "Pickup Location")
        
        let deliveryLocation = Waypoint(coordinate: dropOffCoordinate, name: "Delivery Location")
        
        var options: NavigationRouteOptions!
      
        options = NavigationRouteOptions(waypoints: [origin, pickUpLocation, deliveryLocation])
       
        Directions.shared.calculate(options) { [weak self] (waypoints, routes, error) in
            
            guard let self = self else {
                return
            }
            
            guard let route = routes?.first else {
                return
            }
        
            let customBannerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "customBottomBannerViewController") as! CustomBottomBannerViewController
            
            customBannerViewController.mapDelegate = self
            
            let navigationOptions = NavigationOptions(styles: nil, navigationService: nil, voiceController: nil, bottomBanner: customBannerViewController)
            
            self.mapNavigationViewController = NavigationViewController(for: route, options: navigationOptions)
            
            self.mapNavigationViewController.delegate = self
            
            self.mapNavigationViewController.navigationService.delegate = self
            
            self.addChild(self.mapNavigationViewController)
            self.view.addSubview(self.mapNavigationViewController.view)
            
            self.mapNavigationViewController.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.mapNavigationViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                self.mapNavigationViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                self.mapNavigationViewController.view.topAnchor.constraint(equalTo: self.label.topAnchor, constant: 20),
                self.mapNavigationViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
                ])
            
            self.didMove(toParent: self)
            
        }
    }
}

extension ViewController: NavigationViewControllerDelegate, NavigationServiceDelegate {
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
        showAlertMessage("You have arrived at \(waypoint.name)")
        return false
    }
    
    func router(_ router: Router, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
      
        let currentLegProgress = RouteLegProgress(leg: progress.currentLeg)
        
        label.text = "\(currentLegProgress.distanceRemaining) meters, \(currentLegProgress.durationRemaining) seconds"
        
        showAlertMessage("\(currentLegProgress.distanceRemaining) meters, \(currentLegProgress.durationRemaining) seconds")
    }
}


private extension ViewController {
    
    func showAlertMessage(_ message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


extension ViewController: MapDelegate {
    
    func recenterMap() {
        print("RECENTER CALLED")
        mapNavigationViewController.mapView?.recenterMap()
    }
}
