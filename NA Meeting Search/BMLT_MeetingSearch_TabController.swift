//
//  BMLT_MeetingSearch_TabController.swift
//  NA Meeting Search
//
//  Created by MAGSHARE
//
//  This is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  BMLT is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this code.  If not, see <http://www.gnu.org/licenses/>.

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
