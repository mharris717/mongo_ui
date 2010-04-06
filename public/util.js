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