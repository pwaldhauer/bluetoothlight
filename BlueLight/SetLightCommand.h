//
//  SetLightCommand.h
//  BlueLight
//
//  Created by Philipp Waldhauer on 24/12/14.
//
//

#import <UIKit/UIKit.h>
#import "BluetoothLightManager.h"

@interface SetLightCommand : NSObject <BluetoothLightCommand>

@property (strong, nonatomic) UIColor *color;
@property (nonatomic) NSUInteger ledId;

+ (instancetype) commandWithColor:(UIColor*)color ledId:(NSUInteger)ledId;

@end
