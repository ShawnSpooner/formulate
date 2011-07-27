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

@implementation FormulateViewController

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
    }
    return self;
}

-(void)loadPdf:(CFURLRef)pdfURL{
    NSLog(@"init pdf url of %@", pdfURL);
    pdfWrapper = [[PdfHelper alloc] initWithPdf:pdfURL];
    pdf = pdfWrapper.pdf;
    pdfFormElements = [[NSMutableDictionary alloc] init];
    pdfControlHandles = [[NSMutableArray alloc] init];
    [self cleanFormControls];
    [pdfControlHandles removeAllObjects];
}

-(void)cleanFormControls{
    for(UIView *control in pdfControlHandles){
        [control removeFromSuperview];
    } 
}

- (void)dealloc {
	[pdfWrapper release];
    [pdfFormElements release];
    [pdfControlHandles release];
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
    [self renderCheckboxFields:[fields getCheckboxFields]];
    [self renderSignatureFields:[fields getSignatureFields]];
    [self renderChoiceFields:[fields getChoiceFields]];
}

-(UITextField*)buildTextFieldAt:(CGRect)position{
    
    UITextField *pdfTextField = [[UITextField alloc] initWithFrame:position];
    pdfTextField.borderStyle = UITextBorderStyleRoundedRect;
    pdfTextField.delegate = self;
    //pdfTextField.placeholder = data.displayName;
    //pdfTextField.layer.borderColor=[[UIColor greenColor]CGColor];
    //pdfTextField.layer.borderWidth= 1.0f;
    //pdfTextField.layer.cornerRadius=8.0f;
    return pdfTextField;
}

-(void) renderTextFields:(NSDictionary*) fields{ 
    for(id key in fields){
        AnnotationData *data = [fields objectForKey:key];
        CGRect adjustedPosition = [self convertToDisplay:data.position];
        UITextField *pdfTextField = [self buildTextFieldAt: adjustedPosition];
        StringBlock value = ^{return pdfTextField.text ? : @"";};
        [pdfFormElements setObject:[value copy] forKey:key];
        [self renderControl:pdfTextField];
    }
}

-(SimpleCheckbox*)buildCheckboxAt:(CGRect)position{
    SimpleCheckbox *pdfCheckbox = [[SimpleCheckbox alloc] initWithFrame:position];
    
    CALayer * border = [pdfCheckbox layer];
    [border setMasksToBounds:YES];
    [border setBorderWidth:2.0];
    [border setBorderColor:[[UIColor greenColor] CGColor]];  
    return pdfCheckbox;
}

-(void) renderChoiceFields:(NSDictionary*) fields{ 
    
    for(id key in fields){
        AnnotationData *data = [fields objectForKey:key];
        CGRect adjustedPosition = [self convertToDisplay:data.position];
        SimplePicker *picker = [self buildDropDownAt:adjustedPosition andOptions:data.values];
        picker.borderStyle = UITextBorderStyleRoundedRect;
        StringBlock value= ^{return picker.text;};
        [pdfFormElements setObject:[value copy] forKey:key];
        [self renderControl:picker];
    }
}

-(SimplePicker*)buildDropDownAt:(CGRect)position andOptions:(NSArray*) options{
    position.origin.y = position.size.height > 0 ? : position.origin.y + position.size.height;
    position.size.height = position.size.height > 0 ? : -1 * position.size.height;
    SimplePicker *view = [[SimplePicker alloc] initWithFrame:position andData:options];
    return view;
}

-(SigningView*)buildSignatureFieldAt:(CGRect)position{
    //the sample signature fields have a negative height associated with them, convert it to a postive
    //and adjust the origin to account for the shift.
    position.origin.y = position.size.height > 0 ? : position.origin.y + position.size.height;
    position.size.height = position.size.height > 0 ? : -1 * position.size.height;
    SigningView *view = [[SigningView alloc] initWithFrame:position];
    return view;
}

-(void) renderSignatureFields:(NSDictionary*) fields{ 
    for(id key in fields){
        AnnotationData *data = [fields objectForKey:key];
        CGRect adjustedPosition = [self convertToDisplay:data.position];
        SigningView *signingArea = [self buildSignatureFieldAt:adjustedPosition];
        StringBlock value= ^{return [signingArea capture] ? : @"";};
        [pdfFormElements setObject:[value copy] forKey:key];
        [self renderControl:signingArea];
    }
}

-(void) renderCheckboxFields:(NSDictionary*) fields{ 
 
    for(id key in fields){
        AnnotationData *data = [fields objectForKey:key];
        CGRect adjustedPosition = [self convertToDisplay:data.position];
        SimpleCheckbox *pdfCheckbox = [self buildCheckboxAt:adjustedPosition];

        StringBlock value= ^{return pdfCheckbox.checked ? @"On" : @"Off";};
        [pdfFormElements setObject:[value copy] forKey:key];
        [self renderControl:pdfCheckbox];
    }
}

-(void)renderControl:(id)control{
    [scrollView addSubview:control];
    [pdfControlHandles addObject:control];
}

//Get a dictionary of the form elements keyed by name with a block that returns the value entered by the user
-(NSDictionary*)getFormElements{
    return pdfFormElements;    
}

-(CGRect)convertToDisplay:(CGRect)rawPosition{
    CGPoint newOrigin = [self convertPDFPointToViewPoint:CGPointMake(rawPosition.origin.x, rawPosition.origin.y)];
    CGPoint newTerminus = [self convertPDFPointToViewPoint:CGPointMake(rawPosition.size.width, rawPosition.size.height)];
    return CGRectMake(newOrigin.x, newOrigin.y, newTerminus.x - newOrigin.x, newTerminus.y - newOrigin.y);   
}

//taken from http://ipdfdev.com/2011/06/21/links-navigation-in-a-pdf-document-on-iphone-and-ipad/
- (CGPoint)convertPDFPointToViewPoint:(CGPoint)pdfPoint {
    CGPoint viewPoint = CGPointMake(0, 0);
    
    CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    
    int rotation = CGPDFPageGetRotationAngle(page);
    CGRect currentViewBounds = self.view.bounds;

    float width = cropBox.size.width != 0 ? cropBox.size.width : 1.0;
    float height = cropBox.size.height != 0 ? cropBox.size.height : 1.0;

    switch (rotation) {
        case 90:
        case -270:
            viewPoint.x = currentViewBounds.size.width * (pdfPoint.y - cropBox.origin.y) / height;
            viewPoint.y = currentViewBounds.size.height * (pdfPoint.x - cropBox.origin.x) / width;
            break;
        case 180:
        case -180:
            viewPoint.x = currentViewBounds.size.width * (cropBox.size.width - (pdfPoint.x - cropBox.origin.x)) / width;
            viewPoint.y = currentViewBounds.size.height * (pdfPoint.y - cropBox.origin.y) / cropBox.size.height;
            break;
        case -90:
        case 270:
            viewPoint.x = currentViewBounds.size.width * (cropBox.size.height - (pdfPoint.y - cropBox.origin.y)) / height;
            viewPoint.y = currentViewBounds.size.height * (cropBox.size.width - (pdfPoint.x - cropBox.origin.x)) / width;
            break;
        case 0:
        default:
            viewPoint.x = currentViewBounds.size.width * (pdfPoint.x - cropBox.origin.x) / width;
            viewPoint.y = currentViewBounds.size.height * (cropBox.size.height - pdfPoint.y) / height;
            break;
    }
    
    viewPoint.x = viewPoint.x + currentViewBounds.origin.x;
    viewPoint.y = viewPoint.y + currentViewBounds.origin.y;
    
    return viewPoint;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector (keyboardShown:)
                                          name: UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden) name:UIKeyboardWillHideNotification object:nil];
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

-(void)textFieldDidBeginEditing:(UITextField *)textField {
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
