function newRow() {
    var fields = $('table tr:first th')
    var str = "<form id='form' action='/new_row'>"
    str += "<tr class='new-row'>"
    
    for(var i=0;i<fields.length;i++) {
        str += "<td><input type='text' name='" + fields[i].innerText + "'></td>"
    }
    str += "<td><input type='submit' value='abc'></td>"
    str += "</tr>"
    str += "</form>"
    
    $('table').append(str)
    $('#form').ajaxForm({success: reloadTable})
}

function saveNewRow() {
    var h = {}
    $('tr.new-row td input').each(function() {
        h[$(this).attr('name')] = $(this).val()
    })
    $.post("/new_row",h)
}

function reloadTable() {
  $.get('/table',function(data) {
    $('.collection').html(data)
  })
}

$(function() {
    $('a.new-row').click(function() {
        newRow()
    })
    // $('tr.new-row a.save').live('click',function() {
    //     saveNewRow()
    // })
})