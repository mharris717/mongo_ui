function coll(n) {
    var collName = n
    this.getCollName = function() {
        return collName;
    }
    function collScope(str) {
        return $('#' + collName + " " + str)
    }
    
    function fieldNames() {
        return collScope('table tr:first th').map(function() { return $(this).text() })
    }
    
    function hitServer(url,ops,f) {
        ops['coll'] = collName
        if (isBlank(f)) f = function() {}
        myGet(url,ops,f)
    }
    
    function newRow() {
        function newRowStr() {
            var str = "<tr class='new-row'>"

            fieldNames().each(function() {
                str += tag("td",textInputField({name: this}))
            })

            str += tag('td',hid + inputField({type:'submit', value:'Save'}) ) + "</form>"
            str += "</tr>"
            return str
        }
        var hid = inputField({type:'hidden',name:'coll',value:collName})
        
        collScope('table').append(newRowStr())
        collScope('form').submit(function() { 
            $(this).ajaxSubmit({success: reloadTable}); 
            return false; 
        });
    }

    function reloadTable() {
        hitServer('/table',{},collScope(''))
    }
    
    function setupRename() {
        collScope('.title').click(function() {
            $(this).html(textInputField({value: $(this).text()}))
            var box = $(this).find("input").focus()
            box.blur(function() {
                hitServer("/rename",{new_name: $(this).val()},function(data) {
                    collScope('.title').html(data)
                    window.location.reload()
                })
            })
        })
    }
    
    function searchStrAttr() {
        return collScope('').attr('data-search-str')
    }
    
    function onDraw() {
        hideID()
        setupCellEdit()
    }
    
    function baseSetupOps(addl) {
        var h = {
    		"bProcessing": true,
    		"bServerSide": true,
            fnDrawCallback: onDraw,
    		"sAjaxSource": "/table2?coll="+collName
    	}
    	return hash_merge(h,addl)
    }
    
    function resetTable(ops) {
        var ops = baseSetupOps(ops)
        collScope('table:first').dataTable(ops)
    }
    
    var setupTable = function() {
        var ops = {}
        //var ops = hash_add_if_present({},'oSearch',searchStrAttr())
    	ops['aaSorting'] = eval(collScope('').attr('data-sort'))
        //smeDebug('setupTable data-sort',{oSearch: ops['oSearch'], datasort: collScope('').attr('data-sort'), evaled: eval(collScope('').attr('data-sort'))})
        resetTable(ops)
    }
    
    function copy() {
        hitServer("/copy",{},function() {
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
        var h = {'copy': copy, 'search': search, 'pagesize': pagesize, 'reload': setupTable, 'newrow': newRow}
        collScope('.actions select').change(function() {
            var val = $(this).find('option:selected').val()
            h[val]()
        })
    }
    
    function hideID() {
        collScope('table.colltable > tbody > tr, table.colltable > thead > tr').each(function() {
            $(this).find('td, th').eq(0).hide()
        })
    }
    function savePositionInner(top,left) {
        hitServer("/save_position",{top: top, left: left})
    }
    
    function savePosition(event,ui) {
        return savePositionInner(ui.offset.top,ui.offset.left)
    }
    
    function setupDraggable() {
        collScope('').draggable({stop: savePosition})
    }
    
    function setupCellEdit() {
        collScope('table.colltable > tbody > tr > td').click(function() {
            if ($(this).find('input').eq(0).val() != '99') {
                var c = new collCell($(this))
                c.editCell()
            }
        })
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
    this.setupCollection = function() {
        $.each([setupTable,setupRename,setupActions,setupDraggable,reposition,setupCellEdit],function() { this() } )
    }
    this.reload = setupTable
    return this;
}

function eachColl(f) {
    $('.collection').each(function(x) {
        var c = coll($(this).attr('id'))
        f(c)
    })
}