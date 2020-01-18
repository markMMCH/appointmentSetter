


import UIKit

class PushSegue: UIStoryboardSegue, HalfModal {

    var height: CGFloat?
    let duration: TimeInterval = 0.2

    override func perform() {
        guard let fromView = self.source.view,
              let toView = self.destination.view else { return }

        let size = UIScreen.main.bounds.size
        let height = self.height ?? size.height / 2
        toView.frame = CGRect(x: 0, y: size.height, width: size.width, height: height)

        //let window = UIApplication.shared.keyWindow
        //window?.insertSubview(toView, aboveSubview: fromView)

        UIView.animate(withDuration: duration) {

            toView.frame.origin.y -= toView.frame.height

        }
    }

}

