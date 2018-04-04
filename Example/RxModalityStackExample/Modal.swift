//
// Created by Chope on 2018. 3. 30..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import Foundation
import RxModalityStack

enum Modal: ModalityType {
    static let shared: RxSerialModalityStack<Modal, ModalData> = RxSerialModalityStack()

    case green
    case blue
    case red
    case yellow
    case color

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
        }
    }
}

enum ModalData: ModalityData {
    static let none: ModalData = .empty

    case empty
    case color(UIColor)

    static func ==(lhs: ModalData, rhs: ModalData) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.color(let lhsValue), .color(let rhsValue)) where lhsValue == rhsValue:
            return true
        default:
            return false
        }
    }
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
    static func viewController<T: ModalityType, D: ModalityData>(for type: T, with data: D) throws -> (UIViewController & ModalityPresentable) {
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

    static func transition<T: ModalityType, D: ModalityData>(for type: T, with data: D) throws -> ModalityTransition {
        guard let modal = type as? Modal else {
            throw ModalPresentableError.invalidType
        }
        guard let data = data as? ModalData else {
            throw ModalPresentableError.invalidDataType
        }
        return transitionOf(modal, with: data) ?? .system
    }
}