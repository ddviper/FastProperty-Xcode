//
//  DCRemoveDuplicateImportHeaders.h
//  FastProperty
//
//  Created by collegepre on 2018/2/9.
//  Copyright © 2018年 CP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCRemoveDuplicateImportHeaders : NSObject
// import的类名
@property (copy,nonatomic) NSString *importClass;
// 所属文本中第几行
@property (nonatomic, assign) NSInteger  atLine;
@end
