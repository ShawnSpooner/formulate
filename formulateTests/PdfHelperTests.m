//
//  PdfHelperTests.m
//  formulate
//
//  Created by Shawn Spooner on 6/28/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import "PdfHelperTests.h"
#import "PdfHelper.h"


@implementation PdfHelperTests

- (void)setUp
{
    [super setUp];
    CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("form.pdf"), NULL, NULL);
    helper = [[PdfHelper alloc] initWithPdf:pdfURL];
    pdf = [PdfHelper load:pdfURL];
    CFRelease(pdfURL);
}

- (void)tearDown
{
    // Tear-down code here.
    [helper release];
    [super tearDown];
}


-(void)testAnnotsArrayShouldHave38Elements
{  
    CGPDFArrayRef outputArray = [helper formFieldsonPage:1];
    int count = CGPDFArrayGetCount(outputArray);
    STAssertEquals(38, count, @"the annots array should contain 38 fields", count);
}

-(void)testLoadShouldAllowAnnotationsToBeReturned
{
    CGPDFArrayRef outputArray = [PdfHelper annotations:pdf onPage:1];
    int count = CGPDFArrayGetCount(outputArray);
    STAssertEquals(38, count, @"the annots array should contain 38 fields", count);  
}

-(void)testRetrievingTheFormFieldsShouldReturn18TextFields
{
    NSDictionary* fields = [helper formElements:[helper formFieldsonPage:1]];
    int count = [fields count];
    STAssertEquals(18, count, @"the annots array should contain 18 text fields on page 1", count);  
}


@end
