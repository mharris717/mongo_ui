function hash_keys(h)
{
  var keys = [];
  for(i in h) if (h.hasOwnProperty(i))
  {
    keys.push(i);
  }
  return keys;
}

Jaml.register("array-entry-row",function(el) {
    tr(
        td(el.ind),
        td({'class': 'value' + ' ' + el['parent_id'], 'data-key': ''+el.ind}, 
            input({type: 'text', value: el.val}) 
        )
    )
})

Jaml.register("hash-entry-row",function(el) {
    tr(
        td( input({type: 'text', value: el.key}) ),
        td( {'class': 'value ' + el['parent_id'], 'data-key': ''+el.key},
            input({type: 'text', value: el.val}) 
        )
    )
})

function array_entry(arr,child,parent_id) {
    console.debug("array_entry arr: " + arr)
    var narr = []
    for(var i=0;i<arr.length;i++) {
        narr.push({val: arr[i], ind: ''+i, parent_id: parent_id})
    }
    var res = "<table>" + Jaml.render('array-entry-row',narr) + "</table>"
    if (!child) res += "<a class='save' href='#'>Save</a>"
    res += "<a class='add' href='#'>Add</a>"
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
    return "<table>" + Jaml.render('hash-entry-row',narr) + "</table>" + "<a class='save' href='#'>Save</a>" + "<a class='add' href='#'>Add</a>"
}

