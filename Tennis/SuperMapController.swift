//
//  SuperMapController.swift
//  Tennis
//
//  Created by Alvaro Ruiz on 06/12/18.
//  Copyright © 2018 Alvaro Ruiz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Darwin
class SuperMapController: UIViewController {
    
    
    @IBOutlet weak var lblLong: UILabel!
    @IBOutlet weak var lblLat: UILabel!
    @IBOutlet weak var lblCoordinates: UILabel!
    @IBOutlet weak var MyMap: MKMapView!
    let locationManager = CLLocationManager()
    var Latitude : Double = 0
    var Longitude : Double = 0
    let court8Lat = -23.603632649658284
    let court8Long = -46.7198458313942
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            //CheckLocationAuth()
            
        }
        
    }
    @IBAction func setLocation(_ sender: Any) {
        guard let  location = locationManager.location?.coordinate else {return}
        Latitude = location.latitude
        Longitude = location.longitude
    }
    func CheckLocationAuth(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            lblCoordinates.text = "InUse"
            MyMap.showsUserLocation = true
            if let location = locationManager.location?.coordinate{
                let region = MKCoordinateRegion.init(center: location, span: MKCoordinateSpan.init(latitudeDelta: 0.0001, longitudeDelta: 0.0001))
                Latitude = location.latitude
                Longitude = location.longitude
                MyMap.setRegion(region, animated: true)
                
                locationManager.startUpdatingLocation()
                
            }
            break;
        case .authorizedAlways:
            lblCoordinates.text = "Always"
            break;
        case .denied:
            lblCoordinates.text = "denied"
            break;
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            lblCoordinates.text = "notDetermined"
            break;
        case .restricted:
            lblCoordinates.text = "restricted"
            break;
            
        }
        
    }
    func getMeters(_ lat1 : Double, _ lon1 : Double, _ lat2 : Double, _ lon2 : Double) -> Double {
        
        let radius = 6378.137
        let dLat = lat2 * Double.pi / 180 - lat1 * Double.pi / 180
        let dLon = lon2 * Double.pi / 180 - lon1 * Double.pi / 180
        let a = sin(dLat/2) * sin(dLat/2) +
            cos(lat1 + Double.pi / 180) + cos(lat2 + Double.pi / 180) *
            sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let d = radius * c
        return d * 1000
        
    }
    
}
extension SuperMapController : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, span: MKCoordinateSpan.init(latitudeDelta: 0.0001, longitudeDelta: 0.0001))
        let origin = CLLocation(latitude: Latitude, longitude: Longitude)
        lblLat.text = String(location.coordinate.latitude)
        lblLong.text = String(location.coordinate.longitude)
        let current = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let meters = Int(origin.distance(from: current))
        MyMap.setRegion(region, animated: true)
        lblCoordinates.text = String(meters) + " distância"
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        CheckLocationAuth()
    }
    
}
