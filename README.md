# RxModalityStack

[![Build Status](https://travis-ci.org/yoonhg84/RxModalityStack.svg?branch=master)](https://travis-ci.org/yoonhg84/RxModalityStack)

ModalityStack 은 Modal ViewController 의 Stack 을 관리해줍니다.

Modal 위에 Modal, 그 위에 Modal 등 복수개의 Modal을 연속으로 띄워줍니다.

화면에 상관없이 띄워야 하는 Modal 에 유용합니다.


# Installation

**Carthage**

```
github 'yoonhg84/RxModalityStack' 'master'
```

**Cocoapods**

(지원 예정)

## Usage

### Present view controller

prsent 하는 방법은 UIViewController 에서 하는 방법과 유사합니다.

```swift
let vc = UIViewController()
RxModalityStack.shared.present(viewController: vc, animated: true)
```

ModalityStack 에는 completion block 이 없습니다.

completion 은 RxSwift로 대신 합니다.

```swift
let vc = UIViewController()
RxModalityStack.shared
  .present(viewController: vc, animated: true)
  .subscribe(onNext: { _ in
    print("presented viewController")
  })
  .disposed(by: disposeBag)
```

### Dismiss view controller

최상위 Modal UIViewController 를 dismiss

```swift
RxModalityStack.shared.dismiss(animated: true)
```

특정 Modal UIViewController 를 dismiss

```swift
RxModalityStack.shared.dismiss(viewController: vc, animated: true)
```

모든 Modal UIViewController 를 dismiss

```swift
RxModalityStack.shared.dismissAll(animated: true)
```

모든 dismiss 는 completion을 RxSwift 로 구현할 수 있습니다.

```swift
RxModalityStack.shared
  .dismissAll(animated: true)
  .subscribe(onNext: { _ in
    print("dismiss all")
  })
```

## Change stack (Experimental function)

Stack 에 있는 특정 Moal UIViewController 를 최상위로 변경합니다.

```swift
RxModalityStack.shared.moveToFront(viewController: firstViewController)
```

## UIViewController+Rx

```swift
class AViewController: UIViewController {
.....
  self.rx
    .present(viewController: vc, animated: true)
    .subscribe()
    .disposed(by: disposeBag)
  self.rx
    .dismiss(animated: true)
    .subscribe()
    .disposed(by: disposeBag)
.....
}
```

## License

RxModalityStack is released under the MIT license. See [LICENSE](https://github.com/yoonhg84/RxModalityStack/blob/master/LICENSE) for details.
