# tbs_driver

Пользователь должен иметь возможность выполнять sudo без пароля.

cat << EOF | sudo tee -a /etc/sudoers.d/90-users
$(whoami) ALL=(ALL) NOPASSWD:ALL
EOF
