// La partie du code qui suit est migrée vers la page '/layouts/_sparkom_support.html.erb'
//Faire attention lors des mises à jour car de nouvelles variables ont été définies

//var dropdownCreated = false;
//function onWidgets(widgets) {
//    if(dropdownCreated) {
//        updateDropdownAvailabilities(widgets);
//    } else {
//        drawDropdown(widgets);
//        dropdownCreated = true;
//    }
//}
//function drawDropdown(widgets) {
//    var userLang = navigator.language || navigator.userLanguage;
//    var isEnglish = (userLang.indexOf("en")===0);
//    var width = '250px';
//    var textColor = '#206A7C';
//    var html='<div class="dropdown">';
//    html += '<a id="dLabel" role="button" style="width:'+width+';" data-toggle="dropdown" class="btn btn-primary" data-target="#" href="/page.html">';
//    if(isEnglish) {
//        html += 'Live chat support ';
//    } else {
//        html += 'Accès conseillers ';
//    }
//    html += '<span class="caret"></span></a>';
//
//    html += '<ul class="dropdown-menu multi-level" style="width:'+width+';" role="menu" aria-labelledby="dropdownMenu">';
//    for(var i=0; i < widgets.length; i++) {
//        var wi = widgets[i];
//        html += '<li><a style="color:'+textColor+';" href="" onclick="';
//        html += widgetLaunchUrl(wi.widgetId);
//        html += '">';
//        if(wi.available) {
//            html += '<span id="spk_wi_'+wi.widgetId+'" class="fa fa-user" aria-hidden="true" style="color:green;"></span> ';
//        } else {
//            html += '<span id="spk_wi_'+wi.widgetId+'" class="fa fa-user" aria-hidden="true" style="color:gray;"></span> ';
//        }
//        html += wi.displayName;
//        html += '</a></li>';
//        html += '<li class="dropdown-submenu">';
//        html += '<a style="text-align:right;font-size:80%;color:'+textColor+';" tabindex="-1" href="" onclick="';
//        html += widgetLaunchUrl(wi.widgetId);
//        html += '">';
//        if(isEnglish) {
//            html += 'See helpers ';
//        } else {
//            html += 'Voir les conseillers ';
//        }
//        //html += '<span class="fa fa-chevron-right" style="color:#6396A3;" aria-hidden="true"></span>';
//        html += '</a>';
//        html += '<ul class="dropdown-menu">';
//        for(var j=0; j < wi.members.length; j++) {
//            var wmb = wi.members[j];
//            html += '<li><a style="color:'+textColor+';" tabindex="-1" href="" onclick="';
//            html += memberLaunchUrl(wi.widgetId, wmb.laid);
//            html += '">';
//            if(wmb.available) {
//                html += '<span id="spk_wmb_'+wmb.laid+'" class="fa fa-user" aria-hidden="true" style="color:green;"></span> ';
//            } else {
//                html += '<span id="spk_wmb_'+wmb.laid+'" class="fa fa-user" aria-hidden="true" style="color:gray;"></span> ';
//            }
//            html += wmb.displayName;
//            html += '</a></li>';
//        }
//        html += '</ul>';
//        html += '</li>';
//    }
//    html += '</ul></div>';
//
//    $('#spktargetdiv').html(html);
//}
//
//function updateDropdownAvailabilities(widgets) {
//    for(var i=0; i < widgets.length; i++) {
//        var wi = widgets[i];
//        if(wi.available) {
//            $('#spk_wi_'+wi.widgetId).css('color','green');
//        } else {
//            $('#spk_wi_'+wi.widgetId).css('color','gray');
//        }
//        for(var j=0; j < wi.members.length; j++) {
//            var wmb = wi.members[j];
//            if(wmb.available) {
//                $('#spk_wmb_'+wmb.laid).css('color','green');
//            } else {
//                $('#spk_wmb_'+wmb.laid).css('color','gray');
//            }
//        }
//    }
//}
//function onSpkError(errMessage) {
//    $('#spktargetdiv').html(errMessage);
//}



// La partie du code qui suit est migrée vers la page '/layouts/_sparkom_support.html.erb'

//$(document).ready(function() {
//    if(helperId == null) {
//        $('#spktargetdiv').html("MISSING helperId.");
//    } else {
//        var multiWidget = new SpkMultiWidget(helperId);
//        multiWidget.onWidgets(onWidgets);
//        multiWidget.onError(onSpkError);
//        multiWidget.start();
//    }
//});
//
//// May use different displays
//function widgetLaunchUrl(widgetId) {
//    var tUrl = PAN_SERVER_BASE_URL + 'wchat/sparkom/wchat.html?wid=';
//    tUrl = tUrl + widgetId;
//    tUrl = 'javascript:window.open(\''+ tUrl + '\', \'chat\', \'scrollbars=no,location=no,width=700,height=450,location=no,menubar=no,status=no,toolbar=no\');';
//    return tUrl;
//}
//function memberLaunchUrl(widgetId, laid) {
//    var tUrl = PAN_SERVER_BASE_URL + 'wchat/sparkom/wchat.html?wid=';
//    tUrl = tUrl + widgetId;
//    tUrl += '&tolaid=' + laid;
//    tUrl = 'javascript:window.open(\''+ tUrl + '\', \'chat\', \'scrollbars=no,location=no,width=700,height=450,location=no,menubar=no,status=no,toolbar=no\');';
//    return tUrl;
//}

