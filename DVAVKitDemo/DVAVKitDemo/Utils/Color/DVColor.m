//
//  MyTheme.m
//   
//
//  Created by My on 2017/11/29.
//  Copyright © 2017年 com.znjk.test. All rights reserved.
//

#import "DVColor.h"

@implementation DVColor

#pragma mark - <-- Custom -->
+ (UIColor *)theme {
//    return [UIColor colorWithHex:0x16AEB8];
    return [UIColor colorWithHex:0x131426];
}

+ (UIColor *)grayBackgroundColor {
    return [UIColor colorWithHex:0xF2F2F7];
}

+ (UIColor *)collectionViewBackgroundColor {
    return [UIColor whiteColor];
}

+ (UIColor *)cellViewBackgroundColor {
    return [UIColor whiteColor];
}


#pragma mark - <-------------------- Black -------------------->
+ (UIColor *)black1 {
    return [UIColor colorWithHex:0x2c2c2c];
}

+ (UIColor *)black2 {
    return [UIColor colorWithHex:0x515151];
}

+ (UIColor *)black3 {
    return [UIColor colorWithHex:0x707070];
}

+ (UIColor *)black4 {
    return [UIColor colorWithHex:0x8a8a8a];
}

+ (UIColor *)black5 {
    return [UIColor colorWithHex:0xbfbfbf];
}

+ (UIColor *)black6 {
    return [UIColor colorWithHex:0xcdcdcd];
}

+ (UIColor *)black7 {
    return [UIColor colorWithHex:0xdbdbdb];
}

+ (UIColor *)black8 {
    return [UIColor colorWithHex:0xe6e6e6];
}

@end
