function collCell(t,r) {
    var me = this
    var initial_root_td = r
    var root_td = r
    var td = $(t)
    if (isBlank(root_td)) root_td = td
    var val = td.text()
    var row = root_td.parent()
    var table = row.parent().parent()
    var coll_name = table.attr('data-coll')
    var c = coll(coll_name)
    var row_id = row.find('td:first').text()
    var column_index = getIndex(root_td[0],row.find('td'))
    var field_name = table.find('tr:first th').eq(column_index).text()
    var saved_field_info = null
    
    function ensureCellHasID() {
        if (isBlank(td.attr('id'))) {
            td.attr('id',randID())
        }
    }
    ensureCellHasID()
    
    var funcWithFieldInfo = loggingFunc('funcWithFieldInfo',function(f) {
        return function() {
            smeDebug('in funcWithFieldInfo inner function')
            return withType(f)
        }
    })
    
    this.getTd = function() { return td }
    this.getNaiveFieldName = function() { return field_name }
    this.text = function() { return td.text(); }
    function std_entry_field(val) { return textInputField({value: val}); }
    function baseOps(ops) { 
        return hash_merge({coll: coll_name, row_id: row_id,field: this.getFieldName()},ops)
    }
    this.getFieldName = function() {
        return isChild() ? collCell(root_td).getFieldName() : this.getNaiveFieldName();
    }
    
    function getVal() {
        if (td.find('input').length > 0) {
            return td.find('input').eq(0).val()
        }
        else {
            return val
        }
    }
    
    function isChild() {
        return isPresent(initial_root_td)
    }
    
    function fieldInfoOps() {
        var ops = isChild() ? {subfield: td.attr('data-key')} : {}
        return baseOps(ops)
    }
    
    var withTypeInner = function(f) {
        $.getJSON("/field_info",fieldInfoOps(),function(data) {
            saved_field_info = data
            smeDebug('field_info',data)
            f(data)
        })
    }
    
    var withType = function(f) {
        if (saved_field_info == null) {
            withTypeInner(f)
        }
        else {
            f(saved_field_info)
        }
    }
    
    //override this in subclasses
    this.getInputHtmlInner = function(field_info,c,t) {
        return std_entry_field(field_info)
    }
    
    //override this.setupField in subclass
    //override this.fieldVals in subclass
    //override this.addField in subclass
    
    var getInputHtml = function(field_info) {
        return this.getInputHtmlInner(field_info.value,isChild(),td.attr('id'))
    }
    
    this.setInputHtml = function() {
        withType(function(fi) {
            td.html(getInputHtml(fi))
        })
        td.find('a.add').click(this.addField)
    }
    
    function eachInnerTd(f) {
        td.find("td.value").each(function() {
            f(collCell(this,root_td))
        })
    }

    this.setupCompoundField = function() {
        var sthis = this
        td.find('a.save').click(function() {
            myGet("/update_row", updateRowOps(sthis.fieldVals()), td)
        })
        td.find('a.add').click(function() {
            smeDebug('adding field')
            me.addField
        })
    }
    
    this.setupFieldPlain = function() {
        td.find('input').blur(function() {
            myGet("/update_row", updateRowOps($(this).val()), td) 
        })
    }
    
    function updateRowOps(val) {
        return {coll: coll_name, row_id: row_id, field_name: field_name, field_value: val}
    }
    
    function plainCellSetup() { this.setupField = this.setupFieldPlain }
    var setupInheritance = function(field_info) {
        var h = {'Array': arrayCell, 'Hash': hashCell}
        this.subclassFunc = get_matching_func(h,field_info.field_type,plainCellSetup)
        this.subclassFunc()
    }
    
    var editCellInner = loggingFunc('editCellInner',function() {
        withType(function(field_info) {
            setupInheritance(field_info)
            this.setInputHtml()
            eachInnerTd(function(x) { x.setInputHtml() })
            this.setupField()
            td.find('input').eq(0).focus()
        })     
    })

    this.editCell = function() {
        if (edited) return;
        editCellInner()
        edited = true
    }
    
    return this;
}
edited = false
function setupCellEdit() {
    $('.collection td').click(function() {
        collCell($(this)).editCell()
    })
}