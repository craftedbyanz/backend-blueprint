# Dựng Redis local Doker

1. `Dockerfile`

```
FROM redis:latest
```

2. Run

```
docker build -t redis-annt .
```

3. Kiểm tra image đã thành công:

```
docker images
```

4. Run image thành container:

```
docker run --name redis-annt -p 6379:6379 -d redis-annt
```

5. Kiểm tra container thành công:

```
docker ps
```
