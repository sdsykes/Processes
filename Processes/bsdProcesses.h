//
//  bsdProcesses.h
//  Processes
//
//  Created by Stephen Sykes on 22/01/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#ifndef bsdProcesses_h
#define bsdProcesses_h

#include <stdio.h>
#include <stdbool.h>

pid_t *fetchProcesses(bool includeAll);
char *nameForProcess(pid_t pid);
int killProc(pid_t pid, int sig);
uid_t uidForProcess(pid_t pid);
char *ownerForProcess(pid_t pid);

#endif /* bsdProcesses_h */
