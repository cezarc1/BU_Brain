//
//  BuBrainCredentials.m
//  BU Brain
//
//  Created by Cezar Cocu on 10/20/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import "BuBrainCredentials.h"
#define SERVICE @"BUBrain"

@interface BuBrainCredentials ()

@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * password;


@end

@implementation BuBrainCredentials

+(BuBrainCredentials*)sharedInstance{
    
    static BuBrainCredentials *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[BuBrainCredentials alloc ] init];
        _sharedClient.username = nil;
        _sharedClient.password = nil;
    });
    return _sharedClient;

}

-(NSArray*) getCredentials{
    
    NSArray *accounts = [SSKeychain accountsForService:SERVICE];
    if([accounts count] > 0 ) {
        //NSLog(@"Found keychain credentials");
        NSString *account = [[accounts objectAtIndex:0]objectForKey:kSSKeychainAccountKey];
        NSString *password = [SSKeychain passwordForService:SERVICE account:account];
        if( ![account isEqual:nil] && ![password isEqual:nil]){
            _username = account;
            _password = password;
            NSArray *arr = [[NSArray alloc] initWithObjects:_username,_password, nil];
            return arr;
        }
        
        
    }
    return NULL;
    
}
-(void) StoreUser: (NSString*) user andPassword: (NSString*) password{
    [SSKeychain setPassword:password forService: SERVICE account:user];
}

-(void) DeleteCredentialsForUser: (NSString *) user{
    [SSKeychain deletePasswordForService:SERVICE account:user];
}


@end
