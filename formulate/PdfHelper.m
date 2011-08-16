//
//  PdfHelper.m
//  formulate
//
//  Created by Shawn Spooner on 6/28/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import "PdfHelper.h"
#import "PDfAnnotations.h"
#import "AnnotationData.h"

@implementation PdfHelper
@synthesize pdf;

- (id)initWithPdf:(CFURLRef)pdfUrl
{
    self = [super init];
    if (self) {
        pdf = [PdfHelper load:pdfUrl];
    }
    return self;
}

- (void)dealloc
{
    //if(pdf)
        //CFRelease(pdf);
    [super dealloc];
}

+(CGPDFDocumentRef)load:(CFURLRef)pdfURL;
{
    return CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
}

+(CGPDFArrayRef)annotations:(CGPDFDocumentRef)pdf onPage:(int)page
{
    CGPDFPageRef pageAd = CGPDFDocumentGetPage(pdf, page);
    
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(pageAd);
    
    CGPDFArrayRef outputArray;
    CGPDFDictionaryGetArray(pageDictionary, "Annots", &outputArray);
    
    return outputArray;
}

-(CGPDFArrayRef)formFieldsonPage:(int)page
{
    return [PdfHelper annotations:pdf onPage:page];
}

-(NSString*)getOptionalStringField:(char*)key from:(CGPDFDictionaryRef)annotationDictionary{
    CGPDFStringRef fieldName;
    NSString* value = (!CGPDFDictionaryGetString(annotationDictionary, key, &fieldName)) ? @"" : (NSString *) CGPDFStringCopyTextString(fieldName);
    return [value autorelease];
}

-(PdfAnnotations*) formElements:(CGPDFArrayRef) annotations
{
    PdfAnnotations* pdfAnnotations = [[PdfAnnotations alloc] init];
    if (annotations != NULL) {
        int annotsCount = CGPDFArrayGetCount(annotations);
        
        for (int j = 0; j < annotsCount; j++) {
            CGPDFDictionaryRef annotationDictionary = NULL;            
            if (CGPDFArrayGetDictionary(annotations, j, &annotationDictionary)) {
                const char *type;
                CGPDFDictionaryGetName(annotationDictionary, "Subtype", &type);
                
                if(strcmp(type, "Widget") == 0){
                    const char *fieldType;
                    if(!CGPDFDictionaryGetName(annotationDictionary, "FT", &fieldType)) {
                        continue;
                    }
                    
                    CGPDFStringRef fullName;
                    if(!CGPDFDictionaryGetString(annotationDictionary, "T", &fullName)) {
                        continue;
                    }
                    
                    CGPDFArrayRef rectArray;
                    if(!CGPDFDictionaryGetArray(annotationDictionary, "Rect", &rectArray)) {
                        continue;
                    }
                    
                    NSString *displayName = [self getOptionalStringField:"TU" from:annotationDictionary];
                    NSString *value = [self getOptionalStringField:"V" from:annotationDictionary];
                    CGRect coordinates = [self retrieveCoordinates: rectArray];
                    
                    AnnotationData* data = [[AnnotationData alloc] initWithPosition:coordinates andValue:value andDisplay:displayName];
                    NSString* key = (NSString *) CGPDFStringCopyTextString(fullName);
                    //#TODO break this out into other methods
                    if(strcmp(fieldType, "Tx") == 0){
                        [pdfAnnotations addTextEntry:key withValue:data];
                    }
                    else if(strcmp(fieldType, "Btn") == 0){
                        const char *buttonType;
                        if(!CGPDFDictionaryGetName(annotationDictionary, "Ff", &buttonType)) {
                            [pdfAnnotations addCheckboxEntry:key withValue:data];
                        }
                    }
                    else if(strcmp(fieldType, "Sig") == 0){
                        [pdfAnnotations addSignatureEntry:key withValue:data];
                    }
                    else if(strcmp(fieldType, "Ch") == 0){
                        CGPDFArrayRef options;
                        if(!CGPDFDictionaryGetArray(annotationDictionary, "Opt", &options)) {
                            continue;
                        }
                        data.options = [self toArray:options];
                        [pdfAnnotations addChoiceEntry:key withValue:data];
                        
                    }
                    else{
                        NSLog(@"Unhandled type %s", fieldType);
                    }
                    [key release];
                    [data release];
                }
            }
        }  
    }
    return pdfAnnotations;
}

-(NSArray*)toArray:(CGPDFArrayRef)source{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    int arrayCount = CGPDFArrayGetCount(source);
    for( int k = 0; k < arrayCount; ++k ) {
        CGPDFObjectRef elementObject;
        if(!CGPDFArrayGetObject(source, k, &elementObject)) {
            break;
        }
        
        CGPDFStringRef element;
        if(!CGPDFObjectGetValue(elementObject, kCGPDFObjectTypeString, &element)) {
            break;
        }
        
        [newArray addObject:(NSString *) CGPDFStringCopyTextString(element)];
    }
    return [newArray autorelease];
}

-(CGRect)retrieveCoordinates:(CGPDFArrayRef) coordinateArray
{
    int arrayCount = CGPDFArrayGetCount( coordinateArray );
    CGPDFReal coords[4];
    for( int k = 0; k < arrayCount; ++k ) {
        CGPDFObjectRef rectObj;
        if(!CGPDFArrayGetObject(coordinateArray, k, &rectObj)) {
            break;
        }
        
        CGPDFReal coord;
        if(!CGPDFObjectGetValue(rectObj, kCGPDFObjectTypeReal, &coord)) {
            break;
        }
        
        coords[k] = coord;
    }
    CGPDFReal x = coords[0];
    CGPDFReal y = coords[1];
    return CGRectMake(x, y, coords[2], coords[3]);
}

@end
