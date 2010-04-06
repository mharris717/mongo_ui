function arrayCell() {
    var td = getTd()
    
    function immediateChildren() {
        return $('td.value.'+td.attr('id'))
    }
    
    this.setupField = function() {
        this.setupCompoundField()
    }
    
    this.fieldVals = function() {
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
    
    this.addField = function() {
        td.find('table').eq(0).append(Jaml.render('array-entry-row',{val: '', parent_id: td.attr('id')}))
    }
    
    this.getInputHtmlInner = function(field_info,is_child,td_id) {
        return array_entry(field_info, is_child, td_id)
    }
    
    return this;
}

function hashCell(t,r) {
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
    
    function addHashField() {
        td.find('table').append(Jaml.render('hash-entry-row',{val: '', key: ''}))
    }
    

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
    
    if (td.attr('id') == undefined || td.attr('id') == '' || td.attr('id') == null) {
        td.attr('id',''+randID())
    }
    
    this.getTd = function() { return td }
    
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
    function std_entry_field(val) { console.debug('getVal ' + getVal()); return "<input type='text' value='" + val + "'/>" }
    
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
    
    function withTypeInner(f) {
        console.debug('getting remote field info')
        $.getJSON("/field_info",fieldInfoOps(),function(data) {
            saved_field_info = data
            console.debug('withTypeInner')
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
    
    this.getInputHtmlInner = function(field_info,c,t) {
        return std_entry_field(field_info)
    }
    function getInputHtml(field_info) {
        return this.getInputHtmlInner(field_info.value,isChild(),td.attr('id'))
    }
    
    this.setInputHtml = function() {
        withType(function(field_info) {
            td.html(getInputHtml(field_info))
            td.find('a.add').click(this.addField)
        })
    }
    
    function eachInnerTd(f) {
        td.find("td.value").each(function() {
            f(collCell(this,root_td))
        })
    }

    this.setupCompoundField = function() {
        alert('setupCompoundField')
        td.find('a.save').click(function() {
            alert('update')
            $.get("/update_row", updateRowOps(this.fieldVals()), function(data) {
                td.html(data)
            })
        })
        td.find('a.add').click(this.addField)
    }
    
    this.setupFieldPlain = function() {
        alert('crummy setup')
        td.find('input').blur(function() {
            $.get("/update_row", updateRowOps($(this).val()), function(data) {
                td.text(data)
            }) 
        })
    }
    
    function updateRowOps(val) {
        var res = {coll: coll_name, row_id: row_id, field_name: field_name, field_value: val}
        console.debug('update row ops ')
        console.debug(res)
        return res
    }
    
    function editCellInner(field_info) {
        alert(field_info.field_type)
        if (field_info.field_type == 'Array') {
            this.sub = arrayCell
            this.sub()
        }
        else if (field_info.field_type == 'Hash') {
            this.sub = hashCell
            this.sub()
        }
        else {
            this.setupField = this.setupFieldPlain
        }
        this.setInputHtml()
        eachInnerTd(function(x) { x.setInputHtml() })
        this.setupField()
        td.find('input').eq(0).focus()        
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