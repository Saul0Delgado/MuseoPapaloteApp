//
//  IconDetector.swift
//  VisionTest
//
//  Created by Alumno on 14/11/24.
//


import UIKit

class IconDetector {
    
    // Define minimum and maximum HSV ranges for each color
    enum IconColor: String, CaseIterable {
        case red, green, blue, yellow, purple, orange
        
        var hsvRange: (min: [NSNumber], max: [NSNumber]) {
            switch self {
            case .red:
                return ([NSNumber(value: 0.0), NSNumber(value: 0.4), NSNumber(value: 0.4)],
                        [NSNumber(value: 0.1), NSNumber(value: 1.0), NSNumber(value: 1.0)])
            case .green:
                return ([NSNumber(value: 0.25), NSNumber(value: 0.4), NSNumber(value: 0.4)],
                        [NSNumber(value: 0.4), NSNumber(value: 1.0), NSNumber(value: 1.0)])
            case .blue:
                return ([NSNumber(value: 0.55), NSNumber(value: 0.4), NSNumber(value: 0.4)],
                        [NSNumber(value: 0.7), NSNumber(value: 1.0), NSNumber(value: 1.0)])
            case .yellow:
                return ([NSNumber(value: 0.15), NSNumber(value: 0.4), NSNumber(value: 0.4)],
                        [NSNumber(value: 0.2), NSNumber(value: 1.0), NSNumber(value: 1.0)])
            case .purple:
                return ([NSNumber(value: 0.75), NSNumber(value: 0.4), NSNumber(value: 0.4)],
                        [NSNumber(value: 0.9), NSNumber(value: 1.0), NSNumber(value: 1.0)])
            case .orange:
                return ([NSNumber(value: 0.05), NSNumber(value: 0.4), NSNumber(value: 0.4)],
                        [NSNumber(value: 0.1), NSNumber(value: 1.0), NSNumber(value: 1.0)])
            }
        }
    }
    
    // Method to detect icons
    func detectIcons(in image: UIImage) -> [(color: IconColor, rect: CGRect)] {
        var detectedIcons: [(color: IconColor, rect: CGRect)] = []
        
        for color in IconColor.allCases {
            let hsvRange = color.hsvRange
            // Create a mask for the specified color using OpenCVBridge
            guard let maskImage = OpenCVBridge.mask(forColor: image, minHSV: hsvRange.min, maxHSV: hsvRange.max) else {
                continue
            }
            
            // Find circular contours within the color mask
            let contours = OpenCVBridge.findCircularContours(maskImage, minCircularity: 0.8)
            
            // Add each detected contour to the results
            if let contours = contours { // Unwrap the optional safely
                for contour in contours {
                    detectedIcons.append((color: color, rect: contour.cgRectValue))
                }
            }

        }
        
        return detectedIcons
    }
    
    // Method to match detected icon with a template
    func matchDetectedIcon(_ image: UIImage, template: UIImage) -> Bool {
        let matchScore = OpenCVBridge.matchTemplate(image, withTemplate: template)
        return matchScore > 0.8  // Example threshold, adjust based on similarity needs
    }
}
