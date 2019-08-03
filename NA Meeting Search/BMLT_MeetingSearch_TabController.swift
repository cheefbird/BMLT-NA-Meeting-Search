//
//  BMLT_MeetingSearch_TabController.swift
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

/* ###################################################################################################################################### */
/**
 This class manages the "first tier" Tab Controller instance.
 */
class BMLT_MeetingSearch_TabController: UITabBarController {
    // MARK: - Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     These are direct links to our controllers.
     */
    /// The first tab (Meetings Today)
    var todayController: BMLT_MeetingSearch_Today_ViewController! = nil
    /// The second tab (Basic search)
    var basicSearchController: BMLT_MeetingSearch_Basic_ViewController! = nil
    /// The third tab (Location Search)
    var advancedSearchController: BMLT_MeetingSearch_Location_Search_ViewController! = nil
    /// The fourth tab (Settings and Info)
    var settingsViewController: BMLT_MeetingSearch_Settings_ViewController! = nil

    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.unselectedItemTintColor = self.tabBar.tintColor.withAlphaComponent(0.5)
        
        if let controllers = self.viewControllers {
            for theController in controllers {
                theController.tabBarItem.title = theController.tabBarItem.title?.localizedVariant
                if let navController = theController as? BMLT_MeetingSearch_Basic_NavigationController {
                    if let controller = navController.viewControllers[0] as? BMLT_MeetingSearch_RootViewController {
                        if let todayController = controller as? BMLT_MeetingSearch_Today_ViewController {
                            self.todayController = todayController
                        } else {
                            if let basicSearchController = controller as? BMLT_MeetingSearch_Basic_ViewController {
                                self.basicSearchController = basicSearchController
                            } else {
                                if let advancedSearchController = controller as? BMLT_MeetingSearch_Location_Search_ViewController {
                                    self.advancedSearchController = advancedSearchController
                                } else {
                                    if let settingsViewController = controller as? BMLT_MeetingSearch_Settings_ViewController {
                                        self.settingsViewController = settingsViewController
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        BMLT_MeetingSearch_AppDelegate.delegateObject.mainTabController = self
    }
    
    // MARK: - Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the comm object is ready.
     */
    func commObjectReady() {
        if nil != self.todayController {
            self.todayController.navigationController?.tabBarItem.isEnabled = true
            self.todayController.theBigSearchButton.stopAnimation()
            self.todayController.theBigSearchButton.isUserInteractionEnabled = true
            self.todayController.theActivityView.isHidden = true
            self.todayController.thePromptView.isHidden = true
            self.todayController.theBigSearchButton.showMeGray = false
        }
        
        if nil != self.basicSearchController {
            self.basicSearchController.navigationController?.tabBarItem.isEnabled = true
        }
        
        if nil != self.advancedSearchController {
            self.advancedSearchController.navigationController?.tabBarItem.isEnabled = true
        }
    }
    
    /* ################################################################## */
    /**
     Called when the comm object is NOT ready.
     */
    func commObjectNotReady() {
        if nil != self.todayController {
            self.todayController.navigationController?.tabBarItem.isEnabled = true
            self.todayController.theBigSearchButton.stopAnimation()
            self.todayController.theBigSearchButton.isUserInteractionEnabled = true
            self.todayController.theActivityView.isHidden = true
            self.todayController.thePromptView.isHidden = true
            self.todayController.theBigSearchButton.showMeGray = true
        }
    }
}
