//
//  AccountService.swift
//  SchoolThanksApp
//
//  Created by 前澤健一 on 2021/10/03.
//

import Firebase
import Foundation

class AccountService {
    static var currentTeacher: Teacher? {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        guard let name = currentUser.displayName else { return nil }
        guard let photoURL = currentUser.photoURL else { return nil }
        return Teacher(uid: currentUser.uid, name: name, imageURL: photoURL.absoluteString)
    }
}

