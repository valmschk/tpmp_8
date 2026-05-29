import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - IBOutlets
    @IBOutlet weak var studentNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - Properties
    var students: [Student] = []
    var managedContext: NSManagedObjectContext!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCoreData()
        loadStudents()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - UI Setup
    func setupUI() {
        addButton.layer.cornerRadius = 8
        
        studentNameTextField.layer.cornerRadius = 8
        studentNameTextField.layer.borderWidth = 1
        studentNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        studentNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        studentNameTextField.leftViewMode = .always
    }
    
    // MARK: - Core Data Setup
    func setupCoreData() {
        // 1. Получаем AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // 2. Получаем контекст (рабочую область в памяти)
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - CRUD Operations
    
    /// Загрузка студентов из Core Data
    func loadStudents() {
        // Создаем запрос
        let fetchRequest = NSFetchRequest<Student>(entityName: "Students")
        
        // Сортировка по имени
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            // Выполняем запрос
            students = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Ошибка загрузки студентов: \(error)")
            showAlert(message: "Не удалось загрузить список студентов")
        }
    }
    
    /// Добавление нового студента
    func addStudent(name: String) {
        // 1. Создаем новый объект в контексте
        let entity = NSEntityDescription.entity(forEntityName: "Students", in: managedContext)!
        let newStudent = Student(entity: entity, insertInto: managedContext)
        newStudent.name = name
        
        do {
            // 2. Сохраняем изменения на диск
            try managedContext.save()
            
            // 3. Обновляем массив и таблицу
            students.append(newStudent)
            
            // Сортируем после добавления
            students.sort { ($0.name ?? "") < ($1.name ?? "") }
            
            tableView.reloadData()
            studentNameTextField.text = ""
            
        } catch {
            print("Ошибка сохранения: \(error)")
            showAlert(message: "Не удалось сохранить студента")
        }
    }
    
    /// Удаление студента
    func deleteStudent(at indexPath: IndexPath) {
        let studentToDelete = students[indexPath.row]
        
        // 1. Удаляем из контекста
        managedContext.delete(studentToDelete)
        
        do {
            // 2. Сохраняем изменения на диск
            try managedContext.save()
            
            // 3. Удаляем из массива и таблицы
            students.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } catch {
            print("Ошибка удаления: \(error)")
            showAlert(message: "Не удалось удалить студента")
        }
    }
    
    // MARK: - IBActions
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let name = studentNameTextField.text, !name.isEmpty else {
            showAlert(message: "Введите имя студента")
            return
        }
        
        addStudent(name: name)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        let student = students[indexPath.row]
        
        cell.textLabel?.text = student.name
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let student = students[indexPath.row]
        showAlert(message: "Выбран студент: \(student.name ?? "")")
    }
    
    // Удаление свайпом
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteStudent(at: indexPath)
        }
    }
    
    // Кастомная кнопка удаления
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Удалить"
    }
    
    // MARK: - Helper Methods
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", 
                                      message: message, 
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
