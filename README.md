# Kubernetes (K8s) — Giới thiệu chi tiết

## Mục lục

- [Tổng quan](#tổng-quan)
- [Kiến trúc Kubernetes](#kiến-trúc-kubernetes)
  - [Node](#node)
  - [Pod](#pod)
  - [Service](#service)
  - [Networking (mạng)](#networking-mạng)
- [Cấu hình & triển khai](#cấu-hình--triển-khai)
- [Các resource phổ biến](#các-resource-phổ-biến)
- [Hoạt động tổng quan](#hoạt-động-tổng-quan)
- [Lệnh nhanh (cheatsheet)](#lệnh-nhanh-cheatsheet)
- [Kết luận](#kết-luận)

## Tổng quan

**Kubernetes (K8s)** là hệ thống mã nguồn mở để quản lý container, ban đầu phát triển bởi Google và hiện được duy trì bởi Cloud Native Computing Foundation (CNCF). Kubernetes giúp tự động hóa việc triển khai, quản lý, mở rộng và vận hành ứng dụng container.

- Ngôn ngữ chính: Go (Golang)
- Container runtime phổ biến: containerd (hoặc Docker, CRI-O…)
- Mục tiêu: triển khai, scale và vận hành ứng dụng container hóa một cách ổn định và có thể tự động hóa

---

## Kiến trúc Kubernetes

Kubernetes thường được mô tả theo mô hình Control-plane (master) — Worker node.

### Node

| Loại Node | Vai trò |
|-----------|--------:|
| Control-plane (control-plane / master) | Quản lý cluster; chạy các thành phần hệ thống như kube-apiserver, etcd, kube-controller-manager, kube-scheduler |
| Worker node | Chạy workloads (pod ứng dụng) và các pod hệ thống như kube-proxy, coredns, cni-plugin (ví dụ: calico-node) |

Kiểm tra trạng thái node:

```bash
kubectl get nodes
```

Ví dụ đầu ra:

```text
NAME       STATUS   ROLES           AGE     VERSION
ubuntu3    Ready    control-plane   6m44s   v1.31.13
ubuntu22   Ready    <none>          4m27s   v1.32.9
```

Chú ý: `<none>` thường có nghĩa là node không có role control-plane (tức là worker). Bạn có thể gán role bằng label nếu cần:

```bash
kubectl label node ubuntu22 node-role.kubernetes.io/worker=
```

### Pod

Pod là đơn vị triển khai nhỏ nhất trong Kubernetes; một Pod có thể chứa một hoặc nhiều container chia sẻ network namespace và storage.

- Application pod: chứa container ứng dụng
- System pod: phục vụ chức năng của cluster (ví dụ: coredns, kube-proxy, calico-node)

Kiểm tra pod hệ thống:

```bash
kubectl get pods -n kube-system
```

Ví dụ đầu ra:

```text
NAME                                       READY   STATUS    AGE
calico-node-xxrhd                          1/1     Running   5m
coredns-7c65d6cfc9-vk8m6                   1/1     Running   6m
```

### Service

Service là abstraction để kết nối các Pod với nhau hoặc expose ra ngoài cluster.

Các loại Service chính:

- ClusterIP (mặc định): chỉ truy cập trong cluster
- NodePort: expose qua cổng trên mỗi node
- LoadBalancer: tích hợp với cloud LB khi có hỗ trợ
- ExternalName: ánh xạ DNS tới một tên ngoài

Ví dụ YAML cho Service loại ClusterIP:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

### Networking (mạng)

- Mỗi Pod có IP riêng và có thể giao tiếp trực tiếp với Pod khác trong cluster.
- Các lớp mạng thường quan tâm: Layer 3 (IP routing) và Layer 7 (HTTP routing qua Service/Ingress).
- Control-plane quyết định nơi chạy Pod (scheduler). Các CNI plugin phổ biến: Calico, Flannel, Weave.

---

## Cấu hình & triển khai

Kubernetes dùng file YAML để mô tả các đối tượng (Pod, Deployment, Service, ConfigMap, Ingress, Job, CronJob, StatefulSet, DaemonSet, ...).

Ví dụ tạo Pod Nginx (file `pod.yaml`):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

Áp dụng lên cluster:

```bash
kubectl apply -f pod.yaml
```

---

## Các resource phổ biến

| Resource | Chức năng |
|---------|:---------|
| Pod | Đơn vị chạy container cơ bản |
| Deployment | Quản lý ReplicaSet, cho rolling update và scaling |
| ReplicaSet | Đảm bảo số lượng Pod chạy |
| StatefulSet | Quản lý Pod có state và tên cố định |
| DaemonSet | Đảm bảo Pod chạy trên mọi (hoặc một số) node |
| Job | Chạy Pod một lần hoàn thành |
| CronJob | Chạy job theo lịch |
| Service | Kết nối Pod trong/ngoài cluster |
| Ingress | Định tuyến HTTP/HTTPS vào Service |
| ConfigMap | Lưu cấu hình không nhạy cảm |
| Secret | Lưu thông tin nhạy cảm (mật khẩu, token) |
| PersistentVolume (PV) | Định nghĩa storage cấp phát cho cluster |
| PersistentVolumeClaim (PVC) | Yêu cầu storage từ PV |
| Namespace | Phân vùng logic cho các resource trong cluster |
| NetworkPolicy | Quy định traffic giữa Pod |
| Role / ClusterRole | Định nghĩa quyền truy cập |
| RoleBinding / ClusterRoleBinding | Gán quyền cho user/serviceaccount |
| CustomResourceDefinition (CRD) | Tạo resource tùy chỉnh |

---

## Hoạt động tổng quan

Luồng hoạt động cơ bản khi deploy một resource:

1. Người dùng viết YAML và chạy `kubectl apply -f`.
2. `kube-apiserver` nhận request và lưu trạng thái vào `etcd`.
3. Scheduler quyết định node phù hợp để chạy Pod.
4. Kubelet trên node tạo container thông qua runtime (ví dụ: containerd).
5. Service / Ingress định tuyến traffic giữa Pod và ra bên ngoài.

---

## Lệnh nhanh (cheatsheet)

```bash
# Kiểm tra nodes
kubectl get nodes

# Kiểm tra pod trong namespace kube-system
kubectl get pods -n kube-system

# Áp dụng file YAML
kubectl apply -f <file.yaml>

# Xem logs của một pod
kubectl logs <pod-name> [-c <container>]

# Mở port-forward từ pod tới máy local
kubectl port-forward <pod-name> 8080:80
```

---

## Kết luận

Kubernetes là nền tảng tiêu chuẩn cho các kiến trúc Cloud Native: nó cho phép bạn mô tả mọi resource bằng YAML, tự động hóa triển khai, mở rộng và quản lý mạng/lưu trữ/quyền hạn. Với các CNI plugins và hệ sinh thái rộng lớn, Kubernetes phù hợp cho cả môi trường on-premise và cloud.

Nếu bạn muốn, tôi có thể tiếp tục: thêm phần hướng dẫn cài đặt nhanh (kubeadm, kind, k3s), ví dụ Deployments nâng cao, hoặc checklist vận hành.