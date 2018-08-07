//
//  GLFrameRate.m
//  GLFrameRate
//
//  Created by liguoliang on 2018/8/7.
//

#import "GLFrameRate.h"
#define kHardwareFramesPerSecond 60

static double const kNormalFrameDuration = 1.0 / kHardwareFramesPerSecond;

@interface GLFrameRate()
{
    double currentSecondRate[kHardwareFramesPerSecond];
    int frameCounter;
    BOOL inScreen;
}
@property (nonatomic , assign) BOOL running;
@property (nonatomic , strong) UILabel *rateLabel;
@property (nonatomic , strong) CADisplayLink *displayLink;
@end

@implementation GLFrameRate

+ (instancetype)sharedFrameRate{
    static GLFrameRate *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLFrameRate alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self=[super init]) {
        [[UIApplication sharedApplication].keyWindow addSubview:[self createView]];
    }
    return self;
}

- (UIView *)createView {
    if(!self.rateLabel) {
        self.rateLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-120, 0,65, 20)];
        self.rateLabel.font = [UIFont boldSystemFontOfSize:12.0];
        self.rateLabel.backgroundColor = [UIColor grayColor];
        self.rateLabel.textColor = [UIColor whiteColor];
        self.rateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self.rateLabel;
}

- (void)dealloc {
    [_displayLink invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        if (enabled) {
            [self enable];
        }
        else{
            [self disable];
        }
        _enabled = enabled;
    }
}

- (void)displayFrameView {
    UIView * containerView = [UIApplication sharedApplication].keyWindow;
    UIView * frameView = [self createView];
    for(UIView *subView in containerView.subviews) {
        if([subView isMemberOfClass:[frameView class]]){
            inScreen = YES;
        }
    }
    if(inScreen==NO && containerView && frameView){
        [containerView addSubview:frameView];
        inScreen = YES;
    }
}

- (void)enable{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        self.running = YES;
    }
}

- (void)disable{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.running = NO;
}

- (void)setRunning:(BOOL)running{
    if (_running != running) {
        if (running) {
            [self start];
        } else {
            [self stop];
        }
        _running = running;
    }
}

- (void)start{
    frameCounter = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkWillDraw:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stop{
    [self.displayLink invalidate];
    self.displayLink = nil;
    if(inScreen == YES){
        inScreen = NO;
        [[self createView] removeFromSuperview];
    }
}

- (void)displayLinkWillDraw:(CADisplayLink *)link{
    [self updateFrameTimer:link.timestamp];
    int lostCount = [self lostFrameCountCurrentSecond];
    int drawCount = [self drawFrameCountCurrentSecond:lostCount];
    NSString *lostString = [NSString stringWithFormat:@"%d",lostCount];
    NSString *drwaString = [NSString stringWithFormat:@"%d",drawCount];
    if (lostCount<= 0) {
        lostString = @"--";
        self.rateLabel.backgroundColor = [UIColor colorWithRed:0.1 green:0.8 blue:0.1 alpha:1];
    }
    else if(lostCount<=2){
        self.rateLabel.backgroundColor = [UIColor colorWithRed:0.1 green:0.8 blue:0.1 alpha:1];
    }
    else if(lostCount<12){
        self.rateLabel.backgroundColor = [UIColor orangeColor];
    }
    else{
        self.rateLabel.backgroundColor = [UIColor redColor];
    }
    if (drawCount==-1) {
        drwaString = @"--";
    }
    self.rateLabel.text = [NSString stringWithFormat:@"%@    %@",lostString,drwaString];
}

- (void)updateFrameTimer:(double)frameTime{
    ++frameCounter;
    currentSecondRate[frameCounter%kHardwareFramesPerSecond] = frameTime;
}

- (int)lostFrameCountCurrentSecond{
    int lostFrameCount = 0;
    double currentFrameTime = CACurrentMediaTime() - kNormalFrameDuration;
    for (int i=0; i<kHardwareFramesPerSecond; ++i) {
        if (1.0 <= currentFrameTime - currentSecondRate[i]) {
            ++lostFrameCount;
        }
    }
    return lostFrameCount;
}

- (int)drawFrameCountCurrentSecond:(int)lostCount{
    if (!self.running || frameCounter<kHardwareFramesPerSecond) {
        return -1;
    }
    return kHardwareFramesPerSecond-lostCount;
}

- (void)applicationDidBecomeActive{
    if(inScreen==NO){
        [self displayFrameView];
    }
    self.running = self.enabled;
}

- (void)applicationWillResignActive
{
    self.running = NO;
}

@end
