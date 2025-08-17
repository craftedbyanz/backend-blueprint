### String

- String là immutable (đối tượng không thể bị thay đổi sau khi được tạo ra)
```
s = "abc"
s[0] = "x"   # ❌ lỗi, không thể gán
```

- Vì vậy `string` khi đã được tạo ra, ta không thể thay đổi trực tiếp nội dung của nó.

-> Nên để `thay đổi` 1 string:

- tạo một string mới để thay đổi

> trong python không có string builder.
