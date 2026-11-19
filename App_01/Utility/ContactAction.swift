import UIKit

class ContactAction {
    
    static func call(phoneNumber: String) {
        let trimmed = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        if let url = URL(string: "tel://\(trimmed)") {
            print("calling \(trimmed)")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    static func message(phoneNumber: String) {
        let trimmed = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        if let url = URL(string: "sms:\(trimmed)") {
            print("messaging \(trimmed)")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    static func email(to emailAddress: String) {
        if let url = URL(string: "mailto:\(emailAddress)") {
            print("mailing to \(emailAddress)")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    static func videoCall(identifier: String) {
        if let url = URL(string: "facetime://\(identifier)") {
            print("video calling \(identifier)")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
