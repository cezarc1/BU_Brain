//
//  BuBrainCredentials.h
//  BU Brain
//
//  Created by Cezar Cocu on 10/20/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CaptureCredentialsController.h"
#import "SSKeychain.h"


@interface BuBrainCredentials : NSObject 

+(BuBrainCredentials*)sharedInstance;
-(NSArray*) getCredentials;

-(void) StoreUser: (NSString*) user andPassword: (NSString*) password;

-(void) DeleteCredentialsForUser: (NSString *) user;

@end
