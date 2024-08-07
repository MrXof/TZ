//
//  UIView+Blur.swift
//  Powerful Subliminals
//
//  Created by Oleksii Chernysh on 05.01.2021.
//

import UIKit

extension UIImage {
  
  func blurred(radius: CGFloat) -> UIImage {
    let context = CIContext(options: nil);
    let inputImage = CIImage(cgImage: self.cgImage!);
    let filter = CIFilter(name: "CIGaussianBlur");
    filter?.setValue(inputImage, forKey: kCIInputImageKey);
    filter?.setValue("\(radius)", forKey:kCIInputRadiusKey);
    let result = filter?.value(forKey: kCIOutputImageKey) as! CIImage
    let rect = CGRect(x: radius * 2.0,
                      y: radius * 2.0,
                      width: size.width * UIScreen.main.scale - radius * 4.0,
                      height: size.height * UIScreen.main.scale - radius * 4.0)
    let cgImage = context.createCGImage(result, from: rect)!
    let returnImage = UIImage(cgImage: cgImage);
    
    return returnImage;
  }
  
}
