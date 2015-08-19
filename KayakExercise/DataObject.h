//
//  DataObject.h
//  KayakExercise
//
//  Created by Er Li on 8/16/15.
//  Copyright (c) 2015 elieric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataObject : NSObject

@property (nonatomic) NSString *clazz;
@property (nonatomic) NSString *code;
@property (nonatomic) NSString *logoURL;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *site;

-(id)initWithCode:(NSString *)code
             name:(NSString *)name
          logoURL:(NSString *)logoURL
            phone:(NSString *)phone
             site:(NSString *)site;

@end
