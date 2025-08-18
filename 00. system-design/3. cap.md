## CAP theorem

- Setup:
  - có 2 server G1 và G2
  - cả 2 server để keep track 1 biến v0
  - 1 client
  - 3 đối tượng client, G1, G2 communicate với nhau qua network (network có thể bị lỗi)

### Consistency (C):

- Mọi node đều thấy `cùng một dữ liệu tại cùng một thời điểm` (tương tự như database đơn, atomic).
- Điều này nghĩa là các users có thể đọc/ghi từ bất kì ở node nào và sẽ cùng nhận được data giống nhau.
- Data consistency trên các node với nhau

### Availability (A):

- Mỗi request đều nhận được phản hồi (success hoặc failure), `không bị treo hay timeout.`
- Lúc nào hệ thống cũng có thể phục vụ được các request tới
- `no downtime`

### Partition tolerance (P)

- Hệ thống `tiếp tục hoạt động ngay cả khi có sự cố mạng`, gây mất kết nối giữa các node trong hệ thống.
- `Thường luôn phải` có vì trong các hệ thống lúc nào cũng có thể sự về communicate network cũng có thể xảy ra

### Các loại hệ thống theo CAP

| Loại hệ thống                       | Chọn yếu tố nào                                                          | Ví dụ                               |
| ----------------------------------- | ------------------------------------------------------------------------ | ----------------------------------- |
| **CP (Consistency + Partition)**    | Ưu tiên dữ liệu nhất quán, chấp nhận downtime khi cần                    | HDFS, MongoDB (configurable), HBase |
| **AP (Availability + Partition)**   | Ưu tiên phản hồi nhanh, chấp nhận dữ liệu không nhất quán tạm thời       | Cassandra, Couchbase, DynamoDB      |
| **CA (Consistency + Availability)** | Chỉ đạt được khi **không có partition** — rất khó trong thực tế phân tán | Database đơn máy như PostgreSQL     |

> Thường trong 3 yếu tố mình chỉ có thể thỏa mãn 2/3 yếu tố trên thôi.
>
> Thường P là phải có rồi nên ta chỉ chọn giữ A và C thêm thôi

## Consensus in DB (Sự đồng thuận)

Consensus use case:

1. Bầu ra leader trong các nodes
2. Data replication
3. Distributed file system

### Có 2 thuật toán xử lý `consensus`:

- `PAXOS`
- `RAFT`

### Quorum ???
