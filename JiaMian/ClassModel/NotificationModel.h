//
// NotificationModel.h
//
// Created by wy on 13-12-6.
// Copyright (c) 2013年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

#import "MessageModel.h"
#import "AreaModel.h"
#import "UserModel.h"

@interface NotificationModel : JSONModel

@property(nonatomic, copy) NSString*       create_at;
@property(nonatomic, assign) long          notification_id;
@property(nonatomic, assign) long          status;         //1-未读，2-已读
@property(nonatomic, copy) MessageModel*   message;
@property(nonatomic, copy) AreaModel*      area;
@property(nonatomic, copy) UserModel*      user;

@end