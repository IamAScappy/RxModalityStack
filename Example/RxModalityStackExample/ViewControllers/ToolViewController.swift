//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxModalityStack

enum ToolError: Error {
    case invalidData
    case invalidVC
}

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
        view.addSubview(createControlButton(title: "dismiss except", origin: CGPoint(x: 180, y: 6), action: #selector(self.dismissExceptGreenAndBlue)))

        view.addSubview(createControlButton(title: "first to front", origin: CGPoint(x: 6, y: 40), action: #selector(self.firstToFront)))
        view.addSubview(createControlButton(title: "activity", origin: CGPoint(x: 95, y: 40), action: #selector(self.presentActivityController)))

        view.addSubview(createControlButton(title: "alert", origin: CGPoint(x: 6, y: 74), action: #selector(self.presentAlert)))
        view.addSubview(createControlButton(title: "imagePicker", origin: CGPoint(x: 50, y: 74), action: #selector(self.presentImagePicker)))
        view.addSubview(createControlButton(title: "blue", origin: CGPoint(x: 140, y: 74), action: #selector(self.presentBlue)))
        view.addSubview(createControlButton(title: "green", origin: CGPoint(x: 180, y: 74), action: #selector(self.presentGreen)))
        view.addSubview(createControlButton(title: "red", origin: CGPoint(x: 230, y: 74), action: #selector(self.presentRed)))
        view.addSubview(createControlButton(title: "yellow", origin: CGPoint(x: 270, y: 74), action: #selector(self.presentYellow)))
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

    @objc func dismissExceptGreenAndBlue() {
        Modal.shared.dismissAll(except: [.green, .blue]).subscribe().disposed(by: disposeBag)
    }

    @objc func firstToFront() {
        guard Modal.shared.stack.count > 0 else { return }
        let modality = Modal.shared.stack[0]
        Modal.shared.bringModality(toFront: modality.id).subscribe().disposed(by: disposeBag)
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

enum UIImagePickerControllerError: Error {
    case originalImageNotExists
    case infoNotExists
    case imageNotExists
}

class RxImagePickerDelegateProxy
    : DelegateProxy<UIImagePickerController, UIImagePickerControllerDelegate & UINavigationControllerDelegate>
        , DelegateProxyType
        , UIImagePickerControllerDelegate
        , UINavigationControllerDelegate {

    init(imagePicker: UIImagePickerController) {
        super.init(parentObject: imagePicker, delegateProxy: RxImagePickerDelegateProxy.self)
    }

    let imagePublishSubject = PublishSubject<UIImage>()
    let cancelPublishSubject = PublishSubject<Void>()

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            imagePublishSubject.onError(UIImagePickerControllerError.originalImageNotExists)
            return
        }
        guard let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
            imagePublishSubject.onNext(originalImage)
            return
        }
        imagePublishSubject.onNext(editedImage)
        imagePublishSubject.onCompleted()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        cancelPublishSubject.onNext(Void())
    }

    class func currentDelegate(for object: UIImagePickerController) -> (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? {
        return object.delegate
    }

    class func setCurrentDelegate(_ delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?, to object: UIImagePickerController) {
        object.delegate = delegate
    }

    class func registerKnownImplementations() {
        self.register { RxImagePickerDelegateProxy(imagePicker: $0) }
    }

    override func forwardToDelegate() -> (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? {
        fatalError("forwardToDelegate() has not been implemented")
    }

    override func setForwardToDelegate(_ forwardToDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?, retainDelegate: Bool) {
    }
}

extension Reactive where Base: UIImagePickerController {
    var didSelectImage: ControlEvent<UIImage> {
        let source = RxImagePickerDelegateProxy.proxy(for: base).imagePublishSubject
        return ControlEvent(events: source)
    }

    var didCancel: ControlEvent<Void> {
        let source = RxImagePickerDelegateProxy.proxy(for: base).cancelPublishSubject
        return ControlEvent(events: source)
    }
}