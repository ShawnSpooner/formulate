//
//  FormCollection.m
//  formulate
//
//  Created by Shawn Spooner on 8/15/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import "FormCollection.h"
#import "Utilities.h"
#import "PdfHelper.h"
#import "PdfAnnotations.h"
#import "AnnotationData.h"
#import "SimpleCheckbox.h"
#import "SigningView.h"
#import "SimplePicker.h"
#import <QuartzCore/QuartzCore.h>

typedef NSString* (^StringBlock)();

@implementation FormCollection

@synthesize mainView, pdfWrapper, textFieldBeingUpdated;

-(id) initWithPdf:(PdfHelper*)wrapper andView:(UIView*)view{
    if ((self = [super init])) {
        pdfWrapper = wrapper;
        mainView = view;
        formValues = [[NSMutableDictionary alloc] init];
        pdfPages = [[NSMutableDictionary alloc] init];
    }
    return self;
  
}

-(void) moveToPage:(int)pageNumber{
    [self cleanFormControls];
    currentPage = [NSNumber numberWithInt:pageNumber];
    if([pdfPages objectForKey:currentPage] == nil){
        page = CGPDFDocumentGetPage(pdfWrapper.pdf, pageNumber);  
        [pdfPages setObject:[[NSMutableArray alloc] init] forKey:currentPage];
        PdfAnnotations *fields = [pdfWrapper formElements:[pdfWrapper formFieldsonPage:pageNumber]];
        [self renderTextFields:[fields getTextFields]];
        [self renderCheckboxFields:[fields getCheckboxFields]];
        [self renderSignatureFields:[fields getSignatureFields]];
        [self renderChoiceFields:[fields getChoiceFields]];
    }else{
        for(UIView *control in [pdfPages objectForKey:currentPage]){
            [mainView addSubview:control];
        } 
    }

}

-(void)cleanFormControls{
    for(UIView *control in [pdfPages objectForKey:currentPage]){
        [control removeFromSuperview];
    }
}

-(UITextField*)buildTextFieldAt:(CGRect)position{
    
    UITextField *pdfTextField = [[UITextField alloc] initWithFrame:position];
    pdfTextField.borderStyle = UITextBorderStyleRoundedRect;
    pdfTextField.delegate = self;
    //pdfTextField.placeholder = data.displayName;
    //pdfTextField.layer.borderColor=[[UIColor greenColor]CGColor];
    //pdfTextField.layer.borderWidth= 1.0f;
    //pdfTextField.layer.cornerRadius=8.0f;
    return [pdfTextField autorelease];
}

-(void) renderTextFields:(NSDictionary*) fields{ 
    for(id key in fields){
        AnnotationData *data = [fields objectForKey:key];
        CGRect adjustedPosition = [self convertToDisplay:data.position];
        UITextField *pdfTextField = [self buildTextFieldAt: adjustedPosition];
        pdfTextField.text = data.value;
        StringBlock value = ^{return pdfTextField.text ? : @"";};
        [formValues setObject:[[value copy] autorelease] forKey:key];
        [self renderControl:pdfTextField];
    }
}

-(SimpleCheckbox*)buildCheckboxAt:(CGRect)position{
    SimpleCheckbox *pdfCheckbox = [[SimpleCheckbox alloc] initWithFrame:position];
    CALayer * border = pdfCheckbox.layer;
    border.masksToBounds = YES;
    border.borderWidth = 2.0;
    border.borderColor = [[UIColor greenColor] CGColor];  
    return [pdfCheckbox autorelease];
}

-(void) renderChoiceFields:(NSDictionary*) fields{ 
    
    for(id key in fields){
        AnnotationData *data = [fields objectForKey:key];
        CGRect adjustedPosition = [self convertToDisplay:data.position];
        SimplePicker *picker = [self buildDropDownAt:adjustedPosition andOptions:data.options];
        picker.borderStyle = UITextBorderStyleRoundedRect;
        StringBlock value= ^{return picker.text;};
        [formValues setObject:[[value copy] autorelease] forKey:key];
        [self renderControl:picker];
    }
}

-(SimplePicker*)buildDropDownAt:(CGRect)position andOptions:(NSArray*) options{
    position.origin.y = position.size.height > 0 ? : position.origin.y + position.size.height;
    position.size.height = position.size.height > 0 ? : -1 * position.size.height;
    SimplePicker *view = [[SimplePicker alloc] initWithFrame:position andData:options];
    return [view autorelease];
}

-(SigningView*)buildSignatureFieldAt:(CGRect)position{
    //the sample signature fields have a negative height associated with them, convert it to a postive
    //and adjust the origin to account for the shift.
    position.origin.y = position.size.height > 0 ? : position.origin.y + position.size.height;
    position.size.height = position.size.height > 0 ? : -1 * position.size.height;
    SigningView *view = [[SigningView alloc] initWithFrame:position];
    return [view autorelease];
}

-(void) renderSignatureFields:(NSDictionary*) fields{ 
    for(id key in fields){
        AnnotationData *data = [fields objectForKey:key];
        CGRect adjustedPosition = [self convertToDisplay:data.position];
        SigningView *signingArea = [self buildSignatureFieldAt:adjustedPosition];
        StringBlock value= ^{return [signingArea capture] ? : @"";};
        [formValues setObject:[[value copy] autorelease] forKey:key];
        [self renderControl:signingArea];
    }
}

-(void) renderCheckboxFields:(NSDictionary*) fields{ 
    
    for(id key in fields){
        AnnotationData *data = [fields objectForKey:key];
        CGRect adjustedPosition = [self convertToDisplay:data.position];
        SimpleCheckbox *pdfCheckbox = [self buildCheckboxAt:adjustedPosition];
        
        StringBlock value= ^{return pdfCheckbox.checked ? @"On" : @"Off";};
        [formValues setObject:[[value copy] autorelease] forKey:key];
        [self renderControl:pdfCheckbox];
    }
}

-(void)renderControl:(id)control{
    [mainView addSubview:control];
    [[pdfPages objectForKey:currentPage] addObject:control];
}

//Get a dictionary of the form elements keyed by name with a block that returns the value entered by the user
-(NSDictionary*)getFormElements{
    return formValues;    
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
    CGRect currentViewBounds = mainView.bounds;
    
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

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.textFieldBeingUpdated = textField;
}

- (void)dealloc {
    [formValues release];
    [currentPage release];
    [mainView release];
    [super dealloc];
}

@end
