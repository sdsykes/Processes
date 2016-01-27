//
//  Auth.h
//  Processes
//
//  Created by Stephen Sykes on 26/01/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface Auth : NSObject 

+ (BOOL)authAndKill:(pid_t)pid;

@end
