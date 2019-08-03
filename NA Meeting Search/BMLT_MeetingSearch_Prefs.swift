//
//  BMLT_MeetingSearch_Prefs.swift
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
//

import UIKit
import BMLTiOSLib

/* ###################################################################################################################################### */
/**
 This is a simple convenience calculated variable for strings. It gives us a localized variant.
 */
extension String {
    /* ################################################################## */
    /**
     - returns: the localized string (main bundle) for this string.
     */
    var localizedVariant: String {
        return NSLocalizedString(self, comment: "")
    }

    /* ################################################################## */
    /**
     This extension lets us uppercase only the first letter of the string (used for weekdays).
     From here: https://stackoverflow.com/a/28288340/879365
     
     - returns: The string, with only the first letter uppercased.
     */
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}

/* ###################################################################################################################################### */
/**
 This extension allows us to get whatever part of a view hierarchy is the first responder.
 */
extension UIView {
    /* ################################################################## */
    /**
     - returns: the first responder view. Nil, if no view is a first responder.
     */
    var currentFirstResponder: UIResponder! {
        if self.isFirstResponder {
            return self
        }
        
        for view in self.subviews {
            if let responder = view.currentFirstResponder {
                return responder
            }
        }
        
        return nil
    }
}

// MARK: - Prefs Class -
/* ###################################################################################################################################### */
/**
 This is a very simple "persistent user prefs" class. It is instantiated as a SINGLETON, and provides a simple, property-oriented gateway
 to the simple persistent user prefs in iOS. It shouldn't be used for really big, important prefs, but is ideal for the basic "settings"
 type of prefs most users set in their "gear" screen.
 */
class BMLT_MeetingSearch_Prefs {
    // MARK: Private Static Properties
    /* ################################################################################################################################## */
    /** This is the key for the prefs used by this app. */
    private static let _mainPrefsKey: String = "BMLTNAMeetingSearchPrefs"
    /** This is the default auto-search density. */
    private static let _defaultAutoSearchValue: Int = 10
    /** This is the number of miles/kilometers to use for initial distance displays. */
    private static let _defaultDistanceValue: Float = 10

    // MARK: Private Variable Properties
    /* ################################################################################################################################## */
    /** We load the user prefs into this Dictionary object. */
    private var _loadedPrefs: NSMutableDictionary! = nil
    /** This is our BMLTiOSLib Instance */
    private var _communicationObject: BMLTiOSLib! = nil
    /** This is how we enforce a SINGLETON pattern. */
    private static var _sSingletonPrefs: BMLT_MeetingSearch_Prefs! = nil
    
    // MARK: Private Enums
    /* ################################################################################################################################## */
    /** These are the keys we use for our persistent prefs dictionary. */
    private enum PrefsKeys: String {
        /** This is the Root Server URI */
        case RootServerURI = "rootURI"
        /** This represents how long we allow a meeting to be in progress before we remove it from our list of candidates. */
        case GracePeriod = "gracePeriod"
        /** This represents the units we use for our distance display. The string that is stored and returned in the localization key, not the displayed string. */
        case DistanceUnits = "distanceUnits"
        /** This dictates how the results are sorted. If 0, then they are sorted by time. If 1, they are sorted by distance. */
        case ResultSort = "resultSort"
        /** In the "More Info" screen, the user can select a map type. This is saved here. 0 = standard, 1 = hybrid, 2 = satellite. */
        case DisplayMapType = "displayMapType"
        /** In the meeting details screen, we can possibly access the Google Maps App (if installed). */
        case CanUseGoogleMaps = "canUseGoogleMapsApp"
        /** We can determine the density of the response when "Auto" is selected. */
        case AutoSearchValue = "autoSearchValue"
        /** This is the number of miles/kilometers to use for initial distance displays. */
        case DefaultDistanceValue = "defaultDistanceValue"
    }
    
    // MARK: Private Initializer
    /* ################################################################################################################################## */
    /** We do this to prevent the class from being instantiated in a different context than our controlled one. */
    private init() { /* Sergeant Schultz says: "I do nut'ing. Nut-ING!" */ }

    // MARK: Private Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This method simply saves the main preferences Dictionary into the standard user defaults.
     */
    private func _savePrefs() {
        UserDefaults.standard.set(self._loadedPrefs, forKey: type(of: self)._mainPrefsKey)
    }
    
    /* ################################################################## */
    /**
     This method loads the main prefs into our instance storage.
     
     NOTE: This will overwrite any unsaved changes to the current _loadedPrefs property.
     
     - returns: a Bool. True, if the load was successful.
     */
    private func _loadPrefs() -> Bool {
        if let temp = UserDefaults.standard.object(forKey: type(of: self)._mainPrefsKey) as? NSDictionary {
            self._loadedPrefs = NSMutableDictionary(dictionary: temp)
        } else {
            self._loadedPrefs = NSMutableDictionary()
        }
        
        return nil != self._loadedPrefs
    }
    
    // MARK: Class Static Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is how the singleton instance is instantiated and accessed. Always use this variable to capture the prefs object.
     
     The syntax is:
     
         let myPrefs = BMLTNAMeetingSearchPrefs.prefs
     */
    static var prefs: BMLT_MeetingSearch_Prefs {
        if nil == self._sSingletonPrefs {
            self._sSingletonPrefs = BMLT_MeetingSearch_Prefs()
        }
        
        return self._sSingletonPrefs
    }
    
    /* ################################################################## */
    /**
     This tells us whether or not the device is set for military time.
     */
    static var using12hClockFormat: Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let dateString = formatter.string(from: Date())
        let amRange = dateString.range(of: formatter.amSymbol)
        let pmRange = dateString.range(of: formatter.pmSymbol)
        
        return !(pmRange == nil && amRange == nil)
    }
    
    /* ################################################################## */
    /**
     This tells us whether or not the device is set for kilometers.
     */
    static var usingKilometeres: Bool {
        let locale = NSLocale.current
        return locale.usesMetricSystem
    }
    
    /* ################################################################## */
    /**
     Returns the 0-based index of the first weekday for the current calendar (0 = Sunday, 6 = Saturday).
     */
    static var indexOfWeekStart: Int {
        return Calendar.current.firstWeekday - 1
    }
    
    // MARK: Instance Static Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Gets a localized version of the weekday name from an index.
     
     Cribbed from Here: http://stackoverflow.com/questions/7330420/how-do-i-get-the-name-of-a-day-of-the-week-in-the-users-locale#answer-34289913
     
     - parameter weekdayNumber::1-based index (1 - 7), with 1 being Sunday, and 7 being Saturday.
     - parameter short::if true, then the shortened version of the name is returned (default is false).

     - returns: The localized, full-length weekday name (or shortened, if short is true).
     */
    class func weekdayNameFromWeekdayNumber(_ weekdayNumber: Int, short: Bool = false) -> String {
        let calendar = Calendar.current
        let weekdaySymbols = short ? calendar.shortWeekdaySymbols : calendar.weekdaySymbols
        let weekdayIndex = weekdayNumber - 1
        var index = weekdayIndex
        if 6 < index {
            index -= 7
        }
        return weekdaySymbols[index].firstUppercased
    }

    // MARK: Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is a read-only property, as the value is read from the plist file.
     
     - returns: the selected Root Server URI, as a String.
     */
    var rootURI: String {
        if let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let plistDictionary = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
                if let uri = plistDictionary["BMLTRootServerURI"] as? NSString {
                    return uri as String
                }
            }
        }
        
        return ""
    }
    
    /* ################################################################## */
    /**
     - returns: the selected Distance Units, as a String.
     */
    var distanceUnits: String {
        get {
            var ret: String = type(of: self).usingKilometeres ? "BMLTNAMeetingSearch-DistanceUnitsKm" : "BMLTNAMeetingSearch-DistanceUnitsMiles"
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.DistanceUnits.rawValue) as? String {
                    ret = temp
                } else {
                    self._loadedPrefs.setObject(ret, forKey: PrefsKeys.DistanceUnits.rawValue as NSString)
                }
            }
            
            return ret
        }
        
        set {
            if self._loadPrefs() {
                if newValue.isEmpty {
                    self._loadedPrefs.removeObject(forKey: PrefsKeys.DistanceUnits.rawValue)
                } else {
                    self._loadedPrefs.setObject(newValue, forKey: PrefsKeys.DistanceUnits.rawValue as NSString)
                }
                self._savePrefs()
            }
        }
    }
    
    /* ################################################################## */
    /**
     - returns: the "grace period" we give meetings (How long they have to already be running before we decide not to attend).
     */
    var gracePeriodInMinutes: Int {
        get {
            if var ret: Int = Int(NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Default-Value", comment: "")) {
                if self._loadPrefs() {
                    if let temp = self._loadedPrefs.object(forKey: PrefsKeys.GracePeriod.rawValue) as? NSNumber {
                        ret = temp.intValue
                    } else {
                        self._loadedPrefs.setObject(NSNumber(value: ret), forKey: PrefsKeys.GracePeriod.rawValue as NSString)
                    }
                }
                
                return ret
            } else {
                self._loadedPrefs.setObject(NSNumber(value: 0), forKey: PrefsKeys.GracePeriod.rawValue as NSString)
                return 0
            }
        }
        
        set {
            if self._loadPrefs() {
                let value = NSNumber(value: newValue)
                self._loadedPrefs.setObject(value, forKey: PrefsKeys.GracePeriod.rawValue as NSString)
                self._savePrefs()
            }
        }
    }
    
    /* ################################################################## */
    /**
     Should we sort meetings by distance? If false, we sort by day and time. Default is false.
     
     - returns: True, if we are to sort by distance. False, if we are to sort by weekday and time.
     */
    var sortResultsByDistance: Bool {
        get {
            var ret: Int = 0   // Default is false
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.ResultSort.rawValue) as? NSNumber {
                    ret = temp.intValue
                } else {
                    self._loadedPrefs.setObject(ret as NSNumber, forKey: PrefsKeys.ResultSort.rawValue as NSString)
                }
            }
            
            return 1 == ret
        }
        
        set {
            if self._loadPrefs() {
                let value = newValue ? 1 : 0
                self._loadedPrefs.setObject(value as NSNumber, forKey: PrefsKeys.ResultSort.rawValue as NSString)
                self._savePrefs()
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is the Map type index.
     
     - returns: 0, for standard, 1 for hybrid, and 2 for satellite. Default is hybrid.
     */
    var mapTypeIndex: Int {
        get {
            var ret: Int = 1    // Default is hybrid.
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.DisplayMapType.rawValue) as? NSNumber {
                    ret = temp.intValue
                } else {
                    self._loadedPrefs.setObject(NSNumber(value: ret), forKey: PrefsKeys.DisplayMapType.rawValue as NSString)
                }
            }
                
            return ret
        }
        
        set {
            if self._loadPrefs() {
                let value = NSNumber(value: newValue)
                self._loadedPrefs.setObject(value, forKey: PrefsKeys.DisplayMapType.rawValue as NSString)
                self._savePrefs()
            }
        }
    }
    
    /* ################################################################## */
    /**
     If the Google Maps App is installed, the user can choose to use that for directions.
     
     - returns: True, if we are able to open the Google Maps App. False, if we should always use Apple Maps.
     */
    var canUseGoogleMaps: Bool {
        get {
            var ret: Int = 0   // Default is false
            if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                ret = 1   // Default is true, if the app is installed.
                
                if self._loadPrefs() {
                    if let temp = self._loadedPrefs.object(forKey: PrefsKeys.CanUseGoogleMaps.rawValue) as? NSNumber {
                        ret = temp.intValue
                    } else {
                        self._loadedPrefs.setObject(ret as NSNumber, forKey: PrefsKeys.CanUseGoogleMaps.rawValue as NSString)
                    }
                }
            }
            
            return 1 == ret
        }
        
        set {
            if self._loadPrefs() {
                let value = newValue ? 1 : 0
                self._loadedPrefs.setObject(value as NSNumber, forKey: PrefsKeys.CanUseGoogleMaps.rawValue as NSString)
                self._savePrefs()
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is the density of the auto-search.
     
     - returns: an Int.
     */
    var autoSearchDensity: Int {
        get {
            var ret: Int = type(of: self)._defaultAutoSearchValue
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.AutoSearchValue.rawValue) as? NSNumber {
                    ret = temp.intValue
                } else {
                    self._loadedPrefs.setObject(ret as NSNumber, forKey: PrefsKeys.AutoSearchValue.rawValue as NSString)
                }
            }
            
            return ret
        }
        
        set {
            if self._loadPrefs() {
                let value = newValue
                self._loadedPrefs.setObject(value as NSNumber, forKey: PrefsKeys.AutoSearchValue.rawValue as NSString)
                self._savePrefs()
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is the default (initial) distance to use for distance specifiers.
     
     - returns: A Float.
     */
    var defaultDistanceValue: Float {
        get {
            var ret: Float = type(of: self)._defaultDistanceValue
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.DefaultDistanceValue.rawValue) as? NSNumber {
                    ret = temp.floatValue
                } else {
                    self._loadedPrefs.setObject(ret as NSNumber, forKey: PrefsKeys.DefaultDistanceValue.rawValue as NSString)
                }
            }
            
            return ret
        }
        
        set {
            if self._loadPrefs() {
                let value = newValue
                self._loadedPrefs.setObject(value as NSNumber, forKey: PrefsKeys.DefaultDistanceValue.rawValue as NSString)
                self._savePrefs()
            }
        }
    }

    /* ################################################################## */
    /**
     This is a quick access to the communication object.
     
     - returns: the BMLTiOSLib instance. Nil, if none.
     */
    var commObject: BMLTiOSLib! {
        get {
            return self._communicationObject
        }
        
        // We can set the object. It will terminate and overwrite any existing instance. There can only be one.
        set {
            self._communicationObject = newValue
        }
    }
}
