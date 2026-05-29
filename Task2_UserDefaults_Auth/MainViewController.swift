import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayWelcomeMessage()
    }
    
    func setupUI() {
        logoutButton.layer.cornerRadius = 8
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = UIColor.systemRed.cgColor
    }
    
    func displayWelcomeMessage() {
        if let login = UserDefaults.standard.string(forKey: "userLogin") {
            welcomeLabel.text = "Добро пожаловать, \(login)!"
        } else {
            welcomeLabel.text = "Добро пожаловать!"
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        // Сбрасываем флаг авторизации
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        
        // Возвращаемся на экран авторизации
        dismiss(animated: true)
    }
}
