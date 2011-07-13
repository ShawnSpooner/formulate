//
//  SimpleCheckbox.m
//  formulate
//
//  Created by Shawn Spooner on 7/13/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import "SimpleCheckbox.h"


@implementation SimpleCheckbox
@synthesize checked;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentLeft;
        
        [self setImage:[UIImage imageNamed: @"clear.png"] forState:UIControlStateNormal];
        
        [self addTarget:self action: @selector(clicked)forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(IBAction) clicked{
    if(checked == NO){
        checked = YES;
        [self setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
    }else{
        checked = NO;
        [self setImage:[UIImage imageNamed: @"clear.png"] forState:UIControlStateNormal];
    }
}


- (void)dealloc
{
    [super dealloc];
}

@end
