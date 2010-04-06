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

function eachColl(f) {
    $('.collection').each(function(x) {
        console.debug($(this))
        console.debug($(this).attr('id'))
        var c = coll($(this).attr('id'))
        f(c)
    })
}