//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import <SDAutoLayout/SDAutoLayout.h>
#import "DetailTableViewCell.h"
#import "SGBaseMapViewController.h"
#import "DetailModel.h"
#import "SDWebImageManager.h"

static CGFloat const kIconSize = 18;
static CGFloat const kSpacingY = 14;

@interface DetailTableViewCell ()
@property(nonatomic, strong) DetailModel *model;

@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UIImageView *photoView;
@property(nonatomic, strong) SGBaseMapViewController *mapViewController;
@end

@implementation DetailTableViewCell
#pragma mark - accessors

- (NSInteger)cellStyle {
    return self.reuseIdentifier.integerValue;
}

- (void)setModel:(DetailModel *)model {
    _model = model;
    
    _iconView.image = [UIImage imageNamed:model.iconName];
    if (model.content && model.content.length) {
        _contentLabel.text = model.content;
        _contentLabel.textColor = [UIColor blackColor];
    } else {
        _contentLabel.text = model.placeholder;
        _contentLabel.textColor = [SGHelper subTextColor];
    }
    
    __weak __typeof(self) weakSelf = self;
    if (model.photoPath) {
        _photoView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.jpg", [SGHelper photoPath], model.identifier]];
    } else if (model.photoUrl) {
        SDImageDownload(model.photoUrl, ^(UIImage *image) {
            weakSelf.photoView.image = image;
        });
    }
    
    [self setNeedsUpdateConstraints];
}

#pragma mark - initial

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
        [self bindConstraints];
    }
    return self;
}

- (void)setupViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _iconView = [UIImageView new];
    [self.contentView addSubview:_iconView];
    
    _contentLabel = [UILabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [SGHelper themeFontDefault];
    [self.contentView addSubview:_contentLabel];
    
    _photoView = [UIImageView new];
    _photoView.contentMode = UIViewContentModeScaleAspectFill;
    _photoView.clipsToBounds = YES;
    [self.contentView addSubview:_photoView];
}

- (void)bindConstraints {
    CGPoint space = CGPointMake(19, kSpacingY);
    
    _iconView.sd_layout
            .leftSpaceToView(self.contentView, space.x)
            .topSpaceToView(self.contentView, space.y)
            .heightIs(kIconSize)
            .widthEqualToHeight();
    
    _contentLabel.sd_layout
            .leftSpaceToView(_iconView, space.x)
            .topEqualToView(_iconView)
            .rightSpaceToView(self.contentView, space.x)
            .autoHeightRatio(0)
            .maxHeightIs(55);   //三排字刚好
    
    _photoView.sd_layout
            .leftSpaceToView(_iconView, space.x)
            .topEqualToView(_iconView)
            .rightSpaceToView(self.contentView, space.x)
            .heightIs(100);
}

- (void)updateConstraints {
    [super updateConstraints];
    
    UIView *bottomView = nil;
    if (_model.cellStyle == DetailCellStyleMap) {
        
    } else if (_model.cellStyle == DetailCellStylePhoto && _model.hasPhoto) {
        _contentLabel.sd_layout.maxHeightIs(0);
        bottomView = _photoView;
    } else {
        bottomView = _contentLabel;
    }
    
    [self setupAutoHeightWithBottomView:bottomView bottomMargin:kSpacingY];
}

@end