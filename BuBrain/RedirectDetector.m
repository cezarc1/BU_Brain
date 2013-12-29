//
//  RedirectDetector.m
//  BU Brain
//
//  Created by Cezar Cocu on 11/10/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import "RedirectDetector.h"

@implementation RedirectDetector
static NSString* originalURL = @"https://buonline.binghamton.edu";

+ (RedirectDetector *)sharedClient{
    static RedirectDetector * _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[RedirectDetector alloc] init];
        [_sharedClient setBaseURL:nil];
    });
    return _sharedClient;
}

-(void) checkAndUpdateForURL{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager GET:originalURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [self setBaseURL:[operation.response URL] ];
             
             NSString *valueToSave = [self.baseURL absoluteString];
             [[NSUserDefaults standardUserDefaults]
              setObject:valueToSave forKey:@"BU-Brain Sub Domain"];//NSUserDefaults
             
             NSLog(@"Resolved BuBrain URL: %@", operation.response.URL);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Possible Error: Might not have Resolved BuBrain URL: %@", error);
    }];
    
}


@end
