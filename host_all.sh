#!/bin/bash

# Show usage message if no arguments passed
if [ $# -eq 0 ]; then
    echo -e "Use:./host_all site.com.br"
    exit 1
fi

print(){
    echo -e "\e[35m" $1 "\e[0m"
}

verificar_spf() {
    local minha_string="$*"
    local posicao_all=$(expr index "$minha_string" "all")

    if [ "$posicao_all" -gt 1 ]; then
        caractere_anterior=$(echo "$minha_string" | cut -c "$((posicao_all - 1))")
        
        case "$caractere_anterior" in
            "-")
                echo -e "\e[92m RESTRITIVO: - \e[0m"
                ;;
            "~")
                echo -e "\e[93m SEMI-RESTRITIVO: ~ \e[0m"
                ;;
            "?")
                echo -e "\e[91m SUSCETÍVEL: ? \e[0m"
                ;;
            *)
                echo -e "\e[95m LIVRE PARA EXPLORAR! Aparentemente não há configuração! \e[0m"
                ;;
        esac
    else
        echo -e "\e[95m LIVRE PARA EXPLORAR! Aparentemente não há configuração!! \e[0m"
    fi
}

verificar_spf() {
    spf="$*"
    # Usando expressão regular para encontrar "all" e capturar o caractere anterior
    if [[ "$spf" =~ (.)(A|a)(L|l)(L|l) ]]; then
        caractere_anterior="${BASH_REMATCH[1]}"  # Obtém o último caractere da captura
        # Verificar o caractere e imprimir a resposta correspondente
        if [ "$caractere_anterior" = "-" ]; then
            echo -e "\e[92m SPF RESTRITIVO: - \e[0m"
        elif [ "$caractere_anterior" = "~" ]; then
            echo -e "\e[93m SPF SEMI-RESTRITIVO: ~ \e[0m"
        elif [ "$caractere_anterior" = "?" ]; then
            echo -e "\e[91m SPF SUSCETÍVEL A MAIL SPOOFING: ? \e[0m"
        else
            echo -e "\e[95m SUSCETÍVEL A MAIL SPOOFING! Caractere inválido:" $caractere_anterior "\e[0m"
        fi
    else
        echo -e "\e[95m SUSCETÍVEL A MAIL SPOOFING! Aparentemente não está configurado! \e[0m"
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
        
    print "Servidores"
    host -t ns $site | cut -d " " -f4 | sed 's/.$//' # Nomes de Servidores. ns1 -> registro de entradas de DNS (CNAME, registros de IP, subdomínios…) | ns2 -> backup
    print ""

    print "Informações do host"
    host -t hinfo $site
    print ""
    
    print "Configuração de SPF"
    spf=$(host -t txt $site)
    echo "$spf"
    verificar_spf $spf
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
