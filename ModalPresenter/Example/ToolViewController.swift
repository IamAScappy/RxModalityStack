//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit

class ToolViewController: UIViewController {
    var toolView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        toolView = createToolView()
        view.addSubview(toolView)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        toolView.frame.size.width = view.bounds.size.width
        toolView.frame.origin.y = view.bounds.size.height - toolView.frame.size.height
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(self): viewWillAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(self): viewWillDisappear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(self): viewDidAppear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\(self): viewDidDisappear")
    }

    func createToolView() -> UIView? {
        let height: CGFloat = 120
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: height))
        view.backgroundColor = UIColor.black
        view.addSubview(createControlButton(title: "dismiss all", origin: CGPoint(x: 6, y: 6), action: #selector(self.dismissAll)))
        view.addSubview(createControlButton(title: "dismiss front", origin: CGPoint(x: 90, y: 6), action: #selector(self.dismissFront)))
        view.addSubview(createControlButton(title: "dismiss First", origin: CGPoint(x: 190, y: 6), action: #selector(self.dismissFirst)))
        view.addSubview(createControlButton(title: "first to front", origin: CGPoint(x: 6, y: 40), action: #selector(self.firstToFront)))
        view.addSubview(createControlButton(title: "present blue", origin: CGPoint(x: 6, y: 74), action: #selector(self.presentBlue)))
        view.addSubview(createControlButton(title: "present green", origin: CGPoint(x: 94, y: 74), action: #selector(self.presentGreen)))
        view.addSubview(createControlButton(title: "present red", origin: CGPoint(x: 188, y: 74), action: #selector(self.presentRed)))
        view.addSubview(createControlButton(title: "present yellow", origin: CGPoint(x: 270, y: 74), action: #selector(self.presentYellow)))
        return view
    }

    func createControlButton(title: String, origin: CGPoint, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.frame.origin = origin
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.sizeToFit()
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc func dismissAll() {
        ModalPresenter.shared.dismissAll(animated: true)
    }

    @objc func dismissFront() {
        ModalPresenter.shared.dismiss(animated: true)
    }

    @objc func dismissFirst() {
        guard let viewController = ModalPresenter.shared.viewController(at: 0) else { return }
        ModalPresenter.shared.dismiss(viewController: viewController, animated: true)
    }

    @objc func firstToFront() {
        guard let viewController = ModalPresenter.shared.viewController(at: 0) else { return }
        ModalPresenter.shared.moveToFront(viewController: viewController)
    }

    @objc func presentBlue() {
        ModalPresenter.shared.present(viewController: BlueVC(), animated: true)
    }

    @objc func presentGreen() {
        ModalPresenter.shared.present(viewController: GreenVC(), animated: true)
    }

    @objc func presentRed() {
        ModalPresenter.shared.present(viewController: RedVC(), animated: true)
    }

    @objc func presentYellow() {
        ModalPresenter.shared.present(viewController: YellowVC(), animated: true)
    }
}