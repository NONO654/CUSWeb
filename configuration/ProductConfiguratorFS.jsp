<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProductVariables.inc"%>
<%@include file="../common/emxCompCommonUtilAppInclude.inc"%>
<%@ page import="java.net.URLDecoder"%>
<%@ page import="java.net.URLEncoder"%>


<script src="../webapps/ConfiguratorWebClient/ConfiguratorWebClient.js" type="text/javascript"></script> 
<%		

String appendParams = emxGetQueryString(request);
String contextId = emxGetParameter(request,"contextId");
String strAction = emxGetParameter(request,"strAction");
String pcId = emxGetParameter(request, "pcId");
String txtParentFrameUrl = emxGetParameter(request,"txtParentFrameUrl");
String fromPCComparePage = emxGetParameter(request,"fromPCComparePage");

        String strHelpMarker = "emxhelpproductconfigurationcreate";
        if("true".equals(fromPCComparePage)){
    		strHelpMarker = "false";     	
        }
		String strFooterURL = "ProductConfigurationFooter.jsp?" + appendParams;
		String strBodyURL = "../webapps/ConfiguratorWebClient/ConfigurationCLV.html?hideToolbar=true&"+ appendParams;
		   	 	
		String strHeaderSelectOptions 	="emxProduct.Heading.ProductConfigurationFlatViewContentFSDialog";
		String strHeaderView 	="emxConfiguration.Heading.ViewProductConfiguration";
   	  	String Directory = (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteConfiguration.Directory");

 		if(txtParentFrameUrl != null && txtParentFrameUrl.length() != 0) {
 			txtParentFrameUrl = URLEncoder.encode(txtParentFrameUrl, "UTF-8");
   	  		Cookie parentFrameUrlCookie = new Cookie("DS_ConfiguratorCookie_parentFremeUrl",txtParentFrameUrl);
   	  		parentFrameUrlCookie.setMaxAge(60*30);
   	  		response.addCookie(parentFrameUrlCookie);
   	  	} else {
   	  		Cookie [] cookies = request.getCookies();
	   	   	if( cookies != null ){
	   	      for (int i = 0; i < cookies.length; i++){
	   	    	Cookie cookie = cookies[i];
	   	         if((cookie.getName()).equals("DS_ConfiguratorCookie_parentFremeUrl")){
	   	        	txtParentFrameUrl = cookie.getValue();
	   	        	break;
	   	         }
	   	      }
	   	   	}
   	  	}

 		if(txtParentFrameUrl != null && txtParentFrameUrl.length() != 0) {
 			txtParentFrameUrl = URLDecoder.decode(txtParentFrameUrl, "UTF-8");
 		}
 		
      	framesetObject fs = new framesetObject();
      	fs.setDirectory(Directory);
      	if(pcId == null) {
      	fs.setObjectId(contextId);
      	}else {
      		fs.setObjectId(pcId);
      	}
      	fs.setStringResourceFile("emxConfigurationStringResource");

      	if(!"view".equalsIgnoreCase(strAction))
		{
      		if("create".equalsIgnoreCase(strAction))
      			fs.setToolbar("FTRProductConfigurationPageHelpToolBar");
      		else
      			fs.setToolbar("FTRProductConfigurationPageViewToolBar");
          	/* fs.initFrameset(strHeaderSelectOptions,
            		strHelpMarker,
            		strBodyURL,
                    false,
                    true,
                    false,
                    false); */
            fs.initFrameset("",
            		strHelpMarker,
            		strBodyURL,
                    false,
                    true,
                    false,
                    false);

      		fs.createFooterLink("emxProduct.Button.Done",
                "createUpdateProductConfiguration('"+txtParentFrameUrl+"')",
                "role_GlobalUser",
                false,
                true,
                "common/images/buttonDialogDone.gif",
                0);

          	fs.createFooterLink("emxProduct.Button.Cancel",
                    "cancelAction('"+txtParentFrameUrl+"')",
                    "role_GlobalUser",
                    false,
                    true,
                    "common/images/buttonDialogCancel.gif",
                    0);
		}else
		{
			fs.setToolbar("FTRProductConfigurationPageEditToolBar");
          	/* fs.initFrameset(strHeaderView,
            		strHelpMarker,
            		strBodyURL,
                    false,
                    true,
                    false,
                    false); */
	        
			fs.initFrameset("",
            		strHelpMarker,
            		strBodyURL,
                    false,
                    true,
                    false,
                    false);
		}

       
        fs.writePage(out);
%>  

