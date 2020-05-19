//
//  FGLog.m
//  FGLog
//
//  Created by 周浩冉 on 2020/3/26.
//

#import "FGLog.h"
#import "FGTTYLogger.h"

@implementation FGLogPrinter

+ (void)FGLogLevel:(NSInteger)level
            Module:(NSInteger)module
         ModuleStr:(const char* const)moduleStr
          Function:(const char* const)function
            Thread:(NSThread*)currentThread
              Line:(int)line
            Format:(NSString*)format
              Info:(NSString*)info {
    NSLog((@"%@-[%s]-%d-\nLog:%@%@."),currentThread, function, line,info,@"\n");
    if(level >= FGLogLevel_MustShow){
        [[FGTTYLogger shareLogger]writeLog:[NSString stringWithFormat: @"%@-[%s]-%d-\nLog:%@.\n", currentThread, function, line,info] moduleName:[NSString stringWithCString:moduleStr encoding:NSUTF8StringEncoding]];
    }
}

@end
