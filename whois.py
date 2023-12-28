#!/usr/share/python
import socket, sys
# Registra o argumento em uma variavel
site = sys.argv[1]+"\r\n"
# Criacao de um socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# Estabele a conexao com o whois na porta 43
s.connect(("whois.iana.org", 43))
# Envia a consulta lendo o argumento passado na execucao do codigo
# (o padrao de envio eh o dominio + \r\n)
s.send(site)
# Captura a resposta do servidor (1024 eh a quantidade de bytes a receber)
# e separa todas palavras por espaco
resposta = s.recv(1024).split()
# Filtra para resgatar apenas o whois de dominio continental
whois = resposta[19]
# Fecha a conexao
s.close()

socket1 = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
socket1.connect((whois,43))
socket1.send(site)
resposta1 = socket1.recv(1024)
print(resposta1)
