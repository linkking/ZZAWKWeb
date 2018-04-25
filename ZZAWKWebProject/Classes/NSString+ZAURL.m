//
//  NSString+ZAURL.m
//  H5-Demo-wk
//
//  Created by zhulei on 2018/4/9.
//  Copyright © 2018年 zs. All rights reserved.
//

#import "NSString+ZAURL.h"

@implementation NSString (ZAURL)

-(NSURL *)url {
//    NSString *str = [self stringByAddingPercentEncodingWithAllowedCharacters:@"!$&'()*+,-./:;=?@_~%#[]"];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    return [NSURL URLWithString:(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, (CFStringRef)@"!$&()'+,-./:;=?@_~%#[]*", NULL, kCFStringEncodingUTF8))];
#pragma clang diagnostic pop

}

@end
