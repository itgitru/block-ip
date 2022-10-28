# Примеры конфигурации Mikrotik | RouterOS
	`blacklist_mikrotik.rsc` - RSC файл включающий все блокировки из данного репозитория.
## Примеры 
### Вариант 1
В RouterOS заходим в System -> Script и создаем скрипт следующего содержания:
```
/file/remove blacklist_mikrotik.rsc
/ip/firewall/address-list/remove [find list=blacklist comment=IT-GIT]
/tool fetch url="https://raw.githubusercontent.com/itgitru/block-ip/main/RouterOS/blacklist_mikrotik.rsc" mode=http;
/import file-name=blacklist_mikrotik.rsc
```
Перед выполнение данного скрипта, желательно сначала загрузить через консоль:
```
/tool fetch url="https://raw.githubusercontent.com/itgitru/block-ip/main/RouterOS/blacklist_mikrotik.rsc" mode=http;
```

### Вариант 2
Скрипт который сам обработает все строчки с IP адресами и добавит их в Blacklist:
```
ip firewall address-list
:local update do={
:do {
:local data ([:tool fetch url=$url output=user as-value]->"data")
remove [find list=blacklist comment=$description]
:while ([:len $data]!=0) do={
:if ([:pick $data 0 [:find $data "\n"]]~"^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}") do={
:do {add list=blacklist address=([:pick $data 0 [:find $data $delimiter]].$cidr) comment=$description timeout=1d} on-error={}
}
:set data [:pick $data ([:find $data "\n"]+1) [:len $data]]
}
} on-error={:log warning "Address list <$description> update failed"}
}
$update url=https://raw.githubusercontent.com/itgitru/block-ip/main/RouterOS/blacklist_mikrotik.rsc description="Spamer ip IT-GIT" delimiter=("\n")
```

### Почти готово:
После создания скрипта в RouterOS незабываем в System -> Sheduler о задании на его запуск.
```
/system script run ИМЯ_Скрипта
```
Не забываем создать правило блокировки в фаерволе, например так:
```
/ip firewall raw
add action=drop chain=prerouting in-interface=ether1 src-address-list=blacklist
```
------

Данные скрипты приведены как пример, создания автоматически обновляемых спиков блокировки.

Вы можете разработать свои скрипты под задачи на основе генерируемых нами списоков. 
