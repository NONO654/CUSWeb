<%-- emxSearchGetContainedInObjectInfo.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchGetContainedInObjectInfo.jsp.rca 1.1.5.4 Wed Oct 22 15:48:39 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%

  String containedInObjId = emxGetParameter(request,"objectId");
  String languageStr = request.getHeader("Accept-Language");
  String sType = emxGetParameter(request,"type");
  String sName = emxGetParameter(request,"name");
  String sRev =  emxGetParameter(request,"revision");
  sType = i18nNow.getTypeI18NString(sType, languageStr);
%>
<div id="formLayerBorder" class="formLayerBorder">
<div id="formLayer" class="formLayer">
<div id="formLabelBorder" class="formLabelBorder">
<div class="formLabel" id="formLabel">
					<table id ="tblHeader" width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td class="formLabel" width="70%">
								<emxUtil:i18n localize="i18nId">emxFramework.ContainedInInfoDiv.Header</emxUtil:i18n>
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

	<table border="0" cellpadding="0" cellspacing="0" width="100%" >

			<tr>
			  <td width="30%" class="containedInLabel" ><emxUtil:i18n localize="i18nId">emxFramework.Common.Type</emxUtil:i18n>:</td>
			  <td width="70%" ><xss:encodeForHTML><%=sType%></xss:encodeForHTML></td>
			</tr>
			<tr>
			  <td width="30%" class="containedInLabel"><emxUtil:i18n localize="i18nId">emxFramework.Common.Name</emxUtil:i18n>:</td>
			  <td width="70%" ><xss:encodeForHTML><%=sName!=null?sName:""%></xss:encodeForHTML></td>
			</tr>
			<tr>
			  <td width="30%" class="containedInLabel"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Revision</emxUtil:i18n>:</td>
			  <td width="70%" ><xss:encodeForHTML><%=sRev!=null?sRev:""%></xss:encodeForHTML></td>
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
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
