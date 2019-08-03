//
//  BMLT_MeetingSearch_PageRenderer.swift
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
 This extension allows us to get the displayed height and width (given a full-sized canvas -so no wrapping or truncating) of an attributed string.
 */
extension NSAttributedString {
    /* ################################################################## */
    /**
     - returns: The string height required to display the string.
     */
    var stringHeight: CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(rect.size.height)
    }
    
    /* ################################################################## */
    /**
     - returns: The string width required to display the string.
     */
    var stringWidth: CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(rect.size.width)
    }
}

/* ###################################################################################################################################### */
/**
 This class is a printe renderer for list results. It creates a fairly simple black-and-white list.
 */
class BMLT_MeetingSearch_ListResults_PageRenderer: UIPrintPageRenderer {
    // MARK: - Fixed Instance Properties
    /* ################################################################################################################################## */
    /** The font size can be dynamic for each meeting. We start with this, and get smaller, if necessary. */
    let startingFontSize: CGFloat = 30

    // MARK: - Variable Instance Properties
    /* ################################################################################################################################## */
    /** This is the maximum number of meetings to display per page. */
    var maxMeetingsPerPage: Int = 10
    /** These are the actual meeting objects being rendered. */
    var meetings: [BMLTiOSLibMeetingNode] = []
    
    // MARK: - Base Class Override Calculated Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     - returns: The number of pages required to display the list of meetings.
     */
    override var numberOfPages: Int {
        let perPageCount = Float(self.maxMeetingsPerPage)
        let meetingCount = Float(self.meetings.count)
        return Int(ceil(meetingCount / perPageCount))
    }
    
    // MARK: - Initializers
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Initializer with a list of meetings.
     
     - parameter meetings: This is an array of meeting objects.
     */
    init(meetings: [BMLTiOSLibMeetingNode]) {
        super.init()
        self.meetings = meetings
        self.headerHeight = 0
        self.footerHeight = 0
    }

    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This loops through the subset of meeting objects being printed on the given page, and renders them.
     
     - parameter pageIndex: This is the 0-based index of the page.
     - parameter in: This is the display rect.
     */
    override func drawContentForPage(at pageIndex: Int, in contentRect: CGRect) {
        let perMeetingHeight: CGFloat = contentRect.size.height / CGFloat(min(self.maxMeetingsPerPage, self.meetings.count))
        let startingPoint =  pageIndex * self.maxMeetingsPerPage
        let endingPointPlusOne = min(self.meetings.count, startingPoint + self.maxMeetingsPerPage)
        for index in startingPoint..<endingPointPlusOne {
            let top = contentRect.origin.y + (CGFloat(index - startingPoint) * perMeetingHeight)
            let meetingRect = CGRect(x: contentRect.origin.x, y: top, width: contentRect.size.width, height: perMeetingHeight)
            self.drawMeeting(at: index, in: meetingRect)
        }
    }

    // MARK: - Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This displays a single meeting.
     
     - parameter at: The 0-based index of the meeting to be rendered.
     - parameter in: This is the display rect.
     */
    func drawMeeting(at meetingIndex: Int, in contentRect: CGRect) {
        let cRect = contentRect.insetBy(dx: 4, dy: 4)
        let myMeetingObject = self.meetings[meetingIndex]
        
        if (1 < self.meetings.count) && (0 == meetingIndex % 2) {
            if let drawingContext = UIGraphicsGetCurrentContext() {
                drawingContext.setFillColor(UIColor.black.withAlphaComponent(0.075).cgColor)
                drawingContext.fill(contentRect)
            }
        }
        
        var fontSize = self.startingFontSize
        var width: CGFloat = 0
        var height: CGFloat = 0
        var descriptionString: NSAttributedString! = nil
        
        // What we do here, is continuously sample the display rect of the string, until we find a font size that fits the display.
        repeat {
            var attributes: [NSAttributedString.Key: Any] = [:]
            attributes[NSAttributedString.Key.backgroundColor] = UIColor.clear
            attributes[NSAttributedString.Key.foregroundColor] = UIColor.black
            attributes[NSAttributedString.Key.font] = UIFont.italicSystemFont(ofSize: fontSize)
            
            var stringContent = myMeetingObject.description
            if !myMeetingObject.comments.isEmpty {
                stringContent += "\n" + myMeetingObject.comments
            }
            
            descriptionString = NSAttributedString(string: stringContent, attributes: attributes)

            width = descriptionString.stringWidth
            height = descriptionString.stringHeight
            
            fontSize -= 0.25
        } while (width > cRect.size.width) || (height > cRect.size.height)

        if nil != descriptionString {
            descriptionString.draw(at: cRect.origin)
        }
    }
}

/* ###################################################################################################################################### */
/**
 This class extends the above, so that the first page is the displayed map.
 */
class BMLT_MeetingSearch_MapResults_PageRenderer: BMLT_MeetingSearch_ListResults_PageRenderer {
    /** This is the formatter used to render the map on the first page. */
    var mapFormatter: UIViewPrintFormatter! = nil
    
    // MARK: - Initializers
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Default initializer.
     
     - parameter meetings: An array of meeting objects to be listed after the map.
     - parameter mapFormatter: The formatter generated by the displayed map.
     */
    init(meetings: [BMLTiOSLibMeetingNode], mapFormatter: UIViewPrintFormatter) {
        super.init(meetings: meetings)
        self.mapFormatter = mapFormatter
    }

    // MARK: - Base Class Override Calculated Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     - returns: The number of pages required to display the list of meetings (We add one for tha map).
     */
    override var numberOfPages: Int {
        return super.numberOfPages + 1
    }

    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This draws the map, then loops through the subset of meeting objects being printed on the given page, and renders them.
     
     - parameter pageIndex: This is the 0-based index of the page.
     - parameter in: This is the display rect.
     */
    override func drawContentForPage(at pageIndex: Int, in contentRect: CGRect) {
        if 0 < pageIndex {
            super.drawContentForPage(at: pageIndex - 1, in: contentRect)
        } else {
            self.mapFormatter.draw(in: contentRect, forPageAt: 0)
        }
    }
}

/* ###################################################################################################################################### */
/**
 This extends the list formatter for a single page, with a single meetings and a map.
 */
class BMLT_MeetingSearch_SingleMeeting_PageRenderer: BMLT_MeetingSearch_ListResults_PageRenderer {
    /// This is the formatter object we'll use to render the page.
    var mapFormatter: UIViewPrintFormatter! = nil
    
    // MARK: - Base Class Override Calculated Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     - returns: The number of pages required to display the meeting (always 1).
     */
    override var numberOfPages: Int { return 1 }
    
    // MARK: - Initializers
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Default initializer.
     
     - parameter meeting: A meeting object to be displayed.
     - parameter mapFormatter: The formatter generated by the displayed map.
     */
    init(meeting: BMLTiOSLibMeetingNode, mapFormatter: UIViewPrintFormatter) {
        super.init(meetings: [meeting])
        self.mapFormatter = mapFormatter
    }

    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This draws the meeting info.
     
     - parameter pageIndex: This is the 0-based index of the page.
     - parameter in: This is the display rect.
     */
    override func drawContentForPage(at pageIndex: Int, in contentRect: CGRect) {
        let cRect = contentRect.insetBy(dx: 4, dy: 4)
        let myMeetingObject = self.meetings[0]

        var fontSize = self.startingFontSize
        var width: CGFloat = 0
        var height: CGFloat = 0
        var descriptionString: NSAttributedString! = nil
        
        // What we do here, is continuously sample the display rect of the string, until we find a font size that fits the display.
        repeat {
            var attributes: [NSAttributedString.Key: Any] = [:]
            attributes[NSAttributedString.Key.backgroundColor] = UIColor.clear
            attributes[NSAttributedString.Key.foregroundColor] = UIColor.black
            attributes[NSAttributedString.Key.font] = UIFont.italicSystemFont(ofSize: fontSize)
            
            var stringContent = myMeetingObject.description
            if !myMeetingObject.comments.isEmpty {
                stringContent += "\n" + myMeetingObject.comments
            }
            
            descriptionString = NSAttributedString(string: stringContent, attributes: attributes)
            
            width = descriptionString.stringWidth
            height = descriptionString.stringHeight
            
            fontSize -= 0.25
        } while (width > cRect.size.width) || (height > cRect.size.height)
        
        if nil != descriptionString {
            descriptionString.draw(at: cRect.origin)
        }
        
        let bottomDrawingRect = CGRect(x: cRect.origin.x, y: cRect.origin.y + height, width: cRect.size.width, height: cRect.size.height - height)
        self.mapFormatter.draw(in: bottomDrawingRect, forPageAt: 0)
    }
}
