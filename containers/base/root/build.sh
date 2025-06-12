# Set up fzf
wget https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf-0.62.0-linux_amd64.tar.gz
tar xzf fzf-0.62.0-linux_amd64.tar.gz
rm fzf-0.62.0-linux_amd64.tar.gz
mv fzf /usr/bin/fzf
# Set up blesh
zypper --non-interactive install gawk make
cd /root
git clone https://github.com/akinomyoga/ble.sh.git blesh
cd blesh
make install
cd ..
rm -r blesh
