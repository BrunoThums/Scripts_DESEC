#!/bin/bash
if [ $# -eq 0 ]; then
    echo -e "Use: $0 site.com.br"
else
    servers = $(host -t ns $1 | cut -d " " -f4 | sed 's/.$//')
    for server in $servers;
    do 
        host -l -a $1 $server
    done
fi
