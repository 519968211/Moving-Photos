//
//  ImageShowViewController.m
//  Moving Photos
//
//  Created by 519968211 on 2019/9/7.
//

#import "ImageShowViewController.h"
#import "ViewController.h"
#import <AVKit/AVKit.h>

@interface ImageShowViewController () <CAAnimationDelegate>

@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, assign) BOOL shouldStopPlay;
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeLeft;
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeRight;
@property (nonatomic, retain) UITapGestureRecognizer *doubleTap;
@property (nonatomic, retain) NSString *transitionType;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

@end

@implementation ImageShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    NSString *imagePath = [_imagePathArray objectAtIndex:_index];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    _imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, image.size.height*[[UIScreen mainScreen] bounds].size.width/image.size.width)];
    _imageView1.image = image;
    _imageView1.center = self.view.center;
    [self.view addSubview:_imageView1];
    
    CGFloat scale = [[UIScreen mainScreen] bounds].size.width/750.0;
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton.frame = CGRectMake(650/2.0*scale, [[UIScreen mainScreen] bounds].size.height-350*scale, 100*scale, 150*scale);
    _playButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 50*scale, 0);
    _playButton.titleEdgeInsets = UIEdgeInsetsMake(120*scale, -[UIImage imageNamed:@"play"].size.width, 0, 0);
    [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_playButton setTitle:@"play" forState:UIControlStateNormal];
    [_playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _playButton.titleLabel.backgroundColor = [UIColor colorWithWhite:0.41 alpha:1];
    _playButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:30*scale];
    [_playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchTransitionType)];
    _doubleTap.numberOfTapsRequired = 2;
    _doubleTap.enabled = NO;
    [self.view addGestureRecognizer:_doubleTap];
    
    [tap requireGestureRecognizerToFail:_doubleTap];
    
    _swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction)];
    _swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:_swipeLeft];
    
    _swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightAction)];
    _swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:_swipeRight];
    
    _transitionType = @"oglFlip";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(_autoPlay)
    {
        [self play];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tap
{
    if(_playButton.isHidden)
    {
        _shouldStopPlay = YES;
        _playButton.hidden = NO;
    }
    else{
        [self back];
    }
}

- (void)back
{
    [self homeVCImageSync];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)homeVCImageSync{
    ViewController *homeVC = (ViewController *)self.presentingViewController;
    [homeVC scrollCurrentImageToVisibleWithIndex:_index];
}

- (void)swipeLeftAction
{
    if(_index==_imagePathArray.count-1)
    {
        return;
    }
    
    ViewController *homeVC = (ViewController *)self.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        [homeVC showNext];
    }];
}

- (void)swipeRightAction
{
    if(_index==0)
    {
        return;
    }
    
    ViewController *homeVC = (ViewController *)self.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        [homeVC showPrevious];
    }];
}

- (void)play
{
    _playButton.hidden = YES;
    _swipeLeft.enabled = NO;
    _swipeRight.enabled = NO;
    _doubleTap.enabled = YES;
    
    //添加动画
    [self setupTransition];
    NSString *mp3Path = [[NSBundle mainBundle] pathForResource:@"song" ofType:@"mp3"];
    NSURL *mp3URL = [NSURL fileURLWithPath:mp3Path];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:mp3URL error:nil];
    [_audioPlayer play];
}

- (void)setupTransition
{
    if(_shouldStopPlay)
    {
        _shouldStopPlay = NO;
        _swipeLeft.enabled = YES;
        _swipeRight.enabled = YES;
        _doubleTap.enabled = NO;
        [_audioPlayer stop];
        return;
    }
    //更换图片
    NSString *imagePath = [_imagePathArray objectAtIndex:_index];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    self.imageView1.image = image;
    
    CATransition *animation = [CATransition animation];
    
    //设置动画的过渡方式
    animation.type = _transitionType;
    //设置动画的过渡方向
    animation.subtype = kCATransitionFromRight;
    //设置动画时长
    animation.duration = 1;
    animation.delegate = self;
    
    //将动画添加到图层上
    [self.imageView1.layer addAnimation:animation forKey:nil];
}

- (void)switchTransitionType
{
    NSArray *array = @[@"fade",@"push",@"moveIn",@"reveal",@"cube",@"oglFlip",@"suckEffect",@"rippleEffect",@"pageCurl"];
    NSUInteger randomIndex = (NSUInteger)arc4random_uniform((uint32_t)array.count);
    _transitionType = [array objectAtIndex:randomIndex];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
    //控制图片循环展示
    if (_index == _imagePathArray.count-1)
    {
        _index = 0;
    }
    else{
        _index++;
    }

    NSString *imagePath = [_imagePathArray objectAtIndex:_index];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    self.imageView1.image = image;
    CGFloat height = image.size.height*[[UIScreen mainScreen] bounds].size.width/image.size.width;
    self.imageView1.frame = CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height-height)/2.0, [[UIScreen mainScreen] bounds].size.width, height);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if(flag)
    {
        [self homeVCImageSync];
        [self performSelector:@selector(setupTransition) withObject:nil afterDelay:1];
    }
}

@end
