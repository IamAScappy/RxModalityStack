//
// Created by Chope on 2018. 3. 8..
// Copyright (c) 2018 Chope. All rights reserved.
//

import Foundation

public struct RxModalityStack {
    public static var shared: RxModalityStackType = RxSerialModalityStack()
}
