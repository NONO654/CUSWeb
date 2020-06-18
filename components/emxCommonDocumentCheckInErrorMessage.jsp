<%-- emxCommonDocumentCheckInErrorMessage.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDocumentCheckInErrorMessage.jsp.rca 1.1.7.5 Wed Oct 22 16:18:25 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc" %>
<%
  String errorMessage = emxGetParameter(request,"errorMessage");
  errorMessage = FrameworkUtil.decodeURL(errorMessage,"UTF8");
  String languageStr = request.getHeader("Accept-Language");
%>
<div id="formLayerBorder" class="formLayerBorder">
<div id="formLayer" class="formLayer">
<div id="formLabelBorder" class="formLabelBorder">
<div class="formLabel" id="formLabel">
                    <table id ="tblHeader" width="100%" cellpadding="0" cellspacing="0" border="0">
                        <tr>
                            <td class="formLabel" width="70%">
                                <emxUtil:i18n localize="i18nId">emxComponents.VCDocument.ErrorMessage</emxUtil:i18n>
                            </td>
                            <td width="30%" ><input type="button" name="closebutton" class="buttonClose" onClick="closeDiv();" value="X" /></td>
                    
                        </tr>
                    </table>
                </div>
</div>
<%
  try
  {
%>

    <table id ="tblBody" border="0" cellpadding="0" cellspacing="0" width="100%" >

            <tr>
              <td width="100%" ><%=XSSUtil.encodeForHTML(context, errorMessage)%></td>
            </tr>
    </table>

    <%
     
  }
    catch(Exception e)
    {

        out.println(e);
    }

    %>
</div>
</div>
