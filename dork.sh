#!/bin/bash
# resgata os primeiros 100 resultados, fazendo os filtros para colher apenas o que é relevante; excluindo os 3 últimos caracteres
lynx -dump "http://google.com/search?num=100&?q=site:"$1"+ext:"$2"" | grep ".$2" | cut -d "=" -f2 | egrep -v "site|google" | sed s'/...$//'g
