#!/bin/bash

# честно одолженный скрипт

# Используем CA из Minikube
MINIKUBE_CA_CERT=~/.minikube/ca.crt
MINIKUBE_CA_KEY=~/.minikube/ca.key

# Генерируем ключи для developer-view
openssl genrsa -out developer-view.key 2048
openssl req -new -key developer-view.key -out developer-view.csr -subj "/CN=developer-view"
openssl x509 -req -in developer-view.csr -CA $MINIKUBE_CA_CERT -CAkey $MINIKUBE_CA_KEY -CAcreateserial -out developer-view.crt -days 365

# Генерируем ключи для admin
openssl genrsa -out admin.key 2048
openssl req -new -key admin.key -out admin.csr -subj "/CN=admin"
openssl x509 -req -in admin.csr -CA $MINIKUBE_CA_CERT -CAkey $MINIKUBE_CA_KEY -CAcreateserial -out admin.crt -days 365

# Добавляем пользователей в kubeconfig
kubectl config set-credentials developer-view --client-certificate=developer-view.crt --client-key=developer-view.key --embed-certs=true
kubectl config set-credentials admin --client-certificate=admin.crt --client-key=admin.key --embed-certs=true

# Получаем имя кластера Minikube
CLUSTER_NAME=$(kubectl config view -o jsonpath='{.clusters[0].name}')

# Создаем контексты
kubectl config set-context developer-view-context --cluster=$CLUSTER_NAME --user=developer-view
kubectl config set-context admin-context --cluster=$CLUSTER_NAME --user=admin

# Очистка временных файлов
rm *.csr 