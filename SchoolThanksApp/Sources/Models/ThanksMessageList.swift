//
//  ThanksMessageList.swift
//  SchoolThanksApp
//
//  Created by 藤門莉生 on 2021/10/02.
//

import Foundation

struct ThanksMessageList {
    let uid: String
    let thanksMessageList:[ThanksMessage]
    
    init(uid:String, thanksMessageList: [ThanksMessage]) {
        self.uid = uid
        self.thanksMessageList = thanksMessageList
    }
}
