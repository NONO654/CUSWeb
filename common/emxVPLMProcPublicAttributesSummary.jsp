<%--  emxVPLMProcPublicAttributes.jsp   -   page for Public attributes of VPLMEntities
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxVPLMProcPublicAttributes.jsp.rca 1.12.1.1.1.2 Sun Oct 14 00:27:58 2007 przemek Experimental cmilliken przemek $
--%>
<%@ page import = "java.util.Set" %>
<%@ page import = "java.util.List" %>
<%@ page import = "java.util.HashMap" %>
<%@ page import = "java.text.DateFormat" %>
<%@ page import = "java.text.SimpleDateFormat"%>

<%@ page import = "matrix.db.*" %>

<%@ page import = "com.dassault_systemes.vplm.fctProcessNav.interfaces.IVPLMFctProcessNav" %>
<%@ page import = "com.dassault_systemes.vplm.interfaces.access.IPLMxCoreAccess" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.PLMCoreModelerSession" %>
<%@ page import = "com.dassault_systemes.vplm.data.service.PLMIDAnalyser"%> 
<%@ page import = "com.dassault_systemes.vplm.data.PLMxJResultSet"%>
<%@ page import = "com.dassault_systemes.VPLMJCommonUIServices.VPLMJCommonUIDicoServices"%> 

<%@include file = "emxUIConstantsInclude.inc"%> 
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>    

<head>
  <title>Basic Information</title>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStylePropertiesInclude.inc"%>  
</head>

<%
 
    out.println("<body bgcolor=\"#E7EEF2\">");
	out.println("<p style=\"font-family:verdana;font-size:0.8em;\">");
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);

	boolean isStartedByMe = false;
	String myApplication = context.getApplication();
    if (myApplication == null || !myApplication.equals("VPLM"))
	{
		context.setApplication("VPLM");
   	}
	if(!(context.isTransactionActive()))
	{
		isStartedByMe = true;
		context.resetVault("vplm"); 
		context.start(false); // false because it's a NON authoring session
	}
	else if (!context.getVault().equals("vplm") )
	{
		context.resetContext(context.getUser(), context.getPassword(),"vplm");
	}

    String lang = (String)context.getSession().getLanguage();
    PLMCoreModelerSession _session = PLMCoreModelerSession.getPLMCoreModelerSessionFromContext(context);
    
	try {
	_session.openSession();

	// modeler de navig de base
	IPLMxCoreAccess _coreAccess=_session.getVPLMAccess(); 
   	
   	// modeler Process
      IVPLMFctProcessNav modeler = (IVPLMFctProcessNav)_session.getModeler("com.dassault_systemes.vplm.fctProcessNav.implementation.VPLMFctProcessNav");

    // passage Id M1 à Id VPLM
	String rmbId = (String) requestMap.get("emxTableRowId");
	String rmbObj = rmbId;
	
    String formatedM1Id = null;
    StringList sList = FrameworkUtil.split(rmbObj,"|");

    if(sList.size() == 3)
    {
        formatedM1Id = (String)sList.get(0);
    }
    else if(sList.size() == 4)
    {
        formatedM1Id = (String)sList.get(1);
    }
    else if(sList.size() == 2)
    { //For bug 370990
        formatedM1Id = (String)sList.get(1);
	}
    else if(sList.size() == 1)
    { //For bug 142501
       	formatedM1Id = (String)sList.get(0);
    }
    else
    {
        formatedM1Id = rmbObj;
    }

	rmbObj = formatedM1Id;
	
	List m1idList = new ArrayList(1);
	m1idList.add(rmbObj);
    
    // en menu contextuel on doit récupérer emxTableRowId, en selection dans l'arbre, on doit récupérer objectId ...
      if (1==m1idList.size() && null == m1idList.get(0))
      {
        m1idList.remove(0);
        m1idList.add((String) requestMap.get("objectId"));
      }

	String[] plmidArray = null;

   	try
	{
		plmidArray = ((IVPLMFctProcessNav) modeler).getPLMObjectIdentifiers(m1idList);
	}
	catch (Exception e){
		e.printStackTrace();
	}
    
    out.println("<table border=\"0\" width=\"100%\" cellpadding=\"5\" cellspacing=\"2\">");
	
    PLMxJResultSet plmxresult=_coreAccess.getProperties(plmidArray[0]);
    if (plmxresult.next())
    {
	    String TableName=(String)plmxresult.getTableName();
	    String CustoType = PLMIDAnalyser.getTypeName(plmidArray[0]); 
	    
	    String plmType = CustoType.substring(CustoType.indexOf("/")+1, CustoType.length());
	    
		HashMap<String, String> dicoAttributes = VPLMJCommonUIDicoServices.translateDicoAttributes(context, plmType, lang);

		//First print V_Name
		String name = "V_Name";
		String translatedAttributeName = dicoAttributes.get(name);
		Object value = plmxresult.getRowValue(TableName + "." + name);
		String formattedAttributeValue = VPLMJCommonUIDicoServices.formatValue(context, "VPLMSystemEditor", plmType, name, value, lang);
		out.println("<tr><td class=\"label\">" + translatedAttributeName + "</td>");
		out.println("<td class=\"field\">" + formattedAttributeValue + "</td>");
		
		for (String shortName : dicoAttributes.keySet())
		{
			try
			{
				if (shortName.equals("V_Name"))
				{
					//already handled
					continue;
				}

				translatedAttributeName = dicoAttributes.get(shortName);
				value = plmxresult.getRowValue(TableName + "." + shortName);
				formattedAttributeValue = VPLMJCommonUIDicoServices.formatValue(context, "VPLMProcessEditor", plmType, shortName, value, lang);
				out.println("<tr><td class=\"label\">" + translatedAttributeName + "</td>");
				out.println("<td class=\"field\">" + formattedAttributeValue + "</td>");
			}
			catch (Exception e)
			{
				out.println("<tr><td class=\"label\">" + shortName + "</td>");
				out.println("<td class=\"field\">" + "xxx" + "</td>");
			}
		}
		
		out.println("</tr>");
    }

	out.println("</table>");
	out.println("</body>");

   } catch (Exception e) {
		if (( e.toString() != null) && (e.toString().trim().length()>0))
    		{
			emxNavErrorObject.addMessage ("emxVPLMProcPublicAttributesSummary: The supplied object is invalid");
		}
	      e.printStackTrace();
   } finally {
		if (_session != null) {
			try {
				_session.closeSession(true);
				if (isStartedByMe) context.abort();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
   }

%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>



