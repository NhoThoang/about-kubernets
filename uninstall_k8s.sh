#!/bin/bash
# ===============================================
# 🧹 Script gỡ cài đặt hoàn toàn Kubernetes (kubeadm/kubelet/kubectl)
# ===============================================

echo "🔧 Dừng kubelet và container runtime..."
sudo systemctl stop kubelet
sudo systemctl stop containerd
sudo systemctl stop docker

echo "🧼 Reset kubeadm..."
sudo kubeadm reset -f

echo "🗑 Xóa cấu hình và dữ liệu Kubernetes..."
sudo rm -rf ~/.kube
sudo rm -rf /etc/kubernetes
sudo rm -rf /var/lib/etcd
sudo rm -rf /var/lib/kubelet
sudo rm -rf /var/lib/cni
sudo rm -rf /etc/cni
sudo rm -rf /opt/cni
sudo rm -rf /run/flannel
sudo rm -rf /var/lib/dockershim
sudo rm -rf /var/run/kubernetes
sudo rm -rf /etc/systemd/system/kubelet.service.d
sudo rm -rf /etc/systemd/system/kubelet.service
sudo rm -rf /usr/bin/kube*

echo "🧹 Xóa gói kubeadm, kubelet, kubectl..."
sudo apt-get purge -y kubeadm kubelet kubectl kubernetes-cni cri-tools
sudo apt-get autoremove -y
sudo apt-get autoclean -y

echo "🧽 Xóa container runtime (Docker/Containerd) nếu muốn..."
read -p "❓ Bạn có muốn gỡ luôn Docker/Containerd không? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo rm -rf /var/lib/docker
  sudo rm -rf /var/lib/containerd
fi

echo "🔄 Reload lại systemd và dọn sạch cgroup..."
sudo systemctl daemon-reload
sudo systemctl reset-failed

echo "✅ Hoàn tất! Kubernetes đã được gỡ bỏ hoàn toàn."
