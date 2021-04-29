//
//  ALChannelMsgCell.m
//  Applozic
//
//  Created by Abhishek Thapliyal on 2/20/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#import "ALChannelMsgCell.h"
#import "ALUIUtilityClass.h"

static NSString *identifier = @"UserCell";

@implementation ALChannelMsgCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processKeyBoardHideTap)];
    tapGesture.numberOfTapsRequired = 1;
    [self.contentView setUserInteractionEnabled:YES];
    [self.contentView addGestureRecognizer:tapGesture];
    
    return self;
}

-(void) layoutSubviews {
    [super layoutSubviews];
    CGFloat widht = 40 + 35 * self.channel.userCount.intValue;
    if (UIScreen.mainScreen.bounds.size.width - 40 - widht > 0) {
        self.collectionView.frame = CGRectMake(20, 0, UIScreen.mainScreen.bounds.size.width - 40, 40);
    } else {
        self.collectionView.frame = CGRectMake(20, 0, widht, 40);
        self.collectionView.center = CGPointMake(self.center.x, 0);
    }
    
}

-(UIFont *)getDynamicFontWithDefaultSize:(CGFloat)size
{
    UIFont *defaultFont = [UIFont systemFontOfSize:size];
    if (!defaultFont) {
        defaultFont = [UIFont systemFontOfSize:size];
    }
    
    if ([ALApplozicSettings getChatChannelCellFontTextStyle] && [ALApplozicSettings isTextStyleInCellEnabled]) {
        if (@available(iOS 10.0, *)) {
            return [UIFont preferredFontForTextStyle:[ALApplozicSettings getChatChannelCellFontTextStyle]];
        }
    }
    return defaultFont;
}

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize
{
    [super populateCell:alMessage viewSize:viewSize];
    
    [self.mMessageLabel setFont:[self getDynamicFontWithDefaultSize:[ALApplozicSettings getChannelCellTextFontSize]]];
    
    [self.mMessageLabel setTextAlignment:NSTextAlignmentCenter];
    [self.mMessageLabel setText:alMessage.message];
    [self.mMessageLabel setBackgroundColor:[UIColor clearColor]];
    [self.mMessageLabel setTextColor:[ALApplozicSettings getChannelActionMessageTextColor]];
    
    [self.mDateLabel setHidden:YES];
    self.mUserProfileImageView.alpha = 0;
    self.mNameLabel.hidden = YES;
    self.mChannelMemberName.hidden = YES;
    self.mMessageStatusImageView.hidden = YES;
    
    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message maxWidth:viewSize.width - 115
                                               fontSize:self.mMessageLabel.font.pointSize];
    int padding = 10;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat bubbleWidth = theTextSize.width + (2 * padding);
    
    CGPoint theTextPoint = CGPointMake((screenSize.width - bubbleWidth)/2, 0);
    
    CGRect frame = CGRectMake(theTextPoint.x, theTextPoint.y,
                              bubbleWidth, theTextSize.height + (2 * padding));
    
    self.mBubleImageView.backgroundColor = [ALApplozicSettings getChannelActionMessageBgColor];
    [self.mBubleImageView setFrame:frame];
    [self.mBubleImageView setHidden:NO];
    
    [self.mMessageLabel setFrame: CGRectMake(self.mBubleImageView.frame.origin.x + padding ,padding,
                                             theTextSize.width,
                                             theTextSize.height)];
    if (@available(iOS 11.0, *)) {
        self.mBubleImageView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    } else {
        // Fallback on earlier versions
    }
    
    if (self.channel != nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = -5.0f;
        flowLayout.minimumInteritemSpacing = 10.0f;
        flowLayout.itemSize = CGSizeMake(40.0f, 40.0f);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(10.0f, 20.0f, 10.0f, 20.0f);
        
        CGRect rect = CGRectMake(20, 0, UIScreen.mainScreen.bounds.size.width - 40, 40);
        UICollectionView* collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:flowLayout];
        [collectionView setDataSource: (id)self];
        [collectionView setDelegate: (id)self];
        collectionView.backgroundColor = [UIColor greenColor];
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.showsHorizontalScrollIndicator = false;
        
        [self addSubview:collectionView];
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
    }
    
    return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.channel.userCount.intValue;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"UserCell";
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    for (UIView *subview in [cell.contentView subviews]) {
        [subview removeFromSuperview];
    }
    
    if (@available(iOS 13.0, *)) {
        UIImage* image = [ALUIUtilityClass getImageFromFramworkBundle:@"contact_default_placeholder"];
        UIImageView* imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
      //  ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];

        [cell.contentView addSubview:imageView];
    } else {
        // Fallback on earlier versions
    }
    return cell;
}

-(void)snapToCenter {
    CGPoint centerPoint = [self convertPoint:self.center toView: self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:centerPoint];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
 }

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self snapToCenter];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self snapToCenter];
    }
}

-(void) processKeyBoardHideTap
{
    [self.delegate handleTapGestureForKeyBoard];
}

@end
