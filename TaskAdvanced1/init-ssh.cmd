:: Создаем папку .ssh если её нет
if not exist "%USERPROFILE%\.ssh" mkdir "%USERPROFILE%\.ssh"

:: Генерируем ключ (нажимайте Enter на все вопросы)
ssh-keygen -t rsa -b 4096 -f "%USERPROFILE%\.ssh\future20_vm" -N ""

:: Выводим публичный ключ (скопируйте всё содержимое!)
type "%USERPROFILE%\.ssh\future20_vm.pub"