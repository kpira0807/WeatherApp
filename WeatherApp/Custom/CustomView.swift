import Foundation
import UIKit

class CustomView: UIView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        createBorder()
    }
    
    func createBorder(){
        self.layer.borderWidth = 3
        self.layer.cornerRadius = 7
        self.clipsToBounds = true
    }
}
