//
//  BMLT_MeetingSearch_Basic_ViewController.swift
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

/* ###################################################################################################################################### */
/**
 This handles the "Basic Search" screen.
 */
class BMLT_MeetingSearch_Basic_ViewController: BMLT_MeetingSearch_RootViewController, UITextFieldDelegate {
    /** This is the segue to perform the search. */
    private let _mainSearchSegueID: String = "perform-basic-meetings-in-range-search-segue-id"

    /** These are our various IB items. */
    @IBOutlet weak var findMeetingsWithinLabel: UILabel!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var distanceValueStepper: UIStepper!
    @IBOutlet weak var stringSearchLabel: UILabel!
    @IBOutlet weak var stringSearchTextField: UITextField!
    @IBOutlet weak var performBasicSearchButton: UIButton!
    @IBOutlet weak var weekdayCheckbox01: BMLT_MeetingSearch_Checkbox!
    @IBOutlet weak var weekdayCheckbox02: BMLT_MeetingSearch_Checkbox!
    @IBOutlet weak var weekdayCheckbox03: BMLT_MeetingSearch_Checkbox!
    @IBOutlet weak var weekdayCheckbox04: BMLT_MeetingSearch_Checkbox!
    @IBOutlet weak var weekdayCheckbox05: BMLT_MeetingSearch_Checkbox!
    @IBOutlet weak var weekdayCheckbox06: BMLT_MeetingSearch_Checkbox!
    @IBOutlet weak var weekdayCheckbox07: BMLT_MeetingSearch_Checkbox!
    @IBOutlet weak var weekdayLabel01: UILabel!
    @IBOutlet weak var weekdayLabel02: UILabel!
    @IBOutlet weak var weekdayLabel03: UILabel!
    @IBOutlet weak var weekdayLabel04: UILabel!
    @IBOutlet weak var weekdayLabel05: UILabel!
    @IBOutlet weak var weekdayLabel06: UILabel!
    @IBOutlet weak var weekdayLabel07: UILabel!
    @IBOutlet weak var checkUncheckButton: UIButton!
    @IBOutlet weak var autoSwitch: UISwitch!
    
    /** This is the current distance the user has selected. */
    var distance: Int = 0
    /** This is any search string that the user has entered. */
    var searchString: String = ""
    /** This maps the state of the weekday selections. */
    var selectedWeekdays: [Bool] = [false, false, false, false, false, false, false]
    /** This is an array of checkboxes for weekdays, for easy access. */
    var weekdayCheckboxes: [BMLT_MeetingSearch_Checkbox] = []
    /** These are the labels displayed under the checkboxes. */
    var weekdayLabels: [UILabel] = []

    // MARK: - IB Action Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is called when the "Auto" switch changes.
     
     - parameter: ignored
     */
    @IBAction func autoSwitchChanged(_ : Any) {
        self.checkSearchButtonEnabledStatus()
    }
    
    /* ################################################################## */
    /**
     This is called when the button over the weekday checkboxes changes (check or uncheck all).
     
     - parameter: ignored
     */
    @IBAction func checkUncheckHit(_ : Any) {
        var allChecked = true
        
        for weekday in 0..<7 where !self.weekdayCheckboxes[weekday].checked {
            allChecked = false
        }
        
        for weekday in 0..<7 {
            self.weekdayCheckboxes[weekday].checked = !allChecked
            self.selectedWeekdays[weekday] = !allChecked
        }
        
        self.checkSearchButtonEnabledStatus()
    }
    
    /* ################################################################## */
    /**
     This is called when one of the weekday checkboxes changes.
     
     - parameter sender: The checkbox object
     */
    @IBAction func weekdayCheckboxChanged(_ sender: BMLT_MeetingSearch_Checkbox) {
        self.checkSearchButtonEnabledStatus()
        
        if var selectedIndex = self.weekdayCheckboxes.firstIndex(of: sender) {
            selectedIndex += BMLT_MeetingSearch_Prefs.indexOfWeekStart
            if 6 < selectedIndex {
                selectedIndex -= 7
            }
            
            self.selectedWeekdays[selectedIndex] = sender.checked
        }
	}
    
    /* ################################################################## */
    /**
     This is called when the search distance stepper changes value.
     
     - parameter sender: The stepper object.
     */
    @IBAction func stepperHit(_ sender: UIStepper) {
        let newValue = Int(sender.value)
        self.distance = newValue
        self.distanceTextField.text = String(newValue)
        self.checkSearchButtonEnabledStatus()
    }

    /* ################################################################## */
    /**
     This is called when the "Find Meetings" button is hit.
     
     - parameter: ignored
     */
    @IBAction func doSearchHit(_ : Any!) {
        var atleastOneWeekdayChecked = false
        
        for weekday in 0..<7 where weekdayCheckboxes[weekday].checked {
            atleastOneWeekdayChecked = true
            break
        }
        
        if (!self.autoSwitch.isOn || (0 < self.distance)) && atleastOneWeekdayChecked {
            self.performSegue(withIdentifier: self._mainSearchSegueID, sender: nil)
        }
    }

    // MARK: - Internal Instance Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This goes through the object state, and shows/hides/enables/disables items as needed.
     */
    func checkSearchButtonEnabledStatus() {
        var atleastOneWeekdayChecked = false
        var allChecked = true
        
        for weekday in 0..<7 {
            if self.weekdayCheckboxes[weekday].checked {
                atleastOneWeekdayChecked = true
            } else {
                allChecked = false
            }
        }
        
        self.performBasicSearchButton.isEnabled = ((!self.autoSwitch.isOn || (0 < self.distance)) && atleastOneWeekdayChecked)
        self.distanceTextField.isEnabled = self.autoSwitch.isOn
        self.distanceValueStepper.isEnabled = self.autoSwitch.isOn
        
        if !self.autoSwitch.isOn {
            self.distanceTextField.text = ""
        } else {
            self.distanceValueStepper.value = Double(self.distance)
            if (self.distanceTextField.text?.isEmpty)! {
                self.distanceTextField.text = String(self.distance)
            }
        }
        
        let buttonText = allChecked ? "BASIC-UNCHECK-ALL".localizedVariant : "BASIC-CHECK-ALL".localizedVariant
        
        self.checkUncheckButton.setTitle(buttonText, for: .normal)
    }
    
    // MARK: - Base Class Override Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Called when the view is loaded. We set the localized string for the label here.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.performBasicSearchButton.setTitle(performBasicSearchButton.title(for: .normal)?.localizedVariant, for: .normal)
        self.findMeetingsWithinLabel.text = self.findMeetingsWithinLabel.text?.localizedVariant
        self.stringSearchLabel.text = self.stringSearchLabel.text?.localizedVariant
        self.stringSearchTextField.placeholder = self.stringSearchTextField.placeholder?.localizedVariant
        self.unitLabel.text = (BMLT_MeetingSearch_Prefs.usingKilometeres ? "BMLTNAMeetingSearch-DistanceUnitsKm-Short" : "BMLTNAMeetingSearch-DistanceUnitsMiles-Short").localizedVariant
        self.weekdayLabels = [self.weekdayLabel01, self.weekdayLabel02, self.weekdayLabel03, self.weekdayLabel04, self.weekdayLabel05, self.weekdayLabel06, self.weekdayLabel07]
        self.weekdayCheckboxes = [self.weekdayCheckbox01, self.weekdayCheckbox02, self.weekdayCheckbox03, self.weekdayCheckbox04, self.weekdayCheckbox05, self.weekdayCheckbox06, self.weekdayCheckbox07]
        self.distance = Int(ceil(self.prefs.defaultDistanceValue))

        for weekday in 0..<7 {
            weekdayLabels[weekday].text = BMLT_MeetingSearch_Prefs.weekdayNameFromWeekdayNumber(weekday + 1, short: true)
        }
    }
    
    /* ################################################################## */
    /**
     Called just before the view is to appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        for weekday in 0..<7 {
            weekdayCheckboxes[weekday].checked = true
            self.selectedWeekdays[weekday] = true
        }

        self.distanceValueStepper.value = Double(self.distance)
        self.distanceTextField.text = String(self.distance)
        self.checkSearchButtonEnabledStatus()
    }

    /* ################################################################## */
    /**
     This is called as the segue is about to happen.
     We use this opportunity to tell the progress screen what we want done (simple location lookup, followed by today and tomorrow).
     
     - parameter segue: The segue being exercised.
     - parameter sender: Any extra info we want attached (ignored).
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == self._mainSearchSegueID {
            if let destination = segue.destination as? BMLT_MeetingSearch_Progress_ViewController {
                var allchecked = true
                var allUnchecked = true
                
                for weekday in 0..<7 {
                    if self.selectedWeekdays[weekday] {
                        allUnchecked = false
                    } else {
                        allchecked = false
                    }
                }

                if !allUnchecked {  // Should never happen, but belt and suspenders...
                    destination.lookUpLocationFirst = true
                    destination.useSearchCriteria = true
                    
                    // If we are all checked, then we clear all the fields. This is the same as all checked, but more efficient.
                    for weekday in 0..<7 {
                        if let theKey = BMLTiOSLibSearchCriteria.WeekdayIndex(rawValue: weekday + 1) {
                            let setValue: Bool = !allchecked && self.selectedWeekdays[weekday]
                            destination.criteriaObject.weekdays[theKey] = setValue ? .Selected : .Clear
                        }
                    }
                    
                    if !self.autoSwitch.isOn {
                        destination.criteriaObject.searchRadius = -1 * Float(self.prefs.autoSearchDensity)
                    } else {
                        destination.criteriaObject.searchRadius = Float(self.distance)
                    }
                    
                    destination.criteriaObject.searchString = self.searchString
                }
            }
        }
    }

    // MARK: - UITextFieldDelegate Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is called when something is typed in a text field.
     
     We interpret the result of the typing, and either allow or disallow it, based on those results.
     
     We also update our distance and search string properties.
     
     - parameter textField: The text field affected.
     - parameter shouldChangeCharactersIn: A range that denotes which existing characters will be replaced by...
     - parameter replacementString: The string to replace the above characters.
     
     - returns: True, if the replacement is allowed.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let originalString = textField.text as NSString? {
            let newString = originalString.replacingCharacters(in: range, with: string)
            
            if textField == self.distanceTextField {
                if !newString.isEmpty {
                    if nil != newString.range(of: "^([0-9]+?)$", options: .regularExpression) {
                        if let newValue = Int(newString) {
                            if newValue <= Int(self.distanceValueStepper.maximumValue) {
                                self.distance = newValue
                            } else {
                                return false
                            }
                        } else {
                            return false
                        }
                    } else {
                        return false
                    }
                } else {
                    self.distance = 0
                }
                
                self.distanceValueStepper.value = Double(self.distance)
            } else {
                self.searchString = newString
            }
        }
        
        self.checkSearchButtonEnabledStatus()
        
        return true
    }
    
    /* ################################################################## */
    /**
     This is called when the return/done key is hit.
     
     It closes the text field, and starts the search.
     
     - parameter textField: The text field affected.
     
     - returns: True, if the return is OK (all the time).
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.doSearchHit(self.performBasicSearchButton)
        return true
    }
}
