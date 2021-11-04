//
//  MessagesSummaryTableViewCell.swift
//  SchoolThanksApp
//
//  Created by 前澤健一 on 2021/10/03.
//

import UIKit

class MessagesSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(count: Int) {
        self.countLabel.text = "\(count)"
    }
}
