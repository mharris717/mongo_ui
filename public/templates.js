Object.prototype.keys = function ()
{
  var keys = [];
  for(i in this) if (this.hasOwnProperty(i))
  {
    keys.push(i);
  }
  return keys;
}

Jaml.register("array-entry-row",function(el) {
    tr(
        td(el.ind),
        td( input({type: 'text', value: el.val}) )
    )
})

Jaml.register("hash-entry-row",function(el) {
    tr(
        td( input({type: 'text', value: el.key}) ),
        td( input({type: 'text', value: el.val}) )
    )
})

function array_entry(arr) {
    var narr = []
    for(var i=0;i<arr.length;i++) {
        narr.push({val: arr[i], ind: ''+i})
    }
    return "<table>" + Jaml.render('array-entry-row',narr) + "</table>" + "<a class='save' href='#'>Save</a>" + "<a class='add' href='#'>Add</a>"
}

function hash_entry(arr) {
    var narr = []
    var ks = arr.keys()
    for(var i=0;i<ks.length;i++) {
        var k = ks[i]
        var v = arr[k]
        narr.push({val: v, key: k})
    }
    return "<table>" + Jaml.render('hash-entry-row',narr) + "</table>" + "<a class='save' href='#'>Save</a>" + "<a class='add' href='#'>Add</a>"
}

