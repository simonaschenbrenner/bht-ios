//
//  Location.swift
//  Aufgabe4Aschenbrenner
//
//  Created by Simon Núñez Aschenbrenner on 06.06.21.
//

import Foundation
import CoreLocation


class LocationEnvironment: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    var locationManager = CLLocationManager()
    
    @Published var stations = [
            Station(latitude: 52.504851, longitude: 13.337183, title: "Kiosk", description: "Zeitung kaufen"),
            Station(latitude: 52.506912, longitude: 13.351791, title: "Supermarkt", description: "Wocheneinkauf und ein Kasten Bier"),
            Station(latitude: 52.517696, longitude: 13.361825, title: "Drogerie", description: "Spül- und Waschmittel kaufen"),
            Station(latitude: 52.517907, longitude: 13.377825, title: "Blumenladen", description: "Pfingstrosen"),
            Station(latitude: 52.517334, longitude: 13.387574, title: "Arzt", description: "Rezept abholen"),
            Station(latitude: 52.522064, longitude: 13.408436, title: "Apotheke", description: "Medikamente abholen")
        ]
    
    func initPositionService() {
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        for station in stations {
            locationManager.startMonitoring(for: station.region)
        }
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        for i in 0..<stations.count {
            if (stations[i].id.uuidString == region.identifier) {
                stations[i].setStatus(.active)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        for i in 0..<stations.count {
            if (stations[i].id.uuidString == region.identifier) {
                stations[i].setStatus(.inactive)
            }
        }
    }
}

class Station: Identifiable, ObservableObject {
    
    let id = UUID()
    
    let latitude: Double
    let longitude: Double
    let title: String
    let description: String
    var status: Status = .inactive
    
    var delegates: [StationDelegate] = []
    
    init(latitude: Double, longitude: Double, title: String, description: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.description = description
    }
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    var region: CLCircularRegion {
        CLCircularRegion(center: self.location, radius: 1, identifier: id.uuidString)
    }
    
    func addDelegate(_ delegate: StationDelegate) {
        delegates.append(delegate)
    }
    func setStatus(_ status: Status) {
        self.status = (self.status != .done) ? status : .done
        for delegate in delegates {
            delegate.changeStatus(to: self.status)
        }
    }
    func resetStatus() {
        self.status = .inactive
        for delegate in delegates {
            delegate.changeStatus(to: self.status)
        }
    }
}

enum Status {
    case inactive, active, done
}

protocol StationDelegate {
    func changeStatus(to: Status)
}
