//
//  ColorHelper.swift
//  CheckIn
//
//  Created by Anand Kelkar on 03/05/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit

public class ColorHelper {
    
    public static var color = false;
    
    public static var navBarColor:UIColor=UIColor.darkGray
    public static var labelColor:UIColor=UIColor.black
    public static var textColor:UIColor=UIColor.black
    public static var lineColor:UIColor=UIColor.darkGray
    public static var navTextColor:UIColor=UIColor.black
    
    public class func switchToColor(){
        navBarColor=UIColor(red:2,green:86,blue:0) //Green
        labelColor=UIColor(red:3,green:129,blue:0)
        textColor=UIColor(red:253,green:201,blue:16) 
        lineColor=UIColor(red:3,green:129,blue:0) //Very slightly brighter green
        navTextColor=UIColor(red:253,green:201,blue:16) //Yellow
        color = true;
    }
    
    public class func switchToGrayScale(){
        navBarColor=UIColor.darkGray
        labelColor=UIColor.black
        textColor=UIColor.black
        lineColor=UIColor.darkGray
        navTextColor=UIColor.black
        color = false;
    }
    
    
}
