// function vehicle() {
//     function run() {
//         console.debug('run')
//     }
// }
// 
// function car() {
//     this.ifr = vehicle
//     this.ifr()
//     this.abc = function() {
//         run()
//     }
//     return this;
// }
// 
// car().abc()



// $.get('/cell_edit',{row_id: row_id, coll: table.attr('data-coll')},function(data) {
//     $('#content').attr('src',data)
// })

function reloadAll() {
    eachColl(function(c) {
        c.reload()
    })
}

$(function() {
    $('a.reload-all').click(reloadAll)
})

function setupMasonry() {
    $('#colls').masonry({
        columnWidth: 200, 
        itemSelector: '.collection'
    })
}

Object.prototype.makeGetter = function(var_name,method_name) {
    var f = function() {
        return eval(var_name)
    }
    this[method_name] = f
}

function car(t) {
    var maker = t;
    alert(this['maker'])
    //this.getMaker = f
    //makeGetter('maker','getMaker')
    return this;
}

function coll() {
    function setNewField() {
        //formData['abc'] = 'xyz'
        // var n = collScope("table tr:first input").val()
        // alert("setting name attr to " + n)
        // collScope("tr input").attr('name',n)
    }
    function headerVal(cell) {
        if ($('input',cell).length > 0) {
            return $('input',cell).val()
        }
        else {
            return $(cell).text()
        }
    }
    function newColumn() {
        collScope('table tr:first').append(tag("th",textInput('newField')))
    }
    
    if (collScope('table tr').length == 1) {
        alert('sup')
        var row_id = collScope('table tr td').eq(0).text()
        $.get('/cell_edit',{row_id: row_id, coll: collScope('table').attr('data-coll')},function(data) {
            $('#content').attr('src',data)
           // ..alert(data)
        })
    }
}

// jquery each puts element in this, index in arg