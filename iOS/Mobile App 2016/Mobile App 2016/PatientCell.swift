//
//  PatientCell.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 4/6/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class PatientCell: UITableViewCell {
    @IBOutlet var medName: UILabel!
    @IBOutlet var amount: UILabel! //Dosage

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
