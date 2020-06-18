/*!==========================================================================
 *  JavaScript Report Functions
 *
 *  emxMetricsDashboard.js
 *
 *  This file contains the code for Metrics Dashboard feature
 *
 *  Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
 *
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxMetricsDashboard.js.rca 1.13 Wed Oct 22 16:11:56 2008 przemek Experimental $
 *============================================================================
 */

 // Global variables

    var maxReportsInWideChannels;
    var maxReportsInNarrowChannels;
    var layout1Format;
    var layout2Format;
    var layout3Format;
    var layout4Format;
    var layout5Format;
    var totalLayouts;
    var storedSelectedLayout;

    var channel1prefreports;
    var channel2prefreports;
    var channel3prefreports;
    var channel4prefreports;

    var channel1Display;
    var channel2Display;
    var channel3Display;
    var channel4Display;

    var validReports;

    function assignwebreport(buttonObj)
    {
        var buttonValue = buttonObj.name;
        var buttonDisplay = buttonObj.value;
        var spaceIndex = buttonValue.indexOf(" ");
        var channelNo = parseInt(buttonValue.substring(spaceIndex));
        var formObj  = document.forms[0];

        var unAssnList  = formObj.UnassignedReports;
        var assnList  = formObj.AssignedReports;
        var allowedLen = 0;

        var maxItemsUnAssn = unAssnList.options.length;

        var maxItemsAssn = assnList.length;

        allowedLen = getAllowedReportsSize(channelNo);

        if(unAssnList.selectedIndex != -1){
            if(canAddReport(allowedLen, channelNo, assnList)){
                for(var i=0;i<maxItemsUnAssn; i++)  {
                    if(unAssnList.options[i] != null) {
                        if(unAssnList.options[i].selected){
                            var reportWithOwnerName = unAssnList.options[i].value;
                            var reportName = "";
                            var index = reportWithOwnerName.indexOf("|");
                            if(index != -1){
                                reportName = reportWithOwnerName.substring(0,index)
                            }

                            var channelReport = buttonDisplay+" | "+reportName
                            var hiddenOptionValue = buttonValue+" | " + reportWithOwnerName

                            var optReport = new Option(channelReport,hiddenOptionValue);
                            if(checkReportExistence(channelReport))  {
                                if(canAddReport(allowedLen, channelNo, assnList)){
                                    var len = assnList.options.length;
                                    assnList.options.add(optReport);
                                    addReportHidden(formObj, hiddenOptionValue);
                                    unAssnList.options[i] = null;
                                    --i;

                                    if(buttonValue == 'Channel 1')
                                    {
                                        assnList.options[len].className = "channel1";
                                        len++;
                                    }
                                    else if(buttonValue == 'Channel 2') {
                                        assnList.options[len].className = "channel2";
                                        len++;
                                    }
                                    else if(buttonValue == 'Channel 3') {
                                        assnList.options[len].className = "channel3";
                                        len++;
                                    }
                                    else if(buttonValue == 'Channel 4') {
                                        assnList.options[len].className = "channel4";
                                        len++;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else{
                alert(allowedLen+" "+STR_METRICS_LIMITREACHED_MSG);
            }
        }
        else if(assnList.selectedIndex != -1){
            if(canAddReport(allowedLen, channelNo, assnList)){
                  for(var i=maxItemsAssn-1;i>-1; i--){
                    if(assnList.options[i].selected == true){
                        if(canAddReport(allowedLen, channelNo, assnList)){
                            var channelReport = assnList.options[i].value
                            assnList.options[i]=null;
                            removeReportHidden(formObj, channelReport);
                            var channelRemoved = trimString(channelReport.substring(channelReport.indexOf("|")+1,channelReport.length));
                            var webreportname = trimString(channelReport.substring(channelReport.indexOf("|")+2,channelReport.lastIndexOf("|")));
                            channelReport = buttonDisplay+" | "+webreportname
                            var hiddenOptionValue = buttonValue+" | "+channelRemoved
                            var optReport = new Option(channelReport,hiddenOptionValue);

                            if(checkReportExistence(channelReport))  {
                                var len = assnList.options.length;
                                assnList.options.add(optReport);
                                addReportHidden(formObj, hiddenOptionValue);

                                if(buttonValue == 'Channel 1')
                                {
                                  assnList.options[len].className = "channel1";
                                  len++;
                                }
                                else if(buttonValue == 'Channel 2') {
                                  assnList.options[len].className = "channel2";
                                  len++;
                                }
                                else if(buttonValue == 'Channel 3') {
                                  assnList.options[len].className = "channel3";
                                  len++;
                                }
                                else if(buttonValue == 'Channel 4') {
                                  assnList.options[len].className = "channel4";
                                  len++;
                                }
                            }
                        }
                    }
                }
            }
            else{
                alert(allowedLen+" "+STR_METRICS_LIMITREACHED_MSG);
            }
        }
        else
        {
            alert(STR_METRICS_UNASSIGNED_SELECTION_MSG);
        }
     }


    function checkMaxSize(selectedLayout){
        var assnList  = document.forms[0].AssignedReports;
        var channel1Count = 0;
        var channel2Count = 0;
        var channel3Count = 0;
        var channel4Count = 0;

        if(assnList.length > 0) {
            for(var i=0; i<assnList.length; i++){
                var channelReport = assnList.options[i].value;
                channelReport = channelReport.substring(0,channelReport.lastIndexOf("|")-1);
                if(channelReport == 'Channel 1'){
                    channel1Count++;
                }
                if(channelReport == 'Channel 2'){
                    channel2Count++;
                }
                if(channelReport == 'Channel 3'){
                    channel3Count++;
                }
                if(channelReport == 'Channel 4'){
                    channel4Count++;
                }
            }
        }
    }

    function checkReportExistence(selectedValue){

        var assnList  = document.forms[0].AssignedReports;
        var returnVal = true;

        for(var j=0; j<assnList.length; j++){
            if(assnList.options[j].value == selectedValue){
                returnVal = false;
            }
        }
        return returnVal;
    }

    function unassignwebreport(){

        var formObj  = document.forms[0];
        var unAssnList  = formObj.UnassignedReports;
        var assnList  = formObj.AssignedReports;

        var maxItemsUnAssn = unAssnList.length;
        var maxItemsAssn = assnList.length;

        if(assnList.selectedIndex == -1){
          alert(STR_METRICS_DASHBOARD_UNASSIGN_MSG);
        }
        else {
            for(var i=maxItemsUnAssn-1;i>-1; i--){
                unAssnList.options[i].selected = false;
            }

            for(var i=maxItemsAssn-1;i>-1; i--){
              if(assnList.options[i].selected == true){
                 if(assnList.options.length !=0){
                     var channelReport = assnList.options[i].value;
                     // will be of the form....
                     // channelReport = "Channel 1 | T2E Rep3|Test2 Employee

                     assnList.options[i] = null; //delete
                     var assListChannelValues;
                     var hiddenOptionValue;
                     var valueForRemoving;
                     var valueForDisplay;

                     valueForRemoving = channelReport.substring(0,channelReport.lastIndexOf("|"));
                     removeReportHidden(formObj,channelReport);

                     // again add into the Unassigned Reports List box
                     hiddenOptionValue = channelReport.substring(channelReport.indexOf("|")+2,channelReport.length );
                     
                     valueForDisplay = valueForRemoving.substring(valueForRemoving.lastIndexOf("|")+2,valueForRemoving.length)
                     
                     var optReport = new Option(valueForDisplay,hiddenOptionValue);
                     unAssnList.options.add(optReport);
                }
              }
           }
        }
    }


    function changeSelection(obj, selectedLayout,selectedLayoutFormat)  {
        var previousSelectedLayout = document.forms[0].prevlayout.value;
        var assnList  = document.forms[0].AssignedReports;
        var unAssnList  = document.forms[0].UnassignedReports;
        var maxItemsAssn = assnList.length;
        var maxItemsUnassn = unAssnList.length;
        var channelTemplateValues = getLayoutFormat();
        var channelTemplateAllowedSize = Array(4);
        for(var i=0; i<channelTemplateValues.length;i++)
        {
            if(channelTemplateValues[i] == "wide")  {
                channelTemplateAllowedSize[i] = maxReportsInWideChannels
            }
            else {
                channelTemplateAllowedSize[i] = maxReportsInNarrowChannels
            }
        }

       var formObj  = document.forms[0]
       var channel1reportsno = 0;
       var channel2reportsno = 0;
       var channel3reportsno = 0;
       var channel4reportsno = 0;

       for(var i=0;i<maxItemsAssn; i++)  {
           var channelReport = assnList.options[i].value
           var spaceFirstIndex = channelReport.indexOf(" ");
           var spaceLastIndex = channelReport.indexOf("|");
           var channelNo = trimString(channelReport.substring(spaceFirstIndex,spaceLastIndex));
           if(channelNo == 1)
           {
               ++channel1reportsno;
           }
           else if(channelNo == 2) {
               ++channel2reportsno;
           }
           else if(channelNo == 3) {
               ++channel3reportsno;
           }
           else {
               ++channel4reportsno;
           }
       }

       if(!(channel1reportsno<=channelTemplateAllowedSize[0] && channel2reportsno<=channelTemplateAllowedSize[1] && channel3reportsno<=channelTemplateAllowedSize[2] && channel4reportsno<=channelTemplateAllowedSize[3])) {
           if(confirm(STR_METRICS_CHANGELAYOUT_MSG) !=0)
           {
               for(var x=0; x<totalLayouts;x++)  {
                   if(document.forms[0].template[x].checked == true)
                   {
                       document.forms[0].prevlayout.value = document.forms[0].template[x].value;
                   }
               }

               for(var i=maxItemsAssn-1;i>-1; i--)  {
                   var channelReport = assnList.options[i].value

                   var spaceFirstIndex = channelReport.indexOf(" ");
                   var spaceLastIndex = channelReport.indexOf("|");
                   var channelNo = trimString(channelReport.substring(spaceFirstIndex,spaceLastIndex));
                   if(channelNo == 1 && channel1reportsno>channelTemplateAllowedSize[0]) {
                       //before removing add it to the unassigned column
                       setReportsToUnassignedList(unAssnList,channelReport);
                       assnList.options[i]=null;
                       removeReportHidden(formObj, channelReport);
                       --channel1reportsno;
                   }
                   else if(channelNo == 2 && channel2reportsno>channelTemplateAllowedSize[1]) {
                       //before removing add it to the unassigned column
                       setReportsToUnassignedList(unAssnList,channelReport);
                       assnList.options[i]=null;
                       removeReportHidden(formObj, channelReport);
                       --channel2reportsno;
                   }
                   else if(channelNo == 3 && channel3reportsno>channelTemplateAllowedSize[2]) {
                       //before removing add it to the unassigned column
                       setReportsToUnassignedList(unAssnList,channelReport);
                       assnList.options[i]=null;
                       removeReportHidden(formObj, channelReport);
                       --channel3reportsno;
                   }
                   else if(channelNo == 4 && channel4reportsno>channelTemplateAllowedSize[3]) {
                       //before removing add it to the unassigned column
                       setReportsToUnassignedList(unAssnList,channelReport);
                       assnList.options[i]=null;
                       removeReportHidden(formObj, channelReport);
                       --channel4reportsno;
                   }
               }
            }
            else{
                for(var x=0; x<totalLayouts;x++)  {
                    if(document.forms[0].template[x].value == previousSelectedLayout){
                        document.forms[0].template[x].checked = true;
                        document.forms[0].prevlayout.value = document.forms[0].template[x].value;
                    }
               }
            }
        }
        else{
            for(var x=0; x<totalLayouts;x++)  {
                if(document.forms[0].template[x].checked == true) {
                    document.forms[0].prevlayout.value = document.forms[0].template[x].value;
                }
            }
        }


        var newSelectedDiv = document.getElementById(selectedLayout);
        newSelectedDiv.className = "selected";

        chn1 = arguments[1];
        chn2 = arguments[2];
        chn3 = arguments[3];
        chn4 = arguments[4];

        var chn1Counter =0;
        var chn2Counter =0;
        var chn3Counter =0;
        var chn4Counter =0;

        for(var i=0;i<assnList.length;i++){
            var channelReport = assnList.options[i].value;
            channelReport = channelReport.substring(0,channelReport.lastIndexOf("|")-1);
            if(channelReport == 'Channel 1'){
                chn1Counter++;
            }
            else if(channelReport == 'Channel 2'){
                chn2Counter++;
            }
            else if(channelReport == 'Channel 3'){
                chn3Counter++;
            }
            else if(channelReport == 'Channel 4'){
                chn4Counter++;
            }
        }

        if(chn1 < chn1Counter ){
            confirm(STR_METRICS_DASHBOARD_CHANGELAYOUT_MSG);
        }

        // Disable other divs
        for(var x=0; x<totalLayouts;x++){
            if(!document.forms[0].template[x].checked){
                var otherLayoutsDiv = document.getElementById(document.forms[0].template[x].value);
                if(otherLayoutsDiv){
                    otherLayoutsDiv.className = "notSelected";
                }
            }
        }
    }

    // This function will set the reports to the unassigned list
    function setReportsToUnassignedList(unAssnList,channelReport){
        valueForRemoving = channelReport.substring(0,channelReport.lastIndexOf("|"));

        hiddenOptionValue = channelReport.substring(channelReport.indexOf("|")+2,channelReport.length );
        valueForDisplay = valueForRemoving.substring(valueForRemoving.lastIndexOf("|")+2,valueForRemoving.length)

        var optReport = new Option(valueForDisplay,hiddenOptionValue);
        unAssnList.options.add(optReport);
    }


     // sets the layout and div color of the user's selection as
     // stored in the database
     function setStoredSelectedLayout(){

        for(var x=0; x<totalLayouts;x++){
            if(storedSelectedLayout == document.forms[0].template[x].value){
                document.forms[0].template[x].checked = "true";
                document.forms[0].prevlayout.value = document.forms[0].template[x].value;
                // Enable the selected layout div
                var storedSelectedLayoutDiv = document.getElementById(storedSelectedLayout);
                if(storedSelectedLayoutDiv){
                    storedSelectedLayoutDiv.className = "selected";
                }
            }
            else{
                // Disable all the other selected layout div (if any)
                var otherLayoutsDiv = document.getElementById(document.forms[0].template[x].value);
                if(otherLayoutsDiv){
                    otherLayoutsDiv.className = "notSelected";
                }
            }
        }
        initialPopulateAssignList();
     }

    function deselectOption(selObj){
        var nxtSelObj = null;
        if(selObj.name == "AssignedReports"){
            nxtSelObj  = document.forms[0].UnassignedReports;
        }
        else {
            nxtSelObj  = document.forms[0].AssignedReports;
        }
        var maxItems = nxtSelObj.length;

        for(var i=0;i<maxItems; i++)  {
          nxtSelObj.options[i].selected = false;
        }
    }

    function canAddReport(allowedLen, chnNo, listObj)
    {
        var count = 0;
        for(var i=0; i<listObj.length;i++)  {
            var chkName = listObj.options[i].value.split("|");
            var channelNo = trimString(chkName[0]);
            channelNo = channelNo.substring((channelNo.length -1), channelNo.length);

            if(channelNo == chnNo)  {
                ++count;
            }
        }

        if(count < allowedLen) {
            return true;
        }
        else  {
            return false;
        }
    }

    function trimString(strString) {
        strString = strString.replace(/^\s*/g, "");
        return strString.replace(/\s+$/g, "");
    }


    function createDashboard(){
        document.forms[0].action = "emxMetricsDashboardCreateProcess.jsp";
        document.forms[0].submit();
    }

    function getLayoutFormat()
    {
        //layout1Format
        var globalLayoutSelection;
        for(var x=0; x<totalLayouts;x++)  {
          if(document.forms[0].template[x].checked){
              globalLayoutSelection = document.forms[0].template[x].value;
          }
        }

        var channelTemplateValues;
        if(globalLayoutSelection == "layout1") {
            channelTemplateValues = layout1Format.split(",")
        } else if(globalLayoutSelection == "layout2") {
            channelTemplateValues = layout2Format.split(",")
        } else if(globalLayoutSelection == "layout3") {
            channelTemplateValues = layout3Format.split(",")
        } else if(globalLayoutSelection == "layout4") {
            channelTemplateValues = layout4Format.split(",")
        } else if(globalLayoutSelection == "layout5") {
            channelTemplateValues = layout5Format.split(",")
        }
        return channelTemplateValues;
    }

    function initialPopulateAssignList()
    {
        var assnList = document.forms[0].AssignedReports;

        var populatechnAssnReports;
        var populatechnAssnReportsHidden = new Array;
        var channelNo;
        var allowedReportSize;
        if(channel1prefreports)
        {
            populatechnAssnReports = channel1prefreports.split(",");

            for(var i=0;i<populatechnAssnReports.length-1;i++){
                populatechnAssnReportsHidden[i] = "Channel 1"+ populatechnAssnReports[i].substring(populatechnAssnReports[i].indexOf("|"));
            }   

            channelNo = 1;
            allowedReportSize = getAllowedReportsSize(channelNo);
            channel1prefreports = "";

            for(var i=0;i<populatechnAssnReports.length-1;i++)
            {
                if(canAddReport(allowedReportSize, channelNo, assnList)){
                    var displayValue = populatechnAssnReports[i].substring(0,populatechnAssnReports[i].lastIndexOf("|"));
                    var addOption = new Option(displayValue, populatechnAssnReportsHidden[i]);

                    if(isReportExistsinDB(displayValue))
                    {
                        assnList.options.add(addOption);
                        channel1prefreports += populatechnAssnReportsHidden[i]+",";
                    }
                }
            }
        }

        if(channel2prefreports)
        {
            populatechnAssnReports = channel2prefreports.split(",");
            for(var i=0;i<populatechnAssnReports.length-1;i++){
                populatechnAssnReportsHidden[i] = "Channel 2"+ populatechnAssnReports[i].substring(populatechnAssnReports[i].indexOf("|"));
            }   
            channelNo = 2;
            allowedReportSize = getAllowedReportsSize(channelNo);
            channel2prefreports = "";
            for(var i=0;i<populatechnAssnReports.length-1;i++)
            {
                if(canAddReport(allowedReportSize, channelNo, assnList))  {
                    var displayValue = populatechnAssnReports[i].substring(0,populatechnAssnReports[i].lastIndexOf("|"));
                    var addOption = new Option(displayValue, populatechnAssnReportsHidden[i]);
                    if(isReportExistsinDB(displayValue))
                    {
                        assnList.options.add(addOption);
                        channel2prefreports += populatechnAssnReportsHidden[i]+",";
                    }
                }
            }
        }

        if(channel3prefreports)
        {
            populatechnAssnReports = channel3prefreports.split(",");
            for(var i=0;i<populatechnAssnReports.length-1;i++){
                populatechnAssnReportsHidden[i] = "Channel 3"+ populatechnAssnReports[i].substring(populatechnAssnReports[i].indexOf("|"));
            }   
            channelNo = 3;
            allowedReportSize = getAllowedReportsSize(channelNo);
            channel3prefreports = "";

            for(var i=0;i<populatechnAssnReports.length-1;i++)
            {
                if(canAddReport(allowedReportSize, channelNo, assnList))  {
                    var displayValue = populatechnAssnReports[i].substring(0,populatechnAssnReports[i].lastIndexOf("|"));
                    var addOption = new Option(displayValue, populatechnAssnReportsHidden[i]);
                    if(isReportExistsinDB(displayValue))
                    {
                        assnList.options.add(addOption);
                        channel3prefreports += populatechnAssnReportsHidden[i]+",";
                    }
                }
            }
        }
        if(channel4prefreports)
        {
            populatechnAssnReports = channel4prefreports.split(",");
            for(var i=0;i<populatechnAssnReports.length-1;i++){
                populatechnAssnReportsHidden[i] = "Channel 4"+ populatechnAssnReports[i].substring(populatechnAssnReports[i].indexOf("|"));
            }   
            channelNo = 4;
            allowedReportSize = getAllowedReportsSize(channelNo);
            channel4prefreports = "";

            for(var i=0;i<populatechnAssnReports.length-1;i++)
            {
                if(canAddReport(allowedReportSize, channelNo, assnList))  {
                    var displayValue = populatechnAssnReports[i].substring(0,populatechnAssnReports[i].lastIndexOf("|"));
                    var addOption = new Option(displayValue, populatechnAssnReportsHidden[i]);

                    if(isReportExistsinDB(displayValue))
                    {
                        assnList.options.add(addOption);
                        channel4prefreports += populatechnAssnReportsHidden[i]+",";
                    }
                }
            }
        }

        for(var i=0; i<assnList.options.length;i++)
        {
            var channelReport = assnList.options[i].value;
            channelReport = channelReport.substring(0,channelReport.indexOf("|"));
            if(channelReport == 'Channel 1'){
                assnList.options[i].className = "channel1";
            }
            else if(channelReport == 'Channel 2'){
                assnList.options[i].className = "channel2";
            }
            else if(channelReport == 'Channel 3'){
                assnList.options[i].className = "channel3";
            }
            else if(channelReport == 'Channel 4'){
                assnList.options[i].className = "channel4";
            }
        }

        document.forms[0].channel1reports.value = channel1prefreports;
        document.forms[0].channel2reports.value = channel2prefreports;
        document.forms[0].channel3reports.value = channel3prefreports;
        document.forms[0].channel4reports.value = channel4prefreports;
    }

    function getAllowedReportsSize(channelNo)
    {
        channelTemplateValues = getLayoutFormat();
        var allowTyp = channelTemplateValues[channelNo-1];
        var allowedLen;
        if(allowTyp == "wide")  {
            allowedLen = maxReportsInWideChannels;
        }
        else  {
            allowedLen = maxReportsInNarrowChannels;
        }
        return allowedLen;
    }



    function isReportExistsinDB(optionValue)
    {
        var validDBReports = validReports.split(",");
        var reportNameWithoutChannel = optionValue.substring(optionValue.indexOf("|")+1);

        var isExists = false;
        for(var i=0;i < validDBReports.length;i++)
        {
            if(trimString(validDBReports[i]) == trimString(reportNameWithoutChannel))
            {
                isExists = true;
            }
        }
        return isExists;
    }


    function removeReportHidden(formObj, channelReport)
    {
        var assListChannelValues;
        var spaceLastIndex = channelReport.indexOf("|");
        var varChannelName = trimString(channelReport.substring(0,spaceLastIndex));
        if(varChannelName == trimString(channel1Display) || varChannelName == 'Channel 1') {
            if(formObj.channel1reports.value != "")
            {
                assListChannelValues = formObj.channel1reports.value.split(',');
                var resetValue="";
                for(var i=0;i<assListChannelValues.length-1;i++)
                {
                    if(assListChannelValues[i] != channelReport)
                    {
                        resetValue = resetValue + assListChannelValues[i]+",";
                    }
                }
                    formObj.channel1reports.value = resetValue;
            }
        }
        else if(varChannelName == trimString(channel2Display) || varChannelName == 'Channel 2') {
            if(formObj.channel2reports.value)
            {
                assListChannelValues = formObj.channel2reports.value.split(',');
                var resetValue="";
                for(var i=0;i<assListChannelValues.length-1;i++)
                {
                    if(assListChannelValues[i] != channelReport)
                    {
                        resetValue = resetValue + assListChannelValues[i]+",";
                    }
                }
                    formObj.channel2reports.value = resetValue;
            }
        }
        else if(varChannelName == trimString(channel3Display) || varChannelName == 'Channel 3') {
            if(formObj.channel3reports.value != "")
            {
                assListChannelValues = formObj.channel3reports.value.split(',');
                var resetValue="";
                for(var i=0;i<assListChannelValues.length-1;i++)
                {
                    if(assListChannelValues[i] != channelReport)
                    {
                        resetValue = resetValue + assListChannelValues[i]+",";
                    }
                }
                    formObj.channel3reports.value = resetValue;
            }
        }
        else if(varChannelName == trimString(channel4Display) || varChannelName == 'Channel 4') {
            if(formObj.channel4reports.value)
            {
                assListChannelValues = formObj.channel4reports.value.split(',');

                var resetValue="";
                for(var i=0;i<assListChannelValues.length-1;i++)
                {
                    if(assListChannelValues[i] != channelReport)
                    {
                        resetValue = resetValue + assListChannelValues[i]+",";
                    }
                }
                    formObj.channel4reports.value = resetValue;
            }
        }
    }


    function addReportHidden(formObj, channelReport)
    {
        var spaceFirstIndex = channelReport.indexOf(" ");
        var spaceLastIndex = channelReport.indexOf("|");
        var channelNo = trimString(channelReport.substring(spaceFirstIndex,spaceLastIndex));

        if(channelNo == 1) {
            formObj.channel1reports.value = formObj.channel1reports.value+channelReport+ ",";
        }
        if(channelNo == 2) {
            formObj.channel2reports.value = formObj.channel2reports.value+channelReport+ ",";
        }
        if(channelNo == 3) {
            formObj.channel3reports.value = formObj.channel3reports.value+channelReport+ ",";
        }
        if(channelNo == 4) {
            formObj.channel4reports.value = formObj.channel4reports.value+channelReport+ ",";
        }
    }


