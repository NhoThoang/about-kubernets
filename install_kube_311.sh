#!/bin/bash
# ===============================================
# 🚀 Cài đặt Kubernetes (kubeadm, kubelet, kubectl) + containerd trên Ubuntu
# Tested on Ubuntu 22.04 / 24.04
# ===============================================

set -e

echo "🔧 Cập nhật hệ thống..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "📦 Cài đặt các gói cần thiết..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# --- Cài đặt Containerd ---
echo "🐳 Cài đặt Containerd..."
sudo apt-get install -y containerd

echo "⚙️  Cấu hình containerd..."
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

echo "🔁 Khởi động lại containerd..."
sudo systemctl restart containerd
sudo systemctl enable containerd

# --- Cài đặt Kubernetes ---
echo "🔑 Thêm kho lưu trữ Kubernetes..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "📦 Cài kubeadm, kubelet, kubectl..."
# sudo apt-get update -y
# sudo apt-get install -y kubelet kubeadm kubectl
VERSION="1.31.4-00"

sudo apt-get update -y
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION

echo "📌 Giữ phiên bản cố định (không bị update tự động)"
sudo apt-mark hold kubelet kubeadm kubectl

echo "🔄 Kích hoạt kubelet..."
sudo systemctl enable kubelet

echo "✅ Hoàn tất cài đặt Kubernetes!"
echo "👉 Kiểm tra phiên bản:"
echo "   kubeadm version"
echo "   kubectl version --client"
echo "   kubelet --version"

echo "🚨 Nếu đây là master node, chạy lệnh:"
echo "   sudo kubeadm init --pod-network-cidr=10.244.0.0/16"
echo "🌐 Sau đó cài plugin mạng (Flannel, Calico, v.v.)"
