
import UIKit

class TourShortInfoView: UIView {

    let nibName = "TourShortInfoView"
    var view: UIView!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var tagsLabel: UILabel!

    @IBOutlet weak var infosLabel: UILabel!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupWithNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupWithNib()
    }

    func setupWithNib() {
        let nib = UINib(nibName: self.nibName, bundle: Bundle(for: type(of: self)))
        self.view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        self.addSubview(view)
    }

    func updateContent(using tour: Tour) {
        self.nameLabel.text = tour.name

        self.infosLabel.text = String(format: "%@, %d min., %.2f km (%@)",
                                 tour.type.representation,
                                 tour.duration,
                                 (Float(tour.walkLength) / Float(1000)),
                                 tour.accessibility)

        self.tagsLabel.text = String(format: "%@ - %@ - %@",
                                tour.tagWhat,
                                tour.tagWhen,
                                tour.tagWhere)
    }

}
