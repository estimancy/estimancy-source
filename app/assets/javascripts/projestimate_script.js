/*
 #encoding: utf-8
 #############################################################################
 #
 # Estimancy, Open Source project estimation web application
 # Copyright (c) 2014 Estimancy (http://www.estimancy.com)
 #
 #    This program is free software: you can redistribute it and/or modify
 #    it under the terms of the GNU Affero General Public License as
 #    published by the Free Software Foundation, either version 3 of the
 #    License, or (at your option) any later version.
 #
 #    This program is distributed in the hope that it will be useful,
 #    but WITHOUT ANY WARRANTY; without even the implied warranty of
 #    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #    GNU Affero General Public License for more details.
 #
 #############################################################################**/

//$(document).ready(function() {
$(document).ready(function() {

    $(".alert").delay(4000).slideUp(200, function() {
        $(this).alert('close');
    });

    //$("#ratio").change(function() {
    //    if ($(this).val() !== "") {
    //        return $.ajax({
    //            url: "/refresh_dashboard_module_project_ratio_elements",
    //            method: "GET",
    //            data: {
    //                wbs_activity_ratio_id: $(this).val(),
    //                dashboard_selected_ratio_id: $("#dashboard_selected_ratio_id").val()
    //            },
    //
    //            success: function(data) {
    //                $("#dashboard_selected_ratio_id").val($(this).val());
    //                return $(".total-ratio").html(data);
    //            },
    //            error: function(XMLHttpRequest, testStatus, errorThrown) {
    //                return alert("Error! :" +  errorThrown);
    //            }
    //        });
    //    }
    //});
});

//$(document).on('ready turbolinks:load', function() {
$(document).ready(function() {
    //====================================================

    //$(".module_project11").draggable({
    //    start: function(event, ui) {}, // console.log(event);console.log(ui)},
    //    stop: function(event, ui) {}, // console.log(event);//console.log(ui)},
    //    cursor:'move',
    //    opacity: 0.5,
    //
    //    drag: function(){
    //        jsPlumb.repaint($(this)); // (or) jsPlumb.repaintEverything(); to repaint the connections and endpoints
    //        //followed by your code
    //        var offset = $(this).offset();
    //        var xPos = offset.left;
    //        var yPos = offset.top;
    //        console.log('x: ' + xPos);
    //        console.log('y: ' + yPos);
    //    }
    //});
    //
    //$(".window11").draggable({
    //    //helper: 'clone',
    //    // appendTo: 'body',
    //    start: function(event, ui) {}, // console.log(event);console.log(ui)},
    //    stop: function(event, ui) {}, // console.log(event);//console.log(ui)},
    //    //revert: false,
    //    cursor:'move',
    //    opacity: 0.5,
    //});

    //====================================================

    //tinymce.init({
    //    selector: 'textarea'
    //});

    // $(".modal").draggable({
    //     handle: ".modal-drag"
    // });
    //
    // $("#edit_component").draggable({
    //     handle: ".modal-header, .modal-body"
    // });

    $("#edit_component").draggable({
        handle: ".modal-header, .modal-body"
    });

    // Modal bug
    $('.modal-backdrop').remove();
    $(".modal").hide();
    $(".close").on('click', function(){
        $('.modal-backdrop').remove();
        $(".modal").hide();
    });

    // Update the jscolor library Dir to resolve bug on colors detection
    jscolor.dir = '/assets/images/';


    $("form.send_feedback input[type=submit]").click(function() {
        var error=false;
        if($("#send_feedback_user_name").val() == "") {
            $("#error_send_feedback").show();
            $("#send_feedback_user_name").css("border-color", "red");
            error= true;
        }else
        {
            $("#send_feedback_user_name").css("border", "1px solid #cccccc");
            $("#error_send_feedback").hide();
        }

        if( $("#send_feedback_type").val() == "")
        {
            $("#error_send_feedback").show();
            $("#send_feedback_type").css("border-color", "red");
            error=  true;
        }
        else
        {
            $("#send_feedback_type").css("border", "1px solid #cccccc");
            $("#error_send_feedback").hide();
        }
        if ($("#send_feedback_description").val() == "")
        {
            $("#error_send_feedback").show();
            $("#send_feedback_description").css("border-color", "red");
            error=  true;
        }
        else
        {
            $("#send_feedback_description").css("border", "1px solid #cccccc");
            $("#error_send_feedback").hide();
        }

        if (error==true)
        {   return false
        }
        else
        {
            return true
        }

    });

    $("#technology").change(function() {
        return $.ajax({
            url: "/change_abacus",
            method: "GET",
            data: "technology=" + $(this).val()
        });
    });

    $(".accordion").on("show", function (e) {
       $(e.target).parent().find(".icon-caret-right").removeClass("icon-caret-right").addClass("icon-caret-down");
    });


    $(".accordion").on("hide", function (e) {
        $(e.target).parent().find(".icon-caret-down").removeClass("icon-caret-down").addClass("icon-caret-right");
    });

    // $(window).resize(function() {
    //     jsPlumb.repaintEverything();
    // });
    //
    // $('.module_box').add('.estimation_plan_min').scroll(
    //     function(){
    //         jsPlumb.repaintEverything();
    //     }
    // );
    //
    //
    //$('.tabs').tabs();
    //$('.tabs-project').tabs();
    // $('.tabs').tabs({
    //     activate: function (event, ui) {
    //         var scrollTop = $(window).scrollTop();
    //         var active = $('.tabs').tabs('option', 'active');
    //         window.location.hash = $(".tabs ul>li a").eq(active).attr("href");
    //         $(window).scrollTop(scrollTop);
    //     }
    // });
    //
    // $('.tabs-project').tabs({
    //     activate: function (event, ui) {
    //         var scrollTop = $(window).scrollTop();
    //         var active = $('.tabs-project').tabs('option', 'active');
    //         window.location.hash = $(".tabs-project ul>li a").eq(active).attr("href");
    //         $(window).scrollTop(scrollTop);
    //     }
    // });


    // $('.attribute_tooltip').tooltip({'html' : true, 'placement' : 'bottom', container: 'body'});
    // $('.button_attribute_tooltip').tooltip({'html' : true, 'placement' : 'bottom', container: 'body'});
    // $('.profile_description_tooltip').tooltip({'html' : true, 'placement': 'right', container: 'body'});

    $("#run_estimation").bind('click', function() {
        $('.icon-signal').toggle();
        $('.icon-list').toggle();
        $('.icon-align-left').toggle();
        $('.spiner').show();

        // Remove the disabled attribute for submit (if single_entry_attribute)
        $('select').removeAttr('disabled');
    });

    $("#select_pbs_project_elements").on('click', function() {
        $.ajax({
            url: "/select_pbs_project_elements",
            method: "get",
            data: {
                pbs_project_element_id: $(this).val(),
                project_id: $("#project_id").val()
            }
        });
    });

    // Refresh the balancing module input data after change
    $("#select_balancing_attribute").change(function(){
        $('.spiner').show();
        $.ajax({
            url:'/selected_balancing_attribute',
            data: {
                attribute_id: this.value,
                project_id: $('#project_id').val(),
                is_project_show_view:  $('#is_project_show_view').val()
            }
        }).done(function() {
            if($("#select_balancing_attribute").val() == "") {
                $("#select_balancing_attribute").css("border-color", "red");
            }
        });
    });

    // Add red border-color to the select_tag
    if($("#select_balancing_attribute").val() == "") {
        $("#select_balancing_attribute").css("border-color", "red");
    }

    // For the Balancing-Module, We need to copy current text_field value in high and most_likely text_field
//    $("#").change(function(){
//        //_low_effort_person_hour_76
//    });

     $('.component_tree ul li, .widget-content ul li').hover(
        function () {
          $(this.children).css('display', 'block');
        },
        function () {
         $('.block_link').hide();

        }
      );

    $('.block_label, div.block_link').hover(
        function () {
            $('div.block_label.selected_pbs').css('width', 'inherit');
        },
        function () {
            $('div.block_label.selected_pbs').css('width', '100%');
        }
    );


    $("#component_work_element_type_id").change(function(){
      if(this.value == "2"){
        $(".link_tabs").show();
      }
      else{
        $(".link_tabs").hide();
      }
    });

    $('#user_record_number').change(
        function(){
            $.ajax({
                    url:"user_record_number",
                    method: 'GET',
                    data: "nb=" + this.value
            })
    });

    $('#states').change(
        function(){
            $.ajax({
                    url:"display_states",
                    method: 'GET',
                    data: "state=" + this.value
            })
    });

    $("#user_id").change(
            function () {
              $.ajax({ url:'/load_security_for_selected_user',
                data:'user_id=' + this.value + '&project_id=' + $('#project_id').val()
              })
            }
    );

    $("#group_id").change(
            function () {
              $.ajax({ url:'/load_security_for_selected_group',
                data:'group_id=' + this.value + '&project_id=' + $('#project_id').val()
              })
            }
    );

    $("#pbs_list").change(
        function(){
            $('.spiner').show();
            $.ajax({
                url:'/selected_pbs_project_element',
                data: {
                    pbs_id: this.value,
                    project_id: $('#project_id').val(),
                    is_project_show_view:  $('#is_project_show_view').val()
                }
            })
        }
    );

    if(($('.div_tabs_to_disable').data('enable_update')) ==  false){
        $('.div_tabs_to_disable').find('input, textarea, button, select, a').attr('disabled','disabled');
        $('.select_ratio, .back').removeAttr("disabled");
    }

    $(function() {
        $("#users th a, #users .pagination a").on("click", function() {
          $.getScript(this.href);
          return false;
        });
        $("#users_search input").keyup(function() {
          $.get($("#users_search").attr("action"), $("#users_search").serialize(), null, "script");
          return false;
        });
    });

    // var hideFlashes = function () {
    //     $("#notice, #error, #warning, .on_success_global, .on_success_attr, .on_success_attr_set").fadeOut(2000);
    // };
    // setTimeout(hideFlashes, 5000);

    $(".pemodule").hover(
        function(){
            $(this.children).css('display', 'block');
        },
        function () {
            $('.links').hide();
        }
    );

    // $(".pbs").resizable({
    //     alsoResizeReverse: ".estimation_plan"
    // });
    //
    // $(".i").resizable({
    //     alsoResizeReverse: ".o"
    // });
    
//Need to disable or enable the custom_value field according to the record_status value
//    $(".record_status").change(function(){
//        var status_text = $('select.record_status :selected').text();
//        if(status_text == "Custom"){
//            $(".custom_value").removeAttr("disabled");
//        }
//        else{
//            $(".custom_value").attr("disabled", true);
//        }
//    });

    $("#wbs_activity_element_parent_id").change(function(){
        $.ajax({
            url:"/update_status_collection",
            method: 'GET',
            data: "selected_parent_id=" + $('#wbs_activity_element_parent_id').val()
        })
    });

    $("#wbs_activity_element").change(function(){
        $("#add_activity_and_ratio_to_project").attr("disabled", true);
        $.ajax({
            url:"/refresh_wbs_activity_ratios",
            method: 'GET',
            data: "wbs_activity_element_id=" + $('#wbs_activity_element').val()
        })
    });

  // Pre-visualize the selected Wbs-Activity
    preview_selected_wbs_activity();

    //Allow to copy value from one field to another
    $('.copyLib').css('cursor', 'pointer');

    $(".copyLib").click(function(){
        var effort_input_id = "_low"+$(this).data("effort_input_id");
        var first_value = $("#"+effort_input_id).val();

        var low_level =         "_low"+$(this).data("effort_input_id");
        var most_likely_level = "_most_likely"+$(this).data("effort_input_id");
        var high_level =        "_high"+$(this).data("effort_input_id");

        document.getElementById(low_level).value = first_value;
        document.getElementById(most_likely_level).value = first_value;
        document.getElementById(high_level).value = first_value;
        return false;
    });

    // If single_attribute_value, data if low = most_likely=high
    $(".single_entry_attribute").change(function(){
        var effort_input_id = $(this).attr('id');
        var first_value = $("#"+effort_input_id).val();

        var common_on_id = effort_input_id.split("_low")[1];
        var low_level =         "_low"+common_on_id;
        var most_likely_level = "_most_likely"+common_on_id;
        var high_level =        "_high"+common_on_id;

        document.getElementById(low_level).value = first_value;
        document.getElementById(most_likely_level).value = first_value;
        document.getElementById(high_level).value = first_value;
        return false;
    });

    //Update the profiles name and description according to the selected Profile
    $("#profile_id_for_organization").change(function(){
        $.ajax({
            url:"/refresh_organization_profile_data",
            method: 'GET',
            data: {
                profile_id: $(this).val()
            }
        })
    });


    //Update the total ratio value per activity when activity's profile ratio has changed
    update_wbs_activity_ratio_profiles();

    //Find use Attribute in Module: which module is using such attribute
    //ADD selected WBS-Activity to Project
    $("#find_use_pe_attribute").click(function(){
        $.ajax({
            url:"/find_use_attribute",
            method: 'GET',
            data: {
                pe_attribute_id: $(this).data("pe_attribute_id")
            }
        });
        return false;
    });


    $("#find_use_projects").click(function(){
        $.ajax({
            url:"/find_use_project",
            method: 'GET',
            data: {
                project_id: $(this).data("project_id")
            }
        });
        return false;
    });

    $("#find_use_estimation_model").click(function(){
            $.ajax({
                url:"/find_use_estimation_model",
                method: 'GET',
                data: {
                    project_id: $(this).data("project_id")
                }
            });
            return false;
    });


    //Filter estimations according to the estimation version
    $("#filter_projects_version, #filter_organization_projects_version").on('change', function() {
        //if ($("#filter_projects_version").val() !== "") {
        if ($(this).val() !== "") {
            return $.ajax({
                url: "/add_filter_on_project_version",
                method: "get",
                data: {
                    filter_selected: $(this).val(),
                    filter_version: $(this).val(),
                    project_list_name: $(this).attr('id'),
                    organization_id: $(this).data('organization_id'),
                    group_id: $("#group_id").val()
                    //project_ids: $(this).data('project_ids')
                },
                success: function(data) {
                    //return alert("success");
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    return alert("Error! :" + textStatus + ";" + errorThrown );
                }
            });
        }
    });

    $("#select_pbs_project_elements").on('change', function() {
        return $.ajax({
            url: "/select_pbs_project_elements",
            method: "get",
            data: {
                pbs_project_element_id: $(this).val(),
                project_id: $("#project_id").val()
            }
        });
    });

    $("#project_security_level").change(function() {
        return $.ajax({
            url: "/update_project_security_level",
            data: "project_security_level=" + $(this).val() + "&user_id=" + $("#user_id").val()
        });
    });

    $("#project_security_level_group").change(function() {
        return $.ajax({
            url: "/update_project_security_level_group",
            data: "project_security_level=" + $(this).val() + "&group_id=" + $("#group_id").val()
        });
    });

    $("#project_area").change(function() {
        return $.ajax({
            url: "/select_categories",
            data: "project_area_selected=" + $(this).val()
        });
    });

    $("#jump_project_id").change(function() {
        return $.ajax({
            url: "change_selected_project",
            method: "get",
            data: "project_id=" + $(this).val(),
            success: function(data) {
                return document.location.href = "dashboard";
            }
        });
    });

    $(".select_ratio").change(function() {
        return $.ajax({
            url: "/refresh_ratio_elements",
            method: "GET",
            data: "wbs_activity_ratio_id=" + $(this).val(),
            success: function(data) {
                return $(".total-ratio").html(data);
            },
            error: function(XMLHttpRequest, testStatus, errorThrown) {
                return alert("Error!");
            }
        });
    });

    $("#ratio").change(function() {
        if ($(this).val() !== "") {
            return $.ajax({
                url: "/refresh_dashboard_module_project_ratio_elements",
                method: "GET",
                data: "wbs_activity_ratio_id=" + $(this).val(),
                success: function(data) {
                    $("#dashboard_selected_ratio_id").val($(this).val());
                    return $(".total-ratio").html(data);
                },
                error: function(XMLHttpRequest, testStatus, errorThrown) {
                    return alert("Error! :" +  errorThrown);
                }
            });
        }
    });

    // ON DASHBOARD: UPdate the Effort-Breakdown Cost retained value when effort has changed
    update_mp_ratio_element_retained_effort_and_cost_values();


    $("#project_record_number").change(function() {
        return $.ajax({
            url: "project_record_number",
            method: "GET",
            data: "nb=" + $(this).val()
        });
    });

   // Update the organization's estimation statuses
    $("#project_organization_id").change(function(){
        $.ajax({
            url:"/update_organization_estimation_statuses",
            method: 'GET',
            data: {
                project_organization_id: $(this).val(),
                project_id: $("#project_id").val()
            }
        })
    });

    //SHow the selected icon-image on Widget

    //$("option").hover($("#somplace").load($(this).attr("id")));

//    $('#widget_icon_class').on('mouseover change','option',function(e) {
//        $("#icon_class_image").removeClass();
//        $("#icon_class_image").addClass( "icon-user");
//        $("#icon_class_image").addClass( "icon-large" );
//    });

    $("#widget_icon_class").change(function(){
        if ($(this).val() !== ""){
            $("#icon_class_image").removeClass();
            $("#icon_class_image").addClass( $(this).val());
            $("#icon_class_image").addClass( "icon-large blue" );
        }
        else{
            $("#icon_class_image").removeClass();
        }
        return false;
    });


    $("#views_widget_icon_class").change(function(){
        if ($(this).val() !== ""){
            $("#view_icon_class_image").removeClass();
            $("#view_icon_class_image").addClass( $(this).val());
            $("#view_icon_class_image").addClass( "icon-large blue" );
        }
        else{
            $("#view_icon_class_image").removeClass();
        }
        return false;
    });

    // $.ui.plugin.add("resizable", "alsoResizeReverse", {
    //
    //     start: function(event, ui) {
    //
    //         var self = $(this).data("resizable"), o = self.options;
    //
    //         var _store = function(exp) {
    //             $(exp).each(function() {
    //                 $(this).data("resizable-alsoresize-reverse", {
    //                     width: parseInt($(this).width(), 10), height: parseInt($(this).height(), 10),
    //                     left: parseInt($(this).css('left'), 10), top: parseInt($(this).css('top'), 10)
    //                 });
    //             });
    //         };
    //
    //         if (typeof(o.alsoResizeReverse) == 'object' && !o.alsoResizeReverse.parentNode) {
    //             if (o.alsoResizeReverse.length) { o.alsoResize = o.alsoResizeReverse[0];    _store(o.alsoResizeReverse); }
    //             else { $.each(o.alsoResizeReverse, function(exp, c) { _store(exp); }); }
    //         }else{
    //             _store(o.alsoResizeReverse);
    //         }
    //     },
    //
    //     resize: function(event, ui){
    //         var self = $(this).data("resizable"), o = self.options, os = self.originalSize, op = self.originalPosition;
    //
    //         var delta = {
    //                 height: (self.size.height - os.height) || 0, width: (self.size.width - os.width) || 0,
    //                 top: (self.position.top - op.top) || 0, left: (self.position.left - op.left) || 0
    //             },
    //
    //             _alsoResizeReverse = function(exp, c) {
    //                 $(exp).each(function() {
    //                     var el = $(this), start = $(this).data("resizable-alsoresize-reverse"), style = {}, css = c && c.length ? c : ['width', 'height', 'top', 'left'];
    //
    //                     $.each(css || ['width', 'height', 'top', 'left'], function(i, prop) {
    //                         var sum = (start[prop]||0) - (delta[prop]||0); // subtracting instead of adding
    //                         if (sum && sum >= 0)
    //                             style[prop] = sum || null;
    //                     });
    //
    //                     //Opera fixing relative position
    //                     if (/relative/.test(el.css('position')) && $.browser.opera) {
    //                         self._revertToRelativePosition = true;
    //                         el.css({ position: 'absolute', top: 'auto', left: 'auto' });
    //                     }
    //
    //                     el.css(style);
    //                 });
    //             };
    //
    //         if (typeof(o.alsoResizeReverse) == 'object' && !o.alsoResizeReverse.nodeType) {
    //             $.each(o.alsoResizeReverse, function(exp, c) { _alsoResizeReverse(exp, c); });
    //         }else{
    //             _alsoResizeReverse(o.alsoResizeReverse);
    //         }
    //     },
    //
    //     stop: function(event, ui){
    //         var self = $(this).data("resizable");
    //
    //         //Opera fixing relative position
    //         if (self._revertToRelativePosition && $.browser.opera) {
    //             self._revertToRelativePosition = false;
    //             el.css({ position: 'relative' });
    //         }
    //
    //         $(this).removeData("resizable-alsoresize-reverse");
    //     }
    // });


    $(".ui-resizable-handle").css("background-image", 'none');


    //Handler Action link_to event for project history tree view
    $('.node_link_to').on('click', function(){
        var counter = 0,
            i = 0,
            node_ids = new Array();

        var get_function_url = "/show_project_history";

        $('.infovis_project_history input:checked').each(function() {
            // ... increase counter and update the nodes Array
            counter++;
            node_ids.push($(this).attr('value'));
        });

        if($(this).attr('id') === "find_use_projects_from_history"){
            get_function_url = "/find_use_project";
        }
        // if set_checkout_version_path
        else if ($(this).attr('id') === "set_checkout_version_path"){
            get_function_url = "/set_checkout_version";
        }

        // if there is no selected project
        if(node_ids[0] == null){
            //console.log("get_function_url 1 : "+ get_function_url);
            alert($('#select_at_least_one_project').val()) ;
            return false;
        }
        else{
            $.ajax({
                url: get_function_url,
                data: {
                    checked_node_ids: node_ids,
                    counter:  counter,
                    action_id: $(this).attr('id'),
                    project_id: node_ids[0],
                    project_ids: node_ids,
                    current_showed_project_id: $('#current_showed_project_id').val(),
                    from_tree_history_view: true
                }
            })
            return false;
        }
    });

    //Test:  Duplicate organization with a gif animation image
    $("#create_organization_from_image, #yes_delete_project").click(function(){
        $("#display_animation_ajax_loader").show();
    });

});


function toggle_folder(elem){
    if($(elem).parent().parent().next().is('ul') == true)
        $(elem).parent().parent().next().toggle();
}

function refresh_me(data){
    var show_exclude = false;
    //if($('input:checkbox').is(":checked")) {
    if($('#show_excluded_elt:checkbox').is(":checked")) { show_exclude = true; }
    else{ show_exclude = false; }

    $.ajax({
        url:"/refresh_wbs_project_elements",
        method: 'GET',
        data: {
            project_id: $("#project_id").val(),
            show_hidden: show_exclude,
            is_project_show_view: $('#is_project_show_view').val(),
            dataType: "html"
        }
        ,
        success: function(data) {
            $('#wbs_project_elements_section').html(data.html);
            $('ul li').hover(
                function () {
                    $(this.children).css('display', 'block');
                },
                function () {
                    $('.block_link').hide();
                }
            );
        },
        error: function(XMLHttpRequest, testStatus, errorThrown) { alert('Error!'); }
    });
}

function select_or_unselect_all(clicked_elt){
    var mp_id = $(clicked_elt).data("mp_id");
    var rows_or_cols = $(clicked_elt).data("rows_or_cols");
    var at_least_one_selected = false;
    var number_of_elt = 0;
    var number_of_checked_elt = 0;

    if (rows_or_cols == "cols") {
        $('.module_project_'+mp_id+':checkbox').each(function(){
            number_of_elt = number_of_elt+1;
            //at_least_one_selected = (this.checked ? true : false);
            if (this.checked)
                number_of_checked_elt = number_of_checked_elt+1;
        });

        if (number_of_checked_elt==0 || number_of_checked_elt < number_of_elt)
            $('.module_project_'+mp_id).attr("checked", true);
        else
            $('.module_project_'+mp_id).attr("checked", false);
    }
    else{
        if (rows_or_cols == "rows") {
            $('.pbs_'+mp_id+':checkbox').each(function(){
                number_of_elt = number_of_elt+1;
                if (this.checked)
                    number_of_checked_elt = number_of_checked_elt+1;
            });

            if (number_of_checked_elt==0 || number_of_checked_elt < number_of_elt)
                $('.pbs_'+mp_id).attr("checked", true);
            else
                $('.pbs_'+mp_id).attr("checked", false);
        }
    }
}


//Function for Select/Unselect All permission on Permissions page
function select_or_unselect_all_permissions(clicked_elt, cols_data_name, rows_data_name, rows_or_cols_name){
    var group_id = $(clicked_elt).data(cols_data_name);
    var permission_id = $(clicked_elt).data(rows_data_name);
    var rows_or_cols = $(clicked_elt).data("rows_or_cols_"+rows_or_cols_name);
    var at_least_one_selected = false;
    var number_of_elt = 0;
    var number_of_checked_elt = 0;

    if(rows_or_cols == "cols") {
        $('.'+cols_data_name+'_'+group_id+':checkbox').each(function(){

            number_of_elt = number_of_elt+1;
            //at_least_one_selected = (this.checked ? true : false);
            if (this.checked)
                number_of_checked_elt = number_of_checked_elt+1;
        });

        if (number_of_checked_elt==0 || number_of_checked_elt < number_of_elt)
            $('.'+cols_data_name+'_'+group_id).attr("checked", true);
        else
            $('.'+cols_data_name+'_'+group_id).attr("checked", false);
    }
    else{
        if (rows_or_cols == "rows") {
            $('.'+rows_data_name+'_'+permission_id+':checkbox').each(function(){
                number_of_elt = number_of_elt+1;
                if (this.checked)
                    number_of_checked_elt = number_of_checked_elt+1;
            });

            if (number_of_checked_elt==0 || number_of_checked_elt < number_of_elt)
                $('.'+rows_data_name+'_'+permission_id).attr("checked", true);
            else
                $('.'+rows_data_name+'_'+permission_id).attr("checked", false);
        }
    }
}

//Submit the search form
function submit_search_form(){

    var search_option;

    $('#search_all_words, #search_any_words, #search_phrase, #search_query').live("click", function(event) {
        search_option = $(event.target).data("search_option_link");
        $('#search_form').submit();
    });

    $('#search_form').submit(function(){
        $('<input />').attr('type', 'hidden')
            .attr('name', "search_option")
            .attr('value', search_option)
            .appendTo('#search_form');
    });
}

//function to manage a single entry attribute on dashbord
function manage_single_entry_attribute(){
    $(".single_entry_attribute").change(function(){
        var effort_input_id = $(this).attr('id');
        var first_value = $("#"+effort_input_id).val();

        var common_on_id = effort_input_id.split("_low")[1];
        var low_level =         "_low"+common_on_id;
        var most_likely_level = "_most_likely"+common_on_id;
        var high_level =        "_high"+common_on_id;

        document.getElementById(low_level).value = first_value;
        document.getElementById(most_likely_level).value = first_value;
        document.getElementById(high_level).value = first_value;
        //return false;
    });
}

//Function to update BalancingModule input data when it changes
function update_balancing_module_input(){
    // Refresh input data according to the selected balancing attribute
    $("#select_balancing_attribute").change(function(){
        $('.spiner').show();
        $.ajax({
            url:'/selected_balancing_attribute',
            data: {
                attribute_id: this.value,
                project_id: $('#project_id').val(),
                is_project_show_view:  $('#is_project_show_view').val()
            }
        }).done(function() {
            if($("#select_balancing_attribute").val() == "") {
                $("#select_balancing_attribute").css("border-color", "red");
            }
        });
    });
}

//Function that update the Ratio/Profile table on the Wbs-Activity view
function update_wbs_activity_ratio_profiles(){
    //Update the total ratio value per activity when activity's profile ratio has changed
    $('.profiles_per_activity').change(function(){
        var ap_id = $(this).attr('id');
        var ap_value = $('#'+ap_id).val();
        ap_value = parseFloat(ap_value.replace("," , "."));

        if(!isNaN(parseFloat(ap_value)) && isFinite(ap_value)){
            var activity_id = $(this).data('activity_id');
            var profile_id = $(this).data('profile_id');

            var sum_of_wbs_ratio = 0;
            var sum_of_profile_ratio_array = {};

            $("tr").find("[data-activity_id='" + activity_id + "']").each(function(){
                var current_ratio_value = $(this).val();
                if((current_ratio_value != "") && (current_ratio_value != undefined))
                    sum_of_wbs_ratio += parseFloat(current_ratio_value.replace("," , "."));
            });
            $('td#total_ratio_activity_'+activity_id).text(sum_of_wbs_ratio + ' %');

            if(sum_of_wbs_ratio != 100){
                $('td#total_ratio_activity_'+activity_id).addClass('red_color');
                //alert("Attention : le pourcentage de contribution des profils par phase n'est pas à 100%"); //alert("Warning : sum of activity's ratio values is greater than 100 !");
            }
            else {
                $('td#total_ratio_activity_'+activity_id).removeClass('red_color');
            }
        }
        return false;
    });
}

// Function that Preview the selected WBS-Activity
function preview_selected_wbs_activity(){
    $("#project_default_wbs_activity_ratio").change(function(){
        var selection = $('#project_default_wbs_activity_ratio').val();
        if(selection == ""){
            $("#add_activity_and_ratio_to_project").attr("disabled", true);
        }
        else{
            $("#add_activity_and_ratio_to_project").removeAttr("disabled");
            // Update the project wbs-activity view (without saving the values until the user clicks on the "Add" button
            $.ajax({
                url: "/render_selected_wbs_activity_elements",
                method: 'GET',
                data: {
                    project_id: $('#project_id').val(),
                    wbs_activity_elt_id: $('#wbs_activity_element').val(),
                    wbs_activity_ratio_id: $('#project_default_wbs_activity_ratio').val(),
                    is_project_show_view: $('#is_project_show_view').val()
                }
            })
        }
        return false;
    });
}


// Function to update the Cost value when the Retained Effort change
function update_mp_ratio_element_retained_effort_and_cost_value(){

}

// Function to update the Cost value when the Retained Effort change
function update_mp_ratio_element_retained_effort_and_cost_values(){

    // Mise à jour de la valeur booleenne de "is_just_changed" lorsque la valeur de l'effort retenu change
    $('.retained_effort, .retained_cost').change(function(){
        var ap_id = $(this).attr('id');
        var ap_value = $(this).val();
        //ap_value = parseFloat(ap_value.replace("," , "."));

        var mp_ratio_element_id = $(this).data("mp_ratio_element_id");

        if(!isNaN(parseFloat(ap_value)) && isFinite(ap_value)){
            if(ap_value != undefined){
                //$("is_just_changed_"+mp_ratio_element_id).prop( "checked", true );
                $("#is_just_changed_"+mp_ratio_element_id).attr("checked",true);
            }
        }
    });


    $('.retained_cost_SAVE').on('focusin', function(){
        $(this).data('previous_value', $(this).val());
    });

    $('.retained_cost_SAVE').change(function(){
        var cost_elt_id = $(this).attr('id'),
            cost_value = $('#'+cost_elt_id).val(),
            previous_cost_value = $(this).data("previous_value"),
            mp_ratio_element_id = $(this).data("mp_ratio_element_id"),
            level = $(this).data("level");

        // call function to get element parents effort value
        var wbs_activity_element_parent_ids = $(this).data("mp_ratio_element_ancestor_ids"),
            wbs_activity_element_parent_costs = new Object();

        $.each(wbs_activity_element_parent_ids, function( index, value ) {
            var parent_cost_id = "retained_cost_"+level+"_"+value,
                parent_cost_value = $("#"+parent_cost_id).val();
            wbs_activity_element_parent_costs[value] = { cost: parent_cost_value };
        });

        if(!isNaN(parseFloat(cost_value)) && isFinite(cost_value)){
            if(cost_value != undefined){
                return $.ajax({
                    url: "/refresh_dashboard_added_phase_parents_cost_value",
                    method: "GET",
                    data: {
                        wbs_activity_ratio_id: $("#ratio").val(),
                        mp_ratio_element_id: mp_ratio_element_id,
                        level: $(this).data("level"),
                        ratio_value: $("#ratio_values_"+mp_ratio_element_id).val(),
                        cost_value: cost_value,
                        previous_cost_value: previous_cost_value,
                        element_parents_costs: wbs_activity_element_parent_costs
                    },
                    success: function(data) {
                    },
                    error: function(XMLHttpRequest, testStatus, errorThrown) {
                        return alert("Error!");
                    }
                });
            }
        }
    });


    $('.retained_effort_SAVE').on('focusin', function(){
        //console.log("Saving value " + $(this).val());
        $(this).data('previous_value', $(this).val());
    });

    // ON DASHBOARD: UPdate the Effort-Breakdown Cost retained value when effort has changed
    $('.retained_effort_SAVE').change(function(){
        var ap_id = $(this).attr('id');
        var ap_value = $('#'+ap_id).val();
        //ap_value = parseFloat(ap_value.replace("," , "."));
        var previous_value = $(this).data("previous_value");
        var mp_ratio_element_id = $(this).data("mp_ratio_element_id"),
            level = $(this).data("level");

        var cost_field_id = ap_id.replace("effort" , "cost");
        var current_cost_value = $('#'+cost_field_id).val();

        // call function to get element parents effort value
        var wbs_activity_element_parent_ids_string = $(this).data("mp_ratio_element_ancestor_ids");
        var wbs_activity_element_parent_ids = wbs_activity_element_parent_ids_string ; //JSON.parse(wbs_activity_element_parent_ids_string);
        var wbs_activity_element_parent_efforts = new Object();

        //$.each(wbs_activity_element_parent_ids, function( index, value ) {
        //    alert( index + ": " + value );
        //});

        $.each(wbs_activity_element_parent_ids, function( index, value ) {
            var parent_effort_id = "retained_effort_"+level+"_"+value;
            var parent_cost_id = "retained_cost_"+level+"_"+value;

            var parent_effort_value = $("#"+parent_effort_id).val();
            var parent_cost_value = $("#"+parent_cost_id).val();
            wbs_activity_element_parent_efforts[value] = { effort: parent_effort_value, cost: parent_cost_value };
        });

        if(!isNaN(parseFloat(ap_value)) && isFinite(ap_value)){
            if(ap_value != undefined){

                return $.ajax({
                    url: "/refresh_dashboard_retained_effort_and_cost",
                    method: "GET",
                    data: {
                        wbs_activity_ratio_id: $("#ratio").val(),
                        mp_ratio_element_id: mp_ratio_element_id,
                        level: $(this).data("level"),
                        ratio_value: $("#ratio_values_"+mp_ratio_element_id).val(),
                        effort_value: ap_value,
                        previous_cost_value: current_cost_value,
                        previous_effort_value: previous_value,
                        element_parents_ids: wbs_activity_element_parent_ids,
                        element_parents_efforts: wbs_activity_element_parent_efforts
                    },
                    success: function(data) {

                    },
                    error: function(XMLHttpRequest, testStatus, errorThrown) {
                        return alert("Error!");
                    }
                });

            }

        }
    });


    // TEST

    // ON DASHBOARD: UPdate the Effort-Breakdown Cost retained value when effort has changed
    $('.selected_phase_SAVE').change(function(){
        var $obj = $(this);
        var val = $obj.val();
        var checked_or_not;  //var checked_or_not = $(".selected_phase").is(':checked') ? 1 : 0;

        if ($(this).is(':checked') ) {
            checked_or_not = 1;
        }
        else{
            checked_or_not = 0;
        }

        //alert("val = "+ val);
        var mp_ratio_element_id = val; //$(this).data("mp_ratio_element_id");
        var current_ratio_value = $("#ratio_values_"+val).val();
        var global_ratio_value = parseFloat($("#modified_global_ratio").text().replace("," , "."));  //$("#global_ratio").text();

        var retained_modified_effort = parseFloat($("#retained_modified_effort").text().replace("," , "."));  //Retained effort value

        var new_retained_modified_effort, new_ratio_value;

        //alert("global ratio" + global_ratio_value);
        //alert("current ratio" + current_ratio_value);
        //alert("diff ratio" + (global_ratio_value - current_ratio_value));

        // call function to get element parents effort value
        var wbs_activity_element_parent_ids =  $(this).data("mp_ratio_element_ancestor_ids");
        var wbs_activity_element_parent_efforts = new Object();

        var levels = ['low', 'most_likely', 'high'];
        var levelLength = levels.length;

        //for(var i=0; i<levelLength; i+=1) {

            var level = "most_likely"; //levels[i];

            //alert("level = "+ level);
            var retained_effort_level_id = "retained_effort_"+level+"_"+val;
            var retained_cost_level_id = "retained_cost_"+level+"_"+val;

            var retained_effort_level_value = $('#'+retained_effort_level_id).val();
            var retained_cost_level_value = $('#'+retained_cost_level_id).val();

            var effort_value = parseFloat(retained_effort_level_value.replace("," , "."));
            var cost_value = parseFloat(retained_cost_level_value.replace("," , "."));

            //alert("ancestors length = "+ wbs_activity_element_parent_ids.length);

            $.each(wbs_activity_element_parent_ids, function( index, value ) {
                var parent_effort_id = "retained_effort_"+level+"_"+value;
                var parent_cost_id = "retained_cost_"+level+"_"+value;

                var parent_effort_value = $("#"+parent_effort_id).val();
                var parent_cost_value = $("#"+parent_cost_id).val();

                var parent_effort = parseFloat(parent_effort_value.replace("," , "."));
                var parent_cost = parseFloat(parent_cost_value.replace("," , "."));

                var new_parent_effort_value,  new_parent_cost_value;

                if (checked_or_not == 1 ) {
                    //alert("addition");
                    new_parent_effort_value = parent_effort + effort_value;
                    new_parent_cost_value = parent_cost + cost_value;
                    //new_ratio_value = global_ratio_value + current_ratio_value;
                    //new_retained_modified_effort = retained_modified_effort + effort_value;
                }
                else{
                    //alert("non cocher");
                    //alert("soustraction");
                    new_parent_effort_value = parent_effort - effort_value;
                    new_parent_cost_value = parent_cost - cost_value;
                    //new_ratio_value = global_ratio_value - current_ratio_value;
                    //new_retained_modified_effort = retained_modified_effort - effort_value;
                }

                //alert("parent_effort = "+ parent_effort);
                //alert("effort_value = "+ effort_value);

                wbs_activity_element_parent_efforts[value] = { effort: new_parent_effort_value.toFixed(2), cost: new_parent_cost_value.toFixed(2) };

                //update values
                $("#11"+parent_effort_id).val(new_parent_effort_value.toFixed(2));
                $("#11"+parent_cost_id).val(new_parent_cost_value.toFixed(2));

                //$("#"+"retained_effort_most_likely_202").val(new_parent_effort_value);
            });

        if (checked_or_not == 1) {
            //new_ratio_value = global_ratio_value + current_ratio_value;
            new_ratio_value = parseFloat(global_ratio_value) + parseFloat(current_ratio_value);
            new_retained_modified_effort = retained_modified_effort + effort_value;
        }
        else{
            //new_ratio_value = global_ratio_value - current_ratio_value;
            new_ratio_value = parseFloat(global_ratio_value) - parseFloat(current_ratio_value);
            new_retained_modified_effort = retained_modified_effort - effort_value;
        }

        //update Ratio value and retained effort
        $("#modified_global_ratio11").text(new_ratio_value.toFixed(2));
        $("#retained_modified_effort11").text(new_retained_modified_effort.toFixed(2));


        //var ap_id = $(this).attr('id');
        //var ap_value = $('#'+ap_id).val();
        ////ap_value = parseFloat(ap_value.replace("," , "."));
        //var previous_value = $(this).data("previous_value");
        //var cost_field_id = ap_id.replace("effort" , "cost");
        //var current_cost_value = $('#'+cost_field_id).val();


            //if(!isNaN(parseFloat(val)) && isFinite(val)){
            //    if(val != undefined){
                    return $.ajax({
                        url: "/refresh_checked_retained_effort_and_cost",
                        method: "GET",
                        data: {
                            wbs_activity_ratio_id: $("#ratio").val(),
                            mp_ratio_element_id: mp_ratio_element_id,
                            level: level,
                            ratio_value: $("#ratio_values_"+mp_ratio_element_id).val(),
                            element_parents_ids: wbs_activity_element_parent_ids,
                            element_parents_efforts: wbs_activity_element_parent_efforts,
                            retained_modified_effort: new_retained_modified_effort.toFixed(2),
                            modified_global_ratio: new_ratio_value.toFixed(2)

                        },
                        success: function(data) {

                        },
                        error: function(XMLHttpRequest, testStatus, errorThrown) {
                            //return alert("Error!");
                        }
                    });
            //
            //    }
            //
            //}
        //}



    });

    // End test
}

