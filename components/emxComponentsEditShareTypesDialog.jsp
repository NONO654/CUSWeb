<%--  emxComponentsEditShareTypes.jsp - The editing page for editing the Share Types attribute

      Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
      This program contains proprietary and trade secret information of MatrixOne, Inc.
      Copyright notice is precautionary only and does not evidence any actual or intended
      publication of such program

   static const char RCSID[] = $Id: emxComponentsEditShareTypesDialog.jsp.rca 1.8 Wed Oct 22 16:18:57 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>

<!-- content begins here -->
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String languageStr  = request.getHeader("Accept-Language");
  String objectId     = emxGetParameter(request,"objectId");
  String relId        = emxGetParameter(request,"relId");  
%>
<script language="Javascript">
function submitForm()
{
  // concatenating the selected checkbox values and sending it through the URL.
  var selShareTypes="";
  for (var i = 0; i<document.formShareTypeDialog.elements.length; i++)
  {
    if(document.formShareTypeDialog.elements[i].type == "checkbox" && document.formShareTypeDialog.elements[i].checked == true)
    {
      selShareTypes += document.formShareTypeDialog.elements[i].value+",";
    }
  }
  // removing the last comma from the string
  selShareTypes = selShareTypes.substring(0,selShareTypes.lastIndexOf(','));
  document.formShareTypeDialog.selectedShareTypes.value=selShareTypes;
  document.formShareTypeDialog.action="emxComponentsEditShareTypesDialogProcess.jsp";
  document.formShareTypeDialog.submit(); 
}
</script>

<%
  // getting the attribute name from the properties file.
  String strShareTypeSelect = DomainConstants.ATTRIBUTE_SHARE_TYPES;
  // getting the company name
  DomainObject company  = new DomainObject(objectId);
  String companyName    = company.getName(context);
  
  String shareTypes = "";
  boolean isShareTypesAvailable = false;
  
  shareTypes = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","ShareTypes");
  if (shareTypes == null)
  {
    shareTypes = "";
  }
  else if (!"".equals(shareTypes))
  {
    isShareTypesAvailable = true;
  }
  
  //to get the values of the attribute Share Types for the corresponding relationship
  String shareTypeAttributeValues = DomainRelationship.getAttributeString(context,relId,strShareTypeSelect);
  //Tokenizing the attribute share type values and putting it into String array.
  StringTokenizer stringtokenizerShareType = new StringTokenizer(shareTypeAttributeValues, ",");
  int tokenNumber=stringtokenizerShareType.countTokens();
  String shareTypevalues[]=new String[tokenNumber];
  for(int token=0;token<tokenNumber;token++)  
  {
    shareTypevalues[token]=stringtokenizerShareType.nextToken();
  } 
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="formShareTypeDialog" method="post" action="" target="_parent" onSubmit="submitForm(); return false;">
  <table border="0" cellspacing="2" cellpadding="3" width="100%" >
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></td>
      <td class="field"><%=XSSUtil.encodeForHTML(context, companyName)%></td>
    </tr>
    <tr><td>&nbsp;</td></tr>
<%
  String tokenValue="";
  String checkSelected="";
  
  // to check the checkboxes for the values which is already there in the Share Type attribute
  StringTokenizer stringtokenizer = new StringTokenizer(shareTypes, ",");
  while (stringtokenizer.hasMoreTokens())
  {    
        tokenValue=stringtokenizer.nextToken();
        checkSelected="";
        for(int uu=0;uu<shareTypevalues.length;uu++)
        {
          if(tokenValue.equals(shareTypevalues[uu]))
          {
            checkSelected="checked";
            break;//break the while loop
          }
        }
%>
    <tr>
      <td width="30%" class="label"><%=XSSUtil.encodeForHTML(context, i18nNow.getTypeI18NString(PropertyUtil.getSchemaProperty(context, tokenValue),languageStr))%></td>
      <!-- //XSSOK -->
      <td class="inputField"><input type="checkbox" <%=checkSelected%> name="selectedShareType" value="<%=tokenValue%>" /></td>
    </tr>    
<%
   }// end of while loop
   
   if(!isShareTypesAvailable)
   {
%>   
    <tr>
      <td colspan="2"><emxUtil:i18n localize="i18nId">emxComponents.EditShareTypes.NoShareTypes</emxUtil:i18n></td>
    </tr>
<%    
   }
%>
  </table>
  <input type="hidden" name="selectedShareTypes" />
  <input type="hidden" name="relId" value="<xss:encodeForHTMLAttribute><%=relId%></xss:encodeForHTMLAttribute>" />
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
