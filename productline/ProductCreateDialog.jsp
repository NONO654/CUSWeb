  <%--  ProductCreateDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/ProductCreateDialog.jsp 1.15.2.9.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";

--%>
<%-- Include JSP for error handling --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%-- Common Includes --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "GlobalSettingInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>



<%@page import="com.matrixone.apps.productline.*,com.matrixone.apps.domain.DomainConstants,java.util.*,java.text.*"%>
<%@page import = "com.matrixone.apps.common.Person"%>
<%@page import = "com.matrixone.apps.domain.util.i18nNow"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants" %>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>


<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>  
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script>
	var bAllowSubmit = true;
</script>

<%

  //This is required for the Type Chooser to work
  String strBaseType = "";
  String PRCFSParam2 = "";
  String ProductId  = "";
   String objectId = "";

  //Added for Type Chooser, to exclude Product Variant type
  //Added by Praveen V
    String strInclusionType = EnoviaResourceBundle.getProperty(context,"emxProduct.Product.Create.IncludeTypes");
	String strName = "";
	String strDesResId =  null;
	String strOldDOId = null;
	String strModelPrefixLength = EnoviaResourceBundle.getProperty(context,"emxProductLine.Model.ModelPrefixLength");
	
	%>
	<script type="text/javascript">
	var strModelPrefixLength = "<xss:encodeForJavaScript><%=strModelPrefixLength %></xss:encodeForJavaScript>"
	</script>
	<% 
	//Added for 376215
	 String strModelPrefixVal = "false";
  try
  {
      //Modifications for BUG: 376215
//    If is UNT Installed and property setting(ModelPrefixMandatoryAndUnique) is true
 	
	String strClassLabelForModel = "label";
	if( com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appInstallTypeUnitTracking",false,null,null)){
	 	    try{
	    	    String propVal = EnoviaResourceBundle.getProperty(context,"emxUnitTracking.Model.ModelPrefixMandatoryAndUnique");
    		    if(propVal!= null && propVal.equalsIgnoreCase("true")) {
					strClassLabelForModel = "labelRequired";
					strModelPrefixVal = "true";
    	    	}
	 	    }catch (Exception e){}
	}
// End - 376215
    //Retrieves Objectid and jsTreeID for processing
    objectId = emxGetParameter(request, "objectId");
  
    String modelPrefixVal = "";
    String isReadOnly = "";
    if (objectId == null||"null".equalsIgnoreCase(objectId)||"".equals(objectId)){
     objectId = "";
     }
    else
    {
    DomainObject domainObj = new DomainObject(objectId);
    
    modelPrefixVal = domainObj.getAttributeValue(context, "Prefix");
    isReadOnly = "readOnly";
   

    Map hMap = new HashMap();
    StringList slist = new StringList();
    slist.add("from[Products].to.id");
    hMap = domainObj.getInfo(context,slist);
    ProductId = (String)hMap.get("from[Products].to.id");
    }


	/* Start-Added by Amarpreet Singh 3dPLM for addition of Design Responsibility*/
	if (objectId!= null && !"".equals(objectId)){
		ProductLineCommon plcBean = new ProductLineCommon();
		strDesResId = plcBean.getDefaultRDO(context,objectId);
		if(strDesResId != null && !"".equals(strDesResId))
		{
			DomainObject domDesRes = new DomainObject(strDesResId);
			strName = domDesRes.getInfo(context,DomainConstants.SELECT_NAME);
		}
		strOldDOId = strDesResId;	
	}
	 /* End-Added by Amarpreet Singh 3dPLM for addition of Design Responsibility*/

    StringList companyList = ProductLineUtil.getUserCompanyIdName(context);
    String strCompanyId = (String)companyList.elementAt(0);
    String strCompanyName = (String)companyList.elementAt(1);

    String strModelName = "";

    if (null != objectId && !"null".equalsIgnoreCase(objectId) && !"".equals(objectId))
    {
	    strModelName = com.matrixone.apps.framework.ui.UINavigatorUtil.getParsedHeaderWithMacros(context,acceptLanguage,"NAME",objectId);
	   //Added For FCA Start
	    DomainObject dmoObj = DomainObject.newInstance(context, objectId);
	    if(!dmoObj.isKindOf(context, ProductLineConstants.TYPE_MODEL))
	    {
	    	strModelName = "";
	    }
	  //Added For FCA End
    }
    
    
    PRCFSParam2 = emxGetParameter(request, "PRCFSParam2");

    //Retrieves the tree node id to insert the created object
    String jsTreeID = emxGetParameter(request, "jsTreeID");

    //The base type is set for the Type chooser variable.
    strBaseType = ProductLineConstants.TYPE_PRODUCTS;

    //Product bean instantiated for processing
    Product productBean = (Product) com.matrixone.apps.domain.DomainObject.newInstance(context,strBaseType,"ProductLine");

    /*
     *The array of attribute names is formed to get back the ranges of the
     *attribute from the backend using one function call
     */
    String strAttribNames[] = {ProductLineConstants.ATTRIBUTE_WEB_AVAILABILITY};
    Map attrRangeMap = ProductLineUtil.getAttributeChoices(context,strAttribNames);

    //The default revision for the product object is obtained from the bean.
    String strDefaultRevision = productBean.getDefaultRevision(context,ProductLineConstants.POLICY_PRODUCT);

    if ((!objectId.equals("")) && (ProductId!=null) ){

        ProductLineCommon commonBean = new ProductLineCommon();
        //This method returns a map containing information about Type, name next revision sequence and description.
        //it is used to populate the default values in the dialog box
        Map mpObjectInfo = (HashMap)commonBean.getRevisionInfo(context,ProductId);
        if(mpObjectInfo!=null && mpObjectInfo.size()!=0){
            strDefaultRevision = (String) mpObjectInfo.get(DomainConstants.SELECT_REVISION);
        }
    }

    MapList policyList = com.matrixone.apps.domain.util.mxType.getPolicies(context,strBaseType,false);
    String strDefaultPolicy = (String)((HashMap)policyList.get(0)).get(DomainConstants.SELECT_NAME);
    Locale Local = request.getLocale();
    String strLocale = context.getSession().getLanguage();

    String strPolicy = ProductLineConstants.POLICY;
    String i18nPolicy  = i18nNow.getMXI18NString(strDefaultPolicy,"",strLocale.toString(),strPolicy);

    //For formating the dates
                 String timeZone = (String)session.getValue ("timeZone");
                 String Country = Local.getCountry();
    //displaying Owner name in Last Name,First Name format
    Person person = Person.getPerson(context);
    String strFirstName = person.getInfo(context,Person.SELECT_FIRST_NAME);
    String strLastName = person.getInfo(context,Person.SELECT_LAST_NAME);
    String strOwnerDisplay = strLastName + "," + strFirstName;

	
	 String strHardwareProduct = i18nNow.getTypeI18NString(ProductLineConstants.TYPE_HARDWARE_PRODUCT, strLocale);


%>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<body onload="return getFocus();">
    <form name="ProductCreate" method="post" onsubmit="submitForm(); return false">
    <!--Begin of Add: Raman,Enovia MatrixOne for Bug # 300768 on 3/30/2005-->
    <%
     String strContextMode = emxGetParameter(request,"PRCFSParam2");
    if ( (!"null".equalsIgnoreCase(strContextMode))&&
         (!"".equalsIgnoreCase(strContextMode))&&
          strContextMode!=null &&
          strContextMode.equalsIgnoreCase("contextModel"))
    {
    %>
         <input type="hidden" name="ContextMode" value="Model">
    <% }
    // Modified by Enovia MatrixOne for Bug # 302981 Date 04/29/2005
    else if(strContextMode.equalsIgnoreCase("contextProduct"))
    {
    %>
         <input type="hidden" name="ContextMode" value="Product">
    <%
       }
    %>
    <!--End of Add: Raman,Enovia MatrixOne for Bug # 300768 on 3/30/2005-->
      <input type="hidden" name="objectId" value="">
     <%
   //Added For FCA Start
    if (null != objectId && !"null".equalsIgnoreCase(objectId) && !"".equals(objectId))
        {
          DomainObject dmoObj = DomainObject.newInstance(context, objectId);
	    if(!dmoObj.isKindOf(context, ProductLineConstants.TYPE_MODEL))
	    {
     %>   	    <input type="hidden" name="txtModelId" value="">
     <%    }
          else
          {
     %>        	
                <input type="hidden" name="txtModelId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">
     <%   }
        }
   //Added For FCA End
    %>
      
      
      <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>">
      <input type="hidden" name="TimeZone" value="<xss:encodeForHTMLAttribute><%=timeZone%></xss:encodeForHTMLAttribute>">
                        <input type="hidden" name="RequestLocale" value="<xss:encodeForHTMLAttribute><%=Local%></xss:encodeForHTMLAttribute>">
      <input type="hidden" name="Country" value="<xss:encodeForHTMLAttribute><%=Country%></xss:encodeForHTMLAttribute>">
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <!-- Added by :Raman Enovia MatrixOne for Bug # 298000 on 5/12/2005-->
      <input type="hidden" name="contextParentId" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "objectId")%></xss:encodeForHTMLAttribute>">
      <%-- Display the input fields. --%>


<%
    /*
     *This logic defines if the name field is to be made visible to the user or not
     *These setting are based on the global settings for each module made in the
     *application property file.
     */
%>
    <input type="hidden" name="strAutoNamer" value="<xss:encodeForHTMLAttribute><%=strAutoNamer%></xss:encodeForHTMLAttribute>" >
<%
// XSSOK
    if (strAutoNamer.equalsIgnoreCase("False") || strAutoNamer.equalsIgnoreCase(""))
    {
    	//Added For FCA Start
    	//if(!objectId.equals("")){
    	if (null != strModelName && !"null".equalsIgnoreCase(strModelName) && !"".equals(strModelName)){
        //Added For FCA End
%>
      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Name
          </emxUtil:i18n>
        </td>
        <td class="field">
                <%=XSSUtil.encodeForHTML(context,strModelName)%>
        <input type="hidden" name="txtName" value="<xss:encodeForHTMLAttribute><%=strModelName%></xss:encodeForHTMLAttribute>">
        <input type="hidden" name="chkAutoName" checked="false">
        </td>
      </tr>

<%
        }else{

%>
      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Name
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtName" size="20" value="" onFocus="valueCheck()" onBlur="updateMarketingName()">
          &nbsp;
<%

      if (strAutoNamer.equalsIgnoreCase(""))
      {
%>
          <input type="checkbox" name="chkAutoName" onclick="nameDisabled()"><emxUtil:i18n localize="i18nId">emxProduct.Form.Label.Autoname</emxUtil:i18n>
<%
      }
%>
        </td>
      </tr>
<%
      }

    }else{

%>
      <input type="hidden" name="txtName" value="">


<%
    }
%>
      <!--Type Field -->
      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Type
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtProductType" size="20" value="<xss:encodeForHTMLAttribute><%=strHardwareProduct%></xss:encodeForHTMLAttribute>" readonly="readonly">
          <input class="button" type="button" name="btnType" size="200" value="..." alt=""  onClick="javascript:showTypeSelector();">
          <input type="hidden" name="txtProductActualType" value="<xss:encodeForHTMLAttribute><%=ProductLineConstants.TYPE_HARDWARE_PRODUCT%></xss:encodeForHTMLAttribute>" >
        </td>
      </tr>
      <!--Revision Field -->
      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Revision
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtRevision" size="20" value="<xss:encodeForHTMLAttribute><%=strDefaultRevision%></xss:encodeForHTMLAttribute>">
        </td>
      </tr>
      <tr>
       <!-- Class is defined using a variable for bug: 376215 -->
      <td width="150" class="<xss:encodeForHTMLAttribute><%=strClassLabelForModel%></xss:encodeForHTMLAttribute>">
        <framework:i18n localize="i18nId">emxProductLine.Model.ModelPrefix</framework:i18n>
      </td>
        
          
          <%
	          if(isReadOnly.equalsIgnoreCase(""))
	          {            
		          %>
		          <td  nowrap="nowrap" class="field">
		          <input type="text" name="txtModelPrefix" size="20"  maxlength="<xss:encodeForHTMLAttribute><%=strModelPrefixLength%></xss:encodeForHTMLAttribute>" onBlur="validatePrefix()" value="">
		          &nbsp;
		          </td>
		          <% 
	          }
	          else
	          {
	              %>
	              <td class="field">
	                <%=XSSUtil.encodeForHTML(context,modelPrefixVal)%>	              
	                <input type="hidden" name="txtModelPrefix" value="<xss:encodeForHTMLAttribute><%=strModelPrefixLength%></xss:encodeForHTMLAttribute>">
	               </td>
	              <% 
	          }
	        %>           
             
           
      
    </tr>
      <!--Description Field -->
      <tr>
        <td width="150" class="label" >
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Description
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <textarea name="txtProductDescription" rows="5" cols="25"></textarea>
        </td>
      </tr>
      <!--Company Field -->
      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxProduct.Form.Label.Company
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtProductCompany" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strCompanyName%></xss:encodeForHTMLAttribute>">
          <input class="button" type="button" name="btnCompany" size="200" value="..." alt=""  onClick="javascript:showCompanySelector();">
          <input type="hidden" name="txtCompanyId" value="<xss:encodeForHTMLAttribute><%=strCompanyId%></xss:encodeForHTMLAttribute>">
        </td>
      </tr>
      <!--Owner Field -->
      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Owner
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtProductOwnerId" size="20" value="<xss:encodeForHTMLAttribute><%=strOwnerDisplay%></xss:encodeForHTMLAttribute>" readonly="readonly">
          <input class="button" type="button" name="btnOwner" size="200" value="..." alt=""  onClick="javascript:showPersonSelector();">
          <input type="hidden" name="txtProductOwner" value="<xss:encodeForHTMLAttribute><%=context.getUser()%></xss:encodeForHTMLAttribute>">
        </td>
      </tr>
      <!--Design Responsibility Field -->
      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxProduct.Form.Label.DesignResponsibility
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtProductDesResp" size="20" readonly="readonly">
          <input class="button" type="button" name="btnProductDesignResponsibility" size="200" value="..." alt=""  onClick="javascript:showDesignResponsibilitySelector();">
          <input type="hidden" name="txtDRId" value="">
        </td>
      </tr>
      <!--Marketing Name Field -->
      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.Marketing_Name
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtMarketingName" size="20" onBlur="setMarketingNameFlag()">
        </td>
      </tr>
      <!--Marketing Text Field -->
      <tr>
        <td width="150" class="label" >
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.Marketing_Text
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <textarea name="txtProductMarketingText" rows="5" cols="25"></textarea>
        </td>
      </tr>
      <!--Base Price Field -->
      <tr>
        <td width="150" class="label" width="200" align="left">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.Base_Price
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <input type="text" name="txtProductBasePrice" size="20">
        </td>
      </tr>
      <!--Start Effectivity Field -->
      <tr>
        <td width="150" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.Start_Effectivity
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <input type="text" name="txtProductSEDate" size="20"  readonly="readonly">
          <a href="javascript:showCalendar('ProductCreate','txtProductSEDate', '')">
            <img src="../common/images/iconSmallCalendar.gif" border="0" valign="bottom">
          <input type="hidden" name="txtProductSEDate_msvalue" value="">
          </a>
        </td>
      </tr>
      <!--End effectivily Field -->
      <tr>
        <td width="150" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.End_Effectivity
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <input type="text" name="txtProductEEDate" size="20"  readonly="readonly">
          <a href="javascript:showCalendar('ProductCreate','txtProductEEDate', '')">
            <img src="../common/images/iconSmallCalendar.gif" border="0" valign="bottom">
          <input type="hidden" name="txtProductEEDate_msvalue" value="">
          </a>
        </td>
      </tr>
      <!--Web Availability Field -->
      <tr>
        <td width="150" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.Web_Availability
          </emxUtil:i18n>
        </td>
        <td  class="field">
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
        <INPUT TYPE="radio" NAME="radProductWebAvailability" value="<xss:encodeForHTMLAttribute><%=attrRangeValue%></xss:encodeForHTMLAttribute>" <xss:encodeForHTMLAttribute><%=strSelected%></xss:encodeForHTMLAttribute>><%=XSSUtil.encodeForHTML(context,attrI18nRangeValue)%>
        <BR></BR>

<%
    }
%>
        </td>
      </tr>

<%
    if (!bPolicyAwareness)
    {
        if( policyList.size() > 1)
        {
%>
      <!--Policy Field -->
      <tr>
        <td width="150" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Policy
          </emxUtil:i18n>
        </td>
        <td class="field">
          <select name="txtProductPolicy">
            <!-- XSSOK -->           
            <framework:optionList
              optionMapList="<%= policyList%>"
              optionKey="<%=DomainConstants.SELECT_NAME%>"
              valueKey="<%=DomainConstants.SELECT_NAME%>"
              selected = ""/>
          </select>
        </td>
      </tr>
<%
        }else{
%>
      <tr>
        <td width="150" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Policy
          </emxUtil:i18n>
        </td>
        <td class="field">
          <%=XSSUtil.encodeForHTML(context,i18nPolicy)%>
          <input type="hidden" name="txtProductPolicy" value="">
        </td>
      </tr>
<%
        }
    }else{
%>
      <input type="hidden" name="txtProductPolicy" value="">
<%
    }
%>
<%
    if (bShowVault)
    {
%>
      <!--Vault Field -->
      <tr>
        <td width="150" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Vault
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <input type="text" name="txtProductVaultDisplay" readonly="readonly" size="20" value="<xss:encodeForHTMLAttribute><%=strUserVaultDisplay%></xss:encodeForHTMLAttribute>">
          <input type="hidden" name="txtProductVault" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>" size=15>
          <input class="button" type="button" name="btnVault" size="200" value="..." alt=""  onClick="javascript:showVaultSelector();">&nbsp;
          <a name="ancClear" href="#ancClear" class="dialogClear" onclick="document.ProductCreate.txtProductVault.value='';document.ProductCreate.txtProductVaultDisplay.value=''"><framework:i18n localize="i18nId">emxProduct.Button.Clear</framework:i18n></a>
        </td>
      </tr>
<%
    }else{
%>
        <input type="hidden" name="txtProductVault" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>">
<%
    }

// HDM: Code to add HDM specific fields.
Boolean hasDesignSync =(Boolean)JPO.invoke(context, "emxVCDocumentUI", null, "hasDesignSyncServer", null, Boolean.class);
Boolean hasHDM = (Boolean)FrameworkUtil.isSuiteRegistered(context,"appVersionTeamCollaboration",false,"","");

if(hasDesignSync && hasHDM) {

%>
<tr>

<jsp:include page="../semiteamcollab/emxSCCHDMDesignSyncInformation.jsp">
 <jsp:param name="path" value="null"/>
      <jsp:param name="vcDocumentType" value="null"/>
      <jsp:param name="selector" value="null"/>
      <jsp:param name="server" value="null"/>
      <jsp:param name="format" value="null"/>
      <jsp:param name="showFormat" value="null"/>
      <jsp:param name="populateDefaults" value="null"/>
      <jsp:param name="objectAction" value="createAndConnect"/>
       <jsp:param name="formName" value="ProductCreate"/>
      <jsp:param name="disableFileFolder" value="null"/>
      <jsp:param name="defaultDocumentPolicyName" value="Product"/>
      <jsp:param name="reloadPage" value="null"/>
    </jsp:include>

</tr>
      <tr>
        <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
        <td width="90%">&nbsp;</td>
      </tr>
<%}
// HDM: End of HDM specific insertion.
 %>
      </table>
        <input type="image" value="" height="1" width="1" border="0" >
    </form>
    </body>
<%
  }catch(Exception e){
    session.putValue("error.message", e.getMessage());
  }
%>

  <%@include file = "emxValidationInclude.inc" %>

  <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
  <script language="javascript" type="text/javaScript">
  //START - Added for bug no. 0623125V6R2011x
  function getFocus()
  {
	  // XSSOK
	  if(<%=strAutoNamer.equalsIgnoreCase("False")%> == true || <%=strAutoNamer.equals("")%> == true)
	  {
		  document.ProductCreate.txtName.focus();
	  }else
	  {
		  document.ProductCreate.txtRevision.focus();
	  }
	  return true;
  }
  // END - Added for bug no. 0623125V6R2011x
  //<![CDATA[
    var  formName = document.ProductCreate;

    //if Autoname field is checked, focus goes to Revision field
    function valueCheck()
    {
        //XSSOK
      if (<%=strAutoNamer.equals("")%> == true)
      {
          if (formName.chkAutoName.checked)
          {
             formName.txtName.blur();
          }
      }
    }

    //for disabling the name field is autoname is checked
    function nameDisabled()
    {
        //XSSOK
      if (<%=strAutoNamer.equals("")%> == true)
      {
        if (formName.chkAutoName.checked)
        {
          formName.txtName.value="";
          formName.chkAutoName.value="true";
          formName.txtRevision.focus();
		  updateMarketingName();
        }else
        {
          formName.txtName.focus();
        }
      }
    }

    //when 'Cancel' button is pressed in Dialog Page
    function closeWindow()
    {
        //Releasing Mouse Events

        parent.window.closeWindow();
    }
/* Modified by <Tanmoy Chatterjee> On <10th July 2003>
   For the following Bug
   <In Case of Create  if the user has opened any of the choosers before the press of Done button  then when the operation fails then the previously entered values are getting lost>
   Fixed as Follows:
   <added the target as a hidden frame>
*/
    //When Enter Key Pressed on the form
   function submitForm()
   {
        submit();
   }
        //when 'Done' button is pressed in Dialog Page
    function submit()
    {
		
		if(bAllowSubmit == false)
		{
			return;
		}
		   
      //Validation for Required field,Length and Bad characters for Name
      var iValidForm = true;
      //XSSOK
      if (!(<%=strAutoNamer.equalsIgnoreCase("True")%> == true))
      {
          // XSSOK
        if (<%=strAutoNamer.equalsIgnoreCase("False")%> == true)
        {
          if (iValidForm)
          {
            var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
            var field = formName.txtName;
            iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
          }
        }else
        {
         if (!formName.chkAutoName.checked)
          {

            if (iValidForm)
            {
              var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
              var field = formName.txtName;
              iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
            }
          }
        }
      }

      //Validation for Required field, field Length and Bad characters for Revision
      if (iValidForm)
      {
        var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Revision", bundle,acceptLanguage)%> ";
        var field = formName.txtRevision;
        iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);

      }

      //Validation for Required field for Type
      if (iValidForm)
      {
        var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Type", bundle,acceptLanguage)%> ";
        var field = formName.txtProductType;
        iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,false);

      }

          //validation for special chars in the description field - The sixth(true/false) and last parameter 'checkBadChars' specifies which characters have to be blocked (all bad chars, common illegal characters are now Restricted Characters)
         if (iValidForm)
         {
           var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Description", bundle,acceptLanguage)%> ";
           var field = formName.txtProductDescription;
           iValidForm = basicValidation(formName,field,fieldName,false,false,false,false,false,false,checkBadChars);
         }

      //Validation for Required field,Length and Bad characters for Base Price
      if (iValidForm)
      {
        var fieldName = "<%=i18nStringNowUtil("emxFramework.Attribute.Base_Price", bundle,acceptLanguage)%> ";
        var field =  formName.txtProductBasePrice;
        iValidForm = basicValidation(formName,field,fieldName,false,false,false,true,false,false,false);
      }

      //Validation for Required field,Length for Marketing Name
      if (iValidForm)
      {
        var fieldName = "<%=i18nStringNowUtil("emxFramework.Attribute.Marketing_Name", bundle,acceptLanguage)%> ";
        var field = formName.txtMarketingName;
        iValidForm = basicValidation(formName,field,fieldName,true,true,false,false,false,false,false);
        if(iValidForm)
        {
            iValidForm = chkMarketingNameBadChar(field);
        }
      }

         //Validation for Marketing text
          if (iValidForm)
          {
           var fieldName = "<%=i18nStringNowUtil("emxFramework.Attribute.Marketing_Text", bundle,acceptLanguage)%> ";
           var field = formName.txtProductMarketingText;
           iValidForm = basicValidation(formName,field,fieldName,false,false,false,false,false,false,checkBadChars);
          }

      if (iValidForm)
      {
        //Condition to check Web Availability Option as well as Date Validation
        var fieldSED = formName.txtProductSEDate_msvalue;
        var fieldEED = formName.txtProductEEDate_msvalue;
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
                        msg = "<%=i18nStringNowUtil("emxProduct.Alert.ReleasedAndEffectiveProducts",bundle,acceptLanguage)%>";
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
            msg = "<%=i18nStringNowUtil("emxProduct.Alert.EmptyStartEffectivity",bundle,acceptLanguage)%>";
            alert(msg);
            iValidForm = false;
        }
        else if(trimWhitespace(fieldEED.value) == '')
        {
            //Condition Check when only End Effectivity is not entered. End Effectivity is also needed.
            msg = "<%=i18nStringNowUtil("emxProduct.Alert.EmptyEndEffectivity",bundle,acceptLanguage)%>";
            alert(msg);
            iValidForm = false;
        }
        else
        {
           // var strSED = new Date(fieldSED.value);
           // var strEED = new Date(fieldEED.value);
            if (fieldSED.value > fieldEED.value)
            {
                //Condition check when Start Effectivity Date is after End Effectivity Date. It should be before the End Effectivity //Date
                msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidEffectivityDateEntry",bundle,acceptLanguage)%>";
                alert(msg);
                iValidForm = false;
            }

        }

      }
	if(iValidForm)
   	{
   	    var fieldName = "<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefix", bundle,acceptLanguage)%> ";
        var field = formName.txtModelPrefix;
        //Added code for Mx376215
        var isModelPrefixRequired = "<xss:encodeForJavaScript><%=strModelPrefixVal%></xss:encodeForJavaScript>";
        var isPrefixRequired = false;
        if(isModelPrefixRequired == "true"){
	        isPrefixRequired = true;
        }
        //End - Mx376215
        iValidForm = basicValidation(formName,field,fieldName,isPrefixRequired,false,false,false,false,false,false);
        if(iValidForm)
        {
	   	  iValidForm = checkModelPrefix();
	   	}
   	}

      //If validation fails
      if (!iValidForm)
      {
        return ;
      }
      formName.action="../productline/ProductUtil.jsp?mode=createProduct&PRCFSParam2=<%=XSSUtil.encodeForURL(context,PRCFSParam2)%>";
      //Capturing mouse events before submitting the form
      //If validation passes
      formName.target = "jpcharfooter";
      //To display the Progress clock
      //nextgenui
     
      if (jsDblClick()) {
        formName.submit();
      }
    }


    function showTypeSelector()
    {

      //This function is for popping the Type chooser.
      //The value chosen by the type chooser is returned to the corresponding field.

      var field = formName.txtProductType.name;
      var fieldActual = formName.txtProductActualType.name;
      showChooser("../common/emxTypeChooser.jsp?fieldNameDisplay="+field+"&fieldNameActual="+fieldActual+"&formName=ProductCreate&SelectType=single&SelectAbstractTypes=false&InclusionList=<%=XSSUtil.encodeForURL(context,strInclusionType)%>&ObserveHidden=true&SuiteKey=eServiceSuiteProductLine&ShowIcons=true",500,400);

    }


    function showDesignResponsibilitySelector()
    {
      var sURL=
	"../common/emxFullSearch.jsp?field=TYPES=type_Organization,type_ProjectSpace&table=PLCDesignResponsibilitySearchTable&selection=single&formName=ProductCreate&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../productline/SearchUtil.jsp?&mode=Chooser&chooserType=FormChooser&fieldNameActual=txtDRId&fieldNameDisplay=txtProductDesResp";
      showChooser(sURL, 850, 630)
    }


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

		var objForm = document.forms["ProductCreate"];
		
		var hiddenElement = objForm.elements["txtProductOwner"];
		var displayElement = objForm.elements["txtProductOwnerId"];

		for (var i = 0; i < arrSelectedObjects.length; i++) 
		{ 
			var objSelection = arrSelectedObjects[i];
			hiddenElement.value = objSelection.name;
			displayElement.value = objSelection.name;
			break;

      }
}
    function showCompanySelector()
    {


  var objCommonAutonomySearch = new emxCommonAutonomySearch();
//Commented for BugNo 359712  Start
	   //objCommonAutonomySearch.txtType = "type_Organization";
	   objCommonAutonomySearch.txtType = "type_Company";
//Changes for BugNo 359712 End
	   objCommonAutonomySearch.selection = "single";
	   objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchCompany"; 
	   objCommonAutonomySearch.open();
    }
function submitAutonomySearchCompany(arrSelectedObjects) 
	{

		var objForm = document.forms["ProductCreate"];
		
		var hiddenElement = objForm.elements["txtCompanyId"];
		var displayElement = objForm.elements["txtProductCompany"];

		for (var i = 0; i < arrSelectedObjects.length; i++) 
		{ 
			var objSelection = arrSelectedObjects[i];
			hiddenElement.value = objSelection.objectId;
			displayElement.value = objSelection.name;
			break;
 
      }
    }

    // Replace vault dropdown box with vault chooser.
    var txtVault = null;
    var bVaultMultiSelect = false;
    var strTxtVault = "document.forms['ProductCreate'].txtProductVault";
    function showVaultSelector()
    {
      //This function is for popping the Vault chooser.
      txtVault = eval(strTxtVault);
showChooser('../common/emxVaultChooser.jsp?fieldNameActual=txtProductVault&fieldNameDisplay=txtProductVaultDisplay&incCollPartners=false&multiSelect=false');
    }
    
function checkPrefix()
{

	//Added for Mx376215
 	var isPrefixValRequired = "<xss:encodeForJavaScript><%=strModelPrefixVal%></xss:encodeForJavaScript>";
     if(isPrefixValRequired == "false") {
     	bAllowSubmit = true;  
		return true;
     }
     //End - Mx376215
     var inputStr = document.ProductCreate.txtModelPrefix.value;
     if(inputStr==null || inputStr=="")
     {
    	   return false;
    	    bAllowSubmit = false;
     }
	var url="BuildUtil.jsp?mode=checkModelPrefix&inputStr="+inputStr+"&productId=null";
	
	var resText = emxUICore.getData(url);	
	
	if(resText.search(/validationMsg=true/) == -1)
	{			
		alert("<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixNotAvailable",bundle,acceptLanguage)%>");
		document.ProductCreate.txtModelPrefix.value = "";
		 bAllowSubmit = false;				
		return false;
	}
	bAllowSubmit = true;
	return true;

}

    
function validatePrefix()
{
	var inputStr = document.ProductCreate.txtModelPrefix.value;
	//For issue 359806 start

	document.ProductCreate.txtModelPrefix.value = inputStr.toUpperCase();
	
	//For issue 359806 End

	  var returnVal = checkModelPrefix();

		if( returnVal == true && inputStr!=null && inputStr!="")
	    {
			   checkPrefix();
	    }	
}

   var strModelId = "";
   var strObjectId = "<%=XSSUtil.encodeForJavaScript(context,objectId)%>";

    //Code to set focus on the first editable field based on Autonamer check option.
    var strAutoNamer = document.ProductCreate.strAutoNamer.value;

    // Begin of Modify by Enovia MatrixOne for Bug # 300769 Date 03/29/2005
    //IR-061274V6R2011x - BEGIN  
    if(strObjectId !=""){
     strModelId = document.ProductCreate.txtModelId.value;
   }
    //IR-061274V6R2011x - END 
    if((strAutoNamer == "False" || strAutoNamer == "" ) && strModelId == "")
    // End of Modify by Enovia MatrixOne for Bug # 300769 Date 03/29/2005
    {
        document.ProductCreate.txtName.focus();
    }
    else
    {
      document.ProductCreate.txtRevision.focus();
    }

    //This file contains the function to update the marketing name
    <%@include file = "./emxUpdateMarketingNameInclude.inc" %>

    //]]>
    </script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
