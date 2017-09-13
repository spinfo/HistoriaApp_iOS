//
//  TourDownloadTableViewCell.swift
//  HistoriaApp
//
//  Created by David on 13.09.17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class TourDownloadTableViewCell: UITableViewCell {


    @IBOutlet weak var tourName: UILabel!

    @IBOutlet weak var areaName: UILabel!

    @IBOutlet weak var progress: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
