# Bài 5: Giới thiệu Helm – Trái tim DevOps với K8s

## Heml là gì

- Helm là `package manager` cho Kubernetes
- Tương tự như: apt, brew, pip
- Dành riêng cho k8s
  - Gói các YAML thành 1 `chart`
  - Cho phép `tái sử dụng, biến động cấu hình, triển khai theo môi trường (dev, staging, prod)`

## Helm chart gồm những gì?

Một Helm chart là một thư mục với cấu trúc như sau:

```
my-app/
├── Chart.yaml            # Metadata của chart
├── values.yaml           # Biến cấu hình mặc định
├── templates/            # Các file YAML template
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ...
```

👉 values.yaml là nơi bạn định nghĩa:

```
replicaCount: 2
image:
  repository: your-dockerhub/flask-app
  tag: "1.0"
service:
  port: 5000
```

Còn templates/deployment.yaml có thể dùng cú pháp biến kiểu Go template:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment
spec:
  replicas: {{ .Values.replicaCount }}
  ...
```

**Lợi ích của Helm:**

- `Tái sử dụng chart:` Một chart có thể dùng cho nhiều môi trường
- `Cấu hình linh hoạt:` Dễ dàng thay đổi image, replica, env, v.v.
- `Triển khai versioned:` Helm hỗ trợ rollback, upgrade dễ dàng
- `Quản lý package từ repo:` Có thể dùng chart từ Bitnami, ArtifactHub, v.v.

# Bài 6: Thực hành tạo Helm Chart cho Flask App

## Mục tiêu

Tạo Helm chart cho app Flask mà bạn đã triển khai trước đó bằng YAML.

**Bước 1: Tạo chart mới**

```
helm create flask-chart
```

> Nó sẽ tạo cấu trúc như sau:

```
flask-chart/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── ...
```

**Bước 2: Dọn dẹp file không cần thiết**

> Xóa những file mặc định mà ta chưa cần:

```
cd flask-chart/templates
rm -f ingress.yaml hpa.yaml tests/* serviceaccount.yaml
```

**Bước 3: Cập nhật file values.yaml**
Đây là nơi chứa cấu hình mặc định có thể ghi đè:

```
replicaCount: 1

image:
  repository: your-dockerhub-username/flask-app
  tag: "1.0"
  pullPolicy: IfNotPresent

service:
  type: NodePort
  port: 5000
  nodePort: 30051

env:
  WELCOME_MSG: "Hello from Helm"
  DB_PASSWORD: "secret_password"
```

**Bước 4: Template hóa deployment.yaml**
Sửa `templates/deployment.yaml` thành:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
      - name: flask
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: 5000
        env:
        - name: WELCOME_MSG
          value: {{ .Values.env.WELCOME_MSG | quote }}
        - name: DB_PASSWORD
          value: {{ .Values.env.DB_PASSWORD | quote }}
```

**Bước 5: Template hóa service.yaml**

```
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-service
spec:
  type: {{ .Values.service.type }}
  selector:
    app: {{ .Release.Name }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: 5000
    nodePort: {{ .Values.service.nodePort }}
```

**Bước 6: Cài thử Helm chart**

```
helm install flask-app ./flask-chart
```

✅ Mọi tài nguyên sẽ được tạo:

- Deployment
- Service
- Với cấu hình từ values.yaml

**Bước 7: Cập nhật cấu hình (Helm upgrade) -> test thay đổi**
Giả sử bạn muốn đổi WELCOME_MSG:

1. Mở values.yaml, đổi dòng:

```
WELCOME_MSG: "Hello from upgraded Helm!"
```

2. Chạy upgrade:

```
helm upgrade flask-app ./flask-chart
```

**Bước 8: Gỡ ứng dụng**

```
helm uninstall flask-app
```

# Bài 12: Helm advance

## Helm là gì? Khác gì với kubectl apply?

- `kubectl apply:`
  - Bạn viết file YAML cụ thể rồi apply trực tiếp vào K8s, file YAML này tĩnh, không linh hoạt.
- `Helm:` Là một package manager cho Kubernetes, giúp bạn:
  - Viết các manifest theo dạng `template` có biến, logic điều kiện.
  - `Quản lý version`, cài đặt, nâng cấp, xóa ứng dụng dễ dàng bằng lệnh Helm.
  - Quản lý cấu hình linh hoạt qua file values.yaml.
  - Chia sẻ và sử dụng lại các chart (gói manifest) từ các Helm repo như Bitnami, ArtifactHub.

## Cấu trúc cơ bản của 1 Helm Chart

```
flask-chart/
├── Chart.yaml         # Metadata chart (tên, version, description)
├── values.yaml        # File cấu hình mặc định (biến)
├── templates/         # Thư mục chứa các file YAML template
│   ├── deployment.yaml
│   ├── service.yaml
│   └── _helpers.tpl  # file template helper (tuỳ chọn)
└── charts/            # Thư mục chứa chart phụ thuộc (dependencies)
```

## Các thành phần chính:

- `Chart.yaml:` Thông tin cơ bản về chart.
- `values.yaml:` Giá trị mặc định cho biến trong template.
- `templates/:` Các manifest YAML có chứa biến Helm, sẽ được render khi deploy.

## Cách Helm template hoạt động

- Bạn viết các file YAML trong templates/ với biến như {{ .Values.image.repository }}.
- Khi chạy lệnh helm install, Helm sẽ:
  - Đọc values.yaml (hoặc file values bạn truyền vào).
  - Render template ra file YAML hoàn chỉnh.
  - Áp dụng manifest đã render vào cluster.

## Các cú pháp Helm template phổ biến

- `Biến:` {{ .Values.someKey }}
- If condition:

```
{{- if .Values.someFlag }}
# manifest code ở đây
{{- end }}
```

- With:

```
{{- with .Values.service }}
port: {{ .port }}
{{- end }}
```

- Range (vòng lặp):

```
{{- range .Values.ports }}
- name: {{ .name }}
  containerPort: {{ .port }}
{{- end }}
```

## Các lệnh Helm cơ bản

```
# Cài mới chart
helm install release-name ./flask-chart

# Upgrade (cập nhật):
helm upgrade release-name ./flask-chart

# Xóa release:
helm uninstall release-name

# Render template ra YAML (xem trước):
helm template release-name ./flask-chart
```
