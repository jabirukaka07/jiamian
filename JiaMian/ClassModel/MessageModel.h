// MessageModel.h
//
// Created by wy on 13-11-16.
// Copyright (c) 2013年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "AreaModel.h"
#import "UserModel.h"
#import "CommentModel.h"
#import "VoteModel.h"
#import "TopicModel.h"
#import "CategoryModel.h"

@protocol MessageModel
@end

@interface MessageModel : JSONModel

@property(nonatomic, strong) NSString*           create_at;
@property(nonatomic, assign) long                message_id;
@property(nonatomic, assign) int                 message_type;    // 1-文本消息(默认)，2-（语音...）
@property(nonatomic, strong) NSString<Optional>* text;
@property(nonatomic, assign) int                 comments_count;  //评论数目
@property(nonatomic, assign) int                 likes_count;     //点赞数目
@property(nonatomic, assign) int                 visible_count;   //可见人数数目
@property(nonatomic, assign) int                 background_type; //背景图片类型，1-序号，2-图片URL
@property(nonatomic, assign) int                 background_no;   //背景图片序号（仅当type为1有效，否则null）
@property(nonatomic, assign) int                 background_no2;
@property(nonatomic, strong) NSString<Optional>* background_url;  //背景图片序号（仅当type为2有效，否则null）
@property(nonatomic, strong) AreaModel<Optional>*  area;
@property(nonatomic, strong) UserModel<Optional>* user;
@property(nonatomic, assign) BOOL                is_official;
@property(nonatomic, assign) BOOL                is_owner;
@property(nonatomic, assign) BOOL                has_like;
@property(nonatomic, assign) BOOL                voted;
@property(nonatomic, strong) NSArray <VoteModel, Optional>*   votes;
@property(nonatomic, strong) NSArray<Optional>* topics;
@property(nonatomic, strong) CommentModel <Optional>* hots_comment;
@property(nonatomic, strong) NSString<Optional>* message_key;
@property(nonatomic, assign) int                 real_like_count;
@property(nonatomic, assign) int                 report_count;
@property(nonatomic, assign) int                 real_comment_count;
@property(nonatomic, assign) int                 message_status;
@property(nonatomic, strong) CategoryModel<Optional>*      category;

@end

@interface Messages : JSONModel

@property(strong, nonatomic) NSString* categoryName;
@property(strong, nonatomic) NSArray<MessageModel>* messages;

@end
