function arrayCell() {
    var td = this.getTd()
    
    function immediateChildren() {
        return $('td.value.'+td.attr('id'))
    }
    
    this.setupField = function() {
        this.setupCompoundField()
    }
    
    this.fieldVals = function() {
        function abc(child) {
            var c = new collCell($(child),td)
            var cls = c.guessInheritanceClass()
            c.setupInheritanceIfPossible()
            if (isBlank(cls)) {
                return '"' + child.find('input').val() + '"'
            }
            else {
                return c.fieldVals()
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
        smeDebug('array getInputHtmlInner val: ')
        smeDebug(field_info)
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