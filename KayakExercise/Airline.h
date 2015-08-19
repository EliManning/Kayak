//
//  Entity.h
//  KayakExercise
//
//  Created by Er Li on 8/18/15.
//  Copyright (c) 2015 elieric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Airline : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * logoURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * site;

@end
