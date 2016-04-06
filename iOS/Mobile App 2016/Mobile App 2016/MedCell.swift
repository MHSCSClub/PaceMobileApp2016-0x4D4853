//
//  MedCell.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 4/5/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class MedCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!
    @IBOutlet var remaining: UILabel!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
