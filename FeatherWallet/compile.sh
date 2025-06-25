#!/bin/bash

# Скрипт для скачивания и сборки Feather Wallet с выбором релиза

REPO_URL="https://api.github.com/repos/feather-wallet/feather/releases"

# Получаем список релизов
echo "Получение списка релизов Feather Wallet..."
releases=$(curl -s "$REPO_URL" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$releases" ]; then
    echo "Не удалось получить список релизов."
    exit 1
fi

# Выводим релизы и предлагаем выбрать
echo "Доступные релизы:"
select release in $releases; do
    if [ -n "$release" ]; then
        echo "Выбран релиз: $release"
        break
    else
        echo "Пожалуйста, выберите номер релиза из списка."
    fi
done

# Скачиваем исходники выбранного релиза
ARCHIVE_URL="https://github.com/feather-wallet/feather/archive/refs/tags/$release.tar.gz"
echo "Скачивание исходников релиза $release..."
curl -L "$ARCHIVE_URL" -o "feather-$release.tar.gz"

if [ $? -ne 0 ]; then
    echo "Ошибка скачивания архива."
    exit 1
fi

# Распаковываем архив
tar -xzf "feather-$release.tar.gz"
cd "feather-${release#v}" || cd "feather-$release" || { echo "Не удалось перейти в директорию исходников."; exit 1; }

# Сборка (пример для Linux, требуется cmake и Qt)
echo "Начинаем сборку..."
mkdir -p build && cd build
cmake ..
make -j$(nproc)

if [ $? -eq 0 ]; then
    echo "Сборка завершена успешно!"
else
    echo "Ошибка сборки."
    exit 1
fi