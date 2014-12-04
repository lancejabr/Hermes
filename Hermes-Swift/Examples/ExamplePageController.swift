//
//  ExamplePageController.swift
//  Hermes-Swift
//
//  Created by Lance Jabr on 11/12/14.
//  Copyright (c) 2014 Lance Jabr. All rights reserved.
//

import UIKit

let resourcePath = NSBundle.mainBundle().resourcePath!

class ExamplePageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let player = HermesPlayer()
    
    var examples = [UIViewController]()
    
    override func viewDidLoad() {
        
        delegate = self
        dataSource = self
        
        let storyB = UIStoryboard(name: "Main", bundle: nil)
        
        examples.append(storyB.instantiateViewControllerWithIdentifier("Now Listen Here") as UIViewController)
        examples.append(storyB.instantiateViewControllerWithIdentifier("Chopper") as UIViewController)
        
        setViewControllers([examples.first!], direction: .Forward, animated: false) {finished in }
    }
    

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        for (i, currVC) in enumerate(examples) {
            if currVC === viewController {
                return i == 0 ? nil : examples[i-1]
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        for (i, currVC) in enumerate(examples) {
            if currVC === viewController {
                return i == examples.count-1 ? nil : examples[i+1]
            }
        }
        return nil
    }
    
}
