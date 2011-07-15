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
    return [PdfHelper annotations:pdf onPage:1];
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
 
                    CGPDFStringRef fieldName;
                    CGPDFDictionaryGetString(annotationDictionary, "TU", &fieldName);                           
                    
                    CGRect coordinates = [self retrieveCoordinates: rectArray];
                    NSString* displayName = (NSString *) CGPDFStringCopyTextString(fieldName);
                    AnnotationData* data = [[AnnotationData alloc] initWithPosition:coordinates andDisplay:displayName];
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
                    else{
                         NSLog(@"Unhandled type %s", fieldType);
                    }
                }
            }
        }  
    }
    return pdfAnnotations;
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
