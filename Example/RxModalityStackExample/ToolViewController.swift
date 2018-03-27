//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxSwift
import RxModalityStack

class ToolViewController: TransparentModalViewController {
    var toolView: UIView!

    private let disposeBag = DisposeBag()

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
        RxModalityStack.shared.dismissAll(animated: true).subscribe().disposed(by: disposeBag)
    }

    @objc func dismissFront() {
        RxModalityStack.shared.dismiss(animated: true).subscribe().disposed(by: disposeBag)
    }

    @objc func dismissFirst() {
        guard let viewController = RxModalityStack.shared.viewController(at: 0) else { return }
        RxModalityStack.shared.dismiss(viewController: viewController, animated: true).subscribe().disposed(by: disposeBag)
    }

    @objc func firstToFront() {
        guard let viewController = RxModalityStack.shared.viewController(at: 0) else { return }
        RxModalityStack.shared.moveToFront(viewController: viewController).subscribe().disposed(by: disposeBag)
    }

    @objc func presentBlue() {
        RxModalityStack.shared.present(viewController: BlueVC(), animated: true, transition: .slideUpDownDarkBackground(alpha: 0.6)).subscribe().disposed(by: disposeBag)
    }

    @objc func presentGreen() {
        RxModalityStack.shared.present(viewController: GreenVC(), animated: true, transition: .slideLeftRightDarkBackground(alpha: 0.6)).subscribe().disposed(by: disposeBag)
    }

    @objc func presentRed() {
        RxModalityStack.shared.present(viewController: RedVC(), animated: true, transition: .system).subscribe().disposed(by: disposeBag)
    }

    @objc func presentYellow() {
        RxModalityStack.shared.present(viewController: YellowVC(), animated: true, transition: .system).subscribe().disposed(by: disposeBag)
    }
}
