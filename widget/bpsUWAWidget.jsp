<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file="bpsWidgetConstants.inc"%>

<html xmlns="http://www.w3.org/1999/xhtml"
    xmlns:widget="http://www.netvibes.com/ns/">
    <head>

        <!-- Application Metas -->
        <title/>
        <meta name="author" content="Dassault Systemes" />
        <meta name="autoRefresh" content="0" />
        <meta name="description" content="ENOVIA Configurable Widget" />
        <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no" />

        <!--  Libraries -->
        <link rel="stylesheet" type="text/css" href="<%= sRealURL %>/plugins/libs/jqueryui/1.10.3/css/cupertino/jquery.ui.custom.min.css" />
        <link rel="stylesheet" type="text/css" href="<%= sRealURL %>/plugins/dynatree/1.2.4/skin-vista/ui.dynatree.css" />
        <link rel="stylesheet" type="text/css" href="<%= sRealURL %>/plugins/treetable/stylesheets/jquery.treetable.css" />

        <script type="text/javascript" src="<%= sRealURL %>/plugins/libs/jquery/2.0.0/jquery.min.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/plugins/libs/jqueryui/1.10.3/js/jquery.ui.custom.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/plugins/libs/jquerycookie/jquery.cookie.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/plugins/dynatree/1.2.4/jquery.dynatree.min.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/plugins/highchart/3.0.2/js/highcharts.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/plugins/treetable/javascripts/src/jquery.treetable.js"></script>

        <!-- Enovia Specific Files -->
        <link rel="stylesheet" type="text/css" href="<%= sRealURL %>/widget/styles/bpsWidget.css" />
        <link rel="stylesheet" type="text/css" href="<%= sRealURL %>/widget/timeline/css/timeline.css" />

        <script type="text/javascript" src="<%= sRealURL %>/common/scripts/bpsTagNavConnector.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/widget/scripts/bpsWidgetUtils.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/widget/scripts/bpsWidgetTagNavInit.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/widget/scripts/bpsWidgetTemplate.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/widget/scripts/bpsWidgetAPIs.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/widget/scripts/bpsWidgetSave.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/widget/scripts/bpsWidgetChart.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/widget/scripts/bpsWidgetEngine.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/widget/scripts/bpsWidgetPreferences.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/widget/timeline/js/Timeline.js"></script>
        <script type="text/javascript" src="<%= sRealURL %>/widget/timeline/js/Dateline.js"></script>

<% if ("true".equalsIgnoreCase(request.getParameter("bps_standalone"))) { %>
        <!-- Application Standalone emulation files -->
        <link rel="stylesheet" type="text/css" href="http://cdn.uwa.netvibes.com/lib/c/UWA/assets/css/standalone.css" />
        <script type="text/javascript" src="http://cdn.uwa.netvibes.com/lib/c/UWA/js/UWA_Standalone_Alone.js"></script>
<% } %>

        <!-- Application JavaScript Source  -->
        <script type="text/javascript">
            //<![CDATA[
            jQuery.noConflict();// this IS needed
            //defining constants, IFWE & enoviaServer as global.
            <%= widgetConst %>
            isIFWE = true;
            enoviaServer = {
                params : decodeURIComponent('<%= sQstring %>'),
                tenant : null,
                space : null,
                rows : null,
                preferences: {},
                storageUrl : '<%= sMyAppsURL %>',
                getUrl : function () { return this.storageUrl || '<%=sRealURL%>' },
                getParams : function () {
                    var paramString = "";
                    if (this.tenant && this.tenant.length > 0) {
                        paramString += "&tenant=" + this.tenant;
                    }
                    if (this.space && this.space.length > 0) {
                        paramString += "&SecurityContext=" + this.space;
                    }
                    if (this.rows && this.rows.length > 0) {
                        paramString += "&bps_objLimit=" + this.rows;
                    }
                    if (bpsWidgetConstants.str.language) {
                        paramString += "&bps_lang=" + bpsWidgetConstants.str.language;
                    }
                    for (var key in this.preferences) {
                        paramString += "&" + key + "=" + this.preferences[key];
                    }
                    if (paramString == "") {
                        paramString = this.params;
                    } else {
                        paramString = paramString.substring(1) + "&" + this.params;
                    }
                    return paramString;
                },
                getParamsAsJSON : function () {
                    var paramObj = {};
                    if (this.tenant && this.tenant.length > 0) {
                        paramObj.tenant = this.tenant;
                    }
                    if (this.space && this.space.length > 0) {
                        paramObj.SecurityContext = this.space;
                    }
                    if (this.rows && this.rows.length > 0) {
                        paramObj.bps_objLimit = this.rows;
                    }
                    if (bpsWidgetConstants.str.language) {
                        paramObj.bps_lang = bpsWidgetConstants.str.language;
                    }
                    for (var key in this.preferences) {
                        paramObj[key] = this.preferences[key];
                    }
                    
                    return paramObj;
                }
            };
            enoviaServer.storageUrl = enoviaServer.storageUrl.replace(":443","");

            var showSpace = '<%= XSSUtil.encodeForURL(request.getParameter("bps_showSpace")) %>';
            var objectId = '<%= XSSUtil.encodeForURL(request.getParameter("objectId")) %>';
            /*
                We create the global MyWidget object (it could be any other name).
                This object will be used to store variables and functions.
            */
            (function () {
            var randomName = "wdg_" + new Date().getTime(),
            MyWidget = {
                widgetEventSocket: null,
                arrOid: [],
                spaceNames: {},
                myAppsStorages: null,
                onLoad: function() {
                    if (widget.getValue('icon') != null) {
                        widget.setIcon("<%=sRealURL%>/" + widget.getValue('icon'));
                    } else {
                        var prefix = '<%= XSSUtil.encodeForURL(request.getParameter("bps_widget")) %>'.substring(0,3);
                        if (prefix != "CSG") {
                            widget.setIcon("<%=sRealURL%>/widget/images/MyApps/iconENOVIA.png");
                        }
                    }
                    if (widget.getValue('title') != null) {
                        widget.setTitle(widget.getValue('title'));
                    }
                },
                loadBPS: function() {
                    widget.setBody('<p>' + bpsWidgetConstants.str.Loading + '...</p>');
                    var storage = widget.getValue('collabstorage'),
                    space = widget.getValue('collabspace');
                    enoviaServer.rows = widget.getValue("totalrows");

                    function processStorages(data) {
                        MyWidget.myAppsStorages = data;
                        var isInPrefs = false,
                        myOpts = [{
                            label: bpsWidgetConstants.str.OptionsSelect,
                            value: ""
                        }];
                        jQuery(data).each(function(index) {
                            this.url = this.url.replace(":443", "");  //work-around config issue.
                            if (this.url.charAt(this.url.length-1) == "/") { //remove slash from end of URL.
                                this.url = this.url.substring(0, this.url.length-1)
                            }
                            if (this.id) {
                                this.url = this.url.replace(this.id, this.id.toLowerCase());  //ensure URL prefix is lower case for valid URL.
                            }
                            myOpts.push({
                                label: this.displayName,
                                value: this.url
                            });
                            if (storage === this.url) {
                                isInPrefs = true;
                                enoviaServer.storageUrl = this.url;
                                enoviaServer.tenant = this.id;
                            }
                        });

                        if (!isInPrefs && !widget.isEdit) {
                            isInPrefs = true;
                            enoviaServer.storageUrl = data[0].url;
                            enoviaServer.tenant = data[0].id;
                        }

                        widget.addPreference({
                            name: "collabstorage",
                            type: "list",
                            defaultValue: enoviaServer.storageUrl,
                            options: myOpts,
                            label: bpsWidgetConstants.str.CollaborativeStorages,
                            onchange: "onStorageChange"
                        });

                        if (showSpace.toLowerCase() != "false") {
                            widget.addPreference({
                                    name: "collabspace",
                                    type: "list",
                                    defaultValue: "",
                                    options: [{
                                    label: bpsWidgetConstants.str.StorageSelect,
                                    value: ""
                                },{
                                    label: "",
                                    value: ""
                                }],
                                    label: bpsWidgetConstants.str.CollaborativeSpaces
                            });
                        }

                        MyWidget.setRowPref();
                        MyWidget.setSizePref();

                        if (isInPrefs) {
                            // try to get spaces
                            if (showSpace.toLowerCase() != "false") {
                                //get the spaces
                                MyWidget.processStorageChange("collabstorage", storage);
                            } else if(!widget.isEdit) {
                                widget.setValue("collabstorage", enoviaServer.storageUrl);
                                MyWidget.onAfterLoad();
                            }
                        } else {
                            widget.setBody('<p>' + bpsWidgetConstants.str.StorageSelect + '</p>');
                        }
                    }//end function processStorages
                    if(MyWidget.myAppsStorages){
                         processStorages(MyWidget.myAppsStorages);
                    } else {
                        bpsWidgetAPIs.getCollaborativeStorages(processStorages);
                    }
                },
                setRowPref: function () {
                        var defaultValue = "100";
                        widget.addPreference({
                        name: "totalrows",
                        type: "list",
                        defaultValue: defaultValue,
                        options: [{
                                    label: "10",
                                    value: "10"
                                }, {
                                    label: "20",
                                    value: "20"
                                }, {
                                    label: "50",
                                    value: "50"
                                }, {
                                    label: "100",
                                    value: "100"
                                }, {
                                    label: "500",
                                    value: "500"
                                }, {
                                    label: "1000",
                                    value: "1000"
                                }],
                        label: bpsWidgetConstants.str.Rows,
                        onchange: "onRowChange"
                    });
                    if (enoviaServer.rows == null) {
                        enoviaServer.rows = defaultValue;
                    }
                },
                setSizePref: function () {
                        widget.addPreference({
                        name: "widgetsize",
                        type: "list",
                        defaultValue: "small",
                        options: [{
                                    label: bpsWidgetConstants.str.Small,
                                    value: "small"
                                }, {
                                    label: bpsWidgetConstants.str.Medium,
                                    value: "medium"
                                }, {
                                    label: bpsWidgetConstants.str.Large,
                                    value: "large"
                                }],
                        label: bpsWidgetConstants.str.Size,
                        onchange: "onSizeChange"
                    });
                },
                setPref: function(name, label, data, changeEvent, isSortPref) {
                    var myOpts = [],
                        defaultValue = "",
                        sortdir = "";
                    jQuery(data).each(function(index) {
                        myOpts.push({
                            label: this.displayName,
                            value: this.value
                        });
                        if(this.defaultValue != null || index == 0) {
                            defaultValue = this.defaultValue || this.value;
                            if(isSortPref == true) {
                                sortdir = this.sortdir;
                            }
                        }
                    });

                    widget.addPreference({
                        name: name,
                        type: "list",
                        defaultValue: defaultValue,
                        options: myOpts,
                        label: label,
                        onchange: changeEvent != null ? changeEvent : "onEditPrefChange"
                    });

                    if(isSortPref == true) {
                        var dirOptions = [{
                            displayName: bpsWidgetConstants.str.OptionsSelect,
                            value: "",
                            defaultValue: sortdir
                        }, {
                            displayName: bpsWidgetConstants.str.SortAscending,
                            value: "ascending"
                        }, {
                            displayName: bpsWidgetConstants.str.SortDescending,
                            value: "descending"
                        }];
                        MyWidget.setPref("sortdir", bpsWidgetConstants.str.SortDirection, dirOptions);
                    }
                },
                onAfterLoad: function() {
                    var storage = widget.getValue('collabstorage'),
                    space = enoviaServer.space,
                    widget_name = '<%= XSSUtil.encodeForURL(request.getParameter("bps_widget")) %>';

                    MyWidget.setDimensions();
                    //add custom preferences
                    for (var key in widget.data) {
                        if (key.indexOf("bps_preference_") != -1) {
                            var val = eval ( '(' + widget.getValue(key) + ')'),
                            prefValue = widget.getValue(val.name);
                            widget.addPreference(val);
                            if (prefValue != "") {
                                enoviaServer.preferences[val.name] = prefValue;
                            }
                        }
                    }

                    var initObj = {
                        name: widget_name,
                        div: randomName,
                        uwaWidget: widget,
                        viewpref: widget.getValue("view"),
                        sortpref: widget.getValue("sort"),
                        sortdirpref: widget.getValue("sortdir"),
                        callback: MyWidget.draw,
                        cspace: space,
                        params: enoviaServer.params,
                        tenant: enoviaServer.tenant
                    };
                    var data = (this.bpsWidget != null) ? this.bpsWidget.data : null;
                    this.bpsWidget = bpsWidgetEngine.widget(initObj);
                    this.bpsWidget.setLabel(false);
                    this.bpsWidget.init(data);
                },
                setDimensions: function (){
                    var viewport = widget.getViewportDimensions();
                    widget.body.setStyles({
                        width: viewport.width + 'px'
                    });
                    jQuery('.uwa-scroller', this.body).css('width','100%');
                },
                draw: function (dom) {
                    try {
                        var title, lbl = this.data.widgets[0].label;
                        if (showSpace.toLowerCase() == "true") {
                            title = MyWidget.spaceNames[widget.getValue('collabspace')] + " " + bpsWidgetConstants.str.Content;
                        } else {
                            var objectLabel = "",
                            objId = widget.getValue('objectId') || objectId;
                            if (objId != null && objId != "" && objId != 'null') {
                                title = bpsWidgetAPIs.getWidgetTitle(this.data.widgets[0], objId);
                                if (title != null) {
                                    objectLabel = title;
                                }
                            } else if (lbl && lbl.text) {
                                var indexDash = lbl.text.lastIndexOf(" - ");
                                if (indexDash != -1) {
                                    objectLabel = lbl.text.substring(indexDash+3);
                                } else {
                                    objectLabel = lbl.text;
                                }                                
                            }
                            title = objectLabel;
                        }
                        if (title != "") {
                            widget.setTitle(title);
                            widget.setValue("title", title);
                        }
                        if (lbl && lbl.icon) {
                            widget.setIcon("<%=sRealURL%>/" + lbl.icon);
                            widget.setValue("icon", lbl.icon);
                        }
                        //display user views.
                        var userviews = bpsWidgetAPIs.getWidgetViews(this.data.widgets[0]);
                        if (userviews.length > 0) {
                            MyWidget.setPref("view", bpsWidgetConstants.str.Views, userviews);
                        }
                        //display sort options.
                        var sortfields = bpsWidgetAPIs.getSortableFields(this.data.widgets[0]);
                        if (sortfields.length > 0) {
                            sortfields = [{displayName: bpsWidgetConstants.str.OptionsSelect, value: ""}].concat(sortfields);
                            MyWidget.setPref("sort", bpsWidgetConstants.str.Sorts, sortfields, null, true);
                        }
                    } catch (e) {
                        console.log(e.message);
                        //do nothing
                    }
                    widget.setBody('<div id="' + randomName +'"></div>');
                    jQuery('#' + randomName).empty().append(this.dom);
                    jQuery('#' + randomName + ' .ds-widget').on('click', '[data-objectId]', MyWidget.onClickItem);
                    widget.refreshing = false;
                },
                searchWidgets: function (searchStr) {
                    var items = bpsWidgetAPIs.getContainerItems(MyWidget.bpsWidget.data.widgets[0]),
                    i = 0, len = items.length;
                    for (; i < len; i++) {
                       bpsWidgetTagNavInit.keywordSearch(items[i], searchStr);
                    }
                },
                clearData: function () {
                    //clear TN if exists
                    if (MyWidget.bpsWidget && MyWidget.bpsWidget.data) {
                        bpsWidgetAPIs.destroyTNProxies(MyWidget.bpsWidget.data.widgets[0]);
                        MyWidget.bpsWidget.data = null;
                    }
                },
                onStorageChange: function (name, storageUrl) {
                    MyWidget.clearData();
                    MyWidget.loadBPS();
                },
                onSpaceChange: function () {
                    MyWidget.clearData();
                },
                onRowChange: function () {
                    MyWidget.clearData();
                },
                onSizeChange: function () {
                    MyWidget.onEdit();
                },
                processStorageChange: function (name, storageUrl) {
                    var space = widget.getValue('collabspace');
                    function tmpFunc(data) {
                        var isInSpace = false,
                        myOpts = [{
                                    label: bpsWidgetConstants.str.OptionsSelect,
                                    value: ""
                                }]
                        jQuery(data).each(function(index) {
                            myOpts.push({
                                    label: this.displayName,
                                    value: this.name
                                });
                            if (space === this.name || (!isInSpace && space == null && "Common Space" == this.displayName)) {
                                if (space != "default") {
                                    enoviaServer.space = this.name;
                                }
                                isInSpace = true;
                            }
                            MyWidget.spaceNames[this.name] = this.displayName;
                        });
                        MyWidget.spaceNames[enoviaServer.storageUrl] = data; //save last retrieved storage spaces.

                        //set default space if not specified yet.
                        if (!isInSpace && !widget.isEdit) {
                            if (data[0].name != "default") {
                                enoviaServer.space = data[0].name;
                            }
                            isInSpace = true;
                        }

                        widget.addPreference({
                                name: "collabspace",
                                type: "list",
                                defaultValue: enoviaServer.space,
                                options: myOpts,
                                label: bpsWidgetConstants.str.CollaborativeSpaces,
                                onchange: "onSpaceChange"
                        });

                        // Request edit to open/refresh
                        if (widget.isEdit) {
                            widget.dispatchEvent('onEdit');
                        }

                        if(isInSpace && !widget.isEdit) {
                           if (enoviaServer.space) {
                              widget.setValue("collabspace", enoviaServer.space);
                           }
                                MyWidget.onAfterLoad();
                        } else {
                            widget.setBody('<p>' + bpsWidgetConstants.str.SpaceSelect +  '</p>');
                        }
                    }
                    var cspaceData = MyWidget.spaceNames[storageUrl];
                    if (cspaceData) {
                        tmpFunc(cspaceData);
                    } else {
                        enoviaServer.space = null; //clear out existing space when getting spaces from a tenant.
                        bpsWidgetAPIs.getCollaborativeSpaces(tmpFunc);
                    }
                },
                onRefresh: function () {
                    if (widget.refreshing == true) {
                        return;
                    }
                    widget.refreshing = true;
                    if (MyWidget.dontClear != true) {
                        MyWidget.clearData();
                        MyWidget.spaceNames = {};
                    }
                    MyWidget.dontClear = false;
                    MyWidget.loadBPS();
                },
                onForceRefresh: function (doReload) {
                    MyWidget.clearData();
                    if (doReload) {
                        MyWidget.loadBPS();
                    }
                    enoviaServer.preferences = {};
                },
                onContextChange: function (contextId) {//get the tagger context id.
                    enoviaServer.taggerContextId = contextId;
                    MyWidget.loadBPS();
                },
                onEditPrefChange: function () {
                    MyWidget.onEdit();
                },
                onEdit: function () {//prevent onRefresh from being called when editing preferences
                    widget.refreshing = false;
                    MyWidget.dontClear = true;
                },
                onClickItem: function() {// Valid items have the following properties: item.objectType, item.objectId, item.cstorage, item.cspace. No one of these properties is mandatory, however, if objectId is set, cstorage must be set and conversely.
                    var InterCom, item, oid, pid, busType, isSelected,
                    widgetEventSocket = MyWidget.widgetEventSocket,
                    space = enoviaServer.space,
                    jElem, evtSocketName = randomName + "EventSocket";
                    jElem = jQuery(this);
                    isSelected = jElem.hasClass('selected');
                    oid = jElem.attr('data-objectId');
                    pid = jElem.attr('data-pid');
                    //oid is set to physicalId if it exists
                    if (pid && pid.length > 0) {
                        oid = pid;
                    } else if (oid == null || oid.length == 0) {
                        return;
                    }
                    busType = jElem.attr('data-type');
                    if (isSelected) {// add oid to top of stack
                        MyWidget.arrOid.push(oid);
                    } else { //remove oid from anywhere in stack
                        for(var i in MyWidget.arrOid){
                            if(MyWidget.arrOid[i]===oid){
                                MyWidget.arrOid.splice(i,1);
                                break;
                            }
                        }
                        // get last oid if it exists
                        if (MyWidget.arrOid.length == 0) {
                            oid = null;
                        } else {
                            oid = MyWidget.arrOid[MyWidget.arrOid.length-1];
                        }
                    }
                    if (widgetEventSocket == null) {
                        InterCom = UWA.Utils.InterCom; // Make an alias to API, it's not required, but help for compression and shortcut.
                        widgetEventSocket = new InterCom.Socket(evtSocketName); // Init "widgetNameEventSocket" into an iframe or main page
                        widgetEventSocket.subscribeServer('com.ds.compass', window.parent); // Request the Compass Server for widgetEventSocket
                        MyWidget.widgetEventSocket = widgetEventSocket;  //cache intercom object.
                    }
                    if (oid) {
                        item = {
                            objectType: busType,
                            objectId: oid,
                            envId: enoviaServer.tenant,
                            contextId: space != null ? space.replace("ctx::","") : ""
                        };

                        widgetEventSocket.dispatchEvent('onSetObject', item, evtSocketName); // Send the item to widgetNameEventSocket socket by the dispatchEvent 'onSetObject', it will be caught by the subscribed event server
                    } else {
                        widgetEventSocket.dispatchEvent('onResetObject', {}, evtSocketName);
                    }
                }
            }

            widget.MyWidget = MyWidget;

            /*
                The "onLoad" event is the very first event triggered when the widget is loaded.
                Here, we make it trigger the MyWidget.onLoad() function as listener.
            */
            widget.addEvents({
                onLoad: MyWidget.onLoad,
                onResize: MyWidget.setDimensions,
                onStorageChange: MyWidget.onStorageChange,
                onSpaceChange: MyWidget.onSpaceChange,
                onRowChange: MyWidget.onRowChange,
                onSizeChange: MyWidget.onSizeChange,
                onEditPrefChange: MyWidget.onEditPrefChange,
                onRefresh: MyWidget.onRefresh,
                onForceRefresh: MyWidget.onForceRefresh,
                onContextChange: MyWidget.onContextChange,
                onSearch: MyWidget.searchWidgets,
                onResetSearch: MyWidget.searchWidgets,
                onEdit: MyWidget.onEdit
            });
            })();

        //]]>
        </script>
    </head>
    <body/>
</html>
