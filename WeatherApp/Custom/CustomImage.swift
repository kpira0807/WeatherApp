import Foundation
import UIKit

class CustomImage: UIImageView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        createBorder()
    }
    
    func createBorder(){
    self.layer.borderWidth = 2
    self.layer.borderColor = UIColor.yellowColor.cgColor
    self.layer.cornerRadius = self.frame.size.width / 2
    self.backgroundColor = UIColor.white
    self.clipsToBounds = true
    }
}
