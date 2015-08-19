//
//  DataManager.h
//  KayakExercise
//
//  Created by Er Li on 8/16/15.
//  Copyright (c) 2015 elieric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

+(DataManager *)sharedInstance;

-(NSArray *)parseInfoFromJSON:(NSData *) JSONData error:(NSError **)error;


    
@end
