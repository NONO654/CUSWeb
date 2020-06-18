<%--  emxpartECRAttributesDialog.jsp   -
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

<%
  ECR ecrId = (ECR)DomainObject.newInstance(context,
                    DomainConstants.TYPE_ECR,DomainConstants.ENGINEERING);

  String sContextMode         ="";
  String sECRType             = "";
  String sProductLineId       = "";
  String selVault             = "";
  String selPolicy            = "";
  String sDescription         = "";
  String sDescriptionOfChange = "";
  String sReasonForChange     = "";
  String prevmode   ="true";

  sContextMode        = emxGetParameter(request, "sContextMode");

  if ("true".equals(sContextMode)){

    sECRType              = emxGetParameter(request,"textECRType");
    sProductLineId        = emxGetParameter(request,"hidProductLineId");
    selVault              = emxGetParameter(request,"selVault");
    selPolicy             = emxGetParameter(request,"selPolicy");
    sDescription          = emxGetParameter(request,"description");
  }

%>

<script language="Javascript">

  function goBack()
    {
       document.relattrFrm.action="emxengchgCreateECRDialogFS.jsp";
       document.relattrFrm.submit();
       return;
    }


  function submit() {
      if (jsDblClick()) {
        var sFieldName = "|";
        var sAttributeArray = "|";

        var count = document.relattrFrm.count.value;
        for(var i=1;i<=count;i++)
        {
          var strFieldName = "document.relattrFrm.FieldName" + i + ".value";
          sFieldName += eval(strFieldName) + '|';

          var strAttrArrayName = "document.relattrFrm.attributeArray" + i;
          if(eval(strAttrArrayName).type == "select-one")
          {
            var argSelect = eval("document.relattrFrm.attributeArray" + i);
            var strAttrArrayValue = argSelect.options[argSelect.selectedIndex].value;
            sAttributeArray += " " + strAttrArrayValue + " " + '|';
          }
          else
          {
            sAttributeArray += " " + eval(strAttrArrayName + ".value") + " " + '|';
          }
        }

        document.relattrFrm.FieldName.value = sFieldName;
        document.relattrFrm.attributeArray.value = sAttributeArray;
        document.relattrFrm.submit();
        return;
      } else {
          alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ObjectCreation.InProcess</emxUtil:i18nScript>");
      }
  }

</script>
<%


  String targetPage = "";
  if ("true".equals(sContextMode)){
     targetPage = "emxengchgCreateECR.jsp";
   }else{
     targetPage = "emxpartECRProcessConnect.jsp";
   }

  String languageStr = request.getHeader("Accept-Language");
  String suiteKey = emxGetParameter(request, "suiteKey");

  String objectId = emxGetParameter(request,"objectId");
  String[] selectedTypes = (String[]) session.getAttribute("selectedType");
  session.removeAttribute("selectedType");
  String sName = emxGetParameter(request,"Name");
  sName = (((sName == null) || (sName.equalsIgnoreCase("null"))) ? "*" : sName.trim().equals("") ? "*" : sName.trim());
  String sRev = emxGetParameter(request,"Rev");

  String sSelected = "Selected";
  String sVault = JSPUtil.getVault(context, session);
  Vault vault = new Vault(sVault);

%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "emxEngrStartReadTransaction.inc"%>

<!--XSSOK-->
    <form name="relattrFrm" method="post" action="<%=targetPage%>" target="_parent" onSubmit="javascript:submit(); return false">
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Name" value="<xss:encodeForHTMLAttribute><%=sName%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Rev" value="<xss:encodeForHTMLAttribute><%=sRev%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="FieldName" value="" />
      <input type="hidden" name="attributeArray" value="" />

      <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <tr>

<%
try
{
    // Get relationships available between
    // From type = ECR
    // To type = the type passed
    Vector vRelTypes = ecrId.getRelTypes(context,ecrId.TYPE_PART,sVault);

    // Create a list of attributes to be displayed. If the source page is conn data page then create a
    // Attribute list with the attributes from the passed relationship Id
    // or else
    // choose the first relationship type as the default relationship type and create an Attribute List with
    // the attributes with default values for the default selected relationship type
    // since we cannot create an attribute list as the attributes do not exist create an attributetypelist

    String sSelRelType = null;

    int count = 0;
    String sFieldName = "";
    String sAttributeArray = "";
    String key;
    String attrName;
    String attrDataType;

   // int iSize = vRelTypes.size();
  //  for(int i = 0 ; i < iSize ; i++)
   // {
     //   if (((RelationshipType)vRelTypes.elementAt(i)).getName().equals(DomainConstants.RELATIONSHIP_REQUEST_PART_REVISION))
      //  {
       //     sSelRelType = DomainConstants.RELATIONSHIP_REQUEST_PART_REVISION;
       //     break;
      //  }
   // }

    //if(sSelRelType == null)
   // {
    //    sSelRelType = ((RelationshipType)vRelTypes.elementAt(0)).getName();
    //}
    DomainObject obj1 = new DomainObject(objectId);
    String sECRPolicyName = obj1.getInfo(context, DomainObject.SELECT_POLICY);
    String strRelAffectedItem = PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem");
// Added for Bug 343966 starts
		//if("policy_ECR".equalsIgnoreCase(sECRPolicyName))
	//{
		sSelRelType = strRelAffectedItem;
		vRelTypes = new Vector();
		vRelTypes.add(new RelationshipType(strRelAffectedItem));

	//}
	// Added for Bug 343966 Ends

    Map attrMap = DomainRelationship.getAttributeTypeMapFromRelType(context,sSelRelType);
    Iterator itr = attrMap.keySet().iterator();
    String attrWhereUsedCompRef = PropertyUtil.getSchemaProperty(context, "attribute_WhereUsedComponentReference");

    while(itr.hasNext())
    {

      key = (String) itr.next();
      Map mapinfo = (Map) attrMap.get(key);
      attrName = (String)mapinfo.get("name");
      if(!attrName.equals(attrWhereUsedCompRef))
      {
      count++;

%>
        </tr><tr>
        <!-- XSSOK -->
        <td class="label"><%=i18nNow.getAttributeI18NString(attrName,languageStr)%></td>
        <td class="inputField">
<%
        //check to see if we need to display a list box or a text area or a text box
        //if the datatype is string and has Choices is true the show a list box
        //else if the attribute is multiline then show a text area
        //else show a text box

        attrDataType = (String) mapinfo.get("type");
        sFieldName = "FieldName" + count;
        sAttributeArray = "attributeArray" + count;

%>
        <input type="hidden" name="<%=sFieldName%>" value="<xss:encodeForHTMLAttribute><%=attrName%></xss:encodeForHTMLAttribute>" />
<%
        StringList attrOptions = (StringList) mapinfo.get("choices");
        if(attrDataType.equalsIgnoreCase("string") && attrOptions != null)
        {
          StringItr sChoicesItr = new StringItr(attrOptions);
%>
          <select name=<xss:encodeForHTMLAttribute><%=sAttributeArray%></xss:encodeForHTMLAttribute>>
<%
          String sDefault = (String) mapinfo.get("value");
          while(sChoicesItr.next())
          {
            String sChoice = sChoicesItr.obj();


            if(sChoice.equals(sDefault))
            {
%>
				<!-- XSSOK -->
              <option VALUE="<%=sChoice%>" <%=sSelected%>><%=i18nNow.getRangeI18NString(attrName,(sChoice).trim(), languageStr)%></option>
<%
            }
            else
            {
%>
				<!-- XSSOK -->
              <option VALUE="<%=sChoice%>"><%=i18nNow.getRangeI18NString(attrName,(sChoice).trim(), languageStr)%></option>
<%
            }
          }
%>
          </select>
<%
        }

        // Since we cannot determine isMultiline() from attribute type we display everything as textarea
        else
        {
%>
          <textarea name=<xss:encodeForHTMLAttribute><%=sAttributeArray%></xss:encodeForHTMLAttribute> style="font-size: 8pt; color:black" rows="3" cols="40"  wrap="soft"><xss:encodeForHTML><%=mapinfo.get("value")%></xss:encodeForHTML></textarea>
<%
        }
%>
        </td>
<%
      } else {
%>
        </tr><tr>
        <!-- XSSOK -->
        <td class="label"><%=i18nNow.getAttributeI18NString(attrName,languageStr)%></td>
        <td class="inputField">&nbsp;</td>
<%

      }
      }

%>
      <input type="hidden" name="count" value="<xss:encodeForHTMLAttribute><%=count%></xss:encodeForHTMLAttribute>" />
      </tr>
<%
    // if the source page is connected data then selected the select the passes relationship id as selected
    // relationship and display the specific attributes or else select the first relationship as default
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Relationship</emxUtil:i18n></td>
      <td class="inputField">
        <select name = "ChangeType" >
<%
      Enumeration enumRels = vRelTypes.elements();
      for(int i=0; i<vRelTypes.size(); i++)
      {
        RelationshipType relType = (RelationshipType) enumRels.nextElement();
        relType.open(context);
        String sRelType = relType.getName();
        if(sRelType.equals(sSelRelType))
      {
%>
	<!-- XSSOK -->
      <option selected value="<%=sRelType%>"><%=i18nNow.getAdminI18NString("Relationship",sRelType,languageStr)%></option>

<%
      }
      else
      {
%>
		<!-- XSSOK -->
          <option value="<%=sRelType%>"><%=i18nNow.getAdminI18NString("Relationship",sRelType,languageStr)%></option>
<%
      }
        relType.close(context);
      }
%>
        </select>
      </td>
    </tr>
    </table>
<%
  if ("true".equals(sContextMode))
  {
%>
    <input type="hidden" name="hidProductLineId" value="<xss:encodeForHTMLAttribute><%=sProductLineId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="textECRType" value="<xss:encodeForHTMLAttribute><%=sECRType%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="selVault" value="<xss:encodeForHTMLAttribute><%=selVault%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="selPolicy" value="<xss:encodeForHTMLAttribute><%=selPolicy%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="description" value="<xss:encodeForHTMLAttribute><%=sDescription%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="sContextMode" value="<xss:encodeForHTMLAttribute><%=sContextMode%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="prevmode" value="<xss:encodeForHTMLAttribute><%=prevmode%></xss:encodeForHTMLAttribute>" />

<%
  }
  else
  {
     for (int i=0; i<selectedTypes.length;i++)
     {
%>
        <input type="hidden" name="selectedType" value="<xss:encodeForHTMLAttribute><%=selectedTypes[i]%></xss:encodeForHTMLAttribute>" />
<%
     }
  }

  }
   catch(Exception e)
        {
  %>
          <%@include file = "emxEngrAbortTransaction.inc"%>
  <%
          throw e;
      }
%>
    <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
        <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" 
style="-moz-user-focus: none" />

</form>
<%@include file = "emxEngrCommitTransaction.inc"%>
<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
