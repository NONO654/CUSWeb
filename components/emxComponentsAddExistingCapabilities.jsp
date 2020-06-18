<%-- emxComponentsAddExistingCapabilities.jsp - This page displays the Capability to be added

  Copyright (c) 1992-2018  Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsAddExistingCapabilities.jsp.rca 1.11 Wed Oct 22 16:18:44 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil" %>
<%@ include file = "../emxJSValidation.inc" %>

<script language = "javascript">

   // function to trim the value of the the text box.
  function trim (textBox) 
  {
     while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
     {
       textBox = textBox.substring(0,textBox.length - 1);
     }
     while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
     {
       textBox = textBox.substring(1,textBox.length);
     }
     return textBox;
  }
  
  // scripts performs checks and assigns the object Id of the Process object to be connected as value to hidden filed.
  // Sets the target page to adding new capabilities and performs submit action.

  function add() 
  {
    var flag = false; //moved this variable declaration from middle to beggining.
    if(document.Capability.elements.length > 2) // default two hidden variables are created
  {
    var sLeadTime     = trim(document.Capability.StandardLeadTimePrototype.value);
    var sLeadTimeProd = trim(document.Capability.StandardLeadTimeProd.value);
    var sLeadTimeTool = trim(document.Capability.StandardLeadTimeTooling.value);

    if ( !isNumeric(sLeadTime) || sLeadTime.indexOf("-") != -1 ) 
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxProfileManager.ProfileEditCapabilityDialog.ProtoTypeMessage</emxUtil:i18nScript>");
      document.Capability.StandardLeadTimePrototype.focus();
      return;
    } else if ( !isNumeric(sLeadTimeProd) || sLeadTimeProd.indexOf("-") != -1 ) {
       alert("<emxUtil:i18nScript localize="i18nId">emxProfileManager.ProfileEditCapabilityDialog.ProductionMessage</emxUtil:i18nScript>");
       document.Capability.StandardLeadTimeProd.focus();
       return;
    } else if ( !isNumeric(sLeadTimeTool) || sLeadTimeTool.indexOf("-") != -1 ) {
       alert("<emxUtil:i18nScript localize="i18nId">emxProfileManager.ProfileEditCapabilityDialog.ToolingMessage</emxUtil:i18nScript>");
       document.Capability.StandardLeadTimeTooling.focus();
       return;
    }
    
    document.Capability.StandardLeadTimePrototype.value = sLeadTime;
    document.Capability.StandardLeadTimeProd.value = sLeadTimeProd;
    document.Capability.StandardLeadTimeTooling.value = sLeadTimeTool;
    
    var badCharacters = checkForBadChars(document.Capability.Comments);
    if(badCharacters.length != 0)
    {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.InvalidChars</emxUtil:i18nScript>"+badCharacters+"<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.RemoveInvalidChars</emxUtil:i18nScript>"+" \""+"<emxUtil:i18nScript localize="i18nId">emxComponents.Capabilities.Comments</emxUtil:i18nScript>"+"\"");
        document.Capability.Comments.focus();
        return;
    }

     flag = false;
    for (var iProcess = 0; iProcess < document.Capability.elements.length; iProcess++) 
    {
      if ( (document.Capability.elements[iProcess].name == "process" ) &&
         (document.Capability.elements[iProcess].checked == true)) 
      {
        if (document.Capability.elements[iProcess].value == "TestingProcess") 
        {
          document.Capability.processId.value =  document.Capability.TestingProcess.options[document.Capability.TestingProcess.selectedIndex].value;
        } else if (document.Capability.elements[iProcess].value == "DesignProcess") 
        {
          document.Capability.processId.value = document.Capability.DesignProcess.options[document.Capability.DesignProcess.selectedIndex].value;
        } else if (document.Capability.elements[iProcess].value == "ManufacturingProcess") 
        {
          document.Capability.processId.value = document.Capability.ManufacturingProcess.options[document.Capability.ManufacturingProcess.selectedIndex].value;
        }
        flag = true;
        break;
      }
    }
  }
    if (flag == true) 
    {
      document.Capability.action = "emxComponentsAddCapabilityProcess.jsp";
      if(jsDblClick())
      {
	    document.Capability.submit();
	  }
      return;
    } else {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Capabilities.ProcessMessage</emxUtil:i18nScript>");
      return;
    }
   
  }

  //  Script markes the radio button as cheked when the corresponding  List is selected.
  function setFocus(selectBox) 
  {
    for (var iElements = 0 ; iElements < document.Capability.elements.length ; iElements++ ) 
    {
      if (document.Capability.elements[iElements].value == selectBox.name) 
      {
        document.Capability.elements[iElements].checked = true;
      }
    }
  }
  function closeWindow()
  {
    window.closeWindow();
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String strObjectId = emxGetParameter(request,"objectId");

  if (session.getValue("Error") != null) 
  {
%>
    <table border="0" cellspacing="0" cellpadding="0" width="100%">
      <tr><td>&nbsp;</td></tr>
      <tr>
		<!-- //XSSOK -->
        <td class="errorMessage"><%=session.getValue("Error")%></td>
      </tr>
      <tr><td>&nbsp;</td></tr>
    </table>
<%
    session.removeValue("Error");
  }

  // Declaration to store the Ogranization Buisness Object
  
  MapList mapListCap = new MapList();
  MapList mapListCapObj = new MapList();
  
  // Flag to control the display of buttons depend on the person role.
  String sRoleSupplierRepresentative = PropertyUtil.getSchemaProperty(context,"role_SupplierRepresentative");
  String sRoleBuyerAdmin             = PropertyUtil.getSchemaProperty(context,"role_BuyerAdministrator");

  String sRelCapability              = PropertyUtil.getSchemaProperty(context,"relationship_Capability");
  String sProcess                    = PropertyUtil.getSchemaProperty(context,"type_Process");
  String sTypeManufacturingProcess   = PropertyUtil.getSchemaProperty(context, "type_ManufacturingProcess");
  String sTypeTestingProcess         = PropertyUtil.getSchemaProperty(context, "type_TestingProcess");
  String sTypeDesignProcess          = PropertyUtil.getSchemaProperty(context, "type_DesignProcess");
  
  String sAttrQualificationStatus    = PropertyUtil.getSchemaProperty(context, "attribute_ProcessQualificationStatus");  
  String sAttrPrototypeCapability    = PropertyUtil.getSchemaProperty(context, "attribute_PrototypeCapability");

  String strLanguage = request.getHeader("Accept-Language");

  //get the where expression for the type 
  String whereExpression = FrameworkUtil.getWhereExpressionForMql(context,"",sProcess) ;
  
  // Query the database for  process.
  matrix.db.Query qryBOProcess       = new matrix.db.Query();
  qryBOProcess.setBusinessObjectType(sProcess);
  qryBOProcess.setBusinessObjectName("*");
  qryBOProcess.setBusinessObjectRevision("*");
  qryBOProcess.setOwnerPattern("*");
  qryBOProcess.setVaultPattern("*");
  qryBOProcess.setWhereExpression(whereExpression);
  qryBOProcess.setExpandType(true);

  StringList strListOnQuery = new StringList(3);
  strListOnQuery.addElement(DomainObject.SELECT_ID);
  strListOnQuery.addElement(DomainObject.SELECT_TYPE);
  strListOnQuery.addElement(DomainObject.SELECT_NAME);
  
  BusinessObjectWithSelectList busWithSelList = qryBOProcess.select(context,strListOnQuery);
  
  int listSize = 0;
  
%>
<form name  = "Capability" method = "post" action = "" onSubmit="add(); return false;">
<input type="hidden" name = "objectId" value = "<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name = "processId" value = "" />

<table cellspacing="2" cellpadding="3">
<%

  
  if(busWithSelList != null && (listSize = busWithSelList.size()) > 0)
  {
      // Get the id of the Organization from the request construct the Organization Business Object.
      BusinessObject boOrganization = new BusinessObject(strObjectId);
      StringList strListOnOrg = new StringList(1);
      strListOnOrg.addElement("from["+sRelCapability+"].to.id");
      
      BusinessObjectWithSelect busWithSelOrg = boOrganization.select(context,strListOnOrg);
      StringList strListOfProcessID = busWithSelOrg.getSelectDataList("from["+sRelCapability+"].to.id");
      if(strListOfProcessID == null)
      {
        strListOfProcessID = new StringList();
      }
  
      BusinessObjectWithSelect busWithSelProcess = null;
      String strID = "";
      String strType = "";
      String strName = "";
      boolean isProcessShown = false;
      boolean isProcessHeaderShown = false;
      MapList manuMapList = new MapList();
      MapList testMapList = new MapList();
      MapList desgMapList = new MapList();
      Map tempMap = null;
      
      for(int i = 0 ; i < listSize ; i++)
      {
        busWithSelProcess = busWithSelList.getElement(i);
        strID = busWithSelProcess.getSelectData(DomainObject.SELECT_ID);
        strType = busWithSelProcess.getSelectData(DomainObject.SELECT_TYPE);
        strName = busWithSelProcess.getSelectData(DomainObject.SELECT_NAME);
        if(strListOfProcessID.contains(strID))
        {
            continue;
        }
        
        if(strType.equals(sTypeManufacturingProcess))
        {
            tempMap = new HashMap();
            tempMap.put("ID",strID);
            tempMap.put("NAME",strName);
            manuMapList.add(tempMap);
        }
        else if(strType.equals(sTypeTestingProcess))
        {
            tempMap = new HashMap();
            tempMap.put("ID",strID);
            tempMap.put("NAME",strName);
            testMapList.add(tempMap);
        }
        else if(strType.equals(sTypeDesignProcess))
        {
            tempMap = new HashMap();
            tempMap.put("ID",strID);
            tempMap.put("NAME",strName);
            desgMapList.add(tempMap);
        }
        
      }
      int manuListSize = manuMapList.size();
      int testListSize = testMapList.size();
      int desgListSize = desgMapList.size();

      int rowspan = 0;
      if(manuListSize > 0)
      {
        rowspan++;
        isProcessShown = true;
      }
      if(testListSize > 0)
      {
        rowspan++;
        isProcessShown = true;
      }
      if(desgListSize > 0)
      {
        rowspan++;
        isProcessShown = true;
      }

      if(isProcessShown)
      {
%>
        <tr>
            <td class="labelRequired" rowspan="<%=rowspan%>" valign="top">
                <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.Process</emxUtil:i18n>
            </td>
<%
      }
      
      if(manuListSize > 0)
      {
        manuMapList.sort("NAME", "ascending", "string");
        if(isProcessHeaderShown)
        {
%>        
            <tr>
<%            
        }
        isProcessHeaderShown = true;
%>
            <td class="field">
                <input type="radio" name = "process" value = "ManufacturingProcess" />&nbsp;<emxUtil:i18n localize="i18nId">emxComponents.Capabilities.ManufacturingProcess</emxUtil:i18n>
                <select name = "ManufacturingProcess" onfocus = "setFocus(this)">
<%
                for(int i = 0 ; i < manuListSize ; i++)
                {
                    tempMap = (Map)manuMapList.get(i);
%>
                    <option value = "<xss:encodeForHTMLAttribute><%=tempMap.get("ID")%></xss:encodeForHTMLAttribute>" ><xss:encodeForHTML><%=tempMap.get("NAME")%></xss:encodeForHTML></option>
<%
                }
%>
                </select>
            </td>
         </tr>
<%
      }
      if(testListSize > 0)
      {
        testMapList.sort("NAME", "ascending", "string");
        if(isProcessHeaderShown)
        {
%>        
            <tr>
<%            
        }
        isProcessHeaderShown = true;
%>
            <td class="field">
                <input type="radio" name = "process" value = "TestingProcess" />&nbsp;<emxUtil:i18n localize="i18nId">emxComponents.Capabilities.TestingProcess</emxUtil:i18n>
                <select name = "TestingProcess" onfocus = "setFocus(this)">
<%
                for(int i = 0 ; i < testListSize ; i++)
                {
                    tempMap = (Map)testMapList.get(i);
%>
                    <option value = "<xss:encodeForHTMLAttribute><%=tempMap.get("ID")%></xss:encodeForHTMLAttribute>" ><xss:encodeForHTML><%=tempMap.get("NAME")%></xss:encodeForHTML></option>
<%
                }
%>             
                </select>
            </td>
         </tr>
<%
      }
      if(desgListSize > 0)
      {
        desgMapList.sort("NAME", "ascending", "string");
        if(isProcessHeaderShown)
        {
%>        
            <tr>
<%            
        }
        isProcessHeaderShown = true;
%>
            <td class="field">
                <input type="radio" name = "process" value = "DesignProcess" />&nbsp;<emxUtil:i18n localize="i18nId">emxComponents.Capabilities.DesignProcess</emxUtil:i18n>
                <select name = "DesignProcess" onfocus = "setFocus(this)">
<%
                for(int i = 0 ; i < desgListSize ; i++)
                {
                    tempMap = (Map)desgMapList.get(i);
%>
                    <option value = "<xss:encodeForHTMLAttribute><%=tempMap.get("ID")%></xss:encodeForHTMLAttribute>" ><xss:encodeForHTML><%=tempMap.get("NAME")%></xss:encodeForHTML></option>
<%
                }
%>               
                </select>
            </td>
         </tr>
<%
      }
      if(!isProcessShown)
      {
%>
        <tr>
          <td>
            &nbsp;<emxUtil:i18n localize="i18nId">emxComponents.Capabilities.NotMoreFound</emxUtil:i18n>
          </td>
        </tr>
<%
      }
      else
      {
%>
          </tr>
          <tr>
            <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Capabilities.CapabilityStatus</emxUtil:i18n></td>
            <td class="inputField">
               <input type="text" name="CapabilityStatus" value="" size="20" onFocus="select()" />
                &nbsp;
            </td>
          </tr>

          <tr>
            <td width="300" class="label">
              <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.ProcessQualificationStatus</emxUtil:i18n>
            </td>
            <td class="inputField">
                 <select name = "ProcessQualificationStatus">
<%
                 StringList sAttrQualStatus = mxAttr.getChoices(context, sAttrQualificationStatus);
                 MapList ml = AttributeUtil.sortAttributeRanges(context,sAttrQualificationStatus,sAttrQualStatus,strLanguage);
                 Iterator mlItr = ml.iterator();
                 while (mlItr.hasNext())
                 {
                    Map choiceMap = (Map) mlItr.next();
                    String choice = (String) choiceMap.get("choice");
                    String translation = (String) choiceMap.get("translation");
%>
                    <option  value ="<xss:encodeForHTML><%=choice%></xss:encodeForHTML>" ><xss:encodeForHTMLAttribute> <%=translation%></xss:encodeForHTMLAttribute></option>
<%
                 }
%>
                 </select>
            </td>
          </tr>

          <tr>
            <td class="label">
               <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.PrototypeCapability</emxUtil:i18n>
            </td>
            <td class="inputField">
                <select name = "PrototypeCapability">
<%
                StringList sAttrProtoCap = mxAttr.getChoices(context, sAttrPrototypeCapability);     
                MapList mAttrProtoCap = AttributeUtil.sortAttributeRanges(context,sAttrPrototypeCapability,sAttrProtoCap,request.getHeader("Accept-Language"));
                Iterator AttrProtoCapItr = mAttrProtoCap.iterator();
                while (AttrProtoCapItr.hasNext())
                {
                    Map choiceMap = (Map) AttrProtoCapItr.next();
                    String choice = (String) choiceMap.get("choice");
                    String translation = (String) choiceMap.get("translation");
%>
                    <option  value ="<xss:encodeForHTMLAttribute><%=choice%></xss:encodeForHTMLAttribute>" > <xss:encodeForHTML><%=translation%></xss:encodeForHTML></option>
<%
                }
%>
                </select>
            </td>
          </tr>

          <tr>
            <td class="label">
               <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.StandardLeadTimePrototype</emxUtil:i18n>
            </td>
            <td class="inputField">
               <input type="text" name = "StandardLeadTimePrototype" value = "" size = "20" onFocus="select()" />
            </td>
          </tr>

          <tr>
            <td class="label">
              <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.StandardLeadTimeProduction</emxUtil:i18n>
            </td>
            <td class="inputField">
              <input type= "text" name = "StandardLeadTimeProd" value = "" size = "20" onFocus="select()" />
            </td>
          </tr>

          <tr>
            <td class="label">
              <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.StandardLeadTimeTooling</emxUtil:i18n>
            </td>
            <td class="inputField">
              <input type="text" name = "StandardLeadTimeTooling" value = "" size = "20" onFocus="select()" />
            </td>
          </tr>

          <tr>
            <td class="label">
              <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.MaterialLimitation</emxUtil:i18n>
            </td>
            <td class="inputField">
                <input type="text" name = "MaterialLimitation" size = "20" value = "" onFocus="select()" />
            </td>
          </tr>

          <tr>
            <td class="label">
                <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.ShapeLimitation</emxUtil:i18n>
            </td>
            <td class="inputField">
                <input type="text" name="ShapeLimitation" size="20" value="" onFocus="select()" />
            </td>
          </tr>

          <tr>
            <td class="label">
               <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.SizeLimitation</emxUtil:i18n>
            </td>
            <td class="inputField">
               <input type="text" name="SizeLimitation" size="20" value="" onFocus="select()" />
            </td>
          </tr>

          <tr>
            <td class="label">
               <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.WeightLimitation</emxUtil:i18n>
            </td>
            <td class="inputField">
               <input type="text" name="WeightLimitation" size="20" value="" onFocus="select()" />
            </td>
          </tr>

          <tr>
            <td class="label" valign="top">
              <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.Comments</emxUtil:i18n>
            </td>
            <td class="inputField">
               <textarea rows="3" name="Comments" cols="30" wrap></textarea>
            </td>
          </tr>
<%
      }
  }
  else
  {
%>
    <tr>
      <td>
        &nbsp;<emxUtil:i18n localize="i18nId">emxComponents.Capabilities.NotFound</emxUtil:i18n>
      </td>
    </tr>
<%
  }
%>

</table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
