//
//  SourceEditorCommand.m
//  FastProperty
//
//  Created by collegepre on 2018/2/5.
//  Copyright © 2018年 CP. All rights reserved.
//

#import "SourceEditorCommand.h"
#import "NSString+fastProperty.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // 选中去除重复头文件选项
    if ([invocation.commandIdentifier isEqualToString:@"RemoveDuplicateHeaders"]) {
         [self removeDuplicateImportHeaders:invocation];
    }else if([invocation.commandIdentifier isEqualToString:@"FastProperty"]){
        // 自动生成属性
        
    }
   
    
    completionHandler(nil);
}


// 自动添加属性
- (void)audoAddClassProperty:(XCSourceEditorCommandInvocation *)invocation{
    // 1.找到当前类的类名
    // 2.找到@interface位置
    NSString *className = nil;
    NSString *classInterfaceContentString = nil;
    NSInteger classInterfaceLine = -1;
    
    // 找到类的定义
    for (int index = 0; index < invocation.buffer.lines.count; index++) {
        NSString *lineCode = invocation.buffer.lines[index];
        if ([lineCode containsString:@"@interface"]) {
            classInterfaceContentString = lineCode;
            classInterfaceLine = index;
            break;
        }
    }
    
    // 找到类的实现
    for (int index = 0; index < invocation.buffer.lines.count; index++) {
        NSString *lineCode = invocation.buffer.lines[index];
        if ([lineCode containsString:@"@implementation"]) {
            // 去除所有的空格
            NSString *subSr = [lineCode removeBlankString];
            subSr = [lineCode stringByReplacingOccurrencesOfString:@"@implementation" withString:@""];
            className = subSr;
            break;
        }
    }
    
    XCSourceTextRange *selectRange =[invocation.buffer.selections firstObject];
    NSString *lineString = invocation.buffer.lines[selectRange.start.line];
    NSString *selectString = lineString;
    
    if ([selectString containsString:@"="]) {
        NSRange progretyRange = NSMakeRange(0, [selectString rangeOfString:@"="].location);
        NSString *property = [selectString substringWithRange:progretyRange];
        
        // 如果带* 则是对象 使用强引用 如果不带*则使用弱引用
        if ([property containsString:@"*"]) {
            // 添加属性
            NSString *classProperty = [NSString stringWithFormat:@"\n@property (strong, nonatomic) %@;",property];
            invocation.buffer.lines[classInterfaceLine] = [NSString stringWithFormat:@"%@%@",classInterfaceContentString,classProperty];
            
            // 赋值属性
            
            
            
        }
    }
    
}

// 移除重复头文件
- (void)removeDuplicateImportHeaders:(XCSourceEditorCommandInvocation *)invocation{
    //headerDict存放文本中所有的头文件
    NSMutableDictionary <NSString*, NSNumber *> *headerDict = [NSMutableDictionary dictionary];
    //willCheckDict存放将要删除的头文件
    NSMutableDictionary <NSNumber*, NSString *> *willCheckDict = [NSMutableDictionary dictionary];
    
    //遍历编辑器每一行
    for (int idx = 0; idx < invocation.buffer.lines.count; idx++) {
        NSString *lineCode = invocation.buffer.lines[idx];
        //若willCheckDict文件不为空，则进行是否使用了该头文件的判断
        if (willCheckDict.count > 0)
        {
            [willCheckDict enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSString * _Nonnull checkString, BOOL * _Nonnull stop) {
                if ([lineCode containsString:checkString]) {
                    if (![lineCode containsString:@"#import"]) {
                        if ([headerDict[checkString] isEqualToNumber: @1]) {
                            //若使用了该头文件，则从willCheckDict字典中提出该项
                            [willCheckDict removeObjectForKey:key];
                            //同时设置该头文件已经检查过，若后续仍出现该头文件，则可以进行删除
                            headerDict[checkString] = @0;
                        }
                    }
                }
            }];
        }
        
        //检测代码是否含有#import为头文件标志；+号我们认为是类扩展的标志
        if ([lineCode containsString:@"#import"] && ![lineCode containsString:@"+"]) {
            //解析获取类名
            NSRange range1 = [lineCode rangeOfString:@"\""];
            NSRange range2 = [lineCode rangeOfString:@"\"" options:NSBackwardsSearch];
            NSRange zeroRange = NSMakeRange(0, 0);
            
            if (!(NSEqualRanges(range1, zeroRange) || NSEqualRanges(range2, zeroRange))) {
                NSRange findRange = NSMakeRange(range1.location + 1, range2.location - range1.location - 3);
                NSString *classString = [lineCode substringWithRange:findRange];
                willCheckDict[@(idx)] = classString;
                headerDict[classString] = @1;
            }
        }
    }
    
    
    //取出需要删除的行
    NSMutableIndexSet *index = [NSMutableIndexSet indexSet];
    [willCheckDict.allKeys enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [index addIndex:obj.integerValue];
        
    }];
    
    //删除不符合条件的行
    [invocation.buffer.lines removeObjectsAtIndexes:index];
}



@end
