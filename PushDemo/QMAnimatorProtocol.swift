//
//  QMAnimatorProtocol.swift
//  PushDemo
//
//  Created by mumu on 2022/11/1.
//

import UIKit

public enum QMDirection {
    case top
    case right
    case bottom
    case left
}

public typealias QMOperation = UINavigationController.Operation

public protocol QMAnimatorProtocol: UIViewControllerAnimatedTransitioning {
    /// 动画时间(默认值：0.25s，最小值必须大于0.01f)
    var transitionDuration: TimeInterval { get set }
    /// 设置Pop/present侧滑交互的方向
    var operation: QMOperation { get set }
    /// 动画百分比控制器
    var interactiveTransition: UIPercentDrivenInteractiveTransition? { get set }    
    /// Pop侧滑交互的方向。
    var direction: QMDirection { get set }

    /// 是否使用背景色
    var useBackground: Bool { get set }
//    /// 动画完成多少百分比后，直接完成转场（默认：0 表示不启用）--> (0 ，1]
//    func percentOfFinished()
//    /// 用来调节完成完成百分比，数值越大越快（默认：0，小于0.2 表示不启用）
//    func speedOfPercent()
}
