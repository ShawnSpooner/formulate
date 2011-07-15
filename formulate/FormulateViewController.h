//
//  RootViewController.h
//  formulate
//
//  Created by Shawn Spooner on 6/27/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeavesViewController.h"

@class PdfHelper;

@interface FormulateViewController : LeavesViewController {
    CGPDFDocumentRef pdf;
    PdfHelper* pdfWrapper;
    CGPDFPageRef page;
    NSMutableDictionary *pdfFormElements;
}

-(id)initWithPdf:(CFURLRef)pdfURL;
-(void) renderTextFields:(NSDictionary*) fields;
-(void) renderCheckboxFields:(NSDictionary*) fields;
//taken from here http://ipdfdev.com/2011/06/21/links-navigation-in-a-pdf-document-on-iphone-and-ipad/
-(CGPoint)convertPDFPointToViewPoint:(CGPoint)pdfPoint;
-(CGRect)convertToDisplay:(CGRect)rawPosition;
-(void) renderSignatureFields:(NSDictionary*) fields;
-(NSMutableDictionary*)getFormElements;
-(void)renderControl:(id)control;
//Factory methods
-(UITextField*)buildTextFieldAt:(CGRect)position;
@end
