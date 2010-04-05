TableToolsInit.sSwfPath = "/media/swf/ZeroClipboard.swf";
 
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
    
    function setupRename() {
        collScope('.title').click(function() {
            $(this).html('<input type="text" value="' + $(this).text() + '" />')
            var box = $(this).find("input")
            box.focus()
            box.blur(function() {
                $.get("/rename",{coll: collName, new_name: $(this).val()},function(data) {
                    collScope('.title').html(data)
                    window.location.reload()
                })
            })
        })
    }
    
    function setupTable() {
        var ops = {
    		"bProcessing": true,
    		"bServerSide": true,
           // "sPaginationType": "full_numbers",
            //"sDom": 'T<"clear">lfrtip', 
          //  'aoColumns': [{ "bVisible": false },null,null,null,null,null,null],
            //fnDrawCallback: function() { setTimeout(setupMasonry,0) },
            fnDrawCallback: function() {
                hideID()
                if (collScope('table tr').length == 1) {
                    alert('sup')
                    var row_id = collScope('table tr td').eq(0).text()
                    $.get('/cell_edit',{row_id: row_id, coll: collScope('table').attr('data-coll')},function(data) {
                        $('#content').attr('src',data)
                       // ..alert(data)
                    })
                }
            },
    		"sAjaxSource": "/table2?coll="+collName
    	}
    	var ss = collScope('').attr('data-search-str')
    	if (ss != 'undefined' && ss != '' && ss != undefined) {
    	    ops['oSearch'] = {'sSearch': ss}
    	}
    	ops['aaSorting'] = eval(collScope('').attr('data-sort'))
        var t = collScope('table').dataTable( ops );
        //new FixedHeader(t)
        
    }
    
    function copy() {
        $.get("/copy",{coll: collName},function() {
            window.location.reload()
        })
    }
    
    function search() {
        collScope('.dataTables_filter input').show()
        collScope('.actions').after(collScope('.dataTables_filter'))
    }
    
    function pagesize() {
        collScope('.dataTables_length').show()
    }
    
    function setupActions() {
        var h = {'copy': copy, 'search': search, 'pagesize': pagesize}
        collScope('.actions select').change(function() {
            var val = $(this).find('option:selected').val()
            h[val]()
        })
    }
    
    function hideID() {
        collScope('tr').each(function() {
            $(this).find('td').eq(0).hide()
            $(this).find('th').eq(0).hide()
        })
    }
    function savePositionInner(top,left) {
        $.get("/save_position",{top: top, left: left, coll: collName},function(data) {
            
        })
    }
    
    function savePosition(event,ui) {
        return savePositionInner(ui.offset.top,ui.offset.left)
    }
    
    function reposition() {
        if (collScope('').attr('data-top')) {
            collScope('').css('position','absolute').css('top',collScope('').attr('data-top')).css('left',collScope('').attr('data-left'))
        }
        else {
            var pos = collScope('').position()
            savePositionInner(pos.top,pos.left)
        }
    }
    this.setupNewRow = function() {
        collScope('a.new-row').live('click',newRow)
        collScope('a.new-column').live('click',newColumn)
        collScope('a.reload').live('click',reloadTable)
        setupTable()
        setupRename()
        setupActions()
        collScope('').draggable({stop: savePosition})
        reposition()
    }
    this.reload = setupTable
    return this;
}


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

function getIndex(obj,array) {
    for(var i=0;i<array.length;i++) {
        if (obj == array[i]) {
            return i;
        }
    }
    alert('didnt find')
}


function setupCellEdit() {
    function editCell(cell) {
        var val = cell.attr('data-raw-value')
        val = cell.text()
        cell.html("<input type='text' value='" + val + "'/>" + "<a href='#' class='expand' >e</a>")
        cell.find('input').focus()
        cell.find('a.expand').click(function() {
            alert('foo')
        })
        var row = cell.parent()
        var table = row.parent().parent()
        var row_id = row.find('td:first').text()
        var column_index = getIndex(cell[0],row.find('td'))
        var field_name = table.find('tr:first th').eq(column_index).text()
        $.get('/cell_edit',{row_id: row_id, coll: table.attr('data-coll')},function(data) {
            $('#content').attr('src',data)
           // ..alert(data)
        })
        //alert(row.find('td').length)
        cell.find('input').blur(function() {
            var ops = {coll: table.attr('data-coll'), row_id: row_id, field_name: field_name, field_value: $(this).val()}
            $.get("/update_row",ops,function(data) {
                console.debug(data)
                cell.text(data)
                //reloadAll()
            })
            
        })
    }
    
    
    $('.collection td').live('click',function() {
        editCell($(this))
    })
}


function reloadAll() {
    eachColl(function(c) {
        c.reload()
    })
}

$(function() {
    $('a.reload-all').click(reloadAll)
})

$(setupCellEdit)

function runRepeat(f) {
    f()
    setTimeout(function() { runRepeat(f) },1000)
}

function setupMasonry() {
    $('#colls').masonry({
        columnWidth: 200, 
        itemSelector: '.collection'
    })
}

//---------------------------

// $(document).ready(function() {
//  $('.collection').dataTable( {
//      "bProcessing": true,
//      "bServerSide": true,
//      "sAjaxSource": "/table"
//  } );
// } );

function hideID() {
    $('tr').each(function() {
        $(this).find('td').eq(0).hide()
        $(this).find('th').eq(0).hide()
    })
}


$(function() {
    $('tr').each(function() {
        $(this).find('td').eq(0).hide()
    })
})