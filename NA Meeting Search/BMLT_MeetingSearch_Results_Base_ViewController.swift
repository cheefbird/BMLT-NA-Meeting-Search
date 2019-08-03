//
//  BMLT_MeetingSearch_ListResults_ViewController.swift
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
import MapKit
import BMLTiOSLib

/* ######################################################################################################################################*/
/**
 This is a base class for the results screens.
 */
class BMLT_MeetingSearch_Results_Base_ViewController: BMLT_MeetingSearch_RootViewController {
    // MARK: IB Properties
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is the navigation bar object.
     */
    @IBOutlet weak var myNavigationBar: UINavigationBar!
    
    // MARK: Instance Properties
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     If the search was location-based, then we have the location here.
     */
    var searchLocation: CLLocationCoordinate2D! = nil
    
    // MARK: IB Handler Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Reacts to the NavBar "Done" button being hit.
     */
    @IBAction func doneButtonHit(_ sender: Any) {
        if let tabBarController = self.tabBarController as? BMLT_MeetingSearch_ResultsTabControllerViewController {
            tabBarController.myOwner.cancelSearch()
        }
    }
    
    /* ################################################################## */
    /**
     Reacts to the NavBar "Action" button being hit.
     
     - parameter sender: The IB Object that called this (the action button -ignored).
     */
    @IBAction func actionButtonHit(_ sender: Any) {
    }

    // MARK: - Base Class Override Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Called when the view is loaded. We set the localized string for the label here.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myNavigationBar.barTintColor = self.gradientTopColor
    }
}
