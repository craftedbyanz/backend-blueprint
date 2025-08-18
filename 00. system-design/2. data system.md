## Data in distributed system

- Hệ thống hiện nay là `data intensive` - các hệ thống xử lý data rất là nhiều
  - Nó phải collect, process, generate data lớn, phức tạp và data thay đổi rất là nhanh

## Replication

- Replication nghĩa là giữ bản copy của 1 data trên nhiều máy khác nhau kết nối thông qua network

### Lợi ích:

- Nó sẽ giữ data gần user(địa lý) -> tăng tốc độ response
- tăng tính availability: Khi 1 data bị hỏng ta vẫn còn data khác để hệ thống xử lý
- phục vụ việc scale - reade data tập trung ở 1 máy

### Các kĩ thuật:

1. Single leader replication:

- Có các node replica. Có 1 node là `leader` và các node khác là `followers`
- `Write`: Mỗi `write req từ client` sẽ đi vào `leader`. Và leader sẽ write data đó vào các follers khác (copy data leader sang followers)
- `Read`: Có thể đọc từ bất kì node nào kể cả node leader

2. Multi-leader replication:

- Phức tạp hơn được dùng ở nhưng nơi có rất nhiều data, cty lớn có nhiều data center
- Nó giống như single leader nhưng khác là bây giờ sẽ có nhiều leaders và `mỗi leaders này sẽ ở data center khác nhau`
- `Write`: Có thể write ở leader nào cũng được.

  - Leader được write sẽ lưu ở storage của leader đó.
  - Sau đó communicate đến các followers khác và `leaders khác`.
  - Các leader khác sẽ proces write và replica vào các followers của nó

- `Read`: Có thể đọc từ bất kì node nào kể cả node leader
- Vậy có issue gì xảy ra?:
  - Maybe sẽ có conflict data xảy ra giữa các leaders

3. Leaderless replication:

- Không có leader.
- Node nào cũng có thể phục vụ `write request`. Khi node nào đc write sẽ communicate với các node khác để đồng bộ data
- Read có thể đọc từ bất kì node nào

## Data Partitioning

- Khi 1 data số lượng rất là lớn thì server không thể store được hết data set được nữa. Để lưu trữ được hết đống data đó -> partitioning or sharding.
- Data partitioning (or sharding):
  - Chia nhỏ data đó thành các khúc nhỏ
  - Mỗi khúc data là 1 partition
  - Mỗi row trong db nó chỉ thuộc về đúng 1 partition thôi

### Lợi ích:

- Scalability

### Note:

- Partition (Có 1 đống data sau đó cắt nhỏ ra và chỉ chứa 1 phần data trong 1 máy) khác Replication - (Data 1 máy copy sang 1 máy khác)

### Chiến lược sharding:

1. Key-range based sharding:
2. Hash-based sharding:
