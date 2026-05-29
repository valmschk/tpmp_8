import Foundation
import CoreData

extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Students")
    }

    @NSManaged public var name: String?

}

extension Student : Identifiable {

}
