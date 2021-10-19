//
//  MLogger.m
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 19.10.2021.
//

#import <Foundation/Foundation.h>
#import "MLogger.h"

@interface MLogger ()

- (void)writeLogWithLevel:(MLogLevel)level message:(NSString *)message;

@end

@implementation MLogger

static MLogger *_shared = nil;

+ (MLogger *)shared {
  if (!_shared) {
    _shared = [[MLogger alloc] init];
  }

  return _shared;
}

- (void)emergency:(NSString *)message {
  [self writeLogWithLevel:MLogLevelEmergency message:message];
}

- (void)alert:(NSString *)message {
  [self writeLogWithLevel:MLogLevelAlert message:message];
}

- (void)critical:(NSString *)message {
  [self writeLogWithLevel:MLogLevelCritical message:message];
}

- (void)error:(NSString *)message {
  [self writeLogWithLevel:MLogLevelError message:message];
}

- (void)warning:(NSString *)message {
  [self writeLogWithLevel:MLogLevelWarning message:message];
}

- (void)notice:(NSString *)message {
  [self writeLogWithLevel:MLogLevelNotice message:message];
}

- (void)info:(NSString *)message {
  [self writeLogWithLevel:MLogLevelInfo message:message];
}

- (void)debug:(NSString *)message {
  [self writeLogWithLevel:MLogLevelDebug message:message];
}

- (void)logAtLevel:(MLogLevel)level message:(NSString *)message {
  [self writeLogWithLevel:level message:message];
}

- (void)writeLogWithLevel:(MLogLevel)level message:(NSString *)message {
  NSString *logLevelMessage;

  switch (level) {
    case MLogLevelEmergency:
      logLevelMessage = @"EMERGENCY";
      break;
    case MLogLevelAlert:
      logLevelMessage = @"ALERT";
      break;
    case MLogLevelCritical:
      logLevelMessage = @"CRITICAL";
      break;
    case MLogLevelError:
      logLevelMessage = @"ERROR";
      break;
    case MLogLevelWarning:
      logLevelMessage = @"WARNING";
      break;
    case MLogLevelNotice:
      logLevelMessage = @"NOTICE";
      break;
    case MLogLevelInfo:
      logLevelMessage = @"INFO";
      break;
    case MLogLevelDebug:
      logLevelMessage = @"DEBUG";
      break;
  }

  NSLog(@"MLogger(%@): %@", logLevelMessage, message);
}

@end
