//
//  MyContactMessageCell.m
//  Applozic
//
//  Created by apple on 06/06/19.
//  Copyright © 2019 applozic Inc. All rights reserved.
//

#import "ALMyContactMessageCell.h"
#import "UIImageView+WebCache.h"
#import "ALColorUtility.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"
#import "ALVCardClass.h"
#import "ALUIUtilityClass.h"

static CGFloat const USER_PROFILE_PADDING_X_OUTBOX = 50;
static CGFloat const USER_PROFILE_HEIGHT = 36;
static CGFloat const BUBBLE_PADDING_X_OUTBOX = 50;
static CGFloat const BUBBLE_PADDING_WIDTH = 120;
static CGFloat const BUBBLE_PADDING_HEIGHT_OUTBOX = 180;

static CGFloat const DATE_PADDING_X = 25;
static CGFloat const DATE_HEIGHT = 20;

static CGFloat const MSG_STATUS_WIDTH = 20;
static CGFloat const MSG_STATUS_HEIGHT = 20;

static CGFloat const CNT_PROFILE_X = 10;
static CGFloat const CNT_PROFILE_Y = 10;
static CGFloat const CNT_PROFILE_HEIGHT = 50;
static CGFloat const CNT_PROFILE_WIDTH = 50;
static CGFloat const CNT_PERSON_X = 10;
static CGFloat const CNT_PERSON_HEIGHT = 20;

static CGFloat const USER_CNT_Y = 5;
static CGFloat const USER_CNT_HEIGHT = 50;

static CGFloat const EMAIL_Y = 5;
static CGFloat const EMAIL_HEIGHT = 50;

static CGFloat const BUTTON_Y = 50;
static CGFloat const BUTTON_WIDTH = 20;
static CGFloat const BUTTON_HEIGHT = 40;
static CGFloat const AL_CONTACT_ADD_BUTTON_HEIGHT_PADDING = 230;

@interface ALMyContactMessageCell ()

@end

@implementation ALMyContactMessageCell
{
    NSURL *theUrl;
}
-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if(self)
    {

        if(!ALApplozicSettings.isAddContactButtonForSenderDisabled){

            self.addContactButton = [[UIButton alloc] init];
            [self.addContactButton setTitle: NSLocalizedStringWithDefaultValue(@"addContactButtonText", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"ADD CONTACT", @"") forState:UIControlStateNormal];
            [self.addContactButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.addContactButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [self.addContactButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [self.addContactButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [self.contentView addSubview:self.addContactButton];

            if([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft){
                self.addContactButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            }
        }
    }
    return self;
}

-(instancetype)populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize
{

    [super populateCell:alMessage viewSize:viewSize];
    self.contactProfileImage.layer.cornerRadius = self.contactProfileImage.frame.size.width/2;
    self.contactProfileImage.layer.masksToBounds = YES;

    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];

    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];

    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 fontSize:self.mDateLabel.font.pointSize];


    [self addContactButtonEnable:NO];
    
    if ([alMessage isSentMessage]){

        [self.contactPerson setTextColor:[ALApplozicSettings getSentContactMsgLabelColor]];
        [self.userContact setTextColor:[ALApplozicSettings getSentContactMsgLabelColor]];
        [self.emailId setTextColor:[ALApplozicSettings getSentContactMsgLabelColor]];

        self.mUserProfileImageView.frame = CGRectMake(viewSize.width - USER_PROFILE_PADDING_X_OUTBOX, 0, 0, USER_PROFILE_HEIGHT);

        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];


        //Shift for message reply and channel name..

        int widthPadding =  (ALApplozicSettings.isAddContactButtonForSenderDisabled ?   AL_CONTACT_ADD_BUTTON_HEIGHT_PADDING: BUBBLE_PADDING_HEIGHT_OUTBOX );

        CGFloat requiredHeight = viewSize.width - widthPadding;

        CGFloat imageViewY =  self.mBubleImageView.frame.origin.y + CNT_PROFILE_Y;

        self.mBubleImageView.frame = CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + BUBBLE_PADDING_X_OUTBOX), 0,
                                                viewSize.width - BUBBLE_PADDING_WIDTH, viewSize.width - widthPadding);

        if(alMessage.isAReplyMessage)
        {
            [self processReplyOfChat:alMessage andViewSize:viewSize];

            requiredHeight = requiredHeight + self.replyParentView.frame.size.height;
            imageViewY = imageViewY +  self.replyParentView.frame.size.height;

        }


        self.mBubleImageView.frame = CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + BUBBLE_PADDING_X_OUTBOX), 0,
                                                viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight);
   
        if (@available(iOS 11.0, *)) {
            self.mBubleImageView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
        } else {
            // Fallback on earlier versions
        }
        
        [self.contactProfileImage setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + CNT_PROFILE_X,
                                                      self.mBubleImageView.frame.origin.y + CNT_PROFILE_Y,
                                                      CNT_PROFILE_WIDTH, CNT_PROFILE_HEIGHT)];

        CGFloat widthName = self.mBubleImageView.frame.size.width - (self.contactProfileImage.frame.size.width + 25);

        [self.contactPerson setFrame:CGRectMake(self.contactProfileImage.frame.origin.x +
                                                self.contactProfileImage.frame.size.width + CNT_PERSON_X,
                                                self.contactProfileImage.frame.origin.y, widthName, CNT_PERSON_HEIGHT)];

        [self.userContact setFrame:CGRectMake(self.contactPerson.frame.origin.x,
                                              self.contactPerson.frame.origin.y + self.contactPerson.frame.size.height + USER_CNT_Y,
                                              widthName, USER_CNT_HEIGHT)];

        [self.emailId setFrame:CGRectMake(self.userContact.frame.origin.x, self.userContact.frame.origin.y +
                                          self.userContact.frame.size.height + EMAIL_Y,
                                          widthName, EMAIL_HEIGHT)];

        if(!ALApplozicSettings.isAddContactButtonForSenderDisabled){

            [self.addContactButton setFrame:CGRectMake(self.contactProfileImage.frame.origin.x,
                                                       self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height - BUTTON_Y,
                                                       self.mBubleImageView.frame.size.width - BUTTON_WIDTH, BUTTON_HEIGHT)];

            self.msgFrameHeight = self.mBubleImageView.frame.size.height - (self.addContactButton.frame.size.height + self.addContactButton.frame.size.height/2);
            
            [self.addContactButton setBackgroundColor:[UIColor whiteColor]];
            self.addContactButton.layer.cornerRadius = 10;

        }else{
            self.msgFrameHeight = self.mBubleImageView.frame.size.height;
        }

        self.mDateLabel.textAlignment = NSTextAlignmentLeft;

        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width)
                                           - theDateSize.width - DATE_PADDING_X,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height,
                                           theDateSize.width, DATE_HEIGHT);

        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width + 5,
                                                        self.mDateLabel.frame.origin.y,
                                                        MSG_STATUS_WIDTH, MSG_STATUS_HEIGHT);

    }

    [self.contactProfileImage setImage:[ALUIUtilityClass getImageFromFramworkBundle:@"contact_default_placeholder"]];
    self.contactProfileImage.layer.cornerRadius = self.contactProfileImage.frame.size.width/2;
    self.contactProfileImage.layer.masksToBounds = YES;

    self.mDateLabel.text = theDate;

    self.frontView.frame = self.mBubleImageView.frame;

    theUrl = nil;
    self.vCardClass = nil;
    if (alMessage.imageFilePath != NULL)
    {
        NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * filePath = [docDir stringByAppendingPathComponent:alMessage.imageFilePath];
        theUrl = [NSURL fileURLWithPath:filePath];

        self.vCardClass = [[ALVCardClass alloc] init];
        [self.vCardClass vCardParser:filePath];

        [self.contactPerson setText:self.vCardClass.fullName];
        if(self.vCardClass.contactImage)
        {
            [self.contactProfileImage setImage:self.vCardClass.contactImage];
        }
        [self.emailId setText:self.vCardClass.userEMAIL_ID];
        [self.userContact setText:self.vCardClass.userPHONE_NO];
        [self addContactButtonEnable:YES];

    }

    if ([alMessage isSentMessage] && ((self.channel && self.channel.type != OPEN) || !self.channel)) {

        self.mMessageStatusImageView.hidden = NO;
        NSString * imageName = [self getMessageStatusIconName:self.mMessage];
        self.mMessageStatusImageView.image = [ALUIUtilityClass getImageFromFramworkBundle:imageName];
    }
    return self;
}


-(void)addButtonAction
{
    @try
    {
        [self.vCardClass addContact:self.vCardClass];
    } @catch (NSException *exception) {

        ALSLog(ALLoggerSeverityInfo, @"CONTACT_EXCEPTION :: %@", exception.description);
    }
}

-(void)addContactButtonEnable:(BOOL)flag{
    if(!ALApplozicSettings.isAddContactButtonForSenderDisabled){
        [self.addContactButton setEnabled:flag];
    }
}

@end
