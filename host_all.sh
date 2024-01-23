#!/bin/bash

# Show usage message if no arguments passed
if [ $# -eq 0 ]; then
    echo -e "Use:./host_all site.com.br"
    exit 1
fi

print(){
    echo -e "\e[35m" $1 "\e[0m"
}

automatize_host(){
    print "IPv4"
    host -t A $site | cut -d " " -f4 | sed 's/.$//'
    print ""
    
    print "IPv6"
    host -t AAAA $site | egrep -v "has no" | cut -d " " -f5 | sed 's/.$//'
    print ""
        
    print "Servidor (es) de e-mail"
    host -t mx $site | cut -d " " -f7 | sed 's/.$//'
    print ""
        
    print "Servidores"
    host -t ns $site | cut -d " " -f4 | sed 's/.$//' # Nomes de Servidores. ns1 -> registro de entradas de DNS (CNAME, registros de IP, subdomínios…) | ns2 -> backup
    print ""

    print "Informações do host"
    host -t hinfo $site
    print ""
    
    print "Configuração de SPF"
    host -t txt $site
    print ""    

    print "AXFR"
    host -l $site | egrep -v "failed"
    print ""
        
    # aqui precisa colocar subdomínios, senão NUNCA vai funcionar. Os ALIAS são específicos para subdomínios, isso INCLUI o www        
    print "CNAME/ALIAS (use com um subdomínio: host -t cname {site}"
    host -t cname $site | egrep -v "has no" 
}

if [ "$1" ]; then
    site="$1"
    automatize_host
fi
