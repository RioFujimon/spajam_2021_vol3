//
//  ThanksMessage.swift
//  SchoolThanksApp
//
//  Created by 藤門莉生 on 2021/10/02.
//

import Foundation

struct ThanksMessage {
    let message: String?
    let sender: String?
    let date: Date
    
    init(message: String?, sender: String?, date: Date) {
        self.message = message
        self.sender = sender
        self.date = date
    }
}
