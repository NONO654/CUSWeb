<%--    emxObjectCompareAttributeSelectBody.jsp
        Copyright (c) 1992-2018 Dassault Systemes.
        All Rights Reserved.
        This program contains proprietary and trade secret information of MatrixOne,Inc.
        Copyright notice is precautionary only   and does not evidence any actual or intended publication of such program
        static const char RCSID[] = $Id: emxObjectCompareBaseObjectSelectBody.jsp.rca 1.5 Wed Oct 22 15:47:59 2008 przemek Experimental przemek $
--%>

<jsp:useBean id="compare" class="com.matrixone.apps.domain.util.ObjectCompare" scope="session"/>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>


<html>
<head>
<script language="javascript" src="scripts/emxUIConstants.js"></script>
<%@include file = "../emxStyleDefaultInclude.inc"%> 
<%@include file = "../emxStyleListInclude.inc"%> 
<%@include file = "../emxStyleFormInclude.inc"%> 



<script type="text/javascript" language="javascript">
	addStyleSheet("emxUIMenu");
</script>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript" language="javascript" src="../emxUIFilterUtility.js"></script>
<script type="text/javascript" language="javascript" src="../emxUIPageUtility.js"></script>

</head>
<body>

<%
 boolean windowClose = false;
      String baseObjectID = "";
       String currObjectID = "";
       String name="";
       String type="";
       String revision="";
       String description="";
       boolean exist = true;
       boolean previous = false;
       MapList objectMapList = null;
       
       String previousPage = emxGetParameter(request,"previous");

       if (previousPage != null && previousPage.equals("true"))
       {
         previous = true;
         baseObjectID = compare.getBaseObjectID();
       }

        objectMapList = compare.getObjectsDetails();
%>
      
      <script language = "javascript">

      function submit() 
      {
         if( document.objcompbaseobjectselect.baseCompId.length > 1)
         {
             document.objcompbaseobjectselect.action = "emxObjectCompareAttributeSelect.jsp";
             document.objcompbaseobjectselect.submit();
         }
         else
          {
             alert("<emxUtil:i18nScript localize="i18nId">emxFramework.ObjectCompare.SelectMinObjects</emxUtil:i18nScript>");
          }
      }
      </script>


      <form name="objcompbaseobjectselect" id="objcompbaseobjectselect" method="post" target="_top">

       <table class="list" width="100%">
        <tr>

          <th width="5%" style="text-align:center"> </th>
          <th nowrap><emxUtil:i18n localize="i18nId">emxFramework.ObjectCompare.name</emxUtil:i18n></th>
          <th nowrap><emxUtil:i18n localize="i18nId">emxFramework.ObjectCompare.type</emxUtil:i18n></th>
          <th nowrap><emxUtil:i18n localize="i18nId">emxFramework.ObjectCompare.revision</emxUtil:i18n></th>
          <th nowrap><emxUtil:i18n localize="i18nId">emxFramework.ObjectCompare.description</emxUtil:i18n></th>

        </tr>

        <framework:mapListItr mapList="<%= objectMapList %>" mapName="objDetailsMap">
<%
				try
				{
				
        currObjectID  = (String)objDetailsMap.get(DomainConstants.SELECT_ID);

        if (previous)
        {
          if (currObjectID.equals(baseObjectID))
          {
            exist=true;
          }
        }

        name=(String)objDetailsMap.get(DomainObject.SELECT_NAME);
        revision=(String)objDetailsMap.get(DomainObject.SELECT_REVISION);
        type=(String)objDetailsMap.get(DomainObject.SELECT_TYPE);
        description=(String)objDetailsMap.get(DomainObject.SELECT_DESCRIPTION);
        String sDynamicURLEnabled = FrameworkProperties.getProperty(context, "emxFramework.DynamicURLEnabled");
        if(!"false".equals(sDynamicURLEnabled)) {
            description = UINavigatorUtil.formatEmbeddedURL(context, description, false, request.getHeader("Accept-Language"));
        }

        
        if(name.equals("") && revision.equals("revision"))
        {
            					windowClose = true;				
        }
        String desc= description.replaceAll("\n","<br/>");  

%>
            <tr class='<framework:swap id ="1" />'>

                <!-- //XSSOK -->
                <td align="center"><input type="radio" name ="baseCompId" id="baseCompId" value = "<%=currObjectID%>" <%=exist?"checked":""%> /></td>
                <td><xss:encodeForHTML><%=name%></xss:encodeForHTML>&nbsp;</td>
                <td><xss:encodeForHTML><%=i18nNow.getAdminI18NString("Type",type,request.getHeader("Accept-Language"))%></xss:encodeForHTML>&nbsp;</td>
                <td><xss:encodeForHTML><%=revision%></xss:encodeForHTML>&nbsp;</td>
                <td><xss:encodeForHTML><%=desc%></xss:encodeForHTML>&nbsp;</td>

           </tr>
<%
       exist=false;


    }
    catch (Exception ex)
    { 
      if (ex != null &&  ex.toString().trim().equals("java.lang.Exception: 'business object' does not exist"))
      { 
      
					windowClose = true;				
					emxNavErrorObject.addMessage(ex.toString());
       }
       else if (ex.toString()!=null && ex.toString().length()>0) 
       {
             emxNavErrorObject.addMessage(ex.toString());
       } 
    }
%>
  </framework:mapListItr>

   </table>
  </form>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

<%
if(windowClose)
{
%>
<script language = "javascript">
		 alert("<emxUtil:i18nScript localize="i18nId">emxFramework.ObjectCompare.ObjectsDeleted</emxUtil:i18nScript>");
		 getTopWindow().closeWindow();
</script>
<%
}
%>

</body>
</html>
