//
//  PdfHelper.h
//  formulate
//
//  Created by Shawn Spooner on 6/28/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PdfAnnotations;

@interface PdfHelper : NSObject {
@private
    CGPDFDocumentRef pdf;
    
}

@property (nonatomic) CGPDFDocumentRef pdf;

- (id)initWithPdf:(CFURLRef)pdfUrl;
-(CGPDFArrayRef)formFieldsonPage:(int)page;
+(CGPDFDocumentRef)load:(CFURLRef)pdfURL;
+(CGPDFArrayRef)annotations:(CGPDFDocumentRef)pdf onPage:(int)page;
-(PdfAnnotations*) formElements:(CGPDFArrayRef) annotations;
-(CGRect)retrieveCoordinates:(CGPDFArrayRef)coordinateArray;
-(NSArray*)toArray:(CGPDFArrayRef)source;
@end
