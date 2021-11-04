//
//  ThanksListViewController.swift
//  SchoolThanksApp
//
//  Created by 前澤健一 on 2021/10/02.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase

class ThanksListViewController: UIViewController {

    typealias Dependency = ThanksListViewModel

    // MARK: UIProperties
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(cellType: MessagesSummaryTableViewCell.self)
            tableView.register(cellType: ThanksMessageTableViewCell.self)
        }
    }
    private let signOutButton = UIBarButtonItem(title: "SignOut", style: .done, target: nil, action: nil)
    private let refreshControl = UIRefreshControl()
    
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
        let vc = UIStoryboard(name: "ThanksListViewController", bundle: nil)
            .instantiateInitialViewController { coder in
                ThanksListViewController(coder: coder, dependency: dependency)
            }! as! Self
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bind()
        viewModel.viewDidLoad.accept(())
    }
    
    private func setupView() {
        navigationItem.title = "受け取ったメッセージ一覧"
        signOutButton.tintColor = UIColor.purple
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        navigationItem.rightBarButtonItem = signOutButton
        tableView.refreshControl = refreshControl
    }
    
    private func bind() {
        refreshControl.rx.controlEvent(.valueChanged).asObservable()
            .bind(to: viewModel.beginRefreshing)
            .disposed(by: disposeBag)
        
        viewModel.tableItems
            .drive(tableView.rx.items) { tableView, row, element in
                switch element {
                case let .summary(count):
                    let cell = tableView.dequeueReusableCell(with: MessagesSummaryTableViewCell.self, for: [0, row])
                    cell.configure(count: count)
                    return cell
                case let .thanksMessge(thanksMessage):
                    let cell = tableView.dequeueReusableCell(with: ThanksMessageTableViewCell.self, for: [0, row])
                    cell.configure(with: thanksMessage)
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.didEndRefrashing
            .drive(onNext: { [weak self] in
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        signOutButton.rx.tap.asSignal()
            .emit(onNext: {
                print("サインアウトします")
                let alertController = UIAlertController(title: nil, message: "サインアウトしますか？", preferredStyle: UIAlertController.Style.alert)
                //OKボタンを追加
                let okAction = UIAlertAction(title: "OK", style: .default){ [weak self] (action: UIAlertAction) in
                    //OKボタンがタップされたときの処理
                    do {
                        try Auth.auth().signOut()
                        let vc = TeachersListViewController.configure()
                        let nc = UINavigationController(rootViewController: vc)
                        nc.modalPresentationStyle = .fullScreen
                        self?.present(nc, animated: true, completion: nil)
                    } catch let signOutError as NSError {
                        print ("Error signing out: \(signOutError)")
                    }
                }
                alertController.addAction(okAction)
                //cancelボタンを追加
                let cancelButton = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
                alertController.addAction(cancelButton)
                //アラートダイアログを表示
                self.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
