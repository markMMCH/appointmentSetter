


import UIKit

class RoundButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()

        setImage(#imageLiteral(resourceName: "markIcon"), for: .selected)
        setImage(#imageLiteral(resourceName: "markIcon"), for: .highlighted)
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        layer.cornerRadius = self.bounds.midX
        layer.borderColor = UIColor.white.cgColor
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderWidth = 2
            } else {
                layer.borderWidth = 0
            }
        }
    }
}
