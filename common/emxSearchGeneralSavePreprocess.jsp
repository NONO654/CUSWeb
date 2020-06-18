
<%-- emxSearchGeneralSavePreprocess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchGeneralSavePreprocess.jsp.rca 1.8 Wed Oct 22 15:48:31 2008 przemek Experimental przemek $
--%>
                 
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<html>
<head>
<%@include file = "emxUIConstantsInclude.inc"%>
</head>

<body>
<%

String[] values = null;
StringBuffer bufParams = new StringBuffer(100);
String mxLink = emxGetParameter(request,"mxLink");
if("true".equals(mxLink)) {
    for(Enumeration names = emxGetParameterNames(request);names.hasMoreElements();)
    {
      String name = (String) names.nextElement();
      values = emxGetParameterValues(request, name);
      
      if(values != null && values.length > 0) {
          if (!((name.startsWith("comboDescriptor_") || name.startsWith("txt_")) && (values[0] == null || "".equals(values[0].trim()) || "*".equals(values[0])))) {
              bufParams.append(XSSUtil.encodeForURL(context,name));
              bufParams.append("=");
              bufParams.append(XSSUtil.encodeForURL(context, values[0])	);
              bufParams.append("&");
          }
      }
    }
}

  
//get request parameters
String txtTypeActual = emxGetParameter(request,"txtTypeActual");
String containedInFlag=emxGetParameter(request, "containedInFlag");
if (containedInFlag==null|| "null".equals(containedInFlag)||"".equals(containedInFlag))
{
    containedInFlag="true";
}
boolean blnSearch = true;
//txtTypeActual.length() has to be less than 256 to store in PersonUtil
if(txtTypeActual != null && !"".equals(txtTypeActual) && !"null".equals(txtTypeActual) && txtTypeActual.length() < 256)
{
    //save the last searched types from general search
    try 
    {
        ContextUtil.startTransaction(context, true);
        if("true".equals(containedInFlag)) {
            PersonUtil.setLastContainedInSearchedTypePreference(context, txtTypeActual);
        }else {
            PersonUtil.setLastSearchedTypePreference(context, txtTypeActual);
        }
        ContextUtil.commitTransaction(context);

    }
    catch(Exception ex)
    {
        blnSearch = false;
        ContextUtil.abortTransaction(context);
        if(ex.toString() != null && (ex.toString().trim()).length()>0)
        {
            emxNavErrorObject.addMessage("emxSearch:" + ex.toString().trim());
        }
        
    } finally {
    ContextUtil.commitTransaction(context);
    }
}
if(blnSearch){
    %>

      

<script language="JavaScript" type="text/javascript">

        var genFrame = findFrame(getTopWindow(), "searchContent");
        
        //get the form
        var theForm = genFrame.document.forms[0];

        //set form target
        theForm.target = "searchView";
 
        // If the page need to do some pre-processing before displaying the results
        // Use the "searchHidden" frame for target
        // theForm.target = "searchHidden";
       // added for the MxLink	
        //XSSOK
        theForm.action = "emxIndentedTable.jsp?<%=bufParams.toString()%>";
        theForm.submit();

</script>

    
    <%
}else{
%>
<script language="JavaScript" type="text/javascript">findFrame(getTopWindow(),"searchHead").turnOffProgress();</script>
<%  
}
%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

