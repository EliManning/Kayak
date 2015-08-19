//
//  DataObject.m
//  KayakExercise
//
//  Created by Er Li on 8/16/15.
//  Copyright (c) 2015 elieric. All rights reserved.
//

#import "DataObject.h"

@implementation DataObject

-(id)initWithCode:(NSString *)code
             name:(NSString *)name
          logoURL:(NSString *)logoURL
            phone:(NSString *)phone
             site:(NSString *)site{
    
    self = [super init];
    if(self)
    {
        self.code = code;
        self.name = name;
        self.logoURL = logoURL;
        self.phone = phone;
        self.site = site;
        
    }
    
    return self;
    
}
@end
