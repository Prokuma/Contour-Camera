//
//  OpenCVWrapper.mm
//  contours_detector
//
//  Created by Prokuma on 2018/10/02.
//  Copyright © 2018 Prokuma. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.h"

@implementation OpenCVWrapper

- (UIImage *) contours : (UIImage *) image{
    // Transform UIImage to cv::Mat
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);

    /*if (imageMat.channels() == 1)
        return image;
    
    // Transform the cv::mat color image to gray
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, CV_BGR2GRAY);
    
    UIImage* result = MatToUIImage(grayMat);
    NSLog(@"%f", result.size.height);
    return result;*/
    
    //NSLog(@"%f", image.size.height);
    // Create Mask Mat
    cv::Size imgSize = imageMat.size();
    cv::Mat maskMat(imgSize.height, imgSize.width, CV_8UC3, cv::Scalar(255,255,255));
    //NSLog(@"height:%i width:%i", imageMat.size().height, imageMat.size().width);
    
    // Contrast
    cv::Mat contrastMat;
    cv::addWeighted(imageMat, 2.0, imageMat, 0, -127, contrastMat);
    
    // Color to Gray
    cv::Mat grayMat;
    cv::cvtColor(contrastMat, grayMat, CV_BGR2GRAY);
    
    // Gaussian Blur
    cv::Mat gaussianMat;
    cv::GaussianBlur(grayMat, gaussianMat, cv::Size(3,3), 0);
    
    // Canny
    cv::Mat cannyMat;
    cv::Canny(gaussianMat, cannyMat, 50, 200);
    
    // Threshold
    cv::Mat thresholdMat;
    cv::threshold(cannyMat, thresholdMat, 30, 255, cv::THRESH_BINARY);
    
    // Find Contours
    std::vector<std::vector<cv::Point>> contours;
    cv::findContours(thresholdMat, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    
    //cv::drawContours(maskMat, contours, -1, cv::Scalar(0, 0, 0), 2);
    for(int i = 0; i < contours.size(); i++){
        cv::Rect rect;
        rect = cv::boundingRect(contours[i]);
        
        double epsilon = 0.0001 * cv::arcLength(contours[i], true);
        std::vector<cv::Point> approx;
        cv::approxPolyDP(contours[i], approx, epsilon, true);
        std::vector<std::vector<cv::Point>> approxs = {approx};
        cv::drawContours(maskMat, approxs, -1, cv::Scalar(0, 0, 0), 2);
    }
    
    //NSLog(@"%i", maskMat.size().height);
    UIImage *result = MatToUIImage(maskMat);
    return result;
}

@end
