#!/bin/bash

# Show usage message if no arguments passed
if [ $# -eq 0 ]; then
    echo -e "Use: $0 site.com.br"
    exit 1
fi

print(){
    echo -e "\e[35m"$1"\e[0m"
}

verificar_spf() {
    spf="$*"
    # Usando expressão regular para encontrar "all" e capturar o caractere anterior
    if [[ "$spf" =~ (.)(A|a)(L|l)(L|l) ]]; then
        caractere_anterior="${BASH_REMATCH[1]}"  # Obtém o último caractere da captura
        # Verificar o caractere e imprimir a resposta correspondente
        if [ "$caractere_anterior" = "-" ]; then
            echo -e "\e[92mSPF RESTRITIVO (FAIL): - Normalmente recusa o email \e[0m"
        elif [ "$caractere_anterior" = "~" ]; then
            echo -e "\e[93mSPF SEMI-RESTRITIVO (SOFTFAIL): ~ \nSUSCETÍVEL A MAIL SPOOFING \e[0m"
        elif [ "$caractere_anterior" = "?" ]; then
            echo -e "\e[91mSPF SEM POLÍTICA (NEUTRAL): ? Liberado \nSUSCETÍVEL A MAIL SPOOFING \e[0m"
        elif [ "$caractere_anterior" = "+" ]; then
            echo -e "\e[91mSPF LIBERADO (PASS): + Liberado \nSUSCETÍVEL A MAIL SPOOFING \e[0m"
        else
            echo -e "\e[95mCaractere inválido:" $caractere_anterior "\nSUSCETÍVEL A MAIL SPOOFING! \e[0m"
        fi
    else
        echo -e "\e[95mAparentemente não está configurado!\nSUSCETÍVEL A MAIL SPOOFING! \e[0m"
    fi
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

    print "Informações do host"
    host -t hinfo $site | egrep -v "has no"
    print ""
    
    print "Configuração de SPF"
    spf=$(host -t txt $site)
    echo "$spf"
    verificar_spf $spf
    print ""    

    print "Servidores"
    servers=$(host -t ns $site | cut -d " " -f4 | sed 's/.$//') # Nomes de Servidores. ns1 -> registro de entradas de DNS (CNAME, registros de IP, subdomínios…) | ns2 -> backup
    echo "$servers"
    print ""
    
    print "AXFR"
    for server in $servers; do
    	echo -e "\e[95mTentando transferência de zona em:\e[0m \e[93m$server \e[0m"
        host -l $site $server | egrep -v "failed|reset"
    done
    print ""
        
    # aqui precisa colocar subdomínios, senão NUNCA vai funcionar. Os ALIAS são específicos para subdomínios, isso INCLUI o www        
    print "CNAME/ALIAS (use com um subdomínio: host -t cname {site}"
    host -t cname $site | egrep -v "has no" 
}

if [ "$1" ]; then
    site="$1"
    automatize_host $site
fi
