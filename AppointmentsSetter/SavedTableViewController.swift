
import UIKit
import CoreData




class SavedTableViewController: UITableViewController {

    var storage = Storage.shared
    
    var appointments = [DayItem]()
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchItems()
       
    }
    
    
    func fetchItems() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DayItem")
        do {
            let result = try storage.context.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                appointments.append(data as! DayItem)
            }
        } catch {
            print("failed")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointments.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentCell", for: indexPath) as! AppointmentCell
        let rowItem = appointments[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        cell.infoTextView.text = rowItem.appointment
        cell.dateLabel.text = dateFormatter.string(from: rowItem.appointmentDate ?? Date()
        )
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
   
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "delete") { (action, indexPath) in
            
            self.storage.context.delete(self.appointments[indexPath.row])
            do {
                try self.storage.context.save()
               
            } catch {
                print("failed to save data: \(error.localizedDescription)")
            }
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DayItem")
            do {
                self.appointments = try self.storage.context.fetch(request) as! [DayItem]
            } catch {
                print("unable to fetch data \(error.localizedDescription)")
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    

}
