//
//  CreateNewTeacherViewController.swift
//  SchoolThanksApp
//
//  Created by 前澤健一 on 2021/10/03.
//

import UIKit
import RxSwift
import RxCocoa

class CreateNewTeacherViewController: UIViewController {
    
    typealias Dependency = CreateNewTeacherViewModel
    
    // MARK: - UIProperties
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.layer.cornerRadius = 50
            userImageView.layer.borderWidth = 1
            userImageView.layer.borderColor = UIColor.darkGray.cgColor
            userImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createNewButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toLoginView: UIButton!
    
    lazy var imagePickerController: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()
    
    private let viewModel: Dependency
    private let disposeBag = DisposeBag()
    
    init?(coder: NSCoder, dependency: Dependency) {
        self.viewModel = dependency
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func configure(with dependency: Dependency) -> Self {
        let vc = UIStoryboard(name: "CreateNewTeacherViewController", bundle: nil)
            .instantiateInitialViewController { coder in
                CreateNewTeacherViewController(coder: coder, dependency: dependency)
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
        nameTextField.rx.text.asObservable()
            .bind(to: viewModel.nameText)
            .disposed(by: disposeBag)
        
        emailTextField.rx.text.asObservable()
            .bind(to: viewModel.emailText)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.asObservable()
            .bind(to: viewModel.passwordText)
            .disposed(by: disposeBag)
        
        createNewButton.rx.tap.asSignal()
            .emit(to: viewModel.clickedCreateButton)
            .disposed(by: disposeBag)
        
        viewModel.isLoadingIndicator
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.didFinishCreateAccount
            .drive(onNext: { [weak self] in
                let alertController = UIAlertController(title: nil, message: "ユーザーを新規作成しました", preferredStyle: .alert)
                guard let currentTeacher = AccountService.currentTeacher else { return }
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                    let thanksListViewModel = ThanksListViewModel(teacherID: currentTeacher.uid)
                    let thanksListVC = ThanksListViewController.configure(with: thanksListViewModel)
                    self?.navigationController?.pushViewController(thanksListVC, animated: true)
                }))
                self?.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
        
        selectImageButton.rx.tap.asSignal()
            .emit(onNext: { [weak self] in
                self?.present(self!.imagePickerController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        toLoginView.rx.tap.asSignal()
            .emit(onNext: { [weak self] in
                let vm = LoginTeacherViewModel()
                let vc = LoginTeacherViewController.configure(with: vm)
                self?.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension CreateNewTeacherViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.userImageView.image = image
            viewModel.userImage.accept(image)
        } else {
            print("Failed to get image.")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
