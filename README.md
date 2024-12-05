# DS_template

Репозиторий-шаблон, использованный в проекте [Data Science Project Template](https://github.com/KorneevRV/DS_template_infrastructure).

Структура (все, кроме README) этого репозитория копируется при вызове скрипта `make newproject`.

# Структура

```
.
├── README.md # этот файл, не копируется скриптом
├── data
│   ├── artifacts # артефакты модели
│   ├── processed # обработанные данные
│   └── raw # необработанные данные
├── docs # документация
├── makefile # скрипты для автоматизации
├── notebooks # jupyter-ноутбуки для прототипирования
├── requirements.txt # зависимости по умолчанию
└── src # исходный код проекта
```