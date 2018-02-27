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
    //headerDict存放文本中需要导入的头文件
    NSMutableArray  *headerArr = [NSMutableArray array];
    //willCheckDict存放将要删除的重复的头文件
    NSMutableArray  *willCheckArr = [NSMutableArray array];
    
    //遍历编辑器每一行
    for (int idx = 0; idx < invocation.buffer.lines.count; idx++) {
        NSString *lineCode = invocation.buffer.lines[idx];
        lineCode = [self stringWithRemoveTrimmingCharacters:lineCode];
        if ([lineCode containsString:@"#import"]) {
            // 如果包含import 说明是头文件引入
            if ([[lineCode substringWithRange:NSMakeRange(0, 7)] isEqualToString:@"#import"]) {
                //开始引入
                NSDictionary *header = @{@"header":lineCode,@"line":@(idx)};
                for (NSDictionary *dict in headerArr) {
                    if ([dict[@"header"] isEqualToString:lineCode]) {
                        [willCheckArr addObject:header];
                    }
                }
                
                if (![willCheckArr containsObject:header]) {
                    [headerArr addObject:header];
                }
            }
        }
    }
    NSMutableIndexSet *indexs = [NSMutableIndexSet indexSet];
    for (NSDictionary *dict in willCheckArr) {
        NSNumber *index = dict[@"line"];
        [indexs addIndex:index.integerValue];
    }
  
    //删除不符合条件的行
    [invocation.buffer.lines removeObjectsAtIndexes:indexs];
    
}

- (NSString *)stringWithRemoveTrimmingCharacters:(NSString *)string{
    return [string stringByReplacingOccurrencesOfString:@" " withString:@""];
}



@end
