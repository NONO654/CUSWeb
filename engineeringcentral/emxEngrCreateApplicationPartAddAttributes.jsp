<%--  emxpartCreatePartAddAttributes.jsp   - Dialog page to add Attributes to Application Part
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxengchgJavaScript.js"%>
<%@ include file = "../emxJSValidation.inc" %>

<%!
public String setFormData(Map dataMap, String formName) {
        StringBuffer sb = new StringBuffer();
        HashMap map = null;
        Iterator itr = null;

          if ((map = (HashMap)dataMap) != null)
          {
               itr = map.keySet().iterator();
               sb.append("var form = document."+formName+";\n");

               while (itr.hasNext()) {
                   try
                   {
                        String name = (String)itr.next();
                        Object obj = map.get(name);
                        String values[] = null;
                        boolean isArray = obj.getClass().isArray();

                        if(isArray) {
                              values = (String[])obj;
                        } else {
                              values = new String[] {(String)obj};
                        }

                        for(int i=0; i<values.length; i++) {
                              String value = (String)values[i];

                              if (name.equals("Unit of Measure") || name.equals("Part Classification") || name.equals("Lead Time")|| name.equals("Service Make Buy Code")|| name.equals("Production Make Buy Code")|| name.equals("Material Category")) {
                                    sb.append("setComboValue(form,\""+name+"\",\""+value+"\");");
                                    sb.append("\n");
                              }

                              if (name.equals("Estimated Cost") || name.equals("Effectivity Date")|| name.equals("Target Cost")|| name.equals("Weight")) {
                                    sb.append("form.elements[\""+name+"\"].value=\""+value+"\";");
                                    sb.append("\n");
                              }
                              else if (name.startsWith("hid") || name.equals("Originator")) {
                                       sb.append("form.elements[\""+name+"\"].value=\""+value+"\";");
                                       sb.append("\n");
                              }
                              sb.append("\n");
                        }//end of for
                   }    catch(Exception e) {

                   }//end of try-catch()

               }//end of while
         }//end of if
        return sb.toString();
    }//end of function

%>
<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
</head>

<%
  // get the request attributes from previous screen

  String type           = DomainConstants.TYPE_APPLICATION_PART;

  String partNum        = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "partNum"));
  String rev            = emxGetParameter(request, "rev");

  String locName        = emxGetParameter(request, "locName");
  String locId          = emxGetParameter(request, "locId");

  String objectId  = emxGetParameter(request,"objectId");
  String assemblyPartId  = emxGetParameter(request,"assemblyPartId");
  String suiteKey = emxGetParameter(request, "suiteKey");
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String fromsummarypage = emxGetParameter(request, "fromsummaryPage");
  String SuiteDirectory = emxGetParameter(request,"SuiteDirectory");

  String languageStr  = request.getHeader("Accept-Language");
  String partLabel    = i18nNow.getTypeI18NString(type,languageStr) + " " + partNum + " " + rev;
  String prevmode     = "true";

  String attrWeight           = PropertyUtil.getSchemaProperty(context,"attribute_Weight");
  String attrTargetCost       = PropertyUtil.getSchemaProperty(context,"attribute_TargetCost");
  String attrEstimatedCost    = PropertyUtil.getSchemaProperty(context,"attribute_EstimatedCost");
  String attrOriginator       = PropertyUtil.getSchemaProperty(context,"attribute_Originator");
  String sProdMakeBuy         = PropertyUtil.getSchemaProperty(context,"attribute_ProductionMakeBuyCode");
  String sServiceMakeBuy      = PropertyUtil.getSchemaProperty(context,"attribute_ServiceMakeBuyCode");


  String typeIcon;
  String defaultTypeIcon = JSPUtil.getCentralProperty(application, session, "type_Default","SmallIcon");
  String alias           = FrameworkUtil.getAliasForAdmin(context, "type", type, true);

  if ( alias == null || alias.equals("")) {
    typeIcon = defaultTypeIcon;
  }
  else {
    typeIcon = JSPUtil.getCentralProperty(application, session, alias, "SmallIcon");
  }

  if(typeIcon == null) {
      typeIcon = defaultTypeIcon;
  }
%>

<script language="JavaScript">
var isDone = false;
  function goBack()
  {
      document.editForm.action="emxEngrCreateApplicationPartDialogFS.jsp";
      document.editForm.submit();
      return;
  }

  function goNext()
  {
      if(validateForm()) {
      document.editForm.action="emxEngrCreateApplicationSpecifyAssociateMEPFS.jsp";
      document.editForm.submit();
      return;
      }
  }

  function isEmpty(s)
  {
    return ((s == null)||(s.length == 0))
  }

  function isDigit(c)
  {
    return ((c >= "0") && (c <= "9"))
  }


  function validateForm()
  {
	//XSSOK
       var weight = document.editForm.elements["<%=attrWeight%>"];
  	//XSSOK
    var targetCost = document.editForm.elements["<%=attrTargetCost%>"];
    //XSSOK
    var estimateCost = document.editForm.elements["<%=attrEstimatedCost%>"];

    if (estimateCost != null) {
       estimateCost.value = jsTrim(estimateCost.value);

       if(!isNumeric(estimateCost.value) || (estimateCost.value).substr(0,1) == "-")
       {
          alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.EstimatedCostHasToBeGreaterThanZero</emxUtil:i18nScript>");
          estimateCost.focus();
          return false;
       }

    }

    if (weight != null) {
       weight.value = jsTrim(weight.value);
       if (!isNumeric(weight.value) || (weight.value).substr(0,1) == "-")
       {
           alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.WeightHasToBeGreaterThanZero</emxUtil:i18nScript>");
           weight.focus();
           return false;
       }

    }

    if (targetCost != null) {
        targetCost.value = jsTrim(targetCost.value);

        if (!isNumeric(targetCost.value) || (targetCost.value).substr(0,1) == "-")
        {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.TargetCostHasToBeGreaterThanZero</emxUtil:i18nScript>");
            targetCost.focus();
            return false;
        }
    }

    return true;
  }


  function setComboValue(form,name,valu)
  {
        var len = eval("form.elements['"+name+"'].length");
        for (Count = 0; Count < len; Count++)
        {
               var val = eval("form.elements['"+name+"'].options[Count].value");
               if(val == valu)
                     form.elements[name].selectedIndex = Count;
         }
   }

  function cancel()
  {
     parent.closeWindow();
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="editForm" method="post" action="emxEngrCreateApplicationSpecifyAssociateMEPFS.jsp" target="_parent">
<table border="0" cellpadding="5" cellspacing="2" width="100%">
  <tr>
    <td width="25%" class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Part</emxUtil:i18n></td>
    <!-- XSSOK -->
    <td class="inputField"><img src="../common/images/<%=typeIcon%>" border="0" />&nbsp;<%=partLabel%></td>
  </tr>

<%
      BusinessType partType = new BusinessType(type, new Vault(Person.getPerson(context).getVaultName(context)));
      partType.open(context,false);
      AttributeTypeList partAttrList = partType.getAttributeTypes(context) ;
      partType.close(context);

      //get attribute info
      Map attrMap = FrameworkUtil.toMap(context,partAttrList);
      session.setAttribute("attributeMap",attrMap);

      //retrieve and display all attributes
      java.util.Set keys = attrMap.keySet();
      Iterator itr = keys.iterator();

      while (itr.hasNext())
      {
         Map valueMap    = (Map)attrMap.get((String)itr.next());
         String attrName = (String)valueMap.get("name");
         if(attrOriginator.equals(attrName)){
%>
    <!-- XSSOK -->
     <input type="hidden" name="<%=attrName%>" value="<xss:encodeForHTMLAttribute><%=context.getUser()%></xss:encodeForHTMLAttribute>" />
<%
            continue;
         }
%>
  <tr>
  	<!-- XSSOK -->
    <td class="label" width="40%"><%=i18nNow.getAttributeI18NString(attrName,languageStr)%></td>
    <td class="inputField">
    <!-- XSSOK -->
        <%= EngineeringUtil.displayField(context,valueMap,"edit", languageStr, session,"") %>

    </td>
  </tr>
<%
      }//end of while
%>

</table>


<%
      HashMap map = null;
            if((map = (HashMap)session.getAttribute("attributesMap")) != null)
            {
%>
               <script>
               //XSSOK
                    <%out.println(setFormData(map,"editForm"));%>
               </script>
<%    }  %>

<input type="hidden" name="prevmode" value="<xss:encodeForHTMLAttribute><%=prevmode%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="assemblyPartId" value="<xss:encodeForHTMLAttribute><%=assemblyPartId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="fromsummarypage" value="<xss:encodeForHTMLAttribute><%=fromsummarypage%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=SuiteDirectory%></xss:encodeForHTMLAttribute>" />
</form>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
