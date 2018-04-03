//
// Created by Chope on 2018. 3. 8..
// Copyright (c) 2018 Chope. All rights reserved.
//

import UIKit
import RxSwift

public enum RxModalityStackTypeError: Error {
    case frontViewControllerNotExists
    case viewControllerNotExists
    case notExistsInStack
    case topOfStackIsNotFrontViewController
    case tooManyTypesInStack
}

public protocol ModalityPresentable {
    static func viewController<T: ModalityType>(for type: T) throws -> UIViewController
}

public protocol ModalityType: Equatable {
    var modalityPresentableType: (UIViewController & ModalityPresentable).Type { get }

    static func ~=(lhs: Self, rhs: Self) -> Bool
}

public struct Modality<T: ModalityType>: Equatable {
    public let type: T
    public let viewController: UIViewController

    public static func ==(lhs: Modality<T>, rhs: Modality<T>) -> Bool {
        guard lhs.type == rhs.type else { return false }
        guard lhs.viewController == rhs.viewController else { return false }
        return true
    }
}

public protocol RxModalityStackType: class {
    associatedtype LocalModalityType: ModalityType

    var queue: RxTaskQueue { get set }
    var changedStack: PublishSubject<[Modality<LocalModalityType>]> { get }
    var stack: [Modality<LocalModalityType>] { get }

    func present(_ modalityType: LocalModalityType, animated: Bool, transition: ModalityTransition) -> Single<UIViewController>

    func dismissFront(animated: Bool) -> Single<Void>
    func dismiss(_ modalityType: LocalModalityType, animated: Bool) -> Single<Void>
//    func dismiss(_ modalityTypes: [LocalModalityType]) -> Single<Void>
    func dismissAll(animated: Bool) -> Single<Void>
//    func dismissAll(except types: [LocalModalityType]) -> Single<Void>

    func bring(toFront: LocalModalityType) -> Single<Void>

    func isPresented(modalityType: LocalModalityType, onlyType: Bool) -> Bool
    func modality(at index: Int) -> Modality<LocalModalityType>?
    func modality(of type: LocalModalityType) -> [Modality<LocalModalityType>]
}
