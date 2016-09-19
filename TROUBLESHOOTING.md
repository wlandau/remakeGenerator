# Troubleshooting

The usage of [`remake`](https://github.com/richfitz/remake) and dependent packages is not always obvious. For example, to pass a character literal to a command, [use the `I()` function](https://github.com/richfitz/remake/issues/58).

```r
commands(my_target = my_function(I("character_literal")))
```

In addition, [commands cannot be nested](https://github.com/richfitz/remake/issues/86). For example, instead of `commands(my_target = f1(f2(arg)))`, either write

```r
commands(my_target = f1(tmp), tmp = f2(arg))
```

or

```r
commands(my_target = g(arg))
```

where `g(arg)` is just `f1(f2(arg))`.

If you encounter additional problems, please read the [`remake` issues](https://github.com/richfitz/remake/issues) and the [`remakeGenerator` issues](https://github.com/wlandau/remakeGenerator/issues) first, taking care to search the closed issues as well. Please submit bugs and questions as [`remakeGenerator` issues](https://github.com/wlandau/remakeGenerator/issues).
