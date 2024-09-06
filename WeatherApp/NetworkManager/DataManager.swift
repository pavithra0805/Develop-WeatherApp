//
//  DataManagerClass.swift
//  WeatherApp
//
//  Created by Admin on 9/5/24.
//

import Foundation
import CoreLocation

class DataManager {
    
    private let apiKey = "0cfa3ffd18ff67f251db3d3b5ac5e77b"
    private let staticReverseGeoCodeURL = "https://api.openweathermap.org/geo/1.0/reverse?"
    private let staticWeatherURL = "https://api.openweathermap.org/data/2.5/weather?q="
    private let staticImageURL = "https://openweathermap.org/img/wn/"
    var imageURL: URL?
    
    func fetchCountryData(with latitude: Double, longitude: Double) async throws -> WeatherOverviewModel? {
        var urlString = staticReverseGeoCodeURL + "lat=\(latitude)&lon=\(longitude)&limit=1&appid=\(apiKey)"
        if urlString.components(separatedBy: " ").count > 0 {
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, response) = try await URLSession.shared.data(from:url)
            if let response = response as? HTTPURLResponse, response.statusCode == 200 || response.statusCode < 300 {
                let countryData = try JSONDecoder().decode([CityDataModel].self, from: data)
                guard countryData.count > 0 else { return nil }
                return try? await fetchWeatherData(city: countryData[0].name, state: countryData[0].state, country: countryData[0].country)
            }
        } catch let error {
            throw error
        }
        return nil
    }
    
    func fetchWeatherData(city: String, state: String, country: String) async throws -> WeatherOverviewModel? {
        var urlString = ""
        if city.components(separatedBy: " ").contains("County") {
           urlString = staticWeatherURL + "\(state),\(country)&appid=\(apiKey)"
        } else {
           urlString = staticWeatherURL + "\(city),\(state),\(country)&appid=\(apiKey)"
        }
        if urlString.components(separatedBy: " ").count > 0 {
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, response) = try await URLSession.shared.data(from:url)
            if let response = response as? HTTPURLResponse, response.statusCode == 200 || response.statusCode < 300 {
                let weatherData = try JSONDecoder().decode(WeatherOverviewModel.self, from: data)
                self.imageURL =
                URL(string: "\(staticImageURL)\(weatherData.weather[0].icon)@2x.png")
                return weatherData
            }
        } catch let error {
            throw error
        }
        return nil
    }
    
    func setTheStoredValue(with location: CLLocation) {
        UserDefaults.standard.setValue(location.coordinate.latitude, forKey: "userLocationLatitude")
        UserDefaults.standard.setValue(location.coordinate.longitude, forKey: "userLocationLongitude")
    }
    
    func getTheStoredLocation() -> CLLocation? {
        if let latitude = UserDefaults.standard.value(forKey: "userLocationLatitude") as? CLLocationDegrees, let longitude = UserDefaults.standard.value(forKey: "userLocationLongitude") as? CLLocationDegrees {
           return CLLocation(latitude: latitude, longitude: longitude)
        }
       return nil
    }
}
