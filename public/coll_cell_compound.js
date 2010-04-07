function arrayCell() {
    var td = this.getTd()
    var me = this
    
    function immediateChildren() {
        return $('td.value.'+td.attr('id'))
    }
    
    this.setupField = function() {
        this.setupCompoundField()
    }
    
    this.fieldVals = function() {
        smeDebug('array fieldVals',{sz: immediateChildren().length})
        function abc(child) {
            var c = new collCell($(child),td)
            var cls = c.guessInheritanceClass()
            
            c.setupInheritanceIfPossible()
            var res = c.fieldVals()
            smeDebug('guess',{cls: cls, res: res})
            return res
        }
        var t = $.map( immediateChildren(), function(x) { return abc($(x)) } )
        var inner = array_join(t,",")
        var res = "[" + inner + "]"
        return res
    }
    
    this.addField = function() {
        me.wt(function(fi) {
            smeDebug('array addField',fi)
            if (isPresent(fi['array_hash_keys'])) {
                var new_id = randID()
                var str = hash_entry(arrayToBlankHash(fi['array_hash_keys']), false, new_id)
                str = "<tr><td>17</td><td id='"+new_id+"' class='value "+td.attr('id')+"'>"+str + "</td></tr>"
                td.find('table').eq(0).append(str)
            }
            else {
                td.find('table').eq(0).append(Jaml.render('array-entry-row',{val: '', parent_id: td.attr('id')}))
            }
            
        })
    }
    
    this.getInputHtmlInner = function(field_info,is_child,td_id) {
        smeDebug('array getInputHtmlInner')
        smeDebug('getInputHtmlInner',{field_info: field_info})
        if (isBlank(field_info.length) || field_info.length == 0) field_info = ['']
        return array_entry(field_info, is_child, td_id)
    }
    
    return this;
}

function hashCell() {
    var td = this.getTd()
    this.setupField = function() {
        this.setupCompoundField()
    }
    
    function immediateChildRows() {
        var res = $('td.value.'+td.attr('id')).parent()
        //smeDebug("hash child rows",{res: res.length})
        return res
    }
    
    this.fieldVals = function() {
        function hashField(t) {
            var k = $(t).find('input').eq(0).val()
            var c = $(t).find('td.value').eq(0)
            var value_cell = new collCell($(c),td)
            value_cell.setupInheritanceIfPossible()
            var v = value_cell.fieldVals()
            return '"' + k + '" => ' + v 
        }
        
        var t = $.map( immediateChildRows(), function(x) { return hashField(x) } )
        var inner = array_join(t,",")
        var res = "{" + inner + "}"
        return res
    }
    
    this.addField = function() {
        td.find('table').eq(0).append(Jaml.render('hash-entry-row',{val: '', key: '', parent_id: td.attr('id')}))
    }
    
    this.getInputHtmlInner = function(field_info,is_child,td_id) {
        return hash_entry(field_info, is_child, td_id)
    }
}
dclick = false
$('input').live('dblclick',function() {
    var td = $(this).parent()
    td.html(field_type_selector())
})

$('select.field-type-selector').live('change',function() {
    var temp = new collCell($(this).parent())
    var root = temp.findRoot()
    var cell = new collCell($(this).parent(),root)
    var new_type = $(this).find("option:selected").val()
    smeDebug('changing',{new_type: new_type})
    cell.changeType(new_type)
})