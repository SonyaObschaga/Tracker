import UIKit

extension UIColor {
    func toString() -> String? {
        return UIColorMarshalling.hexString(from: self)
    }
    
    static func fromString(_ hexString: String) -> UIColor? {
        return UIColorMarshalling.color(from: hexString)
    }
}
