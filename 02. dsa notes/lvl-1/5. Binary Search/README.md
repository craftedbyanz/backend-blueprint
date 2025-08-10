### Binary Search

Binary search dùng với mảng đã được sắp xếp.
-> tận dùng thông tin `mảng đã được sắp xếp` để giảm thời gian tìm kiếm.

Idea:

- Lợi dụng thông tin mảng đã được sắp xếp để chia nhỏ dần miền tìm kiếm.
- Time complexity: O(logn)

#### Điều kiện áp dụng:

- Mảng đã `được sắp xếp`.
- Không có giá trị trùng lặp.
- Có thể access phần tử trong thời gian O(1) -> thì mới đạt được O(logN). ex: array, sring, list, ...
- Các cấu trúc: LinkedList, Queue, Stack, ... thì không support random access phần tử trong thời gian O(1). -> khó áp dụng `binary search`.

#### Các bước thực hiện:

- B1: Khởi tạo left = 0, right = n - 1.
- B2: Tính mid = (left + right) / 2.
- B3: So sánh giá trị tại mid với target.
  - Nếu giá trị tại `mid == target -> return mid.`
  - Nếu giá trị tại `mid > target -> right = mid - 1.`
  - Nếu giá trị tại `mid < target -> left = mid + 1.`
    : Lặp lại B2 và B3 cho đến khi `left > right`.
    : Nếu không tìm thấy target -> return -1.
- B4: Trả về kết quả.

### Implementation in Python

```python
def binary_search(arr, target):
    left, right = 0, len(arr) - 1
    while left <= right:
        mid = left + (right - left) // 2

        # check if target is present at mid
        if arr[mid] == target:
            return mid
        # If target greater, ignore left half
        elif arr[mid] > target:
            right = mid - 1
        # If target is smaller, ignore right half
        else:
            left = mid + 1
    # If we reach here, then the element was not present
    return -1

```

### Application

- Tìm kiếm trong mảng đã được sắp xếp.
- tìm số nhỏ nhất lớn hơn hoặc bằng target.

### Chú ý:

- sử dụng hàm lower_bound() và upper_bound() để tìm kiếm phần tử lớn nhất nhỏ hơn hoặc bằng target và phần tử nhỏ nhất lớn hơn hoặc bằng target.
