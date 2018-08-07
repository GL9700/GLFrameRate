//
//  GLFrameRate.h
//  GLFrameRate
//
//  Created by liguoliang on 2018/8/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GLFrameRate : NSObject
@property (nonatomic,assign,getter=isEnabled) BOOL enabled;

+ (instancetype)sharedFrameRate;
@end
