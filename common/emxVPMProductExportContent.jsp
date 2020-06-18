<%--  emxVPMProductExportContent.jsp   -   Export VPLM Product by taking Part Number as input
                                       
   Copyright (c) 1992-2002 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
    emxVPMProductExportFS.jsp
     - emxVPMProductExportContent.jsp
       - emxVPMProductExportProcessing.jsp

    RCI - Wk13 2010 - Creation
--%>

<%@ page
	import="java.util.*,com.matrixone.vplmintegrationitf.util.*,com.matrixone.vplmintegration.util.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.framework.taglib.*,matrix.db.*"%>

<%@page  import="com.matrixone.apps.domain.util.i18nNow"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

 
<%
    	String lang = (String)context.getSession().getLanguage();
%>

<HTML>

<HEAD>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<!--   Functions descriptions -->
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">    
    function checkInput()
    {	   
        var strValue = document.editForm.PLM_ExternalID.value;
        if ( "" == strValue ) {
            alert("<%=i18nNow.getI18nString("emxVPMExportProduct.Command.CreateProduct.Warning.MandatoryAttr","emxVPLMWebMgtStringResource",context.getSession().getLanguage())%>");
        }
        else {
            document.editForm.submit();
        } 
    }

 </SCRIPT>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>
</HEAD>

<BODY>

<!--   Acting jsp -->
<emxUtil:localize id="i18nId" bundle="emxVPLMWebMgtStringResource" locale='<%=request.getHeader("Accept-Language")%>' />
<FORM NAME="editForm" ID="exportProduct" METHOD="post" ACTION="emxVPMProductExportProcessing.jsp" target=_parent>

<!--   Atributes Display -->
<%
 String NLSExternalPLMID  = i18nNow.getI18nString("PLM_ExternalID", "emxVPLMWebMgtStringResource",lang);
 String sNameAttrValue="";
%>            

<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="2" WIDTH="100%">
 	<tr>
      	<td class="labelrequired" width="200"><%=NLSExternalPLMID%></td>
            <td class="inputField"><input type="text" size="30" name="PLM_ExternalID" value="<%=sNameAttrValue%>" onFocus="" /></td>
      </tr>
</table>
</form>
</BODY>
</HTML>


<%@include file="../emxUICommonEndOfPageInclude.inc"%>
