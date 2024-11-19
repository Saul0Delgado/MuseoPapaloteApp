#import "OpenCVBridge.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

// C++ helper functions
namespace {
    cv::Mat uiImageToMat(UIImage *image) {
        cv::Mat mat;
        UIImageToMat(image, mat);
        return mat;
    }

    UIImage* matToUIImage(const cv::Mat& mat) {
        return MatToUIImage(mat);
    }
}

@implementation OpenCVBridge

+ (UIImage *)maskForColor:(UIImage *)image minHSV:(NSArray<NSNumber *> *)minHSV maxHSV:(NSArray<NSNumber *> *)maxHSV {
    // Convert UIImage to cv::Mat
    cv::Mat mat = uiImageToMat(image);
    
    // Convert the image to HSV
    cv::Mat hsvMat;
    cv::cvtColor(mat, hsvMat, cv::COLOR_BGR2HSV);
    
    // Create lower and upper bounds for HSV
    cv::Scalar lower(minHSV[0].doubleValue * 180.0,   // OpenCV uses 0-180 range for Hue
                     minHSV[1].doubleValue * 255.0,   // Saturation 0-255
                     minHSV[2].doubleValue * 255.0);  // Value 0-255

    cv::Scalar upper(maxHSV[0].doubleValue * 180.0,
                     maxHSV[1].doubleValue * 255.0,
                     maxHSV[2].doubleValue * 255.0);
    
    // Threshold the image to create a binary mask
    cv::Mat maskMat;
    cv::inRange(hsvMat, lower, upper, maskMat);
    
    // Convert back to UIImage
    return matToUIImage(maskMat);
}

+ (NSArray<NSValue *> *)findCircularContours:(UIImage *)image minCircularity:(double)minCircularity {
    cv::Mat mat = uiImageToMat(image);
    
    // Find contours
    std::vector<std::vector<cv::Point>> contours;
    cv::findContours(mat, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
    
    NSMutableArray<NSValue *> *circularContours = [NSMutableArray array];
    
    for (const auto &contour : contours) {
        // Calculate circularity
        double area = cv::contourArea(contour);
        double perimeter = cv::arcLength(contour, true);
        if (perimeter == 0) continue;
        double circularity = 4 * CV_PI * area / (perimeter * perimeter);
        
        if (circularity >= minCircularity) {
            // Create bounding rectangle and add to the results
            cv::Rect boundingRect = cv::boundingRect(contour);
            CGRect cgRect = CGRectMake(boundingRect.x, boundingRect.y, boundingRect.width, boundingRect.height);
            [circularContours addObject:[NSValue valueWithCGRect:cgRect]];
        }
    }
    
    return [circularContours copy];
}

+ (double)matchTemplate:(UIImage *)image withTemplate:(UIImage *)templateImage {
    cv::Mat img = uiImageToMat(image);
    cv::Mat tmpl = uiImageToMat(templateImage);
    cv::Mat result;

    // Perform template matching
    cv::matchTemplate(img, tmpl, result, cv::TM_CCOEFF_NORMED);
    double minVal, maxVal;
    cv::minMaxLoc(result, &minVal, &maxVal);
    
    return maxVal; // Return the highest matching score
}

@end
