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

class TransparentToolViewController: TransparentModalViewController {
    let toolView: UIView = ToolView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(toolView)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        toolView.frame.size.height = 120
        toolView.frame.size.width = view.bounds.size.width
        toolView.frame.origin.y = view.bounds.size.height - toolView.frame.size.height
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