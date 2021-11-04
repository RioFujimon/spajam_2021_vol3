//
//  TeachersListTableViewCell.swift
//  SchoolThanksApp
//
//  Created by 藤門莉生 on 2021/10/02.
//

import UIKit

class TeachersListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = 24
            profileImageView.layer.borderWidth = 1
            profileImageView.layer.borderColor = UIColor.darkGray.cgColor
            profileImageView.layer.masksToBounds = true
        }
    }
    var uid: String = ""
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(teacher: Teacher) {
        self.uid = teacher.uid
        
        self.nameLabel.text = teacher.name
        
        let url = URL(string: teacher.imageURL)
        print("teacher.imageURL: ", teacher.imageURL)
        do {
            let data = try Data(contentsOf: url!)
            let image = UIImage(data: data)
            profileImageView.image = image
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
