//
//  Teacher.swift
//  SchoolThanksApp
//
//  Created by 藤門莉生 on 2021/10/02.
//

import Foundation

struct Teacher {
    let  uid: String
    let  name: String
    let  imageURL: String
    
    init(uid: String, name: String, imageURL: String) {
        self.uid = uid
        self.name = name
        self.imageURL = imageURL
    }
}
