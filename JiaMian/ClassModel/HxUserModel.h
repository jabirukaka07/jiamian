//
// HXUserModel.h
// JSON
//
// Created by wy on 13-11-12.
// Copyright (c) 2013年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "UserModel.h"
@interface HxUserModel : JSONModel <NSCopying, NSCoding>

@property(nonatomic, assign) UserModel*           user; 
@property(nonatomic, strong) NSString*  chat_head_image;
@property(nonatomic, strong) NSString*  my_head_image;

@end
