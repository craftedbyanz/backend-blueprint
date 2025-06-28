# 1. Installing Typescript

```
npm install -g typescript
```

```
tsc <file_name> # Compile .ts -> .js
```

# TypeScript Basics & Basic Types

## "any" types

`any` là 1 kiểu dữ liệu linh hoạt mà có thể đại diện cho bất kì kiểu dữ liệu nào.

## Union types

`union` là kiểu dữ liệu dùng để định nghĩa 1 biến có thể mang giá trị thuộc `nhiều kiểu dữ liệu khác nhau`. Là 1 công cụ mạnh mẽ để xử lý các trường hợp khi biến có thể mang giá trị từ nhiều loại khác nhau.

Điều này cho phép ta làm việc linh hoạt với biến có thể nhận giá trị từ 1 tập hợp các kiểu khác nhau.

```
// Biến age có thể là number hoặc string
let age: number | string;

age = 25;       // OK, age là một số
age = "twenty"; // OK, age là một chuỗi

// Hàm có thể nhận đối số là number hoặc string
function displayInfo(value: number | string): void {
    console.log(value);
}

displayInfo(30);        // OK, đối số là một số
displayInfo("thirty");  // OK, đối số là một chuỗi

// Kiểm tra kiểu tại thời điểm biên dịch
if (typeof age === "number") {
    // Ở đây, TypeScript hiểu rằng age là number
    console.log("Age is a number");
} else {
    // Ở đây, TypeScript hiểu rằng age là string
    console.log("Age is a string");
}
```

## Literal types

`literal` là 1 loại dữ liệu đặc biệt mà chỉ cho phép `1 biến or tham số nhận 1 giá trị cụ thể`, chứ không phải 1 tập hợp các giá trị

`literal` thường dùng để mô hình hóa các giá trị cố định, `ví dụ các hằng số or các giá trị biết trước`

```
let status: "success" | "error"; // status chỉ có thể là "success" hoặc "error"
status = "success"; // OK
status = "pending"; // Lỗi biên dịch, vì "pending" không thuộc kiểu literal

// Sử dụng literal types trong tham số hàm
function printColor(color: "red" | "blue" | "green"): void {
    console.log(color);
}

printColor("red");    // OK
printColor("yellow"); // Lỗi biên dịch, vì "yellow" không thuộc kiểu literal
```

## Type aliasses / Custom types

Có thể sử dụng `aliases` để tạo ra các kiểu dữ liệu tùy chỉnh, còn được gọi là `custom types`

Type aliases giúp rút ngắn gọn và tái sử dụng định nghĩa kiểu dữ liệu, giúp mã dễ đọc và bảo trì

```
// Định nghĩa type alias cho kiểu dữ liệu Person
type Person = {
    name: string;
    age: number;
    address?: string; // Thuộc tính này là tùy chọn
};

// Sử dụng type alias Person
let user: Person = {
    name: "John",
    age: 25,
    address: "123 Main St"
};

// Type alias cho union type
type Result = "success" | "error";

// Sử dụng type alias Result
let status: Result = "success"; // OK

// Type alias cho function
type MathFunction = (x: number, y: number) => number;

// Sử dụng type alias MathFunction
let add: MathFunction = (a, b) => a + b; // OK

// Type alias cho generic type
type Pair<T> = {
    first: T;
    second: T;
};

// Sử dụng type alias Pair với generic type là string
let pair: Pair<string> = { first: "hello", second: "world" }; // OK
```

## Function types & Callbacks

Có thể sử dụng kiểu dữ liệu cho hàm (function types) để mô tả kiêu dữ liệu của 1 hàm. Điều này bao gồm cả kiểu trả về cả hàm va kiểu của các tham số hàm or giá trị trả về của hàm.

`Kiểu dữ liệu cho hàm`

```
// Kiểu dữ liệu cho hàm add
type AddFunction = (a: number, b: number) => number;

// Biến sum có kiểu dữ liệu là AddFunction
let sum: AddFunction = (x, y) => x + y;

console.log(sum(3, 5)); // Kết quả: 8
```

`Callbacks`

```
// Kiểu dữ liệu cho hàm callback
type CallbackFunction = (result: string) => void;

// Hàm executeWithCallback nhận một hàm callback và gọi nó với một giá trị
function executeWithCallback(callback: CallbackFunction): void {
    // Thực hiện một số công việc và gọi callback với kết quả
    let result = "Task completed successfully!";
    callback(result);
}

// Sử dụng hàm executeWithCallback với một callback cụ thể
executeWithCallback((result) => {
    console.log(result); // Kết quả: Task completed successfully!
});
```

## unknown type

`unknown` kiểu dữ liệu đại diện cho 1 loại dữ liệu mà chúng ta không biết là gì. `unknown` tương tự như `any` nhưng nó yêu cầu ta thực hiện kiểm tra kiểu trước khi sử dụng giá trị của nó, `trong khi kiểu any không yêu cầu điều này.`

```
let userInput: unknown;

userInput = 5;
userInput = "Hello";

// TypeScript yêu cầu kiểm tra kiểu trước khi sử dụng giá trị của unknown
if (typeof userInput === "string") {
    let strLength: number = userInput.length; // OK, vì đã kiểm tra kiểu
}

// Hoặc sử dụng kiểu casting
let strLength: number = (userInput as string).length; // OK, vì đã thực hiện kiểm tra kiểu
```

Kiểu unknown là hữu ích khi bạn có một biến có thể mang giá trị từ nhiều loại khác nhau, và bạn muốn áp dụng kiểm tra kiểu cụ thể trước khi sử dụng nó. Nó giúp tăng tính an toàn của mã và giảm khả năng xuất hiện lỗi kiểu dữ liệu không mong muốn.

Một điểm khác biệt quan trọng giữa any và unknown là khi bạn sử dụng unknown, TypeScript sẽ yêu cầu bạn thực hiện kiểm tra kiểu hoặc sử dụng kiểu casting trước khi thực hiện bất kỳ thao tác cụ thể nào với giá trị đó, giữ cho tính chính xác của kiểu dữ liệu.

## never type

`never` là 1 kiểu dữ liệu đặc biệt được sử dụng `mô tả các hàm không bao giờ trả về giá trị or biểu thức không bao giờ đặt được.`

Nó thường được sử dụng trong các trường hợp như các hàm ném ra ngoại lệ or trong các hàm với vòng lặp vô tận,

`Hàm không bao giờ trả về giá trị:`

```
function throwError(message: string): never {
    throw new Error(message);
}

// Hàm throwError sẽ ném ra một lỗi và không bao giờ trả về giá trị
const result: never = throwError("Something went wrong");
```

`Biểu thức không bao giờ đạt được:`

```
function infiniteLoop(): never {
    while (true) {
        // Vòng lặp vô hạn không bao giờ kết thúc, nên hàm không bao giờ trả về
    }
}

// Hàm infiniteLoop không bao giờ trả về giá trị
const unreachableCode: never = infiniteLoop();
```

> never thường được sử dụng để đánh dấu các điểm trong mã nguồn mà TypeScript hiểu là không bao giờ đạt được. Điều này giúp TypeScript kiểm tra tính đầy đủ của mã nguồn và đảm bảo rằng các giá trị không mong muốn không được sử dụng.
