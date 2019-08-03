//
//  BMLT_MeetingSearch_Settings_ViewController.swift
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
 This class controls the main "Settings and Info" screen.
 */
class BMLT_MeetingSearch_Settings_ViewController: BMLT_MeetingSearch_RootViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: Private Constant Properties
    /* ##################################################################################################################################*/
    /// These are the densities that we display as thresholds for auto-radius. They are a meeting result count.
    private let _densityValues: [Int] = [4, 7, 10, 15, 20]
    /// This is the segue ID for the "More Info" screen.
    private let _moreInfoSegueID = "show-info-screen-segue-id"
    /// This is a threshold for hiding some items in the More Info screen (useful for narrow landscape screens).
    private let _moreInfoHidesHeightThreshold: CGFloat = 500

    // MARK: IB Properties
    /* ##################################################################################################################################*/
    /// The label for the Auto Distance Density switch
    @IBOutlet weak var autoDistanceLabel: UILabel!
    /// The switch for selecting auto density.
    @IBOutlet weak var autoDistanceSwitch: UISegmentedControl!
    /// The container for the "Use Google Maps for Directions" items. It is hidden if the Google Maps app is not available.
    @IBOutlet weak var googleMapsItemsContainerView: UIView!
    /// the switch to use Google Maps.
    @IBOutlet weak var useGoogleMapsSwitch: UISwitch!
    /// the label for the Use Google Maps switch.
    @IBOutlet weak var useGoogleMapsSwitchLabel: UILabel!
    /// The top contraint for the Grace period Picker View.
    @IBOutlet weak var gracePeriodTopConstraint: NSLayoutConstraint!
    /// The label for the Grace Period Picker View.
    @IBOutlet weak var gracePeriodTopLabel: UILabel!
    /// The initial text for the Grace Period.
    @IBOutlet weak var initialGracePeriodText: UILabel!
    /** This is the picker view for selecting a Grace Time. */
    @IBOutlet weak var graceTimePicker: UIPickerView!
    /** This is the main explanation text item. */
    @IBOutlet weak var explainText: UITextView!
    /// The "blurb" button for corporate ID.
    @IBOutlet weak var magshareBlurbButton: UIButton!
    /// the More info (Beanie) button.
    @IBOutlet weak var moreInfoButton: UIButton!
    /// The container view for the More Info button (to assure centering).
    @IBOutlet weak var moreInfoContainerView: UIView!
    
    // MARK: Private Instance Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Matches a row index to a value.
     
     - parameter inRow: The row index
     - returns: A value for a given picker row index.
     */
    private func _getPickerValueForRow (_ inRow: Int) -> Int {
        
        var pickerValue: String = ""
        
        switch inRow {
        case 0:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-00".localizedVariant
        case 1:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-01".localizedVariant
        case 2:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-02".localizedVariant
        case 3:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-03".localizedVariant
        case 4:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-04".localizedVariant
        case 5:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-05".localizedVariant
        case 6:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-06".localizedVariant
        default:
            pickerValue = "0"
        }
        
        var ret: Int = 0
        
        if let pickerIntValue = Int(pickerValue) {
            ret = pickerIntValue
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Matches a value to a row index (opposite of above).
     
     - parameter inValue: The value
     - returns: A row index for a given value. -1 if no row matched the value.
     */
    private func _getPickerRowForValue (_ inValue: Int) -> Int {
        var ret: Int = -1
        
        for i in 0..<self.pickerView(self.graceTimePicker, numberOfRowsInComponent: 0) {
            let value = self._getPickerValueForRow(i)
            
            if value == inValue {
                ret = i
                
                break
            }
        }
        
        return ret
    }

    // MARK: IB Instance Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is called when the segmented switch for auto-search density changes.
     
     - parameter sender: The segmented switch.
     */
    @IBAction func autoDistanceSwitchChanged(_ sender: UISegmentedControl) {
        let autoDensity = self._densityValues[sender.selectedSegmentIndex]
        self.prefs.autoSearchDensity = autoDensity
    }
    
    /* ################################################################## */
    /**
     This is called when the switch for using the GM app is changed.
     
     - parameter sender: The switch.
     */
    @IBAction func googleMapsSwitchChanged(_ sender: UISwitch) {
        self.prefs.canUseGoogleMaps = sender.isOn
    }
    
    /* ################################################################## */
    /**
     This is called to pull in the more info modal screen.
     
     - parameter: ignored
     */
    @IBAction func moreInfoPlease(_ : Any) {
        self.performSegue(withIdentifier: self._moreInfoSegueID, sender: nil)
    }
    
    // MARK: Base Class Override Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is called after the view has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.autoDistanceLabel.text = self.autoDistanceLabel.text?.localizedVariant
        self.gracePeriodTopLabel.text = self.gracePeriodTopLabel.text?.localizedVariant
        self.initialGracePeriodText.text = self.initialGracePeriodText.text?.localizedVariant

        self.magshareBlurbButton.setTitle(self.magshareBlurbButton.title(for: .normal)?.localizedVariant, for: .normal)
        self.moreInfoButton.setTitle(self.moreInfoButton.title(for: .normal)?.localizedVariant, for: .normal)

        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            self.useGoogleMapsSwitchLabel.text = self.useGoogleMapsSwitchLabel.text?.localizedVariant
            self.useGoogleMapsSwitch.isOn = self.prefs.canUseGoogleMaps
        } else {
            self.gracePeriodTopConstraint.constant = 8
            self.googleMapsItemsContainerView.isHidden = true
        }
        
        // Set up localized names for the auto-search density control.
        for i in 0..<self.autoDistanceSwitch.numberOfSegments {
            if let segmentTitle = self.autoDistanceSwitch.titleForSegment(at: i) {
                self.autoDistanceSwitch.setTitle(segmentTitle.localizedVariant, forSegmentAt: i)
            }
        }

        if let index = self._densityValues.firstIndex(of: self.prefs.autoSearchDensity) {
            self.autoDistanceSwitch.selectedSegmentIndex = index
        } else {
            self.autoDistanceSwitch.selectedSegmentIndex = 5
            self.prefs.autoSearchDensity = self._densityValues[5]
        }
        
        let defaultRow = self._getPickerRowForValue(self.prefs.gracePeriodInMinutes)
        
        if 0 <= defaultRow {
            self.graceTimePicker.selectRow(defaultRow, inComponent: 0, animated: false)
        }

        if let textItemText = self.explainText.text {
            self.explainText.text = textItemText.localizedVariant
        }
    }

    /* ################################################################## */
    /**
     This is called just before the view will lay out its subviews.
     */
    override func viewWillLayoutSubviews() {
        let screenSize: CGRect = UIScreen.main.bounds
        self.moreInfoContainerView.isHidden = (screenSize.size.height < self._moreInfoHidesHeightThreshold)
        super.viewWillLayoutSubviews()
    }

    // MARK: UIPickerViewDataSource Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     We only have 1 component.
     
     - parameter pickerView: The UIPickerView being checked
     
     - returns: 1
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /* ################################################################## */
    /**
     We have 7 possible values.
     
     - parameter pickerView: The UIPickerView being checked
     
     - returns: 7
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }
    
    // MARK: UIPickerViewDelegate Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This returns the name for the given row.
     
     - parameter pickerView: The UIPickerView being checked
     - parameter row: The row being checked
     - parameter forComponent: The component (always 0)
     - parameter reusing: If the view is being reused, it is passed in here.
     
     - returns: a view, containing a label with the string for the row.
     */
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let size = pickerView.rowSize(forComponent: 0)
        var frame = pickerView.bounds
        frame.size.height = size.height
        frame.origin = CGPoint.zero
        
        var pickerValue: String = ""
        
        switch row {
        case 0:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-00".localizedVariant
        case 1:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-01".localizedVariant
        case 2:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-02".localizedVariant
        case 3:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-03".localizedVariant
        case 4:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-04".localizedVariant
        case 5:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-05".localizedVariant
        case 6:
            pickerValue = "BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-06".localizedVariant
        default:
            pickerValue = "ERROR"
        }
        
        let ret = UIView(frame: frame)
        
        ret.backgroundColor = UIColor.clear
        
        let label = UILabel(frame: frame)
        
        label.textAlignment = NSTextAlignment.center
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = self.gradientTopColor
        label.textColor = UIColor.white
        label.text = pickerValue
        
        ret.addSubview(label)
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This is called when the user finishes selecting a row.
     We use this to add the selected town to the filter.
     
     If it is one of the top 2 rows, we select the first row, and ignore it.
     
     :param: pickerView The UIPickerView being checked
     :param: row The row being checked
     :param: component The component (always 0)
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.prefs.gracePeriodInMinutes = self._getPickerValueForRow(row)
    }
}
