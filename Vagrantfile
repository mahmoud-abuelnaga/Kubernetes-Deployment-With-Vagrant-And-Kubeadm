# variables
box = "centos/stream10"
box_version = "20251223.1"

controlplanes = [
  {name: "controlplane01", ip: "12.168.121.10", cpu: 2, mem: 2048}
]

workers = [
  {name: "worker01", ip: "12.168.121.30", cpu: 2, mem: 2048}
]

pod_network_cidr = "172.16.0.0/16"

# create hosts file
File.delete("tmp/hosts") if File.exist?("tmp/hosts")
File.open("tmp/hosts", "w") do |file|
  file.write("127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4\n")
  file.write("::1         localhost localhost.localdomain localhost6 localhost6.localdomain6\n")

  controlplanes.each do |cp|
    file.write("#{cp[:ip]} #{cp[:name]}\n")
  end

  workers.each do |w|
    file.write("#{w[:ip]} #{w[:name]}\n")
  end
end

# create Vagrantfile
Vagrant.configure("2") do |config|
  controlplanes.each do |cp|

    config.vm.define cp[:name] do |node|
      node.vm.box = box
      node.vm.box_version = box_version

      node.vm.hostname = cp[:name]
      node.vm.network "private_network", ip: cp[:ip], libvirt__forward_mode: "nat"

      node.vm.provider "libvirt" do |libvirt|
        libvirt.cpus = cp[:cpu]
        libvirt.memory = cp[:mem]
        libvirt.mgmt_attach = false # disable default management interface
      end

      node.vm.provision "file", source: "tmp/hosts", destination: "/tmp/hosts"
      node.vm.provision "shell", inline: "cp /tmp/hosts /etc/hosts"
      node.vm.provision "shell", path: "scripts/00_upgrade_packages.sh"
      node.vm.provision "shell", path: "scripts/01_enable_firewall.sh"
      node.vm.provision "shell", path: "scripts/02_configure_firewall_controlplane.sh"
      node.vm.provision "shell", path: "scripts/03_configure_kernel.sh"
      node.vm.provision "shell", path: "scripts/04_configure_swap.sh"
      node.vm.provision "shell", path: "scripts/05_setup_repos.sh"
      node.vm.provision "shell", path: "scripts/06_setup_container_runtime.sh"
      node.vm.provision "shell", path: "scripts/07_setup_kubernetes_controlplane.sh", args: [pod_network_cidr]
      node.vm.provision "shell", path: "scripts/08_setup_pod_networking.sh", args: [pod_network_cidr]

    end

  end


end

