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
