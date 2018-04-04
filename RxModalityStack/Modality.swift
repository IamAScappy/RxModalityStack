//
// Created by Chope on 2018. 4. 4..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

public protocol ModalityType: Equatable {
    var modalityPresentableType: (UIViewController & ModalityPresentable).Type { get }
}

public protocol ModalityData: Equatable {
    static var none: Self { get }
}

public struct Modality<T: ModalityType, D: ModalityData>: Equatable {
    public let type: T
    public let data: D
    public let transition: ModalityTransition
    public let viewController: UIViewController

    public static func ==(lhs: Modality<T, D>, rhs: Modality<T, D>) -> Bool {
        guard lhs.type == rhs.type else { return false }
        guard lhs.data == rhs.data else { return false }
        guard lhs.transition == rhs.transition else { return false }
        guard lhs.viewController == rhs.viewController else { return false }
        return true
    }
}