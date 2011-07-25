//
//  AnnotationData.m
//  formulate
//
//  Created by Shawn Spooner on 7/11/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import "AnnotationData.h"



@implementation AnnotationData
@synthesize position, values, toolTip;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithPosition:(CGRect)coordinates andDisplay:(NSString*)name
{
    self = [super init];
    if (self) {
        self.position = coordinates;
        self.toolTip = name;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    
}

@end
