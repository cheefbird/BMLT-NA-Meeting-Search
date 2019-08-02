//
//  BMLT_MeetingSearch_Info_ViewController.swift
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

/* ###################################################################################################################################### */
/**
 This classs handles the "More Info" modal screen that is pulled in over the "Settings and Info" screen.
 */
class BMLT_MeetingSearch_Info_ViewController: BMLT_MeetingSearch_Subsequent_ViewController {
    // MARK: IB Properties
    /* ##################################################################################################################################*/
    /// This is the label for the screen header.
    @IBOutlet weak var headerLabel: UILabel!
    /// This is the button that displays the documentation page URI
    @IBOutlet weak var uriButton: UIButton!
    /// This is the scrollable text field, containing the bulk of the text.
    @IBOutlet weak var explanationText: UITextView!
    /// This is the button at the bottom of the screen, with "DONE."
    @IBOutlet weak var doneButton: UIButton!

    // MARK: IB Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is called when the big button or the visit site button is hit.
     
     - parameter: ignored
     */
    @IBAction func beanieButtonHit(_ : Any) {
        let openLink = NSURL(string: "INFO-HELP-URI".localizedVariant)
        UIApplication.shared.open(openLink! as URL, options: [:], completionHandler: nil)
    }
    
    /* ################################################################## */
    /**
     This is called to dismiss the screen.
     
     - parameter: ignored
     */
    @IBAction func doneButtonHit(_ : Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Base Class Override Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is called after the view has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton.setTitle(self.doneButton.title(for: .normal)?.localizedVariant, for: .normal)
        self.uriButton.setTitle(self.uriButton.title(for: .normal)?.localizedVariant, for: .normal)
        self.explanationText.text = self.explanationText.text.localizedVariant
        if let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let plistDictionary = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
                if let format = self.headerLabel.text?.localizedVariant {
                    var appName = "ERROR"
                    var appVersion = "ERROR"
                    
                    if let appNameTemp = plistDictionary["CFBundleName"] as? NSString {
                        appName = appNameTemp as String
                    }
                    
                    if let versionTemp = plistDictionary["CFBundleShortVersionString"] as? NSString {
                        appVersion = versionTemp as String
                    }
                    
                    self.headerLabel.text = String(format: format, appName, appVersion)
                }
            }
        }
    }
}
