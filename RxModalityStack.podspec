Pod::Spec.new do |s|
  s.name         = "RxModalityStack"
  s.version      = "0.0.1"
  s.summary      = "Modal present, dismiss manager"
  s.description  = <<-DESC
  ModalityStack 은 Modal ViewController 의 Stack 을 관리해줍니다.

  Modal 위에 Modal, 그 위에 Modal 등 복수개의 Modal을 연속으로 띄워줍니다.

  화면에 상관없이 띄워야 하는 Modal 에 유용합니다.
                   DESC
  s.homepage     = "https://github.com/yoonhg84/RxModalityStack"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "yoonhg84" => "yoonhg2002@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/yoonhg84/RxModalityStack.git", :tag => "#{s.version}" }
  s.source_files  = "RxModalityStack/*.swift"

  s.dependency "RxSwift"
  s.dependency "RxCocoa"

end
