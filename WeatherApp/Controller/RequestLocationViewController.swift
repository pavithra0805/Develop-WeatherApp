//
//  RequestLocationViewController.swift
//  WeatherApp
//
//  Created by Admin on 9/4/24.
//

import UIKit
import SwiftUI
import CoreLocation

class RequestLocationViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocation? { // updating the UI CTA and navigate to weather when user choose location
        willSet {
            customizeAccessCTA()
            navigateToWeatherView(location: newValue)
        }
    }
    
    @IBOutlet weak var allowLocationButton: UIButton!

    @IBOutlet weak var showWeatherButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customizeAccessCTA()
    }
    
    @IBAction func allowLocationTapped(_ sender: Any) {
        requestLocation()
    }
        
    @IBAction func noLocationAccessTapped(_ sender: Any) {
        navigateToWeatherView()
    }
    
    private func customizeAccessCTA(authStatus: CLAuthorizationStatus? = nil) {
        allowLocationButton.setTitle(CLLocationManager().authorizationStatus == .authorizedWhenInUse ? "Location enabled" : "ALLOW ACCESS", for: .normal)
        allowLocationButton.isUserInteractionEnabled = userLocation == nil
    }
    
    private func navigateToWeatherView(location: CLLocation? = nil) {
        let weatherView = WeatherInfoView(location: location)
        let hostingController = UIHostingController(rootView: weatherView)
        hostingController.modalPresentationStyle = .overFullScreen
        dismiss(animated: true) {
            self.present(hostingController, animated: true)
        }
    }
    
    // Requesting location if User want to look weather based on location
    private func requestLocation() {
        locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension RequestLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        let dataManager = DataManager()
        dataManager.setTheStoredValue(with: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get the location")
    }
}
