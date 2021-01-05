# TMUX Config for Netkit

## Leader Key

The leader key is <ctrl>-<a>. This means if you wanted to create a new window to the right, which requires the key 'c', you would hit <ctrl> and <a> (at the same time) then <c>.

## Help

To open this help message in a tmux session, press [leader] followed by <h>. If you're reading this in a tmux session well done you did it :)

To close this, just press <q>

## The Netkit VM Pane

The Netkit VM will run under window 'netkit-vm' pane '0'. If you are not on this pane all commands will go to the host not the Netkit machine!! 

To help you, the status bar should change colour depending on what pane you are in. By default this is purple if you are in a netkit vm and blue if you are in a host shell.

## Creating New Panes

To create a new pane do [leader] followed by <%> - this will create a vertical split.

If you want a horizontal split instead, you can use [leader] followed by <">

To move between panes you hit [leader] followed by [arrow-key] - with the arrow key depending on the direction you want to move from the current active pane. You also may be able to click on a with your mouse to move to it (depending on your terminal). 

If you have made a split / splits, you may want to zoom into a specific pane. By hitting [leader] followed by <z> you will zoom into the active pane (the active pane will fill the whole window). To zoom out, just do this again.

## Creating new windows

To create a new window, do [leader] followed by <c>. This will create a window to the right of the current window. 

To move between windows you can use [leader] <n> to go to the next window, or [leader] <p> to go to the previous.

## Detaching from a Tmux Session

You may have attached to the machine's tmux session with `vconnect -m MACHINE` and now you want to disconnect. 
To do this press [leader] followed by <d> - this will disconnect you from the session without closing it,
so you can reconnect at any point while the machine is running.

## Capturing Output

Note the following will save the active pane, so if you want to capture the machine log, make sure you are on the netkit pane!

To save output to /tmp hit [leader] then <s> (lower case 's').

To save with a custom filename, use [leader] <S> (capital 'S').

## Netkit Machine Shutdown / Failure

When a machine shuts down it can be due to errors that we need to look at. In order to preserve the machine output, the tmux session will get renamed to MACHINENAME-dead, and the netkit pane will remain open.
