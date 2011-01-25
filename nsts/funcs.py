#!/usr/bin/env python
import subprocess
import os
import re

#function definitions

def apt_get(pkgs):
    subprocess.call('apt-get install ' + pkgs, shell=True)

def mkdir(Dir, Name=''):
    subprocess.call('mkdir ' + Dir + Name, shell=True)

def remove(Dir, File=''):
    subprocess.call('rm -r ' + Dir + File, shell=True)

def put(user, host, loc_path, rem_path):
    subprocess.call('scp -r ' + loc_path + ' ' + user + '@' + host + ':' + rem_path, shell=True)

def get(user, host, rem_path, loc_path):
    subprocess.call('scp -r ' + user + '@' + host + ':' + rem_path + ' ' + loc_path, shell=True)

def remote_run(user, host, execute):
    subprocess.call('ssh ' + user + '@' + host + ' exec ' + execute, shell=True)

def clean(user, host):
   subprocess.call('ssh ' + user + '@' + host + 'exec rm -r /install_tmp/*', shell=True) 

def untar(tar_file, untar_dir=''):
    if untar_dir!='':
        subprocess.call('tar -xzf ' + tar_file, shell=True)
    else:
        subprocess.call('tar -xzf ' + tar_file + '--directory=' + untar_dir, shell=True)

def link(link_to, link):
    subprocess.call('ln -s ' + link_to + ' ' + link, shell=True)

def rename(orig, new):
    subprocess.call('mv ' + orig + ' ' + new)

def make():
    subprocess.call('make', shell=True)

def make_install():
    subprocess.call('make install', shell=True)

def addgroup(group):
    subprocess.call('addgroup ' + group)
