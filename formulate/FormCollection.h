//
//  FormCollection.h
//  formulate
//
//  Created by Shawn Spooner on 8/15/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PdfHelper, SimpleCheckbox, SigningView, SimplePicker;

@interface FormCollection : NSObject<UITextFieldDelegate>{
    NSMutableDictionary *formValues;
    NSMutableDictionary *pdfPages;
    UIView *mainView;
    NSNumber *currentPage;
    CGPDFPageRef page;
    PdfHelper* pdfWrapper;
}

@property(nonatomic, retain) UIView *mainView;
@property(nonatomic, retain) PdfHelper *pdfWrapper;
@property(nonatomic, retain) UITextField *textFieldBeingUpdated;

-(id) initWithPdf:(PdfHelper*)wrapper andView:(UIView*)view;
-(void) moveToPage:(int)page;

/*
 Renders the provided data annotations as UiTextFields onto the current pdf page
 @param fields - a dictionary of textfield DataAnnotations that is in the form (field_name -> annotation)
 */
-(void) renderTextFields:(NSDictionary*) fields;

/*
 Renders the provided data annotations as SimpleCheckboxes onto the current pdf page
 @param fields - a dictionary of checkbox DataAnnotations that is in the form (field_name -> annotation)
 */
-(void) renderCheckboxFields:(NSDictionary*) fields;

//taken from here http://ipdfdev.com/2011/06/21/links-navigation-in-a-pdf-document-on-iphone-and-ipad/
-(CGPoint)convertPDFPointToViewPoint:(CGPoint)pdfPoint;

/**
 Converts the 4 positions of the PDF rectangle to the {x,y}{w,h} format of the iPad view coordinate system
 @param rawPosition the origin x,y and the terminus x,y of the view bounds of the control in the pdf coordinate system
 */
-(CGRect)convertToDisplay:(CGRect)rawPosition;

/*
 Renders the provided signature elements onto the current pdf page
 */
-(void) renderSignatureFields:(NSDictionary*) fields;

/**
 @returns the current value of all the form elements in the form of (element_name -> string_value)
 */
-(NSMutableDictionary*)getFormElements;

/**
 Renders the given control on top of the current pdf page
 */
-(void)renderControl:(id)control;

/**
 Renders the choice field as a action sheet picker control, with the options from the pdf
 */
-(void) renderChoiceFields:(NSDictionary*) fields;

/**
 Removes all the elements from the form control collection
 */
-(void)cleanFormControls;

//Factory methods
-(UITextField*)buildTextFieldAt:(CGRect)position;
-(SimpleCheckbox*)buildCheckboxAt:(CGRect)position;
-(SigningView*)buildSignatureFieldAt:(CGRect)position;
-(SimplePicker*)buildDropDownAt:(CGRect)position andOptions:(NSArray*) options;

@end
