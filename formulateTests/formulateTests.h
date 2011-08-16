//
//  formulateTests.h
//  formulateTests
//
//  Created by Shawn Spooner on 6/27/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class FormCollection;

@interface formulateTests : SenTestCase {
@private
 
    FormCollection *controller; 
    NSMutableDictionary *textFields;
    NSMutableDictionary *checkboxFields;
    NSMutableDictionary *signatureFields;
}

@end
