

import UIKit

class AppointmentCell: UITableViewCell {

    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var infoTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoTextView.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
    }

}

