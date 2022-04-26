//
//  Location.swift
//  Aufgabe4Aschenbrenner
//
//  Created by Simon Núñez Aschenbrenner on 06.06.21.
//

import Foundation
import CoreLocation


class LocationEnvironment: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    private var locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    
    func initPositionService() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }
    
}
