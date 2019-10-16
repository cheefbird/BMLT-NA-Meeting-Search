//
//  BMLT_MeetingSearch_RootViewController.swift
//  NA Meeting Search
//
//  Created by BMLT-Enabled
//
//  https://bmlt.app/
//
//  This software is licensed under the MIT License.
//  Copyright (c) 2017 BMLT-Enabled
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import BMLTiOSLib

/* ######################################################################################################################################*/
/**
 This class handles a basic structure for all our screens.
 */
@IBDesignable class BMLT_MeetingSearch_RootViewController: UIViewController {
    // MARK: - IB Properties
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is the top (initial) color of the background gradient.
     */
    @IBInspectable var gradientTopColor: UIColor = UIColor.black
    
    /* ################################################################## */
    /**
     This is the bottom (final) color of the background gradient.
     */
    @IBInspectable var gradientBottomColor: UIColor = UIColor.darkGray
    
    // MARK: - Instance Fixed Properties
    /* #################################################################################################################################*/
    /* ################################################################## */
    /**
     This is a gradient that is displayed across the background, from top to bottom, using the two colors specified in the IB properties.
     */
    let gradientLayer = CAGradientLayer()
    
    // MARK: - Instance Variable Properties
    /* #################################################################################################################################*/
    /* ################################################################## */
    /**
     This is a gesture recognizer that allows us to swipe to the next page.
     */
    var swipeLeftGestureRecognizer: UISwipeGestureRecognizer! = nil
    /* ################################################################## */
    /**
     This is a gesture recognizer that allows us to swipe to the previous page.
     */
    var swipeRightGestureRecognizer: UISwipeGestureRecognizer! = nil
    /* ################################################################## */
    /**
     This is a gesture recognizer that allows us to dismiss text keyboards.
     */
    var tappedInBackgroundGestureRecognizer: UITapGestureRecognizer! = nil
    /* ################################################################## */
    /**
     This is a shortcut to our tab controller, allowing us to easily access its functionality.
     */
    var myTabBarController: BMLT_MeetingSearch_TabController! = nil
    /* ################################################################## */
    /**
     This is the index of our Navigation Controller within the tab bar.
     */
    var myTabBarIndex: Int = -1
    
    /* ################################################################## */
    /**
     This will contain any relevant search results.
     */
    var searchResults: [BMLTiOSLibMeetingNode] = []

    // MARK: Internal Calculated Variables
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is just a handy accessor for the static prefs object.
     */
    var prefs: BMLT_MeetingSearch_Prefs {
        return BMLT_MeetingSearch_Prefs.prefs
    }
    
    /* ################################################################## */
    /**
     This is just a handy accessor for the comm object.
     */
    var commObject: BMLTiOSLib! {
        if let commObject = self.prefs.commObject {
            return commObject
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This is just a handy accessor for the comm object search criteria object.
     */
    var criteriaObject: BMLTiOSLibSearchCriteria! {
        if let searchCriteria = self.commObject.searchCriteria {
            return searchCriteria
        }
        
        return nil
    }

    // MARK: - Base Class Override Methods
    /* #################################################################################################################################*/
    /* ################################################################## */
    /**
     Called when the view has loaded its resources.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        // The first thing we do is find out which index we are in the tab controller, and keep that handy.
        if let tabController = self.tabBarController as? BMLT_MeetingSearch_TabController {
            self.myTabBarController = tabController
            
            var index = 0
            
            for controller in tabController.viewControllers! {
                // Remember that each of our controllers is actually a Navigation controller, so we are the root controller.
                if controller == self.navigationController {
                    self.myTabBarIndex = index
                    break
                }
                
                index += 1
            }
        }
        
        // Next, we set up the background gradient, as per our colors.
        self.gradientLayer.colors = [self.gradientTopColor.cgColor, self.gradientBottomColor.cgColor]
        self.gradientLayer.locations = [0.0, 1.0]
        
        self.view.layer.sublayers?.insert(self.gradientLayer, at: 0)

        // Finally, we set up the two swipe gesture recognizers we'll use to select our tabs.
        self.swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        self.swipeLeftGestureRecognizer.direction = .left
        self.view.addGestureRecognizer(self.swipeLeftGestureRecognizer)
        
        self.swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        self.swipeRightGestureRecognizer.direction = .right
        self.view.addGestureRecognizer(self.swipeRightGestureRecognizer)
        
        self.tappedInBackgroundGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedInBackground(_:)))
        self.view.addGestureRecognizer(self.tappedInBackgroundGestureRecognizer)
    }
    
    /* ################################################################## */
    /**
     Called when the layout is changed.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradientLayer.frame = self.view.bounds
    }
    
    /* ################################################################## */
    /**
     Called when the view is about to appear.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // We act as a modeless tab page. We have a hidden navbar, and a visible tabbar.
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
   }
    
    // MARK: - Gesture Recognizer Callback Methods
    /* #################################################################################################################################*/
    /* ################################################################## */
    /**
     Called when we want to select the previous page.
     
     - parameter sender: The gesture recognizer for this callback.
     */
    @objc func swipeRight(_ sender: UISwipeGestureRecognizer) {
        if let tabController = self.tabBarController {
            var index = self.myTabBarIndex - 1
            if 0 <= index {
                if let viewControllers = tabController.viewControllers {
                    for vc in viewControllers {
                        if vc.navigationController?.tabBarItem.isEnabled ?? false {
                            break
                        } else {
                            index -= 1
                        }
                    }
                    
                    if (0..<viewControllers.count).contains(index) {
                        tabController.selectedViewController = tabController.viewControllers?[index]
                    }
                }
            }
        }
    }

    /* ################################################################## */
    /**
     Called when we want to select the next page.
     
     - parameter sender: The gesture recognizer for this callback.
     */
    @objc func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        if let tabController = self.tabBarController {
            var index = self.myTabBarIndex + 1
            if  let viewControllers = tabController.viewControllers,
                viewControllers.count > index {
                for vc in viewControllers {
                    if vc.navigationController?.tabBarItem.isEnabled ?? false {
                        break
                    } else {
                        index += 1
                    }
                }
                    
                if (0..<viewControllers.count).contains(index) {
                    tabController.selectedViewController = tabController.viewControllers?[index]
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when there was a tap in the background.
     
     - parameter _: ignored Can be empty.
     */
    @objc func tappedInBackground( _ : Any! = nil) {
        if let responder = self.view.currentFirstResponder {
            if responder is UITextField {
                responder.resignFirstResponder()
            }
        }
    }
}
