//
//  ContentView.swift
//  Aufgabe4Aschenbrenner
//
//  Created by Simon Núñez Aschenbrenner on 02.06.21.
//

import SwiftUI
import MapKit
import AVFoundation

struct ContentView: View {
    
    @StateObject var locationEnvironment = LocationEnvironment()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.543288, longitude: 13.350646), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        
    var body: some View {
        VStack {
            Text("Hallo Herr Kaiser, das sind Ihre To Dos")
            .font(.title3).bold()
            .padding(.vertical, 10)
            
            MapView(locationEnvironment: locationEnvironment)
            
            let numberOfStations = locationEnvironment.stations.count
            let columns = (numberOfStations < 3) ? numberOfStations : 3
            let rows = Int(ceil(Double(numberOfStations)/Double(columns)))
            ForEach((0..<rows), id: \.self) { r in
                HStack {
                    ForEach((0..<columns), id: \.self) { c in
                        if(columns * r + c < numberOfStations) {
                            StationView(station: locationEnvironment.stations[columns * r + c])
                                .padding(10)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
}

struct MapView: View {
    
    @StateObject var locationEnvironment: LocationEnvironment
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.543288, longitude: 13.350646), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        
    var body: some View {
        Map(coordinateRegion: $region,
            showsUserLocation: true,
            userTrackingMode: .constant(.follow),
            annotationItems: locationEnvironment.stations,
            annotationContent: { station in
                MapAnnotation(coordinate: station.location,
                    content: {
                        VStack {
                            Text(station.title)
                                .font(.headline)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .padding(6)
                                .background(RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.blue)
                                    .opacity(0.5)
                                )
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .foregroundColor(.blue)
                                .opacity(0.5)
                        }
                    }
                )
            }
        )
        .frame(height: 300)
        .padding(.vertical, 15)
        .onAppear() {
            locationEnvironment.initPositionService()
        }
    }
}

struct StationView: View, StationDelegate {
    
    @StateObject var station: Station
    @State var color: Color = .red
    @State var showAlert = false
    
    var body: some View {
        VStack {
            Text(station.title).font(.headline).lineLimit(1)
            Text(station.description).font(.subheadline).lineLimit(1)
            Button(action: {
                (station.status != .done) ? station.setStatus(.done) : station.resetStatus()
            }) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(color)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(station.title), message: Text(station.description),
                      primaryButton: .cancel(Text("Erledigen")) { station.setStatus(.done) },
                      secondaryButton: .default(Text("Später machen"))
                )
            }
        }
        .onAppear() {
            station.addDelegate(self)
            station.addDelegate(SoundNotification())
        }
    }
    
    func changeStatus(to status: Status) {
        
        switch(status) {
        case .inactive:
            color = .red
        case .active:
            color = .yellow
            showAlert = true
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                showAlert = false
            }
        case .done:
            color = .green
        }
    }
}

class SoundNotification: StationDelegate {
    
    let alert: SystemSoundID = 1005
    let chime: SystemSoundID = 1001
    
    func changeStatus(to status: Status) {
        
        switch(status) {
        case .active:
            AudioServicesPlaySystemSound(alert)
        case .done:
            AudioServicesPlaySystemSound(chime)
        default:
            return
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
