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

@implementation FormulateViewController


- (id)init {
    if (self = [super init]) {
		CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("form.pdf"), NULL, NULL);
		NSLog(@"init pdf url of %@", pdfURL);
        pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
		pdfWrapper = [[PdfHelper alloc] initWithPdf:pdfURL]; 
        CFRelease(pdfURL);
    }
    return self;
}

-(void)loadPdf:(CFURLRef) pdfURL {
    NSLog(@"pdf url of %@", pdfURL);
    pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
    CFRelease(pdfURL);
}

- (void)dealloc {
	CGPDFDocumentRelease(pdf);
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
    NSLog(@"Rendering page at %d", index + 1);
	CGPDFPageRef page = CGPDFDocumentGetPage(pdf, index + 1);
	CGAffineTransform transform = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox),
											CGContextGetClipBoundingBox(ctx));
	CGContextConcatCTM(ctx, transform);
	CGContextDrawPDFPage(ctx, page);
    
    CGPDFPageRef pageAd = CGPDFDocumentGetPage(pdf, index);
    
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(pageAd);
    
    CGPDFArrayRef outputArray;
    if(!CGPDFDictionaryGetArray(pageDictionary, "Annots", &outputArray)) {
        NSLog(@"bailing out %@  ad is %@ index %d", pageDictionary, pageAd, index);
        return;
    }
    
    int arrayCount = CGPDFArrayGetCount( outputArray );
    
    for( int j = 0; j < arrayCount; ++j ) {
        CGPDFObjectRef aDictObj;
        if(!CGPDFArrayGetObject(outputArray, j, &aDictObj)) {
            return;
        }
        
        CGPDFDictionaryRef annotDict;
        if(!CGPDFObjectGetValue(aDictObj, kCGPDFObjectTypeDictionary, &annotDict)) {
            return;
        }
        
        CGPDFDictionaryRef aDict;
        if(!CGPDFDictionaryGetDictionary(annotDict, "A", &aDict)) {
            return;
        }
        
        CGPDFStringRef uriStringRef;
        if(!CGPDFDictionaryGetString(aDict, "URI", &uriStringRef)) {
            return;
        }
        
        CGPDFArrayRef rectArray;
        if(!CGPDFDictionaryGetArray(annotDict, "Rect", &rectArray)) {
            return;
        }
        
        int arrayCount = CGPDFArrayGetCount( rectArray );
        CGPDFReal coords[4];
        for( int k = 0; k < arrayCount; ++k ) {
            CGPDFObjectRef rectObj;
            if(!CGPDFArrayGetObject(rectArray, k, &rectObj)) {
                return;
            }
            
            CGPDFReal coord;
            if(!CGPDFObjectGetValue(rectObj, kCGPDFObjectTypeReal, &coord)) {
                return;
            }
            
            coords[k] = coord;
        }               
    }
}

/*-(void) bogusRender{
  
    CGPDFPageRef page = CGPDFDocumentGetPage(pdf, index+1);
    CGAffineTransform transform1 = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox),
                                             CGContextGetClipBoundingBox(ctx));
    CGContextConcatCTM(ctx, transform1);
    CGContextDrawPDFPage(ctx, page);
    
    
    CGPDFPageRef pageAd = CGPDFDocumentGetPage(pdf, index);
    
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(pageAd);
    
    CGPDFArrayRef outputArray;
    if(!CGPDFDictionaryGetArray(pageDictionary, "Annots", &outputArray)) {
        return;
    }
    
    int arrayCount = CGPDFArrayGetCount( outputArray );
    if(!arrayCount) {
        //continue;
    }
    
    for( int j = 0; j < arrayCount; ++j ) {
        CGPDFObjectRef aDictObj;
        if(!CGPDFArrayGetObject(outputArray, j, &aDictObj)) {
            return;
        }
        
        CGPDFDictionaryRef annotDict;
        if(!CGPDFObjectGetValue(aDictObj, kCGPDFObjectTypeDictionary, &annotDict)) {
            return;
        }
        
        CGPDFDictionaryRef aDict;
        if(!CGPDFDictionaryGetDictionary(annotDict, "A", &aDict)) {
            return;
        }
        
        CGPDFStringRef uriStringRef;
        if(!CGPDFDictionaryGetString(aDict, "URI", &uriStringRef)) {
            return;
        }
        
        CGPDFArrayRef rectArray;
        if(!CGPDFDictionaryGetArray(annotDict, "Rect", &rectArray)) {
            return;
        }
        
        int arrayCount = CGPDFArrayGetCount( rectArray );
        CGPDFReal coords[4];
        for( int k = 0; k < arrayCount; ++k ) {
            CGPDFObjectRef rectObj;
            if(!CGPDFArrayGetObject(rectArray, k, &rectObj)) {
                return;
            }
            
            CGPDFReal coord;
            if(!CGPDFObjectGetValue(rectObj, kCGPDFObjectTypeReal, &coord)) {
                return;
            }
            
            coords[k] = coord;
        }               
        
        char *uriString = (char *)CGPDFStringGetBytePtr(uriStringRef);
        
        NSString *uri = [NSString stringWithCString:uriString encoding:NSUTF8StringEncoding];
        CGRect rect = CGRectMake(coords[0],coords[1],coords[2],coords[3]);
        CGPDFInteger pageRotate = 0;
        CGPDFDictionaryGetInteger( pageDictionary, "Rotate", &pageRotate ); 
        CGRect pageRect = CGRectIntegral( CGPDFPageGetBoxRect( page, kCGPDFMediaBox ));
        if( pageRotate == 90 || pageRotate == 270 ) {
            CGFloat temp = pageRect.size.width;
            pageRect.size.width = pageRect.size.height;
            pageRect.size.height = temp;
        }
        
        rect.size.width -= rect.origin.x;
        rect.size.height -= rect.origin.y;
        
        CGAffineTransform trans = CGAffineTransformIdentity;
        trans = CGAffineTransformTranslate(trans, 35, pageRect.size.height+150);
        trans = CGAffineTransformScale(trans, 1.15, -1.15);
        
        rect = CGRectApplyAffineTransform(rect, trans);
        
        //urlLink = [NSURL URLWithString:uri];
        [//urlLink retain];
        
        //Create a button to get link actions
        //button = [[UIButton alloc] initWithFrame:rect];
        //[button setBackgroundImage:[UIImage imageNamed:@"link_bg.png"] forState:UIControlStateHighlighted];
        //[button addTarget:self action:@selector(openLink:) forControlEvents:UIControlEventTouchUpInside];
        //[self.view addSubview:button];
    }   
    [leavesView reloadData];
}*/


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
