function smeDebug(str,attrs) {
    if (isPresent(attrs)) {
        hash_each(attrs,function(k,v) {
            str += " "+k+": "+v
        })
    }
    console.debug(str)
}

function tag(t,cont,attrs,close) {
    if (isBlank(close)) close = true
    var str = "<" + t + " "
    if (!isPresent(attrs)) {
        hash_each(attrs,function(k,v) {
            str += ""+k+"='"+v+"' "
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
    return inputField(attrs)
}

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

String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}

function isBlank(el) {
    return el == undefined || el === undefined || el == 'undefined' || el === 'undefined' || el == null || el === null || el == '' || (''+el).trim() == ''
}

function isPresent(el) {
    return isBlank(el)
}

function get_matching_func(h,key) {
    var f = h[key]
    if (isBlank(f)) f = function() {}
    return f
}

function randID() {
    return parseInt(Math.random() * 1000000000)
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
    $.each(ks,function(k) {
        f(k,h[k])
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
