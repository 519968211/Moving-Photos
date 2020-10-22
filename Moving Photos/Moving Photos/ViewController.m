//
//  ViewController.m
//  Moving Photos
//
//  Created by 519968211 on 2019/9/7.
//

#import "ViewController.h"
#import "ImageTableViewCell.h"
#import "ImageShowViewController.h"
#import "ShowImageModelAnimationDelegate.h"
#import "SwipeLeftModelAnimationDelegate.h"
#import "SwipeRightModelAnimationDelegate.h"
#import "MusicSelectionViewController.h"
#import "PhotoSelectionViewController.h"
#import <ImagePicker-Objective-C/ImagePickerController.h>
#import <Photos/Photos.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, ImagePickerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *imagePathArray;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) ShowImageModelAnimationDelegate *showImageModelAnimationDelegate;
@property (nonatomic, strong) SwipeLeftModelAnimationDelegate *swipeLeftModelAnimationDelegate;
@property (nonatomic, strong) SwipeRightModelAnimationDelegate *swipeRightModelAnimationDelegate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self reloadImages];
    
    _tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.bounces = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    if(@available(iOS 11.0, *))
    {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    CGFloat scale = [[UIScreen mainScreen] bounds].size.width/750.0;
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake(450/4.0*scale, [[UIScreen mainScreen] bounds].size.height-350*scale, 100*scale, 150*scale);
    playButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 50*scale, 0);
    playButton.titleEdgeInsets = UIEdgeInsetsMake(120*scale, -[UIImage imageNamed:@"play"].size.width, 0, 0);
    [playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [playButton setTitle:@"play" forState:UIControlStateNormal];
    [playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    playButton.titleLabel.backgroundColor = [UIColor colorWithWhite:0.41 alpha:1];
    playButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:30*scale];
    [playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];

    UIButton *musicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    musicButton.frame = CGRectMake(450/2.0*scale+100*scale, [[UIScreen mainScreen] bounds].size.height-350*scale, 100*scale, 150*scale);
    musicButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 50*scale, 0);
    musicButton.titleEdgeInsets = UIEdgeInsetsMake(120*scale, -[UIImage imageNamed:@"music"].size.width, 0, 0);
    [musicButton setImage:[UIImage imageNamed:@"music"] forState:UIControlStateNormal];
    [musicButton setTitle:@"music" forState:UIControlStateNormal];
    [musicButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    musicButton.titleLabel.backgroundColor = [UIColor colorWithWhite:0.41 alpha:1];
    musicButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:30*scale];
    [musicButton addTarget:self action:@selector(selectMusic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:musicButton];
    
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoButton.frame = CGRectMake(450/4.0*3*scale+100*scale*2, [[UIScreen mainScreen] bounds].size.height-350*scale, 100*scale, 150*scale);
    photoButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 50*scale, 0);
    photoButton.titleEdgeInsets = UIEdgeInsetsMake(120*scale, -[UIImage imageNamed:@"photos"].size.width, 0, 0);
    [photoButton setImage:[UIImage imageNamed:@"photos"] forState:UIControlStateNormal];
    [photoButton setTitle:@"photo" forState:UIControlStateNormal];
    [photoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    photoButton.titleLabel.backgroundColor = [UIColor colorWithWhite:0.41 alpha:1];
    photoButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:30*scale];
    [photoButton addTarget:self action:@selector(selectPhotos) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoButton];
    
    self.showImageModelAnimationDelegate = [[ShowImageModelAnimationDelegate alloc] init];
    self.swipeLeftModelAnimationDelegate = [[SwipeLeftModelAnimationDelegate alloc] init];
    self.swipeRightModelAnimationDelegate = [[SwipeRightModelAnimationDelegate alloc] init];
 }

#pragma mark - images
- (void)reloadImages
{
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    NSString *imagesDir = [document stringByAppendingPathComponent:@"images"];
    BOOL flag = YES;
    if(![[NSFileManager defaultManager] fileExistsAtPath:imagesDir isDirectory:&flag])
    {
        [self setDefaultImages];
    }
    else{
        NSMutableArray *mutArray = [NSMutableArray array];
        for(NSString *subPath in [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:imagesDir error:nil])
        {
            NSString *fullPath = [imagesDir stringByAppendingPathComponent:subPath];
            [mutArray addObject:fullPath];
        }
        _imagePathArray = [mutArray copy];
    }
    _index = 0;
    [_tableView setContentOffset:CGPointMake(0, 0)];
    [_tableView reloadData];
}

- (void)setDefaultImages
{
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    NSString *imagesDir = [document stringByAppendingPathComponent:@"images"];
    [[NSFileManager defaultManager] removeItemAtPath:imagesDir error:nil];
    NSMutableArray *mutArray = [NSMutableArray array];
    for(int i=0;i<10;i++)
    {
        NSString *fileName = [NSString stringWithFormat:@"o_1aimkke7%ld",(long)i];
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
        [mutArray addObject:path];
    }
    _imagePathArray = [mutArray copy];
}

#pragma mark - Button Events
- (void)play
{
    ImageShowViewController *v = [[ImageShowViewController alloc] init];
    v.imagePathArray = _imagePathArray;
    v.index = _index;
    v.autoPlay = YES;
    v.modalPresentationStyle = UIModalPresentationCustom;
    v.transitioningDelegate = _showImageModelAnimationDelegate;
    _showImageModelAnimationDelegate.image = [self currentImage];
    _showImageModelAnimationDelegate.dissmissRect = [self dissmissRect];
    [self presentViewController:v animated:YES completion:nil];
}

- (void)selectMusic
{
    /*
    MusicSelectionViewController *v = [[MusicSelectionViewController alloc] init];
    [self presentViewController:v animated:YES completion:nil];
     */
    UIAlertController *v1 = [UIAlertController alertControllerWithTitle:nil message:@"comming soon!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"I know" style:UIAlertActionStyleCancel
                                                          handler:nil];
    [v1 addAction:defaultAction];
    [self presentViewController:v1 animated:YES completion:nil];
}

- (void)selectPhotos
{
    UIAlertController *v = [[UIAlertController alloc] init];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"select photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    ImagePickerController *v = [[ImagePickerController alloc] init];
                    v.delegate = self;
                    [self presentViewController:v animated:YES completion:nil];
                }
                else if(status == PHAuthorizationStatusDenied)
                {
                    UIAlertController *v1 = [UIAlertController alertControllerWithTitle:nil message:@"You have to open photo library access privacy in settings" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                                                                          handler:nil];
                    [v1 addAction:defaultAction];
                    [self presentViewController:v1 animated:YES completion:nil];
                }
            });
        }];
    }];
    __weak ViewController *weakSelf = self;
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"set default" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setDefaultImages];
        [weakSelf.tableView reloadData];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [v dismissViewControllerAnimated:YES completion:nil];
    }];
    [v addAction:action1];
    [v addAction:action2];
    [v addAction:action3];
    [self presentViewController:v animated:YES completion:nil];
}

- (void)showNext
{
    if(_index==_imagePathArray.count-1)
    {
        return;
    }
    
    UIView *fullScreenBlackMask = [[UIView alloc] initWithFrame:self.view.bounds];
    fullScreenBlackMask.backgroundColor = [UIColor blackColor];
    [self.view addSubview:fullScreenBlackMask];
    
    NSString *path = [_imagePathArray objectAtIndex:_index];
    _swipeLeftModelAnimationDelegate.image = [UIImage imageWithContentsOfFile:path];
    
    _index = _index+1;
    ImageShowViewController *v = [[ImageShowViewController alloc] init];
    v.imagePathArray = _imagePathArray;
    v.index = _index;
    v.modalPresentationStyle = UIModalPresentationCustom;
    v.transitioningDelegate = _swipeLeftModelAnimationDelegate;
    _swipeLeftModelAnimationDelegate.image1 = [self currentImage];
    _swipeLeftModelAnimationDelegate.dissmissRect = [self dissmissRect];
    [self presentViewController:v animated:YES completion:^{
        [fullScreenBlackMask removeFromSuperview];
    }];
}

- (void)showPrevious
{
    if(_index==0)
    {
        return;
    }
    
    UIView *fullScreenBlackMask = [[UIView alloc] initWithFrame:self.view.bounds];
    fullScreenBlackMask.backgroundColor = [UIColor blackColor];
    [self.view addSubview:fullScreenBlackMask];
    
    NSString *path = [_imagePathArray objectAtIndex:_index];
    _swipeRightModelAnimationDelegate.image = [UIImage imageWithContentsOfFile:path];
    
    _index = _index-1;
    ImageShowViewController *v = [[ImageShowViewController alloc] init];
    v.imagePathArray = _imagePathArray;
    v.index = _index;
    v.modalPresentationStyle = UIModalPresentationCustom;
    v.transitioningDelegate = _swipeRightModelAnimationDelegate;
    _swipeRightModelAnimationDelegate.image1 = [self currentImage];
    _swipeRightModelAnimationDelegate.dissmissRect = [self dissmissRect];
    [self presentViewController:v animated:YES completion:^{
        [fullScreenBlackMask removeFromSuperview];
    }];
}

- (UIImage *)currentImage
{
    NSString *path = [_imagePathArray objectAtIndex:_index];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

- (CGRect)dissmissRect
{
    NSString *path = [_imagePathArray objectAtIndex:_index];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_index inSection:0];
    CGRect rectInTableView = [_tableView rectForRowAtIndexPath:indexPath];
    rectInTableView.origin.y = rectInTableView.origin.y-_tableView.contentOffset.y;
    rectInTableView.size.height = image.size.height*[[UIScreen mainScreen] bounds].size.width/image.size.width;
    return rectInTableView;
}

- (void)scrollCurrentImageToVisibleWithIndex:(NSUInteger)index
{
    _index = index;
    [self scrollCurrentImageToVisible];
}

- (void)scrollCurrentImageToVisible
{
    CGRect rect = [self dissmissRect];
    if(!CGRectContainsRect([[UIScreen mainScreen] bounds],rect))
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_index inSection:0];
        if(CGRectGetMaxY(rect) > [[UIScreen mainScreen] bounds].size.height)
        {
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        else{
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        _showImageModelAnimationDelegate.image = [self currentImage];
        _showImageModelAnimationDelegate.dissmissRect = [self dissmissRect];
        _swipeLeftModelAnimationDelegate.dissmissRect = [self dissmissRect];
        _swipeRightModelAnimationDelegate.dissmissRect = [self dissmissRect];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _imagePathArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = [[UIScreen mainScreen] bounds].size.width/750.0;
    NSString *path = [_imagePathArray objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image.size.height*[[UIScreen mainScreen] bounds].size.width/image.size.width+20*scale;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[ImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSString *path = [_imagePathArray objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    cell.imageView1.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, image.size.height*[[UIScreen mainScreen] bounds].size.width/image.size.width);
    cell.imageView1.image = image;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _index = indexPath.row;
    ImageShowViewController *v = [[ImageShowViewController alloc] init];
    v.imagePathArray = _imagePathArray;
    v.index = _index;
    v.modalPresentationStyle = UIModalPresentationCustom;
    v.transitioningDelegate = _showImageModelAnimationDelegate;
    _showImageModelAnimationDelegate.image = [self currentImage];
    _showImageModelAnimationDelegate.dissmissRect = [self dissmissRect];
    [self presentViewController:v animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark ImagePickerDelegate
- (void)wrapperDidPress:(ImagePickerController *)imagePicker
                 images:(NSArray<UIImage *> *)images
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)doneButtonDidPress:(ImagePickerController *)imagePicker
                    images:(NSArray<UIImage *> *)images
{
    if([images count]==0)
    {
        return;
    }
    
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    NSString *imagesDir = [document stringByAppendingPathComponent:@"images"];
    BOOL flag = YES;
    if(![[NSFileManager defaultManager] fileExistsAtPath:imagesDir isDirectory:&flag])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesDir withIntermediateDirectories:YES attributes:nil error:nil];
    }

    for(NSString *subPath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imagesDir error:nil])
    {
        NSString *fullPath = [imagesDir stringByAppendingPathComponent:subPath];
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    }
    
    for(int i=0;i<images.count;i++)
    {
        NSData *data = UIImageJPEGRepresentation([images objectAtIndex:i], 1);
        NSString *imageName = [NSString stringWithFormat:@"%i.jpg",i];
        NSString *imagePath = [imagesDir stringByAppendingPathComponent:imageName];
        [data writeToFile:imagePath atomically:YES];
    }
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        [self reloadImages];
    }];
}

- (void)cancelButtonDidPress:(ImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}

@end
