//
//  SetAllLedsCommand.m
//  BlueLight
//
//  Created by Philipp Waldhauer on 24/12/14.
//
//

#import "SetAllLightsCommand.h"

@implementation SetAllLightsCommand

+ (instancetype)commandWithColor:(UIColor *)color {
    SetAllLightsCommand *command = [[SetAllLightsCommand alloc] init];
    command.color = color;
    
    return command;
}

- (NSData *)bluetoothLightCommandData {
    const CGFloat *components = CGColorGetComponents(self.color.CGColor);
    
    char bytes[7];
    bytes[0] = 127;
    bytes[1] = 255;
    bytes[2] = (char)lroundf(components[0] * 255);
    bytes[3] = (char)lroundf(components[1] * 255);
    bytes[4] = (char)lroundf(components[2] * 255);
    bytes[5] = 127;
    bytes[6] = 130;
    
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&bytes length:sizeof(bytes)];
    
    return data;
}

@end
