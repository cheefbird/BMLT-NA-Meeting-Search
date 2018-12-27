//  MapMarker.swift
//  NA Meeting List Administrator
//
//  Created by MAGSHARE.
//
//  Copyright 2017 MAGSHARE
//
//  This is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  NA Meeting List Administrator is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this code.  If not, see <http://www.gnu.org/licenses/>.

/**
 This file contains a couple of classes that allow us to establish and manipulate markers in our map.
 */

import MapKit
import BMLTiOSLib

typealias BMLT_MeetingSearch_MapMarker_MeetingArray = [BMLTiOSLibMeetingNode]

// MARK: - Annotation Class -
/* ###################################################################################################################################### */
/**
 This handles the marker annotation.
 */
class BMLT_MeetingSearch_Annotation: NSObject, MKAnnotation, NSCoding {
    let sCoordinateObjectKey: String = "MapAnnotation_Coordinate"
    let sMeetingsObjectKey: String = "MapAnnotation_Meetings"
    
    /** This title is displayed in callouts. */
    var title: String? = ""
    /** This is the actual location, in geo points, of the annotation. */
    var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    /** We can associate zero or more meeting objects with the annotation. */
    var meetings: [BMLTiOSLibMeetingNode] = []
    
    /* ################################################################## */
    /**
     Default initializer (Meeting array).
     
     - parameter coordinate: the coordinate for this annotation display.
     - parameter meetings: a list of meetings to be assigned to this annotation.
     */
    init(coordinate: CLLocationCoordinate2D, meetings: [BMLTiOSLibMeetingNode]) {
        self.coordinate = coordinate
        self.meetings = meetings
    }
    
    /* ################################################################## */
    /**
     Convenience initializer (Single meeting).
     
     - parameter coordinate: the coordinate for this annotation display.
     - parameter meeting: a single meeting to be assigned to this annotation.
     */
    convenience init(coordinate: CLLocationCoordinate2D, meeting: BMLTiOSLibMeetingNode) {
        self.init(coordinate: coordinate, meetings: [meeting])
    }
    
    /* ################################################################## */
    /**
     Convenience initializer (No meetings).
     
     - parameter coordinate: the coordinate for this annotation display.
     */
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(coordinate: coordinate, meetings: [])
    }
    
    // MARK: - NSCoding Protocol Methods -
    /* ################################################################################################################################## */
    /**
     This method will restore the locations and coordinate objects from the coder passed in.
     
     - parameter aDecoder: The coder that will contain the coordinates.
     */
    @objc required init?(coder aDecoder: NSCoder) {
        self.meetings = (aDecoder.decodeObject(forKey: self.sMeetingsObjectKey) as? [BMLTiOSLibMeetingNode])!
        if let tempCoordinate = aDecoder.decodeObject(forKey: self.sCoordinateObjectKey) as? [NSNumber] {
            self.coordinate.longitude = tempCoordinate[0].doubleValue
            self.coordinate.latitude = tempCoordinate[1].doubleValue
        }
    }
    
    /* ################################################################## */
    /**
     This method saves the locations and coordinates as part of the serialization.
     
     - parameter aCoder: The coder that contains the coordinates.
     */
    @objc func encode(with aCoder: NSCoder) {
        let long: NSNumber = NSNumber(value: self.coordinate.longitude as Double)
        let lat: NSNumber = NSNumber(value: self.coordinate.latitude as Double)
        let values: [NSNumber] = [long, lat]
        
        aCoder.encode(values, forKey: self.sCoordinateObjectKey)
        aCoder.encode(self.meetings, forKey: self.sMeetingsObjectKey)
    }
}

// MARK: - Marker Class -
/* ###################################################################################################################################### */
/**
 This handles our actual displayed map marker.
 */
class BMLT_MeetingSearch_MapMarkerAnnotationView: MKAnnotationView {
    // MARK: - Constant Properties -
    /* ################################################################################################################################## */
    let sAnnotationObjectKey: String = "MapMarker_Annotation"
    
    // MARK: - Private Properties -
    /* ################################################################################################################################## */
    private var _currentFrame: Int = 0
    private var _animationTimer: Timer! = nil
    private var _animationFrames: [UIImage] = []
    
    // MARK: - Computed Properties -
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     We override this, so we can be sure to refresh the need for a draw state when draggable is set (Meaning it's a black marker).
     */
    override var isDraggable: Bool {
        get {
            return super.isDraggable
        }
        
        set {
            super.isDraggable = newValue
            self.setNeedsDisplay()
        }
    }
    
    /* ################################################################## */
    /**
     This gives us a shortcut to the annotation prpoerty.
     */
    var coordinate: CLLocationCoordinate2D {
        return (self.annotation?.coordinate)!
    }
    
    /* ################################################################## */
    /**
     This gives us a shortcut to the annotation property.
     */
    var meetings: [BMLTiOSLibMeetingNode] {
        return ((self.annotation as? BMLT_MeetingSearch_Annotation)!.meetings)
    }
    
    /* ################################################################## */
    /**
     Loads our array of animation frames from the resource file.
     */
    var animationFrames: [UIImage] {
        // First time through, we load up on our animation frames.
        if self._animationFrames.isEmpty && self.isDraggable {
            let baseNameFormat = "DragMarker/Frame%02d"
            var index = 1
            while let image = UIImage(named: String(format: baseNameFormat, index)) {
                self._animationFrames.append(image)
                index += 1
            }
            
            self._currentFrame = 0
        }
        
        return self._animationFrames
    }
    
    // MARK: Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     - parameter forMapView: The MKMapView that will display the annotations.
     - parameter meetings: An array of meeting objects to be converted to annotations.
     - parameter distanceThresholdInDisplayPoints: The maximum proximity between two markers to make them become a "red" marker (One with multiple meetings). This is in display points.
     
     - returns: An array of annotations, with the meeting objects attached.
     */
    class func generateAnnotations(forMapView: MKMapView, meetings: BMLT_MeetingSearch_MapMarker_MeetingArray, tolerance distanceThresholdInDisplayPoints: CGFloat = 4.0) -> [BMLT_MeetingSearch_Annotation] {
        var ret: [BMLT_MeetingSearch_Annotation] = []
        
        for meeting in meetings {
            #if DEBUG
                print("Meeting: \(String(describing: meeting))")
            #endif
            if let meetingCoord = meeting.locationCoords {
                if !ret.isEmpty {
                    var topLeft = forMapView.convert(meetingCoord, toPointTo: nil)
                    topLeft.x -= distanceThresholdInDisplayPoints
                    topLeft.y -= distanceThresholdInDisplayPoints
                    let rectSize = CGSize(width: distanceThresholdInDisplayPoints * 2.0, height: distanceThresholdInDisplayPoints * 2.0)
                    let hitTestRect = CGRect(origin: topLeft, size: rectSize)
                    
                    var found: Bool = false
                    for annotation in ret {
                        if !annotation.meetings.contains(meeting) {
                            let hitTestPoint = forMapView.convert(annotation.coordinate, toPointTo: nil)
                            #if DEBUG
                                print("hitTestRect: \(String(describing: hitTestRect))")
                                print("hitTestPoint: \(String(describing: hitTestPoint))")
                            #endif
                            
                            if hitTestRect.contains(hitTestPoint) {
                                found = true
                                #if DEBUG
                                    print("Adding Meeting: \(String(describing: meeting)) to Annotation: \(String(describing: annotation))")
                                #endif
                                annotation.meetings.append(meeting)
                            }
                        }
                    }
                    
                    if !found {
                        let newAnnotation = BMLT_MeetingSearch_Annotation(coordinate: meetingCoord, meeting: meeting)
                        #if DEBUG
                            print("New Annotation (\(ret.count)): \(String(describing: newAnnotation))")
                        #endif
                        ret.append(newAnnotation)
                    }
                } else {
                    let newAnnotation = BMLT_MeetingSearch_Annotation(coordinate: meetingCoord, meeting: meeting)
                    #if DEBUG
                        print("First Annotation: \(String(describing: newAnnotation))")
                    #endif
                    ret.append(newAnnotation)
                }
            }
        }
        
        return ret
    }

    // MARK: - Ininializer -
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     The default initializer.
     
     - parameter annotation: The annotation that represents this instance.
     - parameter draggable: If true, then this will be draggable (ignored if the annotation has more than one meeting).
     */
    init(annotation: MKAnnotation?, draggable: Bool, reuseID: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseID)
        self.isDraggable = draggable
        _ = self.animationFrames    // This pre-loads our animation, if necessary.
        
        self.backgroundColor = UIColor.clear
        self.image = self.selectImage(false)
    }
    
    // MARK: - Instance Methods -
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This selects the appropriate image for our display.
     
     - parameter inAnimated: If true, then the drag will be animated.
     
     - returns: an image to be displayed for the marker.
     */
    func selectImage(_ inAnimated: Bool) -> UIImage! {
        var image: UIImage! = nil
        // The draggable marker is big. We need to make room for the entire animation, anchored in the center.
        if self.isDraggable {
            if self.dragState == MKAnnotationView.DragState.dragging {
                if inAnimated { // We can animate dragging, so you can see it around your finger.
                    let bottomImage = self._animationFrames[self._currentFrame]
                    self._currentFrame += 1
                    if self._currentFrame >= self._animationFrames.count {
                        self._currentFrame = 0
                    }
                    
                    if let topImage = UIImage(named: "GreenMarker", in: nil, compatibleWith: nil) {
                        let frame = CGRect(origin: CGPoint.zero, size: bottomImage.size)
                        UIGraphicsBeginImageContext(bottomImage.size)
                        
                        bottomImage.draw(in: frame)
                        topImage.draw(in: frame)
                        
                        image = UIGraphicsGetImageFromCurrentImageContext()
                        
                        UIGraphicsEndImageContext()
                    }
                }
            } else {    // If we aren't dragging, we have a single black marker for "at rest."
                image = UIImage(named: "BlackMarker", in: nil, compatibleWith: nil)
            }
        } else {    // The non-draggable marker is a lot smaller, as we don't need to deal with that animation. also, this makes hit testing a lot more precise.
                    // These "magic numbers" are for the particular image that we use for our "small" markers. It's anchored on the bottom, about a third of the way in.
            self.layer.anchorPoint = CGPoint(x: 0.35, y: 1.0)
            if 1 < self.meetings.count {// Multiple meetings in close proximity are indicated by a red marker.
                image = UIImage(named: "MarkerRed", in: nil, compatibleWith: nil)
            } else {
                if 0 == self.meetings.count {   // A no-meeting marker is black.
                    image = UIImage(named: "MarkerBlack", in: nil, compatibleWith: nil)
                } else {    // A single-meeting marker is blue.
                    image = UIImage(named: "MarkerBlue", in: nil, compatibleWith: nil)
                }
            }
        }
        
        return image
    }
    
    /* ################################################################## */
    /**
     Sets up the next timer.
     */
    func startTimer() {
        if #available(iOS 10.0, *) {
            self._animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { (_: Timer) in DispatchQueue.main.async(execute: { self.setNeedsDisplay() })
            })
        }
    }
    
    /* ################################################################## */
    /**
     Stops the timer.
     */
    func stopTimer() {
        if nil != self._animationTimer {
            self._animationTimer.invalidate()
            self._animationTimer = nil
        }
    }
    
    // MARK: - Base Class Override Methods -
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Draws the image for the marker.
     
     - parameter rect: The rectangle in which this is to be drawn.
     */
    override func draw(_ rect: CGRect) {
        self.stopTimer()
        // Get whichever image is needed for this frame.
        let image = self.selectImage(0 < self._animationFrames.count)
        if nil != image {
            image!.draw(in: rect)
        }
        // Dragging a marker needs animation.
        if self.dragState == MKAnnotationView.DragState.dragging {
            self.startTimer()
        }
    }
    
    /* ################################################################## */
    /**
     Sets the drag state for this marker.
     
     - parameter newDragState: The new state that should be set after this call.
     - parameter animated: True, if the state change is to be animated (ignored).
     */
    override func setDragState(_ newDragState: MKAnnotationView.DragState, animated: Bool) {
        var subsequentDragState = MKAnnotationView.DragState.none
        switch newDragState {
        case MKAnnotationView.DragState.starting:
            subsequentDragState = MKAnnotationView.DragState.dragging
            self._currentFrame = 0
            
        case MKAnnotationView.DragState.dragging:
            self.startTimer()
            subsequentDragState = MKAnnotationView.DragState.dragging
            
        default:
            self.stopTimer()
            subsequentDragState = MKAnnotationView.DragState.none
        }
        
        super.dragState = subsequentDragState
        self.setNeedsDisplay()
    }
    
    // MARK: - NSCoding Protocol Methods -
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This class will restore its meeting object from the coder passed in.
     
     - parameter  aDecoder: The coder that will contain the meeting.
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.annotation = aDecoder.decodeObject(forKey: self.sAnnotationObjectKey) as? BMLT_MeetingSearch_Annotation
    }
    
    /* ################################################################## */
    /**
     This method saves the locations and coordinates as part of the serialization.
     
     - parameter  aCoder: The coder that contains the coordinates.
     */
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.annotation, forKey: self.sAnnotationObjectKey)
        super.encode(with: aCoder)
    }
}
