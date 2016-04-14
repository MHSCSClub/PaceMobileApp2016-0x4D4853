//
//  PatientNameCell.swift
//  Med Together
//
//  Created by Jack Phillips on 4/13/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class PatientNameCell: UITableViewCell {
    
    @IBOutlet var name: UILabel!
    @IBOutlet var status: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
