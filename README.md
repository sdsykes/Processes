# Process monitor

## This is just a demo

* List of processes
* Can select and kill a process
* It's dangerous
* I warned you

### Notes

The app polls the system and updates the list every 2 seconds. I didn't find any API to get callbacks on global process creation/deletion.

If you want to change the setting to view all processes then use the prefPane. The PrefPane is [here](https://github.com/sdsykes/ProcessesPrefs).

You can kill processes you don't own, the code uses AuthorizationExecuteWithPrivileges. I know this is deprecated...

At some point I had the Swift code getting an array of kinfo_proc structs from Apple's GetBSDProcessList() example function. Interfacing Swift to C like that is painful. It sure would have been quicker to write this in Obj C.

