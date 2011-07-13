//
//  SimpleCheckbox.h
//  formulate
//
//  Created by Shawn Spooner on 7/13/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SimpleCheckbox : UIButton {
@private
    BOOL checked;
}

@property BOOL checked;

-(IBAction) clicked;
@end
