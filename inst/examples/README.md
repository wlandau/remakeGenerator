These are the `remakeGenerator` examples managed by functions `example_remakeGenerator()` and `list_examples_remakeGenerator()`. To add your own example, simply make a new folder in `inst/examples` and put your files inside. If you create (and hopefully populate) `inst/examples/my_example`, then, `"my_example"` will be automatically included in the output of `list_examples_remakeGenerator()`, and `example_remakeGenerator(example = "my_example")` will copy `inst/examples/my_example` to the current working directory of your R session.