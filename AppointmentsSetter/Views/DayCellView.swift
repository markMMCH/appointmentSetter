

import UIKit

class DayCellView: UICollectionViewCell {

    enum State {
        case empty
        case day(Int, marked: UIColor?, today: Bool, weekend: Bool, selected: Bool)
    }

    var state = State.empty {
        didSet {
            reloadData()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dotView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: window)
        dotView.layer.cornerRadius = dotView.bounds.midX
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        state = .empty
        reloadData()
    }

    override var isSelected: Bool {
        didSet {
            reloadData(isSelected: isSelected)
        }
    }

    func reloadData(isSelected: Bool = false) {
        switch state {
        case .empty:
            titleLabel.text = nil
            titleLabel.textColor = .black
            dotView.backgroundColor = .clear
            backgroundColor = .white
        case .day(let day, let marked, let today, let weekend, let selected):
            if today {
                if isSelected || selected {
                    backgroundColor = UIColor.fd_RedPigment
                    titleLabel.textColor = UIColor.white
                } else {
                    backgroundColor = UIColor.white
                    titleLabel.textColor = UIColor.fd_RedPigment
                }
                titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            } else {
                if isSelected || selected {
                    backgroundColor = UIColor.darkText
                    titleLabel.textColor = .white
                } else {
                    backgroundColor = UIColor.white
                    titleLabel.textColor = weekend ? UIColor.gray : UIColor.black
                }
                titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
            }

            dotView.backgroundColor = marked ?? .clear
            titleLabel.text = "\(day)"
        }
    }
}
