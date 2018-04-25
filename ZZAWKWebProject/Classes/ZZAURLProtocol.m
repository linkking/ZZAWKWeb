//
//  ZZAURLProtocol.m
//  H5-Demo-wk
//
//  Created by zhulei on 2018/4/9.
//  Copyright © 2018年 zs. All rights reserved.
//

#import "ZZAURLProtocol.h"

@implementation ZZAURLProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)theRequest{
    if ([theRequest.URL.scheme caseInsensitiveCompare:@"myapp"] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)theRequest{
    return theRequest;
}

-(void)startLoading {
    NSURLResponse *response = [[NSURLResponse alloc]initWithURL:[self.request URL] MIMEType:@"image/png" expectedContentLength:-1 textEncodingName:nil];
    NSString *imagePath = [self.request.URL.absoluteString componentsSeparatedByString:@"myapp://"].lastObject;
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self client] URLProtocol:self didLoadData:data];
    [[self client] URLProtocolDidFinishLoading:self];
}

-(void)stopLoading {
    
}
@end
