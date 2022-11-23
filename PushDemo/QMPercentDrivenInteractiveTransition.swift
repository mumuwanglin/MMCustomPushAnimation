//
//  QMPercentDrivenInteractiveTransition.swift
//  PushDemo
//
//  Created by mumu on 2022/11/2.
//

import UIKit

/// 控制动画的比例控制
class QMPercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    // 控制 NavigationBar 返回按钮
    var isInteracting = false
    
    var direction: QMDirection = .bottom
    
    /// 交互手势发生的视图控制器
    private var viewController: UIViewController?
    
    private var scrollView: UIScrollView? {
        var result: UIScrollView? = nil
        viewController?.view.subviews.forEach({ view in
            if let tempView = view as? UIScrollView {
                result = tempView
            }
        })
        return result
    }
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()        
    }
    
    deinit {
        debugPrint("\(Self.classForCoder()): \(#function)")
    }
    
    // MARK: - UIGestureRecognizer
    // 注册下滑手势
    func addDownSwipeUpGesture() {
        // 下滑手势
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(downHandleGesture(_:)))
        viewController?.view.addGestureRecognizer(gestureRecognizer)
    }
    // 注册侧滑手势
    func addEdgePanUpGesture() {
        let gestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.edgePanHandleGesture(_:)))
        gestureRecognizer.edges = .left
        viewController?.view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func downHandleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        let translation = gestureRecognizer.translation(in: view)
        
        var fraction: CGFloat = 0
        var speed: CGFloat = 0
        
        switch direction {
        case .top:
            fraction = translation.y / (viewController?.view.bounds.size.height ?? 0)
            speed = gestureRecognizer.velocity(in: view).y
        case .right:
            fraction = translation.x / (viewController?.view.bounds.size.width ?? 0)
            speed = gestureRecognizer.velocity(in: view).x
        case .bottom:
            fraction = translation.y / (viewController?.view.bounds.size.height ?? 0)
            speed = gestureRecognizer.velocity(in: view).y
        case .left:
            fraction = translation.x / (viewController?.view.bounds.size.width ?? 0)
            speed = gestureRecognizer.velocity(in: view).x
        }        
        
        switch gestureRecognizer.state {
        case .began:
            isInteracting = true
            viewController?.navigationController?.popViewController(animated: true)
        case .changed:
            // 解决手势往上时与scrollview产生的手势冲突
            fraction > 0 ? (scrollView?.isScrollEnabled = false) : (scrollView?.isScrollEnabled = true)
            switch direction {
            case .top, .left:
                guard fraction < 0 else { return }
            case .right, .bottom:
                guard fraction > 0 else { return }
            }
            update(abs(fraction))
        case .cancelled:
            isInteracting = false
            cancel()
        case .ended:
            isInteracting = false
            switch direction {
            case .top, .left:
                if speed < -920 {
                    finish()
                    return
                }
                if fraction < 0, abs(fraction) > 0.3 {
                    finish()
                } else {
                    cancel()
                }
            case .right, .bottom:
                if fraction > 920 {
                    finish()
                    return
                }
                if fraction > 0, abs(fraction) > 0.3 {
                    finish()
                } else {
                    cancel()
                }
            }
        default:
            break
        }
    }
    
    @objc private func edgePanHandleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        let fraction = abs(gestureRecognizer.translation(in: gestureRecognizer.view).x / (view.bounds.size.height))
        
        switch gestureRecognizer.state {
        case .began:
            isInteracting = true
            viewController?.navigationController?.popViewController(animated: true)
        case .changed:
            self.update(fraction)
        case .cancelled:
            isInteracting = false
            self.cancel()
        case .ended:
            isInteracting = false
            if fraction > 0.3 {
                self.finish()
            } else {
                self.cancel()
            }
        default:
            break
        }
    }
}
