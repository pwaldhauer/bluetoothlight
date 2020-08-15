//
//  ChangePatternCommand.m
//  BlueLight
//
//  Created by Philipp Waldhauer on 24/12/14.
//
//

#import "ChangePatternCommand.h"

@implementation ChangePatternCommand

+ (instancetype)commandWithPattern:(NSUInteger)patternId {
    ChangePatternCommand *command = [[ChangePatternCommand alloc] init];
    command.patternId = patternId;
    
    return command;
}

+(instancetype)commandToStopAnimation {
    ChangePatternCommand *command = [[ChangePatternCommand alloc] init];
    command.stop = YES;
    
    return command;
}

- (NSData *)bluetoothLightCommandData {
    char bytes[1];
    //bytes[0] = self.stop ? 131 : 129;
    
    bytes[0] = self.stop ? 123 : 124;
    
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&bytes length:sizeof(bytes)];
    
    return data;
}

@end
