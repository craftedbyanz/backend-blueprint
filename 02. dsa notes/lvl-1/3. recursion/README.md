### Recursion

- là giải pháp để giải quyết các bài toán có thể chia thành các bài toán con có cấu trúc tương tự nhau.
- có 2 phần:

  - base case: điểm dừng
  - recursive case: điểm gọi lại chính nó

> Trong các bài toán đệ quy, chúng ta cần phải xác định được base case và recursive case.

- Trong lập trình, recursion là một kỹ thuật cho phép một hàm gọi lại chính nó.

- Ứng dụng: sorting algorithms, tree traversal, graph traversal, dynamic programming, etc.

### So sánh recursion và iteration

- Recursion:

  - Dễ viết code
  - Dễ hiểu

- Iteration:
  - Tốc độ nhanh hơn
  - Dễ debug

### Example

```
def factorial(n: int) -> int:
  # base case
  if n == 0:
    return 1
  
  # recursion
  retrun n * factorial(n - 1)
```

- Base case: stopping condition, allows recursion to terminate

- Recursive: breaks problem into smaller ones