#!/bin/bash

# Show usage message if no arguments passed
if [ $# -eq 0 ]; then
    echo -e "Use:./host_all site.com.br"
    exit 1
fi

automatize_host(){
    host -t A $site
    host -t mx $site
    host -t ns $site
    host -t hinfo $site
    host -t AAAA $site
    host -t txt $site
    host -t l $site
}

if [ "$1" ]; then
    site="$1"
    automatize_host
fi
