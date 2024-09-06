//
//  WeatherDataModel.swift
//  WeatherApp
//
//  Created by Admin on 9/5/24.
//


struct CityDataModel: Codable {
    let name: String
    let country: String
    let state: String
}

struct WeatherDataModel: Codable {
    let id: Double
    let main: String
    let description: String
    let icon: String
}

struct MainDataModel: Codable {
    let temp: Double
    let feels_like: Double
    let pressure: Double
    let humidity: Double
}

struct WeatherOverviewModel: Codable {
    let weather: [WeatherDataModel]
    let main: MainDataModel
    let name: String
}
