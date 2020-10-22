//
//  ImageShowViewController.h
//  Moving Photos
//
//  Created by 519968211 on 2019/9/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageShowViewController : UIViewController

@property (nonatomic, strong) NSArray *imagePathArray;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) BOOL autoPlay;

@end

NS_ASSUME_NONNULL_END
