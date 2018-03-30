//
// Created by Chope on 2018. 3. 30..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import Foundation
import RxModalityStack

enum Modal: ModalityType {
    static let shared: RxSerialModalityStack<Modal> = RxSerialModalityStack()

    case green
    case blue
    case red
    case yellow
    case color(UIColor)

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

    static func ==(lhs: Modal, rhs: Modal) -> Bool {
        switch (lhs, rhs) {
        case (.green, .green), (.blue, .blue), (.red, .red), (.yellow, .yellow):
            return true
        case let (.color(lhsValue), .color(rhsValue)) where lhsValue == rhsValue:
            return true
        default:
            return false
        }
    }

    static func ~=(lhs: Modal, rhs: Modal) -> Bool {
        switch (lhs, rhs) {
        case (.green, .green), (.blue, .blue), (.red, .red), (.yellow, .yellow), (.color, .color):
            return true
        default:
            return false
        }
    }
}