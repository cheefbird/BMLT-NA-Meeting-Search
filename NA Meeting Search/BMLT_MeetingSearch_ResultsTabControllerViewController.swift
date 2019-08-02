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
import BMLTiOSLib
import MapKit

/* ###################################################################################################################################### */
/**
 This is a tab controller class for the tab controller that displays the two results root screens.
 */
class BMLT_MeetingSearch_ResultsTabControllerViewController: UITabBarController {
    // MARK: - Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     These are direct links to our controllers.
     */
    /// The list view View Controller
    var listViewController: BMLT_MeetingSearch_ListResults_ViewController! = nil
    /// The map view View Controller
    var mapViewController: BMLT_MeetingSearch_MapResults_ViewController! = nil
    
    /* ################################################################## */
    /**
     This is the progress view controller that "owns," this.
     */
    var myOwner: BMLT_MeetingSearch_Progress_ViewController! = nil

    /* ################################################################## */
    /**
     This will contain any relevant search results.
     */
    var searchResults: [BMLTiOSLibMeetingNode] = []
    
    /* ################################################################## */
    /**
     This will contain any relevant format results.
     */
    var formatResults: [BMLTiOSLibFormatNode] = []

    /* ################################################################## */
    /**
     If the search was location-based, then we have the location here.
     */
    var searchLocation: CLLocationCoordinate2D! = nil
    
    /* ################################################################## */
    /**
     If the search was initiated from the map search, this will be set to true.
     */
    var searchWasAMapSearch: Bool {
        return self.myOwner?.searchWasAMapSearch ?? false
    }

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
                if let controller = theController as? BMLT_MeetingSearch_RootViewController {
                    if let listViewController = controller as? BMLT_MeetingSearch_ListResults_ViewController {
                        listViewController.searchResults = self.searchResults
                        listViewController.searchLocation = self.searchLocation
                        self.listViewController = listViewController
                    } else {
                        if let mapViewController = controller as? BMLT_MeetingSearch_MapResults_ViewController {
                            mapViewController.searchResults = self.searchResults
                            mapViewController.searchLocation = self.searchLocation
                            self.mapViewController = mapViewController
                        }
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when the view is about to appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // If this was called from the location/map search, our initial view is the map, as opposed to the list.
        if self.searchWasAMapSearch {
            self.selectedViewController = self.mapViewController
        }
    }
}
