import UIKit

class CitiesTableViewCell: UITableViewCell {

    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var nameCity: UILabel!
    @IBOutlet weak var view: CustomView!
    
    func setup(with citiesModel: CityModel) {
        nameCity.text = citiesModel.name
    }
}
