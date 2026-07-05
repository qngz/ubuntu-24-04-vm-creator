# ubuntu-24-04-vm-creator

Скрипт для быстрого создания виртуальных машин на базе Ubuntu 24.04 через overlay-образы

## Что делает
- Генерирует cloud-init конфигурацию (user-data/meta-data) с пользователем 
  и SSH-ключом
- Создаёт seed-образ через cloud-localds
- Создаёт overlay-диск (qcow2, copy-on-write) поверх базового 
  Ubuntu 24.04 cloud image — без копирования полного образа
- Запускает VM через virt-install (KVM/libvirt)

## Использование
```bash
bash create-vm.bash <имя-vm>
```

## Требования
- необходимые пакеты: qemu-kvm, libvirt-daemon-system, cloud-image-utils, virtinst
- Базовый образ Ubuntu 24.04 cloud image по пути /var/lib/libvirt/images/ubuntu24.04-base.img
- SSH-публичный ключ по пути ~/.ssh/vm.pub
