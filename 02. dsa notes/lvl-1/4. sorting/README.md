### Sorting

There are a lot sorts of sorting algorithms.

- `bubble sort`
- insertion sort
- selection sort
- `quick sort`
- `merge sort`
- heap sort
- counting sort
- radix sort

### Bubble sort - sắp xếp nổi bọt
- Là thuật toán đơn giải nhất
- 2 vòng, duyệt từ trái sang phải, mục tiêu đưa dần phần tử lớn nhất về cuối mảng

```
- time: O(n^2)
- space: O(1)

static void bubbleSort(int arr[], int n) {
    int i, j, temp;

    for (i = 0; i < n - 1; j++) {
        for (j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                // swap arr[j] and arr[j+1]
                temp= arr[j];
                arr[j] = arr[j + 1]
                arr[j + 1] =  temp
            }
        }
    }
}
```

### Merge sort: chia để trị
- Mỗi bước chia đôi mảng to thành 2 phần
- Sort trên mỗi nửa - dùng đệ quy để sort nửa đầu và nửa cuối -> mỗi nửa được sắp xếp tăng dần rồi
- Từ 2 mảng con được sorted ta sẽ trộn (merge) lại thành 1 mảng lớn được sắp xếp
- Quá trình này sẽ lặp lại đến khi mảng được sorted tất cả
- Nói sâu hơn về bước trộn:
    - Chúng ta có 2 con trỏ của 2 mảng cần merge (mỗi con trỏ ở 1 mảng)
    - Chúng ta so sánh 2 phần tử của 2 con trỏ đang trỏ tới
    - Phần tử nào bé hơn thí đẩy vào 1 mảng mới

```
void mergeSort(int arr[], int l, int r) {
    if (l < r) {
        // Find the middle point
        int m = l + (r - l) / 2;

        // Sort first and second halves
        mergeSort(arr, l, m);
        mergeSort(arr, m + 1, r);

        // Merge the sorted halves
        merge(arr, l, m, r)
    }
}
```

```
- time: O(NlogN)
- space: O(N)
```

### Quick sort
- Ý tưởng vẫn là từ 1 mảng to chia thành 2 phần con để sắp xếp nhưng cách chia sẽ hơi khác 1 chút
- với merge sort là chia ra 2 độ dài bằng nhau rồi đệ quy sắp xếp rồi trộn vào
- với quick sort thì ta sẽ chọn ra 1 pivot (1 điểm bất kì để chia mảng)
- sau đo đưa tất cả các phần tử bé hơn điểm phần tử pivot này lên trước, tất cả những phần tử nào lớn hơn thì ở đằng sau pivot
- sau đó mình sẽ gọi đệ quy để sắp xếp phần bé hơn và phần lớn hơn của pivot (gọi đệ quy xử lý từng nửa một)

```
void quickSort(int arr[], int l, int r) {
    if (l > r) return;

    // pi is partitioning index (Tìm điểm pivot để phân mảng thành 2 phần)
    int pI = partition(arr, l, r)

    // separately sort elements before
    // partition and after partition
    // gọi đệ quy để sắp xếp 2 nửa trái phải
    quickSort(arr, l, pI - 1)
    quickSort(are, pI, r)
}
```

```
int partition(int arr[], int l, int r) {
    // choosing the pivot
    int pivot = arr[r]

    // index of next smaller element position
    int i = l
    for(int j = 0; j < r; j ++) {
        // If current element is smaller than the pivot
        if (arr[j] < pivot) {
            // swap this element to the current index
            swap(arr, i, j)
            i++
        }
    }

    swap(arr, i, r)
    return i
}
```

- time:
    - average case: O(NlogN)
    - worst case: O(n^2)

- space: O(1)