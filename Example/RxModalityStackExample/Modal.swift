//
// Created by Chope on 2018. 3. 30..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import Foundation
import RxSwift
import RxModalityStack

enum Modal: ModalityType {
    static let shared: RxSerialModalityStack<Modal, ModalData> = RxSerialModalityStack()

    case green
    case blue
    case red
    case yellow
    case color
    case alert

    var modalityPresentableType: (UIViewController & ModalityPresentable).Type {
        switch self {
        case .green:
            return GreenVC.self
        case .blue:
            return BlueVC.self
        case .red:
            return RedVC.self
        case .yellow:
            return YellowVC.self
        case .color:
            return ColorVC.self
        case .alert:
            return UIAlertController.self
        }
    }
}

enum ModalData: ModalityData {
    static let none: ModalData = .empty

    case empty
    case color(UIColor)
    case alert(title: String, message: String)
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

extension UIAlertController: ModalPresentable {
    static func viewControllerOf(_ modal: Modal, with data: ModalData) -> (UIViewController & ModalityPresentable)? {
        switch (modal, data) {
        case (.alert, .alert(let title, let message)):
            let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "ok", style: .default) { [unowned vc] action in
                print("press ok")
                Modal.shared.setToDismissed(vc)
            })
            vc.addAction(UIAlertAction(title: "delete", style: .destructive) { [unowned vc] action in
                print("press delete")
                Modal.shared.setToDismissed(vc)
                _ = Modal.shared.dismissAll(animated: false).subscribe()
            })
            vc.addAction(UIAlertAction(title: "cancel", style: .cancel) { action in
                print("press cancel")
            })
            return vc
        default:
            return nil
        }
    }

    static func transitionOf(_ modal: Modal, with data: ModalData) -> ModalityTransition? {
        return .system
    }
}