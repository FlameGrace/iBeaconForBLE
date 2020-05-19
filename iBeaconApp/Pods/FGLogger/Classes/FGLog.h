//
//  FGLog.h
//  FGLog
//
//  Created by 周浩冉 on 2020/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FGLogModuleSign) {
    FGLog_UnclearModule,
    FGLog_Home,
    
};

typedef NS_ENUM(NSInteger, FGLogLevel) {
    
    FGLogLevel_UnKnow = 0,
    FGLogLevel_Warning,
    FGLogLevel_MustShow,
    FGLogLevel_WriteToFile = FGLogLevel_MustShow,
};

#define FGLog(module,level,format,...) {[FGLogPrinter FGLogLevel:level Module:module ModuleStr:#module Function:__FUNCTION__ Thread:[NSThread currentThread] Line:__LINE__ Format:format Info:[NSString stringWithFormat:format,##__VA_ARGS__]];}

@interface FGLogPrinter : NSObject

+ (void)FGLogLevel:(NSInteger)level
            Module:(NSInteger)module
         ModuleStr:(const char* const)moduleStr
          Function:(const char* const)function
            Thread:(NSThread*)currentThread
              Line:(int)line
            Format:(NSString*)format
              Info:(NSString*)info;

@end

NS_ASSUME_NONNULL_END
