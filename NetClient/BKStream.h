/*
 *  BKStream.h
 *  BKStream
 *
 *  Created by bearkode on 2015. 4. 7..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>


@interface BKStream : NSObject <NSStreamDelegate>


- (instancetype)initWithInputStream:(NSInputStream *)aInputStream outputStream:(NSOutputStream *)aOutputStream delegate:(id)aDelegate;


- (void)open;
- (void)close;


- (void)handleDataUsingBlock:(NSInteger (^)(NSData *aData))aBlock;
- (void)writeData:(NSData *)aData;


@end


@protocol NEBufferedStreamDelegate <NSObject>

- (void)streamDidOpen:(BKStream *)aStream;
- (void)streamDidClose:(BKStream *)aStream;
- (void)stream:(BKStream *)aStream didWriteData:(NSData *)aData;
- (void)stream:(BKStream *)aStream didReadData:(NSData *)aData;

@end