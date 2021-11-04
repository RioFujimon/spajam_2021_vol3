//
//  File.swift
//  SchoolThanksApp
//
//  Created by 前澤健一 on 2021/10/02.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

class ThanksListViewModel {
    
    // MARK: - Input
    let viewDidLoad = PublishRelay<Void>()
    let beginRefreshing = PublishRelay<Void>()
    
    // MARK: - Output
    let tableItems: Driver<[ListItem]>
    let didEndRefrashing: Driver<Void>
    
    init(teacherID: String, model: ThanksListModel = ThanksListModel()) {
        print("teacherID", teacherID)
        let fetchMessagesTrigger = Observable.merge(viewDidLoad.asObservable(), beginRefreshing.asObservable())
        
        let messages = fetchMessagesTrigger
            .flatMap {
                return model.fetchMesssges(teacherID: teacherID)
            }
            .startWith([])
            .share(replay: 1)
        
        let thanksMessagesMock = (0...15).map { i -> ThanksMessage in
            if 5 < i && i < 10 {
                return ThanksMessage(message: nil, sender: "AAAA\(i)", date: Date())
            } else {
                return ThanksMessage(message: "ありがとうーーーー！！！", sender: "SenderName", date: Date())
            }
        }
        //self.tableItems = Driver.just([.summary(8888)]  + thanksMessagesMock.map { .thanksMessge($0) })
        self.tableItems = messages.map { [.summary($0.count)] + $0.map { ListItem.thanksMessge($0) } }.asDriver(onErrorDriveWith: .empty())
        
        self.didEndRefrashing = messages.map { _ in () }.asDriver(onErrorDriveWith: .empty())
    }
    
    enum ListItem {
        case summary(Int)
        case thanksMessge(ThanksMessage)
    }
}

class ThanksListModel {
    private let db = Firestore.firestore()
    func fetchMesssges(teacherID: String) -> Observable<[ThanksMessage]> {
        return Observable.create { [weak self] obserber in
            
            self?.db
                .collection("Thanks")
                .whereField("teacherID", isEqualTo: teacherID)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        guard let documents = querySnapshot?.documents else {
                            print("Error fetching document")
                            return
                        }
                        let fetchedMessage = documents.map {
                            ThanksMessage(message: $0["thanksMessage"] as! String,
                                          sender: $0["sender"] as! String,
                                          date: ($0["createdAt"] as! Timestamp).dateValue())
                        }
                        print("thanksデータを取得しました", fetchedMessage.count)
                        obserber.onNext(fetchedMessage)
                        obserber.onCompleted()
                    }
                    
                }
            
            return Disposables.create()
        }
    }
}
