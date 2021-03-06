//
//  ViewController.swift
//  Rainy Shine
//
//  Created by Ron Ramirez on 12/27/16.
//  Copyright © 2016 Mochi Apps. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class WeatherVC: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var currentWeatherIconImage: UIImageView!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    
    //Core Location
    var locationManager = CLLocationManager()
    var currentLocation : CLLocation!
    
    
    //Data Models
    var currentWeather : CurrentWeather!
    var forecast : Forecast!
    var forecasts = [Forecast]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Only uses when in use
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
 
        currentWeather = CurrentWeather()
        
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
    }
    
    //MARK: TableView Delegate Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentForecast = forecasts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as? WeatherCell {
            cell.configureCell(forecast: currentForecast)
            return cell
        }else {
            return UITableViewCell()
        }
    }
    
    //MARK: Helper Functions
    
    func updateMainUI() {
        dateLabel.text = currentWeather.date
        currentTempLabel.text = "\(currentWeather.currentTemp)"
        currentWeatherLabel.text = currentWeather.weatherType
        currentLocationLabel.text = currentWeather.cityName
        currentWeatherIconImage.image = UIImage(named: currentWeather.weatherType)
        
    }
    
    func downloadForecastData(complete : @escaping DownloadComplete) {
        //Download forecast weather data for TableView
        
        let forecastURL = URL(string : FORECAST_URL)!
        Alamofire.request(forecastURL).responseJSON { response in
            print(response)
            let result = response.result
            print(result)
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                if let list = dict["list"] as? [Dictionary<String, AnyObject>] {
                    
                    for obj in list {
                        let forecast = Forecast(weatherDict : obj)
                        self.forecasts.append(forecast)
                        print(obj)
                    }
                    self.forecasts.remove(at: 0)
              
                    self.tableView.reloadData()
                    
                }
            }
            complete()
        }
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location
            Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            Location.sharedInstance.longitude = currentLocation.coordinate.longitude
            print(currentLocation)
            print(currentLocation.coordinate.latitude)
            print(currentLocation.coordinate.longitude)
            currentWeather.downloadWeatherDetails {
                self.downloadForecastData {
                    //Setup UI to load downloaded data
                    self.updateMainUI()
                }
            }
            
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    }
    
}

