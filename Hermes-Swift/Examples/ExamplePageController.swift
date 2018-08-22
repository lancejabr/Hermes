//
//  ExamplePageController.swift
//  Hermes-Swift
//
//  Created by Lance Jabr on 11/12/14.
//  Copyright (c) 2014 Lance Jabr. All rights reserved.
//

import UIKit

let resourcePath = Bundle.main.resourcePath!

class ExamplePageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let player = HermesPlayer()
    
    var examples = [UIViewController]()
    
    override func viewDidLoad() {
        
        delegate = self
        dataSource = self
        
        let storyB = UIStoryboard(name: "Main", bundle: nil)
        
        examples.append(storyB.instantiateViewController(withIdentifier: "Now Listen Here") as UIViewController)
        examples.append(storyB.instantiateViewController(withIdentifier: "Chopper") as UIViewController)
        examples.append(storyB.instantiateViewController(withIdentifier: "Money Sings") as UIViewController)

        
        setViewControllers([examples.first!], direction: .forward, animated: false) {finished in }
    }
    

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        for (i, currVC) in examples.enumerated() {
            if currVC === viewController {
                return i == 0 ? nil : examples[i-1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        for (i, currVC) in examples.enumerated() {
            if currVC === viewController {
                return i == examples.count-1 ? nil : examples[i+1]
            }
        }
        return nil
    }
    
}
