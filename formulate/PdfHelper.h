//
//  PdfHelper.h
//  formulate
//
//  Created by Shawn Spooner on 6/28/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PdfHelper : NSObject {
@private
    CGPDFDocumentRef pdf;
    
}

@property (nonatomic) CGPDFDocumentRef pdf;

- (id)initWithPdf:(CFURLRef)pdfUrl;
-(CGPDFArrayRef)formFieldsonPage:(int)page;
+(CGPDFDocumentRef)load:(CFURLRef)pdfURL;
+(CGPDFArrayRef)annotations:(CGPDFDocumentRef)pdf onPage:(int)page;
-(NSDictionary*) formElements:(CGPDFArrayRef) annotations;
-(CGPDFReal)retrieveCoordinates:(CGPDFArrayRef)coordinateArray;
@end
