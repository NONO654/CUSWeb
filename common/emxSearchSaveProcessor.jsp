<%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers"%>
<%@ page buffer="100kb" autoFlush="false" %>
<%-- emxSearchSaveProcessor.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchSaveProcessor.jsp.rca 1.17.2.1 Fri Nov  7 09:41:53 2008 ds-kvenkanna Experimental $
--%>
<%@ page import="com.matrixone.jdom.*,
                 com.matrixone.jdom.Document,
                 com.matrixone.jdom.input.*,
                 com.matrixone.jdom.output.*" %>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%!

public static String decodeSaveSearchName(String strEncodedSaveSearchName) throws Exception
	{
		StringTokenizer st = new StringTokenizer(strEncodedSaveSearchName,".");
		StringBuffer strbufDecodedSaveSearchName = new StringBuffer(16);
		while(st.hasMoreTokens())
		{
			String strToken = st.nextToken();
			char ch = (char)Integer.parseInt(strToken);
			strbufDecodedSaveSearchName.append(ch);
		}
		return strbufDecodedSaveSearchName.toString();
	}
%>



<%
//get request parameters
String saveType = emxGetParameter(request,"saveType");
String saveName = emxGetParameter(request,"saveName");
String collectionSavedName = emxGetParameter(request,"collectionSavedName");
String strNamePrefix = emxGetParameter(request, "namePrefix");
if (strNamePrefix == null || strNamePrefix.equals("")) {
	strNamePrefix = ".emx";
}

if (saveName != null) {
    saveName = saveName.trim();
}
//
// Search name will come as the unicode values separated by . (dot)
// so form the saved search name from it.
//
saveName = decodeSaveSearchName(saveName);
boolean pRefresh = false;

SAXBuilder builder = new SAXBuilder();
builder.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
builder.setFeature("http://xml.org/sax/features/external-general-entities", false);
builder.setFeature("http://xml.org/sax/features/external-parameter-entities", false);

StringWriter sw = new StringWriter();

//close window or refresh?
boolean bCloseWindow = false;
boolean bRefreshWindow = false;

try
{
	if(collectionSavedName == null){
	//create DOM with incoming XML stream
	Document doc = builder.build(new java.io.BufferedInputStream(request.getInputStream()));
	XMLOutputter outputter = MxXMLUtils.getOutputter();

	//string writer to hold XML string
	outputter.output(doc, sw);
	}else {
		collectionSavedName = decodeSaveSearchName(collectionSavedName);
		pRefresh = true;
		String result = MqlUtil.mqlCommand(context, "list query $1 select $2 dump",collectionSavedName,"description");
		sw.append(XSSUtil.decodeFromURL(result));
	}
	
	boolean isIE = EnoviaBrowserUtility.is(request,Browsers.IE);

	boolean isUTF8Encoding = "UTF-8".equalsIgnoreCase(request.getCharacterEncoding()) || "UTF8".equalsIgnoreCase(request.getCharacterEncoding());

	if (!isIE && !isUTF8Encoding)
	{
		//only if encoding not UTF-8 and non IE browser
		saveName = FrameworkUtil.decodeURL(saveName,Framework.getCharacterEncoding(request)); 
	}
	
		boolean isAlreadyExist = false;
		//Corrected spelling of Language for bug 367272 for save alert to work in other languages
		String strLanguage         = request.getHeader("Accept-Language");
		
		String strAlreadyExistsMessage = i18nNow.getI18nString( "emxFramework.SavedSearch.AlreadyExistsMsg", "emxFrameworkStringResource", 	
												   strLanguage);

	
	

	//perform save, update or delete based on saveType

    ContextUtil.startTransaction(context, true);
    if(saveType.equals("save")){
			String sName = strNamePrefix + saveName;
			String strResult  = MqlUtil.mqlCommand(context, "list query $1 select $2",sName,"id");
			if (strResult != null && strResult.length() > 0)
			{
				isAlreadyExist = true;
			}

			if (isAlreadyExist)
			{
					throw new Exception(strAlreadyExistsMessage + "\n" + saveName);
			}

    		UISearch.saveSearch(context, strNamePrefix + saveName, FrameworkUtil.encodeURL(sw.toString(), "UTF-8"));
  		
    }else if(saveType.equals("update")){
        UISearch.updateSearch(context, strNamePrefix + saveName, FrameworkUtil.encodeURL(sw.toString(), "UTF-8"));
    }else if(saveType.equals("delete")){
        UISearch.deleteSearch(context, saveName);
        bRefreshWindow = true;
    }else{
    //do something
    }

//if not refreshing the window then close it
bCloseWindow = !bRefreshWindow;

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);

	if (ex.toString() != null && (ex.toString().trim()).length() > 0)
	{
            	emxNavErrorObject.addMessage(ex.getMessage());
				
	}
	
} finally {
    ContextUtil.commitTransaction(context);
}

//clear the output buffer
out.clear(); %>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
<% if(bRefreshWindow){ %>
<script language="javascript">

 // Modified for Search Component Consolidated View Feature 

var contentWindow = getTopWindow().findFrame(getTopWindow(), "searchContent");

if(contentWindow && contentWindow.document)
{
	contentWindow.document.location.href = contentWindow.document.location.href;	
}
else if(contentWindow && contentWindow.contentWindow)
{	
	contentWindow.contentWindow.document.location.href = contentWindow.contentWindow.document.location.href;
}

//Ended for Search Component Consolidated View Feature 

</script>
<% }else if(bCloseWindow){ %>
<script language="javascript">
getTopWindow().closeWindow();
</script>
<%if(pRefresh){ %>
	<script language="javascript">
		getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
	</script>
<%	
}
%>
<% }else{ %>
<script language="javascript">
getTopWindow().getWindowOpener().pageControl.clearSavedSearchName();
getTopWindow().turnOffProgress();
</script>
<% } %>

