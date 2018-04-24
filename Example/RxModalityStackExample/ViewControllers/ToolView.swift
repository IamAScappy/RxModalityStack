//
// Created by Chope on 2018. 4. 24..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit
import RxSwift
import RxModalityStack

class ToolView: UIView {
    private let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configureViews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureViews()
    }

    private func configureViews() {
        backgroundColor = UIColor.black
        addSubview(createControlButton(title: "dismiss all", origin: CGPoint(x: 6, y: 6), action: #selector(self.dismissAll)))
        addSubview(createControlButton(title: "dismiss front", origin: CGPoint(x: 90, y: 6), action: #selector(self.dismissFront)))
        addSubview(createControlButton(title: "dismiss except", origin: CGPoint(x: 180, y: 6), action: #selector(self.dismissExceptGreenAndBlue)))

        addSubview(createControlButton(title: "first to front", origin: CGPoint(x: 6, y: 40), action: #selector(self.firstToFront)))
        addSubview(createControlButton(title: "activity", origin: CGPoint(x: 95, y: 40), action: #selector(self.presentActivityController)))

        addSubview(createControlButton(title: "alert", origin: CGPoint(x: 6, y: 74), action: #selector(self.presentAlert)))
        addSubview(createControlButton(title: "imagePicker", origin: CGPoint(x: 50, y: 74), action: #selector(self.presentImagePicker)))
        addSubview(createControlButton(title: "blue", origin: CGPoint(x: 140, y: 74), action: #selector(self.presentBlue)))
        addSubview(createControlButton(title: "green", origin: CGPoint(x: 180, y: 74), action: #selector(self.presentGreen)))
        addSubview(createControlButton(title: "red", origin: CGPoint(x: 230, y: 74), action: #selector(self.presentRed)))
        addSubview(createControlButton(title: "yellow", origin: CGPoint(x: 270, y: 74), action: #selector(self.presentYellow)))
    }

    private func createControlButton(title: String, origin: CGPoint, action: Selector) -> UIButton {
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
        Modal.shared.dismissAll(animated: true).debug().subscribe().disposed(by: disposeBag)
    }

    @objc func dismissFront() {
        Modal.shared.dismissFront(animated: true).debug().subscribe().disposed(by: disposeBag)
    }

    @objc func dismissExceptGreenAndBlue() {
        Modal.shared.dismissAll(except: [.green, .blue]).debug().subscribe().disposed(by: disposeBag)
    }

    @objc func firstToFront() {
        guard Modal.shared.stack.count > 0 else { return }
        let modality = Modal.shared.stack[0]
        Modal.shared.bringModality(toFront: modality.id).debug().subscribe().disposed(by: disposeBag)
    }

    @objc func presentActivityController() {
        Modal.shared.present(.activity, with: .empty, animated: true).subscribe().disposed(by: disposeBag)
    }

    @objc func presentBlue() {
        Modal.shared.present(.blue, with: .none, animated: true).subscribe().disposed(by: disposeBag)
    }

    @objc func presentGreen() {
        Modal.shared.present(.green, with: .none, animated: true).subscribe().disposed(by: disposeBag)
    }

    @objc func presentRed() {
        Modal.shared.present(.red, with: .none, animated: true).subscribe().disposed(by: disposeBag)
    }

    @objc func presentYellow() {
        Modal.shared.present(.color, with: .color(.yellow), animated: true).subscribe().disposed(by: disposeBag)
    }

    @objc func presentAlert() {
        Modal.shared.present(.alert, with: .alert(title: "title", message: "message"), animated: true).subscribe().disposed(by: disposeBag)
    }

    @objc func presentImagePicker() {
        Modal.shared.present(.imagePicker, with: .empty, animated: true)
            .asObservable()
            .flatMap { (modality: Modality<Modal, ModalData>) -> Observable<(UIViewController, UIImage)> in
                guard let vc = modality.viewController as? UIImagePickerController else {
                    throw ToolError.invalidVC
                }
                return vc.rx.didSelectImage.asObservable().map { (vc, $0) }
            }
            .subscribe(onNext: { (vc: UIViewController, image: UIImage) in
                Modal.shared.dismiss(vc, animated: true).subscribe()
                Modal.shared.present(.image, with: .image(image), animated: true).subscribe().disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}
