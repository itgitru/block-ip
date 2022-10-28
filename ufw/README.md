# Примеры конфигурации для UFW Фаервола
	`tmp1_before.rules` - Верхняя часть дефолтного конфига для формирования before.rules.
	`tmp2_before.rules` - Нижняя часть дефолтного конфига для формирования before.rules.
	`ufw_before.rules` - Средняя часть, содержит только правила блокировки.
	`before.rules` - Полностью сгенерированный файл включающий все блокировки из данного репозитория.
### Пример формирования файла before.rules
```bash
cat tmp1_before.rules ufw_before.rules tmp2_before.rules >> before.rules
```
*Между tmp1_ и tmp2_ файлами по мимо генерируемого нами ufw_before можно добавить свой файл или файлы блокировок

## Пример скрипта
Ниже приведен пример скрипта который может использоваться для проверки изменений необходимого файла в Github, и последующей загрузки этих изменений в UFW. 
Скрипт проверяет контрольные суммы файлов, после чего если контрольные суммы идентичны, останавливает выполнение, 
если контрольные суммы разные скрипт инициализирует загрузку обновленного файла, после чего применяет настройки фаервола.
```bash
#!/bin/bash
log="/tmp/ufw_rules/hash_git_block_ip.log"
# минимальное логирование
printf "Log File (hash) - " > $log
date >> $log
#--------------------------------
cd /tmp/ufw_rules/
# очищаем файл контрольных сумм
cat /dev/null > hash_git_block_ip.sum
echo "- clear file" >> $log
# получаем контрольные суммы
md5sum ufw_before.rules| cut -d ' ' -f 1 >> hash_git_block_ip.sum
curl -s https://raw.githubusercontent.com/itgitru/block-ip/main/ufw/ufw_before.rules|md5sum | cut -d ' ' -f 1 >> hash_git_block_ip.sum
echo "- md5sum upload" >> $log
sleep 15s
# контрольные суммы в переменные
sum1=$(cat hash_git_block_ip.sum | head -n1 | tail -n1)
sum2=$(cat hash_git_block_ip.sum | head -n2 | tail -n1)
# проверяем равенство контрольных сумм
if [ "$sum1" = "$sum2" ]; then
    echo "- Strings are equal." >> $log
else
    echo "- Strings are not equal." >> $log
    echo "- Start update" >> $log
rm ufw_before.rules
wget https://raw.githubusercontent.com/itgitru/block-ip/main/ufw/ufw_before.rules
cat /dev/null > /etc/ufw/before.rules
cat tmp1_before.rules ufw_before.rules tmp2_before.rules >> /etc/ufw/before.rules
/etc/init.d/ufw restart >> $log
    echo "- Update completed" >> $log
fi
echo "Exit" >> $log
```

