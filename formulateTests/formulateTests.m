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
    AnnotationData *data = [[AnnotationData alloc] initWithPosition:CGRectMake(0, 0, 10, 10) andDisplay:@"Last"];
    [textFields setObject:data forKey:@"LAST"];
}

- (void)tearDown
{
    // Tear-down code here.
    [controller release];
    [super tearDown];
}


-(void)testFormElementsShouldReturAnTestWhenQueriedForLastName
{  
   [controller renderTextFields:textFields];
    StringBlock name = [[controller getFormElements] objectForKey:@"LAST"];
    STAssertTrue([name() isEqualToString:@"Test"] , @"value of last name field should be Test", name());
}


-(void)testSimpleLamdaTest
{  
    NSString* (^value)()= ^{return nil ? : @"value";};
    STAssertTrue([value() isEqualToString:@"value"] , @"value of text field should be value", value());
}
@end
