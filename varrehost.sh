#varrehost.sh
#./nomeDoPrograma site.com.br
#!/bin/bash
for palavra in $(cat $1);do 
host $palavra | egrep -v "NXDOMAIN" | cut -d " " -f 1,4
done
