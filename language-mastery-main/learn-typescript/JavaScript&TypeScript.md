# JavaScript & TypeScript

## 1. "let" and "const"

- Cho phép định nghĩa các hằng số và biến
- const biến không thể thay đổi
- let biến có thể thay đổi được

## 2. Arrow Functions

```
const add = (a: number, b: number) => {
    return a + b;
}
```

## 3. The Spread Operator (...)

- Tính năng hữu ích liên quan đến array và object và cách ta có thể truy xuất data được lưu trữ trong array và object

```
const hobbies = ['sports', 'cooking']
const activeHobbies = ['hiking']

# giả sử muốn push thêm các phần tử của hobbies vào activeHobbies
activeHobbies.push(hobbies)
# nếu như trên ta sẽ được 1 array lồng array không đúng target mong muốn

# ta muốn push nhận các giá trị đơn lẻ

activeHobbies.push(hobbies[0])
activeHobbies.push(hobbies[1])
# cách trên thì hơn cồng kềnh và nếu nhiều phần tử thì sao?

# Sử dụng toán tử Spread
activeHobbies.push(...hobbies)
# or
const activeHobbies = ['hiking', ...hobbies]

=> Output: activeHobbies = ['hiking', 'sports', 'cooking']
```

## 4. Rest Parameters

```
const add = (...numbers: number[]) => {
    // todo
}

const addedNumbers = add(5, 1, 10, 9)
console.log(addedNumbers)
```

Dùng toán tử "Rest" ta chỉ cần 1 biến để hợp nhất các tham số đầu vào của hàm add

## 5. Array & Object Destructuring

```
const hobbies = ['sports', 'cooking']

const [hobby1, hobby2] = hobbies
```

Lấy ra các phần tử và gán vào các hằng số nà ta define
