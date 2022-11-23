//
//  ViewController.swift
//  PushDemo
//
//  Created by mumu on 2022/10/18.
//

import UIKit

// MARK: - Source
class ViewController: UIViewController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pushAction(_ sender: Any) {
        let tv = TargetVC()
        
        let animator = QMSwipeAnimator()
        animator.useBackground = true
        animator.direction = .left
        self.pushViewController(tv, animator: animator)
    }
}

// MARK: - TARGET
class TargetVC: UIViewController, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    private var animator: QMPercentDrivenInteractiveTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        let animator = QMSwipeAnimator()
        animator.direction = .left
        animator.useBackground = true
        self.registerInteractiveTransition(animator: animator)
        QMAnimatinManager.shared.addAnimtor(animator: animator, viewController: self)
        self.navigationController?.delegate = QMAnimatinManager.shared
    }
    
    
    func setupView() {
        // 设置背景色
        self.view.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        
        let tv = UIView()
        tv.backgroundColor = .red
        tv.frame = CGRect(x: 0, y: UIScreen.main.bounds.height/2, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
        self.view.addSubview(tv)
        
        let scrollView = YYNestScrollView()
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
        scrollView.backgroundColor = .darkGray
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 2)
        tv.addSubview(scrollView)
    }
    
    deinit {
        debugPrint("\(Self.classForCoder()): \(#function)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let nestScrollView = scrollView as? YYNestScrollView
        // 管理状态不允许下拉刷新
        if offsetY <= 0 {
            nestScrollView?.instanceShouldRecognizeSimultaneously = true
            scrollView.contentOffset = .zero
            return
        } else {
            nestScrollView?.instanceShouldRecognizeSimultaneously = false
        }
    }
}
