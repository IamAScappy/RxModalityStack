//
// Created by Chope on 2018. 3. 30..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import Foundation
import MobileCoreServices
import RxSwift
import RxModalityStack

enum Modal: ModalityType {
    static let shared: RxModalityStack<Modal, ModalData> = RxModalityStack()

    case green
    case blue
    case red
    case color
    case alert
    case imagePicker
    case image
    case activity

    var modalityPresentableType: (UIViewController & ModalityPresentable).Type {
        switch self {
        case .green:
            return GreenVC.self
        case .blue:
            return BlueVC.self
        case .red:
            return RedVC.self
        case .color:
            return ColorVC.self
        case .alert:
            return UIAlertController.self
        case .imagePicker:
            return UIImagePickerController.self
        case .image:
            return ImageVC.self
        case .activity:
            return UIActivityViewController.self
        }
    }
}

enum ModalData: ModalityData {
    static let none: ModalData = .empty

    case empty
    case color(UIColor)
    case alert(title: String, message: String)
    case image(UIImage)
}

enum ModalPresentableError: Error {
    case invalidType
    case invalidDataType
    case viewControllerNotExists
}

protocol ModalPresentable: ModalityPresentable {
    static func viewControllerOf(_ modal: Modal, with data: ModalData) -> (UIViewController & ModalityPresentable)?
    static func transitionOf(_ modal: Modal, with data: ModalData) -> ModalityTransition?
}

extension ModalPresentable {
    public static func viewController<T: ModalityType, D: ModalityData>(for type: T, with data: D) throws -> (UIViewController & ModalityPresentable) {
        guard let modal = type as? Modal else {
            throw ModalPresentableError.invalidType
        }
        guard let data = data as? ModalData else {
            throw ModalPresentableError.invalidDataType
        }
        guard let vc = viewControllerOf(modal, with: data) else {
            throw ModalPresentableError.viewControllerNotExists
        }
        return vc
    }

    public static func transition<T: ModalityType, D: ModalityData>(for type: T, with data: D) throws -> ModalityTransition {
        guard let modal = type as? Modal else {
            throw ModalPresentableError.invalidType
        }
        guard let data = data as? ModalData else {
            throw ModalPresentableError.invalidDataType
        }
        return transitionOf(modal, with: data) ?? .system
    }
}