//
//  BMLT_MeetingSearch_Checkbox.swift
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
    This is a simple subclass of the standard UIButton class, where we provide custom images, and record a state as "checked" or "not checked."
    You should query the state of the "checked" property to determine the checkbox state.
*/
@IBDesignable class BMLT_MeetingSearch_Checkbox: UIButton {
    /** This holds the actual checked condition. If true, then the control is checked. This should not be accessed outside the class. */
    @IBInspectable var checkedInternal: Bool = false
    /* This is a functional interface to ensure that the control gets redrawn when the state changes. */
    var checked: Bool {
        get {
            return self.checkedInternal
        }
        set {
            self.checkedInternal = newValue
            self.sendActions(for: UIControlEvents.valueChanged)
            self.setNeedsLayout()
        }
    }
    
    /* ################################################################## */
    /**
        We deal with the displayed images as background images, and we
        select those images when our subviews are laid out.
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        if let testImage = UIImage(named: "Checkbox-unselected") {
            self.bounds.size = testImage.size
            if self.checked {
                self.setBackgroundImage(UIImage(named: "Checkbox-selected"), for: UIControlState())
                self.setBackgroundImage(UIImage(named: "Checkbox-selected-highlight"), for: UIControlState.selected)
                self.setBackgroundImage(UIImage(named: "Checkbox-selected-highlight"), for: UIControlState.highlighted)
                self.setBackgroundImage(UIImage(named: "Checkbox-selected-highlight"), for: UIControlState.disabled)
            } else {
                self.setBackgroundImage(UIImage(named: "Checkbox-unselected"), for: UIControlState())
                self.setBackgroundImage(UIImage(named: "Checkbox-unselected-highlight"), for: UIControlState.selected)
                self.setBackgroundImage(UIImage(named: "Checkbox-unselected-highlight"), for: UIControlState.highlighted)
                self.setBackgroundImage(UIImage(named: "Checkbox-unselected-highlight"), for: UIControlState.disabled)
            }
        }
    }
    
    /* ################################################################## */
    /**
        We react to releases of a touch within the control by toggling the checked state.
    
        :param: touch The touch object.
        :param: event The event driving the touch.
    */
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if((nil != touch) && (nil != self.hitTest(touch!.location(in: self), with: event))) {
            self.checked = !self.checked
        }
    }
}
