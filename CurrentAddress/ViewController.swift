//
//  ViewController.swift
//  CurrentAddress
//
//  Created by ZhouHao on 17/7/14.
//  Copyright (c) 2014 Zeus Software. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBookUI

class ViewController: UIViewController , CLLocationManagerDelegate{
    
    var locationManager : CLLocationManager = CLLocationManager()
    var requesting : Bool = false
    var requestTimer : NSTimer?
    
    @IBOutlet var lblLocation: UILabel
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateRightButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let currentLocation = locations[0] as? CLLocation
        self.locationManager.stopUpdatingLocation()
        self.requesting = false
        updateRightButton()
        
        let geocoder : CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: {
            (placemarks, error) in
          
            if error { // error

                self.lblLocation.text = "Current Location Not Detected! Geocode failed with error \(error)."
                
            }
            else {
                if let placemark = placemarks[0] as? CLPlacemark {

                    println("Current location:\(placemark)")
                    
                    self.lblLocation.text = ABCreateStringWithAddressDictionary(placemark.addressDictionary, true)
                }
            }
            
            // get result (even if it's an error)
            // remove requesting timer if needed
            if self.requestTimer {
                self.requestTimer!.invalidate()
                self.requestTimer = nil
            }
        })
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        println(error.localizedDescription)
    }
    
    @IBAction func locateMe(sender: AnyObject) {

        if !self.requesting {
            
            if !CLLocationManager.locationServicesEnabled() {
                println("Location Service is not enabled")
                return
            }
            
            self.locationManager.delegate = self
            if self.locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                self.locationManager.requestWhenInUseAuthorization()
            }
            self.locationManager.distanceFilter = kCLDistanceFilterNone
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
            self.requesting = true
            
            // start timer in case requesting time out
            if self.requestTimer {  // exist already
                self.requestTimer!.invalidate()
            }
            self.requestTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "onTimeout:", userInfo: nil, repeats: false)
            
            updateRightButton()
        }
    }
    
    func onTimeout(timer : NSTimer) {
        
        timer.invalidate()
        self.requestTimer = nil
        
        self.lblLocation.text = "Timeout. Current Location Not Detected!"
    }
    
    func updateRightButton() {
        
        if self.requesting {

            let activityView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 30, 30))
            activityView.color = self.view.tintColor    // In iOS v7.0, all subclasses of UIView derive their behavior for tintColor from the base class. See the discussion of tintColor at the UIView level for more information.
            activityView.startAnimating()
            let loadingView = UIBarButtonItem(customView: activityView)
            self.navigationItem.setRightBarButtonItem(loadingView, animated: true)
            
        }
        else {
            let normalButton = UIBarButtonItem(image: UIImage(named: "Compass"), style: UIBarButtonItemStyle.Bordered, target: self, action: "locateMe:")
            self.navigationItem.setRightBarButtonItem(normalButton, animated: true)
            
        }
    }

}

