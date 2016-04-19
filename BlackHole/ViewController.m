//
//  ViewController.m
//  BlackHole
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#define kScreenHieght [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

#define kRadius 100.0

#define kNumber 8

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,strong)NSMutableArray * viewArray;
@property (nonatomic,assign)int  index;
@property (nonatomic,strong)NSTimer * timer;
@property (nonatomic,assign)int  remvoeIndex;

@property (nonatomic,strong)UIBezierPath * path;


@property (nonatomic,strong)UIImageView * rootImageView;
@property (nonatomic,strong)UIView * rootView;


@property (nonatomic,strong)UIImageView * succeedImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}



- (IBAction)clickBtn:(id)sender {
    
    
    [self creatViews];
    
    self.rootImageView.hidden = NO;
    self.rootView.hidden = NO;
    
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(addAnimationView) userInfo:nil repeats:YES];
}

- (void)creatViews
{
    
    for (int i = 1 ; i <= kNumber; i ++) {
        
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.layer.cornerRadius = 20;
        imageView.layer.masksToBounds = YES;
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i]];
        [self.viewArray addObject:imageView];
    }
    
  
}
- (void)addAnimationView
{
    if (self.index >= self.viewArray.count) {
        [self.timer invalidate];
        return;
    }
    
    UIView * view = self.viewArray[self.index];
    [self.view addSubview:view];
    CAKeyframeAnimation * keyAnima = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat tmpy =  kScreenHieght/2 + 50 * cos(2.0 * M_PI * self.index / kNumber);
    CGFloat tmpx =	kScreenWidth/2  - 50 * sin(2.0 * M_PI * self.index / kNumber);
    
    CGPathMoveToPoint(path,NULL,tmpx,tmpy);
    CGPathAddLineToPoint(path, NULL, kScreenWidth/2 , kScreenHieght/2);

//    keyAnima.path = path;
    keyAnima.path = self.path.CGPath;

    //1.2设置动画执行完毕后，不删除动画
    keyAnima.removedOnCompletion = YES;
    //1.3设置保存动画的最新状态
//    keyAnima.fillMode=kCAFillModeForwards;
    //1.4设置动画执行的时间
    keyAnima.duration=1;
    //1.5设置动画的节奏
    //        keyAnima.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    //设置代理，开始—结束
    keyAnima.delegate = self;
    //2.添加核心动画
    [view.layer addAnimation:keyAnima forKey:nil];
    
    
    //缩放变化
    CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 1.0)];
    scaleAnimation.removedOnCompletion = YES;
    
    scaleAnimation.duration = 1.3;
    [view.layer addAnimation:scaleAnimation forKey:nil];

    
    self.index ++;

}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    UIView * view = self.viewArray[self.remvoeIndex];
    [view removeFromSuperview];
    self.remvoeIndex ++;
    
    if (self.remvoeIndex == self.viewArray.count) {
        
        [self.viewArray removeAllObjects];
        self.index = 0;
        self.remvoeIndex = 0;
        
        [self.rootView.layer removeAnimationForKey:@"rootView"];
        [UIView animateWithDuration:.5 animations:^{
            
            self.rootImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.rootView.transform = CGAffineTransformMakeScale(0.1, 0.1);
            
        } completion:^(BOOL finished) {
            [self.rootView removeFromSuperview];
            [self.rootImageView removeFromSuperview];
            self.rootView = nil;
            self.rootImageView = nil;
            self.succeedImageView.hidden = NO;
            [UIView animateWithDuration:.4 animations:^{
                self.succeedImageView.transform = CGAffineTransformMakeScale(10, 10);
            } completion:^(BOOL finished) {
                [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(removeSucceedImageView) userInfo:nil repeats:NO];
            }];
        }];
    }
}

- (void)removeSucceedImageView
{
    
    [UIView animateWithDuration:.4 animations:^{
        self.succeedImageView.transform = CGAffineTransformMakeScale(.1, .1);
    } completion:^(BOOL finished) {
        self.succeedImageView.hidden = YES;

    }];
}



#pragma mark ----------------------------------------------------------------------
#pragma mark ----------------------lazyLoding-------------------------------------
#pragma mark ----------------------------------------------------------------------
- (NSMutableArray *)viewArray
{
    if (!_viewArray) {
        _viewArray = [NSMutableArray array];
    }
    return _viewArray;
}



- (UIBezierPath *)path
{
    if (!_path) {
        _path = [UIBezierPath bezierPath];
        
        float radius = 50;
        for (int i = 0 ; i < 20; i ++) {
            CGFloat tmpy =  kScreenHieght/2 + radius*cos(2.0*M_PI *i/20);
            CGFloat tmpx =	kScreenWidth/2  - radius*sin(2.0*M_PI *i/20);
            radius -= 50/20.0;
            
            if (i == 0) {
                [_path moveToPoint:CGPointMake(tmpx, tmpy)];
            }else
            {
                [_path addLineToPoint:CGPointMake(tmpx, tmpy)];
            }
            
        }

    }
    return _path;
}

- (UIImageView *)rootImageView
{
    if (!_rootImageView) {
        _rootImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kRadius, kRadius)];
        _rootImageView.center = CGPointMake(kScreenWidth/2, kScreenHieght/2);
        _rootImageView.backgroundColor = [UIColor whiteColor];
        _rootImageView.alpha = .6;
        _rootImageView.layer.cornerRadius = kRadius/2;
        [self.view addSubview:_rootImageView];
    }
    return _rootImageView;
}

- (UIView *)rootView
{
    if (!_rootView) {
        _rootView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kRadius, kRadius)];
        _rootView.center = CGPointMake(kScreenWidth/2, kScreenHieght/2);
        [self.view addSubview:_rootView];
        
        UIImageView * imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kRadius - 10, kRadius - 10)];
        imageView1.center = CGPointMake(kRadius/2, kRadius/2);
        imageView1.image = [UIImage imageNamed:@"cooling_instrument_bg"];
        [_rootView addSubview:imageView1];
        
        UIImageView * imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kRadius - 25, kRadius - 25)];
        imageView2.center = CGPointMake(kRadius/2, kRadius/2);;
        imageView2.image = [UIImage imageNamed:@"cooling_propeller_outside"];
        [_rootView addSubview:imageView2];
        
        UIImageView * imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        imageView3.center = CGPointMake(kRadius/2, kRadius/2);;
        imageView3.image = [UIImage imageNamed:@"clean_shortcut_center_rotate"];
        [_rootView addSubview:imageView3];
        imageView3.layer.cornerRadius = (kRadius - 40)/2;
        imageView3.backgroundColor = [UIColor colorWithRed:42/255.0 green:76/255.0 blue:108/255.0 alpha:1];
        
        [UIView animateWithDuration:.5 animations:^{
            imageView3.bounds = CGRectMake(0, 0, kRadius - 40, kRadius - 40);
        }];
        
        
        CABasicAnimation * basic = [ViewController rotation:0 degree:M_PI_2 direction:1 repeatCount:MAX_CANON];
        
        [_rootView.layer addAnimation:basic forKey:@"rootView"];
    }
    return _rootView;
}


- (UIImageView *)succeedImageView
{
    if (!_succeedImageView) {
        _succeedImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        _succeedImageView.center = CGPointMake(kScreenWidth/2, kScreenHieght/2);
        _succeedImageView.image = [UIImage imageNamed:@"clean_shortcut_clear_finish"];
        [self.view addSubview:_succeedImageView];
        
    }
    return _succeedImageView;
}

+ (CABasicAnimation *)rotation:(float)dur degree:(float)degree direction:(int)direction repeatCount:(int)repeatCount

{
    
    CATransform3D rotationTransform  = CATransform3DMakeRotation(degree, 0, 0,direction);
    
    CABasicAnimation* animation;
    
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    
    animation.toValue= [NSValue valueWithCATransform3D:rotationTransform];
    
    animation.duration= dur;
    
    animation.autoreverses= NO;
    
    animation.cumulative= YES;
    
    animation.removedOnCompletion=NO;
    
    animation.fillMode=kCAFillModeForwards;
    
    animation.repeatCount= repeatCount;
    
    animation.delegate= self;
    
    
    
    return animation;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
