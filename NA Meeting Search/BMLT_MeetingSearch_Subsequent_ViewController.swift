//
//  BMLT_MeetingSearch_Subsequent_ViewController.swift
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
