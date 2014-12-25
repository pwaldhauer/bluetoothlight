//
//  ViewController.h
//  BlueLight
//
//  Created by Philipp Waldhauer on 10/12/14.
//
//

#import <UIKit/UIKit.h>
#import "BluetoothLightManager.h"

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, BluetoothLightManagerDelegate>


@end

