//
//  MMSheetView.m
//  MMPopupView
//
//  Created by Ralph Li on 9/6/15.
//  Copyright © 2015 LJC. All rights reserved.
//

#import "MMSheetView.h"
#import "MMPopupItem.h"
#import "MMPopupCategory.h"
#import "MMPopupDefine.h"
#import <Masonry/Masonry.h>

@interface MMSheetView()

@property (nonatomic, strong) UIView      *titleView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UIView      *buttonView;
@property (nonatomic, strong) UIButton    *cancelButton;

@property (nonatomic, strong) NSArray     *actionItems;

@end

@implementation MMSheetView

- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items
{
    self = [super init];
    
    if ( self )
    {
        NSAssert(items.count>0, @"Could not find any items.");
        
        MMSheetViewConfig *config = [MMSheetViewConfig globalConfig];
        
        self.type = MMPopupTypeSheet;
        self.actionItems = items;
        
        self.backgroundColor = config.backgroundColor;
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        }];
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisVertical];
        
        MASViewAttribute *lastAttribute = self.mas_top;
        if ( title.length > 0 )
        {
            self.titleView = [UIView new];
            [self addSubview:self.titleView];
            [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self);
            }];
            self.titleView.backgroundColor = config.backgroundColor;
            
            self.titleLabel = [UILabel new];
            [self.titleView addSubview:self.titleLabel];
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.titleView).insets(UIEdgeInsetsMake(config.innerMargin, config.innerMargin, config.innerMargin, config.innerMargin));
            }];
            self.titleLabel.textColor = config.titleColor;
            self.titleLabel.font = [UIFont systemFontOfSize:config.titleFontSize];
            self.titleLabel.textAlignment = config.textAlignment;
            self.titleLabel.numberOfLines = 0;
            self.titleLabel.text = title;
            
            lastAttribute = self.titleView.mas_bottom;
        }
        
        self.buttonView = [UIView new];
        [self addSubview:self.buttonView];
        [self.buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(lastAttribute);
        }];
        
        __block UIButton *firstButton = nil;
        __block UIButton *lastButton = nil;
        for ( NSInteger i = 0 ; i < items.count; ++i )
        {
            MMPopupItem *item = items[i];
            
            UIButton *btn = [UIButton mm_buttonWithTarget:self action:@selector(actionButton:)];
            [self.buttonView addSubview:btn];
            btn.tag = i;
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.right.equalTo(self.buttonView);
                make.height.mas_equalTo(config.buttonHeight);
                
                if ( !firstButton )
                {
                    firstButton = btn;
                    make.top.equalTo(self.buttonView.mas_top).offset(-MM_SPLIT_WIDTH);
                }
                else
                {
                    make.top.equalTo(lastButton.mas_bottom).offset(MM_SPLIT_WIDTH);
                    make.height.equalTo(firstButton);
                }
                
                lastButton = btn;
            }];
            [btn setBackgroundImage:[UIImage mm_imageWithColor:config.backgroundColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage mm_imageWithColor:config.backgroundColor] forState:UIControlStateDisabled];
            [btn setBackgroundImage:[UIImage mm_imageWithColor:config.itemPressedColor] forState:UIControlStateHighlighted];
            [btn setTitle:item.title forState:UIControlStateNormal];
            [btn setTitleColor:item.highlight?config.itemHighlightColor:item.disabled?config.itemDisableColor:config.itemNormalColor forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:config.buttonFontSize];
            btn.layer.borderWidth = MM_SPLIT_WIDTH;
            btn.layer.borderColor = config.splitColor.CGColor;
            btn.enabled = !item.disabled;
            btn.contentEdgeInsets = UIEdgeInsetsMake(0, config.innerMargin, 0, config.innerMargin);
            [btn setContentHorizontalAlignment:config.horizontalAlignment];
            [btn setContentVerticalAlignment:config.verticalAlignment];
        }
        [lastButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.buttonView.mas_bottom).offset(MM_SPLIT_WIDTH);
        }];
        
        if (config.showCancelButton) {
            self.cancelButton = [UIButton mm_buttonWithTarget:self action:@selector(actionCancel)];
            [self addSubview:self.cancelButton];
            [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.buttonView).offset(config.innerMargin);
                make.right.equalTo(self.buttonView);
                make.height.mas_equalTo(config.buttonHeight);
                make.top.equalTo(self.buttonView.mas_bottom).offset(8);
            }];
            self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:config.buttonFontSize];
            [self.cancelButton setBackgroundImage:[UIImage mm_imageWithColor:config.backgroundColor] forState:UIControlStateNormal];
            [self.cancelButton setBackgroundImage:[UIImage mm_imageWithColor:config.itemPressedColor] forState:UIControlStateHighlighted];
            [self.cancelButton setTitle:config.defaultTextCancel forState:UIControlStateNormal];
            [self.cancelButton setTitleColor:config.itemNormalColor forState:UIControlStateNormal];
            [self.cancelButton setContentHorizontalAlignment:config.horizontalAlignment];
            [self.cancelButton setContentVerticalAlignment:config.verticalAlignment];
        }
        
        //美化iPhone X
        CGFloat height = MM_IS_IPHONE_X ? 33 : 0;
        
        UIView *extraView = [[UIView alloc] init];
        extraView.backgroundColor = config.backgroundColor;
        extraView.clipsToBounds = YES;
        [self addSubview:extraView];
        [extraView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (config.showCancelButton) {
                make.top.mas_equalTo(self.cancelButton.mas_bottom).offset(MM_SPLIT_WIDTH);
            } else {
                make.top.mas_equalTo(lastButton.mas_bottom).offset(MM_SPLIT_WIDTH);
            }
            
            make.left.right.mas_equalTo(self);
            make.height.mas_equalTo(height);
        }];
        
        
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(extraView.mas_bottom);
        }];
        
        //默认点击空白消失
        [[MMPopupWindow sharedWindow] setTouchWildToHide:YES];
        
    }
    
    return self;
}

- (void)actionButton:(UIButton*)btn
{
    MMPopupItem *item = self.actionItems[btn.tag];
    
    [self hide];
    
    if ( item.handler )
    {
        item.handler(btn.tag);
    }
}

- (void)actionCancel
{
    [self hide];
}

@end


@interface MMSheetViewConfig()

@end

@implementation MMSheetViewConfig

+ (MMSheetViewConfig *)globalConfig
{
    static MMSheetViewConfig *config;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        config = [MMSheetViewConfig new];
        
    });
    
    return config;
}

- (instancetype)init
{
    self = [super init];
    
    if ( self )
    {
        self.buttonHeight   = 50.0f;
        self.innerMargin    = 19.0f;
        
        self.titleFontSize  = 14.0f;
        self.buttonFontSize = 17.0f;
        
        self.backgroundColor    = MMHexColor(0xFFFFFFFF);
        self.titleColor         = MMHexColor(0x666666FF);
        self.splitColor         = MMHexColor(0xE7E7E7FF);
        
        self.itemNormalColor    = MMHexColor(0x333333FF);
        self.itemDisableColor   = MMHexColor(0xCCCCCCFF);
        self.itemHighlightColor = MMHexColor(0xE76153FF);
        self.itemPressedColor   = MMHexColor(0xEFEDE7FF);
        self.defaultTextCancel  = @"取消";
        
        self.showCancelButton   = true;
        self.textAlignment      = NSTextAlignmentCenter;
        self.verticalAlignment  = UIControlContentVerticalAlignmentCenter;
        self.horizontalAlignment= UIControlContentHorizontalAlignmentCenter;
        
    }
    
    return self;
}

@end
