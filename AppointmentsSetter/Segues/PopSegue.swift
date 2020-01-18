
import UIKit

class PopSegue: UIStoryboardSegue {

    let duration: TimeInterval = 0.2

    override func perform() {
        guard let fromView = self.source.view  else { return }

        UIView.animate(withDuration: duration, animations: {

            fromView.frame.origin.y += fromView.frame.height

        }) { finished in
            fromView.removeFromSuperview()
        }
    }
}
