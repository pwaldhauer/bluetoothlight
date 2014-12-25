//
//  SetAllLedsCommand.h
//  BlueLight
//
//  Created by Philipp Waldhauer on 24/12/14.
//
//

#import <Foundation/Foundation.h>
#import "BluetoothLightManager.h"

@interface SetAllLightsCommand : NSObject <BluetoothLightCommand>

@property (strong, nonatomic) UIColor *color;

+ (instancetype) commandWithColor:(UIColor*)color;

@end
