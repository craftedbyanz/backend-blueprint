## What is distributed system
- Là tập hợp của nhiều chương trình và trên nhiều node khác nhau kết nối với nhau qua network

## Các đặc tính của distributed system
1. Scalability
2. Reliability
3. Availability
4. EEiciency
5. Serviceability or Manageability

### Scalability:
- Khả năng 1 system có thể grow lên để mà có thể phục vụ nhiều yêu cầu hơn
- Demand can be:
  - tăng requests per second của server
  - tăng qps

`Các kĩ thuật để giúp Scalability:`
- Vertical scaling:
  - add ram
  - add cpu
- Horizontal scaling
  - add node, instances

Example:

    - Pub/Sub model
    - Datbase sharding
