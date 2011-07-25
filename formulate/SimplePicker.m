//
//  SimplePicker.m
//  formulate
//
//  Created by Shawn Spooner on 7/22/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import "SimplePicker.h"
#import "ActionSheetPicker.h"

@implementation SimplePicker
@synthesize selectedObject, data, selectedIndex;

//#TODO add in the init with title so not all are bound to Select Option
- (id)init
{
    self = [super init];
    if (self) {
    
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame andData:(NSArray*)options{
    data = [[NSArray alloc] initWithArray:options];
    [self addTarget:self action: @selector(selectAnItem)forControlEvents:UIControlEventTouchDown];
    self.delegate = self;
    return [super initWithFrame:frame];
}

- (void)selectAnItem{
    [ActionSheetPicker displayActionPickerWithView:self data:self.data selectedIndex:self.selectedIndex target:self action:@selector(itemWasSelected::) title:@"Select Option"];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return NO;
}
#pragma mark -
#pragma mark Implementation

- (void)itemWasSelected:(NSNumber *)index:(id)element {
	//Selection was made
	self.selectedIndex = [index intValue];
	[self setText:[self.data objectAtIndex:self.selectedIndex]];
}

- (void)dealloc
{
    [data release];
    [super dealloc];
}

@end
