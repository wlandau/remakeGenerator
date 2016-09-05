## example data frames
example_datasets = function(){
  data.frame(
    target = strings(data1, data2),
    command = strings(df1(n = 10), df2(n = 20)),
    check = c(T, F)
  )
}

example_analyses = function(){
  data.frame(
    target = strings(analysis1, analysis2),
    command = strings(analyze1(..dataset..), analyze2(..dataset..)),
    stringsAsFactors = F
  )
}
