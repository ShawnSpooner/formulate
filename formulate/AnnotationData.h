//
//  AnnotationData.h
//  formulate
//
//  Created by Shawn Spooner on 7/11/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AnnotationData : NSObject {
@private
    
}

- (id)initWithPosition:(CGRect)position andDisplay:(NSString*)displayName;

@property CGRect position;
@property (nonatomic, retain) NSString* toolTip;
@property (nonatomic, retain) NSArray *values;

@end
