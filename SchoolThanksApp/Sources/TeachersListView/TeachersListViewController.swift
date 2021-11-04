//
//  TeachersListViewController.swift
//  SchoolThanksApp
//
//  Created by 前澤健一 on 2021/10/02.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import Firebase

class TeachersListViewController: UIViewController {
    
    static func configure() -> Self {
        let vc = UIStoryboard(name: "TeachersListViewController", bundle: nil).instantiateInitialViewController() as! Self
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    @IBOutlet weak var tableview: UITableView!
    private let toLoginButton = UIBarButtonItem(title: "先生はこちら", style: .done, target: nil, action: nil)
    private let disposeBag = DisposeBag()
    var teachers: [Teacher] = [Teacher]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(UINib(nibName: "TeachersListTableViewCell", bundle: nil), forCellReuseIdentifier: "TeachersListTableViewCell")
        tableview.tableFooterView = UIView(frame: .zero)
        //setupTeachersMock()
        addTeachersSnapshotListener()
        toLoginButton.tintColor = UIColor.purple
        toLoginButton.rx.tap.asSignal()
            .emit(onNext: { [weak self] in
                let vm = LoginTeacherViewModel()
                let vc = LoginTeacherViewController.configure(with: vm)
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = toLoginButton
        navigationItem.title = "先生一覧"
    }
    
    func setupTeachersMock() {
        teachers = [Teacher(uid: "1", name: "A先生", imageURL: "https://source.unsplash.com/random"), Teacher(uid: "2", name: "B先生", imageURL: "https://source.unsplash.com/random")]
    }
    
    private func addTeachersSnapshotListener() {
        let db = Firestore.firestore()
        db.collection("teachers")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                let fetchedTeachers = documents.map {
                    Teacher(uid: $0["uid"] as! String,
                            name: $0["name"] as! String,
                            imageURL: $0["imageURL"] as! String)
                }
                print("Current messges count: \(fetchedTeachers.count)")
                self.teachers = fetchedTeachers
                self.tableview.reloadData()
            }
        
    }
    
    @IBAction func transitionToLogin(_ sender: Any) {
        print("Login画面に遷移")
    }
    
}

extension TeachersListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("teachers count：\(teachers.count)")
        return teachers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "TeachersListTableViewCell", for: indexPath) as! TeachersListTableViewCell
        cell.configure(teacher: teachers[indexPath.row])
        return cell
    }
}

extension TeachersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: - ここでteachersIDを指定
//        let thanksListViewModel = ThanksListViewModel(teacherID: "XXXX")
//        let thanksListVC = ThanksListViewController.configure(with: thanksListViewModel)
//        navigationController?.pushViewController(thanksListVC, animated: true)
        
        let nextVC = UIStoryboard(name: "SendThanksViewController", bundle: nil).instantiateViewController(withIdentifier: "SendThanksViewController") as! SendThanksViewController
        nextVC.teacher = teachers[indexPath.row]
        nextVC.indexPathRow = indexPath.row
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

