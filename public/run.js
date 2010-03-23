function tag(t,cont) {
    var str = "<" + t + " "
    str += ">" + cont + "</" + t + ">"
    return str
}

function textInput(n) {
    return "<input type='text' name='" + n + "' >"
}

function coll(n) {
    var collName = n
    function collScope(str) {
        return $('#' + collName + " " + str)
    }
    function headerVal(cell) {
        if ($('input',cell).length > 0) {
            return $('input',cell).val()
        }
        else {
            return $(cell).text()
        }
    }
    
    function newRow() {
        var fields = collScope('table tr:first th')
        var hid = "<input type='hidden' name='coll' value='" + collName + "'>"
        var str = "<tr class='new-row'>"
    
        for(var i=0;i<fields.length;i++) {
            str += tag("td",textInput(headerVal(fields[i])))
        }
        str += "<td>" + hid + "<input type='submit' value='Save'></td></form>"
        str += "</tr>"
        //collScope('table').before("<form action='/new_row'>")
        //collScope('table').after('dd')
        collScope('table').append(str)
        collScope('form').submit(function() { 
            //setNewField()
            $(this).ajaxSubmit({success: reloadTable}); 
            return false; 
        });
    }
    
    function setNewField() {
        //formData['abc'] = 'xyz'
        // var n = collScope("table tr:first input").val()
        // alert("setting name attr to " + n)
        // collScope("tr input").attr('name',n)
    }

    function reloadTable() {
        $.get('/table',{coll: collName},function(data) {
            collScope('').html(data)
        })
    }
    function newColumn() {
        collScope('table tr:first').append(tag("th",textInput('newField')))
    }
    this.setupNewRow = function() {
        collScope('a.new-row').live('click',newRow)
        collScope('a.new-column').live('click',newColumn)
        collScope('a.reload').live('click',reloadTable)
    }
    return this;
}

// $(coll('players').setupNewRow)
// $(coll('PlayersbyValue').setupNewRow)

function eachColl(f) {
    $('.collection').each(function(x) {
        console.debug($(this))
        console.debug($(this).attr('id'))
        var c = coll($(this).attr('id'))
        f(c)
    })
}

$(function() {
    eachColl(function(c) {
        c.setupNewRow()
    })
})


function setupCellEdit() {
    function editCell(cell) {
        cell.html("<input type='text' value='" + cell.attr('data-raw-value') + "'/>")
        cell.find('input').focus()
        var row = cell.parent()
        var table = row.parent().parent()
        var row_id = row.attr('data-row-id')
        cell.find('input').blur(function() {
            var ops = {coll: table.attr('data-coll'), row_id: row_id, field_name: cell.attr('data-field-name'), field_value: $(this).val()}
            $.get("/update_row",ops,function(data) {
                console.debug(data)
                cell.text(data)
            })
            
        })
    }
    
    
    $('.table-cell').live('click',function() {
        editCell($(this))
    })
}

$(setupCellEdit)
$(function() {
    $('a.reload-all').click(function() {
        $('a.reload').click()
    })
})