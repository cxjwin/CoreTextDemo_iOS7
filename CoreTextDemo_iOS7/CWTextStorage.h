//
//  CWTextStorage.h
//  CoreTextDemo_iOS7
//
//  Created by cxjwin on 10/15/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWTextStorage : NSObject

@property (nonatomic, copy) NSString *text;

@property (nonatomic, readonly, copy) NSTextStorage *textStorage;

@end
