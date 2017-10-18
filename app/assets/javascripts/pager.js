// ################################# Table sorter filter #################################
$(document).ready(function() {

$(function table_sorter_filter() {

    <!-- Adding tablesorter filter save on page reload -->
    $('table')
        .bind('filterInit', function() {
            // check that storage ulility is loaded
            if ($.tablesorter.storage) {
                // get saved filters
                var f = $.tablesorter.storage(this, 'tablesorter-filters') || [];
                $(this).trigger('search', [f]);
            }
        })
        .bind('filterEnd', function(){
            if ($.tablesorter.storage) {
                // save current filters
                var f = $(this).find('.tablesorter-filter').map(function(){
                    return $(this).val() || '';
                }).get();
                $.tablesorter.storage(this, 'tablesorter-filters', f);
            }
        });

    <!-- Adding tablesorter filter save -->


    var pagerOptions = {

        // target the pager markup - see the HTML block below
        container: $(".pager"),

        // use this url format "http:/mydatabase.com?page={page}&size={size}&{sortList:col}"
        ajaxUrl: null,

        // modify the url after all processing has been applied
        customAjaxUrl: function(table, url) { return url; },

        // process ajax so that the data object is returned along with the total number of rows
        // example: { "data" : [{ "ID": 1, "Name": "Foo", "Last": "Bar" }], "total_rows" : 100 }
        ajaxProcessing: function(ajax){
            if (ajax && ajax.hasOwnProperty('data')) {
                // return [ "data", "total_rows" ];
                return [ ajax.total_rows, ajax.data ];
            }
        },

        // output string - default is '{page}/{totalPages}'
        // possible variables: {page}, {totalPages}, {filteredPages}, {startRow}, {endRow}, {filteredRows} and {totalRows}
        output: '{startRow} - {endRow} / {filteredRows} ({totalRows})',

        // apply disabled classname to the pager arrows when the rows at either extreme is visible - default is true
        updateArrows: true,

        // starting page of the pager (zero based index)
        page: 0,

        // reset pager after filtering; set to desired page #
        // set to false to not change page at filter start
        pageReset: 0,

        // Number of visible rows - default is 10
        size: 10,

        // if true, the table will remain the same height no matter how many records are displayed. The space is made up by an empty
        // table row set to a height to compensate; default is false
        fixedHeight: false,

        // remove rows from the table to speed up the sort of large tables.
        // setting this to false, only hides the non-visible rows; needed if you plan to add/remove rows with the pager enabled.
        removeRows: false,

        // css class names of pager arrows
        cssNext: '.next', // next page arrow
        cssPrev: '.prev', // previous page arrow
        cssFirst: '.first', // go to first page arrow
        cssLast: '.last', // go to last page arrow

        cssGoto  : ".pagenum",
        cssPageDisplay: '.pagedisplay', // location of where the "output" is displayed
        cssPageSize: '.pagesize', // page size selector - select dropdown that sets the "size" option

        // class added to arrows when at the extremes (i.e. prev/first arrows are "disabled" when on the first page)
        cssDisabled: 'disabled', // Note there is no period "." in front of this class name
        cssErrorRow: 'tablesorter-errorRow' // ajax error information row

    };

    $.extend($.tablesorter.themes.bootstrap, {
        // these classes are added to the table. To see other table classes available,
        // look here: http://twitter.github.com/bootstrap/base-css.html#tables
        table      : 'table table-bordered',
        header     : 'bootstrap-header', // give the header a gradient background
        footerRow  : '',
        footerCells: '',
        icons      : '', // add "icon-white" to make them white; this icon class is added to the <i> in the header
        sortNone   : 'bootstrap-icon-unsorted',
        sortAsc    : 'icon-chevron-up',
        sortDesc   : 'icon-chevron-down',
        active     : '', // applied when column is sorted
        hover      : '', // use custom css here - bootstrap class may not override it
        filterRow  : '', // filter row class
        even       : '', // odd row zebra striping
        odd        : ''  // even row zebra striping
    });
    $("table thead th.action").data({
        sorter: false,
        filter: false
    });

    // call the tablesorter plugin and apply the uitheme widget
    $("table")
        .tablesorter({
            // this will apply the bootstrap theme if "uitheme" widget is included
            // the widgetOptions.uitheme is no longer required to be set
            theme : "bootstrap",
            widthFixed: true,
            sortList: [[0,0]],
            headerTemplate : '{content} {icon}', // new in v2.7. Needed to add the bootstrap icon!
            debug: true,
            dateFormat       : 'ddmmyyyy',
            // widget code contained in the jquery.tablesorter.widgets.js file
            // use the zebra stripe widget if you plan on hiding any rows (filter widget)

            widgets: [ 'uitheme', 'zebra', 'filter', 'savesort'],
            widgetOptions : {
                filter_cssFilter   : 'tablesorter-filter',
                zebra : ["even", "odd"],
                // jQuery selector string of an element used to reset the filters
                filter_reset : '.reset',
                filter_functions : {
                }
            }

        })
        // bind to pager events
        // *********************
        .bind('pagerChange pagerComplete pagerInitialized pageMoved', function(e, c){
            var msg = '"</span> event triggered, ' + (e.type === 'pagerChange' ? 'going to' : 'now on') +
                ' page <span class="typ">' + (c.page + 1) + '/' + c.totalPages + '</span>';
            $('#display')
                .append('<li><span class="str">"' + e.type + msg + '</li>')
                .find('li:first').remove();
        })

        // initialize the pager plugin
        // ****************************
        //.tablesorterPager(pagerOptions);   // line commenté pour corriger les pager au niveau des onglets

    //Update the current TAB footer
    var current_tab_index = $(".tabs").tabs('option', 'selected');
    var current_tab_name = current_tab_index+1;
    if($("#table_list_"+current_tab_name).length){
        $("#table_list_"+current_tab_name).tablesorterPager(pagerOptions);
    }

    // Get the current tab
    //var current_tab_index = $(".tabs").tabs('option', 'active');
    //var current_tab_index = $(".tabs").tabs('option', 'selected');
    $('.tabs').tabs({

        select: function(event, ui) { //bind click event to link
            var tab_index =  ui.index+1;

            var anchor_value = "";
            $(".current_tab").val("tabs-" + tab_index);

            var re = /#/;
            window.location.hash = ui.tab.hash.replace(re, "#");
            anchor_value = ui.tab.hash;

            $.ajax({
                url:"/",
                method: 'GET',
                data: {
                    anchor_value: anchor_value
                }

            });

            // ADD TABLESORTER TO ALL TABLES WITH ID
            $("#table_list_"+tab_index)

                .tablesorter({
                    // this will apply the bootstrap theme if "uitheme" widget is included
                    // the widgetOptions.uitheme is no longer required to be set
                    theme : "bootstrap",
                    widthFixed: true,
                    sortList: [[0,0]],
                    headerTemplate : '{content} {icon}', // new in v2.7. Needed to add the bootstrap icon!
                    debug: true,
                    dateFormat       : 'ddmmyyyy',
                    // widget code contained in the jquery.tablesorter.widgets.js file
                    // use the zebra stripe widget if you plan on hiding any rows (filter widget)

                    widgets: [ 'uitheme', 'zebra', 'filter', 'savesort'],
                    widgetOptions : {
                        filter_cssFilter   : 'tablesorter-filter',
                        zebra : ["even", "odd"],
                        // jQuery selector string of an element used to reset the filters
                        filter_reset : '.reset',
                        filter_functions : {
                        }
                    }

                })
                // bind to pager events
                // *********************
                .bind('pagerChange pagerComplete pagerInitialized pageMoved', function(e, c){
                    var msg = '"</span> event triggered, ' + (e.type === 'pagerChange' ? 'going to' : 'now on') +
                        ' page <span class="typ">' + (c.page + 1) + '/' + c.totalPages + '</span>';
                    $('#display')
                        .append('<li><span class="str">"' + e.type + msg + '</li>')
                        .find('li:first').remove();
                })

                // initialize the pager plugin
                // ****************************
                .tablesorterPager(pagerOptions);
        }

    });

});


// ################################# TABLE SORTER #################################

/*!
 * TableSorter 2.10.8 - Client-side table sorting with ease!
 * @requires jQuery v1.2.6+
 *
 * Copyright (c) 2007 Christian Bach
 * Examples and docs at: http://tablesorter.com
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * @type jQuery
 * @name tablesorter
 * @cat Plugins/Tablesorter
 * @author Christian Bach/christian.bach@polyester.se
 * @contributor Rob Garrison/https://github.com/Mottie/tablesorter
 */
/*jshint browser:true, jquery:true, unused:false, expr: true */
/*global console:false, alert:false */
!(function($) {
    "use strict";
    $.extend({
        /*jshint supernew:true */
        tablesorter: new function() {

            var ts = this;

            ts.version = "2.10.8";

            ts.parsers = [];
            ts.widgets = [];
            ts.defaults = {

                // *** appearance
                theme            : 'default',  // adds tablesorter-{theme} to the table for styling
                widthFixed       : false,      // adds colgroup to fix widths of columns
                showProcessing   : false,      // show an indeterminate timer icon in the header when the table is sorted or filtered.

                headerTemplate   : '{content}',// header layout template (HTML ok); {content} = innerHTML, {icon} = <i/> (class from cssIcon)
                onRenderTemplate : null,       // function(index, template){ return template; }, (template is a string)
                onRenderHeader   : null,       // function(index){}, (nothing to return)

                // *** functionality
                cancelSelection  : true,       // prevent text selection in the header
                dateFormat       : 'mmddyyyy', // other options: "ddmmyyy" or "yyyymmdd"
                sortMultiSortKey : 'shiftKey', // key used to select additional columns
                sortResetKey     : 'ctrlKey',  // key used to remove sorting on a column
                usNumberFormat   : true,       // false for German "1.234.567,89" or French "1 234 567,89"
                delayInit        : false,      // if false, the parsed table contents will not update until the first sort
                serverSideSorting: false,      // if true, server-side sorting should be performed because client-side sorting will be disabled, but the ui and events will still be used.

                // *** sort options
                headers          : {},         // set sorter, string, empty, locked order, sortInitialOrder, filter, etc.
                ignoreCase       : true,       // ignore case while sorting
                sortForce        : null,       // column(s) first sorted; always applied
                sortList         : [],         // Initial sort order; applied initially; updated when manually sorted
                sortAppend       : null,       // column(s) sorted last; always applied

                sortInitialOrder : 'asc',      // sort direction on first click
                sortLocaleCompare: false,      // replace equivalent character (accented characters)
                sortReset        : false,      // third click on the header will reset column to default - unsorted
                sortRestart      : false,      // restart sort to "sortInitialOrder" when clicking on previously unsorted columns

                emptyTo          : 'bottom',   // sort empty cell to bottom, top, none, zero
                stringTo         : 'max',      // sort strings in numerical column as max, min, top, bottom, zero
                textExtraction   : 'simple',   // text extraction method/function - function(node, table, cellIndex){}
                textSorter       : null,       // use custom text sorter - function(a,b){ return a.sort(b); } // basic sort

                // *** widget options
                widgets: [],                   // method to add widgets, e.g. widgets: ['zebra']
                widgetOptions    : {
                    zebra : [ 'even', 'odd' ]    // zebra widget alternating row class names
                },
                initWidgets      : true,       // apply widgets on tablesorter initialization

                // *** callbacks
                initialized      : null,       // function(table){},

                // *** css class names
                tableClass       : 'tablesorter',
                cssAsc           : 'tablesorter-headerAsc',
                cssChildRow      : 'tablesorter-childRow', // previously "expand-child"
                cssDesc          : 'tablesorter-headerDesc',
                cssHeader        : 'tablesorter-header',
                cssHeaderRow     : 'tablesorter-headerRow',
                cssIcon          : 'tablesorter-icon', //  if this class exists, a <i> will be added to the header automatically
                cssInfoBlock     : 'tablesorter-infoOnly', // don't sort tbody with this class name
                cssProcessing    : 'tablesorter-processing', // processing icon applied to header during sort/filter

                // *** selectors
                selectorHeaders  : '> thead th, > thead td',
                selectorSort     : 'th, td',   // jQuery selector of content within selectorHeaders that is clickable to trigger a sort
                selectorRemove   : '.remove-me',

                // *** advanced
                debug            : false,

                // *** Internal variables
                headerList: [],
                empties: {},
                strings: {},
                parsers: []

                // deprecated; but retained for backwards compatibility
                // widgetZebra: { css: ["even", "odd"] }

            };

            /* debuging utils */
            function log(s) {
                if (typeof console !== "undefined" && typeof console.log !== "undefined") {
//                    console.log(s);
                } else {
                    alert(s);
                }
            }

            function benchmark(s, d) {
                log(s + " (" + (new Date().getTime() - d.getTime()) + "ms)");
            }

            ts.log = log;
            ts.benchmark = benchmark;

            function getElementText(table, node, cellIndex) {
                if (!node) { return ""; }
                var c = table.config,
                    t = c.textExtraction, text = "";
                if (t === "simple") {
                    if (c.supportsTextContent) {
                        text = node.textContent; // newer browsers support this
                    } else {
                        text = $(node).text();
                    }
                } else {
                    if (typeof t === "function") {
                        text = t(node, table, cellIndex);
                    } else if (typeof t === "object" && t.hasOwnProperty(cellIndex)) {
                        text = t[cellIndex](node, table, cellIndex);
                    } else {
                        text = c.supportsTextContent ? node.textContent : $(node).text();
                    }
                }
                return $.trim(text);
            }

            function detectParserForColumn(table, rows, rowIndex, cellIndex) {
                var cur,
                    i = ts.parsers.length,
                    node = false,
                    nodeValue = '',
                    keepLooking = true;
                while (nodeValue === '' && keepLooking) {
                    rowIndex++;
                    if (rows[rowIndex]) {
                        node = rows[rowIndex].cells[cellIndex];
                        nodeValue = getElementText(table, node, cellIndex);
                        if (table.config.debug) {
                            log('Checking if value was empty on row ' + rowIndex + ', column: ' + cellIndex + ': "' + nodeValue + '"');
                        }
                    } else {
                        keepLooking = false;
                    }
                }
                while (--i >= 0) {
                    cur = ts.parsers[i];
                    // ignore the default text parser because it will always be true
                    if (cur && cur.id !== 'text' && cur.is && cur.is(nodeValue, table, node)) {
                        return cur;
                    }
                }
                // nothing found, return the generic parser (text)
                return ts.getParserById('text');
            }

            function buildParserCache(table) {
                var c = table.config,
                // update table bodies in case we start with an empty table
                    tb = c.$tbodies = c.$table.children('tbody:not(.' + c.cssInfoBlock + ')'),
                    rows, list, l, i, h, ch, p, parsersDebug = "";
                if ( tb.length === 0) {
                    return c.debug ? log('*Empty table!* Not building a parser cache') : '';
                }
                rows = tb[0].rows;
                if (rows[0]) {
                    list = [];
                    l = rows[0].cells.length;
                    for (i = 0; i < l; i++) {
                        // tons of thanks to AnthonyM1229 for working out the following selector (issue #74) to make this work in IE8!
                        // More fixes to this selector to work properly in iOS and jQuery 1.8+ (issue #132 & #174)
                        h = c.$headers.filter(':not([colspan])');
                        h = h.add( c.$headers.filter('[colspan="1"]') ) // ie8 fix
                            .filter('[data-column="' + i + '"]:last');
                        ch = c.headers[i];
                        // get column parser
                        p = ts.getParserById( ts.getData(h, ch, 'sorter') );
                        // empty cells behaviour - keeping emptyToBottom for backwards compatibility
                        c.empties[i] = ts.getData(h, ch, 'empty') || c.emptyTo || (c.emptyToBottom ? 'bottom' : 'top' );
                        // text strings behaviour in numerical sorts
                        c.strings[i] = ts.getData(h, ch, 'string') || c.stringTo || 'max';
                        if (!p) {
                            p = detectParserForColumn(table, rows, -1, i);
                        }
                        if (c.debug) {
                            parsersDebug += "column:" + i + "; parser:" + p.id + "; string:" + c.strings[i] + '; empty: ' + c.empties[i] + "\n";
                        }
                        list.push(p);
                    }
                }
                if (c.debug) {
                    log(parsersDebug);
                }
                c.parsers = list;
            }

            /* utils */
            function buildCache(table) {
                var b = table.tBodies,
                    tc = table.config,
                    totalRows,
                    totalCells,
                    parsers = tc.parsers,
                    t, v, i, j, k, c, cols, cacheTime, colMax = [];
                tc.cache = {};
                // if no parsers found, return - it's an empty table.
                if (!parsers) {
                    return tc.debug ? log('*Empty table!* Not building a cache') : '';
                }
                if (tc.debug) {
                    cacheTime = new Date();
                }
                // processing icon
                if (tc.showProcessing) {
                    ts.isProcessing(table, true);
                }
                for (k = 0; k < b.length; k++) {
                    tc.cache[k] = { row: [], normalized: [] };
                    // ignore tbodies with class name from css.cssInfoBlock
                    if (!$(b[k]).hasClass(tc.cssInfoBlock)) {
                        totalRows = (b[k] && b[k].rows.length) || 0;
                        totalCells = (b[k].rows[0] && b[k].rows[0].cells.length) || 0;
                        for (i = 0; i < totalRows; ++i) {
                            /** Add the table data to main data array */
                            c = $(b[k].rows[i]);
                            cols = [];
                            // if this is a child row, add it to the last row's children and continue to the next row
                            if (c.hasClass(tc.cssChildRow)) {
                                tc.cache[k].row[tc.cache[k].row.length - 1] = tc.cache[k].row[tc.cache[k].row.length - 1].add(c);
                                // go to the next for loop
                                continue;
                            }
                            tc.cache[k].row.push(c);
                            for (j = 0; j < totalCells; ++j) {
                                t = getElementText(table, c[0].cells[j], j);
                                // allow parsing if the string is empty, previously parsing would change it to zero,
                                // in case the parser needs to extract data from the table cell attributes
                                v = parsers[j].format(t, table, c[0].cells[j], j);
                                cols.push(v);
                                if ((parsers[j].type || '').toLowerCase() === "numeric") {
                                    colMax[j] = Math.max(Math.abs(v) || 0, colMax[j] || 0); // determine column max value (ignore sign)
                                }
                            }
                            cols.push(tc.cache[k].normalized.length); // add position for rowCache
                            tc.cache[k].normalized.push(cols);
                        }
                        tc.cache[k].colMax = colMax;
                    }
                }
                if (tc.showProcessing) {
                    ts.isProcessing(table); // remove processing icon
                }
                if (tc.debug) {
                    benchmark("Building cache for " + totalRows + " rows", cacheTime);
                }
            }

            // init flag (true) used by pager plugin to prevent widget application
            function appendToTable(table, init) {
                var c = table.config,
                    b = table.tBodies,
                    rows = [],
                    c2 = c.cache,
                    r, n, totalRows, checkCell, $bk, $tb,
                    i, j, k, l, pos, appendTime;
                if (!c2[0]) { return; } // empty table - fixes #206
                if (c.debug) {
                    appendTime = new Date();
                }
                for (k = 0; k < b.length; k++) {
                    $bk = $(b[k]);
                    if ($bk.length && !$bk.hasClass(c.cssInfoBlock)) {
                        // get tbody
                        $tb = ts.processTbody(table, $bk, true);
                        r = c2[k].row;
                        n = c2[k].normalized;
                        totalRows = n.length;
                        checkCell = totalRows ? (n[0].length - 1) : 0;
                        for (i = 0; i < totalRows; i++) {
                            pos = n[i][checkCell];
                            rows.push(r[pos]);
                            // removeRows used by the pager plugin
                            if (!c.appender || !c.removeRows) {
                                l = r[pos].length;
                                for (j = 0; j < l; j++) {
                                    $tb.append(r[pos][j]);
                                }
                            }
                        }
                        // restore tbody
                        ts.processTbody(table, $tb, false);
                    }
                }
                if (c.appender) {
                    c.appender(table, rows);
                }
                if (c.debug) {
                    benchmark("Rebuilt table", appendTime);
                }
                // apply table widgets
                if (!init) { ts.applyWidget(table); }
                // trigger sortend
                $(table).trigger("sortEnd", table);
            }

            // computeTableHeaderCellIndexes from:
            // http://www.javascripttoolbox.com/lib/table/examples.php
            // http://www.javascripttoolbox.com/temp/table_cellindex.html
            function computeThIndexes(t) {
                var matrix = [],
                    lookup = {},
                    cols = 0, // determine the number of columns
                    trs = $(t).find('thead:eq(0), tfoot').children('tr'), // children tr in tfoot - see issue #196
                    i, j, k, l, c, cells, rowIndex, cellId, rowSpan, colSpan, firstAvailCol, matrixrow;
                for (i = 0; i < trs.length; i++) {
                    cells = trs[i].cells;
                    for (j = 0; j < cells.length; j++) {
                        c = cells[j];
                        rowIndex = c.parentNode.rowIndex;
                        cellId = rowIndex + "-" + c.cellIndex;
                        rowSpan = c.rowSpan || 1;
                        colSpan = c.colSpan || 1;
                        if (typeof(matrix[rowIndex]) === "undefined") {
                            matrix[rowIndex] = [];
                        }
                        // Find first available column in the first row
                        for (k = 0; k < matrix[rowIndex].length + 1; k++) {
                            if (typeof(matrix[rowIndex][k]) === "undefined") {
                                firstAvailCol = k;
                                break;
                            }
                        }
                        lookup[cellId] = firstAvailCol;
                        cols = Math.max(firstAvailCol, cols);
                        // add data-column
                        $(c).attr({ 'data-column' : firstAvailCol }); // 'data-row' : rowIndex
                        for (k = rowIndex; k < rowIndex + rowSpan; k++) {
                            if (typeof(matrix[k]) === "undefined") {
                                matrix[k] = [];
                            }
                            matrixrow = matrix[k];
                            for (l = firstAvailCol; l < firstAvailCol + colSpan; l++) {
                                matrixrow[l] = "x";
                            }
                        }
                    }
                }
                t.config.columns = cols; // may not be accurate if # header columns !== # tbody columns
                return lookup;
            }

            function formatSortingOrder(v) {
                // look for "d" in "desc" order; return true
                return (/^d/i.test(v) || v === 1);
            }

            function buildHeaders(table) {
                var header_index = computeThIndexes(table), ch, $t,
                    h, i, t, lock, time, c = table.config;
                c.headerList = [];
                c.headerContent = [];
                if (c.debug) {
                    time = new Date();
                }
                i = c.cssIcon ? '<i class="' + c.cssIcon + '"></i>' : ''; // add icon if cssIcon option exists
                c.$headers = $(table).find(c.selectorHeaders).each(function(index) {
                    $t = $(this);
                    ch = c.headers[index];
                    c.headerContent[index] = this.innerHTML; // save original header content
                    // set up header template
                    t = c.headerTemplate.replace(/\{content\}/g, this.innerHTML).replace(/\{icon\}/g, i);
                    if (c.onRenderTemplate) {
                        h = c.onRenderTemplate.apply($t, [index, t]);
                        if (h && typeof h === 'string') { t = h; } // only change t if something is returned
                    }
                    this.innerHTML = '<div class="tablesorter-header-inner">' + t + '</div>'; // faster than wrapInner

                    if (c.onRenderHeader) { c.onRenderHeader.apply($t, [index]); }

                    this.column = header_index[this.parentNode.rowIndex + "-" + this.cellIndex];
                    this.order = formatSortingOrder( ts.getData($t, ch, 'sortInitialOrder') || c.sortInitialOrder ) ? [1,0,2] : [0,1,2];
                    this.count = -1; // set to -1 because clicking on the header automatically adds one
                    this.lockedOrder = false;
                    lock = ts.getData($t, ch, 'lockedOrder') || false;
                    if (typeof lock !== 'undefined' && lock !== false) {
                        this.order = this.lockedOrder = formatSortingOrder(lock) ? [1,1,1] : [0,0,0];
                    }
                    $t.addClass(c.cssHeader);
                    // add cell to headerList
                    c.headerList[index] = this;
                    // add to parent in case there are multiple rows
                    $t.parent().addClass(c.cssHeaderRow);
                    // allow keyboard cursor to focus on element
                    $t.attr("tabindex", 0);
                });
                // enable/disable sorting
                updateHeader(table);
                if (c.debug) {
                    benchmark("Built headers:", time);
                    log(c.$headers);
                }
            }

            function commonUpdate(table, resort, callback) {
                var c = table.config;
                // remove rows/elements before update
                c.$table.find(c.selectorRemove).remove();
                // rebuild parsers
                buildParserCache(table);
                // rebuild the cache map
                buildCache(table);
                checkResort(c.$table, resort, callback);
            }

            function updateHeader(table) {
                var s, c = table.config;
                c.$headers.each(function(index, th){
                    s = ts.getData( th, c.headers[index], 'sorter' ) === 'false';
                    th.sortDisabled = s;
                    $(th)[ s ? 'addClass' : 'removeClass' ]('sorter-false');
                });
            }

            function setHeadersCss(table) {
                var f, i, j, l,
                    c = table.config,
                    list = c.sortList,
                    css = [c.cssAsc, c.cssDesc],
                // find the footer
                    $t = $(table).find('tfoot tr').children().removeClass(css.join(' '));
                // remove all header information
                c.$headers.removeClass(css.join(' '));
                l = list.length;
                for (i = 0; i < l; i++) {
                    // direction = 2 means reset!
                    if (list[i][1] !== 2) {
                        // multicolumn sorting updating - choose the :last in case there are nested columns
                        f = c.$headers.not('.sorter-false').filter('[data-column="' + list[i][0] + '"]' + (l === 1 ? ':last' : '') );
                        if (f.length) {
                            for (j = 0; j < f.length; j++) {
                                if (!f[j].sortDisabled) {
                                    f.eq(j).addClass(css[list[i][1]]);
                                    // add sorted class to footer, if it exists
                                    if ($t.length) {
                                        $t.filter('[data-column="' + list[i][0] + '"]').eq(j).addClass(css[list[i][1]]);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // automatically add col group, and column sizes if set
            function fixColumnWidth(table) {
                if (table.config.widthFixed && $(table).find('colgroup').length === 0) {
                    var colgroup = $('<colgroup>'),
                        overallWidth = $(table).width();
                    $(table.tBodies[0]).find("tr:first").children("td").each(function() {
                        colgroup.append($('<col>').css('width', parseInt(($(this).width()/overallWidth)*1000, 10)/10 + '%'));
                    });
                    $(table).prepend(colgroup);
                }
            }

            function updateHeaderSortCount(table, list) {
                var s, t, o, c = table.config,
                    sl = list || c.sortList;
                c.sortList = [];
                $.each(sl, function(i,v){
                    // ensure all sortList values are numeric - fixes #127
                    s = [ parseInt(v[0], 10), parseInt(v[1], 10) ];
                    // make sure header exists
                    o = c.headerList[s[0]];
                    if (o) { // prevents error if sorton array is wrong
                        c.sortList.push(s);
                        t = $.inArray(s[1], o.order); // fixes issue #167
                        o.count = t >= 0 ? t : s[1] % (c.sortReset ? 3 : 2);
                    }
                });
            }

            function getCachedSortType(parsers, i) {
                return (parsers && parsers[i]) ? parsers[i].type || '' : '';
            }

            function initSort(table, cell, e){
                var a, i, j, o, s,
                    c = table.config,
                    k = !e[c.sortMultiSortKey],
                    $this = $(table);
                // Only call sortStart if sorting is enabled
                $this.trigger("sortStart", table);
                // get current column sort order
                cell.count = e[c.sortResetKey] ? 2 : (cell.count + 1) % (c.sortReset ? 3 : 2);
                // reset all sorts on non-current column - issue #30
                if (c.sortRestart) {
                    i = cell;
                    c.$headers.each(function() {
                        // only reset counts on columns that weren't just clicked on and if not included in a multisort
                        if (this !== i && (k || !$(this).is('.' + c.cssDesc + ',.' + c.cssAsc))) {
                            this.count = -1;
                        }
                    });
                }
                // get current column index
                i = cell.column;
                // user only wants to sort on one column
                if (k) {
                    // flush the sort list
                    c.sortList = [];
                    if (c.sortForce !== null) {
                        a = c.sortForce;
                        for (j = 0; j < a.length; j++) {
                            if (a[j][0] !== i) {
                                c.sortList.push(a[j]);
                            }
                        }
                    }
                    // add column to sort list
                    o = cell.order[cell.count];
                    if (o < 2) {
                        c.sortList.push([i, o]);
                        // add other columns if header spans across multiple
                        if (cell.colSpan > 1) {
                            for (j = 1; j < cell.colSpan; j++) {
                                c.sortList.push([i + j, o]);
                            }
                        }
                    }
                    // multi column sorting
                } else {
                    // get rid of the sortAppend before adding more - fixes issue #115
                    if (c.sortAppend && c.sortList.length > 1) {
                        if (ts.isValueInArray(c.sortAppend[0][0], c.sortList)) {
                            c.sortList.pop();
                        }
                    }
                    // the user has clicked on an already sorted column
                    if (ts.isValueInArray(i, c.sortList)) {
                        // reverse the sorting direction for all tables
                        for (j = 0; j < c.sortList.length; j++) {
                            s = c.sortList[j];
                            o = c.headerList[s[0]];
                            if (s[0] === i) {
                                s[1] = o.order[o.count];
                                if (s[1] === 2) {
                                    c.sortList.splice(j,1);
                                    o.count = -1;
                                }
                            }
                        }
                    } else {
                        // add column to sort list array
                        o = cell.order[cell.count];
                        if (o < 2) {
                            c.sortList.push([i, o]);
                            // add other columns if header spans across multiple
                            if (cell.colSpan > 1) {
                                for (j = 1; j < cell.colSpan; j++) {
                                    c.sortList.push([i + j, o]);
                                }
                            }
                        }
                    }
                }
                if (c.sortAppend !== null) {
                    a = c.sortAppend;
                    for (j = 0; j < a.length; j++) {
                        if (a[j][0] !== i) {
                            c.sortList.push(a[j]);
                        }
                    }
                }
                // sortBegin event triggered immediately before the sort
                $this.trigger("sortBegin", table);
                // setTimeout needed so the processing icon shows up
                setTimeout(function(){
                    // set css for headers
                    setHeadersCss(table);
                    multisort(table);
                    appendToTable(table);
                }, 1);
            }

            // sort multiple columns
            function multisort(table) { /*jshint loopfunc:true */
                var dir = 0, tc = table.config,
                    sortList = tc.sortList, l = sortList.length, bl = table.tBodies.length,
                    sortTime, i, k, c, colMax, cache, lc, s, order, orgOrderCol;
                if (tc.serverSideSorting || !tc.cache[0]) { // empty table - fixes #206
                    return;
                }
                if (tc.debug) { sortTime = new Date(); }
                for (k = 0; k < bl; k++) {
                    colMax = tc.cache[k].colMax;
                    cache = tc.cache[k].normalized;
                    lc = cache.length;
                    orgOrderCol = (cache && cache[0]) ? cache[0].length - 1 : 0;
                    cache.sort(function(a, b) {
                        // cache is undefined here in IE, so don't use it!
                        for (i = 0; i < l; i++) {
                            c = sortList[i][0];
                            order = sortList[i][1];
                            // fallback to natural sort since it is more robust
                            s = /n/i.test(getCachedSortType(tc.parsers, c)) ? "Numeric" : "Text";
                            s += order === 0 ? "" : "Desc";
                            if (/Numeric/.test(s) && tc.strings[c]) {
                                // sort strings in numerical columns
                                if (typeof (tc.string[tc.strings[c]]) === 'boolean') {
                                    dir = (order === 0 ? 1 : -1) * (tc.string[tc.strings[c]] ? -1 : 1);
                                } else {
                                    dir = (tc.strings[c]) ? tc.string[tc.strings[c]] || 0 : 0;
                                }
                            }
                            var sort = $.tablesorter["sort" + s](table, a[c], b[c], c, colMax[c], dir);
                            if (sort) { return sort; }
                        }
                        return a[orgOrderCol] - b[orgOrderCol];
                    });
                }
                if (tc.debug) { benchmark("Sorting on " + sortList.toString() + " and dir " + order + " time", sortTime); }
            }

            function resortComplete($table, callback){
                $table.trigger('updateComplete');
                if (typeof callback === "function") {
                    callback($table[0]);
                }
            }

            function checkResort($table, flag, callback) {
                // don't try to resort if the table is still processing
                // this will catch spamming of the updateCell method
                if (flag !== false && !$table[0].isProcessing) {
                    $table.trigger("sorton", [$table[0].config.sortList, function(){
                        resortComplete($table, callback);
                    }]);
                } else {
                    resortComplete($table, callback);
                }
            }

            function bindEvents(table){
                var c = table.config,
                    $this = c.$table,
                    j, downTime;
                // apply event handling to headers
                c.$headers
                    // http://stackoverflow.com/questions/5312849/jquery-find-self;
                    .find(c.selectorSort).add( c.$headers.filter(c.selectorSort) )
                    .unbind('mousedown.tablesorter mouseup.tablesorter sort.tablesorter keypress.tablesorter')
                    .bind('mousedown.tablesorter mouseup.tablesorter sort.tablesorter keypress.tablesorter', function(e, external) {
                        // only recognize left clicks or enter
                        if ( ((e.which || e.button) !== 1 && !/sort|keypress/.test(e.type)) || (e.type === 'keypress' && e.which !== 13) ) {
                            return false;
                        }
                        // ignore long clicks (prevents resizable widget from initializing a sort)
                        if (e.type === 'mouseup' && external !== true && (new Date().getTime() - downTime > 250)) { return false; }
                        // set timer on mousedown
                        if (e.type === 'mousedown') {
                            downTime = new Date().getTime();
                            return e.target.tagName === "INPUT" ? '' : !c.cancelSelection;
                        }
                        if (c.delayInit && !c.cache) { buildCache(table); }
                        // jQuery v1.2.6 doesn't have closest()
                        var $cell = /TH|TD/.test(this.tagName) ? $(this) : $(this).parents('th, td').filter(':first'), cell = $cell[0];
                        if (!cell.sortDisabled) {
                            initSort(table, cell, e);
                        }
                    });
                if (c.cancelSelection) {
                    // cancel selection
                    c.$headers
                        .attr('unselectable', 'on')
                        .bind('selectstart', false)
                        .css({
                            'user-select': 'none',
                            'MozUserSelect': 'none' // not needed for jQuery 1.8+
                        });
                }
                // apply easy methods that trigger bound events
                $this
                    .unbind('sortReset update updateRows updateCell updateAll addRows sorton appendCache applyWidgetId applyWidgets refreshWidgets destroy mouseup mouseleave '.split(' ').join('.tablesorter '))
                    .bind("sortReset.tablesorter", function(e){
                        e.stopPropagation();
                        c.sortList = [];
                        setHeadersCss(table);
                        multisort(table);
                        appendToTable(table);
                    })
                    .bind("updateAll.tablesorter", function(e, resort, callback){
                        e.stopPropagation();
                        ts.refreshWidgets(table, true, true);
                        ts.restoreHeaders(table);
                        buildHeaders(table);
                        bindEvents(table);
                        commonUpdate(table, resort, callback);
                    })
                    .bind("update.tablesorter updateRows.tablesorter", function(e, resort, callback) {
                        e.stopPropagation();
                        // update sorting (if enabled/disabled)
                        updateHeader(table);
                        commonUpdate(table, resort, callback);
                    })
                    .bind("updateCell.tablesorter", function(e, cell, resort, callback) {
                        e.stopPropagation();
                        $this.find(c.selectorRemove).remove();
                        // get position from the dom
                        var l, row, icell,
                            $tb = $this.find('tbody'),
                        // update cache - format: function(s, table, cell, cellIndex)
                        // no closest in jQuery v1.2.6 - tbdy = $tb.index( $(cell).closest('tbody') ),$row = $(cell).closest('tr');
                            tbdy = $tb.index( $(cell).parents('tbody').filter(':first') ),
                            $row = $(cell).parents('tr').filter(':first');
                        cell = $(cell)[0]; // in case cell is a jQuery object
                        // tbody may not exist if update is initialized while tbody is removed for processing
                        if ($tb.length && tbdy >= 0) {
                            row = $tb.eq(tbdy).find('tr').index( $row );
                            icell = cell.cellIndex;
                            l = c.cache[tbdy].normalized[row].length - 1;
                            c.cache[tbdy].row[table.config.cache[tbdy].normalized[row][l]] = $row;
                            c.cache[tbdy].normalized[row][icell] = c.parsers[icell].format( getElementText(table, cell, icell), table, cell, icell );
                            checkResort($this, resort, callback);
                        }
                    })
                    .bind("addRows.tablesorter", function(e, $row, resort, callback) {
                        e.stopPropagation();
                        var i, rows = $row.filter('tr').length,
                            dat = [], l = $row[0].cells.length,
                            tbdy = $this.find('tbody').index( $row.parents('tbody').filter(':first') );
                        // fixes adding rows to an empty table - see issue #179
                        if (!c.parsers) {
                            buildParserCache(table);
                        }
                        // add each row
                        for (i = 0; i < rows; i++) {
                            // add each cell
                            for (j = 0; j < l; j++) {
                                dat[j] = c.parsers[j].format( getElementText(table, $row[i].cells[j], j), table, $row[i].cells[j], j );
                            }
                            // add the row index to the end
                            dat.push(c.cache[tbdy].row.length);
                            // update cache
                            c.cache[tbdy].row.push([$row[i]]);
                            c.cache[tbdy].normalized.push(dat);
                            dat = [];
                        }
                        // resort using current settings
                        checkResort($this, resort, callback);
                    })
                    .bind("sorton.tablesorter", function(e, list, callback, init) {
                        e.stopPropagation();
                        $this.trigger("sortStart", this);
                        // update header count index
                        updateHeaderSortCount(table, list);
                        // set css for headers
                        setHeadersCss(table);
                        $this.trigger("sortBegin", this);
                        // sort the table and append it to the dom
                        multisort(table);
                        appendToTable(table, init);
                        if (typeof callback === "function") {
                            callback(table);
                        }
                    })
                    .bind("appendCache.tablesorter", function(e, callback, init) {
                        e.stopPropagation();
                        appendToTable(table, init);
                        if (typeof callback === "function") {
                            callback(table);
                        }
                    })
                    .bind("applyWidgetId.tablesorter", function(e, id) {
                        e.stopPropagation();
                        ts.getWidgetById(id).format(table, c, c.widgetOptions);
                    })
                    .bind("applyWidgets.tablesorter", function(e, init) {
                        e.stopPropagation();
                        // apply widgets
                        ts.applyWidget(table, init);
                    })
                    .bind("refreshWidgets.tablesorter", function(e, all, dontapply){
                        e.stopPropagation();
                        ts.refreshWidgets(table, all, dontapply);
                    })
                    .bind("destroy.tablesorter", function(e, c, cb){
                        e.stopPropagation();
                        ts.destroy(table, c, cb);
                    });
            }

            /* public methods */
            ts.construct = function(settings) {
                return this.each(function() {
                    // if no thead or tbody, or tablesorter is already present, quit
                    if (!this.tHead || this.tBodies.length === 0 || this.hasInitialized === true) {
                        return (this.config && this.config.debug) ? log('stopping initialization! No thead, tbody or tablesorter has already been initialized') : '';
                    }
                    // declare
                    var $this = $(this), table = this,
                        c, k = '',
                        m = $.metadata;
                    // initialization flag
                    table.hasInitialized = false;
                    // table is being processed flag
                    table.isProcessing = true;
                    // new blank config object
                    table.config = {};
                    // merge and extend
                    c = $.extend(true, table.config, ts.defaults, settings);
                    // save the settings where they read
                    $.data(table, "tablesorter", c);
                    if (c.debug) { $.data( table, 'startoveralltimer', new Date()); }
                    // constants
                    c.supportsTextContent = $('<span>x</span>')[0].textContent === 'x';
                    c.supportsDataObject = parseFloat($.fn.jquery) >= 1.4;
                    // digit sort text location; keeping max+/- for backwards compatibility
                    c.string = { 'max': 1, 'min': -1, 'max+': 1, 'max-': -1, 'zero': 0, 'none': 0, 'null': 0, 'top': true, 'bottom': false };
                    // add table theme class only if there isn't already one there
                    if (!/tablesorter\-/.test($this.attr('class'))) {
                        k = (c.theme !== '' ? ' tablesorter-' + c.theme : '');
                    }
                    c.$table = $this.addClass(c.tableClass + k);
                    c.$tbodies = $this.children('tbody:not(.' + c.cssInfoBlock + ')');
                    // build headers
                    buildHeaders(table);
                    // fixate columns if the users supplies the fixedWidth option
                    // do this after theme has been applied
                    fixColumnWidth(table);
                    // try to auto detect column type, and store in tables config
                    buildParserCache(table);
                    // build the cache for the tbody cells
                    // delayInit will delay building the cache until the user starts a sort
                    if (!c.delayInit) { buildCache(table); }
                    // bind all header events and methods
                    bindEvents(table);
                    // get sort list from jQuery data or metadata
                    // in jQuery < 1.4, an error occurs when calling $this.data()
                    if (c.supportsDataObject && typeof $this.data().sortlist !== 'undefined') {
                        c.sortList = $this.data().sortlist;
                    } else if (m && ($this.metadata() && $this.metadata().sortlist)) {
                        c.sortList = $this.metadata().sortlist;
                    }
                    // apply widget init code
                    ts.applyWidget(table, true);
                    // if user has supplied a sort list to constructor
                    if (c.sortList.length > 0) {
                        $this.trigger("sorton", [c.sortList, {}, !c.initWidgets]);
                    } else if (c.initWidgets) {
                        // apply widget format
                        ts.applyWidget(table);
                    }

                    // show processesing icon
                    if (c.showProcessing) {
                        $this
                            .unbind('sortBegin.tablesorter sortEnd.tablesorter')
                            .bind('sortBegin.tablesorter sortEnd.tablesorter', function(e) {
                                ts.isProcessing(table, e.type === 'sortBegin');
                            });
                    }

                    // initialized
                    table.hasInitialized = true;
                    table.isProcessing = false;
                    if (c.debug) {
                        ts.benchmark("Overall initialization time", $.data( table, 'startoveralltimer'));
                    }
                    $this.trigger('tablesorter-initialized', table);
                    if (typeof c.initialized === 'function') { c.initialized(table); }
                });
            };

            // *** Process table ***
            // add processing indicator
            ts.isProcessing = function(table, toggle, $ths) {
                table = $(table);
                var c = table[0].config,
                // default to all headers
                    $h = $ths || table.find('.' + c.cssHeader);
                if (toggle) {
                    if (c.sortList.length > 0) {
                        // get headers from the sortList
                        $h = $h.filter(function(){
                            // get data-column from attr to keep  compatibility with jQuery 1.2.6
                            return this.sortDisabled ? false : ts.isValueInArray( parseFloat($(this).attr('data-column')), c.sortList);
                        });
                    }
                    $h.addClass(c.cssProcessing);
                } else {
                    $h.removeClass(c.cssProcessing);
                }
            };

            // detach tbody but save the position
            // don't use tbody because there are portions that look for a tbody index (updateCell)
            ts.processTbody = function(table, $tb, getIt){
                var holdr;
                if (getIt) {
                    table.isProcessing = true;
                    $tb.before('<span class="tablesorter-savemyplace"/>');
                    holdr = ($.fn.detach) ? $tb.detach() : $tb.remove();
                    return holdr;
                }
                holdr = $(table).find('span.tablesorter-savemyplace');
                $tb.insertAfter( holdr );
                holdr.remove();
                table.isProcessing = false;
            };

            ts.clearTableBody = function(table) {
                $(table)[0].config.$tbodies.empty();
            };

            // restore headers
            ts.restoreHeaders = function(table){
                var c = table.config;
                // don't use c.$headers here in case header cells were swapped
                c.$table.find(c.selectorHeaders).each(function(i){
                    // only restore header cells if it is wrapped
                    // because this is also used by the updateAll method
                    if ($(this).find('.tablesorter-header-inner').length){
                        $(this).html( c.headerContent[i] );
                    }
                });
            };

            ts.destroy = function(table, removeClasses, callback){
                table = $(table)[0];
                if (!table.hasInitialized) { return; }
                // remove all widgets
                ts.refreshWidgets(table, true, true);
                var $t = $(table), c = table.config,
                    $h = $t.find('thead:first'),
                    $r = $h.find('tr.' + c.cssHeaderRow).removeClass(c.cssHeaderRow),
                    $f = $t.find('tfoot:first > tr').children('th, td');
                // remove widget added rows, just in case
                $h.find('tr').not($r).remove();
                // disable tablesorter
                $t
                    .removeData('tablesorter')
                    .unbind('sortReset update updateAll updateRows updateCell addRows sorton appendCache applyWidgetId applyWidgets refreshWidgets destroy mouseup mouseleave keypress sortBegin sortEnd '.split(' ').join('.tablesorter '));
                c.$headers.add($f)
                    .removeClass(c.cssHeader + ' ' + c.cssAsc + ' ' + c.cssDesc)
                    .removeAttr('data-column');
                $r.find(c.selectorSort).unbind('mousedown.tablesorter mouseup.tablesorter keypress.tablesorter');
                ts.restoreHeaders(table);
                if (removeClasses !== false) {
                    $t.removeClass(c.tableClass + ' tablesorter-' + c.theme);
                }
                // clear flag in case the plugin is initialized again
                table.hasInitialized = false;
                if (typeof callback === 'function') {
                    callback(table);
                }
            };

            // *** sort functions ***
            // regex used in natural sort
            ts.regex = [
                /(^([+\-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)?)?$|^0x[0-9a-f]+$|\d+)/gi, // chunk/tokenize numbers & letters
                /(^([\w ]+,?[\w ]+)?[\w ]+,?[\w ]+\d+:\d+(:\d+)?[\w ]?|^\d{1,4}[\/\-]\d{1,4}[\/\-]\d{1,4}|^\w+, \w+ \d+, \d{4})/, //date
                /^0x[0-9a-f]+$/i // hex
            ];

            // Natural sort - https://github.com/overset/javascript-natural-sort
            ts.sortText = function(table, a, b, col) {
                if (a === b) { return 0; }
                var c = table.config, e = c.string[ (c.empties[col] || c.emptyTo ) ],
                    r = ts.regex, xN, xD, yN, yD, xF, yF, i, mx;
                if (a === '' && e !== 0) { return typeof e === 'boolean' ? (e ? -1 : 1) : -e || -1; }
                if (b === '' && e !== 0) { return typeof e === 'boolean' ? (e ? 1 : -1) : e || 1; }
                if (typeof c.textSorter === 'function') { return c.textSorter(a, b, table, col); }
                // chunk/tokenize
                xN = a.replace(r[0], '\\0$1\\0').replace(/\\0$/, '').replace(/^\\0/, '').split('\\0');
                yN = b.replace(r[0], '\\0$1\\0').replace(/\\0$/, '').replace(/^\\0/, '').split('\\0');
                // numeric, hex or date detection
                xD = parseInt(a.match(r[2]),16) || (xN.length !== 1 && a.match(r[1]) && Date.parse(a));
                yD = parseInt(b.match(r[2]),16) || (xD && b.match(r[1]) && Date.parse(b)) || null;
                // first try and sort Hex codes or Dates
                if (yD) {
                    if ( xD < yD ) { return -1; }
                    if ( xD > yD ) { return 1; }
                }
                mx = Math.max(xN.length, yN.length);
                // natural sorting through split numeric strings and default strings
                for (i = 0; i < mx; i++) {
                    // find floats not starting with '0', string or 0 if not defined
                    xF = isNaN(xN[i]) ? xN[i] || 0 : parseFloat(xN[i]) || 0;
                    yF = isNaN(yN[i]) ? yN[i] || 0 : parseFloat(yN[i]) || 0;
                    // handle numeric vs string comparison - number < string - (Kyle Adams)
                    if (isNaN(xF) !== isNaN(yF)) { return (isNaN(xF)) ? 1 : -1; }
                    // rely on string comparison if different types - i.e. '02' < 2 != '02' < '2'
                    if (typeof xF !== typeof yF) {
                        xF += '';
                        yF += '';
                    }
                    if (xF < yF) { return -1; }
                    if (xF > yF) { return 1; }
                }
                return 0;
            };

            ts.sortTextDesc = function(table, a, b, col) {
                if (a === b) { return 0; }
                var c = table.config, e = c.string[ (c.empties[col] || c.emptyTo ) ];
                if (a === '' && e !== 0) { return typeof e === 'boolean' ? (e ? -1 : 1) : e || 1; }
                if (b === '' && e !== 0) { return typeof e === 'boolean' ? (e ? 1 : -1) : -e || -1; }
                if (typeof c.textSorter === 'function') { return c.textSorter(b, a, table, col); }
                return ts.sortText(table, b, a);
            };

            // return text string value by adding up ascii value
            // so the text is somewhat sorted when using a digital sort
            // this is NOT an alphanumeric sort
            ts.getTextValue = function(a, mx, d) {
                if (mx) {
                    // make sure the text value is greater than the max numerical value (mx)
                    var i, l = a ? a.length : 0, n = mx + d;
                    for (i = 0; i < l; i++) {
                        n += a.charCodeAt(i);
                    }
                    return d * n;
                }
                return 0;
            };

            ts.sortNumeric = function(table, a, b, col, mx, d) {
                if (a === b) { return 0; }
                var c = table.config, e = c.string[ (c.empties[col] || c.emptyTo ) ];
                if (a === '' && e !== 0) { return typeof e === 'boolean' ? (e ? -1 : 1) : -e || -1; }
                if (b === '' && e !== 0) { return typeof e === 'boolean' ? (e ? 1 : -1) : e || 1; }
                if (isNaN(a)) { a = ts.getTextValue(a, mx, d); }
                if (isNaN(b)) { b = ts.getTextValue(b, mx, d); }
                return a - b;
            };

            ts.sortNumericDesc = function(table, a, b, col, mx, d) {
                if (a === b) { return 0; }
                var c = table.config, e = c.string[ (c.empties[col] || c.emptyTo ) ];
                if (a === '' && e !== 0) { return typeof e === 'boolean' ? (e ? -1 : 1) : e || 1; }
                if (b === '' && e !== 0) { return typeof e === 'boolean' ? (e ? 1 : -1) : -e || -1; }
                if (isNaN(a)) { a = ts.getTextValue(a, mx, d); }
                if (isNaN(b)) { b = ts.getTextValue(b, mx, d); }
                return b - a;
            };

            // used when replacing accented characters during sorting
            ts.characterEquivalents = {
                "a" : "\u00e1\u00e0\u00e2\u00e3\u00e4\u0105\u00e5", // áàâãäąå
                "A" : "\u00c1\u00c0\u00c2\u00c3\u00c4\u0104\u00c5", // ÁÀÂÃÄĄÅ
                "c" : "\u00e7\u0107\u010d", // çćč
                "C" : "\u00c7\u0106\u010c", // ÇĆČ
                "e" : "\u00e9\u00e8\u00ea\u00eb\u011b\u0119", // éèêëěę
                "E" : "\u00c9\u00c8\u00ca\u00cb\u011a\u0118", // ÉÈÊËĚĘ
                "i" : "\u00ed\u00ec\u0130\u00ee\u00ef\u0131", // íìİîïı
                "I" : "\u00cd\u00cc\u0130\u00ce\u00cf", // ÍÌİÎÏ
                "o" : "\u00f3\u00f2\u00f4\u00f5\u00f6", // óòôõö
                "O" : "\u00d3\u00d2\u00d4\u00d5\u00d6", // ÓÒÔÕÖ
                "ss": "\u00df", // ß (s sharp)
                "SS": "\u1e9e", // ẞ (Capital sharp s)
                "u" : "\u00fa\u00f9\u00fb\u00fc\u016f", // úùûüů
                "U" : "\u00da\u00d9\u00db\u00dc\u016e" // ÚÙÛÜŮ
            };
            ts.replaceAccents = function(s) {
                var a, acc = '[', eq = ts.characterEquivalents;
                if (!ts.characterRegex) {
                    ts.characterRegexArray = {};
                    for (a in eq) {
                        if (typeof a === 'string') {
                            acc += eq[a];
                            ts.characterRegexArray[a] = new RegExp('[' + eq[a] + ']', 'g');
                        }
                    }
                    ts.characterRegex = new RegExp(acc + ']');
                }
                if (ts.characterRegex.test(s)) {
                    for (a in eq) {
                        if (typeof a === 'string') {
                            s = s.replace( ts.characterRegexArray[a], a );
                        }
                    }
                }
                return s;
            };

            // *** utilities ***
            ts.isValueInArray = function(v, a) {
                var i, l = a.length;
                for (i = 0; i < l; i++) {
                    if (a[i][0] === v) {
                        return true;
                    }
                }
                return false;
            };

            ts.addParser = function(parser) {
                var i, l = ts.parsers.length, a = true;
                for (i = 0; i < l; i++) {
                    if (ts.parsers[i].id.toLowerCase() === parser.id.toLowerCase()) {
                        a = false;
                    }
                }
                if (a) {
                    ts.parsers.push(parser);
                }
            };

            ts.getParserById = function(name) {
                var i, l = ts.parsers.length;
                for (i = 0; i < l; i++) {
                    if (ts.parsers[i].id.toLowerCase() === (name.toString()).toLowerCase()) {
                        return ts.parsers[i];
                    }
                }
                return false;
            };

            ts.addWidget = function(widget) {
                ts.widgets.push(widget);
            };

            ts.getWidgetById = function(name) {
                var i, w, l = ts.widgets.length;
                for (i = 0; i < l; i++) {
                    w = ts.widgets[i];
                    if (w && w.hasOwnProperty('id') && w.id.toLowerCase() === name.toLowerCase()) {
                        return w;
                    }
                }
            };

            ts.applyWidget = function(table, init) {
                table = $(table)[0]; // in case this is called externally
                var c = table.config,
                    wo = c.widgetOptions,
                    widgets = [],
                    time, i, w, wd;
                if (c.debug) { time = new Date(); }
                if (c.widgets.length) {
                    // ensure unique widget ids
                    c.widgets = $.grep(c.widgets, function(v, k){
                        return $.inArray(v, c.widgets) === k;
                    });
                    // build widget array & add priority as needed
                    $.each(c.widgets || [], function(i,n){
                        wd = ts.getWidgetById(n);
                        if (wd && wd.id) {
                            // set priority to 10 if not defined
                            if (!wd.priority) { wd.priority = 10; }
                            widgets[i] = wd;
                        }
                    });
                    // sort widgets by priority
                    widgets.sort(function(a, b){
                        return a.priority < b.priority ? -1 : a.priority === b.priority ? 0 : 1;
                    });

                    // add/update selected widgets
                    $.each(widgets, function(i,w){
                        if (w) {
                            if (init) {
                                if (w.hasOwnProperty('options')) {
                                    wo = table.config.widgetOptions = $.extend( true, {}, w.options, wo );
                                }
                                if (w.hasOwnProperty('init')) {
                                    w.init(table, w, c, wo);
                                }
                            } else if (!init && w.hasOwnProperty('format')) {
                                w.format(table, c, wo, false);
                            }
                        }
                    });
                }
                if (c.debug) {
                    w = c.widgets.length;
                    benchmark("Completed " + (init === true ? "initializing " : "applying ") + w + " widget" + (w !== 1 ? "s" : ""), time);
                }
            };

            ts.refreshWidgets = function(table, doAll, dontapply) {
                table = $(table)[0]; // see issue #243
                var i, c = table.config,
                    cw = c.widgets,
                    w = ts.widgets, l = w.length;
                // remove previous widgets
                for (i = 0; i < l; i++){
                    if ( w[i] && w[i].id && (doAll || $.inArray( w[i].id, cw ) < 0) ) {
                        if (c.debug) { log( 'Refeshing widgets: Removing ' + w[i].id  ); }
                        if (w[i].hasOwnProperty('remove')) { w[i].remove(table, c, c.widgetOptions); }
                    }
                }
                if (dontapply !== true) {
                    ts.applyWidget(table, doAll);
                }
            };

            // get sorter, string, empty, etc options for each column from
            // jQuery data, metadata, header option or header class name ("sorter-false")
            // priority = jQuery data > meta > headers option > header class name
            ts.getData = function(h, ch, key) {
                var val = '', $h = $(h), m, cl;
                if (!$h.length) { return ''; }
                m = $.metadata ? $h.metadata() : false;
                cl = ' ' + ($h.attr('class') || '');
                if (typeof $h.data(key) !== 'undefined' || typeof $h.data(key.toLowerCase()) !== 'undefined'){
                    // "data-lockedOrder" is assigned to "lockedorder"; but "data-locked-order" is assigned to "lockedOrder"
                    // "data-sort-initial-order" is assigned to "sortInitialOrder"
                    val += $h.data(key) || $h.data(key.toLowerCase());
                } else if (m && typeof m[key] !== 'undefined') {
                    val += m[key];
                } else if (ch && typeof ch[key] !== 'undefined') {
                    val += ch[key];
                } else if (cl !== ' ' && cl.match(' ' + key + '-')) {
                    // include sorter class name "sorter-text", etc; now works with "sorter-my-custom-parser"
                    val = cl.match( new RegExp('\\s' + key + '-([\\w-]+)') )[1] || '';
                }
                return $.trim(val);
            };

            ts.formatFloat = function(s, table) {
                if (typeof s !== 'string' || s === '') { return s; }
                // allow using formatFloat without a table; defaults to US number format
                var i,
                    t = table && table.config ? table.config.usNumberFormat !== false :
                        typeof table !== "undefined" ? table : true;
                if (t) {
                    // US Format - 1,234,567.89 -> 1234567.89
                    s = s.replace(/,/g,'');
                } else {
                    // German Format = 1.234.567,89 -> 1234567.89
                    // French Format = 1 234 567,89 -> 1234567.89
                    s = s.replace(/[\s|\.]/g,'').replace(/,/g,'.');
                }
                if(/^\s*\([.\d]+\)/.test(s)) {
                    // make (#) into a negative number -> (10) = -10
                    s = s.replace(/^\s*\(/,'-').replace(/\)/,'');
                }
                i = parseFloat(s);
                // return the text instead of zero
                return isNaN(i) ? $.trim(s) : i;
            };

            ts.isDigit = function(s) {
                // replace all unwanted chars and match
                return isNaN(s) ? (/^[\-+(]?\d+[)]?$/).test(s.toString().replace(/[,.'"\s]/g, '')) : true;
            };

        }()
    });

    // make shortcut
    var ts = $.tablesorter;

    // extend plugin scope
    $.fn.extend({
        tablesorter: ts.construct
    });

    // add default parsers
    ts.addParser({
        id: "text",
        is: function() {
            return true;
        },
        format: function(s, table) {
            var c = table.config;
            if (s) {
                s = $.trim( c.ignoreCase ? s.toLocaleLowerCase() : s );
                s = c.sortLocaleCompare ? ts.replaceAccents(s) : s;
            }
            return s;
        },
        type: "text"
    });

    ts.addParser({
        id: "digit",
        is: function(s) {
            return ts.isDigit(s);
        },
        format: function(s, table) {
            var n = ts.formatFloat((s || '').replace(/[^\w,. \-()]/g, ""), table);
            return s && typeof n === 'number' ? n : s ? $.trim( s && table.config.ignoreCase ? s.toLocaleLowerCase() : s ) : s;
        },
        type: "numeric"
    });

    ts.addParser({
        id: "currency",
        is: function(s) {
            return (/^\(?\d+[\u00a3$\u20ac\u00a4\u00a5\u00a2?.]|[\u00a3$\u20ac\u00a4\u00a5\u00a2?.]\d+\)?$/).test((s || '').replace(/[,. ]/g,'')); // £$€¤¥¢
        },
        format: function(s, table) {
            var n = ts.formatFloat((s || '').replace(/[^\w,. \-()]/g, ""), table);
            return s && typeof n === 'number' ? n : s ? $.trim( s && table.config.ignoreCase ? s.toLocaleLowerCase() : s ) : s;
        },
        type: "numeric"
    });

    ts.addParser({
        id: "ipAddress",
        is: function(s) {
            return (/^\d{1,3}[\.]\d{1,3}[\.]\d{1,3}[\.]\d{1,3}$/).test(s);
        },
        format: function(s, table) {
            var i, a = s ? s.split(".") : '',
                r = "",
                l = a.length;
            for (i = 0; i < l; i++) {
                r += ("00" + a[i]).slice(-3);
            }
            return s ? ts.formatFloat(r, table) : s;
        },
        type: "numeric"
    });

    ts.addParser({
        id: "url",
        is: function(s) {
            return (/^(https?|ftp|file):\/\//).test(s);
        },
        format: function(s) {
            return s ? $.trim(s.replace(/(https?|ftp|file):\/\//, '')) : s;
        },
        type: "text"
    });

    ts.addParser({
        id: "isoDate",
        is: function(s) {
            return (/^\d{4}[\/\-]\d{1,2}[\/\-]\d{1,2}/).test(s);
        },
        format: function(s, table) {
            return s ? ts.formatFloat((s !== "") ? (new Date(s.replace(/-/g, "/")).getTime() || "") : "", table) : s;
        },
        type: "numeric"
    });

    ts.addParser({
        id: "percent",
        is: function(s) {
            return (/(\d\s*?%|%\s*?\d)/).test(s) && s.length < 15;
        },
        format: function(s, table) {
            return s ? ts.formatFloat(s.replace(/%/g, ""), table) : s;
        },
        type: "numeric"
    });

    ts.addParser({
        id: "usLongDate",
        is: function(s) {
            // two digit years are not allowed cross-browser
            // Jan 01, 2013 12:34:56 PM or 01 Jan 2013
            return (/^[A-Z]{3,10}\.?\s+\d{1,2},?\s+(\d{4})(\s+\d{1,2}:\d{2}(:\d{2})?(\s+[AP]M)?)?$/i).test(s) || (/^\d{1,2}\s+[A-Z]{3,10}\s+\d{4}/i).test(s);
        },
        format: function(s, table) {
            return s ? ts.formatFloat( (new Date(s.replace(/(\S)([AP]M)$/i, "$1 $2")).getTime() || ''), table) : s;
        },
        type: "numeric"
    });

    ts.addParser({
        id: "shortDate", // "mmddyyyy", "ddmmyyyy" or "yyyymmdd"
        is: function(s) {
            // testing for ##-##-#### or ####-##-##, so it's not perfect; time can be included
            return (/(^\d{1,2}[\/\s]\d{1,2}[\/\s]\d{4})|(^\d{4}[\/\s]\d{1,2}[\/\s]\d{1,2})/).test((s || '').replace(/\s+/g," ").replace(/[\-.,]/g, "/"));
        },
        format: function(s, table, cell, cellIndex) {
            if (s) {
                var c = table.config, ci = c.headerList[cellIndex],
                    format = ci.dateFormat || ts.getData( ci, c.headers[cellIndex], 'dateFormat') || c.dateFormat;
                s = s.replace(/\s+/g," ").replace(/[\-.,]/g, "/"); // escaped - because JSHint in Firefox was showing it as an error
                if (format === "mmddyyyy") {
                    s = s.replace(/(\d{1,2})[\/\s](\d{1,2})[\/\s](\d{4})/, "$3/$1/$2");
                } else if (format === "ddmmyyyy") {
                    s = s.replace(/(\d{1,2})[\/\s](\d{1,2})[\/\s](\d{4})/, "$3/$2/$1");
                } else if (format === "yyyymmdd") {
                    s = s.replace(/(\d{4})[\/\s](\d{1,2})[\/\s](\d{1,2})/, "$1/$2/$3");
                }
            }
            return s ? ts.formatFloat( (new Date(s).getTime() || ''), table) : s;
        },
        type: "numeric"
    });

    ts.addParser({
        id: "time",
        is: function(s) {
            return (/^(([0-2]?\d:[0-5]\d)|([0-1]?\d:[0-5]\d\s?([AP]M)))$/i).test(s);
        },
        format: function(s, table) {
            return s ? ts.formatFloat( (new Date("2000/01/01 " + s.replace(/(\S)([AP]M)$/i, "$1 $2")).getTime() || ""), table) : s;
        },
        type: "numeric"
    });

    ts.addParser({
        id: "metadata",
        is: function() {
            return false;
        },
        format: function(s, table, cell) {
            var c = table.config,
                p = (!c.parserMetadataName) ? 'sortValue' : c.parserMetadataName;
            return $(cell).metadata()[p];
        },
        type: "numeric"
    });

    // add default widgets
    ts.addWidget({
        id: "zebra",
        priority: 90,
        format: function(table, c, wo) {
            var $tb, $tv, $tr, row, even, time, k, l,
                child = new RegExp(c.cssChildRow, 'i'),
                b = c.$tbodies;
            if (c.debug) {
                time = new Date();
            }
            for (k = 0; k < b.length; k++ ) {
                // loop through the visible rows
                $tb = b.eq(k);
                l = $tb.children('tr').length;
                if (l > 1) {
                    row = 0;
                    $tv = $tb.children('tr:visible');
                    // revered back to using jQuery each - strangely it's the fastest method
                    /*jshint loopfunc:true */
                    $tv.each(function(){
                        $tr = $(this);
                        // style children rows the same way the parent row was styled
                        if (!child.test(this.className)) { row++; }
                        even = (row % 2 === 0);
                        $tr.removeClass(wo.zebra[even ? 1 : 0]).addClass(wo.zebra[even ? 0 : 1]);
                    });
                }
            }
            if (c.debug) {
                ts.benchmark("Applying Zebra widget", time);
            }
        },
        remove: function(table, c, wo){
            var k, $tb,
                b = c.$tbodies,
                rmv = (wo.zebra || [ "even", "odd" ]).join(' ');
            for (k = 0; k < b.length; k++ ){
                $tb = $.tablesorter.processTbody(table, b.eq(k), true); // remove tbody
                $tb.children().removeClass(rmv);
                $.tablesorter.processTbody(table, $tb, false); // restore tbody
            }
        }
    });

})(jQuery);

// ################################# TABLE SORTER PLUGIN #################################

/*! tablesorter pager plugin minified - updated 5/27/2013 */
;(function(f){f.extend({tablesorterPager:new function(){this.defaults={container:null,ajaxUrl:null,customAjaxUrl:function(b,a){return a},ajaxObject:{dataType:"json"},ajaxProcessing:function(){return[0,[],null]},output:"{startRow} to {endRow} of {totalRows} rows",updateArrows:!0,page:0,size:10,fixedHeight:!1,removeRows:!1,cssFirst:".first",cssPrev:".prev",cssNext:".next",cssLast:".last",cssGoto:".gotoPage",cssPageDisplay:".pagedisplay",cssPageSize:".pagesize",cssErrorRow:"tablesorter-errorRow",cssDisabled:"disabled", totalRows:0,totalPages:0,filteredRows:0,filteredPages:0};var t=this,u=function(b,a){var d=b.cssDisabled,e=!!a,c=Math.min(b.totalPages,b.filteredPages);b.updateArrows&&(b.$container.find(b.cssFirst+","+b.cssPrev)[e||0===b.page?"addClass":"removeClass"](d),b.$container.find(b.cssNext+","+b.cssLast)[e||b.page===c-1?"addClass":"removeClass"](d))},q=function(b,a,d){var e,c,g;e=b.config;c=f(b).hasClass("hasFilters")&&!a.ajaxUrl;a.totalPages=Math.ceil(a.totalRows/a.size);a.filteredRows=c?e.$tbodies.eq(0).children("tr:not(."+ (e.widgetOptions&&e.widgetOptions.filter_filteredRow||"filtered")+","+e.selectorRemove+")").length:a.totalRows;a.filteredPages=c?Math.ceil(a.filteredRows/a.size)||1:a.totalPages;if(0<=Math.min(a.totalPages,a.filteredPages)&&(g=a.size*a.page>a.filteredRows,a.startRow=g?1:0===a.filteredRows?0:a.size*a.page+1,a.page=g?0:a.page,a.endRow=Math.min(a.filteredRows,a.totalRows,a.size*(a.page+1)),c=a.$container.find(a.cssPageDisplay),e=a.output.replace(/\{(page|filteredRows|filteredPages|totalPages|startRow|endRow|totalRows)\}/gi, function(b){return{"{page}":a.page+1,"{filteredRows}":a.filteredRows,"{filteredPages}":a.filteredPages,"{totalPages}":a.totalPages,"{startRow}":a.startRow,"{endRow}":a.endRow,"{totalRows}":a.totalRows}[b]}),c.length&&(c["INPUT"===c[0].tagName?"val":"html"](e),a.$goto.length))){g="";c=Math.min(a.totalPages,a.filteredPages);for(e=1;e<=c;e++)g+="<option>"+e+"</option>";a.$goto.html(g).val(a.page+1)}u(a);a.initialized&&!1!==d&&f(b).trigger("pagerComplete",a)},r=function(b,a){var d,e=b.config.$tbodies.eq(0); if(a.fixedHeight&&(e.find("tr.pagerSavedHeightSpacer").remove(),d=f.data(b,"pagerSavedHeight")))d-=e.height(),5<d&&(f.data(b,"pagerLastSize")===a.size&&e.children("tr:visible").length<a.size)&&e.append('<tr class="pagerSavedHeightSpacer '+b.config.selectorRemove.replace(/(tr)?\./g,"")+'" style="height:'+d+'px;"></tr>')},x=function(b,a){var d=b.config.$tbodies.eq(0);d.find("tr.pagerSavedHeightSpacer").remove();f.data(b,"pagerSavedHeight",d.height());r(b,a);f.data(b,"pagerLastSize",a.size)},s=function(b, a){if(!a.ajaxUrl){var d;d=b.config;var e=d.$tbodies.eq(0).children("tr:not(."+d.cssChildRow+")"),c=e.length,f=a.page*a.size,p=f+a.size,k=d.widgetOptions&&d.widgetOptions.filter_filteredRow||"filtered",h=0;for(d=0;d<c;d++)e[d].className.match(k)||(e[d].style.display=h>=f&&h<p?"":"none",h++)}},y=function(b,a){a.size=parseInt(a.$size.val(),10)||a.size;f.data(b,"pagerLastSize",a.size);u(a);a.removeRows||(s(b,a),f(b).bind("sortEnd.pager filterEnd.pager",function(){s(b,a)}))},A=function(b,a,d,e,c){if("function"=== typeof d.ajaxProcessing){var g,p,k,h,l,m=f(a),n=a.config,z=m.find("thead th").length,j="";b=d.ajaxProcessing(b,a)||[0,[]];g=isNaN(b[0])&&!isNaN(b[1]);m.find("thead tr."+d.cssErrorRow).remove();if(c)f('<tr class="'+d.cssErrorRow+'"><td style="text-align:center;" colspan="'+z+'">'+(0===e.status?"Not connected, verify Network":404===e.status?"Requested page not found [404]":500===e.status?"Internal Server Error [500]":"parsererror"===c?"Requested JSON parse failed":"timeout"===c?"Time out error":"abort"=== c?"Ajax Request aborted":"Uncaught error: "+e.statusText+" ["+e.status+"]")+"</td></tr>").click(function(){f(this).remove()}).appendTo(m.find("thead:first")),n.$tbodies.eq(0).empty();else{d.totalRows=b[g?1:0]||d.totalRows||0;e=b[g?0:1]||[];c=e.length;l=b[2];if(e instanceof jQuery)n.$tbodies.eq(0).empty().append(e);else if(e.length){if(0<c)for(b=0;b<c;b++){j+="<tr>";for(g=0;g<e[b].length;g++)j+="<td>"+e[b][g]+"</td>";j+="</tr>"}n.$tbodies.eq(0).html(j)}l&&l.length===z&&(h=(p=m.hasClass("hasStickyHeaders"))? n.$sticky.children("thead:first").children().children():"",k=m.find("tfoot tr:first").children(),m.find("th."+n.cssHeader).each(function(a){var b=f(this),c;b.find("."+n.cssIcon).length?(c=b.find("."+n.cssIcon).clone(!0),b.find(".tablesorter-header-inner").html(l[a]).append(c),p&&h.length&&(c=h.eq(a).find("."+n.cssIcon).clone(!0),h.eq(a).find(".tablesorter-header-inner").html(l[a]).append(c))):(b.find(".tablesorter-header-inner").html(l[a]),p&&h.length&&h.eq(a).find(".tablesorter-header-inner").html(l[a])); k.eq(a).html(l[a])}))}n.showProcessing&&f.tablesorter.isProcessing(a);m.trigger("update");d.totalPages=Math.ceil(d.totalRows/d.size);q(a,d);r(a,d);d.initialized&&m.trigger("pagerChange",d)}d.initialized||(d.initialized=!0,f(a).trigger("pagerInitialized",d))},v=function(b,a,d){d.isDisabled=!1;var e,c,g,j,k=a.length;e=d.page*d.size;var h=e+d.size;if(!(1>k)){d.initialized&&f(b).trigger("pagerChange",d);if(d.removeRows){h>a.length&&(h=a.length);f.tablesorter.clearTableBody(b);for(j=f.tablesorter.processTbody(b, b.config.$tbodies.eq(0),!0);e<h;e++){g=a[e];k=g.length;for(c=0;c<k;c++)j.appendChild(g[c])}f.tablesorter.processTbody(b,j,!1)}else s(b,d);d.page>=d.totalPages&&B(b,d);q(b,d);d.isDisabled||r(b,d);f(b).trigger("applyWidgets")}},C=function(b,a){a.ajax?u(a,!0):(a.isDisabled=!0,f.data(b,"pagerLastPage",a.page),f.data(b,"pagerLastSize",a.size),a.page=0,a.size=a.totalRows,a.totalPages=1,f(b).find("tr.pagerSavedHeightSpacer").remove(),v(b,b.config.rowsCopy,a));a.$size.add(a.$goto).each(function(){f(this).addClass(a.cssDisabled)[0].disabled= !0})},j=function(b,a,d){if(!a.isDisabled){var e=Math.min(a.totalPages,a.filteredPages);0>a.page&&(a.page=0);a.page>e-1&&0!==e&&(a.page=e-1);if(a.ajax){var c,e=a.ajaxUrl?a.ajaxUrl.replace(/\{page([\-+]\d+)?\}/,function(b,c){return a.page+(c?parseInt(c,10):0)}).replace(/\{size\}/g,a.size):"",g=b.config.sortList,j=a.currentFilters||[],k=e.match(/\{\s*sort(?:List)?\s*:\s*(\w*)\s*\}/),h=e.match(/\{\s*filter(?:List)?\s*:\s*(\w*)\s*\}/),l=[];k&&(k=k[1],f.each(g,function(a,b){l.push(k+"["+b[0]+"]="+b[1])}), e=e.replace(/\{\s*sort(?:List)?\s*:\s*(\w*)\s*\}/g,l.length?l.join("&"):k),l=[]);h&&(h=h[1],f.each(j,function(a,b){b&&l.push(h+"["+a+"]="+encodeURIComponent(b))}),e=e.replace(/\{\s*filter(?:List)?\s*:\s*(\w*)\s*\}/g,l.length?l.join("&"):h));"function"===typeof a.customAjaxUrl&&(e=a.customAjaxUrl(b,e));c=e;var m=f(document),e=b.config;""!==c&&(e.showProcessing&&f.tablesorter.isProcessing(b,!0),m.bind("ajaxError.pager",function(d,e,f,g){c.match(f.url)&&(A(null,b,a,e,g),m.unbind("ajaxError.pager"))}), a.ajaxObject.url=c,a.ajaxObject.success=function(c){A(c,b,a);m.unbind("ajaxError.pager");"function"===typeof a.oldAjaxSuccess&&a.oldAjaxSuccess(c)},f.ajax(a.ajaxObject))}else a.ajax||v(b,b.config.rowsCopy,a);f.data(b,"pagerLastPage",a.page);f.data(b,"pagerUpdateTriggered",!0);a.initialized&&!1!==d&&f(b).trigger("pageMoved",a)}},w=function(b,a,d){d.size=a;d.$size.val(a);f.data(b,"pagerLastPage",d.page);f.data(b,"pagerLastSize",d.size);d.totalPages=Math.ceil(d.totalRows/d.size);j(b,d)},E=function(b, a){a.page=0;j(b,a)},B=function(b,a){a.page=Math.min(a.totalPages,a.filteredPages)-1;j(b,a)},F=function(b,a){a.page++;a.page>=Math.min(a.totalPages,a.filteredPages)-1&&(a.page=Math.min(a.totalPages,a.filteredPages)-1);j(b,a)},G=function(b,a){a.page--;0>=a.page&&(a.page=0);j(b,a)},D=function(b,a,d){var e=a.$size.removeClass(a.cssDisabled).removeAttr("disabled");a.$goto.removeClass(a.cssDisabled).removeAttr("disabled");a.isDisabled=!1;a.page=f.data(b,"pagerLastPage")||a.page||0;a.size=f.data(b,"pagerLastSize")|| parseInt(e.find("option[selected]").val(),10)||a.size;e.val(a.size);a.totalPages=Math.ceil(Math.min(a.totalPages,a.filteredPages)/a.size);d&&(f(b).trigger("update"),w(b,a.size,a),y(b,a),r(b,a))};t.appender=function(b,a){var d=b.config.pager;d.ajax||(b.config.rowsCopy=a,d.totalRows=a.length,d.size=f.data(b,"pagerLastSize")||d.size,d.totalPages=Math.ceil(d.totalRows/d.size),v(b,a,d))};t.construct=function(b){return this.each(function(){if(this.config&&this.hasInitialized){var a,d,e=this.config,c=e.pager= f.extend({},f.tablesorterPager.defaults,b),g=this,p=g.config,k=f(g),h=c.$container=f(c.container).addClass("tablesorter-pager").show();c.oldAjaxSuccess=c.oldAjaxSuccess||c.ajaxObject.success;e.appender=t.appender;k.unbind("filterStart.pager filterEnd.pager sortEnd.pager disable.pager enable.pager destroy.pager update.pager pageSize.pager").bind("filterStart.pager",function(a,b){f.data(g,"pagerUpdateTriggered",!1);c.currentFilters=b}).bind("filterEnd.pager sortEnd.pager",function(){f.data(g,"pagerUpdateTriggered")? f.data(g,"pagerUpdateTriggered",!1):(j(g,c,!1),q(g,c,!1),r(g,c))}).bind("disable.pager",function(a){a.stopPropagation();C(g,c)}).bind("enable.pager",function(a){a.stopPropagation();D(g,c,!0)}).bind("destroy.pager",function(a){a.stopPropagation();C(g,c);c.$container.hide();g.config.appender=null;f(g).unbind("destroy.pager sortEnd.pager filterEnd.pager enable.pager disable.pager")}).bind("update.pager",function(a){a.stopPropagation();s(g,c)}).bind("pageSize.pager",function(a,b){a.stopPropagation(); w(g,parseInt(b,10)||10,c);s(g,c);q(g,c,!1);c.$size.length&&c.$size.val(c.size)}).bind("pageSet.pager",function(a,b){a.stopPropagation();c.page=(parseInt(b,10)||1)-1;c.$goto.length&&c.$goto.val(c.size);j(g,c);q(g,c,!1)});a=[c.cssFirst,c.cssPrev,c.cssNext,c.cssLast];d=[E,G,F,B];h.find(a.join(",")).unbind("click.pager").bind("click.pager",function(){var b,e=f(this),h=a.length;if(!e.hasClass(c.cssDisabled))for(b=0;b<h;b++)if(e.is(a[b])){d[b](g,c);break}return!1});c.$goto=h.find(c.cssGoto);c.$goto.length&& (c.$goto.unbind("change").bind("change",function(){c.page=f(this).val()-1;j(g,c)}),q(g,c,!1));c.$size=h.find(c.cssPageSize);c.$size.length&&c.$size.unbind("change.pager").bind("change.pager",function(){c.$size.val(f(this).val());f(this).hasClass(c.cssDisabled)||(w(g,parseInt(f(this).val(),10),c),x(g,c));return!1});c.initialized=!1;k.trigger("pagerBeforeInitialized",c);D(g,c,!1);"string"===typeof c.ajaxUrl?(c.ajax=!0,p.widgetOptions.filter_serversideFiltering=!0,p.serverSideSorting=!0,j(g,c)):(c.ajax= !1,f(this).trigger("appendCache",!0),y(g,c));x(g,c);c.ajax||(c.initialized=!0,f(g).trigger("pagerInitialized",c))}})}}});f.fn.extend({tablesorterPager:f.tablesorterPager.construct})})(jQuery);


// ################################# TABLE SORTER WIDGET #################################

/*! tableSorter 2.8+ widgets - updated 6/4/2013
 *
 * Column Styles
 * Column Filters
 * Column Resizing
 * Sticky Header
 * UI Theme (generalized)
 * Save Sort
 * [ "columns", "filter", "resizable", "stickyHeaders", "uitheme", "saveSort" ]
 */
/*jshint browser:true, jquery:true, unused:false, loopfunc:true */
/*global jQuery: false, localStorage: false, navigator: false */
;(function($){
    "use strict";
    var ts = $.tablesorter = $.tablesorter || {};

    ts.themes = {
        "bootstrap" : {
            table      : 'table table-bordered table-striped',
            header     : 'bootstrap-header', // give the header a gradient background
            footerRow  : '',
            footerCells: '',
            icons      : '', // add "icon-white" to make them white; this icon class is added to the <i> in the header
            sortNone   : 'bootstrap-icon-unsorted',
            sortAsc    : 'icon-chevron-up',
            sortDesc   : 'icon-chevron-down',
            active     : '', // applied when column is sorted
            hover      : '', // use custom css here - bootstrap class may not override it
            filterRow  : '', // filter row class
            even       : '', // even row zebra striping
            odd        : ''  // odd row zebra striping
        },
        "jui" : {
            table      : 'ui-widget ui-widget-content ui-corner-all', // table classes
            header     : 'ui-widget-header ui-corner-all ui-state-default', // header classes
            footerRow  : '',
            footerCells: '',
            icons      : 'ui-icon', // icon class added to the <i> in the header
            sortNone   : 'ui-icon-carat-2-n-s',
            sortAsc    : 'ui-icon-carat-1-n',
            sortDesc   : 'ui-icon-carat-1-s',
            active     : 'ui-state-active', // applied when column is sorted
            hover      : 'ui-state-hover',  // hover class
            filterRow  : '',
            even       : 'ui-widget-content', // even row zebra striping
            odd        : 'ui-state-default'   // odd row zebra striping
        }
    };

// *** Store data in local storage, with a cookie fallback ***
    /* IE7 needs JSON library for JSON.stringify - (http://caniuse.com/#search=json)
     if you need it, then include https://github.com/douglascrockford/JSON-js

     $.parseJSON is not available is jQuery versions older than 1.4.1, using older
     versions will only allow storing information for one page at a time

     // *** Save data (JSON format only) ***
     // val must be valid JSON... use http://jsonlint.com/ to ensure it is valid
     var val = { "mywidget" : "data1" }; // valid JSON uses double quotes
     // $.tablesorter.storage(table, key, val);
     $.tablesorter.storage(table, 'tablesorter-mywidget', val);

     // *** Get data: $.tablesorter.storage(table, key); ***
     v = $.tablesorter.storage(table, 'tablesorter-mywidget');
     // val may be empty, so also check for your data
     val = (v && v.hasOwnProperty('mywidget')) ? v.mywidget : '';
     alert(val); // "data1" if saved, or "" if not
     */
    ts.storage = function(table, key, val){
        var d, k, ls = false, v = {},
            id = table.id || $('.tablesorter').index( $(table) ),
            url = window.location.pathname;
        // https://gist.github.com/paulirish/5558557
        if ("localStorage" in window) {
            try {
                window.localStorage.setItem('_tmptest', 'temp');
                ls = true;
                window.localStorage.removeItem('_tmptest');
            } catch(e) {}
        }
        // *** get val ***
        if ($.parseJSON){
            if (ls){
                v = $.parseJSON(localStorage[key] || '{}');
            } else {
                k = document.cookie.split(/[;\s|=]/); // cookie
                d = $.inArray(key, k) + 1; // add one to get from the key to the value
                v = (d !== 0) ? $.parseJSON(k[d] || '{}') : {};
            }
        }
        // allow val to be an empty string to
        if ((val || val === '') && window.JSON && JSON.hasOwnProperty('stringify')){
            // add unique identifiers = url pathname > table ID/index on page > data
            if (!v[url]) {
                v[url] = {};
            }
            v[url][id] = val;
            // *** set val ***
            if (ls){
                localStorage[key] = JSON.stringify(v);
            } else {
                d = new Date();
                d.setTime(d.getTime() + (31536e+6)); // 365 days
                document.cookie = key + '=' + (JSON.stringify(v)).replace(/\"/g,'\"') + '; expires=' + d.toGMTString() + '; path=/';
            }
        } else {
            return v && v[url] ? v[url][id] : {};
        }
    };

// Add a resize event to table headers
// **************************
    ts.addHeaderResizeEvent = function(table, disable, options){
        var defaults = {
                timer : 250
            },
            o = $.extend({}, defaults, options),
            c = table.config,
            wo = c.widgetOptions,
            headers,
            checkSizes = function(){
                wo.resize_flag = true;
                headers = [];
                c.$headers.each(function(){
                    var d = $.data(this, 'savedSizes'),
                        w = this.offsetWidth,
                        h = this.offsetHeight;
                    if (w !== d[0] || h !== d[1]) {
                        $.data(this, 'savedSizes', [ w, h ]);
                        headers.push(this);
                    }
                });
                if (headers.length) { c.$table.trigger('resize', [ headers ]); }
                wo.resize_flag = false;
            };
        clearInterval(wo.resize_timer);
        if (disable) {
            wo.resize_flag = false;
            return false;
        }
        c.$headers.each(function(){
            $.data(this, 'savedSizes', [ this.offsetWidth, this.offsetHeight ]);
        });
        wo.resize_timer = setInterval(function(){
            if (wo.resize_flag) { return; }
            checkSizes();
        }, o.timer);
    };

// Widget: General UI theme
// "uitheme" option in "widgetOptions"
// **************************
    ts.addWidget({
        id: "uitheme",
        priority: 10,
        options: {
            uitheme : 'jui'
        },
        format: function(table, c, wo){
            var time, klass, $el, $tar,
                t = ts.themes,
                $t = c.$table,
                theme = c.theme !== 'default' ? c.theme : wo.uitheme || 'jui',
                o = t[ t[theme] ? theme : t[wo.uitheme] ? wo.uitheme : 'jui'],
                $h = c.$headers,
                sh = 'tr.' + (wo.stickyHeaders || 'tablesorter-stickyHeader'),
                rmv = o.sortNone + ' ' + o.sortDesc + ' ' + o.sortAsc;
            if (c.debug) { time = new Date(); }
            if (!$t.hasClass('tablesorter-' + theme) || c.theme === theme || !table.hasInitialized){
                // update zebra stripes
                if (o.even !== '') { wo.zebra[0] += ' ' + o.even; }
                if (o.odd !== '') { wo.zebra[1] += ' ' + o.odd; }
                // add table/footer class names
                t = $t
                    // remove other selected themes; use widgetOptions.theme_remove
                    .removeClass( c.theme === '' ? '' : 'tablesorter-' + c.theme )
                    .addClass('tablesorter-' + theme + ' ' + o.table) // add theme widget class name
                    .find('tfoot');
                if (t.length) {
                    t
                        .find('tr').addClass(o.footerRow)
                        .children('th, td').addClass(o.footerCells);
                }
                // update header classes
                $h
                    .addClass(o.header)
                    .filter(':not(.sorter-false)')
                    .bind('mouseenter.tsuitheme mouseleave.tsuitheme', function(e){
                        // toggleClass with switch added in jQuery 1.3
                        $(this)[ e.type === 'mouseenter' ? 'addClass' : 'removeClass' ](o.hover);
                    });
                if (!$h.find('.tablesorter-wrapper').length) {
                    // Firefox needs this inner div to position the resizer correctly
                    $h.wrapInner('<div class="tablesorter-wrapper" style="position:relative;height:100%;width:100%"></div>');
                }
                if (c.cssIcon){
                    // if c.cssIcon is '', then no <i> is added to the header
                    $h.find('.' + c.cssIcon).addClass(o.icons);
                }
                if ($t.hasClass('hasFilters')){
                    $h.find('.tablesorter-filter-row').addClass(o.filterRow);
                }
            }
            $.each($h, function(i){
                $el = $(this);
                $tar = (c.cssIcon) ? $el.find('.' + c.cssIcon) : $el;
                if (this.sortDisabled){
                    // no sort arrows for disabled columns!
                    $el.removeClass(rmv);
                    $tar.removeClass(rmv + ' tablesorter-icon ' + o.icons);
                } else {
                    t = ($t.hasClass('hasStickyHeaders')) ? $t.find(sh).find('th').eq(i).add($el) : $el;
                    klass = ($el.hasClass(c.cssAsc)) ? o.sortAsc : ($el.hasClass(c.cssDesc)) ? o.sortDesc : $el.hasClass(c.cssHeader) ? o.sortNone : '';
                    $el[klass === o.sortNone ? 'removeClass' : 'addClass'](o.active);
                    $tar.removeClass(rmv).addClass(klass);
                }
            });
            if (c.debug){
                ts.benchmark("Applying " + theme + " theme", time);
            }
        },
        remove: function(table, c, wo){
            var $t = c.$table,
                theme = typeof wo.uitheme === 'object' ? 'jui' : wo.uitheme || 'jui',
                o = typeof wo.uitheme === 'object' ? wo.uitheme : ts.themes[ ts.themes.hasOwnProperty(theme) ? theme : 'jui'],
                $h = $t.children('thead').children(),
                rmv = o.sortNone + ' ' + o.sortDesc + ' ' + o.sortAsc;
            $t
                .removeClass('tablesorter-' + theme + ' ' + o.table)
                .find(c.cssHeader).removeClass(o.header);
            $h
                .unbind('mouseenter.tsuitheme mouseleave.tsuitheme') // remove hover
                .removeClass(o.hover + ' ' + rmv + ' ' + o.active)
                .find('.tablesorter-filter-row').removeClass(o.filterRow);
            $h.find('.tablesorter-icon').removeClass(o.icons);
        }
    });

// Widget: Column styles
// "columns", "columns_thead" (true) and
// "columns_tfoot" (true) options in "widgetOptions"
// **************************
    ts.addWidget({
        id: "columns",
        priority: 30,
        options : {
            columns : [ "primary", "secondary", "tertiary" ]
        },
        format: function(table, c, wo){
            var $tb, $tr, $td, $t, time, last, rmv, i, k, l,
                $tbl = c.$table,
                b = c.$tbodies,
                list = c.sortList,
                len = list.length,
            // keep backwards compatibility, for now
                css = (c.widgetColumns && c.widgetColumns.hasOwnProperty('css')) ? c.widgetColumns.css || css :
                    (wo && wo.hasOwnProperty('columns')) ? wo.columns || css : css;
            last = css.length-1;
            rmv = css.join(' ');
            if (c.debug){
                time = new Date();
            }
            // check if there is a sort (on initialization there may not be one)
            for (k = 0; k < b.length; k++ ){
                $tb = ts.processTbody(table, b.eq(k), true); // detach tbody
                $tr = $tb.children('tr');
                l = $tr.length;
                // loop through the visible rows
                $tr.each(function(){
                    $t = $(this);
                    if (this.style.display !== 'none'){
                        // remove all columns class names
                        $td = $t.children().removeClass(rmv);
                        // add appropriate column class names
                        if (list && list[0]){
                            // primary sort column class
                            $td.eq(list[0][0]).addClass(css[0]);
                            if (len > 1){
                                for (i = 1; i < len; i++){
                                    // secondary, tertiary, etc sort column classes
                                    $td.eq(list[i][0]).addClass( css[i] || css[last] );
                                }
                            }
                        }
                    }
                });
                ts.processTbody(table, $tb, false);
            }
            // add classes to thead and tfoot
            $tr = wo.columns_thead !== false ? 'thead tr' : '';
            if (wo.columns_tfoot !== false) {
                $tr += ($tr === '' ? '' : ',') + 'tfoot tr';
            }
            if ($tr.length) {
                $t = $tbl.find($tr).children().removeClass(rmv);
                if (list && list[0]){
                    // primary sort column class
                    $t.filter('[data-column="' + list[0][0] + '"]').addClass(css[0]);
                    if (len > 1){
                        for (i = 1; i < len; i++){
                            // secondary, tertiary, etc sort column classes
                            $t.filter('[data-column="' + list[i][0] + '"]').addClass(css[i] || css[last]);
                        }
                    }
                }
            }
            if (c.debug){
                ts.benchmark("Applying Columns widget", time);
            }
        },
        remove: function(table, c, wo){
            var k, $tb,
                b = c.$tbodies,
                rmv = (wo.columns || [ "primary", "secondary", "tertiary" ]).join(' ');
            c.$headers.removeClass(rmv);
            c.$table.children('tfoot').children('tr').children('th, td').removeClass(rmv);
            for (k = 0; k < b.length; k++ ){
                $tb = ts.processTbody(table, b.eq(k), true); // remove tbody
                $tb.children('tr').each(function(){
                    $(this).children().removeClass(rmv);
                });
                ts.processTbody(table, $tb, false); // restore tbody
            }
        }
    });

// Widget: filter
// **************************
    ts.addWidget({
        id: "filter",
        priority: 50,
        options : {
            filter_childRows     : false, // if true, filter includes child row content in the search
            filter_columnFilters : true,  // if true, a filter will be added to the top of each table column
            filter_cssFilter     : 'tablesorter-filter', // css class name added to the filter row & each input in the row
            filter_filteredRow   : 'filtered', // class added to filtered rows; needed by pager plugin
            filter_formatter     : null,  // add custom filter elements to the filter row
            filter_functions     : null,  // add custom filter functions using this option
            filter_hideFilters   : false, // collapse filter row when mouse leaves the area
            filter_ignoreCase    : true,  // if true, make all searches case-insensitive
            filter_liveSearch    : true,  // if true, search column content while the user types (with a delay)
            filter_onlyAvail     : 'filter-onlyAvail', // a header with a select dropdown & this class name will only show available (visible) options within the drop down
            filter_reset         : null,  // jQuery selector string of an element used to reset the filters
            filter_searchDelay   : 300,   // typing delay in milliseconds before starting a search
            filter_startsWith    : false, // if true, filter start from the beginning of the cell contents
            filter_useParsedData : false, // filter all data using parsed content
            filter_serversideFiltering : false, // if true, server-side filtering should be performed because client-side filtering will be disabled, but the ui and events will still be used.
            filter_defaultAttrib : 'data-value', // data attribute in the header cell that contains the default filter value

            // regex used in filter "check" functions - not for general use and not documented
            filter_regex : {
                "regex" : /^\/((?:\\\/|[^\/])+)\/([mig]{0,3})?$/, // regex to test for regex
                "child" : /tablesorter-childRow/, // child row class name; this gets updated in the script
                "filtered" : /filtered/, // filtered (hidden) row class name; updated in the script
                "type" : /undefined|number/, // check type
                "exact" : /(^[\"|\'|=])|([\"|\'|=]$)/g, // exact match
                "nondigit" : /[^\w,. \-()]/g, // replace non-digits (from digit & currency parser)
                "operators" : /[<>=]/g // replace operators
            }
        },
        format: function(table, c, wo){
            if (c.parsers && !c.$table.hasClass('hasFilters')){
                var i, j, k, l, val, ff, x, xi, st, sel, str,
                    ft, ft2, $th, rg, s, t, dis, col,
                    fmt = ts.formatFloat,
                    last = '', // save last filter search
                    $ths = c.$headers,
                    css = wo.filter_cssFilter,
                    $t = c.$table.addClass('hasFilters'),
                    b = $t.find('tbody'),
                    cols = c.parsers.length,
                    parsed, time, timer,

                // dig fer gold
                    checkFilters = function(filter){
                        var arry = $.isArray(filter),
                            v = (arry) ? filter : ts.getFilters(table),
                            cv = (v || []).join(''); // combined filter values
                        // add filter array back into inputs
                        if (arry) {
                            ts.setFilters( $t, v );
                        }
                        if (wo.filter_hideFilters){
                            // show/hide filter row as needed
                            $t.find('.tablesorter-filter-row').trigger( cv === '' ? 'mouseleave' : 'mouseenter' );
                        }
                        // return if the last search is the same; but filter === false when updating the search
                        // see example-widget-filter.html filter toggle buttons
                        if (last === cv && filter !== false) { return; }
                        $t.trigger('filterStart', [v]);
                        if (c.showProcessing) {
                            // give it time for the processing icon to kick in
                            setTimeout(function(){
                                findRows(filter, v, cv);
                                return false;
                            }, 30);
                        } else {
                            findRows(filter, v, cv);
                            return false;
                        }
                    },
                    findRows = function(filter, v, cv){
                        var $tb, $tr, $td, cr, r, l, ff, time, r1, r2, searchFiltered;
                        if (c.debug) { time = new Date(); }
                        for (k = 0; k < b.length; k++ ){
                            if (b.eq(k).hasClass(c.cssInfoBlock)) { continue; } // ignore info blocks, issue #264
                            $tb = ts.processTbody(table, b.eq(k), true);
                            $tr = $tb.children('tr:not(.' + c.cssChildRow + ')');
                            l = $tr.length;
                            if (cv === '' || wo.filter_serversideFiltering){
                                $tb.children().show().removeClass(wo.filter_filteredRow);
                            } else {
                                // optimize searching only through already filtered rows - see #313
                                searchFiltered = true;
                                r = $t.data('lastSearch') || [];
                                $.each(v, function(i,val){
                                    // check for changes from beginning of filter; but ignore if there is a logical "or" in the string
                                    searchFiltered = (val || '').indexOf(r[i] || '') === 0 && searchFiltered && !/(\s+or\s+|\|)/g.test(val || '');
                                });
                                // can't search when all rows are hidden - this happens when looking for exact matches
                                if (searchFiltered && $tr.filter(':visible').length === 0) { searchFiltered = false; }
                                // loop through the rows
                                for (j = 0; j < l; j++){
                                    r = $tr[j].className;
                                    // skip child rows & already filtered rows
                                    if ( wo.filter_regex.child.test(r) || (searchFiltered && wo.filter_regex.filtered.test(r)) ) { continue; }
                                    r = true;
                                    cr = $tr.eq(j).nextUntil('tr:not(.' + c.cssChildRow + ')');
                                    // so, if "table.config.widgetOptions.filter_childRows" is true and there is
                                    // a match anywhere in the child row, then it will make the row visible
                                    // checked here so the option can be changed dynamically
                                    t = (cr.length && wo.filter_childRows) ? cr.text() : '';
                                    t = wo.filter_ignoreCase ? t.toLocaleLowerCase() : t;
                                    $td = $tr.eq(j).children('td');
                                    for (i = 0; i < cols; i++){
                                        // ignore if filter is empty or disabled
                                        if (v[i]){
                                            // check if column data should be from the cell or from parsed data
                                            if (wo.filter_useParsedData || parsed[i]){
                                                x = c.cache[k].normalized[j][i];
                                            } else {
                                                // using older or original tablesorter
                                                x = $.trim($td.eq(i).text());
                                            }
                                            xi = !wo.filter_regex.type.test(typeof x) && wo.filter_ignoreCase ? x.toLocaleLowerCase() : x;
                                            ff = r; // if r is true, show that row
                                            // val = case insensitive, v[i] = case sensitive
                                            val = wo.filter_ignoreCase ? v[i].toLocaleLowerCase() : v[i];
                                            if (wo.filter_functions && wo.filter_functions[i]){
                                                if (wo.filter_functions[i] === true){
                                                    // default selector; no "filter-select" class
                                                    ff = ($ths.filter('[data-column="' + i + '"]:last').hasClass('filter-match')) ? xi.search(val) >= 0 : v[i] === x;
                                                } else if (typeof wo.filter_functions[i] === 'function'){
                                                    // filter callback( exact cell content, parser normalized content, filter input value, column index )
                                                    ff = wo.filter_functions[i](x, c.cache[k].normalized[j][i], v[i], i);
                                                } else if (typeof wo.filter_functions[i][v[i]] === 'function'){
                                                    // selector option function
                                                    ff = wo.filter_functions[i][v[i]](x, c.cache[k].normalized[j][i], v[i], i);
                                                }
                                                // Look for regex
                                            } else if (wo.filter_regex.regex.test(val)){
                                                rg = wo.filter_regex.regex.exec(val);
                                                try {
                                                    ff = new RegExp(rg[1], rg[2]).test(xi);
                                                } catch (err){
                                                    ff = false;
                                                }
                                                // Look for quotes or equals to get an exact match; ignore type since xi could be numeric
                                                /*jshint eqeqeq:false */
                                            } else if (val.replace(wo.filter_regex.exact, '') == xi){
                                                ff = true;
                                                // Look for a not match
                                            } else if (/^\!/.test(val)){
                                                val = val.replace('!','');
                                                s = xi.search($.trim(val));
                                                ff = val === '' ? true : !(wo.filter_startsWith ? s === 0 : s >= 0);
                                                // Look for operators >, >=, < or <=
                                            } else if (/^[<>]=?/.test(val)){
                                                s = fmt(val.replace(wo.filter_regex.nondigit, '').replace(wo.filter_regex.operators,''), table);
                                                // parse filter value in case we're comparing numbers (dates)
                                                if (parsed[i] || c.parsers[i].type === 'numeric') {
                                                    rg = c.parsers[i].format('' + val.replace(wo.filter_regex.operators,''), table, $ths.eq(i), i);
                                                    s = (rg !== '' && !isNaN(rg)) ? rg : s;
                                                }
                                                // xi may be numeric - see issue #149;
                                                // check if c.cache[k].normalized[j] is defined, because sometimes j goes out of range? (numeric columns)
                                                rg = ( parsed[i] || c.parsers[i].type === 'numeric' ) && !isNaN(s) && c.cache[k].normalized[j] ? c.cache[k].normalized[j][i] :
                                                    isNaN(xi) ? fmt(xi.replace(wo.filter_regex.nondigit, ''), table) : fmt(xi, table);
                                                if (/>/.test(val)) { ff = />=/.test(val) ? rg >= s : rg > s; }
                                                if (/</.test(val)) { ff = /<=/.test(val) ? rg <= s : rg < s; }
                                                if (s === '') { ff = true; } // keep showing all rows if nothing follows the operator
                                                // Look for an AND or && operator (logical and)
                                            } else if (/\s+(AND|&&)\s+/g.test(v[i])) {
                                                s = val.split(/(?:\s+(?:and|&&)\s+)/g);
                                                ff = xi.search($.trim(s[0])) >= 0;
                                                r1 = s.length - 1;
                                                while (ff && r1) {
                                                    ff = ff && xi.search($.trim(s[r1])) >= 0;
                                                    r1--;
                                                }
                                                // Look for a range (using " to " or " - ") - see issue #166; thanks matzhu!
                                            } else if (/\s+(-|to)\s+/.test(val)){
                                                s = val.split(/(?: - | to )/); // make sure the dash is for a range and not indicating a negative number
                                                r1 = fmt(s[0].replace(wo.filter_regex.nondigit, ''), table);
                                                r2 = fmt(s[1].replace(wo.filter_regex.nondigit, ''), table);
                                                // parse filter value in case we're comparing numbers (dates)
                                                if (parsed[i] || c.parsers[i].type === 'numeric') {
                                                    rg = c.parsers[i].format('' + s[0], table, $ths.eq(i), i);
                                                    r1 = (rg !== '' && !isNaN(rg)) ? rg : r1;
                                                    rg = c.parsers[i].format('' + s[1], table, $ths.eq(i), i);
                                                    r2 = (rg !== '' && !isNaN(rg)) ? rg : r2;
                                                }
                                                rg = ( parsed[i] || c.parsers[i].type === 'numeric' ) && !isNaN(r1) && !isNaN(r2) ? c.cache[k].normalized[j][i] :
                                                    isNaN(xi) ? fmt(xi.replace(wo.filter_regex.nondigit, ''), table) : fmt(xi, table);
                                                if (r1 > r2) { ff = r1; r1 = r2; r2 = ff; } // swap
                                                ff = (rg >= r1 && rg <= r2) || (r1 === '' || r2 === '') ? true : false;
                                                // Look for wild card: ? = single, * = multiple, or | = logical OR
                                            } else if ( /[\?|\*]/.test(val) || /\s+OR\s+/.test(v[i]) ){
                                                s = val.replace(/\s+OR\s+/gi,"|");
                                                // look for an exact match with the "or" unless the "filter-match" class is found
                                                if (!$ths.filter('[data-column="' + i + '"]:last').hasClass('filter-match') && /\|/.test(s)) {
                                                    s = '^(' + s + ')$';
                                                }
                                                ff = new RegExp( s.replace(/\?/g, '\\S{1}').replace(/\*/g, '\\S*') ).test(xi);
                                                // Look for match, and add child row data for matching
                                            } else {
                                                x = (xi + t).indexOf(val);
                                                ff  = ( (!wo.filter_startsWith && x >= 0) || (wo.filter_startsWith && x === 0) );
                                            }
                                            r = (ff) ? (r ? true : false) : false;
                                        }
                                    }
                                    $tr[j].style.display = (r ? '' : 'none');
                                    $tr.eq(j)[r ? 'removeClass' : 'addClass'](wo.filter_filteredRow);
                                    if (cr.length) { cr[r ? 'show' : 'hide'](); }
                                }
                            }
                            ts.processTbody(table, $tb, false);
                        }
                        last = cv; // save last search
                        $t.data('lastSearch', v);
                        if (c.debug){
                            ts.benchmark("Completed filter widget search", time);
                        }
                        $t.trigger('applyWidgets'); // make sure zebra widget is applied
                        $t.trigger('filterEnd');
                    },
                    buildSelect = function(i, updating, onlyavail){
                        var o, t, arry = [], currentVal;
                        i = parseInt(i, 10);
                        t = $ths.filter('[data-column="' + i + '"]:last');
                        // t.data('placeholder') won't work in jQuery older than 1.4.3
                        o = '<option value="">' + (t.data('placeholder') || t.attr('data-placeholder') || '') + '</option>';
                        for (k = 0; k < b.length; k++ ){
                            l = c.cache[k].row.length;
                            // loop through the rows
                            for (j = 0; j < l; j++){
                                // check if has class filtered
                                if (onlyavail && c.cache[k].row[j][0].className.match(wo.filter_filteredRow)) { continue; }
                                // get non-normalized cell content
                                if (wo.filter_useParsedData){
                                    arry.push( '' + c.cache[k].normalized[j][i] );
                                } else {
                                    t = c.cache[k].row[j][0].cells[i];
                                    if (t){
                                        arry.push( $.trim(c.supportsTextContent ? t.textContent : $(t).text()) );
                                    }
                                }
                            }
                        }

                        // get unique elements and sort the list
                        // if $.tablesorter.sortText exists (not in the original tablesorter),
                        // then natural sort the list otherwise use a basic sort
                        arry = $.grep(arry, function(v, k){
                            return $.inArray(v, arry) === k;
                        });
                        arry = (ts.sortText) ? arry.sort(function(a, b){ return ts.sortText(table, a, b, i); }) : arry.sort(true);

                        // Get curent filter value
                        currentVal = $t.find('thead').find('select.' + css + '[data-column="' + i + '"]').val();

                        // build option list
                        for (k = 0; k < arry.length; k++){
                            t = arry[k].replace(/\"/g, "&quot;");
                            // replace quotes - fixes #242 & ignore empty strings - see http://stackoverflow.com/q/14990971/145346
                            o += arry[k] !== '' ? '<option value="' + t + '"' + (currentVal === t ? ' selected="selected"' : '') +'>' + arry[k] + '</option>' : '';
                        }
                        $t.find('thead').find('select.' + css + '[data-column="' + i + '"]')[ updating ? 'html' : 'append' ](o);
                    },
                    buildDefault = function(updating){
                        // build default select dropdown
                        for (i = 0; i < cols; i++){
                            t = $ths.filter('[data-column="' + i + '"]:last');
                            // look for the filter-select class; build/update it if found
                            if ((t.hasClass('filter-select') || wo.filter_functions && wo.filter_functions[i] === true) && !t.hasClass('filter-false')){
                                if (!wo.filter_functions) { wo.filter_functions = {}; }
                                wo.filter_functions[i] = true; // make sure this select gets processed by filter_functions
                                buildSelect(i, updating, t.hasClass(wo.filter_onlyAvail));
                            }
                        }
                    },
                    searching = function(filter){
                        if (typeof filter === 'undefined' || filter === true){
                            // delay filtering
                            clearTimeout(timer);
                            timer = setTimeout(function(){
                                checkFilters(filter);
                            }, wo.filter_liveSearch ? wo.filter_searchDelay : 10);
                        } else {
                            // skip delay
                            checkFilters(filter);
                        }
                    };
                if (c.debug){
                    time = new Date();
                }
                wo.filter_regex.child = new RegExp(c.cssChildRow);
                wo.filter_regex.filtered = new RegExp(wo.filter_filteredRow);
                // don't build filter row if columnFilters is false or all columns are set to "filter-false" - issue #156
                if (wo.filter_columnFilters !== false && $ths.filter('.filter-false').length !== $ths.length){
                    // build filter row
                    t = '<tr class="tablesorter-filter-row">';
                    for (i = 0; i < cols; i++){
                        t += '<td></td>';
                    }
                    c.$filters = $(t += '</tr>').appendTo( $t.find('thead').eq(0) ).find('td');
                    // build each filter input
                    for (i = 0; i < cols; i++){
                        dis = false;
                        $th = $ths.filter('[data-column="' + i + '"]:last'); // assuming last cell of a column is the main column
                        sel = (wo.filter_functions && wo.filter_functions[i] && typeof wo.filter_functions[i] !== 'function') || $th.hasClass('filter-select');
                        // use header option - headers: { 1: { filter: false } } OR add class="filter-false"
                        if (ts.getData){
                            // get data from jQuery data, metadata, headers option or header class name
                            dis = ts.getData($th[0], c.headers[i], 'filter') === 'false';
                        } else {
                            // only class names and header options - keep this for compatibility with tablesorter v2.0.5
                            dis = (c.headers[i] && c.headers[i].hasOwnProperty('filter') && c.headers[i].filter === false) || $th.hasClass('filter-false');
                        }

                        if (sel){
                            t = $('<select>').appendTo( c.$filters.eq(i) );
                        } else {
                            if (wo.filter_formatter && $.isFunction(wo.filter_formatter[i])) {
                                t = wo.filter_formatter[i]( c.$filters.eq(i), i );
                                // no element returned, so lets go find it
                                if (t && t.length === 0) { t = c.$filters.eq(i).children('input'); }
                                // element not in DOM, so lets attach it
                                if (t && (t.parent().length === 0 || (t.parent().length && t.parent()[0] !== c.$filters[i]))) {
                                    c.$filters.eq(i).append(t);
                                }
                            } else {
                                t = $('<input type="search">').appendTo( c.$filters.eq(i) );
                            }
                            if (t) {
                                t.attr('placeholder', $th.data('placeholder') || $th.attr('data-placeholder') || '');
                            }
                        }
                        if (t) {
                            t.addClass(css).attr('data-column', i);
                            if (dis) {
                                t.addClass('disabled')[0].disabled = true; // disabled!
                            }
                        }
                    }
                }
                $t
                    .bind('addRows updateCell update updateRows updateComplete appendCache filterReset filterEnd search '.split(' ').join('.tsfilter '), function(e, filter){
                        if (!/(search|filterReset|filterEnd)/.test(e.type)){
                            e.stopPropagation();
                            buildDefault(true);
                        }
                        if (e.type === 'filterReset') {
                            $t.find('.' + css).val('');
                        }
                        if (e.type === 'filterEnd') {
                            buildDefault(true);
                        } else {
                            // send false argument to force a new search; otherwise if the filter hasn't changed, it will return
                            filter = e.type === 'search' ? filter : e.type === 'updateComplete' ? $t.data('lastSearch') : '';
                            searching(filter);
                        }
                        return false;
                    })
                    .find('input.' + css).bind('keyup search', function(e, filter){
                        // emulate what webkit does.... escape clears the filter
                        if (e.which === 27) {
                            this.value = '';
                            // liveSearch can contain a min value length; ignore arrow and meta keys, but allow backspace
                        } else if ( (typeof wo.filter_liveSearch === 'number' && this.value.length < wo.filter_liveSearch && this.value !== '') || ( e.type === 'keyup' &&
                            ( (e.which < 32 && e.which !== 8 && wo.filter_liveSearch === true && e.which !== 13) || (e.which >= 37 && e.which <=40) || (e.which !== 13 && wo.filter_liveSearch === false) ) ) ) {
                            return;
                        }
                        searching(filter);
                    });

                // parse columns after formatter, in case the class is added at that point
                parsed = $ths.map(function(i){
                    return (ts.getData) ? ts.getData($ths.filter('[data-column="' + i + '"]:last'), c.headers[i], 'filter') === 'parsed' : $(this).hasClass('filter-parsed');
                }).get();

                // reset button/link
                if (wo.filter_reset && $(wo.filter_reset).length){
                    $(wo.filter_reset).bind('click.tsfilter', function(){
                        $t.trigger('filterReset');
                    });
                }
                if (wo.filter_functions){
                    // i = column # (string)
                    for (col in wo.filter_functions){
                        if (wo.filter_functions.hasOwnProperty(col) && typeof col === 'string'){
                            t = $ths.filter('[data-column="' + col + '"]:last');
                            ff = '';
                            if (wo.filter_functions[col] === true && !t.hasClass('filter-false')){
                                buildSelect(col);
                            } else if (typeof col === 'string' && !t.hasClass('filter-false')){
                                // add custom drop down list
                                for (str in wo.filter_functions[col]){
                                    if (typeof str === 'string'){
                                        ff += ff === '' ? '<option value="">' + (t.data('placeholder') || t.attr('data-placeholder') ||  '') + '</option>' : '';
                                        ff += '<option value="' + str + '">' + str + '</option>';
                                    }
                                }
                                $t.find('thead').find('select.' + css + '[data-column="' + col + '"]').append(ff);
                            }
                        }
                    }
                }
                // not really updating, but if the column has both the "filter-select" class & filter_functions set to true,
                // it would append the same options twice.
                buildDefault(true);

                $t.find('select.' + css).bind('change search', function(e, filter){
                    checkFilters(filter);
                });

                if (wo.filter_hideFilters){
                    $t
                        .find('.tablesorter-filter-row')
                        .addClass('hideme')
                        .bind('mouseenter mouseleave', function(e){
                            // save event object - http://bugs.jquery.com/ticket/12140
                            var all, evt = e;
                            ft = $(this);
                            clearTimeout(st);
                            st = setTimeout(function(){
                                if (/enter|over/.test(evt.type)){
                                    ft.removeClass('hideme');
                                } else {
                                    // don't hide if input has focus
                                    // $(':focus') needs jQuery 1.6+
                                    if ($(document.activeElement).closest('tr')[0] !== ft[0]){
                                        // get all filter values
                                        all = $t.find('.' + wo.filter_cssFilter).map(function(){
                                            return $(this).val() || '';
                                        }).get().join('');
                                        // don't hide row if any filter has a value
                                        if (all === ''){
                                            ft.addClass('hideme');
                                        }
                                    }
                                }
                            }, 200);
                        })
                        .find('input, select').bind('focus blur', function(e){
                            ft2 = $(this).closest('tr');
                            clearTimeout(st);
                            st = setTimeout(function(){
                                // don't hide row if any filter has a value
                                if ($t.find('.' + wo.filter_cssFilter).map(function(){ return $(this).val() || ''; }).get().join('') === ''){
                                    ft2[ e.type === 'focus' ? 'removeClass' : 'addClass']('hideme');
                                }
                            }, 200);
                        });
                }

                // show processing icon
                if (c.showProcessing) {
                    $t.bind('filterStart.tsfilter filterEnd.tsfilter', function(e, v) {
                        var fc = (v) ? $t.find('.' + c.cssHeader).filter('[data-column]').filter(function(){
                            return v[$(this).data('column')] !== '';
                        }) : '';
                        ts.isProcessing($t[0], e.type === 'filterStart', v ? fc : '');
                    });
                }

                if (c.debug){
                    ts.benchmark("Applying Filter widget", time);
                }
                // add default values
                $t.bind('tablesorter-initialized', function(){
                    ff = ts.getFilters(table);
                    for (i = 0; i < ff.length; i++) {
                        ff[i] = $ths.filter('[data-column="' + i + '"]:last').attr(wo.filter_defaultAttrib) || ff[i];
                    }
                    ts.setFilters(table, ff, true);
                });
                // filter widget initialized
                $t.trigger('filterInit');
                checkFilters();
            }
        },
        remove: function(table, c, wo){
            var k, $tb,
                $t = c.$table,
                b = c.$tbodies;
            $t
                .removeClass('hasFilters')
                // add .tsfilter namespace to all BUT search
                .unbind('addRows updateCell update updateComplete appendCache search filterStart filterEnd '.split(' ').join('.tsfilter '))
                .find('.tablesorter-filter-row').remove();
            for (k = 0; k < b.length; k++ ){
                $tb = ts.processTbody(table, b.eq(k), true); // remove tbody
                $tb.children().removeClass(wo.filter_filteredRow).show();
                ts.processTbody(table, $tb, false); // restore tbody
            }
            if (wo.filterreset) { $(wo.filter_reset).unbind('click.tsfilter'); }
        }
    });
    ts.getFilters = function(table) {
        var c = table ? $(table)[0].config : {};
        if (c && c.widgetOptions && !c.widgetOptions.filter_columnFilters) { return $(table).data('lastSearch'); }
        return c && c.$filters ? c.$filters.find('.' + c.widgetOptions.filter_cssFilter).map(function(i, el) {
            return $(el).val();
        }).get() || [] : false;
    };
    ts.setFilters = function(table, filter, apply) {
        var $t = $(table),
            c = $t.length ? $t[0].config : {},
            valid = c && c.$filters ? c.$filters.find('.' + c.widgetOptions.filter_cssFilter).each(function(i, el) {
                $(el).val(filter[i] || '');
            }).trigger('change.tsfilter') || false : false;
        if (apply) { $t.trigger('search', [filter, false]); }
        return !!valid;
    };

// Widget: Sticky headers
// based on this awesome article:
// http://css-tricks.com/13465-persistent-headers/
// and https://github.com/jmosbech/StickyTableHeaders by Jonas Mosbech
// **************************
    ts.addWidget({
        id: "stickyHeaders",
        priority: 60,
        options: {
            stickyHeaders : 'tablesorter-stickyHeader',
            stickyHeaders_offset : 0, // number or jquery selector targeting the position:fixed element
            stickyHeaders_cloneId : '-sticky', // added to table ID, if it exists
            stickyHeaders_addResizeEvent : true, // trigger "resize" event on headers
            stickyHeaders_includeCaption : true // if false and a caption exist, it won't be included in the sticky header
        },
        format: function(table, c, wo){
            if (c.$table.hasClass('hasStickyHeaders')) { return; }
            var $t = c.$table,
                $win = $(window),
                header = $t.children('thead:first'),
                hdrCells = header.children('tr:not(.sticky-false)').children(),
                innr = '.tablesorter-header-inner',
                tfoot = $t.find('tfoot'),
                filterInputs = '.' + (wo.filter_cssFilter || 'tablesorter-filter'),
                $stickyOffset = isNaN(wo.stickyHeaders_offset) ? $(wo.stickyHeaders_offset) : '',
                stickyOffset = $stickyOffset.length ? $stickyOffset.height() || 0 : parseInt(wo.stickyHeaders_offset, 10) || 0,
                $stickyTable = wo.$sticky = $t.clone()
                    .addClass('containsStickyHeaders')
                    .css({
                        position   : 'fixed',
                        margin     : 0,
                        top        : stickyOffset,
                        visibility : 'hidden',
                        zIndex     : 2
                    }),
                stkyHdr = $stickyTable.children('thead:first').addClass(wo.stickyHeaders),
                stkyCells,
                laststate = '',
                spacing = 0,
                flag = false,
                resizeHdr = function(){
                    stickyOffset = $stickyOffset.length ? $stickyOffset.height() || 0 : parseInt(wo.stickyHeaders_offset, 10) || 0;
                    var bwsr = navigator.userAgent;
                    spacing = 0;
                    // yes, I dislike browser sniffing, but it really is needed here :(
                    // webkit automatically compensates for border spacing
                    if ($t.css('border-collapse') !== 'collapse' && !/(webkit|msie)/i.test(bwsr)) {
                        // Firefox & Opera use the border-spacing
                        // update border-spacing here because of demos that switch themes
                        spacing = parseInt(hdrCells.eq(0).css('border-left-width'), 10) * 2;
                    }
                    $stickyTable.css({
                        left : header.offset().left - $win.scrollLeft() - spacing,
                        width: $t.width()
                    });
                    stkyCells.filter(':visible').each(function(i){
                        var $h = hdrCells.filter(':visible').eq(i);
                        $(this)
                            .css({
                                width: $h.width() - spacing,
                                height: $h.height()
                            })
                            .find(innr).width( $h.find(innr).width() );
                    });
                };
            // fix clone ID, if it exists - fixes #271
            if ($stickyTable.attr('id')) { $stickyTable[0].id += wo.stickyHeaders_cloneId; }
            // clear out cloned table, except for sticky header
            // include caption & filter row (fixes #126 & #249)
            $stickyTable.find('thead:gt(0), tr.sticky-false, tbody, tfoot').remove();
            if (!wo.stickyHeaders_includeCaption) {
                $stickyTable.find('caption').remove();
            }
            // issue #172 - find td/th in sticky header
            stkyCells = stkyHdr.children().children();
            $stickyTable.css({ height:0, width:0, padding:0, margin:0, border:0 });
            // remove resizable block
            stkyCells.find('.tablesorter-resizer').remove();
            // update sticky header class names to match real header after sorting
            $t
                .addClass('hasStickyHeaders')
                .bind('sortEnd.tsSticky', function(){
                    hdrCells.filter(':visible').each(function(i){
                        var t = stkyCells.filter(':visible').eq(i);
                        t
                            .attr('class', $(this).attr('class'))
                            // remove processing icon
                            .removeClass(c.cssProcessing);
                        if (c.cssIcon){
                            t
                                .find('.' + c.cssIcon)
                                .attr('class', $(this).find('.' + c.cssIcon).attr('class'));
                        }
                    });
                })
                .bind('pagerComplete.tsSticky', function(){
                    resizeHdr();
                });
            // http://stackoverflow.com/questions/5312849/jquery-find-self;
            hdrCells.find(c.selectorSort).add( c.$headers.filter(c.selectorSort) ).each(function(i){
                var t = $(this),
                // clicking on sticky will trigger sort
                    $cell = stkyHdr.children('tr.tablesorter-headerRow').children().eq(i).bind('mouseup', function(e){
                        t.trigger(e, true); // external mouseup flag (click timer is ignored)
                    });
                // prevent sticky header text selection
                if (c.cancelSelection) {
                    $cell
                        .attr('unselectable', 'on')
                        .bind('selectstart', false)
                        .css({
                            'user-select': 'none',
                            'MozUserSelect': 'none'
                        });
                }
            });
            // add stickyheaders AFTER the table. If the table is selected by ID, the original one (first) will be returned.
            $t.after( $stickyTable );
            // make it sticky!
            $win.bind('scroll.tsSticky resize.tsSticky', function(e){
                if (!$t.is(':visible')) { return; } // fixes #278
                var pre = 'tablesorter-sticky-',
                    offset = $t.offset(),
                    cap = -(wo.stickyHeaders_includeCaption ? 0 : $t.find('caption').height()),
                    sTop = $win.scrollTop() + stickyOffset,
                    tableHt = $t.height() - ($stickyTable.height() + (tfoot.height() || 0)),
                    vis = (sTop > offset.top - cap) && (sTop < offset.top - cap + tableHt) ? 'visible' : 'hidden';
                $stickyTable
                    .removeClass(pre + 'visible ' + pre + 'hidden')
                    .addClass(pre + vis)
                    .css({
                        // adjust when scrolling horizontally - fixes issue #143
                        left : header.offset().left - $win.scrollLeft() - spacing,
                        visibility : vis
                    });
                if (vis !== laststate || e.type === 'resize'){
                    // make sure the column widths match
                    resizeHdr();
                    laststate = vis;
                }
            });
            if (wo.stickyHeaders_addResizeEvent) {
                ts.addHeaderResizeEvent(table);
            }

            // look for filter widget
            $t.bind('filterEnd', function(){
                if (flag) { return; }
                stkyHdr.find('.tablesorter-filter-row').children().each(function(i){
                    $(this).find(filterInputs).val( c.$filters.find(filterInputs).eq(i).val() );
                });
            });
            stkyCells.find(filterInputs).bind('keyup search change', function(e){
                // ignore arrow and meta keys; allow backspace
                if ((e.which < 32 && e.which !== 8) || (e.which >= 37 && e.which <=40)) { return; }
                flag = true;
                var $f = $(this), col = $f.attr('data-column');
                c.$filters.find(filterInputs).eq(col)
                    .val( $f.val() )
                    .trigger('search');
                setTimeout(function(){
                    flag = false;
                }, wo.filter_searchDelay);
            });
            $t.trigger('stickyHeadersInit');

        },
        remove: function(table, c, wo){
            c.$table
                .removeClass('hasStickyHeaders')
                .unbind('sortEnd.tsSticky pagerComplete.tsSticky')
                .find('.' + wo.stickyHeaders).remove();
            if (wo.$sticky && wo.$sticky.length) { wo.$sticky.remove(); } // remove cloned table
            // don't unbind if any table on the page still has stickyheaders applied
            if (!$('.hasStickyHeaders').length) {
                $(window).unbind('scroll.tsSticky resize.tsSticky');
            }
            ts.addHeaderResizeEvent(table, false);
        }
    });

// Add Column resizing widget
// this widget saves the column widths if
// $.tablesorter.storage function is included
// **************************
    ts.addWidget({
        id: "resizable",
        priority: 40,
        options: {
            resizable : true,
            resizable_addLastColumn : false
        },
        format: function(table, c, wo){
            if (c.$table.hasClass('hasResizable')) { return; }
            c.$table.addClass('hasResizable');
            var $t, t, i, j, s = {}, $c, $cols, w, tw,
                $tbl = c.$table,
                position = 0,
                $target = null,
                $next = null,
                fullWidth = Math.abs($tbl.parent().width() - $tbl.width()) < 20,
                stopResize = function(){
                    if (ts.storage && $target){
                        s[$target.index()] = $target.width();
                        s[$next.index()] = $next.width();
                        $target.width( s[$target.index()] );
                        $next.width( s[$next.index()] );
                        if (wo.resizable !== false){
                            ts.storage(table, 'tablesorter-resizable', s);
                        }
                    }
                    position = 0;
                    $target = $next = null;
                    $(window).trigger('resize'); // will update stickyHeaders, just in case
                };
            s = (ts.storage && wo.resizable !== false) ? ts.storage(table, 'tablesorter-resizable') : {};
            // process only if table ID or url match
            if (s){
                for (j in s){
                    if (!isNaN(j) && j < c.$headers.length){
                        c.$headers.eq(j).width(s[j]); // set saved resizable widths
                    }
                }
            }
            $t = $tbl.children('thead:first').children('tr');
            // add resizable-false class name to headers (across rows as needed)
            $t.children().each(function(){
                t = $(this);
                i = t.attr('data-column');
                j = ts.getData( t, c.headers[i], 'resizable') === "false";
                $t.children().filter('[data-column="' + i + '"]').toggleClass('resizable-false', j);
            });
            // add wrapper inside each cell to allow for positioning of the resizable target block
            $t.each(function(){
                $c = $(this).children(':not(.resizable-false)');
                if (!$(this).find('.tablesorter-wrapper').length) {
                    // Firefox needs this inner div to position the resizer correctly
                    $c.wrapInner('<div class="tablesorter-wrapper" style="position:relative;height:100%;width:100%"></div>');
                }
                // don't include the last column of the row
                if (!wo.resizable_addLastColumn) { $c = $c.slice(0,-1); }
                $cols = $cols ? $cols.add($c) : $c;
            });
            $cols
                .each(function(){
                    $t = $(this);
                    j = parseInt($t.css('padding-right'), 10) + 10; // 8 is 1/2 of the 16px wide resizer grip
                    t = '<div class="tablesorter-resizer" style="cursor:w-resize;position:absolute;z-index:1;right:-' + j +
                        'px;top:0;height:100%;width:20px;"></div>';
                    $t
                        .find('.tablesorter-wrapper')
                        .append(t);
                })
                .bind('mousemove.tsresize', function(e){
                    // ignore mousemove if no mousedown
                    if (position === 0 || !$target) { return; }
                    // resize columns
                    w = e.pageX - position;
                    tw = $target.width();
                    $target.width( tw + w );
                    if ($target.width() !== tw && fullWidth){
                        $next.width( $next.width() - w );
                    }
                    position = e.pageX;
                })
                .bind('mouseup.tsresize', function(){
                    stopResize();
                })
                .find('.tablesorter-resizer,.tablesorter-resizer-grip')
                .bind('mousedown', function(e){
                    // save header cell and mouse position; closest() not supported by jQuery v1.2.6
                    $target = $(e.target).closest('th');
                    t = c.$headers.filter('[data-column="' + $target.attr('data-column') + '"]');
                    if (t.length > 1) { $target = $target.add(t); }
                    // if table is not as wide as it's parent, then resize the table
                    $next = e.shiftKey ? $target.parent().find('th:not(.resizable-false)').filter(':last') : $target.nextAll(':not(.resizable-false)').eq(0);
                    position = e.pageX;
                });
            $tbl.find('thead:first')
                .bind('mouseup.tsresize mouseleave.tsresize', function(){
                    stopResize();
                })
                // right click to reset columns to default widths
                .bind('contextmenu.tsresize', function(){
                    ts.resizableReset(table);
                    // $.isEmptyObject() needs jQuery 1.4+
                    var rtn = $.isEmptyObject ? $.isEmptyObject(s) : s === {}; // allow right click if already reset
                    s = {};
                    return rtn;
                });
        },
        remove: function(table, c, wo){
            c.$table
                .removeClass('hasResizable')
                .find('thead')
                .unbind('mouseup.tsresize mouseleave.tsresize contextmenu.tsresize')
                .find('tr').children()
                .unbind('mousemove.tsresize mouseup.tsresize')
                // don't remove "tablesorter-wrapper" as uitheme uses it too
                .find('.tablesorter-resizer,.tablesorter-resizer-grip').remove();
            ts.resizableReset(table);
        }
    });
    ts.resizableReset = function(table){
        table.config.$headers.filter(':not(.resizable-false)').css('width','');
        if (ts.storage) { ts.storage(table, 'tablesorter-resizable', {}); }
    };

// Save table sort widget
// this widget saves the last sort only if the
// saveSort widget option is true AND the
// $.tablesorter.storage function is included
// **************************
    ts.addWidget({
        id: 'saveSort',
        priority: 20,
        options: {
            saveSort : true
        },
        init: function(table, thisWidget, c, wo){
            // run widget format before all other widgets are applied to the table
            thisWidget.format(table, c, wo, true);
        },
        format: function(table, c, wo, init){
            var sl, time,
                $t = c.$table,
                ss = wo.saveSort !== false, // make saveSort active/inactive; default to true
                sortList = { "sortList" : c.sortList };
            if (c.debug){
                time = new Date();
            }
            if ($t.hasClass('hasSaveSort')){
                if (ss && table.hasInitialized && ts.storage){
                    ts.storage( table, 'tablesorter-savesort', sortList );
                    if (c.debug){
                        ts.benchmark('saveSort widget: Saving last sort: ' + c.sortList, time);
                    }
                }
            } else {
                // set table sort on initial run of the widget
                $t.addClass('hasSaveSort');
                sortList = '';
                // get data
                if (ts.storage){
                    sl = ts.storage( table, 'tablesorter-savesort' );
                    sortList = (sl && sl.hasOwnProperty('sortList') && $.isArray(sl.sortList)) ? sl.sortList : '';
                    if (c.debug){
                        ts.benchmark('saveSort: Last sort loaded: "' + sortList + '"', time);
                    }
                    $t.bind('saveSortReset', function(e){
                        e.stopPropagation();
                        ts.storage( table, 'tablesorter-savesort', '' );
                    });
                }
                // init is true when widget init is run, this will run this widget before all other widgets have initialized
                // this method allows using this widget in the original tablesorter plugin; but then it will run all widgets twice.
                if (init && sortList && sortList.length > 0){
                    c.sortList = sortList;
                } else if (table.hasInitialized && sortList && sortList.length > 0){
                    // update sort change
                    $t.trigger('sorton', [sortList]);
                }
            }
        },
        remove: function(table){
            // clear storage
            if (ts.storage) { ts.storage( table, 'tablesorter-savesort', '' ); }
        }
    });

})(jQuery);

/*! Filter widget formatter functions - updated 6/4/2013
 * requires: tableSorter 2.7.7+ and jQuery 1.4.3+
 * jQuery UI spinner, silder, range slider & datepicker (range)
 * HTML5 number (spinner), range slider & color selector
 */
;(function(h){h.tablesorter=h.tablesorter||{};h.tablesorter.filterFormatter={uiSpinner:function(b,f,g){var a=h.extend({min:0,max:100,step:1,value:1,delayed:!0,addToggle:!0,disabled:!1,exactMatch:!0,compare:""},g);g=h('<input class="filter" type="hidden">').appendTo(b).bind("change.tsfilter",function(){d({value:this.value,delayed:!1})});var e=[],j=b.closest("table")[0].config,d=function(d){var c=!0,f,g=d&&d.value&&h.tablesorter.formatFloat((d.value+"").replace(/[><=]/g,""))||b.find(".spinner").val()|| a.value;a.addToggle&&(c=b.find(".toggle").is(":checked"));f=a.disabled||!c?"disable":"enable";b.find(".filter").val(c?(a.compare?a.compare:a.exactMatch?"=":"")+g:"").trigger("search",d&&"boolean"===typeof d.delayed?d.delayed:a.delayed).end().find(".spinner").spinner(f).val(g);e.length&&(e.find(".spinner").spinner(f).val(g),a.addToggle&&(e.find(".toggle")[0].checked=c))};a.oldcreate=a.create;a.oldspin=a.spin;a.create=function(b,c){d();"function"===typeof a.oldcreate&&a.oldcreate(b,c)};a.spin=function(b, c){d(c);"function"===typeof a.oldspin&&a.oldspin(b,c)};a.addToggle&&h('<div class="button"><input id="uispinnerbutton'+f+'" type="checkbox" class="toggle" /><label for="uispinnerbutton'+f+'"></label></div>').appendTo(b).find(".toggle").bind("change",function(){d()});b.closest("thead").find("th[data-column="+f+"]").addClass("filter-parsed");h('<input class="spinner spinner'+f+'" />').val(a.value).appendTo(b).spinner(a).bind("change keyup",function(){d()});j.$table.bind("stickyHeadersInit",function(){e= j.widgetOptions.$sticky.find(".tablesorter-filter-row").children().eq(f).empty();a.addToggle&&h('<div class="button"><input id="stickyuispinnerbutton'+f+'" type="checkbox" class="toggle" /><label for="stickyuispinnerbutton'+f+'"></label></div>').appendTo(e).find(".toggle").bind("change",function(){b.find(".toggle")[0].checked=this.checked;d()});h('<input class="spinner spinner'+f+'" />').val(a.value).appendTo(e).spinner(a).bind("change keyup",function(){b.find(".spinner").val(this.value);d()})}); j.$table.bind("filterReset",function(){a.addToggle&&(b.find(".toggle")[0].checked=!1);d()});d();return g},uiSlider:function(b,f,g){var a=h.extend({value:0,min:0,max:100,step:1,range:"min",delayed:!0,valueToHeader:!1,exactMatch:!0,compare:"",allText:"all"},g);g=h('<input class="filter" type="hidden">').appendTo(b).bind("change.tsfilter",function(){d({value:this.value})});var e=[],j=b.closest("table")[0].config,d=function(d){var c="undefined"!==typeof d?h.tablesorter.formatFloat((d.value+"").replace(/[><=]/g, ""))||a.min:a.value,g=a.compare+(a.compare?c:c===a.min?a.allText:c);a.valueToHeader?b.closest("thead").find("th[data-column="+f+"]").find(".curvalue").html(" ("+g+")"):b.find(".ui-slider-handle").addClass("value-popup").attr("data-value",g);b.find(".filter").val(a.compare?a.compare+c:c===a.min?"":(a.exactMatch?"=":"")+c).trigger("search",d&&"boolean"===typeof d.delayed?d.delayed:a.delayed).end().find(".slider").slider("value",c);e.length&&(e.find(".slider").slider("value",c),a.valueToHeader?e.closest("thead").find("th[data-column="+ f+"]").find(".curvalue").html(" ("+g+")"):e.find(".ui-slider-handle").addClass("value-popup").attr("data-value",g))};b.closest("thead").find("th[data-column="+f+"]").addClass("filter-parsed");a.valueToHeader&&b.closest("thead").find("th[data-column="+f+"]").find(".tablesorter-header-inner").append('<span class="curvalue" />');a.oldcreate=a.create;a.oldslide=a.slide;a.create=function(b,c){d();"function"===typeof a.oldcreate&&a.oldcreate(b,c)};a.slide=function(b,c){d(c);"function"===typeof a.oldslide&& a.oldslide(b,c)};h('<div class="slider slider'+f+'"/>').appendTo(b).slider(a);j.$table.bind("filterReset",function(){b.find(".slider").slider("value",a.value);d()});j.$table.bind("stickyHeadersInit",function(){e=j.widgetOptions.$sticky.find(".tablesorter-filter-row").children().eq(f).empty();h('<div class="slider slider'+f+'"/>').val(a.value).appendTo(e).slider(a).bind("change keyup",function(){b.find(".slider").val(this.value);d()})});return g},uiRange:function(b,f,g){var a=h.extend({values:[0,100], min:0,max:100,range:!0,delayed:!0,valueToHeader:!1},g);g=h('<input class="filter" type="hidden">').appendTo(b).bind("change.tsfilter",function(){var b=this.value.split(" - ");""===this.value&&(b=[a.min,a.max]);b&&b[1]&&d({values:b,delay:!1})});var e=[],j=b.closest("table")[0].config,d=function(d){var c=d&&d.values||a.values,g=c[0]+" - "+c[1],h=c[0]===a.min&&c[1]===a.max?"":g;a.valueToHeader?b.closest("thead").find("th[data-column="+f+"]").find(".currange").html(" ("+g+")"):b.find(".ui-slider-handle").addClass("value-popup").eq(0).attr("data-value", c[0]).end().eq(1).attr("data-value",c[1]);b.find(".filter").val(h).trigger("search",d&&"boolean"===typeof d.delayed?d.delayed:a.delayed).end().find(".range").slider("values",c);e.length&&(e.find(".range").slider("values",c),a.valueToHeader?e.closest("thead").find("th[data-column="+f+"]").find(".currange").html(" ("+g+")"):e.find(".ui-slider-handle").addClass("value-popup").eq(0).attr("data-value",c[0]).end().eq(1).attr("data-value",c[1]))};b.closest("thead").find("th[data-column="+f+"]").addClass("filter-parsed"); a.valueToHeader&&b.closest("thead").find("th[data-column="+f+"]").find(".tablesorter-header-inner").append('<span class="currange"/>');a.oldcreate=a.create;a.oldslide=a.slide;a.create=function(b,c){d();"function"===typeof a.oldcreate&&a.oldcreate(b,c)};a.slide=function(b,c){d(c);"function"===typeof a.oldslide&&a.oldslide(b,c)};h('<div class="range range'+f+'"/>').appendTo(b).slider(a);j.$table.bind("filterReset",function(){b.find(".range").slider("values",a.values);d()});j.$table.bind("stickyHeadersInit", function(){e=j.widgetOptions.$sticky.find(".tablesorter-filter-row").children().eq(f).empty();h('<div class="range range'+f+'"/>').val(a.value).appendTo(e).slider(a).bind("change keyup",function(){b.find(".range").val(this.value);d()})});return g},uiDateCompare:function(b,f,g){var a=h.extend({defaultDate:"",cellText:"",changeMonth:!0,changeYear:!0,numberOfMonths:1,compare:""},g);g=b.closest("thead").find("th[data-column="+f+"]");var e=h('<input class="dateCompare" type="hidden">').appendTo(b).bind("change.tsfilter", function(){var b=this.value;if(b)a.onClose(b)}),j,d=[],k=b.closest("table")[0].config;g.addClass("filter-parsed");j="<label>"+a.cellText+'</label><input type="text" class="date date'+f+'" placeholder="'+(g.data("placeholder")||g.attr("data-placeholder")||"")+'" />';h(j).appendTo(b);a.oldonClose=a.onClose;a.onClose=function(c,e){var f=(new Date(c+(a.compare.match("<")?" 23:59:59":""))).getTime()||"";b.find(".dateCompare").val(a.compare+f).trigger("search").end().find(".date").datepicker("setDate", c);d.length&&d.find(".date").datepicker("setDate",c);"function"===typeof a.oldonClose&&a.oldonClose(c,e)};b.find(".date").datepicker(a);a.filterDate&&b.find(".date").datepicker("setDate",a.filterDate);k.$table.bind("filterReset",function(){b.find(".date").val("").datepicker("option","currentText","");d.length&&d.find(".date").val("").datepicker("option","currentText","")});k.$table.bind("stickyHeadersInit",function(){d=k.widgetOptions.$sticky.find(".tablesorter-filter-row").children().eq(f).empty(); d.append(j).find(".date").datepicker(a)});return e.val(a.defaultDate?a.defaultDate:"")},uiDatepicker:function(b,f,g){var a=h.extend({from:"",to:"",textFrom:"from",textTo:"to",changeMonth:!0,changeYear:!0,numberOfMonths:1},g),e,j,d=[];g=h('<input class="dateRange" type="hidden">').appendTo(b).bind("change.tsfilter",function(){var c=this.value;if(c.match(" - "))c=c.split(" - "),b.find(".dateTo").val(c[1]),j(c[0]);else if(c.match(">="))j(c.replace(">=",""));else if(c.match("<="))a.onClose(c.replace("<=", ""))});var k=b.closest("table")[0].config;b.closest("thead").find("th[data-column="+f+"]").addClass("filter-parsed");e="<label>"+a.textFrom+'</label><input type="text" class="dateFrom" /><label>'+a.textTo+'</label><input type="text" class="dateTo" />';h(e).appendTo(b);a.oldonClose=a.onClose;a.defaultDate=a.from||a.defaultDate;j=a.onClose=function(c,e){var f=(new Date(c)).getTime()||"",g=(new Date(b.find(".dateTo").val()+" 23:59:59")).getTime()||"";b.find(".dateTo").datepicker("option","minDate",c).end().find(".dateFrom").val(c).end().find(".dateRange").val(f? g?f+" - "+g:">="+f:g?"<="+g:"").trigger("search");d.length&&d.find(".dateTo").datepicker("option","minDate",c).end().find(".dateFrom").val(c);"function"===typeof a.oldonClose&&a.oldonClose(c,e)};b.find(".dateFrom").datepicker(a);a.defaultDate=a.to||"+7d";a.onClose=function(c,e){var f=(new Date(b.find(".dateFrom").val())).getTime()||"",g=(new Date(c+" 23:59:59")).getTime()||"";b.find(".dateFrom").datepicker("option","maxDate",c).end().find(".dateTo").val(c).end().find(".dateRange").val(f?g?f+" - "+ g:">="+f:g?"<="+g:"").trigger("search");d.length&&d.find(".dateFrom").datepicker("option","maxDate",c).end().find(".dateTo").val(c);"function"===typeof a.oldonClose&&a.oldonClose(c,e)};b.find(".dateTo").datepicker(a);k.$table.bind("stickyHeadersInit",function(){d=k.widgetOptions.$sticky.find(".tablesorter-filter-row").children().eq(f).empty();d.append(e).find(".dateTo").datepicker(a);a.defaultDate=a.from||a.defaultDate||new Date;a.onClose=j;d.find(".dateFrom").datepicker(a)});b.closest("table").bind("filterReset", function(){b.find(".dateFrom, .dateTo").val("");d.length&&d.find(".dateFrom, .dateTo").val("")});e=a.from?a.to?a.from+" - "+a.to:">="+a.from:a.to?"<="+a.to:"";return g.val(e)},html5Number:function(b,f,g){var a,e=h.extend({value:0,min:0,max:100,step:1,delayed:!0,disabled:!1,addToggle:!0,exactMatch:!0,compare:"",skipTest:!1},g);g=h('<input type="number" style="visibility:hidden;" value="test">').appendTo(b);var j=e.skipTest||"number"===g.attr("type")&&"test"!==g.val(),d=[],k=b.closest("table")[0].config, c=function(a,c){var f=e.addToggle?b.find(".toggle").is(":checked"):!0;b.find("input[type=hidden]").val(!e.addToggle||f?(e.compare?e.compare:e.exactMatch?"=":"")+a:"").trigger("search",c?c:e.delayed).end().find(".number").val(a);b.find(".number").length&&(b.find(".number")[0].disabled=e.disabled||!f);d.length&&(d.find(".number").val(a)[0].disabled=e.disabled||!f,e.addToggle&&(d.find(".toggle")[0].checked=f))};g.remove();j&&(a=e.addToggle?'<div class="button"><input id="html5button'+f+'" type="checkbox" class="toggle" /><label for="html5button'+ f+'"></label></div>':"",a+='<input class="number" type="number" min="'+e.min+'" max="'+e.max+'" value="'+e.value+'" step="'+e.step+'" />',b.html(a+'<input type="hidden" />').find(".toggle, .number").bind("change",function(){c(b.find(".number").val())}).closest("thead").find("th[data-column="+f+"]").addClass("filter-parsed").closest("table").bind("filterReset",function(){e.addToggle&&(b.find(".toggle")[0].checked=!1,d.length&&(d.find(".toggle")[0].checked=!1));c(b.find(".number").val())}),b.find("input[type=hidden]").bind("change.tsfilter", function(){c(this.value)}),k.$table.bind("stickyHeadersInit",function(){d=k.widgetOptions.$sticky.find(".tablesorter-filter-row").children().eq(f).empty();d.html(a).find(".toggle, .number").bind("change",function(){c(d.find(".number").val())});c(b.find(".number").val())}),c(b.find(".number").val()));return j?b.find('input[type="hidden"]'):h('<input type="search">')},html5Range:function(b,f,g){var a=h.extend({value:0,min:0,max:100,step:1,delayed:!0,valueToHeader:!0,exactMatch:!0,compare:"",allText:"all", skipTest:!1},g);g=h('<input type="range" style="visibility:hidden;" value="test">').appendTo(b);var e=a.skipTest||"range"===g.attr("type")&&"test"!==g.val(),j=[],d=b.closest("table")[0].config,k=function(c,d){c=(c+"").replace(/[<>=]/g,"")||a.min;var e=" ("+(a.compare?a.compare+c:c==a.min?a.allText:c)+")";b.find("input[type=hidden]").val(a.compare?a.compare+c:c==a.min?"":(a.exactMatch?"=":"")+c).trigger("search",d?d:a.delayed).end().find(".range").val(c);b.closest("thead").find("th[data-column="+f+ "]").find(".curvalue").html(e);j.length&&(j.find(".range").val(c),j.closest("thead").find("th[data-column="+f+"]").find(".curvalue").html(e))};g.remove();e&&(b.html('<input type="hidden"><input class="range" type="range" min="'+a.min+'" max="'+a.max+'" value="'+a.value+'" />').closest("thead").find("th[data-column="+f+"]").addClass("filter-parsed").find(".tablesorter-header-inner").append('<span class="curvalue" />'),b.find(".range").bind("change",function(){k(this.value)}),b.find("input[type=hidden]").bind("change.tsfilter", function(){var b=this.value;b!==this.lastValue&&(this.value=this.lastValue=a.compare?a.compare+b:b==a.min?"":(a.exactMatch?"=":"")+b,k(b))}),d.$table.bind("stickyHeadersInit",function(){j=d.widgetOptions.$sticky.find(".tablesorter-filter-row").children().eq(f).empty();j.html('<input class="range" type="range" min="'+a.min+'" max="'+a.max+'" value="'+a.value+'" />').find(".range").bind("change",function(){k(j.find(".range").val())});k(b.find(".range").val())}),b.closest("table").bind("filterReset", function(){k(a.value)}),k(b.find(".range").val()));return e?b.find('input[type="hidden"]'):h('<input type="search">')},html5Color:function(b,f,g){var a,e=h.extend({value:"#000000",disabled:!1,addToggle:!0,exactMatch:!0,valueToHeader:!1,skipTest:!1},g);g=h('<input type="color" style="visibility:hidden;" value="test">').appendTo(b);var j=e.skipTest||"color"===g.attr("type")&&"test"!==g.val(),d=[],k=b.closest("table")[0].config,c=function(a){a=a||e.value;var c=!0,g=" ("+a+")";e.addToggle&&(c=b.find(".toggle").is(":checked")); b.find(".colorpicker").length&&(b.find(".colorpicker").val(a)[0].disabled=e.disabled||!c);b.find("input[type=hidden]").val(c?a+(e.exactMatch?"=":""):"").trigger("search");e.valueToHeader?b.closest("thead").find("th[data-column="+f+"]").find(".curcolor").html(g):b.find(".currentColor").html(g);d.length&&(d.find(".colorpicker").val(a)[0].disabled=e.disabled||!c,e.addToggle&&(d.find(".toggle")[0].checked=c),e.valueToHeader?d.closest("thead").find("th[data-column="+f+"]").find(".curcolor").html(g):d.find(".currentColor").html(g))}; g.remove();j&&(a='<div class="color-controls-wrapper">',a+=e.addToggle?'<div class="button"><input id="colorbutton'+f+'" type="checkbox" class="toggle" /><label for="colorbutton'+f+'"></label></div>':"",a+='<input type="hidden"><input class="colorpicker" type="color" />',a+=(e.valueToHeader?"":'<span class="currentColor">(#000000)</span>')+"</div>",b.html(a),e.valueToHeader&&b.closest("thead").find("th[data-column="+f+"]").find(".tablesorter-header-inner").append('<span class="curcolor" />'),b.find(".toggle, .colorpicker").bind("change", function(){c(b.find(".colorpicker").val())}),b.find("input[type=hidden]").bind("change.tsfilter",function(){c(this.value)}),b.closest("table").bind("filterReset",function(){b.find(".toggle")[0].checked=!1;c(b.find(".colorpicker").val())}),k.$table.bind("stickyHeadersInit",function(){d=k.widgetOptions.$sticky.find(".tablesorter-filter-row").children().eq(f);d.html(a).find(".toggle, .colorpicker").bind("change",function(){c(d.find(".colorpicker").val())});c(d.find(".colorpicker").val())}),c(e.value)); return j?b.find('input[type="hidden"]'):h('<input type="search">')}}})(jQuery);

/*! input & select parsers for jQuery 1.7+ & tablesorter 2.7.11+
 * Demo: http://mottie.github.com/tablesorter/docs/example-widget-grouping.html
 */
/*jshint browser: true, jquery:true, unused:false */
;(function($){
    "use strict";

    var resort = true, // resort table after update
        updateServer = function(event, $table, $input){
            // do something here to update your server, if needed
            // event = change event object
            // $table = jQuery object of the table that was just updated
            // $input = jQuery object of the input or select that was modified
        };

    // Custom parser for parsing input values
    // updated dynamically using the "change" function below
    $.tablesorter.addParser({
        id: "inputs",
        is: function(){
            return false;
        },
        format: function(s, table, cell) {
            return $(cell).find('input').val() || s;
        },
        type: "text"
    });

    // Custom parser for including checkbox status if using the grouping widget
    // updated dynamically using the "change" function below
    $.tablesorter.addParser({
        id: "checkbox",
        is: function(){
            return false;
        },
        format: function(s, table, cell) {
            // using plain language here because this is what is shown in the group headers
            // change it as desired
            var $c = $(cell).find('input');
            return $c.length ? $c.is(':checked') ? 'checked' : 'unchecked' : s;
        },
        type: "text"
    });

    // Custom parser which returns the currently selected options
    // updated dynamically using the "change" function below
    $.tablesorter.addParser({
        id: "select",
        is: function(){
            return false;
        },
        format: function(s, table, cell) {
            return $(cell).find('select').val() || s;
        },
        type: "text"
    });



    // update select and all input types in the tablesorter cache when the change event fires.
    // This method only works with jQuery 1.7+
    // you can change it to use delegate (v1.4.3+) or live (v1.3+) as desired
    // if this code interferes somehow, target the specific table $('#mytable'), instead of $('table')
    $(window).load(function(){
        // this flag prevents the updateCell event from being spammed
        // it happens when you modify input text and hit enter
        var alreadyUpdating = false;
        $('#table').find('tbody').on('change', 'select, input', function(e){
            if (!alreadyUpdating) {
                var $tar = $(e.target),
                    $table = $tar.closest('table');
                alreadyUpdating = true;
                $table.trigger('updateCell', [ $tar.closest('td'), resort ]);
                updateServer(e, $table, $tar);
                setTimeout(function(){ alreadyUpdating = false; }, 10);
            }
        });
    });

})(jQuery);

});