//
//  main.swift
//  SwizzlingInSwift
//
//  Created by Umberto Raimondi on 22/10/15.
//  Copyright © 2015 Umberto Raimondi. All rights reserved.
//

import Foundation


class TestSwizzling : NSObject {
    dynamic func methodOne()->Int{
        return 1
    }
}


extension TestSwizzling {
    
    //In Objective-C you'd perform the swizzling in load() , but this method is not permitted in Swift
    override class func initialize()
    {
        struct Static
        {
            static var token: dispatch_once_t = 0;
        }
        
        // make sure this isn't a subclass
        if (self !== TestSwizzling.self)
        {
            return;
        }
        
        // Perform this one time only
        dispatch_once(&Static.token)
            {
                let originalSelector = Selector("methodOne");
                let swizzledSelector = Selector("methodTwo");
                
                let originalMethod = class_getInstanceMethod(self, originalSelector);
                let swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
                
                let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
                
                if didAddMethod
                {
                    class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
                }
                else
                {
                    method_exchangeImplementations(originalMethod, swizzledMethod);
                }
        }
    }
    
    func methodTwo()->Int{
        // It will not be a recursive call anymore after the swizzling
        return methodTwo()+1
    }
}

var c = TestSwizzling()
print(c.methodOne())
print(c.methodTwo())


