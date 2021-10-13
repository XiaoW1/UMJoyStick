//
//  UMJoyStick
//  UMJoyStick
//
//  Created by Fred on 2017/6/19.
//

#import <UIKit/UIKit.h>
@class UMJoyStick;

@protocol UMJoyStickDelegate <NSObject>

@optional
- (void)stickDidChangeValue:(UMJoyStick *)stick;
- (void)stickDidMoveEnd:(UMJoyStick *)stick;
@end

typedef void (^UMJoyStickTask)(NSDictionary *info);

@interface UMJoyStick : UIView

@property (nonatomic, assign) id <UMJoyStickDelegate> delegate;
@property(nonatomic, copy) UMJoyStickTask task;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *handleImageView;

//拖动时显示的蓝色渲染层
@property (nonatomic, strong) UIImageView *backgroundViewLayer;
@end
