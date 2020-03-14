//
//  BMLT_MeetingSearch_AppDelegate.swift
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

// MARK: - Classes -
/* ######################################################################################################################################*/
/**
 This is the main App Delegate class for the NA Meeting Search App.
 This also catches messages from the BMLTiOSLib instance.
 */
@UIApplicationMain
class BMLT_MeetingSearch_AppDelegate: UIResponder, UIApplicationDelegate, BMLTiOSLibDelegate {
    // MARK: Class Calculated Variables
    /* ##################################################################################################################################*/
    /**
     This returns the application delegate object.
     */
    class var delegateObject: BMLT_MeetingSearch_AppDelegate {
        return (UIApplication.shared.delegate as? BMLT_MeetingSearch_AppDelegate)!
    }
    
    // MARK: Internal Instance Variables
    /* ##################################################################################################################################*/
    /**
     This is the app window.
     */
    var window: UIWindow?
    
    /**
     This is our main tab controller.
     */
    var mainTabController: BMLT_MeetingSearch_TabController! = nil {
        didSet {    // When we set it, that triggers a setup of the BMLTiOSLib object.
            self._setUpBMLTiOSLibInstance()
        }
    }
    
    /**
     This is whatever search is under way.
     */
    var currentSearchWindow: BMLT_MeetingSearch_Progress_ViewController! = nil

    // MARK: Private Instance Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Set up a new BMLTiOSLib instance
     */
    private func _setUpBMLTiOSLibInstance() {
        BMLT_MeetingSearch_Prefs.prefs.commObject = BMLTiOSLib(inRootServerURI: BMLT_MeetingSearch_Prefs.prefs.rootURI, inDelegate: self)
    }
    
    // MARK: Class Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Displays the given error in an alert with an "OK" button.
     
     - parameter inTitle: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter inMessage: a string to be displayed as the message of the alert. It is localized by this method.
     - parameter presentedBy: An optional UIViewController object that is acting as the presenter context for the alert. If nil (or not provided), we use the top controller of the current Navigation stack.
     */
    class func displayAlert(_ inTitle: String, inMessage: String, presentedBy inPresentingViewController: UIViewController! = nil ) {
        DispatchQueue.main.async {
            var presentedBy = inPresentingViewController
            
            if nil == presentedBy {
                if let navController = self.delegateObject.window?.rootViewController as? UINavigationController {
                    presentedBy = navController.topViewController
                } else {
                    if let tabController = self.delegateObject.window?.rootViewController as? UITabBarController {
                        if let navController = tabController.selectedViewController as? UINavigationController {
                            presentedBy = navController.topViewController
                        } else {
                            presentedBy = tabController.selectedViewController
                        }
                    } else {
                        presentedBy = self.delegateObject.window?.rootViewController
                    }
                }
            }
            
            if nil != presentedBy {
                let alertController = UIAlertController(title: inTitle.localizedVariant, message: inMessage.localizedVariant, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "BASIC-OK-BUTTON".localizedVariant, style: UIAlertAction.Style.cancel, handler: nil)
                
                alertController.addAction(okAction)
                
                presentedBy?.present(alertController, animated: true, completion: nil)
            }
        }
    }

    // MARK: UIApplicationDelegate Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     The call made just after the application has loaded everything up, and is ready to begin.
     
     - parameter application: The application object that "owns" this delegate.
     - parameter launchOptions: A Dictionary of launch options.
     
     - returns: True, if the app is to start. If false, then the startup is aborted.
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    // MARK: BMLTiOSLibDelegate Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Indicates whether or not the server pointed to via the URI is a valid server (the connection was successful).
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter serverIsValid: A Bool, true, if the server was successfully connected. If false, you must reinstantiate BMLTiOSLib. You can't re-use the same instance.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, serverIsValid: Bool) {
        if serverIsValid {
            if nil != self.mainTabController {
                self.mainTabController.commObjectReady()
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called if there is an error.
     
     The error String will be a key for localization, and will be pretty much worthless on its own.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter error: The error that occurred.s
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, errorOccurred error: Error) {
        BMLT_MeetingSearch_Prefs.prefs.commObject = nil
        if nil != self.mainTabController {
            self.mainTabController.commObjectNotReady()
        }
        type(of: self).displayAlert("BMLTNAMeetingSearchError-CommErrorHeader".localizedVariant, inMessage: "BMLTNAMeetingSearchError-CommErrorText".localizedVariant)
    }
    
    /* ################################################################## */
    /**
     Returns the result of a meeting search.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter meetingSearchResults: An array of meeting objects, representing the results of a search.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, meetingSearchResults: [BMLTiOSLibMeetingNode]) {
        if nil != self.currentSearchWindow {
            // After we fetch all the results, we then sort through them, and remove ones that have already passed today (We leave tomorrow alone).
            var finalResults: [BMLTiOSLibMeetingNode] = []
            // In the case of a simple "today and tomorrow" search, we filter for today and tomorrow.
            if !self.currentSearchWindow.useSearchCriteria {
                let calendar = NSCalendar.current
                let today = calendar.component(.weekday, from: Date())
                var hour = calendar.component(.hour, from: Date())
                var minute = calendar.component(.minute, from: Date())
                
                // Get the grace period.
                let tempHourMinutes = (hour * 60) + minute + BMLT_MeetingSearch_Prefs.prefs.gracePeriodInMinutes
                hour = Int(tempHourMinutes / 60)
                minute = Int(tempHourMinutes - (hour * 60))
                
                // This is "right now" (including the effects of Grace Time).
                let startingTime = DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: hour, minute: minute, second: 0, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
                
                // Build up an array of ones that pass muster. We don't include ones that fail our "right now" test.
                for meeting in meetingSearchResults {
                    if (meeting.weekdayIndex != today) || meeting.meetingStartsOnOrAfterThisTime(startingTime as NSDateComponents) {
                        finalResults.append(meeting)
                    }
                }
            } else {
                finalResults = meetingSearchResults
            }
            
            if 0 < finalResults.count {
                self.currentSearchWindow.handleSearchResults(finalResults)
            } else {
                type(of: self).displayAlert("BMLTNAMeetingSearchError-NoResultsHeader", inMessage: "BMLTNAMeetingSearchError-NoResultsText", presentedBy: self.currentSearchWindow)
                self.currentSearchWindow.dismiss(animated: true, completion: nil)
            }
        } else {
            if 0 == meetingSearchResults.count {
                type(of: self).displayAlert("BMLTNAMeetingSearchError-NoResultsHeader", inMessage: "BMLTNAMeetingSearchError-NoResultsText")
            }
        }
    }
}
