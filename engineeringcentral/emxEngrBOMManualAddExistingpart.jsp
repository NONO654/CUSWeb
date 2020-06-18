<%--  emxEngrBOMManualAddExistingParts.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "emxengchgValidationUtil.js" %>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
</head>

<script language="Javascript">

   function clearTxtField(fld) {
       eval("document.addParts."+fld+".value=''");
       disableTxtField(fld)
   }

   function enableTxtField(fld) {
       eval("document.addParts."+fld+".disabled=false");
   }

   function disableTxtField(fld) {
       eval("document.addParts."+fld+".disabled=true");
   }

   function next() {
      form = document.addParts;
       selCount=1;
       for(i=1;i<6;i++) {
               partName=eval('form.part'+i+'.value');
               if(trimWhitespace(partName)!="") {
                   if (partName.indexOf('?') > -1 || partName.indexOf('*') > -1) {
                       Str = "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.WildCardCharNotAllowed</emxUtil:i18nScript>" + "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.DifferentValueMessage</emxUtil:i18nScript>" ;
                       alert(Str);
                       eval('form.part'+i+'.focus()');
                       return;
                   }
                   rev0 =eval('form.revision'+i+'[0].checked');
                   rev1 =eval('form.revision'+i+'[1].checked');
                   rev2 =eval('form.revision'+i+'[2].checked');
                   if( rev0 || rev1 || rev2 ) {
                       if(rev0) {
                           if(trimWhitespace(eval('form.specificTxt'+i+'.value'))=="") {
                               alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.RevisionRequired</emxUtil:i18nScript>");
                               eval('form.specificTxt'+i+'.focus()');
                               return;
                           }
                       }
                   }
               } else {
                      ++selCount;
               }
       }  // end of for loop
       if(selCount==6) {
          alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.PartNameRequired</emxUtil:i18nScript>");
          eval('form.part1.focus()');
          return;
       }

       form.submit();
   }

   function checkSpecific(obj) {
       form = document.addParts;
       val = trim(obj.value);
       if(val != "")
       {
           index =  obj.name.length;
           index = obj.name.charAt(index-1);
           eval('form.revision'+index+'[0].checked=true');
       }
   }
</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<%
try{
  String strObjectId = emxGetParameter(request,"objectId");
  String languageStr = request.getHeader("Accept-Language");
  String jsTreeID = emxGetParameter(request,"jsTreeID");

  
  String uiType = emxGetParameter(request, "uiType");
  

  String sGeneralSearchPref ="";
  String allCheck ="";
  String defaultCheck ="";
  String localCheck ="";
  String selectedVaults ="";
  String selectedVaultsValue ="";

  String part1Specific ="";
  String part1HighestReleased ="";
  String part1Latest ="";
  String part2Specific ="";
  String part2HighestReleased ="";
  String part2Latest ="";
  String part3Specific ="";
  String part3HighestReleased ="";
  String part3Latest ="";
  String part4Specific ="";
  String part4HighestReleased ="";
  String part4Latest ="";
  String part5Specific ="";
  String part5HighestReleased ="";
  String part5Latest ="";

  String part1Revision = emxGetParameter(request, "part1Revision");
  String part2Revision = emxGetParameter(request, "part2Revision");
  String part3Revision = emxGetParameter(request, "part3Revision");
  String part4Revision = emxGetParameter(request, "part4Revision");
  String part5Revision = emxGetParameter(request, "part5Revision");

  if(part1Revision != null ) {
      if(part1Revision.equals("HighestReleased") ) {
          part1HighestReleased = "checked";
      } else if(part1Revision.equals("Latest") ) {
          part1Latest = "checked";
      } else {
          part1Specific ="checked";
      }
  } else {
      part1Specific ="checked";
      part1Revision = "";
  }

  if(part2Revision != null ) {
      if(part2Revision.equals("HighestReleased") ) {
          part2HighestReleased = "checked";
      } else if(part2Revision.equals("Latest") ) {
          part2Latest = "checked";
      } else {
          part2Specific ="checked";
      }
  } else {
      part2Specific ="checked";
      part2Revision = "";
  }

  if(part3Revision != null ) {
      if(part3Revision.equals("HighestReleased") ) {
          part3HighestReleased = "checked";
      } else if(part3Revision.equals("Latest") ) {
          part3Latest = "checked";
      } else {
          part3Specific ="checked";
      }
  } else {
      part3Specific ="checked";
      part3Revision = "";
  }

  if(part4Revision != null ) {
      if(part4Revision.equals("HighestReleased") ) {
          part4HighestReleased = "checked";
      } else if(part4Revision.equals("Latest") ) {
          part4Latest = "checked";
      } else {
          part4Specific ="checked";
      }
  } else {
      part4Specific ="checked";
      part4Revision = "";
  }

  if(part5Revision != null ) {
      if(part5Revision.equals("HighestReleased") ) {
          part5HighestReleased = "checked";
      } else if(part5Revision.equals("Latest") ) {
          part5Latest = "checked";
      } else {
          part5Specific ="checked";
      }
  } else {
      part5Specific ="checked";
      part5Revision = "";
  }

  String part1 = emxGetParameter(request,"part1");
  String part2 = emxGetParameter(request,"part2");
  String part3 = emxGetParameter(request,"part3");
  String part4 = emxGetParameter(request,"part4");
  String part5 = emxGetParameter(request,"part5");

  if(part1==null) {
      part1 = "";
  }
  if(part2==null) {
      part2 = "";
  }
  if(part3==null) {
      part3 = "";
  }
  if(part4==null) {
      part4 = "";
  }
  if(part5==null) {
      part5 = "";
  }

  String specificTxt1 = emxGetParameter(request,"specificTxt1");
  String specificTxt2 = emxGetParameter(request,"specificTxt2");
  String specificTxt3 = emxGetParameter(request,"specificTxt3");
  String specificTxt4 = emxGetParameter(request,"specificTxt4");
  String specificTxt5 = emxGetParameter(request,"specificTxt5");

  if(specificTxt1==null) {
      specificTxt1 = "";
  }
  if(specificTxt2==null) {
      specificTxt2 = "";
  }
  if(specificTxt3==null) {
      specificTxt3 = "";
  }
  if(specificTxt4==null) {
      specificTxt4 = "";
  }
  if(specificTxt5==null) {
      specificTxt5 = "";
  }

  try {
    sGeneralSearchPref = emxGetParameter(request,"vault");
    if(sGeneralSearchPref==null) {
        sGeneralSearchPref = PersonUtil.getSearchDefaultSelection(context);
    }
  } catch(Exception ex){
    throw ex;
  }

  // Check the User SearchVaultPreference Radio button
  if(sGeneralSearchPref.equals("ALL_VAULTS")) {
    allCheck="checked";
  } else if (sGeneralSearchPref.equals("LOCAL_VAULTS")){
    localCheck="checked";
  } else if (sGeneralSearchPref.equals("DEFAULT_VAULT") || sGeneralSearchPref.equals("")) {
    defaultCheck="checked";
  } else {
    selectedVaults="checked";
    com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
    selectedVaultsValue = person.getSearchDefaultVaults(context);

  }

//Multitenant
  /* String specific = i18nNow.getI18nString("emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Specific", "emxEngineeringCentralStringResource", languageStr);
  String HighestReleased = i18nNow.getI18nString("emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.HighestReleased", "emxEngineeringCentralStringResource", languageStr);
  String Latest = i18nNow.getI18nString("emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Latest", "emxEngineeringCentralStringResource", languageStr); */
  
  String specific = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Specific");
  String HighestReleased = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.HighestReleased");
  String Latest = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Latest");

 %>

<%@include file = "emxengchgJavaScript.js" %>


  <form name="addParts" method="post" action="emxEngrBOMManualAddExistingIntermediateProcess.jsp" target="pagehidden">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
  <table class="list" id="UITable" width="700" border="0" cellpadding="3" cellspacing="2">
    <tr>
      <th nowrap="nowrap"> <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Name</emxUtil:i18n></th>
      <th nowrap="nowrap"> <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Revision</emxUtil:i18n></th>
    </tr>

    <tr class="even">
      <td><input type="text" name="part1" value="<xss:encodeForHTMLAttribute><%=part1%></xss:encodeForHTMLAttribute>" /></td>
      <td>
      	<!-- XSSOK -->
         <input type="radio" <%=part1Specific%> name="revision1" value="specific" onClick="javascript:enableTxtField('specificTxt1');" />
        <!-- XSSOK -->
         <input type="text" name="specificTxt1" maxlength="3" size="4" onchange="checkSpecific(this)" value="<xss:encodeForHTMLAttribute><%=specificTxt1%></xss:encodeForHTMLAttribute>" /> &nbsp;<%=specific%>
         <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Separator</emxUtil:i18n>
		<!-- XSSOK -->
         <input type="radio" <%=part1HighestReleased%> name="revision1" value="HighestReleased" onClick="javascript:clearTxtField('specificTxt1');" /> &nbsp;<%=HighestReleased%>&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Separator</emxUtil:i18n>
		<!-- XSSOK -->
         <input type="radio" <%=part1Latest%> name="revision1" value="Latest" onClick="javascript:clearTxtField('specificTxt1');" /> &nbsp;<%=Latest%>&nbsp;
      </td>
    </tr>

    <tr class="odd">
      <td><input type="text" name="part2" value="<xss:encodeForHTMLAttribute><%=part2%></xss:encodeForHTMLAttribute>" /></td>
      <td>
      <!-- XSSOK -->
         <input type="radio" <%=part2Specific%> name="revision2" value="specific" onClick="javascript:enableTxtField('specificTxt2');" />
        <!-- XSSOK -->
         <input type="text" name="specificTxt2" maxlength="3" size="4" onchange="checkSpecific(this)" value="<xss:encodeForHTMLAttribute><%=specificTxt2%></xss:encodeForHTMLAttribute>" /> &nbsp;<%=specific%>
         <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Separator</emxUtil:i18n>
         <!-- XSSOK -->
         <input type="radio" <%=part2HighestReleased%> name="revision2" value="HighestReleased" onClick="javascript:clearTxtField('specificTxt2');" />  &nbsp;<%=HighestReleased%>&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Separator</emxUtil:i18n>
		<!-- XSSOK -->
         <input type="radio" <%=part2Latest%> name="revision2" value="Latest"  onClick="javascript:clearTxtField('specificTxt2');" />  &nbsp;<%=Latest%>&nbsp;
      </td>
    </tr>

    <tr class="even">
      <td><input type="text" name="part3" value="<xss:encodeForHTMLAttribute><%=part3%></xss:encodeForHTMLAttribute>" /></td>
      <td>
      <!-- XSSOK -->
         <input type="radio" <%=part3Specific%> name="revision3" value="specific" onClick="javascript:enableTxtField('specificTxt3');" />
        <!-- XSSOK -->
         <input type="text" name="specificTxt3" maxlength="3" size="4" onchange="checkSpecific(this)" value="<xss:encodeForHTMLAttribute><%=specificTxt3%></xss:encodeForHTMLAttribute>" /> &nbsp;<%=specific%>
         <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Separator</emxUtil:i18n>
         <!-- XSSOK -->
         <input type="radio" <%=part3HighestReleased%> name="revision3" value="HighestReleased" onClick="javascript:clearTxtField('specificTxt3');" />  &nbsp;<%=HighestReleased%>&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Separator</emxUtil:i18n>
		<!-- XSSOK -->
         <input type="radio" <%=part3Latest%> name="revision3" value="Latest" onClick="javascript:clearTxtField('specificTxt3');" /> &nbsp;<%=Latest%>&nbsp;
      </td>
    </tr>

    <tr class="odd">
      <td><input type="text" name="part4" value="<xss:encodeForHTMLAttribute><%=part4%></xss:encodeForHTMLAttribute>" /></td>
      <td>
      <!-- XSSOK -->
         <input type="radio" <%=part4Specific%> name="revision4" value="specific" onClick="javascript:enableTxtField('specificTxt4');" />
        <!-- XSSOK -->
         <input type="text" name="specificTxt4" maxlength="3" size="4" onchange="checkSpecific(this)" value="<xss:encodeForHTMLAttribute><%=specificTxt4%></xss:encodeForHTMLAttribute>" /> &nbsp;<%=specific%>
         <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Separator</emxUtil:i18n>
         <!-- XSSOK -->
         <input type="radio" <%=part4HighestReleased%> name="revision4" value="HighestReleased" onClick="javascript:clearTxtField('specificTxt4');" />  &nbsp;<%=HighestReleased%>&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Separator</emxUtil:i18n>
		<!-- XSSOK -->
         <input type="radio" <%=part4Latest%> name="revision4" value="Latest" onClick="javascript:clearTxtField('specificTxt4');" /> &nbsp;<%=Latest%>&nbsp;
      </td>
    </tr>

    <tr class="even">
      <td><input type="text" name="part5" value="<xss:encodeForHTMLAttribute><%=part5%></xss:encodeForHTMLAttribute>" /></td>
      <td>
      <!-- XSSOK -->
         <input type="radio" <%=part5Specific%> name="revision5" value="specific" onClick="javascript:enableTxtField('specificTxt5');" />
        <!-- XSSOK -->
         <input type="text" name="specificTxt5" maxlength="3" size="4" onchange="checkSpecific(this)" value="<xss:encodeForHTMLAttribute><%=specificTxt5%></xss:encodeForHTMLAttribute>" /> &nbsp;<%=specific%>
         <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Separator</emxUtil:i18n>
         <!-- XSSOK -->
         <input type="radio" <%=part5HighestReleased%> name="revision5" value="HighestReleased" onClick="javascript:clearTxtField('specificTxt5');" />  &nbsp;<%=HighestReleased%>&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMManualAddExisting.RevisionOption.Separator</emxUtil:i18n>
		<!-- XSSOK -->
         <input type="radio" <%=part5Latest%> name="revision5" value="Latest" onClick="javascript:clearTxtField('specificTxt5');" />  &nbsp;<%=Latest%>&nbsp;
      </td>
    </tr>

  </table> 
                 <input type="hidden"  value="DEFAULT_VAULT" name="vaultOption" />
				 <input type="hidden" name="uiType" value="<xss:encodeForHTMLAttribute><%=uiType%></xss:encodeForHTMLAttribute>" />


  <%
    String strFcs = emxGetParameter(request,"focus");
    if(strFcs!=null && !strFcs.equals("")) {
  %>
    <script language="Javascript">
    //XSSOK
      eval("document.addParts.<xss:encodeForJavaScript><%=strFcs%></xss:encodeForJavaScript>.focus()");
    </script>
  <%
    }
  %>

 </form>
  <%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%
}catch(Exception e) {
 }%>

