//
//  UMJoyStick
//  UMJoyStick
//
//  Created by Fred on 2017/6/19.
//

#import "UMJoyStick.h"
#import <Masonry/Masonry.h>

#define RADIUS ([self bounds].size.width / 2)

@interface UMJoyStick()
@property (nonatomic, readonly) CGFloat xValue;
@property (nonatomic, readonly) CGFloat yValue;
@property (nonatomic, assign) BOOL invertedYAxis;
@property (nonatomic, assign) int direction;
@end
@implementation UMJoyStick

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.direction = -1;
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.backgroundViewLayer];
    [self addSubview:self.handleImageView];
    [self.backgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.backgroundViewLayer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.handleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self).multipliedBy(0.5);
        make.centerY.centerX.mas_equalTo(self);
    }];
    
    _xValue = 0;
    _yValue = 0;
}

#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    CGFloat normalisedX = (location.x / RADIUS) - 1;
    CGFloat normalisedY = ((location.y / RADIUS) - 1) * -1;
    
    if (normalisedX > 1.0)
    {
        location.x = [self bounds].size.width;
        normalisedX = 1.0;
    }
    else if (normalisedX < -1.0)
    {
        location.x = 0.0;
        normalisedX = -1.0;
    }
    
    if (normalisedY > 1.0)
    {
        location.y = 0.0;
        normalisedY = 1.0;
    }
    else if (normalisedY < -1.0)
    {
        location.y = [self bounds].size.height;
        normalisedY = -1.0;
    }
    
    if (self.invertedYAxis)
    {
        normalisedY *= -1;
    }
    
    _xValue = normalisedX;
    _yValue = normalisedY;
    
    CGPoint handleImageCenter;
    
    if ([self DistanceBetweenTwoPointsWithPoint1:location withPoint2:_backgroundImageView.center] > RADIUS) {
        double vX = location.x - _backgroundImageView.center.x;
        double vY = location.y - _backgroundImageView.center.y;
        double magV = sqrt(vX*vX + vY*vY);
        handleImageCenter.x = _backgroundImageView.center.x + vX / magV * RADIUS;
        handleImageCenter.y = _backgroundImageView.center.y + vY / magV * RADIUS;
    }else{
        handleImageCenter.x = location.x;
        handleImageCenter.y = location.y;
    }
    _handleImageView.center = handleImageCenter;
    //默认第一个点击的位置
    [self touchesMoved:touches withEvent:event];
    self.backgroundViewLayer.hidden = NO;
    [self startTask:1];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    CGFloat normalisedX = (location.x / RADIUS) - 1;
    CGFloat normalisedY = ((location.y / RADIUS) - 1) * -1;
    
    if (normalisedX > 1.0)
    {
        location.x = [self bounds].size.width;
        normalisedX = 1.0;
    }
    else if (normalisedX < -1.0)
    {
        location.x = 0.0;
        normalisedX = -1.0;
    }
    
    if (normalisedY > 1.0)
    {
        location.y = 0.0;
        normalisedY = 1.0;
    }
    else if (normalisedY < -1.0)
    {
        location.y = [self bounds].size.height;
        normalisedY = -1.0;
    }
    
    if (self.invertedYAxis)
    {
        normalisedY *= -1;
    }
    
    _xValue = normalisedX;
    _yValue = normalisedY;
    
    CGPoint handleImageCenter;
    if ([self DistanceBetweenTwoPointsWithPoint1:location withPoint2:_backgroundImageView.center] > RADIUS) {
        double vX = location.x - _backgroundImageView.center.x;
        double vY = location.y - _backgroundImageView.center.y;
        double magV = sqrt(vX*vX + vY*vY);
        handleImageCenter.x = _backgroundImageView.center.x + vX / magV * RADIUS;
        handleImageCenter.y = _backgroundImageView.center.y + vY / magV * RADIUS;
    }else{
        handleImageCenter.x = location.x;
        handleImageCenter.y = location.y;
    }
    _handleImageView.center = handleImageCenter;
    
    [self startTask:1];
    
    CGPoint superPoint;
    superPoint.x=self.center.x-self.frame.origin.x;superPoint.y=self.center.y-self.frame.origin.y;
    CGFloat angle =[self getRadianWithPx1:superPoint.x py1:superPoint.y px2:handleImageCenter.x py2:handleImageCenter.y];
    //根据弧度旋转达到点击一个方向蓝色渲染效果
    self.backgroundViewLayer.transform = CGAffineTransformMakeRotation(angle);
}
#pragma mark - 计算两点间的弧度
-(double)getRadianWithPx1:(double)px1 py1:(double)py1 px2:(double)px2 py2:(double)py2{
    
    //两点的x、y值
    double x = px2-px1;
    double y = py2-py1;
    
    //斜边长度
    double hypotenuse = sqrt(pow(x, 2)+pow(y, 2));

    double cos = x/hypotenuse;
    //求出弧度
    double radian = acos(cos);
    //用弧度算出角度
//    double angle = 180/(M_PI/radian);
    if (y<0) {
        radian = -radian;
    }
    return radian;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _xValue = 0.0;
    _yValue = 0.0;
    
    _handleImageView.center = _backgroundImageView.center;
    
    [self startTask:1];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _xValue = 0.0;
    _yValue = 0.0;
    _handleImageView.center = _backgroundImageView.center;
    [self startTask:2];
    self.backgroundViewLayer.hidden = YES;
    self.backgroundViewLayer.transform = CGAffineTransformIdentity;
}
#pragma mark -
- (CGFloat)DistanceBetweenTwoPointsWithPoint1:(CGPoint)point1 withPoint2:(CGPoint)point2{
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    CGFloat distance = sqrt(dx*dx + dy*dy);
    
    return distance;
}

- (void)startTask:(int)state{
    if (self.task) {
//        0:左,1:右,2:上,3:下,4:上左,5:上右,6:下左,7:下右,8:放大,9:缩小
        int ptz = -1;
        //上
        if (self.yValue > 0.2 ) {
            if (self.xValue < -0.2) {
                //右
                ptz = 5;
            }else if (self.xValue > 0.2) {
                //左
                ptz = 4;
            }else{
                ptz = 2;
            }
        }else if (self.yValue < -0.2 ) {
            //下
            if (self.xValue < -0.2) {
                //右
                ptz = 7;
            }else if (self.xValue > 0.2) {
                //左
                ptz = 6;
            }else{
                ptz = 3;
            }
        }else if (self.xValue < -0.2) {
            //左
            ptz = 0;
        }else if(self.xValue > 0.2){
            //右
            ptz = 1;
        }
        if (state == 2) {
            ptz = -1;
        }
        if (self.direction == ptz) {
            return;
        }
        self.direction = ptz;
        self.task(@{
                    @"x" : @(self.xValue),
                    @"y" : @(self.yValue),
                    @"state" : @(state),
                    @"ptz": @(ptz)
                    });
    }
    else if ([self.delegate respondsToSelector:@selector(stickDidChangeValue:)] && state == 1)
    {
        [self.delegate stickDidChangeValue:self];
    }
    else if ([self.delegate respondsToSelector:@selector(stickDidMoveEnd:)] && state == 2)
    {
        [self.delegate stickDidMoveEnd:self];
    }
}

#pragma mark -
- (UIImageView *)backgroundImageView{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.image = [UIImage imageNamed:@"joystick_bg.png"];
    }
    
    return _backgroundImageView;
}

- (UIImageView *)handleImageView{
    if (!_handleImageView) {
        _handleImageView = [[UIImageView alloc] init];
        _handleImageView.image = [UIImage imageNamed:@"joystick_ball.png"];
    }
    return _handleImageView;
}

- (UIImageView *)backgroundViewLayer{
    if (!_backgroundViewLayer) {
        _backgroundViewLayer = [[UIImageView alloc] init];
        _backgroundViewLayer.image = [UIImage imageNamed:@"joystick_moved_bg"];
        _backgroundViewLayer.hidden = YES;
    }
    return _backgroundViewLayer;
}
@end
