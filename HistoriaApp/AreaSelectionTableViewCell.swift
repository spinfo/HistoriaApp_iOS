//
//  AreaSelectionTableViewCell.swift
//  HistoriaApp
//
//  Created by David on 28.09.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class AreaSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var tourAmountLabel: UILabel!
    @IBOutlet weak var areaNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
