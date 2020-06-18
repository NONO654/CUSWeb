<%--  emxbomConsolidatedBOMDialog.jsp   -  Consolidated BOM Dialog
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>

<%@include file = "emxengchgJavaScript.js"%>

<%
  Part part = (Part)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  
  
  String maxShort    = Short.toString(Short.MAX_VALUE);
  
  String languageStr = request.getHeader("Accept-Language");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");

  part.setId(objectId);
  String objectName = part.getName(context);
  String objectType = part.getType(context);
  String objectRev = part.getInfo(context,DomainConstants.SELECT_REVISION); //IR-084087V6R2012
  String pageHeader = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Part.ConfigTableConsolidatedBOMSummary",request.getHeader("Accept-Language"));        
  String allString = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Part.WhereUsedLevelAll",request.getHeader("Accept-Language"));      
  //Multitenant
  //String levelStr       = i18nNow.getI18nString("emxEngineeringCentral.Common.Levels", "emxEngineeringCentralStringResource",languageStr);
  String levelStr       = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.Levels");
  

  
  //Fetched suiteKey value from the request-scope to pass to report page
  //required for Version 1 fix process.    
    String sSuiteKey = emxGetParameter(request,"suiteKey");
    String partType=part.getInfo(context ,DomainConstants.SELECT_TYPE);
    String partName=part.getInfo(context ,DomainConstants.SELECT_NAME);
    String partRev=part.getInfo(context ,DomainConstants.SELECT_REVISION);
    String typeIcon=EngineeringUtil.getDisplayPartIcon(context , partType);
    
  
  
  
%>

<script language="Javascript" >

  function updatelevel()
  {
    document.frmLevels.level.value="";
  }


  function alertLevelInput() {
    var field = document.frmLevels.allLevels;
    if(field.checked ==true) {
       field.focus();
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOM.AlreadyChosenAllLevel</emxUtil:i18nScript>");
      document.frmLevels.level.value="";
      return false;
    }
  }

var clicked = false;


function doneMethod()
{   

    if (clicked) {
    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
    return;
  }

    var levels = jsTrim(document.frmLevels.level.value)
    
    //if no level attribute value is specified,setting dft value to '-1'
    if(levels == "") {
       levels = "NOVAL";
    }   
   
    
    var alllevelsfield = document.frmLevels.allLevels;

     
     var pageHeadingFromResource = "emxEngineeringCentral.Part.ConfigTableConsolidatedBOMSummary";
     var pageHeading =  pageHeadingFromResource;
     //XSSOK 
     var subHeader = "<%=objectType%>" + "|";
     
     //if All Levels is checked,set level value as '0'
     if (alllevelsfield.checked == true) {
         levels = 0;
     }    
     
    
     if(levels == "NOVAL") {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOM.SelectEitherLevelOrCheckbox</emxUtil:i18nScript>");
        document.frmLevels.level.value = "";
          document.frmLevels.level.focus();
        return;
     }
     
      //perform below validation only if Level value is Non-zero
      //If Check All option selected we are assigning integral value 0
      if(levels != 0) {
        //Add new validation to check for Level unspecified is integer value in the range 0 to 32767
        //XSSOK 
        if(isNaN(levels) || (levels < 0 ) || (levels >= <%=maxShort%>) || charExists(levels,'.')) {
        	//XSSOK 
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOM.InvalidLevelRange</emxUtil:i18nScript>" + <%=maxShort%>);
            document.frmLevels.level.focus();
          return;
        }
      }
       
     
     
     
     if (levels == 0) {
        
         subHeader += "emxEngineeringCentral.Part.WhereUsedLevelAll";
          subHeader += "|"+"emxEngineeringCentral.Common.Levels";
     }

     else {
          subHeader += levels;
          
          subHeader += "|"+"emxEngineeringCentral.Common.Levels";
     }
        
        
        //modified url below by including suiteKey,CancelButton as argument Parameters
        var suiteKeyVal = "<xss:encodeForJavaScript><%=sSuiteKey%></xss:encodeForJavaScript>";//added for passing 'suiteKey' as param        
        var url = "../common/emxTable.jsp?program=emxPart:getConsolidatedEBOMs&objectId=<xss:encodeForURL><%=objectId%></xss:encodeForURL>&table=ENCConsolidatedBOMSummary&header="+pageHeading+"&sortColumnName=Name&repFormat=consolidatedFormat&PrinterFrinendly=true&sortDirection=ascending&slevels="+levels+"&HelpMarker=emxhelppartbomconsolidatedreport&subHeader="+subHeader+"&suiteKey="+suiteKeyVal+"&CancelButton=true&CancelLabel=emxEngineeringCentral.Common.Close";

        startProgressBar();
        clicked =true
// end
        url = fnEncode(url);
  parent.window.location.href = url;
}

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<script>
var nameHeading="<xss:encodeForJavaScript><%=partName%></xss:encodeForJavaScript>" +" <emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.Revision</emxUtil:i18nScript>" +"<xss:encodeForJavaScript><%= partRev%></xss:encodeForJavaScript>";
</script>

<form name="frmLevels" id ="frmLevels" method="post" action="">

<table border="0" cellpadding="5" cellspacing="2" width="100%">
<tr>
<td width="150" class="label"><label for="part"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Part</emxUtil:i18n></label></td>
<%-- <td class="inputField"><xss:encodeForHTML><%=objectName%></xss:encodeForHTML>&nbsp;<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.Revision</emxUtil:i18nScript>&nbsp;<xss:encodeForHTML><%=objectRev%></xss:encodeForHTML></td> --%>
<td class="field"><b><img src="../common/images/<%=typeIcon%>" border="0" />&nbsp;<script>document.write(nameHeading)</script></b></td>
</tr>

<tr>
<td width="150" class="labelRequired"><label for="Levels"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Levels</emxUtil:i18n></label></td>
<td class="inputField"><input type="text" name="level" id="" value="" onfocus="javascript:alertLevelInput()" />
</td>
</tr>


<tr>
   <td width="150" class="label">&nbsp;</td>
   <td class="inputField"><input type="checkbox" name="allLevels" value=""  checked onClick="javascript:updatelevel()" />
   <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.OrAllLevels</emxUtil:i18n>
<!--    <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.All</emxUtil:i18n>
   <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Levels</emxUtil:i18n> -->
   </td>

</tr>


</table>
<!--  &nbsp;
   <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" 
style="-moz-user-focus: none" /> -->
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
