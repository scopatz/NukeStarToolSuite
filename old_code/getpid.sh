#!/bin/bash

ssh $1 ps -u $(whoami) | grep $2 | cut -c1-5 

