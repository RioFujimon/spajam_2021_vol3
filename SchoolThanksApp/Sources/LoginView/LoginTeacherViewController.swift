//
//  LoginViewController.swift
//  SchoolThanksApp
//
//  Created by 前澤健一 on 2021/10/02.
//

import UIKit
import RxSwift
import RxCocoa

class LoginTeacherViewController: UIViewController {
    
    typealias Dependency = LoginTeacherViewModel
    
    // MARK: - UIProperties
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 8
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.lightGray.cgColor
            containerView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.layer.cornerRadius = 50
            userImageView.layer.borderWidth = 1
            userImageView.layer.borderColor = UIColor.darkGray.cgColor
            userImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            signInButton.layer.cornerRadius = 5
            signInButton.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toCreateViewButton: UIButton!
    @IBOutlet weak var backToTeachersButton: UIButton! {
        didSet {
            backToTeachersButton.layer.cornerRadius = 15
            backToTeachersButton.layer.masksToBounds = true
        }
    }
    
    private let viewModel: Dependency
    private let disposeBag = DisposeBag()
    
    init?(coder: NSCoder, dependency: Dependency) {
        self.viewModel = dependency
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been impslemented")
    }
    
    static func configure(with dependency: Dependency) -> Self {
        let vc = UIStoryboard(name: "LoginTeacherViewController", bundle: nil)
            .instantiateInitialViewController { coder in
                LoginTeacherViewController(coder: coder, dependency: dependency)
            }! as! Self
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bind()
    }

    private func setupView() {
        
    }
    
    private func bind() {
        emailTextField.rx.text.asObservable()
            .bind(to: viewModel.emailText)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.asObservable()
            .bind(to: viewModel.passwordText)
            .disposed(by: disposeBag)
        
        signInButton.rx.tap.asSignal()
            .emit(to: viewModel.clickedSignInButton)
            .disposed(by: disposeBag)
        
        viewModel.isLoadingIndicator
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.isEnableSignInButtun
            .drive(onNext: { [weak self] isEnable in
                self?.signInButton.isEnabled = isEnable
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?.signInButton.alpha = isEnable ? 1 : 0.5
                })
            })
            .disposed(by: disposeBag)
        
        viewModel.didSignedIn
            .drive(onNext: { [weak self] in
                let alertController = UIAlertController(title: nil, message: "サインインしました.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self?.transitionToMessageListView()
                }))
                self?.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.showErrorAlert
            .drive(onNext: { [weak self] messge in
                let alertController = UIAlertController(title: nil, message: messge, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
        
        toCreateViewButton.rx.tap.asSignal()
            .emit(onNext: { [weak self] in
                let vc = CreateNewTeacherViewController.configure(with: CreateNewTeacherViewModel())
                self?.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        backToTeachersButton.rx.tap.asSignal()
            .emit(onNext: { [weak self] in
                let vc = TeachersListViewController.configure()
                let nc = UINavigationController(rootViewController: vc)
                nc.modalPresentationStyle = .fullScreen
                self?.present(nc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        view.addGestureRecognizer(tapBackground)
    }
    
    private func transitionToMessageListView() {
        guard let currentTeacher = AccountService.currentTeacher else { return }
        let thanksListViewModel = ThanksListViewModel(teacherID: currentTeacher.uid)
        let thanksListVC = ThanksListViewController.configure(with: thanksListViewModel)
        let nc = UINavigationController(rootViewController: thanksListVC)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true, completion: nil)
    }
}
