# tbs_driver
version 0.2

Пользователь должен иметь возможность выполнять sudo без пароля.

cat << EOF | sudo tee -a /etc/sudoers.d/90-users
$(whoami) ALL=(ALL) NOPASSWD:ALL
EOF

fedora
Компьютер будет перезагружен. При первом запуске будет произведено две перезагрузки, при установке ПО и окончании установки драйверов.

centos7
Компьютер будет перезагружен. При первом запуске будет произведено три перезагрузки, при установке нового ядра(ml), при установке ПО и окончании установки драйверов.
