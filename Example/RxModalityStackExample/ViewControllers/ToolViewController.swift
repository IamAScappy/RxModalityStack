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
        Modal.shared.dismissAll(animated: true).subscribe().disposed(by: disposeBag)
    }

    @objc func dismissFront() {
        Modal.shared.dismissFront(animated: true).subscribe().disposed(by: disposeBag)
    }

    @objc func dismissFirst() {
        guard let modality = Modal.shared.modality(at: 0) else { return }
        Modal.shared.dismiss(modality.type, animated: false)
    }

    @objc func firstToFront() {
        guard let modality = Modal.shared.modality(at: 0) else { return }
        Modal.shared.bring(toFront: modality.type).subscribe().disposed(by: disposeBag)
    }

    @objc func presentBlue() {
        Modal.shared.present(.blue, animated: true, transition: .slideUpDown).subscribe().disposed(by: disposeBag)
    }

    @objc func presentGreen() {
        Modal.shared.present(.green, animated: true, transition: .slideLeftRight).subscribe().disposed(by: disposeBag)
    }

    @objc func presentRed() {
        Modal.shared.present(.red, animated: true, transition: .system).subscribe().disposed(by: disposeBag)
    }

    @objc func presentYellow() {
        Modal.shared.present(.yellow, animated: true, transition: .system).subscribe().disposed(by: disposeBag)
    }
}
