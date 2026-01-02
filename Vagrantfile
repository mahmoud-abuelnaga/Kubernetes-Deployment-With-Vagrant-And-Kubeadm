# variables
box = 'centos/stream10'
box_version = '20251223.1'

controlplanes = [
  { name: 'controlplane01', ip: '192.168.122.10', cpu: 2, mem: 2048 }
]

workers = [
  { name: 'worker01', ip: '192.168.122.30', cpu: 2, mem: 2048 }
]

all_nodes = controlplanes + workers

pod_network_cidr = '172.16.0.0/16'

# create hosts file
File.delete('tmp/hosts') if File.exist?('tmp/hosts')
File.open('tmp/hosts', 'w') do |file|
  file.write("127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4\n")
  file.write("::1         localhost localhost.localdomain localhost6 localhost6.localdomain6\n")

  controlplanes.each do |cp|
    file.write("#{cp[:ip]} #{cp[:name]}\n")
  end

  workers.each do |w|
    file.write("#{w[:ip]} #{w[:name]}\n")
  end
end

File.delete('tmp/copy_join_command.sh') if File.exist?('tmp/copy_join_command.sh')
File.open('tmp/copy_join_command.sh', 'w') do |file|
  file.write("#!/usr/bin/env bash\n")

  file.write("set -e # Exit immediately if a command exits with a non-zero status\n")
  file.write("set -o pipefail # Prevent errors in a pipeline from being masked\n")
  file.write("set -u # Treat unset variables as an error when substituting\n\n")

  file.write("sudo dnf install -y sshpass nmap-ncat\n\n")

  file.write("mkdir -p ~/.ssh/\n")
  file.write("[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N \"\" -q\n")

  workers.each do |w|
    file.write("while ! nc -z #{w[:name]} 22; do echo \"Waiting for #{w[:name]} to be reachable...\"; sleep 15; done\n")
    file.write("ssh-keyscan -H #{w[:name]} >> ~/.ssh/known_hosts\n")
    file.write("sshpass -p 'vagrant' ssh-copy-id -o StrictHostKeyChecking=no vagrant@#{w[:name]}\n")
    file.write("scp /tmp/join_command.sh vagrant@#{w[:name]}:/tmp/join_command.sh\n")
  end

end

File.delete('tmp/execute_join_command.sh') if File.exist?('tmp/execute_join_command.sh')
File.open('tmp/execute_join_command.sh', 'w') do |file|
  file.write("#!/usr/bin/env bash\n")

  file.write("set -e # Exit immediately if a command exits with a non-zero status\n")
  file.write("set -o pipefail # Prevent errors in a pipeline from being masked\n")
  file.write("set -u # Treat unset variables as an error when substituting\n\n")

  file.write("while [ ! -f /tmp/join_command.sh ]; do echo 'Waiting for join command...'; sleep 15; done\n")
  file.write("chmod +x /tmp/join_command.sh\n")
  file.write("sudo /tmp/join_command.sh\n")
end

# create Vagrantfile
Vagrant.configure('2') do |config|
  controlplanes.each do |cp|
    config.vm.define cp[:name] do |node|
      node.vm.box = box
      node.vm.box_version = box_version

      node.vm.hostname = cp[:name]
      node.vm.network 'private_network', ip: cp[:ip], libvirt__forward_mode: 'nat'

      node.vm.provider 'libvirt' do |libvirt|
        libvirt.cpus = cp[:cpu]
        libvirt.memory = cp[:mem]
      end

      node.vm.provision 'file', source: 'tmp/hosts', destination: '/tmp/hosts'
      node.vm.provision 'shell', inline: 'cp /tmp/hosts /etc/hosts'
      node.vm.provision 'shell', path: 'scripts/00_upgrade_packages.sh'
      node.vm.provision 'shell', path: 'scripts/01_enable_firewall.sh'
      node.vm.provision 'shell', path: 'scripts/02_configure_firewall_controlplane.sh'
      node.vm.provision 'shell', path: 'scripts/03_configure_kernel.sh'
      node.vm.provision 'shell', path: 'scripts/04_configure_swap.sh'
      node.vm.provision 'shell', path: 'scripts/05_setup_repos.sh'
      node.vm.provision 'shell', path: 'scripts/06_setup_container_runtime.sh'
      node.vm.provision 'shell', path: 'scripts/07_setup_kubernetes_controlplane.sh', args: [pod_network_cidr]
      node.vm.provision 'shell', path: 'scripts/08_setup_pod_networking_controlplane.sh', args: [pod_network_cidr]
      node.vm.provision 'shell', path: 'tmp/copy_join_command.sh'
    end
  end

  workers.each do |w|
    config.vm.define w[:name] do |node|
      node.vm.box = box
      node.vm.box_version = box_version

      node.vm.hostname = w[:name]
      node.vm.network 'private_network', ip: w[:ip], libvirt__forward_mode: 'nat'

      node.vm.provider 'libvirt' do |libvirt|
        libvirt.cpus = w[:cpu]
        libvirt.memory = w[:mem]
      end

      node.vm.provision 'file', source: 'tmp/hosts', destination: '/tmp/hosts'
      node.vm.provision 'shell', inline: 'cp /tmp/hosts /etc/hosts'
      node.vm.provision 'shell', path: 'scripts/00_upgrade_packages.sh'
      node.vm.provision 'shell', path: 'scripts/01_enable_firewall.sh'
      node.vm.provision 'shell', path: 'scripts/02_configure_firewall_worker.sh'
      node.vm.provision 'shell', path: 'scripts/03_configure_kernel.sh'
      node.vm.provision 'shell', path: 'scripts/04_configure_swap.sh'
      node.vm.provision 'shell', path: 'scripts/05_setup_repos.sh'
      node.vm.provision 'shell', path: 'scripts/06_setup_container_runtime.sh'
      node.vm.provision 'shell', path: 'scripts/07_setup_kubernetes_worker.sh', args: [pod_network_cidr]
      node.vm.provision 'shell', path: 'scripts/08_setup_pod_networking_worker.sh'
      node.vm.provision 'shell', path: 'tmp/execute_join_command.sh'
    end
  end

  
end
