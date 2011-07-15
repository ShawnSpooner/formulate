//
//  FormulateViewContorller+MockFactory.m
//  formulate
//
//  Created by Shawn Spooner on 7/14/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import "FormulateViewContorller+MockFactory.h"
#import "OCMock/OCMock.h"

@implementation FormulateViewController (FormulateViewContorller_MockFactory)

-(UITextField*)buildTextFieldAt:(CGRect)position{
    id mock = [OCMockObject mockForClass:[UITextField class]];
    [[[mock stub] andReturn:@"Test"] text];
    return mock;
}

-(void)renderControl:(id)control{

}

@end
