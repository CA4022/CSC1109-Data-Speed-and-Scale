zypper --non-interactive install gawk make
cd /root
git clone https://github.com/akinomyoga/ble.sh.git blesh
cd blesh
make install
cd ..
rm -r blesh
