//
//  FMEvent.h
//  Find Me!
//
//  Created by Martin Goffan on 8/29/12.
//
//

#import <Foundation/Foundation.h>

@interface FMEvent : NSObject

@property (strong, nonatomic) NSString *endTime;
@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) UIImage *image;

@end
