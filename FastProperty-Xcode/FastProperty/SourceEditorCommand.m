//
//  SourceEditorCommand.m
//  FastProperty
//
//  Created by collegepre on 2018/2/5.
//  Copyright © 2018年 CP. All rights reserved.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    for (XCSourceTextRange *selection in invocation.buffer.selections) {
        NSInteger firstIndex = selection.start.line;
        NSString *firstText = invocation.buffer.lines[firstIndex];
        
        
        NSInteger lastIndex = selection.end.line;
        NSString *lastText = invocation.buffer.lines[lastIndex];
        
        invocation.buffer.lines[firstIndex] = [NSString stringWithFormat:@"/*1\n%@--%@",firstText,[NSString stringWithFormat:@"%@2\n*/",lastText]];
    }
    
//    if (invocation.buffer.lines.count>1) {
//        XCSourceTextRange *firstSelection = invocation.buffer.selections.firstObject;
//        NSInteger firstIndex = firstSelection.start.line;
//        NSString *firstText = invocation.buffer.lines[firstIndex];
//        invocation.buffer.lines[firstIndex] = [NSString stringWithFormat:@"/*1\n%@",firstText];
//
//        XCSourceTextRange *lastSelection = invocation.buffer.selections.lastObject;
//        NSInteger lastIndex = lastSelection.end.line;
//        NSString *lastText = invocation.buffer.lines[lastIndex];
//        invocation.buffer.lines[lastIndex] = [NSString stringWithFormat:@"%@2\n*/",lastText];
//    }else{
//        XCSourceTextRange *lastSelection = invocation.buffer.selections.firstObject;
//        NSInteger lastIndex = lastSelection.start.line;
//        NSString *lastText = invocation.buffer.lines[lastIndex];
//        invocation.buffer.lines[lastIndex] = [NSString stringWithFormat:@"/*3\n%@\n*/",lastText];
//    }
    completionHandler(nil);
}



@end
