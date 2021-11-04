//
//  SendThanksViewController.swift
//  SchoolThanksApp
//
//  Created by 藤門莉生 on 2021/10/02.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class SendThanksViewController: UIViewController {
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var teacherNameLabel: UILabel!
    @IBOutlet weak var thanksMessageTextField: UITextField!
    @IBOutlet weak var senderNameTextField: UITextField!
    @IBOutlet weak var sendThanksButton: UIButton!
    var teacher: Teacher?
    var indexPathRow: Int?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        self.teacherNameLabel.text = self.teacher!.name
        let url = URL(string: teacher!.imageURL)
        do {
            let data = try Data(contentsOf: url!)
            let image = UIImage(data: data)
            self.userProfileImageView.image = image
            self.userProfileImageView.layer.masksToBounds = true
            self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.width / 2
            self.userProfileImageView.layer.borderWidth = 1.0
            self.userProfileImageView.layer.borderColor = UIColor.darkGray.cgColor
            print(self.userProfileImageView.frame.width/2)
        } catch let error {
            print("Error: \(error.localizedDescription)")
            
        }
    }
    
    @IBAction func sendThanks(_ sender: Any) {
        if senderNameTextField.text!.isEmpty && thanksMessageTextField.text!.isEmpty {
            return
        }
        print("send Thanks")
        sendThanksToFirestore(thanksMessage: thanksMessageTextField.text!, sender: senderNameTextField.text!)
        thanksMessageTextField.text = ""
        senderNameTextField.text = ""
    }
    
    func sendThanksToFirestore(thanksMessage: String, sender: String) {
        print("sendThanksToFirestore")
        db.collection("Thanks").document().setData(["teacherID": teacher!.uid, "thanksMessage": thanksMessage, "sender": sender, "createdAt": Timestamp(date: Date())], completion: { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        })
    }
}
