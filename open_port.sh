#!/bin/bash
# ==========================================================
# 🚀 Mở các port cần thiết cho Kubernetes (Calico + Ingress)
# Tự phát hiện node là Master hay Worker
# ==========================================================

set -e

echo "🔍 Đang phát hiện vai trò node..."

if [ -f /etc/kubernetes/manifests/kube-apiserver.yaml ]; then
    ROLE="master"
    echo "🧠 Phát hiện: Đây là MASTER NODE"
else
    ROLE="worker"
    echo "⚙️  Phát hiện: Đây là WORKER NODE"
fi

# Bật ufw nếu chưa bật
sudo ufw status | grep -q inactive && sudo ufw enable

echo "🌐 Mở port chung..."
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 179/tcp comment 'Calico BGP'
sudo ufw allow 4789/udp comment 'Calico VXLAN'
sudo ufw allow 30000:32767/tcp comment 'NodePort Services'

if [ "$ROLE" == "master" ]; then
    echo "🧠 Cấu hình cho MASTER NODE..."
    sudo ufw allow 6443/tcp comment 'Kubernetes API Server'
    sudo ufw allow 2379:2380/tcp comment 'etcd server client API'
    sudo ufw allow 10250:10252/tcp comment 'kubelet, controller, scheduler'
    sudo ufw allow 80,443/tcp comment 'Ingress HTTP/HTTPS'
else
    echo "⚙️  Cấu hình cho WORKER NODE..."
    sudo ufw allow 10250/tcp comment 'Kubelet API'
    sudo ufw allow 80,443/tcp comment 'Ingress HTTP/HTTPS'
fi

sudo ufw reload
sudo ufw status numbered

echo "✅ Hoàn tất mở port cho node ($ROLE)!"
