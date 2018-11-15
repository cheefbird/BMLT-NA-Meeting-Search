//
//  BMLT_MeetingSearch_ListResults_ViewController.swift
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
