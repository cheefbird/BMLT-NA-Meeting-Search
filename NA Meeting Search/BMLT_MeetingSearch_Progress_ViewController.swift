//
//  BMLT_MeetingSearch_Progress_ViewController.swift
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

/* ###################################################################################################################################### */
/**
 This class is the one that controls the "Doing A Search" screen.
 */
class BMLT_MeetingSearch_Progress_ViewController: BMLT_MeetingSearch_Subsequent_ViewController, CLLocationManagerDelegate {
    /// The segue ID we use to bring in the results, when we are done.
    private let _segueID = "show-search-results-seque-id"
    
    // MARK: - Private Instance Properties
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This will hold our location manager.
     */
    private var _locationManager: CLLocationManager! = nil

    // MARK: - Instance Properties
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is set to true if we want to start the search as soon as we appear.
     */
    var startUponAppearance: Bool = false
    
    /* ################################################################## */
    /**
     This is set to true if we are to look up our location first.
     */
    var lookUpLocationFirst: Bool = false
    
    /* ################################################################## */
    /**
     If this is true, then we use the search criteria. If it is false, then we clear the criteria, and juts look for today and tomorrow.
     */
    var useSearchCriteria: Bool = false
    
    /* ################################################################## */
    /**
     If the search was initiated from the map search, this will be set to true.
     */
    var searchWasAMapSearch: Bool = false

    /* ################################################################## */
    /**
     If the search was location-based, then we have the location here.
     */
    var searchLocation: CLLocationCoordinate2D! {
        get {
            return self.criteriaObject.searchLocation
        }
        
        set {
            self.criteriaObject.searchLocation = newValue
        }
    }
    
    /* ################################################################## */
    /**
     If the search was location-based, then we have the location here.
     */
    var formatsUsedForLastSearch: [BMLTiOSLibFormatNode] = []

    // MARK: - IB Properties
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is the big fat button that the user presses.
     */
    @IBOutlet weak var theBigSearchButton: BMLT_MeetingSearch_AnimatedButtonView!
    
    // MARK: - Base Class Overrides
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Called when the view first loads.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.theBigSearchButton.startAnimation()
        self.startUponAppearance = true
   }
    
    /* ################################################################## */
    /**
     Called when the view will appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BMLT_MeetingSearch_AppDelegate.delegateObject.currentSearchWindow = self
        if self.startUponAppearance {
            self.startUponAppearance = false
            self.startSearch()
        } else {
            self.cancelSearch()
        }
    }

    /* ################################################################## */
    /**
     Called when the view will disappear.
     */
    override func viewWillDisappear(_ animated: Bool) {
        BMLT_MeetingSearch_AppDelegate.delegateObject.currentSearchWindow = nil
        super.viewWillDisappear(animated)
    }
    
    /* ################################################################## */
    /**
     Called when we are about to dosee-doh out the door.
     
     - parameter segue: The segue being called.
     - parameter sender: The data we're attaching to the segue (our meeting results).
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == self._segueID {
            if let destination = segue.destination as? BMLT_MeetingSearch_ResultsTabControllerViewController {
                destination.searchResults = (sender as? [BMLTiOSLibMeetingNode])!
                destination.searchLocation = self.searchLocation
                destination.myOwner = self
                self.theBigSearchButton.stopAnimation(endAnimation: false)
            }
        }
    }

    // MARK: - IB Handlers
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is called when the user hits the big button.
     */
    @IBAction func searchButtonHit( _ inSender: UIButton ) {
        self.cancelSearch()
	}

    // MARK: - Internal Instance Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This simply starts the button animation.
     */
    func startSearch() {
        if self.lookUpLocationFirst {
            self.startLookingUpMyLocation()
        } else {
            if !self.useSearchCriteria {
                self.performSimpleLocationSearch(self.searchLocation)
            } else {
                self.performCriteriaLocationSearch(self.searchLocation)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is called after the location of the user has been determined.
     
     - parameter coordinate: The location to start a simple "today and tomorrow" location search.
     */
    func performSimpleLocationSearch(_ coordinate: CLLocationCoordinate2D) {
        self.criteriaObject.clearAll()
        self.searchLocation = coordinate
        
        let date = NSDate()
        let calendar = NSCalendar.current
        let today = calendar.component(.weekday, from: date as Date)
        let tomorrow = (7 > today) ? today + 1 : 1
        
        if let todayIndex = BMLTiOSLibSearchCriteria.WeekdayIndex(rawValue: today) {
            self.criteriaObject.weekdays[todayIndex] = .Selected
        }
        
        if let tomorrowIndex = BMLTiOSLibSearchCriteria.WeekdayIndex(rawValue: tomorrow) {
            self.criteriaObject.weekdays[tomorrowIndex] = .Selected
        }
        
        // We increase the density for this search, as we are likely to throw out meetings (ones that have passed today).
        self.criteriaObject.searchRadius = Float(-1 * Int(ceil(1.5 * Float(self.prefs.autoSearchDensity))))
        self.criteriaObject.performMeetingSearch(.MeetingsOnly)
    }
    
    /* ################################################################## */
    /**
     This is called after the location of the user has been determined.
     
     - parameter coordinate: The location to start a simple "today and tomorrow" location search.
     */
    func performCriteriaLocationSearch(_ coordinate: CLLocationCoordinate2D! = nil) {
        self.searchLocation = coordinate
        self.criteriaObject.performMeetingSearch(.MeetingsOnly)
    }

    /* ################################################################## */
    /**
     This stops any location lookup, and stops the button animation.
     */
    func cancelSearch() {
        self.stopLookingUpMyLocation()
        self.dismiss(animated: true, completion: nil)
    }
    
    /* ################################################################## */
    /**
     This simply starts looking for where the user is at.
     */
    func startLookingUpMyLocation() {
        var goodLoc: Bool = false
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                break
                
            case .notDetermined, .authorizedAlways, .authorizedWhenInUse:
                goodLoc = true
            @unknown default:
                fatalError("WTF, Dude?")
            }
        }
        
        if !goodLoc {
            BMLT_MeetingSearch_AppDelegate.displayAlert("BMLTNAMeetingSearchError-LocationFailHeader", inMessage: "BMLTNAMeetingSearchError-LocationOffText", presentedBy: self)
            self.cancelSearch()
        } else {
            self.searchLocation = nil
            self._locationManager = CLLocationManager()
            self._locationManager.requestWhenInUseAuthorization()
            self._locationManager.delegate = self
            self._locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self._locationManager.startUpdatingLocation()
        }
    }
    
    /* ################################################################## */
    /**
     This stops the location manager lookups.
     */
    func stopLookingUpMyLocation() {
        self.searchLocation = nil
        if nil != self._locationManager {
            self._locationManager.stopUpdatingLocation()
            self._locationManager.delegate = nil
            self._locationManager = nil
        }
    }
    
    /* ################################################################## */
    /**
     This is called when the search is complete.
     
     - parameter inResults: an array of meeting objects.
     */
    func handleSearchResults(_ inResults: [BMLTiOSLibMeetingNode]) {
        #if DEBUG
            print("Meeting Search Results: \(String(describing: inResults))")
        #endif
        
        self.performSegue(withIdentifier: self._segueID, sender: inResults)
    }
    
    /* ################################################################## */
    /**
     This is called when the search is complete.
     
     - parameter inResults: an array of meeting objects.
     */
    func handleSearchResults(_ inResults: [BMLTiOSLibFormatNode]) {
        #if DEBUG
            print("Format Search Results: \(String(describing: inResults))")
        #endif
        
        self.formatsUsedForLastSearch = inResults
    }

    // MARK: Internal CLLocationManagerDelegate Methods
    /* ##################################################################################################################################*/
    /**
     This is called if the location manager suffers a failure.
     
     - parameter manager: The Location Manager object that had the error.
     - parameter didFailWithError: The error in question.
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.stopLookingUpMyLocation()
        DispatchQueue.main.async {
            self.theBigSearchButton.stopAnimation()
            BMLT_MeetingSearch_AppDelegate.displayAlert("BMLTNAMeetingSearchError-LocationFailHeader", inMessage: "BMLTNAMeetingSearchError-LocationFailText")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /* ################################################################## */
    /**
     Callback to handle found locations.
     
     - parameter manager: The Location Manager object that had the event.
     - parameter didUpdateLocations: an array of updated locations.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if 0 < locations.count {
            for i in 0..<locations.count {
                let location = locations[i]
                
                // Ignore cached locations. Wait for the real.
                if 1.0 > location.timestamp.timeIntervalSinceNow {
                    self.stopLookingUpMyLocation()
                    if !self.useSearchCriteria {
                        self.performSimpleLocationSearch(locations[0].coordinate)
                    } else {
                        self.performCriteriaLocationSearch(locations[0].coordinate)
                    }
                }
            }
        }
    }
}
