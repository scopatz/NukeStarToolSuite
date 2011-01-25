#!/usr/bin/env python
import subprocess
import os
import funcs
import re


if __name__ == "__main__":

    user = 'root'
    host = 'nukestar.me.utexas.edu'
    req_files = [mcnpxinstall.sh, v27c.tar.gz, v260.tar.gz, mcnpxdata.tar.gz]

    #put all nessicary files to install mcnpx onto node
    print "Moving files to node..."
    for i in req_files:
        funcs.put(user, host, i, "/install_tmp/")
    print "Moving files complete!"

    #run install script on node
    print "Starting MCNPX installation..."
    funcs.remote_run(user, host, "/install_tmp/mcnpxinstall.sh)
    print "MCNPX installion complete!"

    #remove all installion files from node
    print "Removing all installation files..."
    funcs.clean(user, host)
    print "Removal complete!"
