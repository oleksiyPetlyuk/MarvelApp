//
//  MLogger.h
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 19.10.2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Describes log levels
typedef NS_ENUM(NSInteger, MLogLevel) {
  MLogLevelEmergency,
  MLogLevelAlert,
  MLogLevelCritical,
  MLogLevelError,
  MLogLevelWarning,
  MLogLevelNotice,
  MLogLevelInfo,
  MLogLevelDebug,
} NS_SWIFT_NAME(MLogger.LogLevel);

NSString *MLogLevelToString(MLogLevel) NS_SWIFT_NAME(getter:MLogLevel.description(self:));

@interface MLogger : NSObject

@property (class, nonatomic, readonly) MLogger* shared;

- (void)emergency:(NSString *)message;
- (void)alert:(NSString *)message;
- (void)critical:(NSString *)message;
- (void)error:(NSString *)message;
- (void)warning:(NSString *)message;
- (void)notice:(NSString *)message;
- (void)info:(NSString *)message;
- (void)debug:(NSString *)message;
- (void)logAtLevel:(MLogLevel)level message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
