<%-- emxCommonDocumentCheckinAppletDialogFS.jsp - used for Checkin of file into Document Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   emxCommonDocumentMultiFileUploadFS.jsp
   static const char RCSID[] = "$Id: emxCommonDocumentCheckinAppletDialogFS.jsp.rca 1.20 Wed Oct 22 16:17:50 2008 przemek Experimental przemek $"
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@ page import = "com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<html> <head>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script> 
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
  Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");

  if(emxCommonDocumentCheckinData == null)
  {
    emxCommonDocumentCheckinData = new HashMap();
  }

  Enumeration enumParam = request.getParameterNames();

  // Loop through the request elements and
  // stuff into emxCommonDocumentCheckinData
  while (enumParam.hasMoreElements())
  {
      String name  = (String) enumParam.nextElement();
      String value = emxGetParameter(request,name); //request.getParameter(name);
      emxCommonDocumentCheckinData.put(name, value);
  }

  String documentType = (String) emxCommonDocumentCheckinData.get("realType");
  String objectId = (String) emxCommonDocumentCheckinData.get("objectId");

  if(documentType == null)
  {
      documentType = CommonDocument.TYPE_DOCUMENT;
  }
  emxCommonDocumentCheckinData.put("type", documentType);

  // put the document attribute values into formBean
  // since JPO expects the attributes in a map, stuff the formBean with attribute map
  // get the list of Attribute names
  MapList attributeMapList = mxType.getAttributes( context, documentType);

  Iterator i = attributeMapList.iterator();
  String attributeName = null;
  String attrValue = "";
  String attrType = "";
  double tz = Double.parseDouble((String) session.getAttribute ( "timeZone" ));
  Map attributeMap = new HashMap();
  while(i.hasNext())
  {
      Map attrMap = (Map)i.next();
      attributeName = (String)attrMap.get("name");
      attrValue = (String) emxCommonDocumentCheckinData.get(attributeName);
      attrType = (String)attrMap.get("type");
      if ( attrValue != null && !"".equals(attrValue) && !"null".equals(attrValue) )
      {
          if("timestamp".equals(attrType))
          {
             attrValue = eMatrixDateFormat.getFormattedInputDate(context, attrValue, tz,request.getLocale());
          }
          attributeMap.put( attributeName, attrValue);
      }
  }
  String accessType = (String)emxCommonDocumentCheckinData.get("AccessType");
  String accessAttrStr = PropertyUtil.getSchemaProperty(context, "attribute_AccessType");
  if ( accessType != null && !"".equals(accessType) && !"null".equals(accessType))
  {
      attributeMap.put( accessAttrStr, accessType);
  }

  // stuff the formBean with attribute map
  emxCommonDocumentCheckinData.put( "attributeMap", attributeMap);
  String objectAction = (String)emxCommonDocumentCheckinData.get("objectAction");

  if (  objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_CHECKIN_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ZIP_TAR_GZ) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ON_DEMAND))
    {
      emxCommonDocumentCheckinData.put("showFormat", "false");
      String[] args = JPO.packArgs(emxCommonDocumentCheckinData);
      String jpoName = (String)emxCommonDocumentCheckinData.get("JPOName");
      String methodName = (String)emxCommonDocumentCheckinData.get("vcMethodName");
      if ( "".equals(objectId) || "null".equals(objectId) )
      {
        objectId = null;
      }
      if (jpoName == null || "".equals(jpoName) || "null".equals(jpoName) )
      {
        jpoName = "emxVCDocument";
      }
      if (methodName == null || "".equals(methodName) || "null".equals(methodName) )
      {
        methodName = "vcDocumentConnectCheckin";
      }
      FrameworkUtil.validateMethodBeforeInvoke(context, jpoName, methodName, "Program");
      Map objectMap = (Map)JPO.invoke(context, jpoName, null, methodName, args, Map.class);
      objectId = (String)objectMap.get("objectId");
      emxCommonDocumentCheckinData.put( "objectId", objectId);
  }

  String actionCommand = null;
  boolean isVersionable = true;

  if ( documentType != null && !"".equals(documentType) && !"null".equals(documentType) )
  {
      if( CommonDocument.TYPE_DOCUMENTS.equals(CommonDocument.getParentType(context, documentType)) )
      {
        CommonDocumentable commonDocument = (CommonDocumentable)DomainObject.newInstance(context,documentType);
        actionCommand = commonDocument.getCheckinCommand(context);
        if ( (objectId != null && !"".equals(objectId) && !"null".equals(objectId)) )
        {
            isVersionable = CommonDocument.allowFileVersioning(context, objectId);
        } else {
            isVersionable = CommonDocument.checkVersionableType(context, documentType);
        }
      } else {
          isVersionable = false;
      }
  }

  if( !isVersionable )
  {
      emxCommonDocumentCheckinData.put("isVersionable", Boolean.valueOf(isVersionable));
      emxCommonDocumentCheckinData.put("showComments", "false");
  }
  if ( !isVersionable && !CommonDocument.OBJECT_ACTION_CHECKIN_WITHOUT_VERSION.equals(objectAction) && !"image".equalsIgnoreCase(objectAction) )
  {
      emxCommonDocumentCheckinData.put("objectAction", CommonDocument.OBJECT_ACTION_CREATE_CHECKIN);
  }
      if ( actionCommand != null )
      {
          Map commandMap  = UICache.getCommand(context, actionCommand);
          String actionURL = UIMenu.getHRef(commandMap);
%>
          <form name="integration" action="<%=XSSUtil.encodeForHTML(context, actionURL)%>" >
            <table>
<%
          java.util.Set set = emxCommonDocumentCheckinData.keySet();
          Iterator itr = set.iterator();
          // Loop through the request elements and
          // stuff into emxCommonDocumentCheckinData
          while (itr.hasNext())
          {
              String name  = (String) itr.next();
              Object value = (Object)emxCommonDocumentCheckinData.get(name);
%>
              <input type="hidden" name="<xss:encodeForHTMLAttribute><%=name%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=value%></xss:encodeForHTMLAttribute>" />
<%
          }
%>
            </table>
          </form>
          <script language="javascript">
            document.integration.submit();
          </script>
     </head>
     </html>
<%
  } else {

  String charset = com.matrixone.apps.framework.ui.UINavigatorUtil.getCheckinEncoding(context, request);
%>
<script language="javascript">
function detectJavaPlugin(jdkvers){
  var searchStr1 = "java";
  var searchStr2 = "plug";

  numPlugins = navigator.plugins.length;

  for (i = 0; i < numPlugins; i++)
  {
    // get the name of the plug in typically it is Java Plug-In
    pname = navigator.plugins[i].name;
    pname = pname.toLowerCase();

    // get the description of the plug in typically this contains version infomation
    // like for example "Java Plug-in 1.4.2 for Netscape Navigator"
    pdes = navigator.plugins[i].description;
    pdes = pdes.toLowerCase();

    if (pname.indexOf(searchStr1) > -1 && pname.indexOf(searchStr2) > -1)
    {
		var jdkversArray = jdkvers.split(",");
		for(var j=0; j<jdkversArray.length; j++)
		{
	        //found java plug-in now test for version
    	    if (pdes.indexOf(jdkversArray[j]) > -1 || pname.indexOf(jdkversArray[j]) > -1)
        	{
	          //return true if required java plug-in version found.
	          return true;
        	}
		}
    }
  }
  return false;
 }

<%
  // Detect the Client OS, if Unix falvor check the java plug-in version 
  // if not redirect to HTML version of file upload
  // because of limitation we have redirecting to Plug-in download page with modal dialogs on Unix Clients
  String userAgent = request.getHeader("User-Agent");

  userAgent = userAgent.toLowerCase();
  String checkJavaPlugIn = userAgent.indexOf("x11")   != -1 ? EnoviaResourceBundle.getProperty(context,"emxFramework.x11.Applet.RequiredJavaPlugIn") :
			        	   userAgent.indexOf("hp-ux") != -1 ? EnoviaResourceBundle.getProperty(context,"emxFramework.hpux.Applet.RequiredJavaPlugIn") :
 	                       userAgent.indexOf("sunos") != -1 ? EnoviaResourceBundle.getProperty(context,"emxFramework.sunos.Applet.RequiredJavaPlugIn") :	"";		            
  checkJavaPlugIn = checkJavaPlugIn.trim();	                       
  if(!checkJavaPlugIn.equals(""))
  {
%>
//XSSOK
    if(!detectJavaPlugin('<%=checkJavaPlugIn%>'))
   {
     document.location.href="emxCommonDocumentCheckinDialogFS.jsp?plugInNotFoundAlert=true";
   }
<%
  }
  // Detecting the content type encoding if it is not UTF8 or UTF-8 then Applet is having problem with
  //    double byte file name so forwording to the html version of the Checkin.
  String encoding = request.getCharacterEncoding();
  if( encoding == null )
  {
    encoding = "UTF-8";
  }
%>
</script>
 </head>
 <frameset rows="78,*,1,40" frameborder="no" framespacing="0">
  <frame name="checkinTopFrame"    src="emxCommonDocumentCheckinTop.jsp"  marginwidth="10" marginheight="10" frameborder="no" scrolling="no" />
  <frame name="checkinFrame"       src="emxCommonDocumentCheckinAppletDialog.jsp" marginwidth="0" marginheight="0" frameborder="no" scrolling="no" />
  <frame name="checkinHiddenFrame" src="emxCommonDocumentCheckinAppletHiddenDialog.jsp" marginwidth="0" marginheight="0" frameborder="no" scrolling="no" />
  <frame name="checkinBottomFrame" src="emxCommonDocumentCheckinBottom.jsp" marginwidth="10" marginheight="5" frameborder="no" scrolling="no" />
</frameset>
</html>
<%
}
%>

