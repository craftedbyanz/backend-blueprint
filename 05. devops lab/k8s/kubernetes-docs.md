# Bài 1. Kubernetes là gì?

Kubernetes (viết tắt: K8s) là một nền tảng điều phối container (container orchestration platform), dùng để:

- Deploy ứng dụng (app) chạy dưới dạng container
- Quản lý tự động các app đó: scaling, cập nhật, khôi phục khi lỗi
- Quản lý tài nguyên hệ thống (CPU, RAM)
- Expose app ra ngoài (networking, load balancing)

Nó giúp bạn không còn phải:

- SSH vào server rồi chạy docker run
- Quản lý port mapping, volume mount thủ công
- Viết script bash cho update, restart, failover

## Thành phần chính trong K8s (cơ bản)

| Thành phần             | Vai trò                                | Ví dụ thực tế                       |
| ---------------------- | -------------------------------------- | ----------------------------------- |
| **Pod**                | 1 hoặc nhiều container chạy cùng nhau  | App container + logging sidecar     |
| **Deployment**         | Đảm bảo app có đủ replica, auto update | Giữ 3 app node luôn chạy            |
| **Service**            | Expose Pod ra ngoài hoặc nội bộ        | Load balancer nội bộ                |
| **ConfigMap / Secret** | Cấu hình app, API keys                 | ENV, DB password                    |
| **kubectl**            | CLI để thao tác với cluster            | `kubectl apply`, `kubectl get pods` |

**Thực hành – Cài Kubernetes local và chạy app đầu tiên**

```
brew install kubectl
kubectl version --client

brew install minikube
minikube version

minikube start

// Kiểm tra Cluster
kubectl get nodes
```

**Deploy app NGINX đầu tiên**

```
kubectl apply -f nginx-deployment.yaml

// Kiểm tra pods
kubectl get pods

// Expose service:
kubectl expose deployment nginx-deployment --type=NodePort --port=80

// Xem service:
kubectl get service

// Forward port để truy cập bằng trình duyệt:
kubectl port-forward service/nginx-deployment 8080:80

```

# Bài 2: Giải thích Pod, Deployment, Service trong Kubernetes

## 1. Pod là gì?

- Pod là đơn vị deploy nhỏ nhất trong Kubernetes.
- Một Pod thường chứa 1 container, nhưng cũng có thể chứa nhiều container (hiếm hơn) – chúng sẽ chia sẻ network và storage
- Pod như một "hộp container" duy nhất – ví dụ một instance của app NGINX.

YAML mẫu:

```
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

> Dùng Pod trực tiếp không phổ biến vì Pod `không tự restart` khi crash. Đó là lý do ta cần `Deployment.`

## 2. Deployment là gì?

- Deployment `quản lý Pod` theo dạng `replica`: số lượng, update rollout, rollback...
- Luôn đảm bảo số lượng Pod như bạn yêu cầu.

Ví dụ thực tế: - Bạn muốn chạy 3 instance của app – Deployment sẽ `đảm bảo có đúng 3 Pod`, nếu 1 pod chết thì nó sẽ `tạo lại`.

YAML mẫu:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

## 3. ReplicaSet là gì?
- ReplicaSet đảm bảo rằng `có đúng số lượng bản sao (replica)` của Pod bạn muốn chạy tại mọi thời điểm.
- Nếu Pod bị crash, ReplicaSet sẽ tự tạo lại.
- Nếu bạn chỉnh số lượng replica, nó sẽ scale up/down tương ứng.

## 4. Service là gì?

- Service là `cổng vào` để truy cập các Pod (vì Pod IP có thể thay đổi).
- Nó tạo ra một địa chỉ `ổn định` để kết nối đến các Pod.

Các loại Service:

| Loại         | Mục đích                    | Ghi chú        |
| ------------ | --------------------------- | -------------- |
| ClusterIP    | Chỉ dùng nội bộ cluster     | Default        |
| NodePort     | Mở cổng từ node để truy cập | Dùng local dev |
| LoadBalancer | Cho cloud, có IP public     | AWS, GCP...    |

YAML mẫu cho NodePort:

```
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  type: NodePort
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080  # Port truy cập từ ngoài
```

> Sau khi apply, bạn có thể truy cập qua localhost:30080 (với minikube service hoặc port-forward).

**Tóm tắt mối quan hệ:**

```
User -> Service -> Pod (ngầm được quản lý bởi Deployment)
```

- Pod: đơn vị chạy container
- Deployment: quản lý pod theo nhóm
- Service: cho phép truy cập đến pod

**✅ Challenge: Viết 1 Deployment + Service cho app Flask**

```
./flask
run build -> deloy
kubectl port-forward service/flask-service 5000:5000

// http://localhost:5000/
// -> Hello from Flask on Kubernetes!
```

> Hoặc không cần port-forward vì service đã để mode `NodePort` - có thể truy cập từ bên ngoài cluster

```
minikube ip
-> 192.168.49.2

-> http://192.168.49.2:30050/
-> Hello from Flask on Kubernetes!
```

**Giải thích file k8s/flask/flask-deployment.yaml**

File này chứa 2 phần chính, được phân tách bởi dấu ---:

- Deployment: Quản lý việc chạy ứng dụng Flask của bạn
- Service: Giúp người dùng truy cập vào ứng dụng Flask

Phần Deployment:

- apiVersion, kind: Cho Kubernetes biết đây là loại tài nguyên gì
- metadata.name: Tên của deployment là "flask-deployment"
- spec.replicas: 2: Tạo 2 bản sao của ứng dụng để đảm bảo tính sẵn sàng cao
- selector.matchLabels: Chọn các pod có nhãn "app: flask-app"
- template: Mô tả cách tạo pod:
  - labels: Gắn nhãn "app: flask-app" cho pod
  - containers: Chỉ định container chạy trong pod:
    - image: Sử dụng image Docker "docker.io/annt17/flask-app:1.0"
    - containerPort: Ứng dụng Flask chạy trên cổng 5000 trong container

Phần Service:

- kind: Service: Đây là tài nguyên Service trong Kubernetes
- metadata.name: Tên service là "flask-service"
- selector: Kết nối service với các pod có nhãn "app: flask-app"
- type: `NodePort:` Loại service này cho phép truy cập từ bên ngoài cluster
- ports: Cấu hình cổng:
  - port: 5000: Cổng mà service lắng nghe bên trong cluster
  - targetPort: 5000: Cổng của ứng dụng trong container
  - nodePort: 30050: Cổng mà bạn có thể truy cập từ bên ngoài cluster

Cách hoạt động

- Deployment tạo và duy trì 2 pod chạy ứng dụng Flask
- Service tạo một điểm truy cập để kết nối đến các pod
- Khi có yêu cầu đến cổng 30050 của node, nó sẽ được chuyển tiếp đến cổng 5000 của một trong các pod

# Bài 3: ConfigMap và Secret trong Kubernetes

## 1. ConfigMap là gì?

- Là một đối tượng trong Kubernetes dùng để `lưu trữ cấu hình` dưới dạng key-value, tách biệt khỏi code/app.
- Giúp bạn dễ dàng thay đổi cấu hình mà không phải build lại container image.
- Dùng để inject cấu hình vào Pod qua environment variables hoặc file.

Ví dụ tạo ConfigMap:

```
kubectl create configmap app-config --from-literal=APP_MODE=production --from-literal=LOG_LEVEL=info
```

Hoặc tạo bằng file YAML:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_MODE: "production"
  LOG_LEVEL: "info"
```

## 2. Secret là gì?

- Dùng để lưu thông tin nhạy cảm như mật khẩu, API key.
- Dữ liệu được mã hóa (base64) khi lưu trữ.
- Cách sử dụng giống ConfigMap nhưng dành cho thông tin bảo mật.

Ví dụ tạo Secret từ CLI:

```
kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASS=secret123
```

Hoặc bằng file YAML:

```
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  DB_USER: YWRtaW4=      # base64 của "admin"
  DB_PASS: c2VjcmV0MTIz  # base64 của "secret123"
```

> Bạn có thể tạo base64 bằng lệnh:

```
echo -n "admin" | base64
```

## Cách dùng ConfigMap và Secret trong Pod

**Inject qua Environment Variables (YAML):**

```
spec:
  containers:
  - name: app-container
    image: your-image
    env:
    - name: APP_MODE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_MODE
    - name: DB_PASS
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: DB_PASS
```

**Inject qua volume (file):**

```
spec:
  containers:
  - name: app-container
    image: your-image
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

**✅ Challenge:**

1. Tạo ConfigMap lưu một biến WELCOME_MSG có giá trị "Welcome to my app".
2. Sửa Deployment Flask để đọc biến này từ env và hiển thị ra / route.
3. Tạo Secret lưu mật khẩu DB.
4. Inject Secret vào container qua env và in ra log khi khởi động (hoặc debug).

> Update flask folder

```
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f flask-deployment.yaml
kubectl apply -f flask-service.yaml
```

> http://localhost:30051 → sẽ hiển thị "Welcome to my app on Kubernetes!"

# Bài 4: Volume và Mount ConfigMap/Secret dưới dạng file

## 1. Tại sao cần Volume?

- Một số app yêu cầu file cấu hình (config.yaml, .env, cert.pem, v.v.) thay vì env vars.
- Kubernetes hỗ trợ bạn `mount ConfigMap hoặc Secret dưới dạng file nhờ volume.`

## 2. Cấu trúc minh họa

Giả sử bạn có một app cần file .env hoặc `config.yaml` như sau:

```
welcome_message: Hello from file!
```

## 3. Tạo ConfigMap từ file config

Bạn có 2 cách:

**Cách 1: Dùng YAML**

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: flask-config-file
data:
  config.yaml: |
    welcome_message: Hello from file!
```

**Cách 2: Tạo từ file thật:**

```
kubectl create configmap flask-config-file --from-file=config.yaml
```

## 4. Cập nhật Deployment để mount config vào container

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-container
        image: your-dockerhub-username/flask-app:1.0
        ports:
        - containerPort: 5000
        volumeMounts:
        - name: config-volume
          mountPath: /app/config         # Mount vào thư mục này
          readOnly: true
      volumes:
      - name: config-volume
        configMap:
          name: flask-config-file
```

## 5. Cập nhật app.py để đọc file config.yaml

```
import yaml
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    try:
        with open("/app/config/config.yaml", "r") as f:
            config = yaml.safe_load(f)
            return config.get("welcome_message", "No message found")
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

## Kết quả:

- Bạn mount file config.yaml vào container.
- Flask app đọc file này mỗi lần request tới /.

## Bonus: Mount Secret dưới dạng file

Cách làm tương tự:

```
volumes:
- name: cert-volume
  secret:
    secretName: my-cert-secret

volumeMounts:
- name: cert-volume
  mountPath: /app/ssl
  readOnly: true
```

**So sánh cách tạo configMap, secret ở bài 3 (env var) và bài 4 (mount volume)**

## 🔍 So sánh: Inject bằng `env var` vs `mount volume`

| **Tiêu chí**                            | **Env var (`env:`)**       | **Volume mount (`volumeMounts:`)**                 |
| --------------------------------------- | -------------------------- | -------------------------------------------------- |
| **Dễ sử dụng**                          | ✅ Rất dễ, ngắn gọn        | ❌ Hơi dài dòng hơn                                |
| **App yêu cầu file cấu hình**           | ❌ Không dùng được         | ✅ Bắt buộc dùng                                   |
| **Có thể reload cấu hình khi thay đổi** | ❌ Không (cần restart Pod) | ✅ Có thể nếu app hỗ trợ đọc lại file (hot reload) |
| **Quản lý file cấu hình phức tạp**      | ❌ Không phù hợp           | ✅ Rất tốt                                         |
| **App bên thứ ba (open-source)**        | ❌ Nhiều app không đọc env | ✅ Hầu hết đều có option chỉ định đường dẫn config |

# Bài 7: Hiểu và sử dụng Namespace trong Kubernetes

> Namespace trong Kubernetes giúp bạn chia cụm (cluster) thành các vùng độc lập nhau để quản lý resource tách biệt.

**🧠 Hình dung:**
Bạn có một cluster K8s dùng chung cho nhiều mục đích:

- `dev` cho lập trình viên
- `staging` để QA test
- `prod` để chạy thật

> Nếu mọi Pod, Service, ConfigMap, Secret... đều nằm cùng namespace default, sẽ:

- Khó quản lý
- Dễ trùng tên
- Dễ xung đột
- Dễ deploy nhầm môi trường

## ✅ Lợi ích của Namespace:

| **Tính năng**               | **Lợi ích**                                    |
| --------------------------- | ---------------------------------------------- |
| **Cách ly tài nguyên**      | `appA` ở `dev` không ảnh hưởng `appA` ở `prod` |
| **Gắn quota riêng biệt**    | Giới hạn CPU/RAM mỗi namespace                 |
| **Gắn Role/Access Control** | Team dev không truy cập được `prod`            |
| **Xoá sạch một môi trường** | `kubectl delete namespace dev` là xoá hết      |

## Cách dùng Namespace

1. Tạo namespace

```
kubectl create namespace dev
```

2. Deploy vào namespace

> Khi apply YAML:

```
kubectl apply -f my-app.yaml --namespace dev
```

> Hoặc trong YAML, bạn thêm phần:

```
metadata:
  name: flask-app
  namespace: dev
```

3. Với Helm

> Khi cài:

```
helm install flask-app ./flask-chart --namespace dev --create-namespace
```

> --create-namespace: tạo namespace nếu chưa có
>
> --namespace dev: Helm sẽ tạo mọi thứ trong namespace dev

4. Kiểm tra resource theo namespace

```
kubectl get all -n dev
```

## Tổng kết bạn cần nhớ

- Namespace giúp phân vùng logic trong cùng 1 cluster
- Tránh xung đột tài nguyên khi deploy nhiều môi trường
- Helm cực kỳ phù hợp để deploy nhiều instance với namespace riêng biệt
