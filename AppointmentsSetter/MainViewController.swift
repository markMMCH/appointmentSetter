
import UIKit


var aaa: Bool = false

class MainViewController: UICollectionViewController {

    enum InsertDirection {
        case initial, top, bottom
    }

    enum WeekdayType {
        case weekday, weekend
    }

    struct Constants {
        static let dayCellIdentifier = "DayCell"
        static let monthHeaderIdentifier = "MonthHeader"
        static let pushDetailsSegue = "PushDetails"
    }

    enum Day {
        case day(Date, Int, Int, Int, Bool)
        case empty
    }

    struct Month: CustomStringConvertible, CustomDebugStringConvertible {
        let days: [Day]
        let title: String?
        let isToday: Bool
        var description: String {
            return title ?? "Empty month description"
        }
        var debugDescription: String {
            return "\(title) [\(isToday)] days: \(days.count)"
        }
        var nonEmptyDays: [Day] {
            return days.filter {
                switch $0 {
                case .day:
                    return true
                case .empty:
                    return false
                }
            }
        }
    }

    var months = [Month]()
    var storage = Storage.shared
    var colors = [
        UIColor.fd_PixelatedGrass,
        UIColor.fd_RadianYellow,
        UIColor.fd_RedPigment,
        UIColor.fd_Hollyhock,
        UIColor.clear,
    ]

    @IBOutlet var headerView: UIView!
    @IBOutlet var weekdayLabels: [UILabel]!
    
    @IBOutlet weak var setButtom: UIButton!
    @IBOutlet var marksView: UIView! {
        didSet {
            marksView.backgroundColor = UIColor.darkText
        }
    }
    @IBOutlet var markButtons: [UIButton]!

    var latestDate: Date? {
        if let latest = months.last?.nonEmptyDays.last,
           case .day(let date, _, _, _, _) = latest {
            return date
        }
        return nil
    }

    var firstDate: Date? {
        if let first = months.first?.nonEmptyDays.first,
            case .day(let date, _, _, _, _) = first {
            return date
        }
        return nil
    }

    var todayIndexPath: IndexPath? {
        var section = 0
        for i in 0..<months.count {
            if months[i].isToday {
                section = i
                break
            }
        }
        let days = months[section].days
        guard let current = calendar.dateComponents([.day], from: Date()).day else {
            debugPrint("Not current day")
            return nil
        }
        for i in 0..<days.count {
            if case .day(_, let day, _, _, _) = days[i], day == current {
                return IndexPath(item: i, section: section)
            }
        }
        debugPrint("Not today's index path")
        return nil
    }

    var topCount = 0
    var bottomCount = 0

    func fetchMonths(insert direction: InsertDirection) {

        let beforeSize = collectionView!.collectionViewLayout.collectionViewContentSize

        prefetchMonths(insert: direction)
        collectionView?.reloadData()

        if direction == .top {
            let afterSize = collectionView!.collectionViewLayout.collectionViewContentSize
            let diff = afterSize.height - beforeSize.height
            collectionView?.contentOffset = CGPoint(
                x: collectionView!.contentOffset.x,
                y: collectionView!.contentOffset.y + diff
            )
        }
    }

    lazy var calendar: Calendar = {
        var calendar = Calendar.autoupdatingCurrent
        return calendar
    }()

    lazy var monthYearFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "LLLL YYYY"
        return formatter
    }()

    func monthDays(from date: Date) -> [Day] {
        let components = calendar.dateComponents([.month, .year, .day], from: date)
        return calendar.filledDays(for: date).compactMap {
            if $0 == 0 {
                return Day.empty
            } else {
                var copy = components
                copy.day = $0
                let thisDay = calendar.date(from: copy) ?? Date()
                return Day.day(date, $0, components.month!, components.year!, calendar.isDateInWeekend(thisDay))
            }
        }
    }

    func month(from date: Date) -> Month {
        let days = monthDays(from: date)
        let title = monthYearFormatter.string(from: date)
        let thisComps = calendar.dateComponents([.month, .year], from: date)
        let todayComps = calendar.dateComponents([.month, .year], from: calendar.startOfDay(for: Date()))
        let today = thisComps.month == todayComps.month && thisComps.year == todayComps.year
        let month = Month(days: days,
                          title: title,
                          isToday: today /*calendar.isDateInToday(date)*/)
        return month
    }

    func prefetchMonths(insert direction: InsertDirection = .initial) {
        switch direction {
        case .initial:
            let date = calendar.startOfDay(for: Date())
            guard let inpast = calendar.add(-6, component: .month, to: date) else {
                return
            }
            calendar.dateRange(from: inpast, component: .month, by: 1).prefix(12).forEach {
                months.append(month(from: $0))
            }
        case .top:
            guard let first = firstDate else {
                return
            }
            calendar.dateRange(from: first, component: .month, by: -1).prefix(12).forEach {
                months.insert(month(from: $0), at: 0)
            }
        case .bottom:
            guard let latest = latestDate else {
                return
            }
            calendar.dateRange(from: latest, component: .month, by: 1).prefix(12).forEach {
                months.append(month(from: $0))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appointmentDate = ""
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor),
            headerView.bottomAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 30)
        ])

        if #available(iOS 11, *) { }
        else {
            headerView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        }

        let weekdays = calendar.veryShortWeekdaySymbols
        let weekdayTypes: [WeekdayType] = [.weekend, .weekday, .weekday, .weekday, .weekday, .weekday, .weekend]

        var weekPairs = Array(zip(weekdays, weekdayTypes))
        if calendar.firstWeekday == 2 {
            weekPairs.append(weekPairs.removeFirst())
        }

        weekdayLabels.sorted(by: { $0.tag < $1.tag }).enumerated().forEach { (idx, label) in
            label.text = weekPairs[idx].0
            switch weekPairs[idx].1 {
            case .weekday:
                label.textColor = UIColor.black
            case .weekend:
                label.textColor = UIColor.gray
            }
        }

        markButtons.sorted(by: { $0.tag < $1.tag }).enumerated().forEach { (idx, view) in
            view.backgroundColor = colors[idx]
        }

//        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
//        gesture.cancelsTouchesInView = false
//        collectionView.addGestureRecognizer(gesture)

        prefetchMonths()
        collectionView?.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard months.count > 0 else {
            return
        }

        if let indexPath = todayIndexPath {
            collectionView?.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let topEdge: CGFloat = 0
        let bottomEdge = collectionView!.contentSize.height - collectionView!.bounds.height

        if collectionView!.contentOffset.y < topEdge {
            fetchMonths(insert: .top)
        } else if collectionView!.contentOffset.y > bottomEdge {
            fetchMonths(insert: .bottom)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTodayTapped(_ sender: Any) {
        scrollToToday()
    }
    
    @IBAction func onAppointmentsTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SavedTableViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    

    
    @IBAction func setButtonTapped(_ sender: UIButton) {
        
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AppointmentViewController")
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func onColorTapped(_ sender: UIButton) {
        
       
        
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }

        debugPrint("Set color to \(sender.tag)")
        markButtons.filter { $0 !== sender }.forEach {
            $0.isSelected = false
        }
        sender.isSelected = true

        let day = dayAt(indexPath)
        if case .day(_, let day, let month, let year, _) = day {
            if let item = DayItem.fetchDayItem(in: storage.context, day: day, month: month, year: year) {
                storage.context.performAndWait {
                    if sender.tag == colors.count {
                        storage.context.delete(item)
                    } else {
                        item.colorIndex = sender.tag - 1
                        
                    }
                }
            } else {
               
                DayItem.insertDayItem(in: storage.context, day: day, month: month, year: year, color: sender.tag - 1)
              
                
            }
            storage.save()
        }
        collectionView.reloadItems(at: [indexPath])
        marksView.removeFromSuperview()
    }

    @objc func onTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: collectionView)
        if collectionView.indexPathForItem(at: location) == nil,
            let indexPath = collectionView.indexPathsForSelectedItems?.first {
            collectionView.deselectItem(at: indexPath, animated: true)
            setViewHidden(true, view: marksView, at: IndexPath(item: 0, section: 0))
        }
    }

    func scrollToToday() {
        if let indexPath = todayIndexPath {
            collectionView?.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }

    override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        scrollToToday()
        return false
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indexPath = collectionView.indexPathsForSelectedItems?.first,
            !collectionView.indexPathsForVisibleItems.contains(indexPath) {
            collectionView.deselectItem(at: indexPath, animated: false)
            setViewHidden(true, view: marksView, at: indexPath)
        }
    }

    func setViewHidden(_ hidden: Bool, view: UIView, at indexPath: IndexPath) {
        let duration = CATransaction.animationDuration()
        if hidden {
            guard view.superview != nil else {
                return
            }
            UIView.animate(withDuration: duration, animations: {
                view.alpha = 0
            }) { _ in
                view.removeFromSuperview()
            }
        } else {
            let maxY = collectionView.layoutAttributesForItem(at: indexPath)?.frame.maxY ?? 0
            view.frame = CGRect(x: 0, y: maxY + 4, width: collectionView.bounds.width, height: 88)
            guard view.superview == nil else {
                return
            }
            view.layer.zPosition = 10
            collectionView.addSubview(view)
            UIView.animate(withDuration: duration, animations: {
                view.alpha = 1
            }) { _ in
                //
            }
        }
    }
}

extension UICollectionView {
    /// Scrolls to supplementray element at given index path
    ///
    /// - Parameters:
    ///   - kind: Element kind of section
    ///   - indexPath: Index path
    ///   - animated: Animated scroll or not
    func scrollToSupplementaryElement(ofKind kind: String, at indexPath: IndexPath, animated: Bool = false) {
        self.layoutIfNeeded()
        if let attributes = self.layoutAttributesForSupplementaryElement(ofKind: kind, at: indexPath) {
            let top = attributes.frame.minY - self.contentInset.top
            self.setContentOffset(CGPoint(x: 0, y: top), animated: false)
        }
    }
}

extension MainViewController {
    func dayAt(_ indexPath: IndexPath) -> Day {
        let month = months[indexPath.section]
        return month.days[indexPath.item]
    }
}

extension MainViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return months.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return months[section].days.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.dayCellIdentifier, for: indexPath) as! DayCellView
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if case .day(_, let day, let month, let year, let isWeekend) = dayAt(indexPath) {
            var color: UIColor?
            if let item = DayItem.fetchDayItem(in: storage.context, day: day, month: month, year: year) {
                color = colors[item.colorIndex % colors.count]
            }

            cell.state = .day(
                day,
                marked: color,
                today: indexPath == todayIndexPath,
                weekend: isWeekend,
                selected: collectionView.indexPathsForSelectedItems?.contains(indexPath) == true
            )
        } else {
            cell.state = .empty
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.monthHeaderIdentifier, for: indexPath) as? MonthHeaderView {
                let month = months[indexPath.section]
                header.title = month.description.localizedCapitalized
                return header
            }
        }
        return UICollectionReusableView()
    }

    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if case .day = dayAt(indexPath) {
            return true
        }
        setViewHidden(true, view: marksView, at: indexPath)
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if case .day = dayAt(indexPath) {
            if collectionView.indexPathsForSelectedItems?.contains(indexPath) == true {
                collectionView.deselectItem(at: indexPath, animated: true)
                // collectionView.collectionViewLayout.invalidateLayout()
                setViewHidden(true, view: marksView, at: indexPath)
                return false
            }
            return true
        }
        return false
    }
    
   

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if case .day(_, let day, let month, let year, _) = dayAt(indexPath) {
         
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy"
            let date = formatter.date(from: "\(DateFormatter().monthSymbols[month - 1]) \(day),  \(year)")!
            appointmentDate = formatter.string(from: date)
            var colorIndex = colors.count - 1
            if let item = DayItem.fetchDayItem(in: storage.context, day: day, month: month, year: year) {
                colorIndex = item.colorIndex % colors.count
            }
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            markButtons.forEach {
                $0.isSelected = $0.tag - 1 == colorIndex
            }
            setViewHidden(false, view: marksView, at: indexPath)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalWidth = collectionView.bounds.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        let cellWidth = (totalWidth - (6 * flowLayout.minimumInteritemSpacing)) / 7

        return CGSize(width: cellWidth, height: cellWidth)
    }
}

