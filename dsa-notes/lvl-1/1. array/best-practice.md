## Tư duy trước khi code
- Đọc kỹ đề, phân biệt mảng `sorted` hay `unsorted` → chọn thuật toán phù hợp
- Có cần in-place không? Có thể tạo mảng mới không?
- Có cần kết quả duy nhất hay tất cả? Có cần sắp xếp?

## TIPS & TRICKS
| Mẹo                   | Mô tả                                     |
| --------------------- | ----------------------------------------- |
| **Không vội tối ưu**  | Luôn thử brute-force để hiểu logic        |
| **In giữa vòng lặp**  | Debug bằng cách `print(i, nums[i])`       |
| **Copy mảng khi cần** | `arr.copy()` để tránh ảnh hưởng mảng gốc  |
| **Edge case**         | Test input rỗng, 1 phần tử, trùng giá trị |


## KHI GẶP BÀI ARRAY KHÓ?
1. Viết brute-force → chạy thử → phân tích chậm ở đâu
2. Tìm pattern:
    - Có “tìm tổng” → hash
    - Có “dãy con” → sliding window / prefix sum
    - Có “tìm cấu trúc” → two pointers
3. Cố gắng nghĩ O(n) trước khi sang O(n log n) hoặc O(n²)

## I. CÁC DẠNG BÀI ARRAY PHỔ BIẾN

| Dạng bài                            | Kỹ thuật chính                   |
| ----------------------------------- | -------------------------------- |
| Tìm phần tử                         | Duyệt tuyến tính / Binary Search |
| Tìm tổng/kết quả thoả mãn điều kiện | Two pointers / Hash              |
| Xử lý tại chỗ (in-place)            | Duyệt và thao tác mảng gốc       |
| Đếm, gom nhóm, lọc                  | HashMap / Sort                   |
| Trượt cửa sổ (sliding window)       | Tối ưu trên mảng con             |
| Prefix Sum / Kadane                 | Tính tích lũy / dãy con          |

## II. TEMPLATE CODE CHUẨN THEO DẠNG

### 1. Two Pointers (Sorted array hoặc dạng tìm cặp)
```
def two_pointers(arr):
    left, right = 0, len(arr) - 1
    while left < right:
        total = arr[left] + arr[right]
        if total == 0:
            return [left, right]
        elif total < 0:
            left += 1
        else:
            right -= 1
```

### 2. Sliding Window (cửa sổ trượt cố định hoặc biến đổi)
```
def sliding_window(s, k):
    window_sum = 0
    max_sum = 0
    left = 0

    for right in range(len(s)):
        window_sum += s[right]

        if right - left + 1 > k:
            window_sum -= s[left]
            left += 1

        max_sum = max(max_sum, window_sum)

    return max_sum
```

### 3. Prefix Sum / Kadane's Algorithm (Dãy con lớn nhất)
```
def max_subarray(nums):
    curr_sum = max_sum = nums[0]
    for num in nums[1:]:
        curr_sum = max(num, curr_sum + num)
        max_sum = max(max_sum, curr_sum)
    return max_sum
```

### 4. HashSet / HashMap lookup (tìm phần tử cặp hoặc lặp)
```
def two_sum(nums, target):
    seen = {}
    for i, num in enumerate(nums):
        diff = target - num
        if diff in seen:
            return [seen[diff], i]
        seen[num] = i
```

### 5. In-place array updates (xử lý tại chỗ)
```
def move_zeroes(nums):
    insert_pos = 0
    for num in nums:
        if num != 0:
            nums[insert_pos] = num
            insert_pos += 1
    while insert_pos < len(nums):
        nums[insert_pos] = 0
        insert_pos += 1
```

### 6. Sort + Two Pointers (3Sum, 4Sum...)
```
def three_sum(nums):
    nums.sort()
    res = []
    for i in range(len(nums)):
        if i > 0 and nums[i] == nums[i - 1]:
            continue
        target = -nums[i]
        left, right = i + 1, len(nums) - 1
        while left < right:
            s = nums[left] + nums[right]
            if s == target:
                res.append([nums[i], nums[left], nums[right]])
                left += 1
                right -= 1
                while left < right and nums[left] == nums[left - 1]: left += 1
                while left < right and nums[right] == nums[right + 1]: right -= 1
            elif s < target:
                left += 1
            else:
                right -= 1
    return res
```

### 7. Prefix HashMap (dạng đếm tổng dãy con)
```
def subarray_sum(nums, k):
    count = 0
    curr_sum = 0
    prefix = {0: 1}

    for num in nums:
        curr_sum += num
        if curr_sum - k in prefix:
            count += prefix[curr_sum - k]
        prefix[curr_sum] = prefix.get(curr_sum, 0) + 1

    return count
```

### 8. Sliding Window nâng cao (Minimum Window Substring)
```
from collections import Counter

def min_window(s, t):
    if not s or not t:
        return ""
    
    count_t = Counter(t)
    window = {}
    have, need = 0, len(count_t)
    res, res_len = [-1, -1], float("inf")
    left = 0

    for right, c in enumerate(s):
        window[c] = window.get(c, 0) + 1

        if c in count_t and window[c] == count_t[c]:
            have += 1

        while have == need:
            if (right - left + 1) < res_len:
                res = [left, right]
                res_len = right - left + 1

            window[s[left]] -= 1
            if s[left] in count_t and window[s[left]] < count_t[s[left]]:
                have -= 1
            left += 1

    l, r = res
    return s[l:r+1] if res_len != float("inf") else ""
```