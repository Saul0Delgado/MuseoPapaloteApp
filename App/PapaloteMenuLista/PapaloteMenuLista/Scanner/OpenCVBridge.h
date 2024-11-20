#ifndef OpenCVBridge_h
#define OpenCVBridge_h

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#endif

#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif

@interface OpenCVBridge : NSObject

// Expose methods using UIImage only
+ (UIImage *)convertToGrayscale:(UIImage *)image;
+ (UIImage *)maskForColor:(UIImage *)image minHSV:(NSArray<NSNumber *> *)minHSV maxHSV:(NSArray<NSNumber *> *)maxHSV;
+ (NSArray<NSValue *> *)findCircularContours:(UIImage *)image minCircularity:(double)minCircularity;
+ (double)matchTemplate:(UIImage *)image withTemplate:(UIImage *)templateImage;

@end

#ifdef __cplusplus
}
#endif

#endif /* OpenCVBridge_h */
