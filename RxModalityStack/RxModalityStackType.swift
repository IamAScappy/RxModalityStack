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

public protocol RxModalityStackType: class {
    associatedtype LocalModalityType: ModalityType
    associatedtype LocalModalityData: ModalityData

    var queue: RxTaskQueue { get set }
    var changedStack: PublishSubject<[Modality<LocalModalityType, LocalModalityData>]> { get }
    var stack: [Modality<LocalModalityType, LocalModalityData>] { get }

    func present(_ modalityType: LocalModalityType, with data: LocalModalityData, animated: Bool) -> Single<Modality<LocalModalityType, LocalModalityData>>

    func dismissFront(animated: Bool) -> Single<Modality<LocalModalityType, LocalModalityData>>
    func dismiss(_ modalityType: LocalModalityType, animated: Bool) -> Single<Modality<LocalModalityType, LocalModalityData>>
//    func dismiss(_ modalityTypes: [LocalModalityType]) -> Single<Void>
    func dismissAll(animated: Bool) -> Single<Void>
//    func dismissAll(except types: [LocalModalityType]) -> Single<Void>

    func bring(toFront: LocalModalityType) -> Single<Modality<LocalModalityType, LocalModalityData>>

    func isPresented(modalityType: LocalModalityType, onlyType: Bool) -> Bool
    func modality(at index: Int) -> Modality<LocalModalityType, LocalModalityData>?
    func modality(of type: LocalModalityType) -> [Modality<LocalModalityType, LocalModalityData>]
}
