#!/bin/bash

# Setup iptables based on host kernel capabilities (nft vs legacy)
if command -v iptables-nft >/dev/null 2>&1 && iptables-nft -t nat -L -n >/dev/null 2>&1; then
    update-alternatives --set iptables /usr/sbin/xtables-nft-multi >/dev/null 2>&1 || \
        (ln -sf /usr/sbin/xtables-nft-multi /etc/alternatives/iptables && \
         ln -sf /usr/sbin/xtables-nft-multi /etc/alternatives/iptables-restore && \
         ln -sf /usr/sbin/xtables-nft-multi /etc/alternatives/iptables-save)
    update-alternatives --set ip6tables /usr/sbin/xtables-nft-multi >/dev/null 2>&1 || true
elif command -v iptables-legacy >/dev/null 2>&1 && iptables-legacy -t nat -L -n >/dev/null 2>&1; then
    update-alternatives --set iptables /usr/sbin/xtables-legacy-multi >/dev/null 2>&1 || \
        (ln -sf /usr/sbin/xtables-legacy-multi /etc/alternatives/iptables && \
         ln -sf /usr/sbin/xtables-legacy-multi /etc/alternatives/iptables-restore && \
         ln -sf /usr/sbin/xtables-legacy-multi /etc/alternatives/iptables-save)
    update-alternatives --set ip6tables /usr/sbin/xtables-legacy-multi >/dev/null 2>&1 || true
fi

if [ -x /usr/bin/python3.12 ]; then
    ln -sf /usr/bin/python3.12 /usr/bin/python3
fi

# Setup cgroup v2 controller delegation if available
if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
    mkdir -p /sys/fs/cgroup/init.scope
    echo $$ > /sys/fs/cgroup/init.scope/cgroup.procs 2>/dev/null || true
    for c in $(cat /sys/fs/cgroup/cgroup.controllers); do
        echo "+$c" > /sys/fs/cgroup/cgroup.subtree_control 2>/dev/null || true
    done
fi

mkdir -p /etc/systemd/system/machine.slice.d
cat << 'EOF' > /etc/systemd/system/machine.slice.d/10-delegate.conf
[Slice]
Delegate=yes
EOF

printenv > /env
exec /sbin/init

