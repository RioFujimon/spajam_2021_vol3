//
//  ThanksMessageTableViewCell.swift
//  SchoolThanksApp
//
//  Created by 前澤健一 on 2021/10/02.
//

import UIKit

class ThanksMessageTableViewCell: UITableViewCell {
    
    // MARK: - UIProperties
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 8
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.lightGray.cgColor
            containerView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var textMessageLabel: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with thanksMessage: ThanksMessage) {
        self.textMessageLabel.text = thanksMessage.message
        self.dateLabel.text = stringFromDate(date: thanksMessage.date, format: "MM-dd HH:mm")
        if let name = thanksMessage.sender {
            self.nameLabel.text = "\(name)より"
        } else {
            self.nameLabel.text = ""
        }
        
    }
    
    private func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

}


