<%--  smaSimulationCentralFormValidation.jsp   
 * 
 * (c) Dassault Systemes, 2007, 2008
 *  
--%>
<%-- Common Includes --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIFreezePane.js"></script>

<script language="javascript" type="text/javascript" src="../common/scripts/emxJSValidationUtil.js"></script>

<%!
/*
 * Returns the I18N string for the given message key.
 * Embedded newlines are escaped so that the message can be placed
 * in a javascript alert() call.
 */
private String getAlertMsg(Context context,String msgKey)
{
    String msg = SimulationUtil.getI18NString(context, msgKey);
    msg = msg.replaceAll("\n", "\\n");
    return msg;
}
%>
<%
    // get internationalized error messages
    String locale = context.getSession().getLanguage();

    String titleNotBlank =
        getAlertMsg(context,"Error.ImportExport.DocTitleNotBlank");
    String titleNotSpecified =
        getAlertMsg(context,"Error.ImportExport.DocTitleNotSpecified");
    String dupChoices =
        getAlertMsg(context,"Error.SimConnectorOpt.DuplicateChoices");
    String optHasChoices =
        getAlertMsg(context,"Error.SimConnectorOpt.HasChoices");
    String optHasDefault =
        getAlertMsg(context,"Error.SimConnectorOpt.HasDefaultValue");
    String defaultNotFound =
        getAlertMsg(context,"Error.SimConnectorOpt.DefaultNotFound");
    String invalidTitle =
        getAlertMsg(context,"smaSimulationCentral.Template.NameBadChars");
    String invalidChar =
        getAlertMsg(context,"smaSimulationCentral.Error.InvalidChars");
    String removeChar =
        getAlertMsg(context,"smaSimulationCentral.Error.RemoveInvalidChars");
    String fieldVal =
        getAlertMsg(context,"smaSimulationCentral.Error.Field");
    String missingExporter =
        getAlertMsg(context,"Error.ImportExport.MissingExporter");
    String checkoutVPMNotAllwd =
        getAlertMsg(context,"Error.ImportExport.VPMCheckoutNotAllowed");
    

%>

<script language="javascript">

//Utility function to count the nuber of times item appears in the list.
// Used for possible value validation to make sure no duplicate values.
function countItem(list,item){
    var cnt = 0;
    var itemTrim = item.replace(/\s/g, "").replace(/\r/g, "");
    for (var ijk = 0; ijk < list.length; ijk++)
    {
        var str =
                list[ijk].replace(/\s/g, "").replace(/\r/g, "");
        if(str == itemTrim )
        {
            cnt = cnt +1;
        }
    }
    return cnt;
}

//Validating Document Title for Import Rule Creation
function checkIfDocTitleIsEmpty(){

    var strTitleSpec = document.forms[0].TitleSpecification.value;
    var strDocTitle = document.forms[0].DocumentTitle.value;
    
    if ( (strTitleSpec != '') && (strTitleSpec == 'titleEqualsFileName') && (strDocTitle != '') )
    {
        alert("<%=titleNotBlank %>");
        return false;
    }
    if ( (strTitleSpec != '') && (strTitleSpec == 'titleUserSpecified') && (strDocTitle == '') )
    {
        alert("<%=titleNotSpecified %>");
        return false;
    }
    return true;
}

// This method validates the option type field for connector option
// webform. If the connector option is set to Standalone, we raise an
// error if any value is given to the possible options
function smaValidateConnectorOptionType()
{

    var optType =document.forms[0].ConnectorOptionTypeId.value;
    
    var possibleValues = document.forms[0].PossibleValues.value;
    
    if ( (optType == 'Standalone') && (possibleValues != ''))
    {
        alert("<%=optHasChoices %>");
        return false;
    }
    if(possibleValues != '')
    {
        var mySplitResult = possibleValues.split("\n");
        for(i = 0; i < mySplitResult.length; i++)
        {
            if (countItem(mySplitResult,mySplitResult[i]) > 1)
            {
                alert ("<%=dupChoices %>");
                return false;
            }   
        }
    } 
    
    return true;
}

function smaValidateConnectorOptionDefaultValue()
{
    var defaultValue = document.forms[0].DefaultValue.value;
    var possibleValues = document.forms[0].PossibleValues.value;
    var valueMatched = false;
    if ( defaultValue != '')
    {
    if(possibleValues != '')
    {
        var mySplitResult = possibleValues.split("\n");
        for(var ixz = 0; ixz < mySplitResult.length; ixz++)
        {
            // do a trim of the default and choices and then compare
            var str =
                mySplitResult[ixz].replace(/^\s\s*/, '').replace(/\s\s*$/, '').replace(/\r/g, "");
            var defValue = defaultValue.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
            if(str == defValue)
            {
                valueMatched = true;
                break;
            }
            else
            {
                continue;
            }
        }
        if(valueMatched == false)
        {
            alert("<%=defaultNotFound %>");
            return false;
        }
    }

    var optType = document.forms[0].ConnectorOptionType.value;
    if ( (optType == 'Standalone') && (defaultValue != ''))
    {
        alert("<%=optHasDefault %>");
        return false;
    }
    }
    return true;
}

function smaConnectorOptionTypeCallBack()
{
    var optType = document.forms[0].ConnectorOptionType.value;
    if (optType == 'Standalone')
    {
         document.forms[0].SeparatorValue.readOnly = true;
         document.forms[0].SeparatorValue.style.backgroundColor= "#A9A9A9";        
         document.forms[0].PossibleValues.readOnly = true;
         document.forms[0].PossibleValues.style.backgroundColor= "#A9A9A9";        
         document.forms[0].PossibleValues.value = "";
         document.forms[0].DefaultValue.readOnly = true;
         document.forms[0].DefaultValue.style.backgroundColor= "#A9A9A9";        
         document.forms[0].DefaultValue.value = "";
         document.forms[0].SeparatorValue.value = "";
    }
    else if (optType == 'Standalone-Value')
    {
         document.forms[0].SeparatorValue.readOnly = true;
         document.forms[0].SeparatorValue.style.backgroundColor= "#A9A9A9";        
         document.forms[0].PossibleValues.readOnly = false;
         document.forms[0].PossibleValues.style.backgroundColor= "#ffffff";        
         document.forms[0].DefaultValue.readOnly = false;
         document.forms[0].DefaultValue.style.backgroundColor= "#ffffff";        
         document.forms[0].DefaultValue.value = "";
    }
    else // option-value pair
    {
         document.forms[0].SeparatorValue.readOnly = false;
         document.forms[0].SeparatorValue.style.backgroundColor= "#ffffff";        
         document.forms[0].PossibleValues.readOnly = false;
         document.forms[0].PossibleValues.style.backgroundColor= "#ffffff";        
         document.forms[0].DefaultValue.readOnly = false;
         document.forms[0].DefaultValue.style.backgroundColor= "#ffffff";        
    }
}

function smaExportDocTypeCallBack()
{
    var myForm = document.forms[0];
    if (myForm.PostProcessCmd != null)
    {
        var docType = myForm.ExportDocType.value;
        if (docType == 'VPM')
        {
            // delete any old commands when disabling
            myForm.PostProcessCmd.value = "";  
            myForm.PostProcessCmd.disabled = true;  
        }
        else
        {
            myForm.PostProcessCmd.disabled = false;  
        }
    }
}
             
function smaExporterValidateCallBack()
{
    var myForm = document.forms[0];
    var exportMethod = myForm.ExportMethod.value;
    if(exportMethod == 'exporter' || exportMethod == 'decExport' )
    {
        var exporterDisplay = myForm.ExporterDisplay.value;
        if(exporterDisplay == '')
        {
            alert("<%=missingExporter %>");
            return false;
        }
    }
    else if(exportMethod == 'checkout')
    {
        var docType = myForm.docType;
        var ExportDocType = myForm.ExportDocType;
        if(docType != null){
        
            if(docType.value == 'PLMProductDS')
            {
                alert("<%=checkoutVPMNotAllwd %>");
                return false;
            }
        }
        else if(ExportDocType != null){

            if(ExportDocType.value == 'VPM')
            {
                alert("<%=checkoutVPMNotAllwd %>");
                return false;
            }
        }
    }
    return true;
}

function checkBadChars(fieldName)
{
    if(!fieldName)
    fieldName=this;
    var badChars = "";
    badChars=checkForNameBadChars(fieldName,true);
    if ((badChars).length != 0)
    {
        msg = "<%=invalidChar%>";
        msg += "\n";
        msg += badChars;
        msg += "\n";
        msg += "<%=removeChar%> ";
        msg += fieldName.name;
        msg += " <%=fieldVal%> ";
        fieldName.focus();
        alert(msg);
        return false;
    }
    return true;
}

//Checking for Bad characters in the field
function checkBadNameChars(fieldName) 
{     
   if(!fieldName)
        fieldName=this;
    var badChars = "";
    badNameChars=checkForNameBadChars(fieldName, true);
    if ((badNameChars).length != 0)
    {           
        msg = "<%=invalidChar%>";
        msg += "\n";
        msg += badChars;
        msg += "\n";
        msg += "<%=removeChar%> ";
        msg += fieldName.name;
        msg += " <%=fieldVal%> ";           
        fieldName.focus();
        alert(msg);
        return false;
   }
   return true;
}

function toggleFormFields()
{
   // alert("toggleFormFields");
    alert("toggleFormFields in jsp");
    var frame = findFrame(getTopWindow(),'detailsDisplay');
    //alert(frame);
    var doc = frame.document;
    //alert(doc);
    var displ = doc.getElementById('calc_retry');
   // alert(displ);
    displ.style.visibility='hidden';
   // alert("Done hidden retry");
    var fastpath = doc.getElementById('calc_fastpath');
    fastpath.style.visibility='hidden';
 //  alert("Done hidden fastpath");
    var mxbatchSize = doc.getElementById('calc_maxbatchsize'); 
    mxbatchSize.style.visibility='hidden';
    var localhost = doc.getElementById('calc_RunOnLocalhost');  
    localhost.style.visibility='hidden';
   var group = doc.getElementById('calc_Group'); 
    group.style.visibility='hidden';
    var delay = doc.getElementById('calc_delay'); 
    delay.style.visibility='hidden';
    var timeout = doc.getElementById('calc_timeout');
    timeout.style.visibility='hidden';
   //var form = document.forms[0];
    //var disabel = form.getElementByID("calc_delay");
}
function changeVisibility ()
{
    var frame = findFrame(getTopWindow(),'detailsDisplay');
    var doc = frame.document;
    var displ = doc.getElementById('calc_retry');
    if (displ.style.visibility=='hidden')
    {displ.style.visibility='visible';}
    else {displ.style.visibility='hidden';}
    var fastpath = doc.getElementById('calc_fastpath');
    if(fastpath.style.visibility=='hidden'){
        fastpath.style.visibility='visible';}
    else{fastpath.style.visibility='hidden';}
    var mxbaatchSize = doc.getElementById('calc_maxbatchsize');
    if(mxbaatchSize.style.visibility=='hidden')
    {mxbaatchSize.style.visibility='visible';}
    else{mxbaatchSize.style.visibility='hidden';}
    var localhost = doc.getElementById('calc_RunOnLocalhost');
    if(localhost.style.visibility=='hidden')
    {localhost.style.visibility='visible';}
    else{localhost.style.visibility='hidden';}
    var group = doc.getElementById('calc_Group');  
    if(group.style.visibility=='hidden') 
    {group.style.visibility='visible';}
    else{group.style.visibility='hidden';}
    var delay = doc.getElementById('calc_delay');
    if(delay.style.visibility=='hidden') 
    {delay.style.visibility='visible';}
    else{delay.style.visibility='hidden';}
    var timeout = doc.getElementById('calc_timeout');
    if(timeout.style.visibility=='hidden') 
    {timeout.style.visibility='visible';}
    else{timeout.style.visibility='hidden';}
    
}
function GGG(){
    var frame = findFrame(getTopWindow(),'detailsDisplay');
    var doc = frame.document;
    //if(doc.getElementById('calc_maxbatchsize').src=\"../common/images/utilSearchMinus.gif\"
}
//function to store extended credentials in session
//and return "" to server 
function getExtendedCreds()
{
 var myForm = document.forms[0];
 var topWin = getTopWindow().getWindowOpener().getTopWindow();
 topWin.sessionStorage.domainName  = myForm.DomainName.value;
 topWin.sessionStorage.windowsUser = myForm.WindowsUserName.value;
 topWin.sessionStorage.windowsPass = myForm.WindowsPassword.value;
 topWin.sessionStorage.linuxUser   = myForm.LinuxUserName.value;
 topWin.sessionStorage.linuxPass   = myForm.LinuxPassword.value;
 topWin.sessionStorage.isightV5User = myForm.IsightV5UserName.value;
 topWin.sessionStorage.isightV5Password = myForm.IsightV5Password.value;
  
 myForm.DomainName.value = "";
 myForm.WindowsUserName.value="";
 myForm.WindowsPassword.value="";
 myForm.LinuxUserName.value="";
 myForm.LinuxPassword.value="";
 myForm.IsightV5UserName.value="";
 myForm.IsightV5Password.value="";
 return true;
}

function getExtendedCredsFromSessionStorage()
{
 var myForm = document.forms[0];
 var topWin = getTopWindow().getWindowOpener().getTopWindow();
 
 if(topWin.sessionStorage.domainName != null)
 myForm.DomainName.value = topWin.sessionStorage.domainName;
 
 if(topWin.sessionStorage.windowsUser != null)
 myForm.WindowsUserName.value = topWin.sessionStorage.windowsUser;
 
 if(topWin.sessionStorage.windowsPass != null )
 myForm.WindowsPassword.value = topWin.sessionStorage.windowsPass;
 
 if(topWin.sessionStorage.linuxUser != null)
 myForm.LinuxUserName.value = topWin.sessionStorage.linuxUser;
 
 if(topWin.sessionStorage.linuxPass != null)
 myForm.LinuxPassword.value = topWin.sessionStorage.linuxPass;
 
 if(topWin.sessionStorage.isightV5User != null)
 myForm.IsightV5UserName.value = topWin.sessionStorage.isightV5User;
 
 if(topWin.sessionStorage.isightV5Password != null)
 myForm.IsightV5Password.value = topWin.sessionStorage.isightV5Password;
 
 return true;
}

 function smaOSCommandEditorTypeChangeHandler()
 {
     jQuery("input[name=Command]").val('');
     jQuery("input[name=ConnectorDisplay]").val('');
     smaOSCommandEditorTypeChangeHandlerWorker();
 }
 
 // load fields that are required initially!
 function preProcessJavaScriptOSCommandEditor()
 {
	 smaOSCommandEditorTypeChangeHandlerWorker();
 }
 
 // works to bring on change effects
 function smaOSCommandEditorTypeChangeHandlerWorker()
 {
	 var myForm = document.forms[0];
	 var optType = myForm.Type.value;
	 if("Command" === optType)
	 {
		 jQuery("input[name=btnConnector]").attr("disabled","disabled");
		 jQuery("input[name=ConnectorDisplay]").attr("disabled","disabled");
		 jQuery("input[name=Command]").removeAttr("disabled");
	 }
	 else if("Connector" === optType)
     {
		 jQuery("input[name=Command]").attr("disabled","disabled");
         jQuery("input[name=Command]").val('');
         jQuery("input[name=btnConnector]").removeAttr("disabled");
         jQuery("input[name=ConnectorDisplay]").removeAttr("disabled");
     }
 }

 //to remove the exporter
 function clearExporter(){
	 var myForm = document.forms[0];	 
     
     if(typeof(document.editDataForm.ExporterDisplay)!="undefined"){
     document.editDataForm.ExporterDisplay.value = "";
     document.editDataForm.Exporter.value = null;
     }
     else{
         document.editDataForm.ImporterDisplay.value = "";
         document.editDataForm.Importer.value = null;
     }
 }
 function clearWorkspaceFolder(widgetName)
 {
	  var formElement=eval ("document.forms[0]."+ widgetName);
	     if (formElement)
	             {
	               formElement.value="";
	             }
	     if (formElement.nextSibling)
	             {
	             formElement.nextSibling.value = "";
	             }
     
 }
//to remove the plm object
 function clearPLMObject(){
	 var myForm = document.forms[0];	 
     
     if(typeof(document.editDataForm.plmObjectDisplay)!="undefined"){
	     document.editDataForm.plmObjectDisplay.value = "";
	     document.editDataForm.plmObject.value = null;
     }
 }
 
 function smaOSCommandEncodingHandler(){
	jQuery("input[name=CommandfieldValue]")[0].value = (jQuery("input[name=Command]")[0].value).htmlEncode();
 }


</script>

