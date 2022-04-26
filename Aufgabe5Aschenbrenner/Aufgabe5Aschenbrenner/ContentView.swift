//
//  ContentView.swift
//  Aufgabe5Aschenbrenner
//
//  Created by Simon Núñez Aschenbrenner on 16.06.21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    // Persistence
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Mood.timestamp, ascending: true)],
        animation: .default)
    private var moods: FetchedResults<Mood>
    
    @StateObject var locationEnvironment = LocationEnvironment()

    // Title
    private var titleColor = Color(red: 0.61, green: 0.72, blue: 0.92)
    private var titleVerticalOffset = UIScreen.screenHeight - CGFloat(200)
    
    // Navigation
    private var buttonColor = Color(red: 0.94, green: 0.63, blue: 0.63)
    private var buttonWidth = CGFloat(40)
    private var buttonVerticalOffset = CGFloat(20)
    private var buttonHorizontalOffset = CGFloat(130)
    private var settingsView = SettingsView()
    private var logView = LogView()
    
    // Mood Selector
    private var moodSelectorDiameter = CGFloat(120)
    private var moodSelectorOffset = CGFloat(13)
    @State private var moodSelectorStartLocation = CGPoint(x: UIScreen.screenWidth/2, y: UIScreen.screenHeight/2 - 47) // moodSelectorDiameter/2-moodSelectorOffset
    @GestureState private var moodSelectorCurrentLocation: CGPoint? = nil
    @State private var happinessValue: Float = 0
    private var moodSelectorDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = moodSelectorCurrentLocation ?? moodSelectorStartLocation
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                // Prevent moodSelector going over the edge
                if (newLocation.y < moodSelectorOffset) {
                    newLocation.y = moodSelectorOffset
                } else if (newLocation.y > (UIScreen.screenHeight - moodSelectorDiameter + moodSelectorOffset)) {
                    newLocation.y = UIScreen.screenHeight - moodSelectorDiameter + moodSelectorOffset
                }
                if (newLocation.x < moodSelectorDiameter/2) {
                    newLocation.x = moodSelectorDiameter/2
                } else if (newLocation.x > (UIScreen.screenWidth - moodSelectorDiameter/2)) {
                    newLocation.x = UIScreen.screenWidth - moodSelectorDiameter/2
                }
                moodSelectorStartLocation = newLocation
            }
            .updating($moodSelectorCurrentLocation) { (value, moodSelectorCurrentLocation, transaction) in
                moodSelectorCurrentLocation = moodSelectorCurrentLocation ?? moodSelectorStartLocation
            }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: moodSelectorDiameter, height: moodSelectorDiameter)
                    .position(moodSelectorStartLocation)
                    .gesture(moodSelectorDragGesture)
                    .onDisappear() {
                        let valueOffset = (moodSelectorDiameter/2) / UIScreen.screenHeight
                        let rawValue = (moodSelectorStartLocation.y + moodSelectorDiameter/2 - moodSelectorOffset) / (UIScreen.screenHeight) - 0.5
                        if (rawValue < 0) {
                            happinessValue = -2*Float((rawValue - valueOffset))
                        } else if (rawValue > 0) {
                            happinessValue = -2*Float((rawValue + valueOffset))
                        } else {
                            happinessValue = 0
                        }
                        happinessValue = (happinessValue < -1) ? -1 : happinessValue
                        happinessValue = (happinessValue >  1) ?  1 : happinessValue
                        addItem()
                    }
                Text("Wie geht es dir?")
                    .font(.largeTitle)
                    .alignmentGuide(VerticalAlignment.bottom, computeValue: { d in d[VerticalAlignment.bottom] + titleVerticalOffset })
                    .foregroundColor(titleColor)
                NavigationLink(destination: logView) {
                    Image(systemName: "book.closed")
                        .resizable()
                        .frame(width: buttonWidth, height: buttonWidth)
                        .alignmentGuide(HorizontalAlignment.center, computeValue: { d in d[HorizontalAlignment.center] - buttonHorizontalOffset })
                        .alignmentGuide(VerticalAlignment.bottom, computeValue: { d in d[VerticalAlignment.bottom] + buttonVerticalOffset })
                        .foregroundColor(buttonColor)
                }
                NavigationLink(destination: settingsView) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: buttonWidth, height: buttonWidth)
                        .alignmentGuide(HorizontalAlignment.center, computeValue: { d in d[HorizontalAlignment.center] + buttonHorizontalOffset })
                        .alignmentGuide(VerticalAlignment.bottom, computeValue: { d in d[VerticalAlignment.bottom] + buttonVerticalOffset })
                        .foregroundColor(buttonColor)

                }
            }
            .navigationBarHidden(true)
            .background(
                LinearGradient(gradient: Gradient(colors: [.blue, .red]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            )
            .onAppear() {
                locationEnvironment.initPositionService()
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newMood = Mood(context: viewContext)
            let newLocation = Location(context: viewContext)
            let currentLocation = locationEnvironment.currentLocation
            if (currentLocation != nil) {
                newLocation.latitude = currentLocation!.coordinate.latitude
                newLocation.longitude = currentLocation!.coordinate.longitude
            }
            newMood.timestamp = Date()
            newMood.happiness = happinessValue
            newMood.location = newLocation
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

extension UIScreen{
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenWidth = UIScreen.main.bounds.size.width
}
