<%-- emxVPLMCommonNavProperties.jsp --%>

<%@ page import = "java.util.Date" %>
<%@ page import = "java.util.Iterator" %>
<%@ page import = "java.util.Map" %>
<%@ page import = "java.util.List" %>
<%@ page import = "java.util.HashMap" %>
<%@ page import = "java.util.Set" %>
<%@ page import = "java.util.Vector" %>
<%@ page import = "java.text.DateFormat" %>
<%@ page import = "java.text.SimpleDateFormat"%>
<%@ page import = "com.matrixone.apps.domain.util.ContextUtil" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.entity.PLMxEntityDef" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.PLMCoreModelerSession" %>
<%@ page import = "com.dassault_systemes.vplm.data.service.PLMIDAnalyser"%>
<%@ page import = "com.dassault_systemes.vplm.simulationNav.interfaces.IVPLMCommonNav" %>
<%@ page import = "com.dassault_systemes.vplm.simulationNav.service.VPLMCommonNavService" %>
<%@ page import = "com.dassault_systemes.vplm.simulationNav.service.VPLMCommonNavUtil" %>
<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>    

<%@page import="java.util.ListIterator"%>
<head>
  <title>Common Nav Properties</title>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStylePropertiesInclude.inc"%>  
</head>

<%
    out.println("<body bgcolor=\"#E7EEF2\">");
	out.println("<p style=\"font-family:verdana;font-size:0.8em;\">");

	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
	
	Context vplmCtx = VPLMCommonNavUtil.getVPLMCtx(context);
    String lang = (String)vplmCtx.getSession().getLanguage();

    PLMCoreModelerSession _session = VPLMCommonNavService.getSession(vplmCtx);
    try 
    {
        ContextUtil.startTransaction(vplmCtx, false);
        _session.openSession();

        IVPLMCommonNav commonNav = VPLMCommonNavService.getCommonNav(_session);
    
        String objectId = (String)requestMap.get("objectId");
        String plmId = commonNav.getPlmId(objectId);
        PLMxEntityDef entity = commonNav.getEntity(plmId);

        Map attributes = entity.getAttributes();

        out.println("<table border=\"0\" width=\"100%\" cellpadding=\"5\" cellspacing=\"2\">");

        // Display PLM Type
        String plmType = PLMIDAnalyser.getTypeName(plmId);
        plmType = plmType.substring(plmType.indexOf("/")+1);
        
		//String typeName = "VPLMtyp/" + plmType;

		//gha migration
		String typeName = plmType;

        String typeLabel = 
            VPLMCommonNavUtil.getI18NString("VPLM.Label.Type", lang);
        String typeNameI18N = UINavigatorUtil.getAdminI18NString(
            "Type", typeName, lang);
        out.println("<tr><td class=\"label\">" + typeLabel   +" </td>");
        out.println("<td class=\"field\">" + typeNameI18N +"</td></tr>");

        // Display PLM_ExternalId using custom JPO
        String attrName = "PLM_ExternalID";
        String attrNameI18N = VPLMCommonNavUtil.getI18NString(attrName, lang); 
        Map objectMap = new HashMap();
        objectMap.put("id", objectId);
        objectMap.put("PLMID", plmId);
        objectMap.put("attributes", attributes);
        String attrValue = VPLMCommonNavUtil.invokeJPO(
            vplmCtx, objectMap, "VPLM.Name");
        if (attrValue == null)
            attrValue = (String)attributes.get(attrName);
        out.println("<tr><td class=\"label\">" + attrNameI18N   +" </td>");
        out.println("<td class=\"field\">" + attrValue +"</td></tr>");

        // Display PLM Version
        attrName = "V_version";
        attrNameI18N = VPLMCommonNavUtil.getI18NString(attrName, lang);
        attrValue = (String)attributes.get(attrName);
        if (attrValue != null)
        {
            out.println("<tr><td class=\"label\">" + attrNameI18N   +" </td>");
            out.println("<td class=\"field\">" + attrValue +"</td></tr>");
        }

        // Get remaining list of attributes to be displayed
        List attributeList = 
            VPLMCommonNavUtil.getTypePropertyList(vplmCtx, plmId, "VPLM.Read");
        Iterator attrIter = (attributeList != null) ?
            attributeList.iterator() :
            attributes.keySet().iterator();

        out.println("<tr></tr>");
        while (attrIter.hasNext())
        {
            attrName = (String)attrIter.next();
            
            // Attributes that won't be displayed in the UI
            if ("PLM_ExternalID".equals(attrName)         ||
                "V_version".equals(attrName)              ||
                "V_HostID".equals(attrName) 	          || 
            	"LOCKSTATUS".equals(attrName) 	          ||
            	"C_updatestamp".equals(attrName) 	      ||
            	"V_isLastVersion".equals(attrName) 	      ||
            	"V_isTerminal".equals(attrName) 	      ||
            	"V_SimObj_CategoryType".equals(attrName)  ||
            	"V_ApplicabilityDate".equals(attrName) 	  )
                continue;

            try {
                attrValue = (String)attributes.get(attrName);
            } catch (ClassCastException cce) {
                continue;
            }
            if (attrValue == null) attrValue = "";

            // Try the attribute name without the type prefix
            attrNameI18N = VPLMCommonNavUtil.getI18NString(attrName, lang);
            if (attrName.equals(attrNameI18N))
            {
                // Try the attribute name with the type prefix
                attrNameI18N = VPLMCommonNavUtil.getI18NString(
                    attrName, plmType, lang);
                if (attrName.equals(attrNameI18N))
                {
                    int index = attrName.lastIndexOf("_");
                    if (index != -1)
                        attrNameI18N = attrName.substring(index+1);
                }
            }

            // Need solution to determine type of attribute
            // For now, check for the two common date attributes
            if ("C_created".equals(attrName) ||
                "C_modified".equals(attrName))
            {
                long tmpLong = Long.parseLong(attrValue);
                tmpLong = tmpLong*1000;
                Date tmpDate = new Date(tmpLong);
                SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy' 'HH:mm:ss");
                attrValue = sdf.format(tmpDate);
            }
            out.println("<tr><td class=\"label\">" + attrNameI18N   +" </td>");
            out.println("<td class=\"field\">" + attrValue +" </td></tr>");
        }

        out.println("</table>");
        out.println("</body>");

        ContextUtil.commitTransaction(vplmCtx);
        // If no updates were done, commitSession throws an exception
        // _session.commitSession(true);
        _session.closeSession(true);
    } 
    catch (Exception e)
    {
        out.println("<br/>An error occured during operation: " + e.getMessage() + "<br/>");
        ContextUtil.abortTransaction(vplmCtx);
        _session.closeSession(true);
    }
    finally
    {
    	VPLMCommonNavUtil.terminateCtx(vplmCtx);
    }

%>



