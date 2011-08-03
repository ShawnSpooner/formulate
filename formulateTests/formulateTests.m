//
//  formulateTests.m
//  formulateTests
//
//  Created by Shawn Spooner on 6/27/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import "formulateTests.h"
#import "PdfHelper.h"
#import "FormulateViewController.h"
#import "AnnotationData.h"

@implementation formulateTests

typedef NSString* (^StringBlock)();
- (void)setUp
{
    [super setUp];
    controller = [[FormulateViewController alloc] init];
    
    textFields = [[NSMutableDictionary alloc] init];
    signatureFields = [[NSMutableDictionary alloc] init];
    checkboxFields = [[NSMutableDictionary alloc] init];
    AnnotationData *data = [[AnnotationData alloc] initWithPosition:CGRectMake(0, 0, 10, 10) andValue:@"Slamchest" andDisplay:@"Last"];
    [textFields setObject:data forKey:@"LAST"];
    [checkboxFields setObject:data forKey:@"Check"];
    [signatureFields setObject:data forKey:@"Signature"];
}

- (void)tearDown
{
    // Tear-down code here.
    [controller release];
    [textFields release];
    [checkboxFields release];
    [signatureFields release];
    [super tearDown];
}


-(void)testFormElementsShouldReturAnTestWhenQueriedForLastName
{  
   [controller renderTextFields:textFields];
    StringBlock name = [[controller getFormElements] objectForKey:@"LAST"];
    STAssertTrue([name() isEqualToString:@"Test"] , @"value of last name field should be Test", name());
}

-(void)testFormElementsShouldReturnOnWhenChecked
{  
    [controller renderCheckboxFields:checkboxFields];
    StringBlock name = [[controller getFormElements] objectForKey:@"Check"];
    STAssertTrue([name() isEqualToString:@"On"] , @"value of check field should be true", name());
}


-(void)testFormElementsShouldReturnASignature
{  
    [controller renderSignatureFields:signatureFields];
    StringBlock name = [[controller getFormElements] objectForKey:@"Signature"];
    STAssertTrue([name() isEqualToString:@"Signature"] , @"value of last name field should be Signature", name());
}



@end
