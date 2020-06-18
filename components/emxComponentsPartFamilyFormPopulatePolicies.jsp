<%--  emxProductCentralFormPopulateTypePolicies.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

 --%>
<%@include file = "emxComponentsUtil.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%

  String selectedType  = emxGetParameter(request, "selectedType");
  String policyFieldName    = emxGetParameter(request, "policyFieldName");

  // get policies of selected type
  MapList typePolicies   = null;

  if(selectedType != null && !"".equalsIgnoreCase(selectedType) && !"null".equalsIgnoreCase(selectedType))
  {
    typePolicies = mxType.getPolicies(context, selectedType, false);
  }

  String policyList      = "";
  String policyListDisp  = "";
  String excludePolicy   = "";
  String languageStr = request.getHeader("Accept-Language");
  int counter = 1;

  if(typePolicies != null)
  {
    Iterator typePolicyItr = typePolicies.iterator();
    while(typePolicyItr.hasNext())
    {
      Map policyMap      = (Map) typePolicyItr.next();
      String policyName  = (String) policyMap.get("name");

      if (!com.matrixone.apps.common.PartFamily.getPolicyClassification(context, policyName).equals("Equivalent"))
      {
        if(counter == 1)
        {
          policyList += policyName;
          policyListDisp += i18nNow.getAdminI18NString("Policy", policyName, languageStr);
        } 
        else 
        {
          policyList += "|"+policyName;
          policyListDisp += "|"+i18nNow.getAdminI18NString("Policy", policyName, languageStr);
        }    
      }
      ++counter;
    }
  }
%>
<script language = "javascript">

  var frameObj = getTopWindow().getWindowOpener().findFrame(getTopWindow(), "formEditDisplay");
  var f = frameObj.document.forms[0];

  for( var i = 0; i < f.elements.length; i++ ) 
  {
    if(f.elements[i].name == '<%=XSSUtil.encodeForJavaScript(context, policyFieldName)%>')
    {
        formfield = f.elements[i];
    }
  }
  var selectedPolicy = formfield.value;
  var formfieldOptsLen = formfield.options.length;

  for(var i = formfieldOptsLen - 1; i>-1; i--)
  {
    formfield.options[i] = null;        
  }

  var policyString     = "<%=XSSUtil.encodeForJavaScript(context, policyList)%>";    
  var policyDispString = "<%=XSSUtil.encodeForJavaScript(context, policyListDisp)%>";
  var policyArray      = policyString.split('|');
  var policyDispArray  = policyDispString.split('|');
  var arrOptionsLen = policyArray.length;

  for(var i = 0; i < arrOptionsLen; i++)
  {
    var optValue = new Option(policyDispArray[i],policyArray[i]);
    formfield.options.add(optValue);
    if(selectedPolicy == policyArray[i])
    {
      formfield.options[i].selected = true;
    }
  }

</script>

