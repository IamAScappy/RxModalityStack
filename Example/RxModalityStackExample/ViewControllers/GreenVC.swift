//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxModalityStack

class GreenVC: TransparentToolViewController, BackgroundColorAlphaAnimation {
    let contentView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    let tableView: UITableView = {
        let view = UITableView()
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return view
    }()
    let disposeBag = DisposeBag()

    let data: [UIColor] = [.purple, .brown, .cyan, .magenta, .orange, .red]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(contentView)
        contentView.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        contentView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        tableView.frame = contentView.bounds
    }
}

extension GreenVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let color = data[indexPath.row]

        cell.backgroundColor = color

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt \(indexPath.row)")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension GreenVC: OutsideTouchable {
    func onTouchOutside() {
        Modal.shared.dismiss(self, animated: true).subscribe().disposed(by: disposeBag)
    }
}

extension GreenVC: ModalPresentable {
    class func viewControllerOf(_ modal: Modal, with data: ModalData) -> (UIViewController & ModalityPresentable)? {
        return GreenVC()
    }

    class func transitionOf(_ modal: Modal, with data: ModalData) -> ModalityTransition? {
        return .slideLeftRight
    }
}