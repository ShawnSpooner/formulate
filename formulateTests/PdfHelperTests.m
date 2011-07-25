//
//  PdfHelperTests.m
//  formulate
//
//  Created by Shawn Spooner on 6/28/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import "PdfHelperTests.h"
#import "PdfHelper.h"
#import "PDfAnnotations.h"
#import "AnnotationData.h"

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
    //NSLog(@"array contains %@", outputArray);
    STAssertEquals(38, count, @"the annots array should contain 38 fields", count); 
}

-(void)testRetrievingTheFormFieldsShouldReturn17TextFields
{
    PdfAnnotations* fields = [helper formElements:[helper formFieldsonPage:1]];
    int count = [[fields getTextFields] count];
    STAssertEquals(17, count, @"the annots array should contain 17 text fields on page 1", count);  
}

-(void)testLastNameShouldHaveDisplayNameOfLast
{
    PdfAnnotations* fields = [helper formElements:[helper formFieldsonPage:1]];
    AnnotationData* data = [[fields getTextFields] objectForKey:@"Name_Last"];
    STAssertTrue([data.toolTip isEqualToString:@"LAST"] , @"last name text field should have a display name of LAST", data.toolTip);
}

-(void)testLastNameShouldHaveTheCorrectDisplayCoordinates                                                                                                                                                                                                                                                                     
{
    PdfAnnotations* fields = [helper formElements:[helper formFieldsonPage:1]];
    AnnotationData* data = [[fields getTextFields] objectForKey:@"Name_Last"];
    CGRect expected = CGRectMake(30.119999, 400.91998, 272.75998, 419.64001);
    STAssertEquals(expected, data.position, @"the last name field shoudl be at the correct position", data.position);  
}

-(void)testRetrievingTheFormFieldsShouldReturn9CheckBoxFields
{
    PdfAnnotations* fields = [helper formElements:[helper formFieldsonPage:1]];
    int count = [[fields getCheckboxFields] count];
    STAssertEquals(9, count, @"the annots array should contain 9 checkbox fields on page 1", count);  
}

-(void)testRetrievingTheFormFieldsShouldReturn1SignatureField
{
    PdfAnnotations* fields = [helper formElements:[helper formFieldsonPage:1]];
    int count = [[fields getSignatureFields] count];
    STAssertEquals(1, count, @"the annots array should contain 1 signature fields on page 1", count);  
}

-(void)testEmployeeSignatureShouldHaveANameOfEmployeeSignature
{
    PdfAnnotations* fields = [helper formElements:[helper formFieldsonPage:1]];
    AnnotationData* data = [[fields getSignatureFields] objectForKey:@"EMPLOYEE SIGNATURE"];
    STAssertTrue([data.toolTip isEqualToString:@"EMPLOYEE SIGNATURE"] , @"Employee Signature Should Have A Name Of Employee Signature", data.toolTip);
}

-(void)testRetrievingTheFormFieldsShouldReturn1ChoiceFields
{
    PdfAnnotations* fields = [helper formElements:[helper formFieldsonPage:1]];
    int count = [[fields getChoiceFields] count];
    STAssertEquals(1, count, @"the annots array should contain 1 choice fields on page 1", count);  
}

-(void)testChoiceFieldShouldHave4Options
{
    PdfAnnotations* fields = [helper formElements:[helper formFieldsonPage:1]];
    AnnotationData* data = [[fields getChoiceFields] objectForKey:@"Position"];
    int count = data.values.count;
    STAssertEquals(4, count, @"the values array should contain four optins for the select list", count); 
}
@end
