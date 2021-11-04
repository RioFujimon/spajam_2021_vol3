//
//  ViewController.swift
//  SchoolThanksApp
//
//  Created by 前澤健一 on 2021/10/02.
//

import UIKit
import RxSwift
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let db = Firestore.firestore()
        db.collection("cities").document("JP").setData([
            "name": "Los Angeles",
            "state": "CA",
            "country": "USA"
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}

