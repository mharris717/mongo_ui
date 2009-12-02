function newRow() {
    var fields = $('table tr:first th')
    var str = "<tr class='new-row'>"
    for(var i=0;i<fields.length;i++) {
        str += "<td><input type='text' name='" + fields[i].innerText + "'></td>"
    }
    str += "<td><a class='save' href='#'>Save</a></td>"
    str += "</tr>"
    $('table').append(str)
}

function saveNewRow() {
    var h = {}
    $('tr.new-row td input').each(function() {
        h[$(this).attr('name')] = $(this).val()
    })
    $.post("/new_row",h)
}

$(function() {
    $('a.new-row').click(function() {
        newRow()
    })
    $('tr.new-row a.save').live('click',function() {
        saveNewRow()
    })
})