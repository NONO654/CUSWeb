<%--  ProductVariantCreateDialog.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "GlobalSettingInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject" %>
<%@page import="com.matrixone.apps.productline.ProductLineConstants" %>
<%@page import="com.matrixone.apps.productline.ProductLineCommon" %>
<%@page import="com.matrixone.apps.productline.ProductLineUtil" %>
<%@page import="com.matrixone.apps.productline.Product" %>
<%@page import="com.matrixone.apps.configuration.ProductVariant" %>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants" %>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>

<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>  
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
    //Retrieves Objectid to make use for the revise process
    String objectId = emxGetParameter(request, "objectId");
    String jsTreeId = emxGetParameter(request, "jsTreeID");
    String relId = emxGetParameter(request, "relId");
    String strMode = emxGetParameter(request, "mode");
    String strParam = emxGetParameter(request, "FTRParam");
    String strTimeStamp = emxGetParameter(request, "timeStamp");
    String  strProductVariantDSName = null;
    String  strProductVariantDSId = null;
    String srcProductVariantId=null;
    HashMap sessionHolder = null;
    boolean bShowSourceProductVariant = false;
    MapList productVariants = null;
    String selectedData = emxGetParameter(request, "selectedData");
    	
  try{

    //ProductVariant productVariantBean = (ProductVariant) DomainObject.newInstance(context,ConfigurationConstants.TYPE_PRODUCT_VARIANT,"Configuration");
    ProductVariant productVariantBean = new com.matrixone.apps.configuration.ProductVariant();
    Product productBean = (Product) DomainObject.newInstance(context,ProductLineConstants.TYPE_PRODUCTS,"ProductLine");
    Map versionInfoMap = productBean.getVersionInfo(context,objectId);
    String strName = (String) versionInfoMap.get(DomainConstants.SELECT_NAME);
    String strRevision = (String) versionInfoMap.get(DomainConstants.SELECT_REVISION);
    String strType = ConfigurationConstants.TYPE_PRODUCT_VARIANT;
    String strAttribNames[] = {ProductLineConstants.ATTRIBUTE_WEB_AVAILABILITY};
    String strPolicy = ConfigurationConstants.POLICY_PRODUCT_VARIANT;
    Map attrRangeMap = ProductLineUtil.getAttributeChoices(context,strAttribNames);
    String language = context.getSession().getLanguage();
    String strDiaplayTypeName = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ProductVariant.Type",language);
    String strDiaplayPolicyName = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ProductVariant.Policy",language);

    String srcProductVariantName =null;

    if(strParam != null && (strParam.equals("getFromSession"))) 
    {
        sessionHolder = new HashMap();
        sessionHolder = (HashMap)session.getAttribute("productVariant");
        srcProductVariantName = (String)session.getAttribute("productVariantName");
    }
   // Populate Design Responsibility of the Context Product to the Product Variant
    if((strMode.equalsIgnoreCase("create"))||(strMode.equalsIgnoreCase("viewCreate"))||(strMode.equalsIgnoreCase("viewClone")))
    {
      try
      {
        DomainObject domProduct = new DomainObject(objectId);
        strProductVariantDSName = domProduct.getInfo(context, "to["+ProductLineConstants.RELATIONSHIP_PRODUCT_ORGANIZATION+"].from.name");
        strProductVariantDSId = domProduct.getInfo(context, "to["+ProductLineConstants.RELATIONSHIP_PRODUCT_ORGANIZATION+"].from.id");
     }
      catch(Exception e)
      {
        session.putValue("error.message", e.getMessage());
      }
    }

    /* if Mode is Clone */
    if(strMode.equalsIgnoreCase("clone") && (!(strMode.equalsIgnoreCase("create"))|| !(strMode.equalsIgnoreCase("viewCreate"))))
    {
      try
      {
        bShowSourceProductVariant = true;
        String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
        String sourceProductVariant="";
        if(arrTableRowIds!=null)
        {
        for (int i=0;i<arrTableRowIds.length;i++)
        {   
            sourceProductVariant += arrTableRowIds[i];
        }
        StringTokenizer strToken = new StringTokenizer(sourceProductVariant);
	        if(strToken.hasMoreElements()){
	        	strToken.nextToken("|");
	        	if(strToken.hasMoreElements())
            srcProductVariantId= strToken.nextToken("|");
        }
        }
        if(srcProductVariantId==null)
        	srcProductVariantId=emxGetParameter(request, "productVariantId");
        DomainObject domProductVariant = new DomainObject(srcProductVariantId);
        srcProductVariantName = domProductVariant.getInfo(context,DomainObject.SELECT_NAME);
        strProductVariantDSName = domProductVariant.getInfo(context, "to["+ProductLineConstants.RELATIONSHIP_PRODUCT_ORGANIZATION+"].from.name");
        strProductVariantDSId = domProductVariant.getInfo(context, "to["+ProductLineConstants.RELATIONSHIP_PRODUCT_ORGANIZATION+"].from.id");
     }
      catch(Exception e)
      {
        session.putValue("error.message", e.getMessage());
      }
    }
    if(strMode.equalsIgnoreCase("viewClone"))
    {
        bShowSourceProductVariant = true;
        productVariants = productVariantBean.getProductVariants(context,objectId);
        productVariants.sort(DomainObject.SELECT_REVISION,"descending","String");
    }
%>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
    <form name="ProductVariant" action="moveNext(); return false" method="post">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
    
      <input type="hidden" name="revision" value="<xss:encodeForHTMLAttribute><%=strRevision%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="chkAutoName" value="unchecked" />
      <table border="0" cellpadding="5" cellspacing="2" width="100%">

      <tr>
        <td width="150" nowrap="nowrap" class="label">
         <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.ProductRevision
         </emxUtil:i18n> 
        </td>
        <td  nowrap="nowrap" class="field">
          <%=XSSUtil.encodeForHTML(context,strName)%>
          <input type="hidden" name="txtProductRevisionName" value="<xss:encodeForHTMLAttribute><%=strName%></xss:encodeForHTMLAttribute>" />
        </td>
      </tr>


      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Name
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <%=XSSUtil.encodeForHTML(context,strName)%>
          <input type="hidden" name="txtProductName" value="<xss:encodeForHTMLAttribute><%=strName%></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="hiddenProductName" value="" />
        </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Type
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <%=XSSUtil.encodeForHTML(context,strDiaplayTypeName)%>
          <input type="hidden" name="txtType" value="<xss:encodeForHTMLAttribute><%=strType%></xss:encodeForHTMLAttribute>" />
        </td>
      </tr>

<%if (strMode.equalsIgnoreCase("clone")&& (srcProductVariantName!=null)){%>
      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.SourceProductVariant
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
        <!-- XSSOK -->
         <%if(sessionHolder != null){out.println(srcProductVariantName);}else{%><%=srcProductVariantName %><%}%>
         <input type="hidden" name="txtSourceProductVariant" value="<xss:encodeForHTMLAttribute><%=srcProductVariantName%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="productVariantId" value="<xss:encodeForHTMLAttribute><%=srcProductVariantId%></xss:encodeForHTMLAttribute>" />
        </td>
      </tr>
<%}%>

<%if (strMode.equalsIgnoreCase("viewClone")){%>
      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.SourceProductVariant
          </emxUtil:i18n>
        </td>
        <td  class="field">
        <select name="productVariantId" onChange="test()">
<%
        String productVariantName = null;
        for(int i=0;i<productVariants.size();i++)
        {
            Map tempMap = (Map) productVariants.get(i);
            productVariantName = (String)tempMap.get("name");
            srcProductVariantId = (String)tempMap.get("id");
            %>
            <option value="<xss:encodeForHTMLAttribute><%=srcProductVariantId%></xss:encodeForHTMLAttribute>"><%=XSSUtil.encodeForHTML(context,productVariantName)%>
<%
        }
%>
        </select>
        </td>
      </tr>

<%}%>

      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.NewVariantName
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtName" value="<% if(sessionHolder != null){ out.println(sessionHolder.get("strName"));}%>" onBlur="updateProductVariantMarketingName()" />
           <input type="hidden" name="hiddenVariantName" value="" />
        </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Description
          </emxUtil:i18n>
        </td>
        <td  class="field">
        <textarea name="txtDescription" rows="5" cols="25"><xss:encodeForHTML><% if(sessionHolder != null){%><%=sessionHolder.get("strDescription")%><%}%></xss:encodeForHTML></textarea>
        </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Owner
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtProductVariantOwner" size="20" readonly="readonly" value="<% if(sessionHolder != null){ out.println(sessionHolder.get("strOwner"));} else { out.println(context.getUser());}%>" />
          <input class="button" type="button" name="btnOwner" size="200" value="..." alt=""  onClick="javascript:showPersonSelector();" />
          <input type="hidden" name="txtProductVariantOwnerId" value="" />
        </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.Marketing_Name
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtMarketingName" size="20" value="<%if(sessionHolder!= null){out.println(sessionHolder.get("strMarketingName"));}%>" onBlur="setMarketingNameFlag()" />
          <input type = "hidden" name="hiddenTxtMarketingName" value="" />
        </td>
      </tr>

      <tr>
        <td width="150" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.Marketing_Text
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <textarea name="txtProductMarketingText" rows="5" cols="25"><xss:encodeForHTML><% if(sessionHolder != null){%><%=sessionHolder.get("strMarketingText")%><%}%></xss:encodeForHTML></textarea>
        </td>
      </tr>

       <tr>
         <td width="150" nowrap="nowrap" class="label">
           <emxUtil:i18n localize="i18nId">
             emxProduct.Form.Label.DesignResponsibility
           </emxUtil:i18n>
         </td>
         <td nowrap="nowrap" class="field">
           <input type="text" name="txtProductVariantDesResp" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><% if(strProductVariantDSName!=null){%><%=strProductVariantDSName%>
           <% }else if(sessionHolder != null){ out.println(sessionHolder.get("strDesRespName"));}%></xss:encodeForHTMLAttribute>" />
           <input class="button" type="button" name="btnProductVariantDesignResponsibility" size="200" value="..." alt=""  onClick="javascript:showDesignResponsibilitySelector();" />
           <!-- XSSOK -->
           <input type="hidden" name="txtProductVariantDesignResponsibility" value="<xss:encodeForHTMLAttribute><%if(strProductVariantDSName!=null){%><%=strProductVariantDSId%> <%}else if(sessionHolder != null){out.println(sessionHolder.get("strDesRespName"));}%></xss:encodeForHTMLAttribute>" />
         </td>
       </tr>

      <tr>
        <td width="150" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.Start_Effectivity
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <input type="text" name="txtProductVariantSEDate" size="20"  readonly="readonly" value="<% if(sessionHolder != null){ out.println(sessionHolder.get("strProductVariantSEDate"));}%>" />
          <a href="javascript:showCalendar('ProductVariant','txtProductVariantSEDate', '')">
            <img src="../common/images/iconSmallCalendar.gif" border="0" valign="bottom" />
          <input type="hidden" name="txtProductVariantSEDate_msvalue" value="<xss:encodeForHTMLAttribute><% if(sessionHolder != null){ out.println(sessionHolder.get("strProductVariantSEDateValue"));}%></xss:encodeForHTMLAttribute>" />
          </a>
        </td>
      </tr>

      <tr>
        <td width="150" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.End_Effectivity
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <input type="text" name="txtProductVariantEEDate" size="20"  readonly="readonly" value="<% if(sessionHolder != null){ out.println(sessionHolder.get("strProductVariantEEDate"));}%>" />
          <a href="javascript:showCalendar('ProductVariant','txtProductVariantEEDate','')">
            <img src="../common/images/iconSmallCalendar.gif" border="0" valign="bottom" />
          <input type="hidden" name="txtProductVariantEEDate_msvalue" value="<xss:encodeForHTMLAttribute><% if(sessionHolder != null){ out.println(sessionHolder.get("strProductVariantEEDateValue"));}%></xss:encodeForHTMLAttribute>" />
          </a>
        </td>
      </tr>

     
<%
    MapList attrMapList = (MapList) attrRangeMap.get(strAttribNames[0]);

    //Getting Internationalized range values
    attrMapList = ProductLineCommon.getI18nValues(attrMapList, ProductLineConstants.ATTRIBUTE_WEB_AVAILABILITY, acceptLanguage);

    String strSelected = "";
    String attrRangeValue = "";
    String attrI18nRangeValue = "";

    for (int i = 0 ; i < attrMapList.size();i++)
    {
      attrRangeValue = (String)((HashMap)attrMapList.get(i)).get(ProductLineConstants.VALUE);
      attrI18nRangeValue = (String)((HashMap)attrMapList.get(i)).get(DomainConstants.SELECT_NAME);

      if (i == 0)
        strSelected = "checked";
      else
        strSelected = "";
%>
        <INPUT TYPE="hidden" NAME="radProductWebAvailability" value="<xss:encodeForHTMLAttribute><%=attrRangeValue%></xss:encodeForHTMLAttribute>" <xss:encodeForHTMLAttribute><%=strSelected%></xss:encodeForHTMLAttribute>>

<%
    }
%>

         <tr>
           <td width="150" class="label" valign="top">
             <emxUtil:i18n localize="i18nId">
               emxFramework.Basic.Policy
             </emxUtil:i18n>
           </td>
           <td class="field">
             <%=XSSUtil.encodeForHTML(context,strDiaplayPolicyName)%>
             <input type="hidden" name="txtProductVariantPolicy" value="<xss:encodeForHTMLAttribute><%=strPolicy%></xss:encodeForHTMLAttribute>" />
           </td>
         </tr>
  <%
    if (bShowVault && (!strMode.equalsIgnoreCase("clone") && !strMode.equalsIgnoreCase("create")))
       {
   %>
       <tr>
         <td width="150" class="label" valign="top">
           <emxUtil:i18n localize="i18nId">
             emxFramework.Basic.Vault
           </emxUtil:i18n>
         </td>
         <td class="field">
           <input type="text" name="txtProductVariantVaultDisplay" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strUserVaultDisplay%></xss:encodeForHTMLAttribute>" />
           <input type="hidden" name="txtProductVariantVault" size="15" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>" />

           <input class="button" type="button" name="btnVault" size="200" value="..." alt=""  onClick="javascript:showVaultSelector();" />&nbsp;
               <a name="ancClear" href="#ancClear" class="dialogClear" href="#" onclick="document.ProductVariant.txtProductVariantVaultDisplay.value='';document.ProductVariant.txtProductVariantVault.value=''">
                 <emxUtil:i18n localize="i18nId">
                   emxProduct.Button.Clear
                 </emxUtil:i18n>
               </a>
         </td>
       </tr>
   <%
       }else{
   %>
       <input type="hidden" name="txtProductVariantVault" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>" />
   <%
       }
   %>


      <tr>
        <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
        <td width="90%">&nbsp;</td>
      </tr>

      </table>
    </form>
<%

	if(sessionHolder != null && !(strMode.equalsIgnoreCase("viewClone")))
	{
		srcProductVariantId = (String)sessionHolder.get("strProductVariantId");
	}


  }catch(Exception e)
  {
    session.putValue("error.message", e.getMessage());
  }
%>

  <%@include file = "emxValidationInclude.inc" %>

  <script language="javascript" type="text/javaScript">
    var  formName = document.ProductVariant;
	function doValidateClear()
	{
		var choice = confirm("<%=i18nNow.getI18nString("emxProduct.DesignResponsibilityClear.ConfirmMessage", bundle,acceptLanguage)%> ");
		if(choice)
		{
				formName.txtProductVariantDesResp.value = ""; // name
				formName.txtProductVariantDesignResponsibility.value = "";			//id
		} 
	}

    //when 'Cancel' button is pressed.
    function closeWindow()
    {
      parent.window.closeWindow();
    }
    //This function is for popping the Person chooser.
    function showPersonSelector()
    {
		var objCommonAutonomySearch = new emxCommonAutonomySearch();

	   objCommonAutonomySearch.txtType = "type_Person";
	   objCommonAutonomySearch.selection = "single";
	   objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchOwner"; 
	   objCommonAutonomySearch.open();
     }
	 function submitAutonomySearchOwner(arrSelectedObjects) 
	{
   
		var objForm = document.forms["ProductVariant"];
		
		var hiddenElement = objForm.elements["txtProductVariantOwnerId"];
		var displayElement = objForm.elements["txtProductVariantOwner"];

		for (var i = 0; i < arrSelectedObjects.length; i++) 
		{ 
			var objSelection = arrSelectedObjects[i];
			hiddenElement.value = objSelection.name;
			displayElement.value = objSelection.name;
			break;
      }
     }

     //This file contains the function to update the marketing name
     <%@include file = "./emxUpdateMarketingNameInclude.inc" %>

    //This function is for popping the Design Responsibility/Organiztion chooser.
    function showDesignResponsibilitySelector()
    {
        var sURL=
	'../common/emxFullSearch.jsp?field=TYPES=type_Organization&table=PLCDesignResponsibilitySearchTable&showInitialResults=false&selection=single&formName=ProductVariant&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../configuration/SearchUtil.jsp?&mode=Chooser&chooserType=FormChooser&fieldNameActual=txtProductVariantDesignResponsibility&fieldNameDisplay=txtProductVariantDesResp';
        showChooser(sURL, 850, 630)
    }

    //This function is for popping the Vault chooser.
    function showVaultSelector()
    {
        showChooser('../common/emxVaultChooser.jsp?fieldNameActual=txtProductVariantVault&fieldNameDisplay=txtProductVariantVaultDisplay&incCollPartners=false&multiSelect=false');
    }

    function test()
    {
//To be implemented
    }




    function moveNext() 
    {
        var iValidForm = true;
        var msg = "";
        var strMode = '<%=XSSUtil.encodeForJavaScript(context,strMode)%>';
        var productVariantId;
        var timeStamp = '<%=XSSUtil.encodeForJavaScript(context,strTimeStamp)%>';

        
        if(strMode=='viewClone')
        {
		    productVariantId = formName.productVariantId.value;
        }
        else{
	        productVariantId ='<%=XSSUtil.encodeForJavaScript(context,srcProductVariantId)%>';
        }
        
        
        
        if (iValidForm) 
        {
             var fieldName = "<%=i18nNow.getI18nString("emxFramework.Attribute.NewVariantName", bundle,acceptLanguage)%> ";
             var field = formName.txtName;
             iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
             document.ProductVariant.hiddenVariantName.value = document.ProductVariant.txtName.value;
             document.ProductVariant.hiddenProductName.value = document.ProductVariant.txtProductName.value;
         }
         if (iValidForm) 
         {
             var fieldName = "<%=i18nNow.getI18nString("emxFramework.Attribute.Marketing_Name", bundle,acceptLanguage)%> ";
             var field = formName.txtMarketingName;
             iValidForm = basicValidation(formName,field,fieldName,true,true,false,false,false,false,false);
             document.ProductVariant.hiddenTxtMarketingName.value = document.ProductVariant.txtMarketingName.value;

             // Added for bug no. IR-052159V6R2011x
             if(iValidForm)
             {
                // iValidForm = chkMarketingNameBadChar(field);
             }
         }

         if (iValidForm)
         {
              var fieldName = "<%=i18nNow.getI18nString("emxFramework.Attribute.Marketing_Text", bundle,acceptLanguage)%> ";
              var field = formName.txtProductMarketingText;
              iValidForm = basicValidation(formName,field,fieldName,false,false,false,false,false,false,checkBadChars);
         }
         if (iValidForm)
         {
               var fieldSED = formName.txtProductVariantSEDate_msvalue;
               var fieldEED = formName.txtProductVariantEEDate_msvalue;
               var msg = "";
               if((trimWhitespace(fieldSED.value) == '') && (trimWhitespace(fieldEED.value) == ''))
               {
                    //Condition Check when both Start Effectivity and End Effectivity are Empty
                    var i = 0;
                    for(i=0; i<formName.radProductWebAvailability.length; i++)
                    {
                        if(formName.radProductWebAvailability[i].checked)
                        {
                            //to check if Released and Effective Products is selected
                            if(formName.radProductWebAvailability[i].value == "Released and Effective Products")
                            {
                                msg = "<%=i18nNow.getI18nString("emxProduct.Alert.ReleasedAndEffectiveProducts",bundle,acceptLanguage)%>";
                                alert(msg);
                                iValidForm = false;
                                break;
                            }
                        }
                    }
              }
              else if(trimWhitespace(fieldSED.value) == '')
              {
                  //Condition Check when only Start Effectivity is not entered. Start Effectivity is also needed.
                  msg = "<%=i18nNow.getI18nString("emxProduct.Alert.EmptyStartEffectivity",bundle,acceptLanguage)%>";
                  alert(msg);
                  iValidForm = false;
              }
              else if(trimWhitespace(fieldEED.value) == '')
              {
                   //Condition Check when only End Effectivity is not entered. End Effectivity is also needed.
                   msg = "<%=i18nNow.getI18nString("emxProduct.Alert.EmptyEndEffectivity",bundle,acceptLanguage)%>";
                   alert(msg);
                   iValidForm = false;
              }
              else
              {
                    if (fieldSED.value > fieldEED.value)
                    {
                    //Condition check when Start Effectivity Date is after End Effectivity Date. It should be before the End Effectivity //Date
                    msg = "<%=i18nNow.getI18nString("emxProduct.Alert.InvalidEffectivityDateEntry",bundle,acceptLanguage)%>";
                    alert(msg);
                    iValidForm = false;
                    }
              }
         }
         
         if(!iValidForm) 
         {
            return;
         }
         formName.target="_top";        
         formName.action="../configuration/ProductVariantUtil.jsp?mode=featureSelect&objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeId)%>&relId=<%=XSSUtil.encodeForURL(context,relId)%>&clone=<%=bShowSourceProductVariant%>&context=<%=XSSUtil.encodeForURL(context,strMode)%>&selectedData=<%=XSSUtil.encodeForURL(context,selectedData)%>&productVariantId="+productVariantId+"&hasTechnicalFeatures=<%="true"%>&timeStamp="+timeStamp;
         submitForm();
    }
	/*Start - Added by   3dPLM on 10/4/2007*/
	function checkDesignResponsibility()
	{
		var oldOID = "<%=XSSUtil.encodeForJavaScript(context,strProductVariantDSId)%>";
		oldOID = trimWHSpaces(oldOID);
		formName.txtProductVariantDesignResponsibility.value = trimWHSpaces(formName.txtProductVariantDesignResponsibility.value);

		if(oldOID != null && oldOID != "" && oldOID != "null" && oldOID != formName.txtProductVariantDesignResponsibility.value)
		{

			 var choice = confirm("<%=i18nNow.getI18nString("emxProduct.DesignResponsibilityChooser.ConfirmMessage", bundle,acceptLanguage)%> ");

			 if(!choice)
				{
					formName.txtProductVariantDesignResponsibility.value = "<%=XSSUtil.encodeForJavaScript(context,strProductVariantDSId)%>";
					formName.txtProductVariantDesResp.value = "<%=XSSUtil.encodeForJavaScript(context,strProductVariantDSName)%>";
					return false;
				}
			 else
				{
					return true;
				}
		}
		return true;
	}

	function trimWHSpaces(testStr)
	{
		if(testStr !=null && testStr != "")
		{
			for(var i=0; i< testStr.length; i++)
			{
				if(testStr.charAt(i)==" ")
				{
					testStr = testStr.replace(" ","");
				}
			}
			return testStr;
		}
		return "";
	}
	function submitForm()
	{
		var isContinue = checkDesignResponsibility();
		if (!isContinue)
		{
			return ;
		}
		formName.submit();
	}
   /*End - Added by , 3dPLM on 10/4/2007*/
  </script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
