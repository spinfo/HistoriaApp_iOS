
import UIKit

class TourSelectionTableViewCell: UITableViewCell {

    var tour: Tour?

    @IBOutlet weak var tourShortInfoView: TourShortInfoView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    public func setTour(_ tour: Tour) {
        self.tour = tour
        self.tourShortInfoView.setTour(with: tour)
    }
    
}
