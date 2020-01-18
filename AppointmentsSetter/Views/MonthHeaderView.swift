
import UIKit

class MonthHeaderView: UICollectionReusableView {

    @IBOutlet fileprivate weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = nil
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        title = nil
    }

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
}
