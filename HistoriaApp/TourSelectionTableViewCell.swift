//
//  TourSelectionTableViewCell.swift
//  HistoriaApp
//
//  Created by David on 19.09.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class TourSelectionTableViewCell: UITableViewCell {

    var tour: Tour?

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var infos: UILabel!
    @IBOutlet weak var tags: UILabel!

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
        self.name.text = tour.name

        self.infos.text = String(format: "%@, %d min., %.2f km (%@)",
                                 tour.type.representation,
                                 tour.duration,
                                 (Float(tour.walkLength) / Float(1000)),
                                 tour.accessibility)

        self.tags.text = String(format: "%@ - %@ - %@",
                                tour.tagWhat,
                                tour.tagWhen,
                                tour.tagWhere)
    }
    
}
