//
//  PdfAnnotations.h
//  formulate
//
//  Created by Shawn Spooner on 7/11/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AnnotationData;

@interface PdfAnnotations : NSObject {
@private
    NSMutableDictionary *textFields;
    NSMutableDictionary *signatureFields;
    NSMutableDictionary *checkboxFields;
}

-(NSMutableDictionary*) getTextFields;
-(NSMutableDictionary*) getSignatureFields;
-(NSMutableDictionary*) getCheckboxFields;
-(void) addTextEntry:(NSString*)key withValue:(AnnotationData*)value;
-(void) addSignatureEntry:(NSString*)key withValue:(AnnotationData*)value;
-(void) addCheckboxEntry:(NSString*)key withValue:(AnnotationData*)value;
@end
