//
// Created by Aleksey Garbarev on 22.05.14.
// Copyright (c) 2014 Jasper Blues. All rights reserved.
//

#import "TyphoonJsonStyleConfiguration.h"
#import "TyphoonResource.h"


@implementation TyphoonJsonStyleConfiguration
{
    NSMutableDictionary *_properties;
}

- (id)init
{
    self = [super init];
    if (self) {
        _properties = [NSMutableDictionary new];
    }
    return self;
}

- (NSString *)stringWithoutCommentsFromString:(NSString *)string
{
    static NSRegularExpression *expression;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        expression = [NSRegularExpression regularExpressionWithPattern:@"((^)([\\s]*)(\\/\\/.*$))" options:NSRegularExpressionAnchorsMatchLines error:nil];
    });

    return [expression stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@""];
}

- (void)appendResource:(id<TyphoonResource>)resource
{
    NSString *jsonWithoutComments = [self stringWithoutCommentsFromString:[resource asString]];
    NSData *jsonData = [jsonWithoutComments dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];

    if (!error) {
        [_properties addEntriesFromDictionary:dictionary];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Can't prase JSON configuration file: %@",error];
    }
}

- (id)objectForKey:(NSString *)key
{
    return [_properties valueForKeyPath:key];
}

@end