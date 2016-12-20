#!/bin/bash

# A quick BASH script that installs noVNC and sets up an Xfce4 session,
# accessible through a browser on port 5901 TCP. Tested against Kali Linux Xfce4 "full" installations.
# If running this on Azure or other virtual hosting, don't foret to allow ingress TCP 5901 .


# Configure the following parameters if needed:
###############################################
resolution="1280x720x16"
display_number=1
web_vnc_port=5901
###############################################

clear
echo -e "\n[*] Setting up \e[31mKali in a Browser\e[0m, generating ~/start.sh\n"
sleep 2
cat << EOF > ~/start.sh
#!/bin/bash
clear
echo -e "\e[31m\n[*] Starting up noVNC.\e[0m"
export DISPLAY=:$display_number
Xvfb :$display_number -screen 0 $resolution &
sleep 5
# Start up Xfce is available, otherwise assume Gnome
if [ -f /etc/xdg/xfce4/xinitrc ]; then
        startxfce4 2>/dev/null &
fi
x11vnc -display :$display_number -shared -nopw -listen localhost -xkb -bg -ncache_cr -forever
websockify --web /usr/share/novnc $web_vnc_port 127.0.0.1:5900 --cert=self.pem -D
ip="\$(host -t a myip.opendns.com resolver1.opendns.com|tail -1 |cut -d" " -f4)"
echo -e "\e[31m\n[*] Kali in a Browser is set up, you can access https://\$ip:$web_vnc_port\e[0m"
echo -e "[*] Don't forget to open up incoming port TCP $web_vnc_port if you have a firewalled host.".
EOF


chmod 755 ~/start.sh
clear
echo -e "\n[+] Installing pre-requisites, enter sudo password if asked.\n"
sleep 2
sudo apt-get update
sudo apt-get -y dist-upgrade
sudo apt-get -y install novnc websockify x11vnc xvfb
sudo apt-get clean
sudo ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html
clear

echo -e "\n[+] Generating SSL cert. Please fill in details, then run \e[31m./start.sh\e[0m\n"
sleep 2
openssl req -new -x509 -days 365 -nodes -out self.pem -keyout self.pem
