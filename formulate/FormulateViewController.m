//
//  RootViewController.m
//  formulate
//
//  Created by Shawn Spooner on 6/27/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import "FormulateViewController.h"
#import "Utilities.h"
#import "PdfHelper.h"
#import "PdfAnnotations.h"
#import "AnnotationData.h"

@implementation FormulateViewController


- (id)init {
    if ((self = [super init])) {
		CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("form.pdf"), NULL, NULL);
		NSLog(@"init pdf url of %@", pdfURL);
		pdfWrapper = [[PdfHelper alloc] initWithPdf:pdfURL];
        pdf = pdfWrapper.pdf;
        CFRelease(pdfURL);
    }
    return self;
}

- (void)dealloc {
    CFRelease(page);
	[pdfWrapper release];
    [super dealloc];
}

- (void) displayPageNumber:(NSUInteger)pageNumber {
	self.navigationItem.title = [NSString stringWithFormat:
								 @"Page %u of %u", 
								 pageNumber, 
								 CGPDFDocumentGetNumberOfPages(pdf)];
}

#pragma mark  LeavesViewDelegate methods

- (void) leavesView:(LeavesView *)leavesView willTurnToPageAtIndex:(NSUInteger)pageIndex {
	[self displayPageNumber:pageIndex + 1];
}

#pragma mark LeavesViewDataSource methods

- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView {
	return CGPDFDocumentGetNumberOfPages(pdf);
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
    int pageNumber = index + 1;
    NSLog(@"Rendering page at %d", pageNumber);
	page = CGPDFDocumentGetPage(pdf, pageNumber);
	CGAffineTransform transform = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox),
											CGContextGetClipBoundingBox(ctx));
	CGContextConcatCTM(ctx, transform);
	CGContextDrawPDFPage(ctx, page);
    
    PdfAnnotations *fields = [pdfWrapper formElements:[pdfWrapper formFieldsonPage:pageNumber]];
    [self renderTextFields:[fields getTextFields]];
}

-(void) renderTextFields:(NSDictionary*) fields{ 
    for(id key in fields){
        AnnotationData *data = [fields objectForKey:key];
        CGRect rawPosition = data.position;
        
        CGPoint newOrigin = [self convertPDFPointToViewPoint:CGPointMake(rawPosition.origin.x, rawPosition.origin.y)];
        CGPoint newTerminus = [self convertPDFPointToViewPoint:CGPointMake(rawPosition.size.width, rawPosition.size.height)];

        CGRect adjustedPosition = CGRectMake(newOrigin.x, newOrigin.y, newTerminus.x - newOrigin.x, newTerminus.y - newOrigin.y);
        UITextField *pdfTextField = [[UITextField alloc] initWithFrame:adjustedPosition];
        pdfTextField.borderStyle = UITextBorderStyleRoundedRect;
        pdfTextField.placeholder = data.displayName;
        [[self view] addSubview:pdfTextField];
    }
}

//taken from http://ipdfdev.com/2011/06/21/links-navigation-in-a-pdf-document-on-iphone-and-ipad/
- (CGPoint)convertPDFPointToViewPoint:(CGPoint)pdfPoint {
    CGPoint viewPoint = CGPointMake(0, 0);
    
    CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    
    int rotation = CGPDFPageGetRotationAngle(page);
    CGRect currentViewBounds = [[self view] frame];
    
    switch (rotation) {
        case 90:
        case -270:
            viewPoint.x = currentViewBounds.size.width * (pdfPoint.y - cropBox.origin.y) / cropBox.size.height;
            viewPoint.y = currentViewBounds.size.height * (pdfPoint.x - cropBox.origin.x) / cropBox.size.width;
            break;
        case 180:
        case -180:
            viewPoint.x = currentViewBounds.size.width * (cropBox.size.width - (pdfPoint.x - cropBox.origin.x)) / cropBox.size.width;
            viewPoint.y = currentViewBounds.size.height * (pdfPoint.y - cropBox.origin.y) / cropBox.size.height;
            break;
        case -90:
        case 270:
            viewPoint.x = currentViewBounds.size.width * (cropBox.size.height - (pdfPoint.y - cropBox.origin.y)) / cropBox.size.height;
            viewPoint.y = currentViewBounds.size.height * (cropBox.size.width - (pdfPoint.x - cropBox.origin.x)) / cropBox.size.width;
            break;
        case 0:
        default:
            viewPoint.x = currentViewBounds.size.width * (pdfPoint.x - cropBox.origin.x) / cropBox.size.width;
            viewPoint.y = currentViewBounds.size.height * (cropBox.size.height - pdfPoint.y) / cropBox.size.height;
            break;
    }
    
    viewPoint.x = viewPoint.x + currentViewBounds.origin.x;
    viewPoint.y = viewPoint.y + currentViewBounds.origin.y;
    
    return viewPoint;
}

- (void) viewDidLoad {
	[super viewDidLoad];
	leavesView.backgroundRendering = YES;
	[self displayPageNumber:1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

@end
