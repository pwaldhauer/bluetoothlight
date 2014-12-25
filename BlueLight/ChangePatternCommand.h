//
//  ChangePatternCommand.h
//  BlueLight
//
//  Created by Philipp Waldhauer on 24/12/14.
//
//

#import <UIKit/UIKit.h>
#import "BluetoothLightManager.h"

@interface ChangePatternCommand : NSObject <BluetoothLightCommand>

@property (nonatomic) NSUInteger patternId;
@property (nonatomic) BOOL stop;

+ (instancetype) commandWithPattern:(NSUInteger)patternId;
+ (instancetype) commandToStopAnimation;

@end
