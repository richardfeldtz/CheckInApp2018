//
//  PageViewController.swift
//  CheckIn
//
//  Created by Alexander Stevens on 1/23/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    
    let pageControl: UIPageControl = {
       let pc = UIPageControl()
        pc.numberOfPages = 2
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .black
        pc.pageIndicatorTintColor = .red
        return pc
    }()
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(name: "CreateEvent"),
                self.newViewController(name: "green")]
    }()
    
    private func newViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "CreateEvent", bundle: nil) .
            instantiateViewController(withIdentifier: "\(name)ViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.addSubview(pageControl)
//        pageControl.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
//            pageControl.widthAnchor.constraint(equalToConstant: 20),
//            pageControl.heightAnchor.constraint(equalToConstant: 50)
//        ])
        
        dataSource = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    
    
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }

        return firstViewControllerIndex
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
}
