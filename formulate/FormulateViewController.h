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
}

-(void)loadPdf:(CFURLRef)pdfPath;
@end
