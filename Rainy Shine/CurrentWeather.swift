//
//  CurrentWeather.swift
//  Rainy Shine
//
//  Created by Ron Ramirez on 1/2/17.
//  Copyright © 2017 Mochi Apps. All rights reserved.
//

import UIKit
import Alamofire

class CurrentWeather {
    var _cityName : String!
    var _date : String!
    var _weatherType : String!
    var _currentTemp : Double!
    
    var cityName : String {
        if _cityName == nil {
            _cityName = ""
        }
        return _cityName
    }
    
    var date : String {
        if _date == nil {
            _date = ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let currentDate = dateFormatter.string(from: Date())
        self._date = "Today, \(currentDate)"
        return _date
    }
    
    var weatherType : String {
        if _weatherType == nil {
            _weatherType = ""
        }
        return _weatherType
    }
    
    var currentTemp : Double {
        if _currentTemp == nil {
            _currentTemp = 0.0
        }
        return _currentTemp
    }
    
    func downloadWeatherDetails(completed : @escaping DownloadComplete) {
        //Alamofire download
        let currentWeatherURL = URL(string : CURRENT_WEATHER_URL)!
        Alamofire.request(currentWeatherURL).responseJSON { response in
            let result = response.result
            print(result)
            print(response)
            
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                
                //City Name
                if let name = dict["name"] as? String {
                    self._cityName = name.capitalized
                    print(name)
                }
                
                //Weather Type
                if let weatherDictArray = dict["weather"] as? [Dictionary<String, AnyObject>] {
                    if let weatherType = weatherDictArray[0]["main"] as? String {
                        self._weatherType = weatherType
                        print(weatherType)
                        
                    }
                }
                
                //Current Temp
                if let tempDictArray = dict["main"] as? Dictionary<String, AnyObject> {
                    if let currentTemp = tempDictArray["temp"] as? Double {
                        self._currentTemp = kelvinToFahrenheit(kelvin : currentTemp)
                        print(self._currentTemp)
                    }
                }
            }
            completed()
        }
    }
}
