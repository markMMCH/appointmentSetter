
import UIKit
import CoreData

extension DayItem {

    var colorIndex: Int {
        set {
            self.color = Int32(newValue)
        }
        get {
            return Int(self.color)
        }
    }

    var date: Date? {
        let dc = DateComponents(year: Int(year), month: Int(month), day: Int(day))
        return Calendar.autoupdatingCurrent.date(from: dc)
    }

    var localizedWeekday: String? {
        guard let date = date else {
            return nil
        }
        let df = DateFormatter()
        df.dateFormat = "EEEE"
        return df.string(from: date)
    }

    static func fetchDayItem(in context: NSManagedObjectContext, day: Int, month: Int, year: Int) -> DayItem? {
        let fetchRequest: NSFetchRequest<DayItem> = DayItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "day == %d AND month == %d AND year == %d", day, month, year)
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            return nil
        }
    }
    
   
    

    static func allDayItems(in context: NSManagedObjectContext, day: Int, month: Int, year: Int) -> [DayItem] {
        let fetchRequest: NSFetchRequest<DayItem> = DayItem.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }

    @discardableResult static func insertDayItem(in context: NSManagedObjectContext, day: Int, month: Int, year: Int, color: Int) -> DayItem {
        var result: DayItem!
        context.performAndWait {
            let item = DayItem(context: context)
            item.day = Int16(day)
            item.month = Int16(month)
            item.year = Int16(year)
            item.color = Int32(color)
            
            result = item
            context.insert(item)
        }
        return result
    }

}
