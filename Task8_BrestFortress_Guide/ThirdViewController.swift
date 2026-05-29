import UIKit

class ThirdViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var coordinatesLabel: UILabel!
    
    var selectedMonument: [String: String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let monument = selectedMonument else { return }
        
        nameLabel.text = monument["Name"]
        descriptionTextView.text = monument["Description"]
        coordinatesLabel.text = monument["Coordinates"]
        iconImageView.image = UIImage(named: monument["Icon"] ?? "")
        
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
    }
}
