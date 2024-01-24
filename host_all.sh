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
        echo -e "\e[95mAparentemente não está configurado.\nSUSCETÍVEL A MAIL SPOOFING! \e[0m"
    fi
    echo -e ""
}

automatize_host(){
    print "IPv4"
    ip=$(host -t A $site | egrep -v "not found" | cut -d " " -f4 | sed 's/.$//')
    [ -z "$ip" ] && echo -e "\e[90mNão encontrado\n\e[0m" || echo -e "$ip\n"
    
    print "IPv6"
    ip6=$(host -t AAAA $site | egrep -v "has no|not found" | cut -d " " -f5 | sed 's/.$//')
    [ -z "$ip6" ] && echo -e "\e[90mNão encontrado\n\e[0m" || echo -e "$ip\n"
        
    print "Servidor (es) de e-mail"
    mx=$(host -t mx $site | cut -d " " -f7 | sed 's/.$//')
    [ -z "$mx" ] && echo -e "\e[90mNão encontrado\n\e[0m" || echo -e "$mx\n"

    print "Informações do host"
    hinfo=$(host -t hinfo $site | egrep -v "has no|not found")
    [ -z "$hinfo" ] && echo -e "\e[90mNão encontrado\n\e[0m" || echo -e "$hinfo\n"
    
    print "Configuração de SPF"
    spf=$(host -t txt $site | egrep -v "not found")
    [ -z "$spf" ] && echo -e "\e[90mNão encontrado\n\e[0m" || (echo -e "$spf\n"; verificar_spf $spf)

    print "Servidores"
    servers=$(host -t ns $site | egrep -v "not found" | cut -d " " -f4 | sed 's/.$//' ) # Nomes de Servidores. ns1 -> registro de entradas de DNS (CNAME, registros de IP, subdomínios…) | ns2 -> backup
    [ -z "$servers" ] && echo -e "\e[90mNão encontrado\n\e[0m" || echo -e "$servers\n"
    
    print "AXFR"
    [ -z "$servers" ] && echo -e "\e[90mNão encontrado\n\e[0m"
    for server in $servers; do
    	echo -e "\e[95mTentando transferência de zona em:\e[0m \e[93m$server \e[0m"
        axfr=$(host -l $site $server | egrep -v "failed|reset|not found")
        [ -z "$axfr" ] && echo -e "\e[90mFalhou\n\e[0m" || echo -e "$axfr\n"
    done

        
    # aqui precisa colocar subdomínios, senão NUNCA vai funcionar. Os ALIAS são específicos para subdomínios, isso INCLUI o www        
    print "CNAME/ALIAS"
    cname=$(host -t cname $site | egrep -v "has no|not found")
    [ -z "$cname" ] && echo -e "\e[90mNão encontrado. Execute individualmente com o subdomínio: host -t cname {site}\n\e[0m" || echo -e "$cname\n"
}

if [ "$1" ]; then
    site="$1"
    automatize_host $site
fi
