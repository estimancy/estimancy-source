
var current_action_url = window.location.href;
// if ((current_action_url.indexOf("estimations") > -1) || (current_action_url.indexOf("dashboard") > -1)){
if (current_action_url.indexOf("estimations") > -1){
    //alert("ok");

    $(document).ajaxStart(function () {
        $.blockUI({ message: '<i class="fa fa-3x fa-spinner fa-spin"></i>',
            css: { backgroundColor: 'transparent', border: 'none' },
            overlayCSS:  { backgroundColor: 'none', opacity: 0.0, cursor:'wait' }
        });
    });

    $(document).ajaxStop(function () {
        $.unblockUI();
        $(".blockUI").fadeOut("slow");
    });

}

// $(document).ajaxStart(function () {
//     $.blockUI({ message: '<i class="fa fa-3x fa-spinner fa-spin"></i>',
//         css: { backgroundColor: 'transparent', border: 'none' },
//         overlayCSS:  { backgroundColor: 'none', opacity: 0.0, cursor:'wait' }
//     });
// });
//
// //$(document).ajaxStop($.unblockUI);
// $(document).ajaxStop(function () {
//     $.unblockUI();
//     $(".blockUI").fadeOut("slow");
// });


//Affichage de spinner lors d'une action
function StartBlockUI() {
    $.blockUI({ message: '<i class="fa fa-3x fa-spinner fa-spin"></i>',
        css: { backgroundColor: 'transparent', border: 'none' },
        overlayCSS:  { backgroundColor: 'none', opacity: 0.0, cursor:'wait' }
    });
}

function CloseBlockUI() {
    //setTimeout($.unblockUI, 1);
    $.unblockUI();
    $(".blockUI").fadeOut("slow");
}

$(document).ready(function() {

    // $(document).ajaxStart($.blockUI).ajaxStop($.unblockUI);
    // $.ajaxStart(StartBlockUI()).ajaxStop(CloseBlockUI());

    // $.ajax(
    //   {
    //     type: "POST",
    //     complete: function() {
    //         $.unblockUI();
    //     }
    // });

});