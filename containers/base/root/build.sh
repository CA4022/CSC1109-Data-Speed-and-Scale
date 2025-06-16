# Set up fzf
wget https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf-0.62.0-linux_amd64.tar.gz
tar xzf fzf-0.62.0-linux_amd64.tar.gz
rm fzf-0.62.0-linux_amd64.tar.gz
mv fzf /usr/bin/fzf
# Install alternative shells and prompt generator
zypper --non-interactive install zsh fish starship
# Set up bash shell
# Set up blesh
zypper --non-interactive install gawk make
cd /root
git clone https://github.com/akinomyoga/ble.sh.git blesh
cd blesh
make install
cd ..
rm -r blesh
# Set up zsh shell
# add oh-my-zsh and required plugins
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
