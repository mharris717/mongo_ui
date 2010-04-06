TableToolsInit.sSwfPath = "/media/swf/ZeroClipboard.swf";
 
$(function() {
    eachColl(function(c) {
        c.setupNewRow()
    })
})

$(setupCellEdit)

function hideID() {
    $('tr').each(function() {
        $(this).find('td').eq(0).hide()
        $(this).find('th').eq(0).hide()
    })
}


// $(function() {
//     $('tr').each(function() {
//         $(this).find('td').eq(0).hide()
//     })
// })