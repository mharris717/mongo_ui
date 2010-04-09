Jaml.register('array-entry-row-cells',function(el) {
    td(el.ind),
    td({'class': 'value ' + el['parent_id'], 'data-key': ''+el.ind, id: el.td_id}, 
        ''
    )
})

Jaml.register("array-entry-row",function(el) {
    tr(
        Jaml.render('array-entry-row-cells',el)
    )
})

function array_entry_row(el,parent_id) {
    //var val = render_input(el,true,parent_id)
    //el.render_val = val
    return Jaml.render('array-entry-row',el)

}

Jaml.register("hash-entry-row",function(el) {
    if (isBlank(el.val)) el.val = ''
    tr(
        td( input({type: 'text', value: el.key}) ),
        td( {'class': 'value ' + el['parent_id'], 'data-key': ''+el.key},
            input({type: 'text', value: el.val}) 
        )
    )
})



function render_input(el,child,parent_id) {
    smeDebug('render_input',{val: el.val, cls: getClass(el.val)})
    if (isArray(el.val)) {
        return array_entry(el.val,child,parent_id)
    }
    else if (isString(el.val)) {
        return textInputField({value: el.val})
    }
    else {
        return hash_entry(el.val,child,parent_id)
    }
}

function array_entry(arr,child,parent_id) {
    console.debug("array_entry",{arr: arr, child: child, parent: parent_id, sz: arr.length})
    var narr = []
    for(var i=0;i<arr.length;i++) {
        narr.push({val: arr[i], ind: ''+i, parent_id: parent_id, field_type: 'Hash'})
    }
    var res = "<table data-type='Array'>"
    $.each(narr,function() {
        res += array_entry_row(this,parent_id)
    })
    res += "</table>"
    smeDebug('array_entry',{res: res})
    if (!child) res += "<a class='save' href='#'>Save</a>"
    res += "<a class='add' href='#'>Add</a><a class='change' href='#'>Change</a>"
    return res
}

function hash_entry(arr,child,parent_id) {
    var narr = []
    var ks = hash_keys(arr)
    for(var i=0;i<ks.length;i++) {
        var k = ks[i]
        var v = arr[k]
        narr.push({val: v, key: k, parent_id: parent_id})
    }
    var res = "<table data-type='Hash'>" + Jaml.render('hash-entry-row',narr) + "</table>"
    if (!child) res += "<a class='save' href='#'>Save</a>"
    res += "<a class='add' href='#'>Add</a><a class='change' href='#'>Change</a>"
    return res
}
// 
// Jaml.register('field-type-selector',function() {
//     select({class: 'field-type-selector'},
//         option({value: 'Array'}, 'Array'),
//         option({value: 'Hash'}, 'Hash')
//     )
// })


function field_type_selector() {
    return "<select class='field-type-selector'><option value=''></option><option value='arrayCell'>Array</option><option value='hashCell'>Hash</option><option value='plain'>Plain</option></select>"
}
