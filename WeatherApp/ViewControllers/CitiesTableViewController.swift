import UIKit

class CitiesTableViewController: UITableViewController {
    
    var cityModel = [CityModel]()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myLocationButton: UIButton!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCities{ city in
            self.cityModel = city
        }
        setupSearchBar()
    }
    
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    var filteredCities: [CityModel] = []
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    func loadCities(completion: @escaping ([CityModel]) -> Void) {
        
        cityModel.removeAll()
        filteredCities.removeAll()
        
        activityIndicator.startAnimating()
        DispatchQueue.global().async  {
            if let path = Bundle.main.path(forResource: "city.list", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonDecoder = JSONDecoder()
                    let cities = try jsonDecoder.decode([CityModel].self, from: data)
                    completion(cities)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }
                }
                catch let error {
                    print(error)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredCities.count
        }
        return cityModel.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CitiesTableViewCell", for: indexPath) as! CitiesTableViewCell
        
        var citiesModel: CityModel
        if isFiltering {
            citiesModel = filteredCities[indexPath.row]
        } else {
            citiesModel = cityModel[indexPath.row]
        }
        cell.setup(with: citiesModel)
        
        
        cityModel.sort {
            $0.name < $1.name
        }
        
        if indexPath.row % 2 == 0 {
            cell.imageCell.downloaded(from: imageURL.unpairedImage)
            cell.view.layer.borderColor = UIColor.greenColor.cgColor
        } else {
            cell.imageCell.downloaded(from: imageURL.pairedImage)
            cell.view.layer.borderColor = UIColor.purpurColor.cgColor
        }
        
        return cell
    }
    
    // go to detailed information about weather
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailedinformation" {
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else { return }
            let cityModels = cityModel[indexPath.row]
            if let weatherViewController: WeatherViewController = segue.destination as? WeatherViewController {
                
                let cityModels: CityModel
                if isFiltering {
                    cityModels = filteredCities[indexPath.row]
                    weatherViewController.cityModels = cityModels
                } else {
                    cityModels = cityModel[indexPath.row]
                    weatherViewController.cityModels = cityModels
                }
            }
        }
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        let city = cityModel
        filteredCities = city.filter({( city : CityModel) -> Bool in
            return city.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension CitiesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
