//
//  bsdProcesses.c
//  Processes
//
//  Created by Stephen Sykes on 22/01/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

// https://developer.apple.com/legacy/library/qa/qa2001/qa1123.html

#include "bsdProcesses.h"

#include <assert.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/sysctl.h>
#include <signal.h>
#include <unistd.h>

#import <string.h>
#import <libproc.h>
#include <pwd.h>

// http://stackoverflow.com/questions/3018054/retrieve-names-of-running-processes

/**
 Returns an array of processes.
 The final element is 0.
 Please free the pointer after use.
 Returns NULL if malloc fails.
*/
pid_t *fetchProcesses(bool includeAll) {
    int numberOfProcesses = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);

    pid_t pidList[numberOfProcesses];
    bzero(pidList, sizeof(pidList));
    proc_listpids(PROC_ALL_PIDS, 0, pidList, (int)sizeof(pidList));

    pid_t *pids = malloc((numberOfProcesses + 1) * sizeof(pid_t));
    int pid_index = 0;
    uid_t myUid = getuid();
    for (int i = 0; i < numberOfProcesses; ++i) {
        if (pidList[i] == 0) continue;  // pid 0 should be the kernel_task, we don't want it
        if (!includeAll) {
            if (myUid != uidForProcess(pidList[i])) continue;
        }
        pids[pid_index] = pidList[i];
        pid_index++;
    }
    pids[pid_index] = 0;
    return pids;
}

/**
 Returns the path of the process.
 Please free the buffer after use.
 Returns NULL if malloc fails, which it has no right to do.
 */
char *nameForProcess(pid_t pid) {
    char pathBuffer[PROC_PIDPATHINFO_MAXSIZE];

    bzero(pathBuffer, PROC_PIDPATHINFO_MAXSIZE);
    proc_pidpath(pid, pathBuffer, PROC_PIDPATHINFO_MAXSIZE);
    if (strlen(pathBuffer) == 0) {
        // in cases where the path is empty, so it this
        proc_name(pid, pathBuffer, PROC_PIDPATHINFO_MAXSIZE);
    }

    char *nameBuffer = malloc(256 * sizeof(char));
    if (nameBuffer == NULL) return NULL;

    int len = (int)strlen(pathBuffer);
    // len seems to be zero only for zombies, but should check the status of the process
    if (len == 0) {
        strcpy(nameBuffer, "ZOMBIE");
        return nameBuffer;
    }

    int position = len;
    while(position >= 0 && pathBuffer[position] != '/') {
        position--;
    }
    strcpy(nameBuffer, pathBuffer + position + 1);

    return nameBuffer;
}

/**
 Uid for process.
 */
uid_t uidForProcess(pid_t pid) {
    struct proc_bsdinfo info;
    bzero(&info, sizeof(info));
    proc_pidinfo(pid, PROC_PIDTBSDINFO, 0,  &info, sizeof(info));
    return info.pbi_uid;
}

/**
 Owner name for process. Might be better to cache a dict of these.
 */
char *ownerForProcess(pid_t pid) {
    uid_t uid = uidForProcess(pid);
    struct passwd *pw = getpwuid(uid);
    return pw->pw_name;
}


/** just a wrapper */
int killProc(pid_t pid, int sig) {
    return kill(pid, sig);
}

