//
//  SimplePicker.h
//  formulate
//
//  Created by Shawn Spooner on 7/22/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimplePicker : UITextField<UITextFieldDelegate>{

@private
    NSArray *data;
   	NSInteger _selectedIndex;
}

-(id)initWithFrame:(CGRect)frame andData:(NSArray*)options;
@property (nonatomic, retain) NSArray *data;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, retain) id selectedObject;
@end
