//
//  PdfHelper.m
//  formulate
//
//  Created by Shawn Spooner on 6/28/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import "PdfHelper.h"


@implementation PdfHelper
@synthesize pdf;

- (id)initWithPdf:(CFURLRef)pdfUrl
{
    self = [super init];
    if (self) {
        NSLog(@"has self");
        self.pdf = [PdfHelper load:pdfUrl];
    }
    NSLog(@"loaded");
    return self;
}

- (void)dealloc
{
    CFRelease(pdf);
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

-(NSDictionary*) formElements:(CGPDFArrayRef) annotations
{
    NSMutableDictionary *formElements = [[NSMutableDictionary alloc] init];
    int arrayCount = CGPDFArrayGetCount( annotations );
    for( int j = 0; j < arrayCount; ++j ) {
        CGPDFObjectRef aDictObj;
        if(!CGPDFArrayGetObject(annotations, j, &aDictObj)) {
            break;
        }
        
        CGPDFDictionaryRef annotDict;
        if(!CGPDFObjectGetValue(aDictObj, kCGPDFObjectTypeDictionary, &annotDict)) {
            break;
        }
        
        CGPDFDictionaryRef aDict;
        if(!CGPDFDictionaryGetDictionary(annotDict, "Tx", &aDict)) {
            break;
        }
        
        CGPDFStringRef uriStringRef;
        if(!CGPDFDictionaryGetString(aDict, "T", &uriStringRef)) {
            break;
        }
        
        CGPDFArrayRef rectArray;
        if(!CGPDFDictionaryGetArray(annotDict, "Rect", &rectArray)) {
            break;
        }
        
        [self retrieveCoordinates: rectArray];
    }
    return formElements;
}

-(CGPDFReal)retrieveCoordinates:(CGPDFArrayRef) coordinateArray
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

}

@end
