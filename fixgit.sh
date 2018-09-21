#!/bin/bash

#
# Cleanup the view and make it usable again 
# - assume everything is checked in and pushed.
# Your Unpushed COMMITS MAY be lost with this script
# hackacharya@gmail.com
#
# If you get following type of errors in your git view and also 
# WANT to restart using your view, (but not necessarily
# recover) - (see the forceclean option)
#
# error: object file .git/objects/../..... is empty
# fatal: loose object ............ (stored in .git/object....
# >> error: HEAD: invalid sha1 pointer ....
# >> error: refs/heads/master does not point to a valid object!
# >> dangling tree  ... 
# >> dangling tree ...
#
#

# Try a FULL FSCK 
/usr/bin/git fsck --full --lost-found

# Find and remove empty objects
find .git/ -type f -size 0 -exec /bin/rm -f $i {} \;

# Look at the reflog and find the commit where
# git show might work.
# and if it does then use that as the HEAD
# now git other commands should work
# 
for com in `tail -n5 .git/logs/refs/heads/master | cut -d" " -f1`
do
   /usr/bin/git show $com > /dev/null
   if [ $? -eq 0 ]; then
        /usr/bin/git stash
        /usr/bin/git update-ref HEAD $com


        if [ "$1" == "forceclean" ]; then
             /usr/bin/git reset --hard HEAD~5
             # Warning: this will clean up all dangling objects but will
             # return your view to a clean state
             /usr/bin/git gc --prune=all
             /usr/bin/git pull
        fi
   fi
done
