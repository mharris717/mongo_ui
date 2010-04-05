Jaml.register("array-entry-row",function(el) {
    tr(
        td(2),
        input({type: 'text', value: el})
    )
})

Jaml.register("array-entry",function(arr) {
    Jaml.render('array-entry-row',arr)
})