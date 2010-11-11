#!/usr/bin/env python

import sys
import getpass
import subprocess as sb

def main():
    info = {
        'node': '',
        'user': getpass.getuser(), 
        'comd': " ".join(sys.argv[1:]), 
    }

    with open('/usr/share/nodelist.txt', 'r') as nodelist:
        nodes = [line.split()[0] for line in nodelist]

    for node in nodes:
        info['node'] = node
        if not node == nodes[0]:
            print ""
        print "\033[0;32mRunning on Node {node}:\033[0m".format(**info)
        sb.call("ssh {user}@{node} {comd}".format(**info), shell=True)

    return

if __name__ == '__main__':
    main()
