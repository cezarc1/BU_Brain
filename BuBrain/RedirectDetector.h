//
//  RedirectDetector.h
//  BU Brain
//
//  Created by Cezar Cocu on 11/10/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface RedirectDetector : NSObject

@property (strong, nonatomic) NSURL *baseURL;

+ (RedirectDetector *)sharedClient;

-(void) checkAndUpdateForURL;
@end
