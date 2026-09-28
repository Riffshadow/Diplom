# Дипломная работа — системный администратор

**Автор:** Чернобровкин Иван

Проект представляет собой отказоустойчивую инфраструктуру в Yandex Cloud, развёрнутую с помощью Terraform и настроенную с использованием Ansible.

## Архитектура

В инфраструктуре используются следующие виртуальные машины:

- Bastion host
- Web Server 1
- Web Server 2
- Zabbix Server
- Elasticsearch
- Kibana

Web-серверы размещены в разных зонах доступности и работают за Application Load Balancer.

Доступ к внутренним виртуальным машинам по SSH осуществляется через bastion-host.

## Используемые технологии

- Yandex Cloud
- Terraform
- Ansible
- nginx
- Application Load Balancer
- Zabbix 7
- PostgreSQL
- Elasticsearch 7.17.9
- Kibana 7.17.9
- Filebeat 7.17.9
- Docker
- Ubuntu 24.04
- Yandex Cloud Snapshot Schedule

## Terraform

Terraform используется для автоматического создания облачной инфраструктуры:

- виртуальной сети и подсетей;
- виртуальных машин;
- security groups;
- Application Load Balancer;
- target group;
- HTTP router;
- backend group;
- автоматического расписания резервного копирования.

### Созданные виртуальные машины

![Yandex Cloud VMs](01-yandex-vms.png.png)

### Terraform outputs

![Terraform outputs](02-terraform-outputs.png.png)

## Ansible

Ansible используется для настройки серверов после создания инфраструктуры.

С его помощью выполняется:

- установка и настройка nginx;
- размещение веб-страницы на двух web-серверах;
- установка Zabbix Server;
- установка Zabbix Agent 2;
- развёртывание Elasticsearch;
- развёртывание Kibana;
- установка и настройка Filebeat.

Повторный запуск playbook для web-серверов завершается без ошибок и без необходимости внесения изменений.

![Ansible](03-ansible-web.png.png)

## Application Load Balancer

Входящий HTTP-трафик распределяется между двумя nginx web-серверами через Yandex Application Load Balancer.

Проверка HTTP-запроса возвращает:

- HTTP 200 OK;
- ответ от Yandex Cloud ALB;
- веб-страницу проекта.

![Application Load Balancer](04-alb.png.png)

## Мониторинг — Zabbix

Для мониторинга инфраструктуры используется Zabbix.

На web-1 и web-2 установлен Zabbix Agent 2. Используется шаблон:

`Linux by Zabbix agent active`

### Zabbix Dashboard

![Zabbix Dashboard](screenshots/05-zabbix-dashboard.png)

### Контролируемые хосты

![Zabbix Hosts](screenshots/06-zabbix-hosts.png)

## Централизованное логирование

Для сбора и просмотра логов используются:

- Filebeat;
- Elasticsearch;
- Kibana.

Filebeat установлен на обоих web-серверах и собирает:

- `/var/log/nginx/access.log`
- `/var/log/nginx/error.log`

Логи передаются в Elasticsearch и доступны для просмотра через Kibana Discover.

![Kibana Discover](screenshots/07-kibana-discover.png)

## Резервное копирование

Для дисков виртуальных машин настроено автоматическое создание snapshot.

Параметры:

- статус расписания: `ACTIVE`;
- запуск: ежедневно;
- срок хранения: 7 дней;
- в расписание включены диски всех 6 виртуальных машин.

![Snapshot Schedule](screenshots/08-snapshot-schedule.png)

## Безопасность

Для разделения доступа используются Security Groups.

Основные принципы:

- внутренние серверы не имеют публичного SSH-доступа;
- подключение выполняется через bastion-host;
- Elasticsearch доступен только внутри инфраструктуры;
- web-серверы получают HTTP-трафик через Application Load Balancer;
- секретные файлы, Terraform State, tfvars и приватные ключи исключены из Git с помощью `.gitignore`.

## Структура проекта

    sys-diplom/
    ├── ansible/
    │   ├── elasticsearch.yml
    │   ├── filebeat.yml
    │   ├── inventory.ini
    │   ├── kibana.yml
    │   ├── web.yml
    │   ├── zabbix.yml
    │   ├── zabbix_agents.yml
    │   └── files/
    │       └── site/
    │           └── index.html
    │
    ├── terraform/
    │   ├── alb.tf
    │   ├── backup.tf
    │   ├── compute.tf
    │   ├── network.tf
    │   ├── outputs.tf
    │   ├── providers.tf
    │   ├── security_admin.tf
    │   ├── security_logs.tf
    │   ├── security_web.tf
    │   └── variables.tf
    │
    ├── screenshots/
    └── README.md

## Результат

В результате выполнения проекта была создана инфраструктура в Yandex Cloud с двумя web-серверами за балансировщиком нагрузки, централизованным мониторингом, сбором логов и автоматическим резервным копированием.

Инфраструктура создаётся Terraform, а настройка программного обеспечения выполняется Ansible.
