function collCell(t,r,top_cb) {
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
        return hash_merge({coll: coll_name, row_id: row_id,field: me.getFieldName()},ops)
    }
    this.getFieldName = function() {
        return isChild() ? collCell(root_td).getFieldName() : me.getNaiveFieldName();
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
        var res = me.getInputHtmlInner(field_info.value,isChild(),td.attr('id'))
        smeDebug("getInputHtml",{res: res, val: field_info.value})
        return res
    }
    
    this.setInputHtml = function() {
        withType(function(fi) {
            td.html(getInputHtml(fi))
        })
        td.find('a.add').click(me.addField)
    }
    
    function eachInnerTd(f) {
        td.find("td.value").each(function() {
            var c = new collCell(this,root_td)
            c.fiSetup(f)
        })
    }

    this.setupCompoundField = function() {
        td.find('a.save').click(function() {
            myGet("/update_row", updateRowOps(me.fieldVals()), td)
        })
        td.find('a.add').click(function() {
            smeDebug('adding field')
            me.addField()
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
    
    this.guessInheritanceClass = function() {
        if (td.find('table').length == 0) {
            return null
        }
        var k = td.find('table').eq(0).attr('data-type')
        return isPresent(k) ? k : null
    }
    this.guessInheritanceFunc = function() {
        var k = me.guessInheritanceClass()
        if (isBlank(k)) return null
        var h = {'Array': arrayCell, 'Hash': hashCell}
        return h[k]
    }
    this.setupInheritanceIfPossible = function() {
        var f = me.guessInheritanceFunc()
        if (isBlank(f)) return
        this.sb = f
        this.sb()
    }
    var setupInheritance = function(field_info) {
        smeDebug("setupInheritance cls: "+field_info.field_type+' val: ' + field_info.value)
        var h = {'Array': arrayCell, 'Hash': hashCell}
        me.subclassFunc = get_matching_func(h,field_info.field_type,plainCellSetup)
        me.subclassFunc()
    }
    
    this.fiSetup = function(f) {
        withType(function(fi) {
            setupInheritance(fi)
            f(me)
        })
    }
    
    var editCellInner = loggingFunc('editCellInner',function() {
        withType(function(field_info) {
            setupInheritance(field_info)
            me.setInputHtml()
            eachInnerTd(function(x) { x.setInputHtml() })
            me.setupField()
            td.find('input').eq(0).focus()
        })     
    })

    this.editCell = function() {
        if (edited) return;
        editCellInner()
        edited = true
    }
    
    if (isPresent(top_cb)) {
        withType(function(fi) {
            setupInheritance(fi)
            top_cb(me)
        })
    }
    
    return this;
}
edited = false
function setupCellEdit() {
    $('.collection td').click(function() {
        var c = new collCell($(this))
        c.editCell()
    })
}