wget https://buildlogs.centos.org/c7.1908.u.x86_64/kernel/20200317234648/3.10.0-1062.18.1.el7.x86_64/kernel-devel-3.10.0-1062.18.1.el7.x86_64.rpm  -P /home/linux --no-check-certificate
wget https://buildlogs.centos.org/c7.1908.u.x86_64/kernel/20200317234648/3.10.0-1062.18.1.el7.x86_64/kernel-headers-3.10.0-1062.18.1.el7.x86_64.rpm  -P /home/linux --no-check-certificate

sudo rpm -i /home/linux/kernel-devel-3.10.0-1062.18.1.el7.x86_64.rpm 
sudo rpm -i /home/linux/kernel-headers-3.10.0-1062.18.1.el7.x86_64.rpm 

sudo dnf install -y tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-devel


wget https://us.download.nvidia.com/XFree86/Linux-x86_64/470.82.00/NVIDIA-Linux-x86_64-470.82.00.run -P /home/linux
sudo bash /home/linux/NVIDIA-Linux-x86_64-470.82.00.run --silent

export PATH=/usr/local/cuda-11.6/bin${PATH:+:${PATH}}

export LD_LIBRARY_PATH=/usr/local/cuda-11.6/lib64\
                         ${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

sudo systemctl enable nvidia-persistenced

sudo cp /lib/udev/rules.d/40-redhat.rules /etc/udev/rules.d 
sudo sed -i 's/SUBSYSTEM!="memory",.*GOTO="memory_hotplug_end"/SUBSYSTEM=="*", GOTO="memory_hotplug_end"/' /etc/udev/rules.d/40-redhat.rules



# install nvidia-container-runtime
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.repo | \
  sudo tee /etc/yum.repos.d/nvidia-container-runtime.repo

sudo yum install -y nvidia-container-runtime
sudo yum install -y nvidia-container-tookit


sudo cat <<EOF > /home/linux/daemon.json
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }, 
    "storage-driver": "devicemapper",
    "storage-opts": [
    "dm.thinpooldev=/dev/mapper/vgpaas-thinpool",
    "dm.use_deferred_removal=true",
    "dm.fs=ext4",
    "dm.use_deferred_deletion=true",
    "dm.basesize=10G"
    ]
}
EOF

sudo cp /home/linux/daemon.json /etc/docker/daemon.json


sudo systemctl restart docker