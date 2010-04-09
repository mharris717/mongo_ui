function smeDebug(str,attrs) {
    if (isPresent(attrs)) {
        hash_each(attrs,function(k,v) {
            str += " "+k+": "+v
        })
    }
    var d = new Date();
    //str = prettyTime()+' | '+str
    //$.get("/log",{str: str},function(data) {})
    console.debug(str)
}

function prettyTime(d) {
    if (isBlank(d)) d = new Date()
    return ''+d.getHours()+':'+d.getMinutes()+':'+d.getSeconds()
}

function tag(t,cont,attrs,close) {
    if (isBlank(close)) close = true
    var str = "<" + t + " "
    if (isPresent(attrs)) {
        hash_each(attrs,function(k,v) {
            if (isPresent(v)) {
                str += ""+k+"='"+v+"' "
            }
        })
    }
    str += ">"
    if (close) str += cont + "</" + t + ">"
    return str
}

function inputField(attrs) {
    return tag('input','',attrs,false)
}

function textInputField(attrs) {
    if (isBlank(attrs['type'])) attrs['type'] = 'text'
    var res = inputField(attrs)
    return res
}

function getIndex(obj,array) {
    for(var i=0;i<array.length;i++) {
        if (obj == array[i]) {
            return i;
        }
    }
    alert('didnt find, array size was '+array.length)
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

String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}

function isBlank(el) {
    return el == undefined || el === undefined || el == 'undefined' || el === 'undefined' || el == null || el === null || el == '' || (''+el).trim() == ''
}

function isPresent(el) {
    return !isBlank(el)
}

function get_matching_func(h,key,default_func) {
    if (isBlank(default_func)) default_func = function() {}
    var f = h[key]
    if (isBlank(f)) f = default_func
    return f
}

function randID() {
    return ''+parseInt(Math.random() * 1000000000)
}

function runRepeat(f) {
    f()
    setTimeout(function() { runRepeat(f) },1000)
}

function hash_keys(h)
{
  var keys = [];
  for(i in h) if (h.hasOwnProperty(i))
  {
    keys.push(i);
  }
  return keys;
}

function hash_each(h,f) {
    var ks = hash_keys(h)
    $.each(ks,function() {
        f(this,h[this])
    })
}

function hash_add_if_present(h,k,v) {
    if (isPresent(v)) {
        h[k] = v
    }
    return h
}

function hash_merge(h,n) {
    if (isPresent(n)) {
        hash_each(n,function(k,v) {
            h[k] = v
        })
    }
    return h
}

function myGet(url,ops,farg) {
    f = null
    if (isBlank(farg)) f = function() {}
    else if (isPresent(farg.html)) {
        f = function(data) {
            farg.html(data)
        }
    }
    else {
        f = farg
    }
    return $.get(url,ops,f)
}

function loggingFunc(name,f) {
    return function(a,b,c,d,e) {
        var i = randID()
        smeDebug("Function Called: " + name + ' ' + i)
        var res = null
        if (arguments.length == 0) res = f()
        else if (arguments.length == 1) res = f(a)
        else if (arguments.length == 2) res = f(a,b)
        else if (arguments.length == 3) res = f(a,b,c)
        else if (arguments.length == 4) res = f(a,b,c,d)
        else fdggdfgf()
        smeDebug("Function Ending: " + name + ' ' + i)
        return res
    }
}

function directChildren(selector,parent) {
    var arr = parent.find(selector)
    var res = []
    arr.each(function() {
        if ($(this).parent()[0] == parent[0]) {
            res.push(this)
        }
    })
    return res
}

function arrayToBlankHash(arr) {
    var res = {}
    $.each(arr,function() {
        res[this] = null
    })
    return res
}

function getClass(obj) {
    var res = obj.constructor.toString().substr(9,4)
    smeDebug('getClass',{obj: obj, res: res})
    smeDebug(obj)
    return res
}
function isArray(obj) {
    return getClass(obj) == 'Arra'
}
function isString(obj) {
    return getClass(obj) == 'Stri'
}