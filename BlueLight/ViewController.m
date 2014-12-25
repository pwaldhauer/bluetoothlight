//
//  ViewController.m
//  BlueLight
//
//  Created by Philipp Waldhauer on 10/12/14.
//
//

#import "ViewController.h"

#import <NKOColorPickerView/NKOColorPickerView.h>

#import "SetAllLightsCommand.h"
#import "SetLightCommand.h"
#import "ChangePatternCommand.h"
#import "UIFont+BL.h"

typedef NS_ENUM(NSUInteger, ViewControllerLoadingState) {
    ViewControllerLoadingStateLoading,
    ViewControllerLoadingStateConnecting,
    ViewControllerLoadingStateConnected,
};

@interface ViewController ()

@property (strong, nonatomic) BluetoothLightManager *manager;
@property (strong, nonatomic) UILabel *rssiLabel;

@property (strong, nonatomic) UIView *loadingView;

@property (strong, nonatomic) UILabel *loadingLabel;
@property (strong, nonatomic) UIActivityIndicatorView *loadingActivity;

@property (strong, nonatomic) UIView *toolbarView;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NKOColorPickerView *colorPicker;

@property (strong, nonatomic) NSMutableArray *colors;

@property (strong, nonatomic) NSMutableSet *selectedLeds;

@end

@implementation ViewController


#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"BluetoothLight";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.rssiLabel = [[UILabel alloc] init];
    self.rssiLabel.font = [UIFont blMainFontWithSize:14];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rssiLabel];;
    
    self.loadingView = [[UIView alloc] init];
    self.loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.loadingLabel = [[UILabel alloc] init];
    self.loadingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingLabel.font = [UIFont blMainFontWithSize:16];
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    
    self.loadingActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingActivity.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.loadingView addSubview:self.loadingLabel];
    [self.loadingView addSubview:self.loadingActivity];
    
    [self.loadingView addConstraints:@[
                                       [NSLayoutConstraint constraintWithItem:self.loadingLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loadingView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
                                       [NSLayoutConstraint constraintWithItem:self.loadingLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.loadingView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0],
                                       [NSLayoutConstraint constraintWithItem:self.loadingLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.loadingView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0],
                                       
                                       [NSLayoutConstraint constraintWithItem:self.loadingActivity attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loadingLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:16],
                                       [NSLayoutConstraint constraintWithItem:self.loadingActivity attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.loadingView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
                                       
                                       [NSLayoutConstraint constraintWithItem:self.loadingActivity attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loadingLabel attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0],
                                       
                                       ]];
    
    [self.view addSubview:self.loadingView];
    
    [self.view addConstraints:@[
                                
                                [NSLayoutConstraint constraintWithItem:self.loadingView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:30],
                                [NSLayoutConstraint constraintWithItem:self.loadingView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-30],
                                
                                [NSLayoutConstraint constraintWithItem:self.loadingView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0],
                                
                                ]];
    
    self.toolbarView = [[UIView alloc] init];
    self.toolbarView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.toolbarView];
    
    UIButton *changePatternButton = [UIButton buttonWithType:UIButtonTypeCustom];
    changePatternButton.translatesAutoresizingMaskIntoConstraints = NO;
    [changePatternButton setTitle:@"Change pattern" forState:UIControlStateNormal];
    [changePatternButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    changePatternButton.titleLabel.font = [UIFont blMainFontWithSize:16];
    [changePatternButton addTarget:self action:@selector(changePatternButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.toolbarView addSubview:changePatternButton];
    
    UIButton *stopPatternButton = [UIButton buttonWithType:UIButtonTypeCustom];
    stopPatternButton.translatesAutoresizingMaskIntoConstraints = NO;
    [stopPatternButton setTitle:@"Stop pattern" forState:UIControlStateNormal];
    [stopPatternButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    stopPatternButton.titleLabel.font = [UIFont blMainFontWithSize:16];
    [stopPatternButton addTarget:self action:@selector(stopPatternButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.toolbarView addSubview:stopPatternButton];
    
    
    [self.toolbarView addConstraints:@[
                                       [NSLayoutConstraint constraintWithItem:changePatternButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.toolbarView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-60],
                                       [NSLayoutConstraint constraintWithItem:changePatternButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.toolbarView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0],
                                   
     
     
                                       [NSLayoutConstraint constraintWithItem:stopPatternButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.toolbarView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:60],
                                       [NSLayoutConstraint constraintWithItem:stopPatternButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.toolbarView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0],
         ]
                                       ];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.collectionView];
    
    NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *color){
        if(self.selectedLeds.count == self.colors.count) {
            [self sendColorForAllLeds:color];
            return;
        }
        
        for(NSIndexPath *path in self.selectedLeds) {
            self.colors[path.item] = color;
            [self sendColor:color forLed:path.item];
        }
        
        [self.collectionView reloadItemsAtIndexPaths:[self.selectedLeds allObjects]];
    };
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTappedCollectionView:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    
    [self.collectionView addGestureRecognizer:doubleTapGesture];
    
    self.colorPicker = [[NKOColorPickerView alloc] initWithFrame:CGRectZero color:[UIColor whiteColor] andDidChangeColorBlock:colorDidChangeBlock];
    self.colorPicker.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.colorPicker];
    
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:self.toolbarView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.toolbarView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0],
                                
                                
                                [NSLayoutConstraint constraintWithItem:self.toolbarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:72],
                                [NSLayoutConstraint constraintWithItem:self.toolbarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:32],
                                
                                [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0],
                                
                                [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.toolbarView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
                                
                                [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.colorPicker attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
                                
                                
                                [NSLayoutConstraint constraintWithItem:self.colorPicker attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.colorPicker attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.colorPicker attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
                                
                                
                                [NSLayoutConstraint constraintWithItem:self.colorPicker attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.3 constant:0],
                                
                                ]];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.manager) {
        self.manager = [BluetoothLightManager managerWithPeripheralName:@"HMSoft"];
        self.manager.delegate = self;
        [self.manager startScanningForPeripheral];
        
        [self setLoadingState:ViewControllerLoadingStateLoading];
        
    }
}

#pragma mark - Collection view delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colors.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(60, 60);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = self.colors[indexPath.item];
    
    cell.layer.borderWidth = 2.0;
    cell.layer.borderColor = [self.selectedLeds containsObject:indexPath] ? [UIColor redColor].CGColor : [UIColor grayColor].CGColor;
    cell.layer.cornerRadius = 30;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if([self.selectedLeds containsObject:indexPath]) {
        [self.selectedLeds removeObject:indexPath];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        return;
    }
    
    [self.selectedLeds addObject:indexPath];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - Light manager delegate

- (void)bluetoothLightManagerDidFindPeripheral:(BluetoothLightManager *)manager {
    [self setLoadingState:ViewControllerLoadingStateConnecting];
}

- (void)bluetoothLightManagerDidConnectPeripheral:(BluetoothLightManager *)manager {
    [self setLoadingState:ViewControllerLoadingStateConnected];
}

- (void)bluetoothLightManagerDidDisconnectPeripheral:(BluetoothLightManager *)manager {
    [self setLoadingState:ViewControllerLoadingStateLoading];
    
    // Restart scanning
    [self.manager startScanningForPeripheral];
}

- (void)bluetoothLightManager:(BluetoothLightManager *)manager didUpdateRSSI:(NSNumber *)RSSI {
    self.rssiLabel.text = [NSString stringWithFormat:@"%@", RSSI];
    [self.rssiLabel sizeToFit];
}

#pragma mark - Loading states

- (void)setLoadingState:(ViewControllerLoadingState)state {
    if(state == ViewControllerLoadingStateLoading) {
        self.loadingView.hidden = NO;
        
        self.loadingLabel.text = @"Suche Lichterkette…";
        [self.loadingActivity startAnimating];
        
        self.toolbarView.hidden = YES;
        self.collectionView.hidden = YES;
        self.colorPicker.hidden = YES;
        return;
    }
    
    if(state == ViewControllerLoadingStateConnecting) {
        self.loadingView.hidden = NO;
        
        self.loadingLabel.text = @"Verbinde Lichterkette…";
        [self.loadingActivity startAnimating];
        
        self.toolbarView.hidden = YES;
        self.collectionView.hidden = YES;
        self.colorPicker.hidden = YES;
        return;
    }
    
    if(state == ViewControllerLoadingStateConnected) {
        self.loadingView.hidden = YES;
        [self.loadingActivity stopAnimating];
        
        [self initializeLeds];
        [self.collectionView reloadData];
        
        self.toolbarView.hidden = NO;
        self.collectionView.hidden = NO;
        self.colorPicker.hidden = NO;
        return;
    }
}

#pragma mark - Sending commands


- (void)sendColorForAllLeds:(UIColor*)color {
    SetAllLightsCommand *command = [SetAllLightsCommand commandWithColor:color];
    [self.manager sendCommand:command];
}

- (void)sendColor:(UIColor*)color forLed:(NSUInteger)led {
    SetLightCommand *command = [SetLightCommand commandWithColor:color ledId:led];
    [self.manager sendCommand:command];
}

- (void)changePatternButtonTapped:(id)sender {
    ChangePatternCommand *command = [ChangePatternCommand commandWithPattern:1];
    [self.manager sendCommand:command];
}


- (void)stopPatternButtonTapped:(id)sender {
    ChangePatternCommand *command = [ChangePatternCommand commandToStopAnimation];
    [self.manager sendCommand:command];
}

- (void)doubleTappedCollectionView:(id)sender {
    if(self.selectedLeds.count == self.colors.count) {
        self.selectedLeds = [NSMutableSet set];
        [self.collectionView reloadData];
        return;
    }
    
    [self.colors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.selectedLeds addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
    }];
    [self.collectionView reloadData];
}

- (void)initializeLeds {
    self.rssiLabel.text = @"";
    self.selectedLeds = [NSMutableSet set];
    self.colors = @[].mutableCopy;
    for(int i = 0; i < 25; i++) {
        [self.colors addObject:[UIColor whiteColor]];
    }
}

@end
