//
//  YYNestScrollView.swift
//  YYReader
//
//  Created by 彭章锟 on 2019/12/17.
//  Copyright © 2019 qimao. All rights reserved.
//

import UIKit

open class YYNestScrollView: UIScrollView {
    open var instanceShouldRecognizeSimultaneously:Bool = true
}

extension YYNestScrollView: UIGestureRecognizerDelegate {
    // 允许同时触发多个手势
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return instanceShouldRecognizeSimultaneously
    }
}
