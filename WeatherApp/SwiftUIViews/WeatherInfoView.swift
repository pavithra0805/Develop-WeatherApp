//
//  SwiftUIView.swift
//  WeatherApp
//
//  Created by Admin on 9/5/24.
//

import SwiftUI
import CoreLocation
import MapKit

struct WeatherInfoView: View {
    
    // Property Wrappers
    @StateObject var viewModel = WeatherInfoViewModel()
    @State var location: CLLocation?
    @State private var query: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    //Weather Info View
    var body: some View {
        NavigationView {
            VStack {
                ZStack() {
                    LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .topLeading, endPoint: .bottomTrailing).edgesIgnoringSafeArea(.all)
                    ScrollView {
                        VStack {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Back to location access").foregroundColor(.white)
                                Image(systemName: "xmark.circle.fill").foregroundColor(.white).font(.largeTitle).frame(width: 10, height: 10).padding(8)
                            }
                            if UserDefaults.standard.value(forKey: "userLocationLatitude") != nil { //Condition checked to handle the case where user doesnt grant access to location and no previous location selection
                                Text(viewModel.weatherInfoViewModel?.name ?? "")
                                    .padding()
                                    .foregroundColor(.white)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                if let infoViewModel = viewModel.weatherInfoViewModel, infoViewModel.weather.count > 0 {
                                    Text(infoViewModel.weather[0].main)
                                        .padding()
                                        .foregroundColor(.white)
                                        .font(.largeTitle)
                                        .fontWeight(.regular)
                                        .fontDesign(.rounded)
                                    HStack {
                                        Text(infoViewModel.weather[0].description.capitalized)
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                            .fontWeight(.regular)
                                            .fontDesign(.rounded)
                                        // Loading the image based on url framed in ViewModel in Async
                                        AsyncImage(url: viewModel.imageURL) { phase in
                                            switch phase {
                                            case .empty: ProgressView()
                                            case .success(let image):
                                                image.resizable().scaledToFit().frame(width: 100, height: 100).cornerRadius(8.0)
                                            case .failure(_):
                                                Image(systemName: "questionmark.square.dashed")
                                            @unknown default:
                                                Image(systemName: "questionmark.square.dashed")
                                            }
                                        }
                                    }
                                }
                                let weatherInfo = viewModel.getWeatherDetails()
                                HStack{
                                    WeatherInfoSubView(title: "Humidity", value: weatherInfo.humidity, imageName: "humidity.fill")
                                    WeatherInfoSubView(title: "Pressure", value: weatherInfo.pressure, imageName: "arrow.down.to.line")
                                }
                                HStack{
                                    WeatherInfoSubView(title: "Actual Temp", value: weatherInfo.tempActual, imageName: "thermometer.medium")
                                    WeatherInfoSubView(title: "Feels like", value: weatherInfo.tempFeelsLike, imageName: "thermometer.medium")
                                }
                            }
                            TextField("Search the text, click enter to view results", text: $query) { inEdit in
                                if !inEdit { viewModel.search(by: query) }
                            }.textFieldStyle(.roundedBorder).padding(8.0)
                            List(viewModel.searchResults, id: \.description) { result in
                                VStack{
                                    Text(result.title)
                                        .background(.clear)
                                    Text(result.subtitle)
                                        .background(.clear)
                                }.onTapGesture {
                                    DispatchQueue.main.async {
                                        viewModel.fetchCoordinatesFromCompletion(result: result) { location in refreshScreen(from: location) }
                                    }
                                }
                            }.frame(width: UIScreen.main.bounds.width - 20, height: 300)
                                .padding()
                        }
                    }
                }}
            .onAppear {
                let dataManager = DataManager()
                if let location = dataManager.getTheStoredLocation() {
                    refreshScreen(from: location)
                }
            }
        }
    }
    
    private func refreshScreen(from location: CLLocation) {
        Task {
            await viewModel.getWeatherInfo(userLocation: location)
        }
    }
}

struct WeatherInfoSubView: View {
    let title: String
    let value: String
    let imageName: String
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 150, height: 150)
                .shadow(radius: 8.0)
                .cornerRadius(8.0)
            VStack {
                Image(systemName: imageName).frame(width: 50, height: 50).font(.largeTitle)
                Text(title)
                Text(value)
            }.foregroundColor(.white)
                .font(.body)
                .fontWeight(.bold)
                .fontDesign(.rounded)
        }
    }
}

