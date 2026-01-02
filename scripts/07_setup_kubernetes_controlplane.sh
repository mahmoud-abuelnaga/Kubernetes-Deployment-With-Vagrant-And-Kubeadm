#!/usr/bin/env bash

set -e          # Exit immediately if a command exits with a non-zero status
set -o pipefail # Prevent errors in a pipeline from being masked
set -u          # Treat unset variables as an error

# variables
pod_network_cidr=$1
# Get the IP from the private network interface (not the Vagrant NAT interface)
interface_ip=$(ip -4 addr show | grep -oP '192\.168\.122\.\d+' | head -n 1)

# packages
sudo dnf install -y 'dnf-command(versionlock)'
sudo dnf install -y kubeadm kubelet kubectl
sudo dnf versionlock add kubeadm kubelet kubectl

# Configure kubelet to use the correct node IP
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--node-ip=${interface_ip}
EOF

# services
sudo systemctl enable --now kubelet

# kubeadm init
sudo kubeadm init \
  --pod-network-cidr="$pod_network_cidr" \
  --apiserver-advertise-address="$interface_ip" \
  --upload-certs | tee /tmp/kubeadm_init_output.txt

# join command
grep -A 1 "kubeadm join" /tmp/kubeadm_init_output.txt >/tmp/join_command.txt
echo "#!/usr/bin/env bash" >/tmp/join_command.sh
cat /tmp/join_command.txt >>/tmp/join_command.sh
chmod +x /tmp/join_command.sh

# kubectl config
echo "KUBECONFIG=/etc/kubernetes/admin.conf" >>/etc/environment
