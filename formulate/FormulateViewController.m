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
#import "SimpleCheckbox.h"
#import "SigningView.h"
#import "SimplePicker.h"
#import "FormCollection.h"

@implementation FormulateViewController

@synthesize formElements;

typedef NSString* (^StringBlock)();

- (id)init {
    CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("form.pdf"), NULL, NULL);
    return [self initWithPdf:pdfURL];
}

- (id)initWithPdf:(CFURLRef)pdfURL{
    if ((self = [super init])) {
        [self loadPdf:pdfURL];
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.delegate = self;
        [self.view addSubview:scrollView];
        [scrollView addSubview:leavesView];
        PdfHelper *pdfWrapper = [[PdfHelper alloc] initWithPdf:pdfURL];
        pdf = pdfWrapper.pdf;
        formElements = [[FormCollection alloc] initWithPdf:pdfWrapper andView:scrollView];
        [formElements addObserver:self forKeyPath:@"textFieldBeingUpdated" options:NSKeyValueObservingOptionNew context:Nil];
    }
    return self;
}

-(void)loadPdf:(CFURLRef)pdfURL{
    NSLog(@"init pdf url of %@", pdfURL);
    PdfHelper *pdfWrapper = [[PdfHelper alloc] initWithPdf:pdfURL];
    pdf = pdfWrapper.pdf;
    //formElements = [[FormCollection alloc] initWithPdf:pdfWrapper andView:scrollView];
}

- (void)dealloc {
    [super dealloc];
}

- (void) displayPageNumber:(NSUInteger)pageNumber {
	self.navigationItem.title = [NSString stringWithFormat:
								 @"Page %u of %u", 
								 pageNumber, 
								 CGPDFDocumentGetNumberOfPages(pdf)];
  [formElements moveToPage:pageNumber];
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
    [formElements moveToPage:pageNumber];
}


//

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
    [self attachKeyboardHandlers];
    [super viewDidAppear:animated];
}

-(void) attachKeyboardHandlers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardShown:)
                                                 name: UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden) name:UIKeyboardWillHideNotification object:nil];   
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    UITextField *textField = [change objectForKey:keyPath];
    shouldScroll = textField.frame.origin.y > 740;//change this to be less hacky  
}

-(void)keyboardShown:(NSNotification*) notif{
    if (keyboardIsShown) {
        return;
    }
    NSDictionary* userInfo = [notif userInfo];
    
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [boundsValue CGRectValue].size;
    if(shouldScroll){
        [scrollView setContentOffset:CGPointMake(0, keyboardSize.height) animated:YES];
    }
    keyboardIsShown = YES;
}

-(void)keyboardHidden{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    keyboardIsShown = NO;
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
