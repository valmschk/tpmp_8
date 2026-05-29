import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmView.isHidden = true
        setupUI()
        
        // Проверка сохраненной сессии
        if UserDefaults.standard.object(forKey: "login") != nil {
            performSegue(withIdentifier: "toMain", sender: self)
        }
    }
    
    func setupUI() {
        loginField.layer.cornerRadius = 8
        loginField.layer.borderWidth = 1
        loginField.layer.borderColor = UIColor.lightGray.cgColor
        loginField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        loginField.leftViewMode = .always
        
        passwordField.layer.cornerRadius = 8
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = UIColor.lightGray.cgColor
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        passwordField.leftViewMode = .always
        
        confirmPasswordField.layer.cornerRadius = 8
        confirmPasswordField.layer.borderWidth = 1
        confirmPasswordField.layer.borderColor = UIColor.lightGray.cgColor
        confirmPasswordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        confirmPasswordField.leftViewMode = .always
        
        actionButton.layer.cornerRadius = 8
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        confirmView.isHidden = sender.selectedSegmentIndex == 0
        if sender.selectedSegmentIndex == 0 {
            actionButton.setTitle("Войти", for: .normal)
        } else {
            actionButton.setTitle("Зарегистрироваться", for: .normal)
        }
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        if segmentControl.selectedSegmentIndex == 0 {
            // Login
            if let login = loginField.text, let password = passwordField.text,
               let savedLogin = UserDefaults.standard.string(forKey: "login"),
               let savedPassword = UserDefaults.standard.string(forKey: "password"),
               login == savedLogin, password == savedPassword {
                performSegue(withIdentifier: "toMain", sender: self)
            } else {
                showAlert(message: "Неверный логин или пароль")
            }
        } else {
            // Sign Up
            guard let login = loginField.text, !login.isEmpty,
                  let password = passwordField.text, !password.isEmpty,
                  let confirm = confirmPasswordField.text, password == confirm else {
                showAlert(message: "Проверьте правильность ввода данных")
                return
            }
            UserDefaults.standard.set(login, forKey: "login")
            UserDefaults.standard.set(password, forKey: "password")
            performSegue(withIdentifier: "toMain", sender: self)
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
