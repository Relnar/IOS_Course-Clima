//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate
{
  //Constants
  private let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
  private let APP_ID = ""

  private let locationManager = CLLocationManager()

  private var weatherModel = WeatherDataModel()

  //Pre-linked IBOutlets
  @IBOutlet weak var weatherIcon: UIImageView!
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!


  override func viewDidLoad()
  {
    super.viewDidLoad()

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }

  //MARK: - Networking
  /***************************************************************/

  //Write the getWeatherData method here:
  private func getWeatherData(url: String, parameters: [String : String])
  {
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON
    { response in
      if response.result.isSuccess
      {
        let weatherJSON = JSON(response.result.value!)
        self.updateWeatherData(with: weatherJSON)
      }
      else
      {
        print("Error \(response.result.error!)")
        self.cityLabel.text = "Connection issue"
      }
    }
  }

  //MARK: - JSON Parsing
  /***************************************************************/


  //Write the updateWeatherData method here:
  private func updateWeatherData(with json : JSON)
  {
    if let temperature = json["main"]["temp"].double
    {
      weatherModel.temperature = Int(temperature - 273.15)
      weatherModel.city = json["name"].stringValue
      weatherModel.condition = json["weather"][0]["id"].intValue
      weatherModel.weatherIconName = weatherModel.updateWeatherIcon(condition: weatherModel.condition)

      updateUIWithWeatherData()
    }
    else
    {
      cityLabel.text = "Weather Unavailable"
    }
  }

  //MARK: - UI Updates
  /***************************************************************/


  //Write the updateUIWithWeatherData method here:
  private func updateUIWithWeatherData()
  {
    cityLabel.text = weatherModel.city
    temperatureLabel.text = String(weatherModel.temperature) // + "ºC"
    weatherIcon.image = UIImage(named: weatherModel.weatherIconName)
  }

  //MARK: - Location Manager Delegate Methods
  /***************************************************************/


  //Write the didUpdateLocations method here:
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
  {
    if let location = locations.last,
       location.horizontalAccuracy > 0
    {
      locationManager.stopUpdatingLocation()

      // TODO PLB: Remove delegate to stop updating (maybe remove the line)
      locationManager.delegate = nil

      print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
      let latitude = location.coordinate.latitude
      let longitude = location.coordinate.longitude
      let params = ["lat" : String(latitude), "lon" : String(longitude), "appid" : APP_ID]

      getWeatherData(url: WEATHER_URL, parameters: params)
    }
  }

  //Write the didFailWithError method here:
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
  {
    print(error)
    cityLabel.text = "Location Unavailable"
  }

  //MARK: - Change City Delegate methods
  /***************************************************************/


  //Write the userEnteredANewCityName Delegate method here:
  func userEnteredANewCityName(city: String)
  {
    cityLabel.text = city
    let params = ["q" : city, "appid" : APP_ID]
    getWeatherData(url: WEATHER_URL, parameters: params)
  }

  //Write the PrepareForSegue Method here
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    super.prepare(for: segue, sender: sender)
    if segue.identifier == "changeCityName"
    {
      let destinationVC = segue.destination as! ChangeCityViewController
      destinationVC.delegate = self
    }
  }
}


