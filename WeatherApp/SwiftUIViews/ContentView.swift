//
//  ContentView.swift
//  WeatherApp
//
//  Created by Admin on 9/4/24.
//
import UIKit
import SwiftUI
import CoreLocation

// Intgrating UIKit View with SwiftUI View.

struct ContentView: View {
    
    var body: some View {
        VStack {
            UILocationViewRepresentable()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct UILocationViewRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) ->  RequestLocationViewController {
        let storyboard = UIStoryboard(name: "RequestLocation", bundle: Bundle.main)
        guard let locationController =  storyboard.instantiateViewController(withIdentifier: "RequestLocationViewController") as? RequestLocationViewController else { return RequestLocationViewController() }
        return locationController
    }
    
    func updateUIViewController(_ uiViewController: RequestLocationViewController, context: Context) {
    }
}
