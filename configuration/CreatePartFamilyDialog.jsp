<%--  emxProductCentralCreatePartFamilyDialog.jsp   - The Dailog page for creating a new Part Family

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "GlobalSettingInclude.inc"%>

<%@page import  = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import  = "com.matrixone.apps.domain.DomainObject"%>
<%@page import  = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import  = "com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import  = "com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import  = "com.matrixone.apps.domain.util.mxType"%>

<%
  String suiteKey                       = emxGetParameter(request, "suiteKey");
  String languageStr                    = request.getHeader("Accept-Language");
  String sSelectedType                  = emxGetParameter(request,"SelectedType");
  String strObjectId                    = emxGetParameter(request,"objectId");

  String sTypeName                    = "";
  String sObjName                     = "";
  String sDescr                       = "";
  String sVaultName                   = "";
  String sSeparator                   = "";
  String sGenerator                   = "";
  String sdefaultPartTypeActual       = "";
  String sdefaultPartPolicyActual     = "";
  String strAttributeNames            = "";

  Properties createPartFamilyProp = (Properties) session.getAttribute("createPartFamilyProp_KEY");
  if(createPartFamilyProp != null )
  {
    sTypeName       = createPartFamilyProp.getProperty("typeName_KEY");
    sObjName        = createPartFamilyProp.getProperty("objName_KEY");
    sDescr        = createPartFamilyProp.getProperty("descr_KEY");
    sVaultName            = createPartFamilyProp.getProperty("vaultName_KEY");
    sSeparator          = createPartFamilyProp.getProperty("separator_KEY");
    sGenerator            = createPartFamilyProp.getProperty("generator_KEY");
    sdefaultPartTypeActual    = createPartFamilyProp.getProperty("defaultPartTypeActual_KEY");
    sdefaultPartPolicyActual  = createPartFamilyProp.getProperty("defaultPartPolicyActual_KEY");
    strAttributeNames           = createPartFamilyProp.getProperty("attributeNames_KEY");

    session.removeAttribute("createPartFamilyProp_KEY");
  }

  if(sTypeName != null && !"null".equals(sTypeName) && !"".equals(sTypeName))
  {
    sSelectedType = sTypeName;
  }

  String attrPartFamilyNameGeneratorOn  = DomainObject.ATTRIBUTE_PART_FAMILY_NAME_GENERATOR_ON;
  String strPartFamilyName              = emxGetParameter(request,"partFamilyName");
  String strDescription                 = emxGetParameter(request,"Description");
  String strCheckbox                    = emxGetParameter(request,DomainObject.ATTRIBUTE_PART_FAMILY_NAME_GENERATOR_ON);
  String selectedVault                  = emxGetParameter(request,"Vault");
  String strAttrCommon                  = "";
  String sPageRefresh = emxGetParameter(request,"pageRefresh");
  if(sVaultName != null && !"null".equals(sVaultName) && !"".equals(sVaultName))
  {
    selectedVault = sVaultName;
  }

  if(sSelectedType == null || "".equals(sSelectedType) || "null".equals(sSelectedType))
  {
    sSelectedType = ProductLineConstants.TYPE_PARTFAMILY;
  }

  //Part Type Selection
  String sSelectedPartType  = emxGetParameter(request,"defaultPartTypeActual");
  String sSelectedPartPolicy  = emxGetParameter(request,"defaultPartPolicyActual");

  if (sdefaultPartTypeActual != null && !(sdefaultPartTypeActual.equalsIgnoreCase("null")) && !(sdefaultPartTypeActual.equals("")))
  {
    sSelectedPartType = sdefaultPartTypeActual;
  }
  if (sdefaultPartPolicyActual != null && !(sdefaultPartPolicyActual.equalsIgnoreCase("null")) && !(sdefaultPartPolicyActual.equals("")))
  {
    sSelectedPartPolicy = sdefaultPartPolicyActual;
  }

  if (sSelectedPartType == null || "".equals(sSelectedPartType))
  {
    AttributeType attrType = new AttributeType(ProductLineConstants.ATTRIBUTE_DEFAULT_PART_TYPE);
    attrType.open(context);
    sSelectedPartType = attrType.getDefaultValue();
    attrType.close(context);
  }

  if (sSelectedPartPolicy == null || "".equals(sSelectedPartPolicy))
  {
    AttributeType attrType = new AttributeType(ProductLineConstants.ATTRIBUTE_DEFAULT_PART_POLICY);
    attrType.open(context);
    sSelectedPartPolicy = attrType.getDefaultValue();
    sSelectedPartPolicy = PropertyUtil.getSchemaProperty(context,sSelectedPartPolicy);
    attrType.close(context);
  }

  String ptype = PropertyUtil.getSchemaProperty(context,sSelectedPartType);
  if (ptype != null && !"".equals(ptype))
  {
   sSelectedPartType = ptype;
  }

%>


<script language="JavaScript">
  var seltype="Part Family";

  function reload() {
    if (seltype == "Part Family"){
      varType = document.createPartFamily.partFamilyType.value;
      varPartType ="";
    }else{
      varType = document.createPartFamily.partFamilyType.value;
      varPartType = document.createPartFamily.defaultPartTypeActual.value;
    }
    var url = "../configuration/CreatePartFamilyDialog.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&PRCFSParam1=&contentPageIsDialog=true&showWarning=true&defaultPartTypeActual=" + varPartType + "&SelectedType=" + varType + "&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>";
    document.createPartFamily.action= fnEncode(url);
    document.createPartFamily.submit();
  }

  function checkInput()
  {
    var separatorValue = "";
    var objArray = document.createPartFamily.elements;
    //Begin of Modify by Vibhu,Infosys for Bug 311827 on 11/10/2005
    var separatorField;
    for(var i = 0; i < document.createPartFamily.elements.length; i++)
    {
        if("<%=DomainObject.ATTRIBUTE_PART_FAMILY_PATTERN_SEPARATOR%>" == objArray[i].name)
        {
           separatorValue = objArray[i].value;
           //separatorField = objArray[i];
        }
    }

    var vaultValue = document.createPartFamily.Vault.value;
    //IR-080022V6R2012 - Invoking checkForNameBadChars by passing in the field value instead of the field
    //var separatorCheckValue = checkForNameBadChars(separatorField,true);
    var separatorCheckValue = checkForNameBadChars(separatorValue,false);
    var nameValue= document.createPartFamily.partFamilyName.value;
    if (nameValue == "") {
       alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkEmptyString</emxUtil:i18nScript>");
       document.createPartFamily.partFamilyName.focus();
       return;
    }
    var namebadCharName = checkForNameBadChars(document.createPartFamily.partFamilyName,true);
    if (namebadCharName.length != 0){
      alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.InvalidChars</emxUtil:i18nScript>"+namebadCharName);
      document.createPartFamily.partFamilyName.focus();
      return;
    }

    if (document.createPartFamily.partFamilyType.value == "") {
       alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkEmptyString</emxUtil:i18nScript>");
       document.createPartFamily.typeButton.focus();
       return;
    }
    //IR-080022V6R2012 - BEGIN
    //else if (separatorCheckValue.length != 0) {
    //   alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.InvalidChars</emxUtil:i18nScript>"+separatorCheckValue);
    //   separatorField.focus();
    //   return;
    //}
    else if (separatorCheckValue == false) {
        alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.PartFamily.InvalidSeparator</emxUtil:i18nScript>");
        document.getElementsByName("Part Family Pattern Separator")[0].focus();
       return;
    }
    //IR-080022V6R2012 :END 
    else if(vaultValue==null || vaultValue=="")
    {
       alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkEmptyString</emxUtil:i18nScript>");
       return;
    }
    //End of Modify by Vibhu,Infosys for Bug 311827 on 11/10/2005
    else
    {
       document.createPartFamily.action="CreatePartFamily.jsp";
       document.createPartFamily.submit();
    }
  }

  function closeThis()
  {
    parent.window.closeWindow();
  }
  var bAbstractSelect = false;
  var bReload = false;

  function showTypeSelector() {
    var strURL="../common/emxTypeChooser.jsp?fieldNameActual=partFamilyType&fieldNameDisplay=partFamilyTypeDisp&formName=createPartFamily&ShowIcons=true&InclusionList=<%=XSSUtil.encodeForURL(ProductLineConstants.TYPE_PARTFAMILY)%>&ObserveHidden=false&SelectAbstractTypes="+bAbstractSelect+"&ReloadOpener="+bReload;
    showModalDialog(strURL, 450, 350);
  }

  function showPartTypeSelector() {
    seltype="Part";
    var strURL="../common/emxTypeChooser.jsp?fieldNameActual=defaultPartTypeActual&fieldNameDisplay=defaultPartTypeDisplay&formName=createPartFamily&ShowIcons=true&InclusionList=<%=XSSUtil.encodeForURL("type_Part")%>&ObserveHidden=false&SelectAbstractTypes="+bAbstractSelect+"&ReloadOpener="+bReload;
    showModalDialog(strURL, 450, 350);
  }

  // Replace vault dropdown box with vault chooser.
  var txtVault = null;
  var bVaultMultiSelect = false;
  var strTxtVault = "document.forms['createPartFamily'].Vault";

  function showVaultSelector()
  {
    txtVault = eval(strTxtVault);
    showChooser('../common/emxVaultChooser.jsp?fieldNameActual=Vault&fieldNameDisplay=VaultDisp&incCollPartners=false&multiSelect=false');
  }


</script>

<%
  // ----------------------- Header End Include Here -----------------------
  if(strPartFamilyName == null || "null".equals(strPartFamilyName))
  {
    strPartFamilyName = "";
  }
  if (sObjName != null && !"null".equals(sObjName) && !"".equals(sObjName))
  {
    strPartFamilyName =  sObjName;
  }
  if(strDescription == null || "null".equals(strDescription))
  {
    strDescription = "";
  }
  if(sDescr != null && !"null".equals(sDescr) && !"".equals(sDescr))
  {
    strDescription = sDescr;
  }
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="createPartFamily" method="post" action="" onsubmit="javascript:checkInput(); return false">
<%@include file = "../common/enoviaCSRFTokenInjection.inc" %>

<input type="hidden" name="partFamilyType" value="<xss:encodeForHTMLAttribute><%=sSelectedType%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="pageRefresh" value="true" />

<table width="100%" border="0" cellspacing="2" cellpadding="5">

  <tr>
    <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Name</emxUtil:i18n> </td>
    <td class="inputField"><input type="text" name="partFamilyName" value="<xss:encodeForHTMLAttribute><%= strPartFamilyName %></xss:encodeForHTMLAttribute>" /></td>
  </tr>

  <tr>
    <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Type</emxUtil:i18n></td>
    <td class="inputField">
      <input type="text" name="partFamilyTypeDisp" size="30" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=i18nNow.getTypeI18NString(sSelectedType,languageStr)%></xss:encodeForHTMLAttribute>">&nbsp;<input class="button" type="button" name="typeButton" size = "200" value="..."  onClick="javascript:showTypeSelector();" />
    </td>
  </tr>

  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Description</emxUtil:i18n> </td>
    <td class="field"><textarea wrap="soft" name="Description" value="" rows="5" cols="30" value=""><xss:encodeForHTML><%=strDescription%></xss:encodeForHTML></textarea> </td>
  </tr>

<%

  BusinessType partType = new BusinessType(sSelectedType, new Vault(com.matrixone.apps.common.Person.getPerson(context).getVaultName(context)));
  partType.open(context,false);
  AttributeTypeList partAttrList = partType.getAttributeTypes(context) ;
  partType.close(context);
  //get attribute info
  Map attrMap = FrameworkUtil.toMap( context,partAttrList);

  StringBuffer attributeNames = new StringBuffer(DomainObject.ATTRIBUTE_PART_FAMILY_NAME_GENERATOR_ON);

  //retrieve and display all attributes
  Iterator itr = attrMap.keySet().iterator();
  String attrValue = "";
  while (itr.hasNext())
  {
       Map valueMap    = (Map)attrMap.get((String)itr.next());

       String attrName = (String)valueMap.get("name");

       // Added by Infosys for Bug # 318081 Date Apr 10, 2006
       String strAttrNameSymb = FrameworkUtil.getAliasForAdmin(context, "attribute", attrName, true);

       if(createPartFamilyProp!=null)
         attrValue           = createPartFamilyProp.getProperty(attrName);

       if (attrName.equals(DomainObject.ATTRIBUTE_PART_FAMILY_NAME_GENERATOR_ON))
       {
%>
  <tr>
    <td class="label"><%=EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Attribute."+strAttrNameSymb,languageStr)%></td>
<%
         strAttrCommon = emxGetParameter(request,attrName);
         String attrCheck = "";
         if(createPartFamilyProp!=null)
         {
           attrCheck           = createPartFamilyProp.getProperty(attrName);
           if (attrCheck != null && ("FALSE".equalsIgnoreCase(attrCheck)))
           {
             strAttrCommon = null;
             sPageRefresh = "TRUE";
           }
         }

         if(sPageRefresh == null)
         {
           strAttrCommon = (String)valueMap.get("value");
         }

         String selected = "";
         if(strAttrCommon != null && ("TRUE".equalsIgnoreCase(strAttrCommon) || "on".equalsIgnoreCase(strAttrCommon)))
         {
           selected = "checked";
         }

%>
            <td class="field"><input type="checkBox" name="<%=DomainObject.ATTRIBUTE_PART_FAMILY_NAME_GENERATOR_ON%>" value="TRUE" <%=XSSUtil.encodeForHTMLAttribute(context,selected)%> />&nbsp;</td>
  </tr>
<%
       }
       else if (attrName.equals(ProductLineConstants.ATTRIBUTE_ORIGINATOR))
       {
%>
          <input type="hidden" name="<xss:encodeForHTMLAttribute><%=attrName%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=context.getUser()%></xss:encodeForHTMLAttribute>" />
<%
          continue;
        }
        else if((ProductLineConstants.ATTRIBUTE_DEFAULT_PART_TYPE).equals(attrName))
        {
          attributeNames.append(";");
          attributeNames.append(attrName);

          // Modified by Infosys for Bug # 318081 Date Apr 10, 2006
          String strAttrNameDisp = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Attribute."+strAttrNameSymb,languageStr);
          //Added by Vibhu,Infosys for Bug 311827 on 11/10/2005
          String sSelectedPartTypeDisplay = i18nNow.getAdminI18NString("Type", sSelectedPartType, languageStr);
%>
          <tr>
            <td class="label"><%=XSSUtil.encodeForHTML(context,strAttrNameDisp)%></td>
            <!--Modified by Vibhu,Infosys for Bug 311827 on 11/10/2005-->
            <td class="inputField"><input type="text" name="defaultPartTypeDisplay" value="<xss:encodeForHTMLAttribute><%=sSelectedPartTypeDisplay%></xss:encodeForHTMLAttribute>" />
            <input type="hidden" name="defaultPartTypeActual" value="<xss:encodeForHTMLAttribute><%=sSelectedPartType%></xss:encodeForHTMLAttribute>" />
            <input type="button" name="" value="..." onClick="Javascript:showPartTypeSelector()" />
            </td>
          </tr>
<%
        }
        else if((ProductLineConstants.ATTRIBUTE_DEFAULT_PART_POLICY).equals(attrName))
        {
          attributeNames.append(";");
          attributeNames.append(attrName);

          // Modified by Infosys for Bug # 318081 Date Apr 10, 2006
          String strAttrNameDisp = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Attribute."+strAttrNameSymb, languageStr);

%>
          <tr>
            <td class="label"><%=XSSUtil.encodeForHTML(context,strAttrNameDisp)%></td>
            <td class="inputField">
            <select name="defaultPartPolicyActual"  >
<%
          // get policies of selected type
          MapList maplistPolicies = mxType.getPolicies(context, sSelectedPartType, false);
          Iterator partPolicyItr = maplistPolicies.iterator();

          while(partPolicyItr.hasNext())
          {
            String selected = "";

            Map policyMap = (Map) partPolicyItr.next();
            String policyName = (String) policyMap.get("name");

            // Don't use Mfg Equivalent policies
            if (com.matrixone.apps.configuration.PartFamily.getPolicyClassification(context, policyName).equals("Equivalent"))
            {
              continue;
            }
            if(sSelectedPartPolicy != null && policyName.equals(sSelectedPartPolicy))
            {
              selected = "selected";
            }

%>
            <option value="<xss:encodeForHTMLAttribute><%=policyName%></xss:encodeForHTMLAttribute>" <%=selected%> ><%=XSSUtil.encodeForHTML(context,i18nNow.getAdminI18NString("Policy", policyName, languageStr))%></option>
<%
          }
%>
            </select>
            </td>
          </tr>
<%
        }
        else
        {
   /***********Begin of Add by Yukthesh, Infosys for Bug #310344**********/
         if((attrName.indexOf("Title"))<0 && (attrName.indexOf("Count"))<0)
          {
             attributeNames.append(";");
             attributeNames.append(attrName);

             // Modified by Infosys for Bug # 318081 Date Apr 10, 2006
             String strAttrNameDisp = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Attribute."+strAttrNameSymb,languageStr);

             strAttrCommon = emxGetParameter(request,attrName);
             if(strAttrCommon == null || "".equals(strAttrCommon) || "null".equals(strAttrCommon))
             {
               strAttrCommon = (String)valueMap.get("value");
             }

%>
          <tr>
            <td class="label"><%=XSSUtil.encodeForHTML(context,strAttrNameDisp)%></td>
             <td class="inputField"><input type="text" name="<xss:encodeForHTMLAttribute><%=attrName%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%= (attrValue !=null && !"".equals(attrValue))?attrValue:(strAttrCommon)%></xss:encodeForHTMLAttribute>" /></td>
          </tr>
<%
          }
          else
          {
               attributeNames.append(";");
               attributeNames.append(attrName);
               String strAttrName = attrName.replace(' ','_');
               strAttrCommon = emxGetParameter(request,attrName);
               if(strAttrCommon == null || "".equals(strAttrCommon) || "null".equals(strAttrCommon))
              {
                strAttrCommon = (String)valueMap.get("value");
              }
%>
              <input type="hidden" name="<%=strAttrName%>" value="<xss:encodeForHTMLAttribute><%= (attrValue !=null && !"".equals(attrValue))?attrValue:(strAttrCommon)%></xss:encodeForHTMLAttribute>" />
<%
           }
        }
  /***********End of Add by Yukthesh, Infosys for Bug #310344**************/
  }
%>

      <input type="hidden" name="VaultDisp" size="16" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=(selectedVault != null && !"".equals(selectedVault))?selectedVault:strUserVaultDisplay%></xss:encodeForHTMLAttribute>">&nbsp;
      <input type="hidden" class="button" size = "200" value="..."  onClick="javascript:showVaultSelector();">
      <input type="hidden" name="Vault" value="<xss:encodeForHTMLAttribute><%=(selectedVault != null && !"".equals(selectedVault))?selectedVault:strUserVault%></xss:encodeForHTMLAttribute>">

</table>
<!-- NextGen UI Adoption : Commented below image-->
<!-- <input type="image" height="1" width="1" border="0"> -->
<input type="hidden" name="attributeNames" value="<xss:encodeForHTMLAttribute><%=attributeNames.toString()%></xss:encodeForHTMLAttribute>" />

</form>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
