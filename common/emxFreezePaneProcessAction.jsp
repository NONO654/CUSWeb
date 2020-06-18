<% response.setContentType("text/xml; charset=UTF-8"); %><?xml version="1.0" encoding="UTF-8"?>
<%-- emxFreezePaneProcessAction.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFreezePaneProcessAction.jsp.rca 1.6 Wed Oct 22 15:48:22 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%
String action = "remove";
String msg = "";

  //take all params passed in and draw hidden fields
  Enumeration eNumParameters = emxGetParameterNames(request);
  while( eNumParameters.hasMoreElements() )
  {

    String strParamName = (String)eNumParameters.nextElement();

    // If the parameter contains multiple values, create multiple hidden
    // fields so that all the values are retained
    String strParamValues[] = emxGetParameterValues(request, strParamName);

    if (strParamValues != null)
    {
      for (int iCount=0; iCount<strParamValues.length; iCount++)
      {
        //PROCESS OID|RELID HERE
      }
    }
  }
try
{

    ContextUtil.startTransaction(context, true);
    //int i = 1/0;


} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    action = "error";
    if (ex.toString() != null && (ex.toString().trim()).length() > 0){
        msg = ex.toString().trim();
    }

} finally {
    ContextUtil.commitTransaction(context);
}

//clear the output buffer
out.clear(); %>
<mxRoot>
<action><![CDATA[<%= action %>]]></action>
<message><![CDATA[
    <%= msg %>
]]></message>
</mxRoot>
