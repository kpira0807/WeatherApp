import UIKit
import MapKit
import Foundation
import CoreLocation

class LocationWeatherViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var temperLabel: UILabel!
    @IBOutlet weak var minmaxTemperlabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var speedWindLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var mapCity: MKMapView!
    @IBOutlet weak var viewBackground: CustomView!
    @IBOutlet weak var imageWeather: CustomImage!
    @IBOutlet weak var nameCity: UILabel!
    
    // for location
    let locationManager = CLLocationManager()
    var coordination: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapCity.delegate = self
        
        viewBackground.layer.borderColor = UIColor.orangeColor.cgColor
        viewBackground.backgroundColor = UIColor.lightOrangeColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setuplocation()
    }
    
    // Location
    func setuplocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, coordination == nil {
            coordination = locations.first
            locationManager.stopUpdatingLocation()
            requesrWeatherForLocation()
        }
    }
    
    func requesrWeatherForLocation() {
        
        guard let coorditation = coordination else {
            return
        }
        let longitude = coorditation.coordinate.longitude
        let latitude = coorditation.coordinate.latitude
        
        let apiKey = "88d63c9ac55ef68f2e5c53be9cac3726"
        
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, response, error in
            
            guard let data = data, error == nil else {
                print("Error 1: \(error)")
                return
            }
            
            var json: WeatherModel?
            do {
                json = try JSONDecoder().decode(WeatherModel.self, from: data)
            }
            catch {
                print("Error 2: \(error)")
            }
            
            guard let result = json else {
                return
            }
            
            DispatchQueue.main.async {
                
                self.nameCity.text = "\(result.name)"
                self.humidityLabel.text = "\(result.main.humidity ?? 0) %"
                self.pressureLabel.text = "\(result.main.pressure) mb"
                self.speedWindLabel.text = "\(result.wind.speed) m/s"
                self.temperLabel.text = "\(result.main.temp ?? 0) °C"
                self.minmaxTemperlabel.text = "\(result.main.temp_min) °C / \(result.main.temp_max) °C"
                
                let description = result.weather[0].description?.capitalized
                self.descriptionLabel.text = description
                
                let coordination = CLLocationCoordinate2D(latitude: result.coord.lat, longitude: result.coord.lon)
                let name = Annotation(coordinate: coordination, title: result.name)
                
                self.mapCity.addAnnotation(name)
                self.mapCity.setRegion(name.region, animated: true)
                
                if let urls = URL.init(string: "https://openweathermap.org/img/wn/\(result.weather[0].icon ?? "01d")@2x.png") {
                    DispatchQueue.global(qos: .userInteractive).async {
                        URLSession.shared.dataTask(with: urls) { data, response, error in
                            guard let data = data, error == nil else { return }
                            DispatchQueue.main.async() {
                                self.imageWeather.image = UIImage(data: data)
                            }
                        }.resume()
                    }
                }
            }
        }).resume()
        
        print("\(longitude) | \(latitude)")
    }
}
