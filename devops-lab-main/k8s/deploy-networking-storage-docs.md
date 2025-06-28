# Bài 8: Networking: Ingress Controller & Ingress Resource - expose app qua domain, giống môi trường production thực sự

## 1. Tại sao cần Ingress?

Trong thực tế, bạn `không thể expose mỗi service bằng NodePort/LoadBalancer` được:

- Không thể nhớ nhiều port
- Không dễ cấu hình SSL
- Không quản lý routing tốt

**✅ Ingress giải quyết vấn đề:**

> Nó giống như một reverse proxy nằm trong cluster, nhận HTTP(S) request từ ngoài và route tới đúng service bên trong.

## 🧱 Cấu trúc gồm 2 phần:

- `Ingress Controller:` pod chạy như proxy/nginx trong cluster
- `Ingress Resource:` YAML định nghĩa rule: domain nào → service nào

## Thực hành: Dùng NGINX Ingress Controller trên Minikube

**Bước 1: Cài NGINX Ingress Controller**

```
minikube addons enable ingress
```

> ✅ Minikube sẽ cài Pod controller nginx-controller chạy trong namespace ingress-nginx
> Kiểm tra:

```
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

> Ta sẽ thấy một LoadBalancer hoặc NodePort service tên ingress-nginx-controller.

**Bước 2: Tạo Ingress resource**
Giả sử bạn đã có flask-app expose qua Service tên là flask-clusterip.

> Tạo file flask-ingress.yaml:

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: flask-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: flask.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: flask-clusterip
            port:
              number: 80
```

**Bước 3: Apply và kiểm tra**

```
kubectl apply -f flask-ingress.yaml
kubectl get ingress
```

Output

```
NAME             CLASS    HOSTS         ADDRESS        PORTS   AGE
flask-ingress    <none>   flask.local   <controllerIP> 80      1m
```

**Bước 4: Truy cập bằng tên miền ảo**
Với Minikube

```
minikube ip
```

Giả sử IP là 192.168.49.2, bạn thêm vào /etc/hosts:

```
sudo nano /etc/hosts
```

Thêm dòng:

```
192.168.49.2   flask.local
```

Lưu lại, sau đó truy cập:

```
http://flask.local
```

**✅ Tổng kết bạn cần nhớ:**

- Ingress Controller là Pod proxy (thường dùng NGINX)
- Ingress Resource định nghĩa HTTP rule: domain/path → service
- Dễ dàng route nhiều app trên cùng IP
- Có thể mở rộng với SSL, redirect, path rewrite, v.v.

# Bài 9: Storage trong Kubernetes

## Storage trong K8s

- `Volume`: Một thư mục được mount vào Pod
- `PersistentVolume (PV)`: Tài nguyên lưu trữ được cấp bởi cluster
- `PersistentVolumeClaim (PVC)`: Yêu cầu sử dụng một phần của PV
- `StorageClass`: Mô tả cách tạo volume động (Dynamic provisioning)

## Tại sao cần PVC và PV?

Trong K8s:

- Volume gắn trong Pod thì sẽ `mất dữ liệu khi Pod bị xoá.`
- PersistentVolume là một storage `ngoài vòng đời của Pod,` nên `giữ được dữ liệu` dù Pod bị xoá hay tái tạo.
- PVC giúp bạn `yêu cầu một volume` mà không cần biết chi tiết về hạ tầng lưu trữ.

## Demo: Viết YAML dùng PVC lưu dữ liệu

Giả sử ta có một Pod chạy nginx lưu file vào `/usr/share/nginx/html`.

1. Tạo PersistentVolume (nếu dùng static)

```
# pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nginx-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/nginx-pv   # dùng hostPath cho Minikube
```

> ⚠️ Chỉ dùng hostPath khi học/lab với Minikube. Trong production cần dùng NFS, EBS, Ceph...

2. Tạo PersistentVolumeClaim

```
# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

3. Dùng PVC trong Pod

```
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pvc-pod
spec:
  containers:
    - name: nginx
      image: nginx
      volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: html-volume
  volumes:
    - name: html-volume
      persistentVolumeClaim:
        claimName: nginx-pvc
```

4. Áp dụng và kiểm tra

```
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f pod.yaml

kubectl get pod
kubectl exec -it nginx-pvc-pod -- /bin/sh
```

Trong container:

```
echo "Hello from volume" > /usr/share/nginx/html/index.html
```

Rồi thử truy cập qua kubectl port-forward:

```
kubectl port-forward pod/nginx-pvc-pod 8080:80
```

> Vào trình duyệt: http://localhost:8080

## 🔍 Tóm gọn sự khác biệt giữa PV và PVC

| **Thành phần**                  | **Là gì?**                                         | **Do ai tạo?**                                    | **Vai trò chính**                      |
| ------------------------------- | -------------------------------------------------- | ------------------------------------------------- | -------------------------------------- |
| **PV** (PersistentVolume)       | Tài nguyên lưu trữ vật lý (ổ cứng, NFS, EBS, v.v.) | Người quản trị cluster hoặc `StorageClass` tự tạo | Cung cấp không gian lưu trữ            |
| **PVC** (PersistentVolumeClaim) | Yêu cầu lưu trữ từ phía người dùng (dev, app)      | Developer (bạn) tạo ra                            | Xin một phần dung lượng để app sử dụng |

---

🧠 **PV giống như "ổ cứng", còn PVC giống như "phiếu yêu cầu sử dụng một phần ổ cứng".**

## Dòng chảy hoạt động

1. `Người quản trị` tạo các `PersistentVolume (PV) trước` – giống như mua sẵn ổ cứng và gắn vào server.
2. `Người dùng (dev)` tạo `PVC` để yêu cầu dùng một phần ổ cứng đó.
3. Kubernetes `match PVC với PV tương ứng` (dựa trên size, mode).
4. `PVC gắn vào Pod` -> Pod dùng được volume bền vững.

## Khi nào cần dùng PV/PVC?

**Bạn cần dùng PVC khi:**

| Trường hợp thực tế                                    | Vì sao cần PVC                                                           |
| ----------------------------------------------------- | ------------------------------------------------------------------------ |
| App như MySQL, PostgreSQL, MongoDB, Redis, MinIO, ... | Cần lưu trữ `dữ liệu lâu dài`, không được mất khi Pod bị xóa hay restart |
| App cần lưu file (upload)                             | `Lưu vào volume dùng chung nhiều Pod`                                    |
| `App cần cache, logs,... bền vững qua lần deploy`     | `Volume gắn với PVC sẽ không bị mất sau khi Pod chết`                    |

## 🤨 Tại sao không dùng Volume trực tiếp luôn?

**Bạn có thể hỏi: `sao không gắn hostPath` hay volume thẳng vào Pod?**

**Lý do do:**

| Gắn trực tiếp (`emptyDir`, `hostPath`) | Dùng PVC (`PV` + `PVC`)               |
| -------------------------------------- | ------------------------------------- |
| Mất dữ liệu khi Pod bị restart         | Dữ liệu vẫn tồn tại                   |
| Không tách biệt giữa app và hạ tầng    | Tách biệt tốt hơn                     |
| Không thể dùng trên nhiều node         | `PVC` + `PV` có thể dùng network disk |
| Không thể scale hoặc HA                | `PVC` + `PV` cho phép                 |

## Ví dụ hình ảnh hóa

`Giả sử bạn là 1 backend dev viết app ghi log ra disk.:`

- Bạn `không biết ổ đĩa nào dùng`, không nên tự cấu hình đường dẫn ổ cứng.
- Bạn chỉ nói: “Tôi cần ổ 1Gi, đọc ghi được, dùng riêng.”
- Bạn viết `pvc.yaml để yêu cầu`.
- K8s tự gắn PVC vào một ổ cứng (PV có sẵn hoặc tạo mới theo StorageClass).
- `Bạn dùng volume này trong Pod mà không quan tâm bên dưới là ổ gì.`

# Bài 10: Resource Requests & Limits trong Kubernetes

Mục tiêu:

- Hiểu cách K8s quản lý tài nguyên CPU & RAM cho container
- Biết cách cấu hình request và limit để app không làm "nghẽn" cluster

## 1. Tại sao cần cấu hình tài nguyên?

Kubernetes là hệ thống multi-tenant, nhiều Pod chạy chung 1 Node.

> Nếu không giới hạn, một app có thể ngốn hết CPU/RAM → ảnh hưởng các app khác.

## 2. Giải thích đơn giản:

- `requests`: Lượng tài nguyên `tối thiểu`Pod cần. K8s dùng để `scheduling`.
- `limits`: Lượng tài nguyên `tối đa` Pod được phép dùng. K8s sẽ `giới hạn cứng`.

## 3. Đơn vị:

- CPU:
  - 1 = 1 core (ví dụ: 0.5 = nửa core, 100m = 0.1 core)
- Memory:
  - Mi = Mebibyte, Gi = Gibibyte

## 4. Ví dụ YAML cấu hình resource:

```
apiVersion: v1
kind: Pod
metadata:
  name: resource-demo
spec:
  containers:
  - name: demo-container
    image: nginx
    resources:
      requests: # Yêu cầu tối thiểu: 64MB RAM, 0.25 CPU
        memory: "64Mi"
        cpu: "250m"
      limits: # Giới hạn tối đa: 128MB RAM, 0.5 CPU
        memory: "128Mi"
        cpu: "500m"
```

## 5. Điều gì xảy ra nếu vượt limit?

- `Vượt CPU limit:` container bị `throttled (giảm tốc độ)`
- `Vượt RAM limit:` container bị `kill`

## Mở rộng - Câu hỏi đặt ra?

### ❓ 1. Nếu bạn chỉ set limits mà không set requests thì chuyện gì xảy ra?

**Ngắn gọn**

> Kubernetes `mặc định coi` request `bằng` limit nếu bạn không khai báo request.

**Giải thích kỹ**

- request là mức tối thiểu để K8s dùng cho việc lên lịch (scheduling).
- Nếu bạn không chỉ định request, thì scheduler `không biết chính xác mức tài nguyên tối thiểu cần thiết, nên sẽ lấy` limit làm request.

```
resources:
  limits:
    cpu: "500m"
    memory: "128Mi"
```

- Pod này được coi là yêu cầu 500m CPU, 128Mi RAM
- Scheduler sẽ tìm Node đáp ứng được mức đó.
  **⚠️ Hậu quả:**
- Có thể gây `overcommit` nếu bạn tưởng là nó yêu cầu ít, nhưng thật ra scheduler coi là yêu cầu nhiều hơn.

### ❓ 2. Nếu bạn set requests > limits thì có hợp lệ không?

**Ngắn gọn**

> Không hợp lệ! Kubernetes sẽ báo lỗi khi apply.

**Giải thích kỹ:**

- requests là lượng `yêu cầu tối thiểu`, còn limits là `lượng tối đa được dùng`.
- Nếu bạn yêu cầu nhiều hơn mức cho phép → `không hợp lý về logic`, nên K8s từ chối.

```
resources:
  requests:
    cpu: "1"
  limits:
    cpu: "500m"  # ❌ Không hợp lệ: yêu cầu > giới hạn
```

Error:

```
spec.containers.resources.requests.cpu: Invalid value: "1": must be less than or equal to cpu limit
```

# Bài 11: StorageClass & Dynamic PVC

**Mục tiêu:**

- Hiểu cách `Kubernetes tự tạo PersistentVolume (PV)` bằng cách sử dụng `StorageClass`.

- `Đây là bước nâng cấp từ cách tạo PV thủ công sang cơ chế tự động hoá` — cực kỳ quan trọng khi triển khai thật (trên cloud, hoặc Minikube có hỗ trợ).

## 1. Vấn đề với cách tạo PV thủ công

Ở các bài trước, bạn phải:

- Viết YAML cho PersistentVolume
- Viết thêm YAML cho PersistentVolumeClaim

> Tốn công, không linh hoạt, khó scale.

## 2. Giải pháp: StorageClass

- StorageClass định nghĩa `cách tạo PV một cách tự động`
- Khi bạn tạo một PersistentVolumeClaim có storageClassName, Kubernetes sẽ dùng StorageClass để `dynamic provisioning PV`
- Không cần viết YAML PV thủ công nữa!

## Các thành phần:

**StorageClass:**

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: my-storageclass
provisioner: kubernetes.io/no-provisioner   # hoặc driver cloud như ebs.csi.aws.com, do bạn dùng Minikube nên thường là `standard` hoặc `hostpath`
volumeBindingMode: WaitForFirstConsumer
```

**PVC dùng StorageClass:**

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-dynamic-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard   # chỉ rõ StorageClass
```

Khi PVC được tạo, Kubernetes sẽ:

- Tự tạo PV phù hợp
- Gắn kết PVC với PV đó

### Câu hỏi đặt ra: Bạn nghĩ bạn vẫn phải viết YAML tạo volume thủ công, đúng không?

**Nhưng thực tế, bạn chỉ cần viết YAML cho PVC (PersistentVolumeClaim), còn việc tạo ra PV (PersistentVolume) thì K8s sẽ tự động làm cho bạn dựa trên StorageClass.**

## So sánh cách làm trước đây (thủ công) và bây giờ (dynamic):

| Thủ công (static provisioning)                                                               | Dynamic provisioning với StorageClass                                                                |
| -------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Bạn tạo `PersistentVolume` (PV) thủ công, định nghĩa rõ storage backend, path, kích thước... | Bạn chỉ cần tạo `PersistentVolumeClaim` (PVC) yêu cầu bao nhiêu storage, dùng `StorageClass` nào     |
| Kubernetes tìm PV phù hợp rồi bind cho PVC                                                   | Kubernetes dựa vào `StorageClass` để gọi provisioner tương ứng tự tạo ra PV mới đúng với yêu cầu PVC |
| Phù hợp môi trường tĩnh, cấu hình thủ công                                                   | Phù hợp môi trường cloud, cluster lớn, tự động, scale tốt                                            |

### Tự động tạo PV ra sao?

- Khi bạn tạo 1 PVC và gán storageClassName: standard (hoặc 1 StorageClass bất kỳ), Kubernetes sẽ gọi trình provisioner tương ứng.
- Provisioner này là một controller chạy trong cluster, nó sẽ tạo PV vật lý (ví dụ gọi cloud API tạo volume EBS, hay tạo thư mục hostPath trên node trong Minikube).
- Sau đó PV được tạo sẽ tự động gán cho PVC

### Ví dụ minh họa

1. Bạn tạo file PVC (pvc.yaml):

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard
```

2. Bạn apply lệnh:

```
kubectl apply -f pvc.yaml
```

3. Kubernetes tự tạo PV tương ứng, bạn không phải tạo PV nữa:

```
kubectl get pv
```

Output:

```
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM            STORAGECLASS   REASON   AGE
pvc-12345678-90ab-cdef-1234-567890abcdef  1Gi        RWO            Delete           Bound    default/test-pvc standard                1m
```

- Bạn thấy PV được tạo tự động, tên PV do K8s sinh ra.
- PV này đã được gán (Bound) cho PVC bạn tạo.

## Tóm lại:

- `Bạn làm`: Tạo PVC chỉ định storageClassName và kích thước -> `k8s làm`: Tự động tạo PV vật lý tương ứng với PVC đó dựa trên StorageClass
- `Bạn làm`: Cấu hình Pod gắn PVC -> `k8s làm`: Gắn PVC vào Pod để sử dụng lưu trữ
