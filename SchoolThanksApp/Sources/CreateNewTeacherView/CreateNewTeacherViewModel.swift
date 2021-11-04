//
//  CreateNewTeacherViewModel.swift
//  SchoolThanksApp
//
//  Created by 前澤健一 on 2021/10/03.
//

import RxSwift
import RxCocoa
import Firebase
import UIKit

class CreateNewTeacherViewModel {
    
    // Input
    let nameText = PublishRelay<String?>()
    let emailText = PublishRelay<String?>()
    let passwordText = PublishRelay<String?>()
    let userImage = PublishRelay<UIImage?>()
    let clickedCreateButton = PublishRelay<Void>()
    
    // Output
    let isLoadingIndicator: Driver<Bool>
    let didFinishCreateAccount: Driver<Void>
    //let showErrorAlert: Driver<Void>
    
    init(model: CreateNewTeacherModel = CreateNewTeacherModel()) {
        let nameEmailPassImage = Observable
            .combineLatest(nameText.compactMap { $0 },
                           emailText.compactMap { $0 },
                           passwordText.compactMap { $0 },
                           userImage)
        
        let createUserResult = clickedCreateButton
            .withLatestFrom(nameEmailPassImage)
            .flatMap {
                return model.createUser(displayName: $0, email: $1, password: $2, image: $3)
            }
            .share(replay: 1)
        
        self.isLoadingIndicator = Observable
            .merge(clickedCreateButton.map { _ in true }, createUserResult.map { _ in false })
            .asDriver(onErrorDriveWith: .empty())
        
        self.didFinishCreateAccount = createUserResult.filter { result -> Bool in
            if case .success = result {
                return true
            } else {
                return false
            }
        }
        .map { _ in () }
        .asDriver(onErrorDriveWith: .empty())
    }
}

class CreateNewTeacherModel {
    private let storage = Storage.storage()
    
    func createUser(displayName: String, email: String, password: String, image: UIImage?) -> Observable<CreateNewUserResult> {
        return Observable.create { obserber in
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let authResult = authResult {
                    print("ユーザーを新規作成しました")
                    
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = displayName
                    changeRequest?.photoURL = URL(string: "\(displayName).jpg")
                    changeRequest?.commitChanges { error in
                        if let error = error {
                            print("ユーザー情報の登録に失敗しました")
                            print("error: ", error.localizedDescription)
                            obserber.onNext(.failure(message: error.localizedDescription))
                            obserber.onCompleted()
                        } else {
                            print("ユーザー情報の登録完了しました")
                            print("displayName: ", authResult.user.displayName)
                            if let image = image {
                                self.uploadPhoto(image, photoURL: URL(string: "\(displayName).jpg")!)
                            }
                            
                           
                            obserber.onNext(.success)
                            obserber.onCompleted()
                        }
                    }
                }
                if let error = error {
                    print("ユーザー新規作成に失敗しました")
                    print("error: ", error.localizedDescription)
                    obserber.onNext(.failure(message: error.localizedDescription))
                    obserber.onCompleted()
                }
            }
            
            return Disposables.create()
        }
        
    }
    
    private func setTeacher() {
        print("Teacher情報を登録します")
        let db = Firestore.firestore()
        guard let teacher = AccountService.currentTeacher else { return }
        var ref: DocumentReference? = nil
        ref = db.collection("teachers").addDocument(data: [
            "uid": teacher.uid,
            "name": teacher.name,
            "imageURL": teacher.imageURL
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
    }
    
    private func uploadPhoto(_ image: UIImage, photoURL: URL) {
        let photoRef = storage.reference().child(photoURL.absoluteString)
        _ = photoRef.putData(image.jpegData(compressionQuality: 1.0)!, metadata: nil) { metaData, error in
            if let error = error {
                print("画像のアップロードでエラーが起きました")
                print(error.localizedDescription)
            } else {
                print("画像をアップロードしました")
                print("metaData: ", metaData?.description)
                photoRef.downloadURL { (url, error) in
                    guard let downloadURL = url else { return }
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.photoURL = downloadURL
                    changeRequest?.commitChanges { error in
                        if let err = error {
                            print("photoURLの登録でエラーが置きました", err.localizedDescription)
                        } else {
                            print("photoURLを登録しました: ", downloadURL)
                            // Teacher情報登録
                            self.setTeacher()
                        }
                    }
                    
                }
            }
        }
    }
}

enum CreateNewUserResult {
    case success
    case failure(message: String)
}
