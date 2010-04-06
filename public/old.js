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

function tag(t,cont) {
    var str = "<" + t + " "
    str += ">" + cont + "</" + t + ">"
    return str
}

function textInput(n) {
    return "<input type='text' name='" + n + "' >"
}

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
