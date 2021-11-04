//
//  LoginTeacherViewModel.swift
//  SchoolThanksApp
//
//  Created by 前澤健一 on 2021/10/02.
//

import RxSwift
import RxCocoa
import Firebase

class LoginTeacherViewModel {
    
    // MARK: - Input
    let emailText = PublishRelay<String?>()
    let passwordText = PublishRelay<String?>()
    let clickedSignInButton = PublishRelay<Void>()
    
    // MARK: - Output
    let isEnableSignInButtun: Driver<Bool>
    let isLoadingIndicator: Driver<Bool>
    let didSignedIn: Driver<Void>
    let showErrorAlert: Driver<String>
    
    init(model: LoginTeacherModel = LoginTeacherModel()) {
        let emailAndPass = Observable
            .combineLatest(emailText.compactMap { $0 }, passwordText.compactMap { $0 })
        
        let signInResult = clickedSignInButton
            .withLatestFrom(emailAndPass)
            .flatMap {
                return model.signIn(withEmail: $0, password: $1)
            }
            .share(replay: 1)
        
        self.isLoadingIndicator = Observable
            .merge(clickedSignInButton.map { _ in true }, signInResult.map { _ in false })
            .asDriver(onErrorDriveWith: .empty())
        
        let isValidInput = emailAndPass
            .map { model.validate($0, $1) }
            .asDriver(onErrorDriveWith: .empty())
        
        self.isEnableSignInButtun = Driver
            .merge(isValidInput, isLoadingIndicator.map { !$0 })
            .startWith(false)
            .distinctUntilChanged()
        
        self.didSignedIn = signInResult.filter { result -> Bool in
            if case .success = result {
                return true
            } else {
                return false
            }
        }
        .map { _ in () }
        .asDriver(onErrorDriveWith: .empty())
        
        self.showErrorAlert = signInResult.map { result -> String in
            if case let .failure(msg) = result {
                return msg
            } else {
                return ""
            }
        }
        .filter { !$0.isEmpty }
        .asDriver(onErrorDriveWith: .empty())
    }
    
    
}

class LoginTeacherModel {
    func validate(_ email: String, _ password: String) -> Bool {
        guard !email.isEmpty && !password.isEmpty else { return false }
        guard password.count >= 6 else { return false }
        return true
    }
    
    func signIn(withEmail email: String, password: String) -> Observable<SignInResult> {
        return Observable.create {  obserber in
            print("サインイン開始")
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if let _ = authResult {
                    print("サインイン成功 ユーザー情報: ")
                    let user = Auth.auth().currentUser
                    print(user?.email, user?.displayName)
                    
                    obserber.onNext(SignInResult.success)
                    obserber.onCompleted()
                }
                if let err = error {
                    print("サインイン失敗")
                    obserber.onNext(SignInResult.failure(message: err.localizedDescription))
                    obserber.onCompleted()
                }
            }
            return Disposables.create()
            
        }
    }
}

enum SignInResult {
    case success
    case failure(message: String)
}
