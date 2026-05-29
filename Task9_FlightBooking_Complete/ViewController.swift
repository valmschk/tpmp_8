import UIKit
import CoreData
import MapKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cityFromField: UITextField!
    @IBOutlet weak var cityToField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    var flights: [NSManagedObject] = []
    var isSelectingFrom = true
    let apiKey = "YOUR_API_KEY"  // Замените на ваш ключ OpenWeatherMap
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMapView()
        setupLocationManager()
        setupGestures()
        loadSampleData()
        updateLocalizedTexts()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - UI Setup
    func setupUI() {
        searchButton.layer.cornerRadius = 8
        activityIndicator.hidesWhenStopped = true
        
        cityFromField.layer.cornerRadius = 8
        cityFromField.layer.borderWidth = 1
        cityFromField.layer.borderColor = UIColor.lightGray.cgColor
        cityFromField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        cityFromField.leftViewMode = .always
        
        cityToField.layer.cornerRadius = 8
        cityToField.layer.borderWidth = 1
        cityToField.layer.borderColor = UIColor.lightGray.cgColor
        cityToField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        cityToField.leftViewMode = .always
    }
    
    // MARK: - MapKit Setup
    func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    // MARK: - CoreLocation Setup
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Gestures
    func setupGestures() {
        cityFromField.delegate = self
        cityToField.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        activityIndicator.startAnimating()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
            
            guard let city = placemarks?.first?.locality else {
                self?.showAlert(message: NSLocalizedString("city_not_found", comment: ""))
                return
            }
            
            DispatchQueue.main.async {
                if self?.isSelectingFrom == true {
                    self?.cityFromField.text = city
                } else {
                    self?.cityToField.text = city
                }
                self?.addAnnotation(at: coordinate, title: city)
            }
        }
    }
    
    func addAnnotation(at coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == cityFromField {
            isSelectingFrom = true
            showAlert(message: NSLocalizedString("tap_on_map", comment: ""))
        } else if textField == cityToField {
            isSelectingFrom = false
            showAlert(message: NSLocalizedString("tap_on_map", comment: ""))
        }
    }
    
    // MARK: - CoreData Operations
    func loadSampleData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Flight")
        
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 { return }
        } catch { }
        
        let sampleFlights: [([String: Any])] = [
            ["cityFrom": "Москва", "cityTo": "Доха", "company": "Qatar Airways", "duration": "5h 20m", "price": 450.0],
            ["cityFrom": "Москва", "cityTo": "Доха", "company": "Aeroflot", "duration": "5h 45m", "price": 380.0],
            ["cityFrom": "Минск", "cityTo": "Стамбул", "company": "Turkish Airlines", "duration": "3h 10m", "price": 220.0],
            ["cityFrom": "Минск", "cityTo": "Стамбул", "company": "Belavia", "duration": "3h 30m", "price": 195.0],
            ["cityFrom": "Киев", "cityTo": "Варшава", "company": "LOT Polish Airlines", "duration": "1h 50m", "price": 150.0],
            ["cityFrom": "Москва", "cityTo": "Париж", "company": "Air France", "duration": "4h 00m", "price": 320.0],
            ["cityFrom": "Минск", "cityTo": "Москва", "company": "Belavia", "duration": "1h 20m", "price": 120.0]
        ]
        
        for flightData in sampleFlights {
            let entity = NSEntityDescription.entity(forEntityName: "Flight", in: context)!
            let flight = NSManagedObject(entity: entity, insertInto: context)
            flight.setValue(flightData["cityFrom"], forKey: "cityFrom")
            flight.setValue(flightData["cityTo"], forKey: "cityTo")
            flight.setValue(flightData["company"], forKey: "company")
            flight.setValue(flightData["duration"], forKey: "duration")
            flight.setValue(flightData["price"], forKey: "price")
        }
        
        try? context.save()
    }
    
    func searchFlights() {
        guard let from = cityFromField.text, !from.isEmpty,
              let to = cityToField.text, !to.isEmpty else {
            showAlert(message: NSLocalizedString("fill_cities", comment: ""))
            return
        }
        
        activityIndicator.startAnimating()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Flight")
        
        fetchRequest.predicate = NSPredicate(format: "cityFrom == %@ AND cityTo == %@", from, to)
        
        do {
            flights = try context.fetch(fetchRequest)
            tableView.reloadData()
            activityIndicator.stopAnimating()
            
            if flights.isEmpty {
                showAlert(message: NSLocalizedString("no_flights", comment: ""))
            }
        } catch {
            activityIndicator.stopAnimating()
            showAlert(message: "Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flights.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlightCell", for: indexPath)
        let flight = flights[indexPath.row]
        
        let company = flight.value(forKey: "company") as? String ?? ""
        let duration = flight.value(forKey: "duration") as? String ?? ""
        let price = flight.value(forKey: "price") as? Double ?? 0
        
        cell.textLabel?.text = "\(company) - \(duration)"
        cell.detailTextLabel?.text = String(format: "$%.2f", price)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let flight = flights[indexPath.row]
        let company = flight.value(forKey: "company") as? String ?? ""
        let price = flight.value(forKey: "price") as? Double ?? 0
        showAlert(message: "\(company)\n\(String(format: "$%.2f", price))")
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        guard let title = annotation.title else { return }
        fetchWeather(for: title ?? "")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "AirportPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .systemRed
            (annotationView as? MKMarkerAnnotationView)?.glyphImage = UIImage(systemName: "airplane")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    // MARK: - Weather API
    func fetchWeather(for city: String) {
        activityIndicator.startAnimating()
        
        let lang = Locale.current.languageCode ?? "en"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric&lang=\(lang)"
        
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            activityIndicator.stopAnimating()
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.showAlert(message: NSLocalizedString("weather_error", comment: ""))
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let main = json?["main"] as? [String: Any]
                let temp = main?["temp"] as? Double
                let humidity = main?["humidity"] as? Int
                let weatherArray = json?["weather"] as? [[String: Any]]
                let description = weatherArray?.first?["description"] as? String
                
                DispatchQueue.main.async {
                    let message = String(format: NSLocalizedString("weather_format", comment: ""), temp ?? 0, humidity ?? 0, description ?? "")
                    self?.showAlert(message: message)
                }
            } catch {
                DispatchQueue.main.async {
                    self?.showAlert(message: NSLocalizedString("weather_error", comment: ""))
                }
            }
        }.resume()
    }
    
    // MARK: - IBActions
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        searchFlights()
    }
    
    // MARK: - Localization
    func updateLocalizedTexts() {
        cityFromField.placeholder = NSLocalizedString("from_city", comment: "")
        cityToField.placeholder = NSLocalizedString("to_city", comment: "")
        searchButton.setTitle(NSLocalizedString("search", comment: ""), for: .normal)
    }
    
    // MARK: - Helper Methods
    func showAlert(message: String) {
        let alert = UIAlertController(title: NSLocalizedString("info", comment: ""), 
                                      message: message, 
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
