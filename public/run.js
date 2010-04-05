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
    this.getCollName = function() {
        return collName;
    }
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
    this.getHR = function() {
        return collCell(this,collScope("td").eq(9))
    }
    return this;
}


function magCell() {
    var cell = coll('available').getHR()
    console.debug(cell.text())
    cell.withType(function(d) {})
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

function array_join(arr,str) {
    var res = ""
    for(var i=0;i<arr.length;i++) {
        res += arr[i]
        if (i < arr.length-1) {
            res += str 
        }
    }
    return res
    
}

function collCell(t,r) {
    var initial_root_td = r
    var root_td = r
    var td = $(t)
    if (root_td == undefined) root_td = td
    var val = td.text()
    var row = root_td.parent()
    var table = row.parent().parent()
    var coll_name = table.attr('data-coll')
    var c = coll(coll_name)
    var row_id = row.find('td:first').text()
    var column_index = getIndex(root_td[0],row.find('td'))
    var field_name = table.find('tr:first th').eq(column_index).text()
    var saved_field_info = null
    
    console.debug("ID: " + td.attr('id'))
    if (td.attr('id') == undefined || td.attr('id') == '' || td.attr('id') == null) {
        td.attr('id',''+randID())
    }
    
    console.debug('coll_name '+coll_name+" initial root: "+initial_root_td+" rowid: "+row_id)
    
    function getVal() {
        if (td.find('input').length > 0) {
            return td.find('input').eq(0).val()
        }
        else {
            return val
        }
    }
    
    this.getFieldName = function() {
        return field_name
    }
    function std_entry_field() { return "<input type='text' value='" + getVal() + "'/>" }
    
    function arrayFieldVals() {
        function abc(child) {
            if (child.find('table').length == 0) {
                return '"' + child.find('input').val() + '"'
            }
            else {
                return collCell($(child),td).afv()
            }
        }
        var t = $.map( immediateChildren(), function(x) { return abc($(x)) } )
        var inner = array_join(t,",")
        var res = "[" + inner + "]"
        console.debug("afv: " + res)
        return res
    }
    this.afv = arrayFieldVals
    
    function hashFieldVals() {
        function hashField(t) {
            var k = $(t).find('input').eq(0).val()
            var v = $(t).find('input').eq(1).val()
            return '"' + k + '" => "' + v + '"' 
        }
        
        var t = $.map( td.find("tr"), function(x) { return hashField(x) } )
        var inner = array_join(t,",")
        var res = "{" + inner + "}"
        console.debug("afv: " + res)
        return res
    }
    this.hfv = hashFieldVals
    
    function addArrayField() {
        td.find('table').eq(0).append(Jaml.render('array-entry-row',{val: '', parent_id: td.attr('id')}))
    }
    function addHashField() {
        td.find('table').append(Jaml.render('hash-entry-row',{val: '', key: ''}))
    }
    
    this.text = function() {
        return td.text();
    }
    
    function isChild() {
        return !(initial_root_td == undefined)
    }
    
    function fieldInfoOps() {
        if (!isChild()) {
            return {coll: coll_name, row_id: row_id, field: field_name}
        }
        else {
            return {coll: coll_name, row_id: row_id, field: collCell(root_td).getFieldName(), subfield: td.attr('data-key')}
        }
    }
    
    function immediateChildren() {
        return $('td.value.'+td.attr('id'))
    }
    
    function immediateChildreng() {
        return $('td.value.'+td.attr('id'))
    }
    
    function withTypeInner(f) {
        console.debug('getting remote field info')
        $.getJSON("/field_info",fieldInfoOps(),function(data) {
            saved_field_info = data
            console.debug(data)
            f(data)
        })
    }
    
    function withType(f) {
        if (saved_field_info == null) {
            withTypeInner(f)
        }
        else {
            f(saved_field_info)
        }
    }
    
    function getInputHtml(field_info) {
        if (field_info.field_type == 'Array') {
            return array_entry(field_info.value,isChild(),td.attr('id'))
        }
        else if (field_info.field_type == 'Hash') {
            return hash_entry(field_info.value)
        }
        else {
            return std_entry_field()
        }
    }
    
    this.setInputHtml = function() {
        withType(function(field_info) {
            td.html(getInputHtml(field_info))
            td.find('a.add').click(addArrayField)
        })
    }
    
    function eachInnerTd(f) {
        td.find("td.value").each(function() {
            f(collCell(this,root_td))
        })
    }
    
    this.eachInnerTdRecursive = function(f) {
        eachInnerTd(function(x) {
            f(x)
            x.eachInnerTdRecursive(f)
        })
    }
    
    function editCellInner(field_info) {
        function updateRowOps(val) {
            var res = {coll: coll_name, row_id: row_id, field_name: field_name, field_value: val}
            console.debug('update row ops ')
            console.debug(res)
            return res
        }
        this.setInputHtml()
        eachInnerTd(function(x) { x.setInputHtml() })
        if (field_info.field_type == 'Array') {
            td.find('a.save').click(function() {
                $.get("/update_row", updateRowOps(arrayFieldVals()), function(data) {
                    td.html(data)
                })
            })
            td.find('a.add').click(addArrayField)
        }
        else if (field_info.field_type == 'Hash') {
            td.find('a.save').click(function() {
                $.get("/update_row", updateRowOps(hashFieldVals()), function(data) {
                    td.html(data)
                })
            })
            td.find('a.add').click(addHashField)
        }
        else
        {
            td.find('input').blur(function() {
                $.get("/update_row", updateRowOps($(this).val()), function(data) {
                    td.text(data)
                    td.attr('data-editing','0')
                }) 
            })
        }
        td.find('input').eq(0).focus()
        console.debug("imm: " + immediateChildren().length)
        
    }
    
    this.editCell = function() {
        if (edited) return;
        withType(editCellInner)
        edited = true
    }
    return this;
}
edited = false
function setupCellEdit() {
    $('.collection td').live('click',function() {
        collCell($(this)).editCell()
    })
}

function randID() {
    return parseInt(Math.random() * 1000000000)
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