//
//  PdfAnnotations.m
//  formulate
//
//  Created by Shawn Spooner on 7/11/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import "PdfAnnotations.h"


@implementation PdfAnnotations

- (id)init
{
    self = [super init];
    if (self) {
        textFields = [[NSMutableDictionary alloc] init];
        signatureFields = [[NSMutableDictionary alloc] init];
        checkboxFields = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [textFields dealloc];
    [signatureFields dealloc];
    [checkboxFields dealloc];
}

-(NSMutableDictionary*) getTextFields{
    return textFields;
}

//should this return a copy?
-(NSMutableDictionary*) getSignatureFields{
    return signatureFields;
}

-(NSMutableDictionary*) getCheckboxFields{
    return checkboxFields;
}

-(void) addTextEntry:(NSString*)key withValue:(AnnotationData*)value{
    [textFields setObject:value forKey:key];
}

-(void) addSignatureEntry:(NSString*)key withValue:(AnnotationData*)value{
    [signatureFields setObject:value forKey:key];
}

-(void) addCheckboxEntry:(NSString*)key withValue:(AnnotationData*)value{
    [checkboxFields setObject:value forKey:key];
}

@end
