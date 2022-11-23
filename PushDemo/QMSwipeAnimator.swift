//
//  QMSwipeAnimator.swift
//  PushDemo
//
//  Created by mumu on 2022/11/2.
//

import UIKit

class QMBGView: UIView {
    static func findBGView(view: UIView) -> UIView? {
        for subView in view.subviews {
            if subView is QMBGView {
                return subView
            }
        }
        return nil
    }
}

class QMSwipeAnimator: NSObject, QMAnimatorProtocol {
    
    var transitionDuration: TimeInterval = 0.25
    
    var operation: QMOperation = .push
    
    var direction: QMDirection = .bottom
    
    var useBackground: Bool = false
    
    var interactiveTransition: UIPercentDrivenInteractiveTransition?
    
    // 遮盖的 View
    private lazy var bgView: QMBGView = {
        let tmp = QMBGView()
        tmp.frame = CGRect(x: -UIScreen.main.bounds.width, y: -UIScreen.main.bounds.height, width: UIScreen.main.bounds.width * 3, height: UIScreen.main.bounds.height * 3)
        return tmp
    }()
    
    deinit {
        debugPrint("\(Self.classForCoder()): \(#function)")
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if operation == .push {
            pushTransition(using: transitionContext)
        } else if operation == .pop {
            popTransition(using: transitionContext)
        } else {
            return
        }
    }
    
    private func pushTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let finalFrame = transitionContext.finalFrame(for: toVC)
        let containerView = transitionContext.containerView
                
        guard let snapshot = fromView.snapshotView(afterScreenUpdates: true) else { return }
                
        containerView.addSubview(toView)
        
        useBackground ? toView.insertSubview(bgView, at: 0) : nil
        useBackground ? bgView.backgroundColor = toView.backgroundColor : nil
        useBackground ? bgView.alpha = 0.0 : nil
        
        toView.backgroundColor = .clear
        
        var beginFrame = CGRect(x: 0, y: finalFrame.height, width: finalFrame.width, height: finalFrame.height)
        switch direction {
        case .top:
            beginFrame = CGRect(x: 0, y: -finalFrame.height, width: finalFrame.width, height: finalFrame.height)
        case .right:
            beginFrame = CGRect(x: finalFrame.width, y: 0, width: finalFrame.width, height: finalFrame.height)
        case .bottom:
            break
        case .left:
            beginFrame = CGRect(x: -finalFrame.width, y: 0, width: finalFrame.width, height: finalFrame.height)
        }
        
        toView.frame = beginFrame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            toView.frame = finalFrame
            self.useBackground ? self.bgView.alpha = 1  : nil
        } completion: { _ in
            toView.insertSubview(snapshot, at: 0)
            toView.insertSubview(self.bgView, at: 1)
            if !transitionContext.transitionWasCancelled {
                QMAnimatinManager.shared.removeAnimator(viewController: fromVC)
                fromVC.animatorKey = nil
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    private func popTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let finalFrame = transitionContext.finalFrame(for: toVC)
        let containerView = transitionContext.containerView
                
        let fromViewFirstSubviews = fromView.subviews.first
        fromViewFirstSubviews?.removeFromSuperview()
        
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        
        let bgView = QMBGView.findBGView(view: fromView)
        useBackground ? (bgView?.alpha = 1.0) : nil
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            self.useBackground ? bgView?.alpha = 0.0 : nil
            var endFrame = CGRect(x: 0, y: finalFrame.height, width: finalFrame.width, height: finalFrame.height)
            switch self.direction {
            case .top:
                endFrame = CGRect(x: 0, y: -finalFrame.height, width: finalFrame.width, height: finalFrame.height)
            case .right:
                endFrame = CGRect(x: finalFrame.width, y: 0, width: finalFrame.width, height: finalFrame.height)
            case .bottom:
                break
            case .left:
                endFrame = CGRect(x: -finalFrame.width, y: 0, width: finalFrame.width, height: finalFrame.height)
            }
            fromView.frame = endFrame
        } completion: { _ in
            fromView.isHidden = false
            if transitionContext.transitionWasCancelled {
                fromView.insertSubview(fromViewFirstSubviews!, at: 0)
            }
            if !transitionContext.transitionWasCancelled {
                QMAnimatinManager.shared.removeAnimator(viewController: fromVC)
                fromVC.animatorKey = nil
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}


