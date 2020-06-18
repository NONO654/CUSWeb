  <%-- emxLaunch3DLiveExamine.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@page import="java.util.Map.Entry"%>
<%@page import="java.util.Map"%>

<%@page import="java.lang.reflect.Method"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import = "com.matrixone.apps.plmprovider.*" %>
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />


<!DOCTYPE html>
<html style="height: 100%; overflow: hidden;">
<head>
<script language="JavaScript" src="emxUIImageManager.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>

<SCRIPT LANGUAGE="Javascript">
    document.oncontextmenu = function(){return false;}
    var myViewer = document.getElementById("viewer");
</SCRIPT>

<%
    String objectId     = (String)emxGetParameter(request, "objectId");

    String embedURL     = null;
    String mode         = (String)emxGetParameter(request, "mode");

    if ( mode != null && "fileBased".equals(mode))
    {
        String fileFormat   = (String)emxGetParameter(request, "fileFormat");
        String fileName     = (String)emxGetParameter(request, "fileName");
        embedURL            =  get3DLiveExamineFileURL(context, pageContext, objectId, fileFormat, fileName);
    }
    else
    {
        embedURL= get3DLiveExamineURL(context, request, response, objectId,session);
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript" src="ENOVIA3DLiveExamine.js"></script>
<script language="javascript" src="ENOVIA3DLiveExamineExtension.js"></script>
</head>
<%
 
boolean noViewer = false;
if (objectId != null && !"".equals(objectId.trim()) && !"null".equals(objectId.trim())) {
    try {
        String info = MqlUtil.mqlCommand(context, "print bus $1 select $2 dump $3", objectId, "current.access[read]", "|");
        StringList infoList = FrameworkUtil.split(info, "|");
        if (!"TRUE".equalsIgnoreCase((String)infoList.get(0))) {
            noViewer = true;
        }

    }catch(Exception e){
	noViewer = true;
    }
}

if(noViewer){
    %>
    <body>
        <script type="text/javascript" >
            location.href = "../common/emxTreeNoDisplay.jsp";
        </script>
    </body>
    <%
}else{
    %>
<body class=" slide-in-panel" style = "height: 100%; margin: 0px;">
<div id="divPageBody" name="divPageBody" style="top: 0px;bottom: 200px;width:100%;height:100%;">
	<script language="javascript">
  		createScriptableViewer('divPageBody', 'viewer', '../components', '<%=embedURL%>');//XSSOK
	</script>
  </div>
  
  	<script language="javascript">
  	<%@include file = "../components/emx3DLiveCrossHighlightJavaScript.inc" %>
  	setSelectionCallback('viewer', onSelection );
	</script>
</body>
<%
}
%>
</html>

<%!

    public String get3DLiveExamineFileURL(Context context, PageContext pageContext, String objectId, String fileFormat, String fileName)
    throws Exception
    {
        ArrayList fileList      = new ArrayList();
        BusinessObjectProxy bop = new BusinessObjectProxy(objectId, fileFormat, fileName, false, false);
        fileList.add(bop);
        HashMap imageData       = UINavigatorUtil.getImageData(context, pageContext);
        String[] urls           = com.matrixone.fcs.common.ImageRequestData.getImageURLS(context, fileList, imageData);
        String fileURL          = urls[0];
        fileURL                 = fileURL + "&name=" + fileName;
        return fileURL;
    }
%>

<%!
    public static String get3DLiveExamineURL(Context context, HttpServletRequest request,
            HttpServletResponse response, String objectId,HttpSession session) throws Exception {

            String mcsURL = Framework.getFullClientSideURL(request, response, "");
            // code added for 3DLive Embed
            String embedURLPrefix = "MX1://";
            String embedURL = "";
            String usage        = (String)emxGetParameter(request,"usage");
	        String jsessionId = session.getId();


            DomainObject object = DomainObject.newInstance(context, objectId);
            StringList objectSelects = new StringList(3);
            objectSelects.add(DomainObject.SELECT_TYPE);
            objectSelects.add(DomainObject.SELECT_NAME);
            objectSelects.add(DomainObject.SELECT_REVISION);
            objectSelects.add(DomainObject.SELECT_ID);
            Map objectData = object.getInfo(context,objectSelects);
            String type = (String)objectData.get(DomainObject.SELECT_TYPE);
            objectId= (String)objectData.get(DomainObject.SELECT_ID);
            String symbolicType = FrameworkUtil.getAliasForAdmin(context,"type",type,true);
            String embedHeader = objectData.get(DomainObject.SELECT_TYPE) + "" + objectData.get(DomainObject.SELECT_NAME) + "" + objectData.get(DomainObject.SELECT_REVISION);

            String userName   = context.getUser();
            String userPw     = context.getPassword();
            String ClassID    = PlmProviderUtil.getHashName(symbolicType);
			String pName = userName;
			String serverId = "";
            embedURLPrefix = embedURLPrefix + mcsURL + "?User=";
			Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                   System.out.println("name: "+cookie.getName()+ ", value: "+cookie.getValue());
                   
                   if(cookie.getName().equals("SERVERID")) {
                	   serverId = cookie.getValue();
                   }
                }
            }

			

            try {
                 // get the session ID from generateCBPKey(). To launch 3DVia, send user ID as null
                 // and password as session id . This will eliminate a new context creation.

                 String embed3DLiveSessionID = PlmProviderUtil.generateCBPKey(context);
                 if(embed3DLiveSessionID !=  null  && ! "null".equals(embed3DLiveSessionID) && ! "".equals(embed3DLiveSessionID))
                 {
                     userName = null;
                     userPw   = embed3DLiveSessionID;
                 }
                 else
                 {
                      userName   = urlEncodeWithNoPluses(userName);
                      userPw     = urlEncodeWithNoPluses(userPw);
                 }

                 embedHeader   = urlEncodeWithNoPluses(embedHeader);
                 embedURL = userName + "&Password=" + userPw + "&pname="+pName+"&OID=" + objectId + "&ClassID=" + ClassID + "&name=" + embedHeader;
             	
             	

                 if (object.isKindOf(context, DomainConstants.TYPE_CAD_DRAWING))
                 {
                    // add the Stream parameter with value as file name with extension
                    // this is required for loading 2D files by the 3DVIA viewer
                    String fileName = null;
                    String program = "jpo.plmprovider.NavRepBase";
                    String function = "getFileName";

                    try
                    {
                        HashMap map = new HashMap();
                        map.put("mcsURL", mcsURL);
                        map.put("objectId", objectId);
                        map.put("imageType", "cgm");

                        fileName = (String) JPO.invoke(context, program, null, function, JPO.packArgs(map), String.class);
                        if(fileName != null)
                        {
                            fileName = urlEncodeWithNoPluses(fileName);
                        }
                    }
                    catch (Exception e)
                    {
                        System.out.println("Exception in getting file Name :" + e.getMessage());
                        throw (new JspException(e));
                    }
                    embedURL = embedURL + "&Type=2D&Stream=" + fileName;
                 } else if ( usage != null && "drafting".equals(usage) ) {
                     embedURL = embedURL +".cgm&&Type=2D";
                 }

                 String proxyTicket = "";
                 try {
				 proxyTicket = getProxyTicket(context,request,response);
                 }catch(Exception e ) {                	 
                	 proxyTicket = "";                	 
                 }
             	
             	if(proxyTicket!=null && !proxyTicket.equals("")){
             		embedURL+="&proxyTicket="+proxyTicket;             		
             	}

              	String securityContext = getSecurityContext(context);         	
             	embedURL+="&SecurityContext="+securityContext;           
				              	
				embedURL+="&jsessionid="+jsessionId+"&SERVERID="+serverId;             	

             } catch (UnsupportedEncodingException e) {
             }
             embedURL = embedURLPrefix + embedURL;             
	     
        return embedURL;
    }
%>
<%!
    public static String getSecurityContext(Context context) throws Exception {
    
        String sc = null;        
        sc = context.getRole();
        
        if (sc != null) {
          sc = urlEncodeWithNoPluses(sc);
        }
        return sc;
}
%>

<%!
    public static String getProxyTicket(Context context,HttpServletRequest request,HttpServletResponse response) throws Exception {	
	
	String proxyTicket = null;
	try
	{
	    Class objectTypeArray[] = new Class[2];
	    objectTypeArray[0] = HttpServletRequest.class;
	    objectTypeArray[1] = String.class;
	    Class c = Class.forName("com.dassault_systemes.dspassport.cas.client.proxyticket.CASProxyTicketManager");
	    Object obj = c.newInstance();
	    Method method = c.getMethod("getProxyTicket", objectTypeArray);
	    String appUrl = FrameworkUtil.getMyAppsURL(context, request, response);
	    String serviceURL = appUrl+"/resources/plmprovider/metaData/getMetaInfo?language=en";
	    
	    proxyTicket = (String)method.invoke(obj, request, serviceURL);
	}
	catch (Exception ce)
	{
	  System.out.println("Failed to get Proxy Ticket for 3DLiveExamine client to make REST calls");
	  throw (new Exception(ce.toString()));
        }
        
	return proxyTicket;
}
%>

<%!
    private static String urlEncodeWithNoPluses(String input) throws Exception {

        if(input==null)
            return null;
        String inputEnc = com.matrixone.apps.domain.util.XSSUtil.encodeForURL(input);
        if(inputEnc.indexOf("+") > -1)
        {
            StringBuffer retu = new StringBuffer();
            for(int i=0;i<inputEnc.length();i++){
                if(inputEnc.charAt(i)=='+')
                    retu.append("%20");
                else
                    retu.append(inputEnc.charAt(i));
            }
            return retu.toString();
        }
        return inputEnc;
    }
%>

