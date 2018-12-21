#!/bin/bash

# полный путь до скрипта
ABSOLUTE_FILENAME=`readlink -e "$0"`
# каталог в котором лежит скрипт
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`

if [[ $(sudo -l) =~ "(ALL) NOPASSWD: ALL" ]] ; then
        echo "==begin=="
else
	echo "У пользователя недостаточно прав"
	exit 1
fi


REQUEST="4.18"
CURVER=$(uname -r)
NEWEST=$( echo -e "${CURVER}\n${REQUEST}" | sort -Vr | head -n1 )
if [[ "${NEWEST}" > ${REQUEST} ]]
then
	echo "==Нужное ядро=="
	sed -i 's#'$ABSOLUTE_FILENAME'##g' ~/.bashrc
else
	echo "==Ядро версии ниже чем нужно=="
	sudo yum -y install epel-release
	sudo yum -y install yum-utils bash-c* wget bzip2
	sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	sudo yum -y install http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
	sudo yum -y --enablerepo=elrepo-kernel install kernel-ml-devel kernel-ml kernel-ml-headers
	sudo grub2-set-default 0
	echo $ABSOLUTE_FILENAME >> ~/.bashrc
	sudo shutdown -r now
fi


if [[ $(id) =~ "135(mock)" ]] ; then
        echo "==moc=="
	sed -i 's#'$ABSOLUTE_FILENAME'##g' ~/.bashrc
else
	echo "==no moc=="
	sudo yum -y groupinstall "Development Tools"
	sudo yum -y install elfutils-libelf-devel
	sudo yum -y install gcc unzip
	sudo yum -y install perl-Digest* perl-Proc* perl-devel perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker
	sudo yum -y install patch patchutils
	sudo yum -y install rpm-build spectool git mock
	sudo usermod -a -G mock $(whoami)
	echo "==Необходим restart=="
	echo $ABSOLUTE_FILENAME >> ~/.bashrc
	sudo shutdown -r now
fi

rpmdev-setuptree

if [[ -d ~/rpmbuild/SOURCES/tbs_driver/$(uname -r) ]]; then
	#    rm -Rf ~/rpmbuild/SOURCES/tbs_driver/$(uname -r)
	cd ~/rpmbuild/SOURCES/$(uname -r)/media
	git remote update
	git pull
	cd ~/rpmbuild/SOURCES/$(uname -r)/media_build
	git remote update
	git pull
	make
	sudo rm -r -f /lib/modules/$(uname -r)/kernel/drivers/media
	sudo rm -r -f /lib/modules/$(uname -r)/kernel/drivers/staging/media
	sudo rm -r -f /lib/modules/$(uname -r)/extra
	sudo make install
	if [[ -f ~/rpmbuild/SOURCES/tbs-tuner-firmwares_v1.0.tar.bz2 ]]; then
		rm -f ~/rpmbuild/SOURCES/tbs-tuner-firmwares_v1.0.tar.bz2
	fi
	wget http://www.tbsdtv.com/download/document/linux/tbs-tuner-firmwares_v1.0.tar.bz2 -O ~/rpmbuild/SOURCES/tbs-tuner-firmwares_v1.0.tar.bz2
	sudo tar jxvf ~/rpmbuild/SOURCES/tbs-tuner-firmwares_v1.0.tar.bz2 -C /lib/firmware/

	echo "==end=="
	exit 1
fi

mkdir -p ~/rpmbuild/SOURCES/tbs_driver/$(uname -r)
cd ~/rpmbuild/SOURCES/tbs_driver/$(uname -r)
git clone https://github.com/tbsdtv/media_build.git
git clone --depth=1 https://github.com/tbsdtv/linux_media.git -b latest ./media
sudo sed -i.bak -e 's/^\(CONFIG_DVB_MAX_ADAPTERS\)=.*/\1=48/g' /lib/modules/$(uname -r)/build/.config
cd media_build
make dir DIR=../media
make distclean
make allyesconfig
make -j5
sudo rm -r -f /lib/modules/$(uname -r)/kernel/drivers/media
sudo rm -r -f /lib/modules/$(uname -r)/kernel/drivers/staging/media
sudo rm -r -f /lib/modules/$(uname -r)/extra
sudo make install
if [[ -f ~/rpmbuild/SOURCES/tbs_driver/tbs-tuner-firmwares_v1.0.tar.bz2 ]]; then
    rm -f ~/rpmbuild/SOURCES/tbs_driver/tbs-tuner-firmwares_v1.0.tar.bz2
fi
wget http://www.tbsdtv.com/download/document/linux/tbs-tuner-firmwares_v1.0.tar.bz2 -O ~/rpmbuild/SOURCES/tbs_driver/tbs-tuner-firmwares_v1.0.tar.bz2
sudo tar jxvf ~/rpmbuild/SOURCES/tbs_driver/tbs-tuner-firmwares_v1.0.tar.bz2 -C /lib/firmware/

echo "==end=="
sudo shutdown -r now
