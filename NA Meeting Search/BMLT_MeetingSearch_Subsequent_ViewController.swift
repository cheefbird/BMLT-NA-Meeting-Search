//
//  BMLT_MeetingSearch_Subsequent_ViewController.swift
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

/* ######################################################################################################################################*/
/**
 This class defines ones that are pushed in modally over tab roots.
 */
class BMLT_MeetingSearch_Subsequent_ViewController: BMLT_MeetingSearch_RootViewController {
    // MARK: - Base Class Override Methods
    /* #################################################################################################################################*/
    /* ################################################################## */
    /**
     Called when the view has loaded its resources.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // We act as modal. No swipes, no tab bar.
        self.swipeLeftGestureRecognizer = nil
        self.swipeRightGestureRecognizer = nil
        self.myTabBarIndex = -1
    }
    
    /* ################################################################## */
    /**
     Called when the view is about to appear.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // We act as a modal navigation page (the reverse of the superclass). We have a visible navbar, and a hidden tabbar.
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
    }
}
