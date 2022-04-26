//
//  LogView.swift
//  Aufgabe5Aschenbrenner
//
//  Created by Simon Núñez Aschenbrenner on 23.06.21.
//  Using SwiftUICharts: https://github.com/peterent/SwiftUICharts
//

import Foundation
import SwiftUI
import CoreData
import MapKit

struct LogView: View, LogViewDelegate {
    
    // Model
    @Environment(\.managedObjectContext) private var viewContext
    @State private var happinessValues: [Double] = []
    @State private var model = ChartModel(dataRange: -1.0...1.0)
    @State var spots: [Spot] = []
    @State var filter = Filter.day
    
    func changeFilter(to: Filter) {
        filter = to
        fetchMoods()
    }
    
    private func fetchMoods() {
        let request: NSFetchRequest<Mood> = Mood.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Mood.timestamp, ascending: true)]
        if (filter == .all) {
            request.predicate = nil
        } else {
            var interval: TimeInterval = 0
            switch filter {
            case .day:
                interval = 86_400
            case .week:
                interval = 604_800
            case .month:
                interval = 2_592_000
            case .quarter:
                interval = 7_884_000
            case .year:
                interval = 31_536_000
            default:
                interval = 0
            }
            let lastDay = Date().addingTimeInterval(-interval)
            request.predicate = NSPredicate(format: "timestamp > %@", lastDay as NSDate)
        }
        var fetchedMoods: [NSManagedObject]?
        do {
            fetchedMoods = try viewContext.fetch(request)
        } catch {
            fatalError("Failed to fetch moods: \(error)")
        }
        if (fetchedMoods != nil) {
            self.happinessValues = []
            self.spots = []
            for managedObject in fetchedMoods! {
                let mood = managedObject as! Mood
                let spot = Spot(for: mood)
                happinessValues.append(Double(mood.happiness))
                spots.append(spot)
            }
            self.model.data = happinessValues
        }
    }

    var body: some View {
        VStack {
            HStack {
                FilterButtonView(filter: .day, delegate: self)
                FilterButtonView(filter: .week, delegate: self)
                FilterButtonView(filter: .month, delegate: self)
            }
            .padding(.top, 15)
            HStack {
                FilterButtonView(filter: .quarter, delegate: self)
                FilterButtonView(filter: .year, delegate: self)
                FilterButtonView(filter: .all, delegate: self)
            }
            .padding(.bottom, 15)
            LineChartView(
                model: self.model,
                showsAxis: false,
                showGrid: true,
                lineColor: Color.blue) { (_, index) in
                String(format: "", self.model.data[index])
            }
            .onAppear() {
                fetchMoods()
            }
            MapView(spots: spots)
            .padding(.vertical, 15)
        }
        .navigationTitle(Text("Tagebucheinträge"))
    }

}

struct MapView: View {
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.543288, longitude: 13.350646), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    var spots: [Spot]
        
    var body: some View {
        Map(coordinateRegion: $region,
            annotationItems: spots,
            annotationContent: { spot in
                MapAnnotation(coordinate: spot.location.coordinate,
                    content: {
                        Circle()
                            .frame(width: 60, height: 60)
                            .foregroundColor(
                                (spot.happiness < 0)
                                    ? Color(red: Double(abs(spot.happiness)), green: 0.3, blue: Double((1.0-abs(spot.happiness))))
                                    : Color(red: Double((1.0-abs(spot.happiness))), green: 0.3, blue: Double(abs(spot.happiness)))
                            )
                            .opacity(0.25)
                    }
                )
            }
        )
    }
}

struct Spot: Identifiable {
    let id = UUID()
    let location: CLLocation
    let happiness: Float
    init(for mood: Mood) {
        if (mood.location != nil) {
            location = CLLocation(latitude: mood.location!.latitude, longitude: mood.location!.longitude)
        } else {
            location = CLLocation()
        }
        happiness = mood.happiness
    }
}

struct FilterButtonView: View {
    let filter: Filter
    var delegate: LogViewDelegate
    var body: some View {
        Button(action: {
            delegate.changeFilter(to: filter)
        }, label: {
            Text(filter.rawValue)
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .foregroundColor((filter == delegate.filter) ? Color.white : Color.blue)
                .background(
                    (filter == delegate.filter)
                        ? RoundedRectangle(cornerRadius: 7).stroke(Color.blue, lineWidth: 1).background(Color.blue)
                        : RoundedRectangle(cornerRadius: 7).stroke(Color.blue, lineWidth: 1).background(Color.white)
                )
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        )
    }
}

enum Filter: String {
    case day = "Heute"
    case week = "Letzte Woche"
    case month = "Letzter Monat"
    case quarter = "Letzte 3 Monate"
    case year = "Letztes Jahr"
    case all = "Alles"
}

protocol LogViewDelegate {
    var filter: Filter { get }
    func changeFilter(to: Filter)
}
