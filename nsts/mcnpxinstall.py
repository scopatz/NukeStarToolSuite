#!/usr/bin/env python
import subprocess
import os
import funcs
import re


if __name__ == '__main__':

    MCNPXDATADIR='/usr/share/mcnpxlib'
    MCNPX26DIR='/usr/share/mcnpxv260'
    MCNPX27DIR='/usr/share/mcnpxv27c'
    install_pkgs='binutils gcc gcc-4.4 gfortran gfortran-4.4 libc-dev-bin libc6-dev libgfortran3 libgomp1 libpthread-stubs0 libpthread-stubs0-dev libx11-dev libxau-dev libxcb1-dev libxdmcp-dev linux-libc-dev x11proto-core-dev x11proto-input-dev x11proto-kb-dev xtrans-dev'

    rm_dirs = [MCNPXDATADIR, MCNPX26DIR, MCNPX27DIR]
    mk_dirs = [MCNPXDATADIR, MCNPX26DIR, MCNPX26DIR+'/bin', MCNPX26DIR+'/lib', MCNPX27DIR, MCNPX27DIR+'/bin', MCNPX27DIR+'/lib']
    groups = [mcnpxdata, mcnpx27, mcnpx26]

    # Install compilers, x11 dev header files, etc...
    print "Installing necessary libraries and compilers"
    funcs.apt_get(install_pkgs)

    # Remove any existing mcnpx installations
    print "Removing existing MCNPX files and directories"
    subprocess.call('rm install.log &> /dev/null', shell=True)
    for i in rm_dirs:
        funcs.remove(i)

    # Create installation directories
    print "Creating MCNPX installation directories"
    for i in mk_dirs:
        funcs.mkdir(i)

    # Unpack all files and link data libraries
    print "Unpacking installation files"
    funcs.untar('mcnpxdata.tar.gz', MCNPXDATADIR)
    funcs.untar('v260.tar.gz')
    funcs.untar('v27c.tar.gz')
    # link data libraries
    funcs.link(MCNPXDATADIR+'/*',MCNPX26DIR+'/lib/.')
    funcs.link(MCNPXDATADIR+'/*',MCNPX27DIR+'/lib/.')
    # create symbolic link for f90 compiler
    funcs.link('/usr/bin/f95','/usr/bin/f90')

    # Begin MCNPX install
    # install v260
    print "Starting install of MCNPX v260"
    os.chdir(v260)
    print "Configuring..."
    subprocess.call('./configure --prefix=' + MCNPX26DIR + ' --with-CC=mpicc --with-FC=mpif90 --with-FOPT="-O3" --with-COPT="-O3" --with-MPILIB --x-include=/usr/lib --x-libraries=/usr/lib --with-FFLAGS="-DUNIX=1 -DLINUX=1" --with-CFLAGS="-DUNIX=1 -DLINUX=1" --with-LDFLAGS="-lirc"', shell=True)
    print "Compiling..."
    funcs.make()
    print "Installing..."
    funcs.make_install()
    print "Finished installing MCNPX v260!"
    # install v27c
    print "Starting install of MCNPX v27c"
    os.chdir('/root/v27c')
    print "Configuring..."
    subprocess.call('./configure --prefix=' + MCNPX27DIR + '--with-CC=mpicc --with-FC=mpif90 --with-FOPT="-O3" --with-COPT="-O3" --with-MPILIB --x-include=/usr/lib --x-libraries=/usr/lib --with-FFLAGS="-DUNIX=1 -DLINUX=1" --with-CFLAGS="-DUNIX=1 -DLINUX=1"  --with-LDFLAGS="-lirc"', shell=True)
    print "Compiling..."
    funcs.make()
    print "Installing..."
    funcs.make_install()
    print "Finished installing MCNPX v27c!"

    # Rename mcnpx v260 and v27c
    funcs.rename(MCNPX26DIR+'/bin/mcnpx', MCNPX26DIR+'/bin/mcnpx260')
    funcs.rename(MCNPX27DIR+'/bin/mcnpx', MCNPX27DIR+'/bin/mcnpx27c')

    # Update environmental variables  
    if (!re.search(MCNPX26DIR, os.environ['PATH'])):
        subprocess.call('echo "export PATH=\$PATH:"' + MCNPX26DIR + '"/bin" >>  /root/.bashrc',shell=True)

    if (!re.search(MCNPX27DIR, os.environ['PATH'])):
        subprocess.call('echo "export PATH=\$PATH:"' + MCNPX27DIR + '"/bin" >>  /root/.bashrc',shell=True)

    if (!re.search(MCNPXDATADIR, os.environ['DATAPATH'])):
        subprocess.call('echo "export DATAPATH="' + MCNPX26DIR + '">>  /root/.bashrc',shell=True)

    # Change permissions
    print "Changing permissions"
    # mcnpx27
    subprocess.call('find ' + MCNPX27DIR + ' -type d | xargs -i chmod 750 {}', shell=True)
    subprocess.call('find ' + MCNPX27DIR + ' -type f | xargs -i chmod 640 {}', shell=True)
    subprocess.call('find ' + MCNPX27DIR + '/bin | xargs -i chmod 750 {}', shell=True)
    subprocess.call('find ' + MCNPX27DIR + ' | xargs -i chgrp mcnpx27 {}', shell=True)

    # mcnpx26
    subprocess.call('find ' + MCNPX26DIR + ' -type d | xargs -i chmod 750 {}', shell=True)
    subprocess.call('find ' + MCNPX26DIR + ' -type f | xargs -i chmod 640 {}', shell=True)
    subprocess.call('find ' + MCNPX26DIR + '/bin | xargs -i chmod 750 {}', shell=True)
    subprocess.call('find ' + MCNPX26DIR + ' | xargs -i chgrp mcnpx26 {}', shell=True)

    # data directories MUST come last (I dont know why though!)
    subprocess.call('find ' + MCNPXDATADIR + ' | xargs -i chgrp mcnpxdata {}', shell=True)
    subprocess.call('find ' + MCNPXDATADIR + ' -type f | xargs -i chmod 640 {}', shell=True)
    subprocess.call('find ' + MCNPXDATADIR + ' -type d | xargs -i chmod 750 {}', shell=True)

    # Add groups
    print "Adding MCNPX groups..."
    for i in groups:
        funcs.addgroup(i)
