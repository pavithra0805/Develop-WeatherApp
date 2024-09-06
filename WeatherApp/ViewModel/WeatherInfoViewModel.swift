//
//  WeatherInfoViewModel.swift
//  WeatherApp
//
//  Created by Admin on 9/5/24.
//

import MapKit
import Foundation
import CoreLocation


class WeatherInfoViewModel: NSObject, ObservableObject {
    @Published var weatherInfoViewModel: WeatherOverviewModel? = nil
    @Published var imageURL: URL? = URL(string: "")
    @Published var location: CLLocation = CLLocation()
    private let completer = MKLocalSearchCompleter()
    @Published var searchResults: [MKLocalSearchCompletion] = []

    func getWeatherInfo(userLocation:CLLocation) async {
        let networkManager = DataManager()
        let weatherData = try? await networkManager.fetchCountryData(with: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        await MainActor.run {
            weatherInfoViewModel = weatherData
            imageURL = networkManager.imageURL
            location = userLocation
        }
    }
    
    func search(by query: String) {
        DispatchQueue.main.async {
            self.completer.delegate = self
            self.completer.resultTypes = .address
            self.completer.queryFragment = query
        }
    }
    
    func fetchCoordinatesFromCompletion(result: MKLocalSearchCompletion, completion: @escaping (CLLocation) -> ()) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = result.title
        MKLocalSearch(request: searchRequest).start { response, error in
            guard let response, let mapItem = response.mapItems.first else {
                return
            }
            let location = CLLocation(latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
            self.location = location
            let dataManager = DataManager()
            dataManager.setTheStoredValue(with: location)
            completion(location)
        }
    }
    
    func getWeatherDetails() -> WeatherInfo {
        let placeHolderString = "--"
        if let weatherInfoViewModel {
            let humidity = "\(weatherInfoViewModel.main.humidity) %"
            let pressure = "\(String(format: "%.0f", weatherInfoViewModel.main.feels_like-273.15)) Hpg"
            let actualTemp = "\(String(format: "%.0f", weatherInfoViewModel.main.temp-273.15))º Celsius"
            let tempFeelsLike = "\(String(format: "%.0f", weatherInfoViewModel.main.feels_like-273.15))º Celsius"
            return WeatherInfo(humidity: humidity, pressure: pressure, tempFeelsLike: tempFeelsLike, tempActual: actualTemp)
        } else {
            return WeatherInfo(humidity: placeHolderString, pressure: placeHolderString, tempFeelsLike: placeHolderString, tempActual: placeHolderString)
        }
    }
}

extension WeatherInfoViewModel: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search Failed With Error: \(error.localizedDescription)")
    }
}

struct WeatherInfo {
    let humidity: String
    let pressure: String
    let tempFeelsLike: String
    let tempActual: String
}
