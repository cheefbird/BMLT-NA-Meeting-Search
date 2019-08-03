//
//  BMLT_MeetingSearch_Checkbox.swift
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

/* ###################################################################################################################################### */
/**
    This is a simple subclass of the standard UIButton class, where we provide custom images, and record a state as "checked" or "not checked."
    You should query the state of the "checked" property to determine the checkbox state.
*/
@IBDesignable class BMLT_MeetingSearch_Checkbox: UIButton {
    /** This holds the actual checked condition. If true, then the control is checked. This should not be accessed outside the class. */
    @IBInspectable var checkedInternal: Bool = false
    /** This is a functional interface to ensure that the control gets redrawn when the state changes. */
    var checked: Bool {
        get {
            return self.checkedInternal
        }
        set {
            self.checkedInternal = newValue
            self.sendActions(for: UIControl.Event.valueChanged)
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
                self.setBackgroundImage(UIImage(named: "Checkbox-selected"), for: UIControl.State())
                self.setBackgroundImage(UIImage(named: "Checkbox-selected-highlight"), for: UIControl.State.selected)
                self.setBackgroundImage(UIImage(named: "Checkbox-selected-highlight"), for: UIControl.State.highlighted)
                self.setBackgroundImage(UIImage(named: "Checkbox-selected-highlight"), for: UIControl.State.disabled)
            } else {
                self.setBackgroundImage(UIImage(named: "Checkbox-unselected"), for: UIControl.State())
                self.setBackgroundImage(UIImage(named: "Checkbox-unselected-highlight"), for: UIControl.State.selected)
                self.setBackgroundImage(UIImage(named: "Checkbox-unselected-highlight"), for: UIControl.State.highlighted)
                self.setBackgroundImage(UIImage(named: "Checkbox-unselected-highlight"), for: UIControl.State.disabled)
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
        if(nil != touch) && (nil != self.hitTest(touch!.location(in: self), with: event)) {
            self.checked = !self.checked
        }
    }
}
