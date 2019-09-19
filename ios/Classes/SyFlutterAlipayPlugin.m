#import "SyFlutterAlipayPlugin.h"
#import <AlipaySDK/AlipaySDK.h>

__weak SyFlutterAlipayPlugin* __FlutterAlipayPlugin;

@interface SyFlutterAlipayPlugin()

@property (readwrite,copy,nonatomic) FlutterResult callback;

@end

@implementation SyFlutterAlipayPlugin

-(id)init{
    if(self = [super init]){

        __FlutterAlipayPlugin  = self;

    }
    return self;
}


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"sy_flutter_alipay"
            binaryMessenger:[registrar messenger]];
  SyFlutterAlipayPlugin* instance = [[SyFlutterAlipayPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"pay" isEqualToString:call.method]) {
      //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
      NSString* urlScheme = [call.arguments objectForKey:@"urlScheme"];
      NSString* payInfo = [call.arguments objectForKey:@"payInfo"];
      if(!urlScheme){
          result(@"");
          NSLog(@"urlScheme 不能为空");
          return;
      }
      self.callback = result;
      // NOTE: 调用支付结果开始支付
       __weak SyFlutterAlipayPlugin* __self = self;
      [[AlipaySDK defaultService] payOrder:payInfo fromScheme:urlScheme callback:^(NSDictionary *resultDic) {
          //NSLog(@"reslut = %@",resultDic);
          [__self onGetResult:resultDic];
      }];
    //result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}
-(void)onGetResult:(NSDictionary*)resultDic{
    if(self.callback!=nil){
        self.callback(resultDic);
        self.callback = nil;
    }

}
+(BOOL)handleOpenURL:(NSURL*)url{
    if(!__FlutterAlipayPlugin)return NO;
    return [__FlutterAlipayPlugin handleOpenURL:url];

}


-(BOOL)handleOpenURL:(NSURL*)url{

    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        __weak SyFlutterAlipayPlugin* __self = self;

        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [__self onGetResult:resultDic];
        }];

        return YES;
    }
    return NO;
}

@end
