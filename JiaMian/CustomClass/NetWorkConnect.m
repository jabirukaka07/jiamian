#import "NetWorkConnect.h"
#import "Reachability.h"

#define CustomErrorDomain @"com.jiamiantech"
#define ErrorAlerView [[[UIAlertView alloc] initWithTitle:@"系统提示" message:@"服务器罢工了,请稍侯再试试吧" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];


@implementation NetWorkConnect

static ASIDownloadCache* myCache;

+(instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        myCache = [[ASIDownloadCache alloc] init];
        
        //设置缓存路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        [myCache setStoragePath:[documentDirectory stringByAppendingPathComponent:@"mycache"]];
        [myCache setDefaultCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    });
    return sharedInstance;
}

- (BOOL)checkNetworkStatus
{
    Reachability *myNetwork = [Reachability reachabilityWithHostName:@"baidu.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    if (NotReachable == myStatus) {
        [[[UIAlertView alloc] initWithTitle:@"系统提示"
                                    message:@"您还没有连接网络哦"
                                   delegate:nil
                          cancelButtonTitle:@"知道了"
                          otherButtonTitles:nil] show];
        return NO;
    }else{
        return YES;
    }
}
//////////////////////////////////////////////////////////////////
- (UserModel*)userLogInWithToken:(NSString*)AccessToken userIdentify:(NSString*)Identity userType:(int)Type error:(NSError**)Error
{
    if (NO == [self checkNetworkStatus])
        return nil;
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/login", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:AccessToken forKey:@"access_token"];
    [request setPostValue:Identity forKey:@"user_identity"];
    [request setPostValue:[NSNumber numberWithInt:Type] forKey:@"user_type"];
    
    [request startSynchronous];
    
    NSLog(@"%@ responseString=%d", requestUrl, request.responseStatusCode);
    if ( [request responseStatusCode] != 200 )
    {
        //{"err_code":"10001","err_msg":"Test Login Error"}
        ErrorAlerView;
        return nil;
    }
    else
    {
        NSError* error;
        UserModel* userInfo = [[UserModel alloc] initWithString:[request responseString] error:&error];
        if (userInfo)
            return userInfo;
        else
        {
            NSDictionary *errorInfo = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:nil];
            *Error = [NSError errorWithDomain:CustomErrorDomain code:0 userInfo:errorInfo];
            return nil;
        }
    }
}

//////////////////////////////////////////////////////////////////
- (BOOL)userLogOut
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/logout", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request startSynchronous];
    return YES;
}

//////////////////////////////////////////////////////////////////
- (UserModel*)userRegisterWithName:(NSString*)UserName userType:(int)Type gender:(int)Gender headImg:(NSString*)HeadImg description:(NSString*)Description
{
    if (NO == [self checkNetworkStatus])
        return nil;
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/register", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:UserName forKey:@"user_name"];
    [request setPostValue:[NSNumber numberWithInt:Type] forKey:@"user_type"];
    [request setPostValue:[NSNumber numberWithInt:Gender] forKey:@"gender"];
    if (HeadImg)
        [request setPostValue:HeadImg forKey:@"head_image"];
    if (Description)
        [request setPostValue:Description forKey:@"description"];
    
    [request startSynchronous];
    if ( 200 == [request responseStatusCode] )
        return [[UserModel alloc] initWithString:[request responseString] error:nil];
    else
    {
        ErrorAlerView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (UserModel*)userShowById:(int)UserId
{
    if (NO == [self checkNetworkStatus])
        return nil;
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/show", HOME_PAGE];
    if (0 != UserId)
        requestUrl = [requestUrl stringByAppendingFormat:@"?user_id=%d", UserId];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    NSLog(@"userShowById: %@", [request responseString]);
    if ( 200 == [request responseStatusCode] )
        return [[UserModel alloc] initWithString:[request responseString] error:nil];
    else
    {
        ErrorAlerView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (NSDictionary*)userMessageLimit
{
    if (NO == [self checkNetworkStatus])
        return nil;
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/messageLimit", HOME_PAGE];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    NSLog(@"userMessageLimit: %@", [request responseString]);
    if ( 200 == [request responseStatusCode] )
    {
        NSData *jsonData = [[request responseString] dataUsingEncoding:NSUTF8StringEncoding];
        return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    }
    else
    {
        ErrorAlerView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (NSArray*)messageList:(int)AreaId sinceId:(long)SinceId maxId:(long)MaxId count:(int)Count trimArea:(BOOL) TrimArea filterType:(int)FilterType
{
    if (NO == [self checkNetworkStatus])
        return [NSArray array];
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/messages/list?area_id=%d&count=%d", HOME_PAGE, AreaId, Count];
    if (SinceId != 0)
        requestUrl = [requestUrl stringByAppendingFormat:@"&since_id=%ld", SinceId];
    if (MaxId != INT_MAX)
        requestUrl = [requestUrl stringByAppendingFormat:@"&max_id=%ld", MaxId];
    if ( (FilterType == 0) || (FilterType == 1) )
        requestUrl = [requestUrl stringByAppendingFormat:@"&filter_type=%d", FilterType];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    NSLog(@"URL = %@, code = %d, %@", requestUrl, request.responseStatusCode, request.responseString);
    if (200 == [request responseStatusCode])
    {
        NSError* error;
        Messages* result = [[Messages alloc] initWithString:[request responseString] error:&error];
        if (result) {
            return [result.messages copy];
        }else{
            NSLog(@"error = %@", [error description]);
            return [NSArray array];
        }
    }
    else
    {
        ErrorAlerView;
        return [NSArray array];
    }
}

//////////////////////////////////////////////////////////////////
- (MessageModel*)messageShowByMsgId:(long)MsgId
{
    if (NO == [self checkNetworkStatus])
        return nil;
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/messages/show?message_id=%ld", HOME_PAGE, MsgId];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
    {
        return [[MessageModel alloc] initWithString:[request responseString] error:nil];
    }
    else
    {
        ErrorAlerView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (MessageModel*)messageCreate:(NSString*)Text msgType:(int)MsgType areaId:(int)AreaId lat:(double)Lat lon:(double)Long
{
    if (NO == [self checkNetworkStatus])
        return nil;
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/messages/create", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:Text forKey:@"text"];
    [request setPostValue:[NSNumber numberWithInt:MsgType]  forKey:@"message_type"];
    [request setPostValue:[NSNumber numberWithInt:AreaId]   forKey:@"area_id"];
    [request setPostValue:[NSNumber numberWithDouble:Lat]   forKey:@"lat"];
    [request setPostValue:[NSNumber numberWithDouble:Long]  forKey:@"long"];
    
    [request startSynchronous];
    NSLog(@"%s, result=%@", __FUNCTION__, [request responseString]);
    if ( 200 == [request responseStatusCode] )
        return [[MessageModel alloc] initWithString:[request responseString] error:nil];
    else
    {
        ErrorAlerView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (NSArray*)commentShowByMsgId:(long)MsgId sinceId:(long)SinceId maxId:(long)MaxId count:(int)Count
{
    if (NO == [self checkNetworkStatus])
        return [NSArray array];
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/comments/show?message_id=%ld&count=%d", HOME_PAGE, MsgId, Count];
    if (SinceId != 0)
        requestUrl = [requestUrl stringByAppendingFormat:@"&since_id=%ld", SinceId];
    if (MaxId != INT_MAX)
        requestUrl = [requestUrl stringByAppendingFormat:@"&max_id=%ld", MaxId];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
    [request startSynchronous];
    
    NSLog(@"url = %@, comment = %@", requestUrl, request.responseString);
    if (200 == [request responseStatusCode])
    {
        NSError* error;
        Comments* result = [[Comments alloc] initWithString:[request responseString] error:&error];
        if (result) {
            return [result.comments copy];
        }else{
            NSLog(@"error = %@", [error description]);
            return [NSArray array];
        }
    }
    else
    {
        ErrorAlerView;
        return [NSArray array];
    }
}
//////////////////////////////////////////////////////////////////
- (CommentModel*)commentCreate:(long)MsgId text:(NSString*)Text
{
    if (NO == [self checkNetworkStatus])
        return nil;
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/comments/create", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:Text forKey:@"text"];
    [request setPostValue:[NSNumber numberWithLong:MsgId]  forKey:@"message_id"];
    
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
        return [[CommentModel alloc] initWithString:[request responseString] error:nil];
    else
    {
        ErrorAlerView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (NSArray*)notificationShow:(long)SinceId maxId:(long)MaxId count:(int)Count
{
    if (NO == [self checkNetworkStatus])
        return [NSArray array];
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/notifications/show?count=%d", HOME_PAGE, Count];
    if (SinceId != 0)
        requestUrl = [requestUrl stringByAppendingFormat:@"&since_id=%ld", SinceId];
    if (MaxId != INT_MAX)
        requestUrl = [requestUrl stringByAppendingFormat:@"&max_id=%ld", MaxId];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    NSLog(@"%@", request.responseString);
    NSMutableArray* result = [NSMutableArray array];
    if ( 200 == [request responseStatusCode] )
    {
        NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableContainers error:nil];
        for (id entry in jsonArray)
        {
            NSError* error;
            NotificationModel* notification = [[NotificationModel alloc] initWithDictionary:entry error:&error];
            NSLog(@"error = %@", error.description);
            if (notification)
                [result addObject:notification];
        }
        return result;
    }
    else
    {
        ErrorAlerView;
        return result;
    }
}

//////////////////////////////////////////////////////////////////
- (int)notificationUnreadCount
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/notifications/unreadCount", HOME_PAGE];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
    {
        NSData *jsonData = [[request responseString] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dict =  [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        return [[dict objectForKey:@"unread_count"] integerValue];
    }
    else
        return 0;
}
@end