import UIKit

class SecondViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    var InfoList: NSDictionary!
    var monumentKeys: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Приветствие
        if let login = UserDefaults.standard.string(forKey: "login") {
            welcomeLabel.text = "Добро пожаловать, \(login)!"
        }
        
        // Загрузка данных из .plist
        let path = Bundle.main.path(forResource: "MonumentInfo", ofType: "plist")!
        InfoList = NSDictionary(contentsOfFile: path)!
        monumentKeys = InfoList.allKeys as? [String]
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monumentKeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonumentCell", for: indexPath) as! MonumentCell
        let key = monumentKeys[indexPath.row]
        let monument = InfoList[key] as! [String: String]
        
        cell.nameLabel.text = monument["Name"]
        cell.iconImageView.image = UIImage(named: monument["Icon"] ?? "")
        cell.layer.cornerRadius = 12
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let key = monumentKeys[indexPath.row]
        let monument = InfoList[key] as! [String: String]
        performSegue(withIdentifier: "toDetail", sender: monument)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? ThirdViewController {
            detailVC.selectedMonument = sender as? [String: String]
        }
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        UserDefaults.standard.removeObject(forKey: "login")
        UserDefaults.standard.removeObject(forKey: "password")
        dismiss(animated: true)
    }
}
