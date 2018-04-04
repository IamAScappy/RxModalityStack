//
// Created by Chope on 2018. 4. 4..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

public protocol ModalityPresentable {
    static func viewController<T: ModalityType, D: ModalityData>(for type: T, with data: D) throws -> (UIViewController & ModalityPresentable)
    static func transition<T: ModalityType, D: ModalityData>(for type: T, with data: D) throws -> ModalityTransition
}