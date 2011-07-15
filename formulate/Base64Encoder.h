//
//  Base64Encoder.h
//  SigMedPatient
//
//  Created by Shawn Spooner on 9/7/10.
//  Copyright 2010 ssSoftwareCreations. All rights reserved.
//


@interface Base64Encoder : NSObject {

}
+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length ;
+ (NSData*) decode:(NSString*) string;
+ (NSString*) encode:(NSData*) rawBytes;
+ (NSData*) decode:(const char*) string length:(NSInteger) inputLength;
+ (void) initialize;

@end


