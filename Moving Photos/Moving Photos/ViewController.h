//
//  ViewController.h
//  Moving Photos
//
//  Created by 519968211 on 2019/9/7.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (void)showNext;
- (void)showPrevious;
- (void)scrollCurrentImageToVisibleWithIndex:(NSUInteger)index;

@end

