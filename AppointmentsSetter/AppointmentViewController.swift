

import UIKit
import CoreData

var appointmentDate: String = ""
let appDelegate = UIApplication.shared.delegate as? AppDelegate



class AppointmentViewController: UIViewController, UITextViewDelegate {
    
    var storage = Storage.shared
    
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        infoTextView.delegate = self
        infoTextView.text = "Appointment information"
        infoTextView.textColor = .white
        infoTextView.layer.borderWidth = 2
        infoTextView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        dateLabel.text = appointmentDate
        fetchItems()
        
    }
    

    
    
    func fetchItems() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        let date = dateFormatter.date(from: dateLabel.text!)
        
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date!)
        dateFormatter.dateFormat = "MM"
        let month = dateFormatter.string(from: date!)
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: date!)
        print(year, "\n", month, "\n", Int(day)!)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DayItem")
        fetchRequest.predicate = NSPredicate(format: "day = %@ AND month = %@ AND year = %@", argumentArray: [day, month, year])
        fetchRequest.fetchLimit = 1
        do {
            if try storage.context.fetch(fetchRequest).first != nil {
                let item = try storage.context.fetch(fetchRequest).first as! DayItem
                infoTextView.text = item.appointment
            } else {
                let alert = UIAlertController(title: "Alert", message: "Your appointment must have a valid text", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
            
         } catch {
             print("failed")
         }
     }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.white {
            textView.text = nil
            textView.textColor = .white
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Appointment information"
            textView.textColor = .white
        }
    }
    
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        let date = dateFormatter.date(from: dateLabel.text!)
        
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date!)
        dateFormatter.dateFormat = "MM"
        let month = dateFormatter.string(from: date!)
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: date!)
        
        
        
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "DayItem")
        fetchRequest.predicate = NSPredicate(format: "day = %@ AND month = %@ AND year = %@", argumentArray: [day, month, year])
        do {
            if try storage.context.fetch(fetchRequest).first != nil {
                let test = try storage.context.fetch(fetchRequest).first as! NSManagedObject
                test.setValue(infoTextView.text, forKey: "appointment")
                test.setValue(date, forKey: "appointmentDate")
                do {
                    try storage.context.save()
                } catch {
                    print(error)
                }
            } else {
                let alert = UIAlertController(title: "Alert", message: "Your appointment must have a color to be setted", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        } catch {
            
            print(error)
        }
        
        
        
    }
    
    

}

