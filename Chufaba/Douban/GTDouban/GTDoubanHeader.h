//
//  GTDoubanHeader.h
//   
//
//  Created by GTL on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef  _GTHeader_h
#define  _GTHeader_h

#define SHARENAME @"绑定豆瓣"
#define kGTAuthorizeURL     @"https://www.douban.com/service/auth2/auth"
#define kGTAccessTokenURL   @"https://www.douban.com/service/auth2/token"
#define kGTAppKey @"03cfaada1083977c0b6f008e318ac674" // 要添加测试用户
#define kGTAppSecret @"3a93b8d8a6fc23d3"

#endif

#define kGTRedirectURI @"http://www.poco.cn"
#define kGTRequestTimeOutInterval   60.0
#define kGTRequestStringBoundary    @"293iosfksdfkiowjksdf31jsiuwq003s02dsaffafass3qw"


#define kGTSDKErrorDomain           @"WeiBoSDKErrorDomain"
#define kGTSDKErrorCodeKey          @"WeiBoSDKErrorCodeKey"
#define kGTSDKAPIDomain             @"https://api.douban.com/"

#define kGTURLSchemePrefix            @"GT_"
#define kGTDoubanServiceNameSuffix    @"_WeiBoServiceName"
#define kGTDoubanUserID               @"douban_user_id"
#define kGTDoubanAccessToken          @"access_token"
#define kGTDoubanExpireTime           @"expires_in"
#define kGTDoubanRefreshToken         @"refresh_token"


typedef enum
{
	kGTErrorCodeInterface	= 100,
	kGTErrorCodeSDK         = 101,
}GTErrorCode;

typedef enum
{
	kGTSDKErrorCodeParseError       = 200,
	kGTSDKErrorCodeRequestError     = 201,
	kGTSDKErrorCodeAccessError      = 202,
	kGTSDKErrorCodeAuthorizeError	= 203,
}GTSDKErrorCode;






