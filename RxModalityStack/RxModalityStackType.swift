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
    case invalidID
    case stackIsEmpty
}

public enum StackEvent<M> {
    case presenting(M)
    case presented(M)
    case dismissing(M)
    case dismissed(M)
    case empty
}

public protocol RxModalityStackType: class {
    associatedtype LocalModalityType: ModalityType
    associatedtype LocalModalityData: ModalityData

    var queue: RxTaskQueue { get set }
    var stackEvent: PublishSubject<StackEvent<Modality<LocalModalityType, LocalModalityData>>> { get }
    var stack: [Modality<LocalModalityType, LocalModalityData>] { get }

    func present(_ modalityType: LocalModalityType, with data: LocalModalityData, animated: Bool) -> Single<Modality<LocalModalityType, LocalModalityData>>

    func dismissFront(animated: Bool) -> Single<Modality<LocalModalityType, LocalModalityData>>
    func dismiss(_ viewController: UIViewController, animated: Bool) -> Single<Modality<LocalModalityType, LocalModalityData>>
    func dismiss(_ id: String, animated: Bool) -> Single<Modality<LocalModalityType, LocalModalityData>>
    func dismissAll(animated: Bool) -> Single<Void>
    func dismissAll(except types: [LocalModalityType]) -> Single<Void>

    func bringModality(toFront id: String) -> Single<Modality<LocalModalityType, LocalModalityData>>
    func bringModality(toFront viewController: UIViewController) -> Single<Modality<LocalModalityType, LocalModalityData>>

    func isPresented(_ type: LocalModalityType) -> Bool
    func isPresented(_ id: String) -> Bool
    func isPresented(_ viewController: UIViewController) -> Bool

    func modality(of id: String) -> Modality<LocalModalityType, LocalModalityData>?
    func modality(of viewController: UIViewController) -> Modality<LocalModalityType, LocalModalityData>?

    func setToDismissed(_ id: String) -> Single<Void>
    func setToDismissed(_ viewController: UIViewController) -> Single<Void>
}
