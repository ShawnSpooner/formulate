//
//  RootViewController.h
//  formulate
//
//  Created by Shawn Spooner on 6/27/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeavesViewController.h"

@class PdfHelper, FormCollection;

@interface FormulateViewController : LeavesViewController<UIScrollViewDelegate, UITextFieldDelegate> {
    CGPDFDocumentRef pdf;
    CGPDFPageRef page;
    UIScrollView *scrollView;
    BOOL shouldScroll;
    BOOL keyboardIsShown;
}

@property (nonatomic, retain) FormCollection *formElements;

-(id)initWithPdf:(CFURLRef)pdfURL;
-(void)loadPdf:(CFURLRef)pdfURL;
-(void) attachKeyboardHandlers;


//keyboard notifications
-(void)keyboardShown:(NSNotification*) notif;

@end
