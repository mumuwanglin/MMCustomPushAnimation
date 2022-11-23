//
//  QMAnimatinManager.swift
//  PushDemo
//
//  Created by mumu on 2022/11/1.
//

import UIKit

public class QMAnimatinManager: NSObject {
    
    public static let shared = QMAnimatinManager()
    
    private var animators: [String: QMAnimatorProtocol] = [:]
    
    // 存储动画器
    func addAnimtor(animator: QMAnimatorProtocol, viewController: UIViewController) {
        let key = key(viewController)
        viewController.animatorKey = key
        animators[key] = animator
    }
    
    // 获取动画器
    func animtor(for viewController: UIViewController) -> QMAnimatorProtocol? {
        let key = key(viewController)
        return animators[key]
    }
    
    // 移除动画器
    func removeAnimator(viewController: UIViewController) {
        let key = key(viewController)
        animators[key] = nil
    }
    
    func key(_ viewController: UIViewController) -> String {
        return "\(viewController.classForCoder)"
    }
}


// MARK: - UINavigationControllerDelegate
extension QMAnimatinManager: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let key = fromVC.animatorKey else { return nil }
        let animator = animators[key]
        animator?.operation = operation        
        return animator
    }

    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let animator = animationController as? QMAnimatorProtocol, let interactiveTransition =  animator.interactiveTransition as? QMPercentDrivenInteractiveTransition {
            return interactiveTransition.isInteracting ? interactiveTransition : nil
        }
        return nil
    }
}

fileprivate var QMAnimatorkey = "QMAnimatorkey"
public extension UIViewController {
    
    var animatorKey: String? {
        set {
            objc_setAssociatedObject(self, &QMAnimatorkey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &QMAnimatorkey) as? String
        }
    }
    
    // 使用自定义动画控制器
    func pushViewController(_ viewController: UIViewController, animator: QMAnimatorProtocol) {
        QMAnimatinManager.shared.addAnimtor(animator: animator, viewController: self)
        self.navigationController?.delegate = QMAnimatinManager.shared
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // 使用默认的动画配置
    func pushViewController(_ viewController: UIViewController, direction: QMDirection) {
        let animator = QMSwipeAnimator()
        animator.direction = direction
        pushViewController(viewController, animator: animator)
    }
    
    // 注册手势
    func registerInteractiveTransition(animator: QMAnimatorProtocol) {
        let interactiveTransition = QMPercentDrivenInteractiveTransition(viewController: self)
        interactiveTransition.direction = animator.direction
        interactiveTransition.addDownSwipeUpGesture()
        interactiveTransition.addEdgePanUpGesture()
        animator.interactiveTransition = interactiveTransition
    }
}
