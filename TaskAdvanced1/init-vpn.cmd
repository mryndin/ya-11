:: Создаем сеть
yc vpc network create --name future20-network

:: Создаем подсеть в зоне ru-central1-a
yc vpc subnet create --name future20-subnet --zone ru-central1-a --range 10.0.1.0/24 --network-name future20-network

:: Получаем ID подсети (скопируйте значение id из вывода)
yc vpc subnet get --name future20-subnet

:: Получаем ID каталога (folder-id)
yc config get folder-id

:: Получаем ID облака (cloud-id)
yc config get cloud-id