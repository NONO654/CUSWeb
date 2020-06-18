<%--  emxVPMProductCreateType.jsp   -   Creates VPLM Product by taking Part Number as input
                                       
   Copyright (c) 1992-2002 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
    RCI - Dec 2009 - 1st delivery. "Type Chooser" not activate while no MASK offer exists. Limited to creation of VPLMtyp/PLMProductDS
    RCI - Jan 2010 - Commentary + Attribute order fixed as the one described in PLMProductDS.mask file + usage of V_description valuation
--%>

<%@ page
	import="java.util.*,com.matrixone.vplmintegrationitf.util.*,com.matrixone.vplmintegration.util.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.framework.taglib.*,matrix.db.*,com.matrixone.vplm.m1mapping.*"%>

<%@ page import = "java.util.Set" %>
<%@ page import = "java.util.List" %>
<%@ page import = "java.text.DateFormat" %>
<%@ page import = "java.util.ArrayList" %>
 
<%@page  import="com.matrixone.apps.domain.util.i18nNow"%>
<%@include file  =  "../components/emxCalendarInclude.inc"  %> 
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%@ page import = "com.dassault_systemes.vplmpublicdictionaryitf.IVPLMPublicDictionary"%>
<%@ page import = "com.dassault_systemes.vplmpublicdictionaryitf.IVPLMPublicDictionaryType"%>
<%@ page import = "com.dassault_systemes.vplmpublicdictionaryitf.IVPLMPublicDictionaryAttribute"%>
<%@ page import = "com.dassault_systemes.vplmpublicdictionaryitf.VPLMPublicDictionaryFactory"%>
  
<%

	String languageStr = request.getHeader("Accept-Language");
    String paramRole = (String) session.getAttribute("role");
    
 	String type;
	String sDefaultType;

    //MUT R217 NameMappingRemoval Migration
    if(com.matrixone.vplm.m1mapping.MappingManager.nameMapping())
    // old names
    {
     	type          = "VPLMtyp/PLMProductDS";
	    sDefaultType  = "VPLMtyp/PLMProductDS";
    }
    else
    // new names
    {
        type          = "PLMProductDS";
	    sDefaultType  = "PLMProductDS";
    }
    //MUT R217 NameMappingRemoval Migration


	String sTypeSelected = emxGetParameter(request, "type");
	String TypeSelected  = "";
	String isTypeChange  = emxGetParameter(request, "isTypeChange");
	
	//in case of type change
	if (isTypeChange == null || isTypeChange.equals("null") || !isTypeChange.equalsIgnoreCase("true"))
	{
		sTypeSelected = type;
	}

    String failed = emxGetParameter(request,"failed");
    if(failed==null || "null".equals(failed)){failed="";}
    
    String prevmode  = emxGetParameter(request,"prevmode");
    if(prevmode==null || "null".equals(prevmode)){prevmode=""; }
    
    String reloadPage  = emxGetParameter(request,"reloadPage");
    if(reloadPage==null || "null".equals(reloadPage)){reloadPage="";}

%>

<HTML>
<HEAD>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>  
<SCRIPT LANGUAGE="JavaScript" SRC="scripts/emxUIConstants.js"	TYPE="text/javascript"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="scripts/emxUIModal.js" 	TYPE="text/javascript"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="scripts/emxUIPopups.js" 	TYPE="text/javascript"></SCRIPT>
<SCRIPT TYPE="text/javascript">
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIForm");
        </SCRIPT>

<!--   Functions descriptions -->
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">    
    function checkInput()
    {	   
        var strValue = document.editForm.PLM_ExternalID.value;
        if ( "" == strValue ) {
            alert("<%=i18nNow.getI18nString("emxVPMCreateProduct.Command.CreateProduct.Warning.MandatoryAttr","emxVPLMProductEditorStringResource",context.getSession().getLanguage())%>");
        }
        else {
            document.editForm.submit();
        } 
    }

    var txtTypeChange = false;
    var bAbstractSelect = false;

    function showTypeSelector() {
        txtTypeChange = true;
        //var strURL="emxTypeChooser.jsp?fieldNameActual=type&fieldNameDisplay=typeDisp&formName=editForm&ShowIcons=true&InclusionList=<%=java.net.URLEncoder.encode("VPLMtyp/PLMProductDS")%>&ObserveHidden=true&ReloadOpener=true&SelectAbstractTypes="+bAbstractSelect;
        showModalDialog(strURL, 450, 350);
    }
       
        </SCRIPT>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>
</HEAD>



<BODY>

<!--   Acting jsp -->
<emxUtil:localize id="i18nId" bundle="emxVPLMProductEditorStringResource" locale='<%=request.getHeader("Accept-Language")%>' />
<FORM NAME="editForm" ID="createProduct" METHOD="post" ACTION="emxVPMProductCreateProcessing.jsp" target=_parent>

<!--   Error Management -->
<%
    if(failed.equals("1")) {
        // case Name Not Unique
%>
  <TABLE BORDER="0" CELLPADDING="5" CELLSPACING="2" WIDTH="100%">
  <emxUtil:localize id="i18nId" bundle="emxVPLMProductEditorStringResource" locale='<%=request.getHeader("Accept-Language")%>' />
    <tr>
      <td class="requiredNotice" nowrap="" align="center"><i><emxUtil:i18n localize="i18nId">emxVPMCreateProduct.Exception.CreateProduct.NameNotUnique</emxUtil:i18n></i></td>
    </tr>
  <emxUtil:localize id="i18nId" bundle="emxVPLMProductEditorStringResource" locale='<%=request.getHeader("Accept-Language")%>' />
  </TABLE>
<%
    } else if(failed.equals("2")) {
     // case Commit Failed
%>
  <TABLE BORDER="0" CELLPADDING="5" CELLSPACING="2" WIDTH="100%">
  <emxUtil:localize id="i18nId" bundle="emxVPLMProductEditorStringResource" locale='<%=request.getHeader("Accept-Language")%>' />
    <tr>
      <td class="requiredNotice" nowrap="" align="center"><i><emxUtil:i18n localize="i18nId">emxVPMCreateProduct.Exception.CreateProduct.CommitFailed</emxUtil:i18n></i></td>
    </tr>
  <emxUtil:localize id="i18nId" bundle="emxVPLMProductEditorStringResource" locale='<%=request.getHeader("Accept-Language")%>' />
  </TABLE>
<%
    }
%>

<!--   Type Display -->
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="2" WIDTH="100%">
  <tr>
      <td class="labelrequired" width="150" ><emxUtil:i18n localize="i18nId">emxVPMCreateProduct.Product.WebForm.Type.Label</emxUtil:i18n></td>
      <td class="inputField">
<%
		if(prevmode.equals("true") || reloadPage.equals("true")) {
%>
			<input type="hidden" name="type" value="<%=TypeSelected%>" >
			<input type="text" size="20" name="typeDisp" value="<%=i18nNow.getTypeI18NString(TypeSelected,languageStr)%>" readonly="readonly">
<%
		} else {
%>
        <input type="hidden" name="type" value="<%=sDefaultType%>" >
        <input type="text" size="20" name="typeDisp" value="<%=i18nNow.getTypeI18NString(sDefaultType,languageStr)%>" readonly="readonly">
<%
		}
%>
        <input type=button name="" value="..." onClick="Javascript:showTypeSelector()">
	</td>
	</TR>

<!--   Atributes Display -->
<%
   // recuperation des attributs public du type "sTypeForAttr" via le code des dico ( doc dans javadoc de IVPLMPublicDictionary)
   VPLMPublicDictionaryFactory  dicoMgr  =  VPLMPublicDictionaryFactory.createInstance(); 
  if ( null != dicoMgr)
    {
      String sTypeForAttr = sDefaultType.substring(8);
             
      IVPLMPublicDictionary vplmDic = dicoMgr.getDictionary();
      IVPLMPublicDictionaryType vplmDicType = vplmDic.getPublicType(context, sTypeForAttr);
      
      String sNameAttrValue="";
      String sDescAttrValue="";
      String sIndCodeAttrValue="";
      String sStdNbAttrValue="";
      String sSupplierNameAttrValue="";
      String sSubCtrAttrValue ="";
      String sNameAttrNameNls="";
      String sDescAttrNameNls="";
      String sIndCodeAttrNameNls="";
      String sStdNbAttrNameNls="";
      String sSupplierNameAttrNameNls="";
      String sSubCtrAttrNameNls ="";
      String nlsTrueBtnValue = i18nNow.getI18nString("emxVPMCreateProduct.Command.CreateProduct.RadioBtn.True","emxVPLMProductEditorStringResource",context.getSession().getLanguage());
      String nlsFalseBtnValue = i18nNow.getI18nString("emxVPMCreateProduct.Command.CreateProduct.RadioBtn.False","emxVPLMProductEditorStringResource",context.getSession().getLanguage());
 

      while ( null != vplmDicType)
      {
      String sTypeNameNls= vplmDicType.getNLSValue(context);
      IVPLMPublicDictionaryType localType = vplmDicType;
     
      List vplmDicAttributeNames = localType.getPublicAttributeNames(context);
  
   
      for (int k=0;k<vplmDicAttributeNames.size();k++)
      {
         String sAttributeName= (String) vplmDicAttributeNames.get(k);
        
         IVPLMPublicDictionaryAttribute vplmDicAttribute = localType.getPublicAttribute(context, sAttributeName);
         String defaultAttrValue = vplmDicAttribute.getDefaultValue(context);
         String sAttributeNameNls= vplmDicAttribute.getNLSValue(context, vplmDicType);
          
         boolean isMand = vplmDicAttribute.isMandatory(context);
 
         // No Mask management => list of attributes to display described here
         // When masks APIs will be available, use directly attributes values, and display thme in the for ... ( cf code Dec 2009 )
         
        if (sAttributeName.equalsIgnoreCase("PLM_ExternalID")) {
         	sNameAttrNameNls = sAttributeNameNls;
        	sNameAttrValue = defaultAttrValue;
        }
        else if (sAttributeName.equalsIgnoreCase("V_description")) {
         	sDescAttrNameNls = sAttributeNameNls;
        	sDescAttrValue = defaultAttrValue;
        }
        else if (sAttributeName.equalsIgnoreCase("V_IndustryCode")) {
        	sIndCodeAttrNameNls = sAttributeNameNls;
        	sIndCodeAttrValue = defaultAttrValue;
        }
        else if (sAttributeName.equalsIgnoreCase("V_StdNumber")) {
        	sStdNbAttrNameNls = sAttributeNameNls;
        	sStdNbAttrValue = defaultAttrValue;
        }
        else if (sAttributeName.equalsIgnoreCase("V_SupplierName")) {
        	sSupplierNameAttrNameNls = sAttributeNameNls;
        	sSupplierNameAttrValue = defaultAttrValue;
        }
        else if (sAttributeName.equalsIgnoreCase("V_Supplier")) {
          	sSubCtrAttrNameNls = sAttributeNameNls;
        	sSubCtrAttrValue = defaultAttrValue;
        }
        	
      }
      vplmDicType = localType.getBaseType(context);
      }

     	  %>
		<!--  NAME -->
            <tr>
                <td class="labelrequired" width="200"><%=sNameAttrNameNls%></td>
                <td class="inputField"><input type="text" size="30" name="PLM_ExternalID" value="<%=sNameAttrValue%>" onFocus="" /></td>
            </tr>
              
        <!-- DESCRIPTION -->
              <tr>
                 <td class="label" width="200"><%=sDescAttrNameNls%></td>
                  <td class="field"><textarea name="V_description" rows="3" cols="35"></textarea></td>      
              </tr>
    <!-- INDUSTRY CODE -->
             <tr>
                <td class="label" width="200"><%=sIndCodeAttrNameNls%></td>
                <td class="inputField"><input type="text" size="30" name="V_IndustryCode" value="<%=sIndCodeAttrValue%>" onFocus="" /></td>
            </tr>
    <!-- STD NUMBER -->
            <tr>
                <td class="label" width="200"><%=sStdNbAttrNameNls%></td>
                <td class="inputField"><input type="text" size="30" name="V_StdNumber" value="<%=sStdNbAttrValue%>" onFocus="" /></td>
            </tr>
   <!-- SUB CONTRACTED  -->
             <tr>
                <td class="label" nowrap="nowrap" width="150"><%=sSubCtrAttrNameNls%></td>
                <td class="Field">
                  <input type="radio" name="V_Supplier" size="20" value="<%=nlsTrueBtnValue%>" >True
                  <input type="radio" name="V_Supplier" size="20" value="<%=nlsFalseBtnValue%>" checked >False
               </td>
           </tr>
     <!-- SUPPLIER NAME -->
           <tr>
                <td class="label" width="150"><%=sSupplierNameAttrNameNls%></td>
                <td class="inputField">
                    <select name="<%="V_SupplierName"%>">
                        <option value="1">
                           <%=i18nNow.getI18nString("emxVPMCreateProduct.Command.CreateProduct.Enum.Supplier_A","emxVPLMProductEditorStringResource",context.getSession().getLanguage())%>
                        </option>
                        <option value="2">
                           <%=i18nNow.getI18nString("emxVPMCreateProduct.Command.CreateProduct.Enum.Supplier_B","emxVPLMProductEditorStringResource",context.getSession().getLanguage())%>
                        </option>
                        <option value="3">
                           <%=i18nNow.getI18nString("emxVPMCreateProduct.Command.CreateProduct.Enum.Supplier_C","emxVPLMProductEditorStringResource",context.getSession().getLanguage())%>
                        </option>
                    </select>
               </td>
            </tr>
       <%
  

}
   else
    System.out.println("Dico Factory Instance not created");
    
  %>

</table>
</form>
</TABLE>
</BODY>
</HTML>


<%@include file="../emxUICommonEndOfPageInclude.inc"%>
