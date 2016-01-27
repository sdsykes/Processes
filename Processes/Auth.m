//
//  Auth.m
//  Processes
//
//  Created by Stephen Sykes on 26/01/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "Auth.h"
#import <Foundation/Foundation.h>

@implementation Auth

// This is the deprecated way. But it works fine for demo. Use SMJobBless.
// By the way, TotalSpaces uses this method via Sparkle code.

+ (BOOL)authAndKill:(pid_t)pid
{
    OSStatus status;
    AuthorizationRef auth = NULL;
    OSStatus authStat = errAuthorizationDenied;
    while (authStat == errAuthorizationDenied) {
        authStat = AuthorizationCreate(NULL,
                                   kAuthorizationEmptyEnvironment,
                                   kAuthorizationFlagDefaults,
                                   &auth);
    }

    if (authStat != errAuthorizationSuccess) {
        NSLog(@"Couldn't create auth");
        return NO;
    }


    AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &right};
    AuthorizationFlags flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed |
    kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;

    // Call AuthorizationCopyRights to determine or extend the allowable rights.
    status = AuthorizationCopyRights(auth, &rights, NULL, flags, NULL);
    if (status != errAuthorizationSuccess) {
        NSLog(@"Copy Rights Unsuccessful: %d", status);
        return NO;
    }

    char pidStr[12];
    sprintf(pidStr, "%d", pid);
    char *tool = "/bin/kill";
    char *args[] = {"-9", pidStr, NULL};
    FILE *pipe = NULL;

    // We don't want any warnings :)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    status = AuthorizationExecuteWithPrivileges(auth, tool, kAuthorizationFlagDefaults, args, &pipe);
#pragma clang diagnostic pop

    if (status != errAuthorizationSuccess) {
        NSLog(@"Error: %d", status);
        return NO;
    }

    // The API is a bit shit, you don't get the pid so you have to call blocking waits to avoid zombies.
    // You could also ignore SIGCHLD, but as the kill process hasn't finished by the time
    // we get here (where we'd like to un-ignore it), you'd have to manage it elsewhere.
    int stat;
    wait(&stat);
    wait(&stat);

    status = AuthorizationFree(auth, kAuthorizationFlagDestroyRights);
    return YES;
}


@end
