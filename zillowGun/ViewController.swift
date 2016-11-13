//
//  ViewController.swift
//  zillowGun
//
//  Created by Anne Maiale on 11/11/16.
//  Copyright © 2016 Anne Maiale. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, XMLParserDelegate {
    var currentElementName = ""
    var listing = ZillowListing()
    var passData:Bool=false
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
    }
    
    @IBAction func findMyLocation(sender: AnyObject) {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        print(locations)
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = (placemarks?[0])! as CLPlacemark
                let address = pm.thoroughfare
                print(address)
                print(pm.subThoroughfare)
                print(pm.postalCode)
                
                self.getZillowSearchResults(forPlacemark: pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func getZillowSearchResults(forPlacemark placemark: CLPlacemark) {
        locationManager.stopUpdatingLocation()
        
        print(placemark.isoCountryCode)
        
        if placemark.isoCountryCode != "US" {
            print("Error: Must be in the US")
            return
        }
        
        let clientID = valueForAPIKey(named:"zws-id")
        let addressString = "\(placemark.subThoroughfare!) \(placemark.thoroughfare!)"
        let citystatezip = "\(placemark.locality!) \(placemark.administrativeArea!) \(placemark.postalCode!)"
        
        let escapedAddressString = addressString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let escapedCityStateZip = citystatezip.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let searchEndpoint = "\(zillowBaseURL)GetSearchResults.htm?zws-id=\(clientID)&address=\(escapedAddressString!)&citystatezip=\(escapedCityStateZip!)"
        guard let url = URL(string: searchEndpoint) else {
            print("Error: cannot create URL")
            return
        }

        let parser = XMLParser(contentsOf: url)!
        parser.delegate = self
        
        let success:Bool = parser.parse()
        
        if success {
            print("parse success!")
            
        } else {
            print("parse failure!")
        }
    }

    func displayLocationInfo(placemark: CLPlacemark) {
        if placemark != nil {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            print(placemark.locality ?? "")
            print(placemark.postalCode ?? "")
            print(placemark.administrativeArea ?? "")
            print(placemark.country ?? "")
            let clientID = valueForAPIKey(named:"zws-id")
            print(clientID)

        }
    }
    
    func locationManager(_ manager: CLLocationManager!, didFailWithError error: NSError!) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            print("SOME OTHER STATUS")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Parser functions
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElementName = elementName;
        print(currentElementName)
        if (currentElementName == "zpid" || elementName=="zestimate") {
            passData = true;
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // passData=false;
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if (passData){
            if currentElementName == "zpid" {
                listing.zpid = string
            } else if currentElementName == "zestimate" {
                listing.zestimate = string
            }
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("failure error: ", parseError)
    }

}

