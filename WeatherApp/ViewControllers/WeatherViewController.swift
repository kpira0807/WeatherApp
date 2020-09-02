import UIKit
import MapKit
import Foundation

final class Annotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?) {
        self.coordinate = coordinate
        self.title = title
        super.init()
    }
    
    var region: MKCoordinateRegion {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        return MKCoordinateRegion(center: coordinate, span: span)
    }
}

class WeatherViewController: UIViewController, MKMapViewDelegate {
    
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
    
    var cityModels: CityModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapCity.delegate = self
        
        let coordination = CLLocationCoordinate2D(latitude: cityModels?.coord.lat ?? 50.45029044, longitude: cityModels?.coord.lon ?? 30.52448273)
        let name = Annotation(coordinate: coordination, title: cityModels?.name)
        
        mapCity.addAnnotation(name)
        mapCity.setRegion(name.region, animated: true)
        
        let currentLocale : NSLocale = NSLocale.init(localeIdentifier :  NSLocale.current.identifier)
        let countryName : String? = currentLocale.displayName(forKey: NSLocale.Key.countryCode, value: cityModels?.country ?? "No information")
        
        nameCity.text = """
        \(cityModels?.name ?? "No information")
        (\(countryName ?? "Invalid country code"))
        """
        
        title = cityModels?.name
        
        requesrWeatherForLocation()
        
        viewBackground.layer.borderColor = UIColor.orangeColor.cgColor
        viewBackground.backgroundColor = UIColor.lightOrangeColor
    }
    
    var weather = [WeatherModel]()
    func requesrWeatherForLocation() {
        
        guard let coorditation = cityModels?.coord else {
            return
        }
        let longitude = coorditation.lon
        let latitude = coorditation.lat
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
                
                self.humidityLabel.text = "\(result.main.humidity ?? 0) %"
                self.pressureLabel.text = "\(result.main.pressure) mb"
                self.speedWindLabel.text = "\(result.wind.speed) m/s"
                self.temperLabel.text = "\(result.main.temp ?? 0) °C"
                self.minmaxTemperlabel.text = "\(result.main.temp_min) °C / \(result.main.temp_max) °C"
                
                let description = result.weather[0].description?.capitalized
                self.descriptionLabel.text = description
                
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
