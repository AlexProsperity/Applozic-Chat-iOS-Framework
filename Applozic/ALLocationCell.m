//
//  ALLocationCell.m
//  Applozic
//
//  Created by devashish on 01/04/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALLocationCell.h"
#import "Applozic.h"
#import "UIImageView+WebCache.h"
#import "ALMessageInfoViewController.h"
#import "ALUIUtilityClass.h"

@implementation ALLocationCell
{
    CGFloat CELL_HEIGHT;
    CGFloat CELL_WIDTH;
    CGFloat ADJUST_HEIGHT;
    CGFloat ADJUST_WIDTH;
    CGFloat BUBBLE_ABSCISSA;
    CGFloat BUBBLE_ORIDANTE;
    CGFloat FLOAT_CONSTANT;
    CGFloat ADJUST_USER_PROFILE;
    CGFloat USER_PROFILE_CONSTANT;
    CGFloat ZERO;
    CGFloat USER_PROFILE_ABSCISSA;
    CGFloat msgFrameHeight;
    CGFloat DATE_HEIGHT;
    CGFloat MSG_STATUS_CONSTANT;
    CGFloat DATE_PADDING_WIDTH;
    
    NSURL * theUrl;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMaps:)];
        tapper.numberOfTapsRequired = 1;
        [self.frontView addGestureRecognizer:tapper];
        [self.contentView addSubview:self.mImageView];
        
        FLOAT_CONSTANT = 2;
        ADJUST_HEIGHT = 4;
        ADJUST_WIDTH = 4;
        ADJUST_USER_PROFILE = 23;
        USER_PROFILE_CONSTANT = 36;
        ZERO = 0;
        DATE_HEIGHT = 21;
        MSG_STATUS_CONSTANT = 20;
        DATE_PADDING_WIDTH = 25;
        
        if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
            self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mImageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }

        [self.contentView addSubview:self.frontView];
    }
    
    return self;
}

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize
{
    [super populateCell:alMessage viewSize:viewSize];
    [self.replyUIView removeFromSuperview];
    
    self.mUserProfileImageView.alpha = 1;
    
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];
    
    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
    
    NSString * receiverName = [alContact getDisplayName];
    
    self.mMessage = alMessage;
    
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 fontSize:self.mDateLabel.font.pointSize];
    
    [self.mChannelMemberName setHidden:YES];
    [self.mNameLabel setHidden:YES];
    [self.mMessageStatusImageView setHidden:YES];
    [self.replyParentView setHidden:YES];
    
    UITapGestureRecognizer *tapForOpenChat = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processOpenChat)];
    tapForOpenChat.numberOfTapsRequired = 1;
    [self.mUserProfileImageView setUserInteractionEnabled:YES];
    [self.mUserProfileImageView addGestureRecognizer:tapForOpenChat];
    
    CELL_WIDTH = viewSize.width - 120;
    CELL_HEIGHT = viewSize.width - 220;
    
    if([alMessage isReceivedMessage])
    {
        [self.contentView bringSubviewToFront:self.mChannelMemberName];
        
        USER_PROFILE_ABSCISSA = 15;
        
        self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_ABSCISSA, ZERO, USER_PROFILE_CONSTANT, USER_PROFILE_CONSTANT);
        
        if([ALApplozicSettings isUserProfileHidden])
        {
            self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_ABSCISSA, ZERO, ZERO, USER_PROFILE_CONSTANT);
        }
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
        self.mNameLabel.frame = self.mUserProfileImageView.frame;
        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:receiverName]];

        BUBBLE_ABSCISSA = self.mUserProfileImageView.frame.size.width + ADJUST_USER_PROFILE;
        
     
        CGFloat imageViewY = self.mBubleImageView.frame.origin.y + FLOAT_CONSTANT;
        CGFloat imageHeight = CELL_HEIGHT;      

       self.mBubleImageView.frame = CGRectMake(BUBBLE_ABSCISSA, ZERO, CELL_WIDTH, CELL_HEIGHT);
        
        if( alMessage.groupId )
        {
            [self.mChannelMemberName setTextColor: [UIColor colorWithRed:33.0/255 green:120.0/255 blue:103.0/255 alpha:1]];
            [self.mChannelMemberName setText:receiverName];
            [self.mChannelMemberName setHidden:NO];
            self.mChannelMemberName.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 10,
                                                       self.mBubleImageView.frame.origin.y + 5,
                                                       self.mBubleImageView.frame.size.width - 10, 20);
            
            CELL_HEIGHT = CELL_HEIGHT + self.mChannelMemberName.frame.size.height ;
            imageViewY = imageViewY + self.mChannelMemberName.frame.size.height;
        }
        
        if( alMessage.isAReplyMessage )
        {
            [self processReplyOfChat:alMessage andViewSize:viewSize];
            CELL_HEIGHT = CELL_HEIGHT + self.replyParentView.frame.size.height ;
            imageViewY =  imageViewY + self.replyParentView.frame.size.height;
        
        }
        self.mBubleImageView.frame = CGRectMake(BUBBLE_ABSCISSA, ZERO, CELL_WIDTH, CELL_HEIGHT);
        
        if (@available(iOS 11.0, *)) {
            self.mBubleImageView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner | kCALayerMaxXMaxYCorner;
        } else {
            // Fallback on earlier versions
        }
                
        self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + FLOAT_CONSTANT,
                                           imageViewY,
                                           self.mBubleImageView.frame.size.width - ADJUST_WIDTH,
                                           imageHeight - ADJUST_HEIGHT);
        
        self.mDateLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x,
                                           self.mBubleImageView.frame.origin.y +
                                           self.mBubleImageView.frame.size.height,
                                           theDateSize.width,
                                           DATE_HEIGHT);
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width + 5,
                                                        self.mDateLabel.frame.origin.y,
                                                        MSG_STATUS_CONSTANT, MSG_STATUS_CONSTANT);
        
        if(alContact.contactImageUrl)
        {
            [ALUIUtilityClass downloadImageUrlAndSet:alContact.contactImageUrl imageView:self.mUserProfileImageView defaultImage:@"contact_default_placeholder"];
        }
        else
        {
            [self.mUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil options:SDWebImageRefreshCached];
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:receiverName colorCodes:self.alphabetiColorCodesDictionary];
        }
    }
    else
    {
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];
        USER_PROFILE_ABSCISSA = viewSize.width - 50;
        self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_ABSCISSA, FLOAT_CONSTANT, ZERO, USER_PROFILE_CONSTANT);
        
        CGFloat imageViewY = self.mBubleImageView.frame.origin.y + FLOAT_CONSTANT;
        CGFloat imageHeight = CELL_HEIGHT;
        
        BUBBLE_ABSCISSA = viewSize.width - self.mUserProfileImageView.frame.origin.x + 50;
        self.mBubleImageView.frame = CGRectMake(BUBBLE_ABSCISSA, ZERO, CELL_WIDTH, CELL_HEIGHT);
    
        if(alMessage.isAReplyMessage)
        {
            [self processReplyOfChat:alMessage andViewSize:viewSize];
            CELL_HEIGHT = CELL_HEIGHT + self.replyParentView.frame.size.height;
            imageViewY = imageViewY + self.replyParentView.frame.size.height;
            
        }
        
        self.mBubleImageView.frame = CGRectMake(BUBBLE_ABSCISSA, ZERO, CELL_WIDTH, CELL_HEIGHT);

        if (@available(iOS 11.0, *)) {
            self.mBubleImageView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
        } else {
            // Fallback on earlier versions
        }
        
        self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + FLOAT_CONSTANT,imageViewY,
                                           self.mBubleImageView.frame.size.width - ADJUST_WIDTH,
                                           imageHeight - ADJUST_HEIGHT);
        
        msgFrameHeight = self.mBubleImageView.frame.size.height;
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width) - theDateSize.width - DATE_PADDING_WIDTH,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height, theDateSize.width, DATE_HEIGHT);
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width + 5,
                                                        self.mDateLabel.frame.origin.y, MSG_STATUS_CONSTANT, MSG_STATUS_CONSTANT);

        if ([alMessage isSentMessage] && ((self.channel && self.channel.type != OPEN) || !self.channel)) {
            self.mMessageStatusImageView.hidden = NO;
            NSString * imageName = [self getMessageStatusIconName:self.mMessage];
            self.mMessageStatusImageView.image = [ALUIUtilityClass getImageFromFramworkBundle:imageName];
        }
    }

    self.frontView.frame = self.mBubleImageView.frame;

    self.mDateLabel.text = theDate;
    theUrl = nil;
    NSString *latLongArgument = [self formatLocationJson:alMessage];
    
    if([ALDataNetworkConnection checkDataNetworkAvailable])
    {
        NSString * finalURl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=17&size=290x179&maptype=roadmap&format=png&visual_refresh=true&markers=%@&key=%@",
                               latLongArgument,latLongArgument,[ALUserDefaultsHandler getGoogleMapAPIKey]];
        
        theUrl = [NSURL URLWithString:finalURl];
        [self.mImageView sd_setImageWithURL:theUrl];
    }
    else
    {
        [self.mImageView setImage:[ALUIUtilityClass getImageFromFramworkBundle:@"ic_map_no_data.png"]];
    }
    
    [self addShadowEffects];
    
    if(alMessage.isAReplyMessage)
    {
        [self.contentView bringSubviewToFront:self.replyParentView];
        
    }

    return self;
}

-(void) addShadowEffects
{
//    self.mBubleImageView.layer.shadowOpacity = 0.3;
//    self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
//    self.mBubleImageView.layer.shadowRadius = 1;
//    self.mBubleImageView.layer.masksToBounds = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(NSString*)formatLocationJson:(ALMessage *)locationAlMessage
{
    NSError *error;
    NSData *objectData = [locationAlMessage.message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonStringDic = [NSJSONSerialization JSONObjectWithData:objectData
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&error];
  
    NSArray* latLog = [[NSArray alloc] initWithObjects:[jsonStringDic valueForKey:@"lat"],[jsonStringDic valueForKey:@"lon"], nil];
    
    if(!latLog.count)
    {
        return [self processMapUrl:locationAlMessage];
    }
    
    NSString *latLongArgument = [NSString stringWithFormat:@"%@,%@", latLog[0], latLog[1]];
    return latLongArgument;
}

-(NSString *)processMapUrl:(ALMessage *)message
{
    NSArray * URL_ARRAY = [message.message componentsSeparatedByString:@"="];
    NSString * coordinate = (NSString *)[URL_ARRAY lastObject];
    return coordinate;
}

-(void)showMaps:(UITapGestureRecognizer *)sender
{
    NSString * URLString = [NSString stringWithFormat:@"https://maps.google.com/maps?q=%@",[self formatLocationJson:super.mMessage]];
    NSURL * locationURL = [NSURL URLWithString:URLString];
    [[UIApplication sharedApplication] openURL:locationURL options:@{} completionHandler:nil];
}

-(void)openUserChatVC
{
    [self.delegate processUserChatView:self.mMessage];
}


-(NSString*)getLocationUrl:(ALMessage*)almessage;
{
    NSString *latLongArgument = [self formatLocationJson:almessage];
    NSString * finalURl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=17&size=290x179&maptype=roadmap&format=png&visual_refresh=true&markers=%@&key=%@",
                           latLongArgument,latLongArgument,[ALUserDefaultsHandler getGoogleMapAPIKey]];

    return finalURl;
}

-(void)processOpenChat
{
    [self.delegate handleTapGestureForKeyBoard];
    [self.delegate openUserChat:self.mMessage];
}

- (void)msgInfo:(id)sender {
    [self.delegate showAnimationForMsgInfo:YES];
    UIStoryboard *storyboardM = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALMessageInfoViewController *msgInfoVC = (ALMessageInfoViewController *)[storyboardM instantiateViewControllerWithIdentifier:@"ALMessageInfoView"];
    msgInfoVC.contentURL = theUrl;
    __weak typeof(ALMessageInfoViewController *) weakObj = msgInfoVC;

    [msgInfoVC setMessage:self.mMessage andHeaderHeight:msgFrameHeight withCompletionHandler:^(NSError *error) {

        if(!error)
        {
            [self.delegate loadViewForMedia:weakObj];
        }
        else
        {
            [self.delegate showAnimationForMsgInfo:NO];
        }
    }];
}

@end
