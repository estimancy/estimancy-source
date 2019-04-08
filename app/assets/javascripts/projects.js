jQuery(function() {

    $('#query-columns').closest('form').submit(function(){
        $('#selected_columns option').prop('selected', true);

        //get the selected value in Array
        var selected_columns = new Array();

        $('#selected_columns option').each(function(){
            selected_columns.push(this.value);
        });

        //update the data in database
        $.ajax({
            url:"/update_available_inline_columns",
            method: 'GET',
            data: {
                query_classname: "Project",
                selected_inline_columns: selected_columns
            }
        })
    });

    $("#select_module").on('change', function() {
        if ($("#select_module").val() !== "") {
            return $.ajax({
                url: "/append_pemodule",
                method: "get",
                data: {
                    module_selected: $(this).val(),
                    project_id: $("#project_id").val(),
                    pbs_project_element_id: $("#select_pbs_project_elements").val()
                }
                ,
                success: function(data) {
                    //return alert("success");
                    //jsPlumb.repaintEverything();
                    //jsPlumb.recalculateOffsets($(ui.item).parents(".draggable"));
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
    $(".select_ratio").change(function() {
        return $.ajax({
            url: "/refresh_ratio_elements",
            method: "GET",
            data: "wbs_activity_ratio_id=" + $(this).val(),
            success: function(data) {
                return $(".total-ratio").html(data);
            },
            error: function(XMLHttpRequest, testStatus, errorThrown) {}
        });
    });
    $(".select_size_unit").change(function() {
        return $.ajax({
            url: "/refresh_value_elements",
            method: "GET",
            data: "size_unit_id=" + $(this).val()
        });
    });
    return $("#project_record_number").change(function() {
        return $.ajax({
            url: "project_record_number",
            method: "GET",
            data: "nb=" + $(this).val()
        });
    });
});