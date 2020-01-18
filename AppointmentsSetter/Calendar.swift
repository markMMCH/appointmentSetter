
import Foundation

struct DateRange: Sequence {

    typealias Iterator = AnyIterator<Date>

    var calendar: Calendar
    var startDate: Date
    var endDate: Date?
    var component: Calendar.Component
    var step: Int

    func makeIterator() -> Iterator {

        precondition(step != 0, "Step must be not 0!")

        var current = startDate
        
        return AnyIterator {
            guard let next = self.calendar.date(byAdding: self.component, value: self.step, to: current) else {
                return nil
            }
            let orderedType: ComparisonResult = self.step > 0 ? .orderedDescending : .orderedAscending
            if let last = self.endDate, next.compare(last) == orderedType {
                return nil
            }
            current = next
            return next
        }
    }
}

extension Calendar {
    func add(_ amount: Int, component: Calendar.Component, to date: Date) -> Date? {
        return self.date(byAdding: component, value: amount, to: date)
    }

    func next(_ component: Calendar.Component, for date: Date) -> Date? {
        return self.add(1, component: component, to: date)
    }

    func previous(_ component: Calendar.Component, for date: Date) -> Date? {
        return self.add(-1, component: component, to: date)
    }

    func dateRange(from: Date, to: Date? = nil, component: Calendar.Component, by step: Int) -> DateRange {
        return DateRange(calendar: self, startDate: from, endDate: to, component: component, step: step)
    }

    func daysCount(for date: Date) -> Int? {
        return self.range(of: .day, in: .month, for: date)?.count
    }

    func firstDayDate(for date: Date) -> Date? {
        let dc = dateComponents([.month, .year], from: self.startOfDay(for: date))
        return self.date(from: dc)
    }
    

    func firstWeekday(for date: Date) -> Int? {
        guard let date = firstDayDate(for: date) else {
            return nil
        }
        return self.dateComponents([.weekday], from: date).weekday
    }

    func filledDays(for date: Date, isFirstWeekdaySunday: Bool = false) -> [Int] {
        guard let first = self.firstWeekday(for: date),
              let count = daysCount(for: date) else {
            return []
        }
     
        var prefix = first - (self.firstWeekday - 1)
        if prefix == 0 { prefix = 7 }
        var days = [Int](repeating: 0, count: prefix - 1)
        days += (1...count)
        let postfix = 7 - days.count % 7
        days += [Int](repeating: 0, count: postfix)
        return days
    }
}
