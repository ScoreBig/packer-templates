#!/bin/bash

if [ -f floppy01.img ]; then
  rm -f floppy01.img
fi

vagrant up

scp -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -i ~/.vagrant.d/insecure_private_key -P 2222 ../../templates/windows-2003R2-serverenterprise-amd64/winnt.sif vagrant@localhost:/home/vagrant/winnt.sif
scp -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -i ~/.vagrant.d/insecure_private_key -P 2222 ../regedit.bat vagrant@localhost:/home/vagrant/regedit.bat
scp -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -i ~/.vagrant.d/insecure_private_key -P 2222 ../runonce.bat vagrant@localhost:/home/vagrant/runonce.bat
scp -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -i ~/.vagrant.d/insecure_private_key -P 2222 ../install-cygwin-sshd.bat vagrant@localhost:/home/vagrant/install-cygwin-sshd.bat
scp -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -i ~/.vagrant.d/insecure_private_key -P 2222 ../ps.bat vagrant@localhost:/home/vagrant/ps.bat
scp -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -i ~/.vagrant.d/insecure_private_key -P 2222 ../downloadFile.vbs vagrant@localhost:/home/vagrant/downloadFile.vbs
scp -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -i ~/.vagrant.d/insecure_private_key -P 2222 ../vagrant-ssh.bat vagrant@localhost:/home/vagrant/vagrant-ssh.bat
scp -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -i ~/.vagrant.d/insecure_private_key -P 2222 ../oracle-cert.cer vagrant@localhost:/home/vagrant/oracle-cert.cer
scp -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -i ~/.vagrant.d/insecure_private_key -P 2222 ../winrm.bat vagrant@localhost:/home/vagrant/winrm.bat

vagrant ssh -c "sudo dd bs=512 count=2880 if=/dev/zero of=floppy01.img"
vagrant ssh -c "sudo mkfs.msdos floppy01.img"
vagrant ssh -c "sudo mount -o loop floppy01.img /mnt"
vagrant ssh -c "sudo cp /home/vagrant/winnt.sif /mnt/winnt.sif"
vagrant ssh -c "sudo cp /home/vagrant/regedit.bat /mnt/regedit.bat"
vagrant ssh -c "sudo cp /home/vagrant/runonce.bat /mnt/runonce.bat"
vagrant ssh -c "sudo cp /home/vagrant/install-cygwin-sshd.bat /mnt/install-cygwin-sshd.bat"
vagrant ssh -c "sudo cp /home/vagrant/vagrant-ssh.bat /mnt/vagrant-ssh.bat"
vagrant ssh -c "sudo cp /home/vagrant/ps.bat /mnt/ps.bat"
vagrant ssh -c "sudo cp /home/vagrant/downloadFile.vbs /mnt/downloadFile.vbs"
vagrant ssh -c "sudo cp /home/vagrant/oracle-cert.cer /mnt/oracle-cert.cer"
vagrant ssh -c "sudo cp /home/vagrant/winrm.bat /mnt/winrm.bat"
vagrant ssh -c "sudo chown root:root /mnt/*.*"
vagrant ssh -c "sudo umount /mnt"

scp -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -i ~/.vagrant.d/insecure_private_key -P 2222 vagrant@localhost:/home/vagrant/floppy01.img .

vagrant destroy -f
