//
//  FormulateViewContorller+MockFactory.h
//  formulate
//
//  Created by Shawn Spooner on 7/14/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormCollection.h"
@class SimpleCheckbox, SigningView;

@interface FormCollection (FormCollection_MockFactory)

-(UITextField*)buildTextFieldAt:(CGRect)position;
-(SimpleCheckbox*)buildCheckboxAt:(CGRect)position;
-(SigningView*)buildSignatureFieldAt:(CGRect)position;
-(void)renderControl:(id)control;

@end
