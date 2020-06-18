<%--  emxTest.jsp   -   FS page for Create CAD Drawing dialog
   Copyright (c) 1992-2007 Dassault Systemes.
 --%>

<%@ page import = "java.util.Set" %>
<%@ page import = "java.util.List" %>
<%@ page import = "java.text.DateFormat" %>
<%@ page import = "matrix.db.*" %>
<%@ page import = "com.dassault_systemes.vplm.interfaces.access.IPLMxCoreAccess" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.PLMCoreModelerSession" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.PLMCoreAbstractModeler" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.entity.PLMxReferenceEntity" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.entity.PLMxRefInstanceEntity" %>
<%@ page import = "com.dassault_systemes.vplm.productNav.interfaces.IVPLMProductNav" %>
<%@ page import = "com.dassault_systemes.vplm.dictionary.PLMDictionaryServices" %>
<%@ page import = "com.dassault_systemes.platform.model.product.itf.IPrd3DPartFactory" %>
<%@ page import = "com.dassault_systemes.platform.model.product.services.ProductBrowseProvider" %>
<%@ page import = "com.dassault_systemes.iPLMDictionaryPublicItf.IPLMDictionaryPublicItf" %>
<%@ page import = "com.dassault_systemes.iPLMDictionaryPublicItf.IPLMDictionaryPublicFactory" %>
<%@ page import = "com.dassault_systemes.iPLMDictionaryPublicItf.IPLMDictionaryPublicClassItf" %>
<%@ page import = "com.dassault_systemes.platform.model.itf.nav.INavBusObject" %>
<%@ page import = "com.dassault_systemes.platform.model.itf.IConnectionAuthoringServices" %>
<%@ page import = "com.dassault_systemes.platform.model.services.AuthoringServicesProvider" %>
<%@ page import = "com.dassault_systemes.platform.model.itf.nav.INavBusConnection" %>
<%@ page import = "com.dassault_systemes.vplm.data.PLMxJResultSet" %>
<%@ page import = "com.dassault_systemes.platform.model.Oxid" %>
<%@ page import = "com.dassault_systemes.platform.model.itf.IOxidService" %>
<%@ page import = "com.dassault_systemes.platform.model.services.NavigationServicesProvider" %>
<%@ page import = "com.dassault_systemes.platform.model.services.IdentificationServicesProvider" %>
<%@include file="../emxUIFramesetUtil.inc"%>

<%
    framesetObject fs = new framesetObject();

	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
	String paramUsr = context.getUser();
	String paramPwd = context.getPassword();
	String paramRole = (String) session.getAttribute("role");
	String paramName = (String) requestMap.get("name");
		
	out.println("<body bgcolor=\"#E7EEF2\">");
	//out.println("<p>u:"+paramUsr+" p:"+paramPwd+" r:"+paramRole+"</p>");
	out.println("<p style=\"font-family:verdana;font-size:0.9em;\">");
				
	String role;
	if (paramRole.startsWith("ctx::"))
		role = paramRole;
	else
		role = "ctx::" + paramRole;

      PLMCoreModelerSession _session = PLMCoreModelerSession.getPLMCoreModelerSession(paramUsr, paramPwd, role);
	try {
	_session.openSession();
    	//IProductOperations product = (IProductOperations) _session.getModeler("com.dassault_systemes.vplm.modeler.implementation.PLMxProduct");
    	IVPLMProductNav product = (IVPLMProductNav)_session.getModeler("com.dassault_systemes.vplm.productAuthoring.implementation.VPLMProductAuthoring");

	String lang = (String)context.getSession().getLanguage();
	String prop = "emxVPLMProductEditor.Create.Custo";
	String custo = i18nNow.getI18nString(prop, 
							"emxVPLMProductEditorStringResource",
							lang);
	if (custo == null || custo.equals(prop))
		custo = "PLMProductDS";
	//List attrs = ((PLMxProduct) product).getPublicAttributes(custo, PLMDictionaryServices.REFERENCE);
    List attrs = ((PLMCoreAbstractModeler) product).getPublicAttributes(custo, PLMDictionaryServices.REFERENCE);
	if (paramName != null) {
    		IPLMxCoreAccess _coreAccess=_session.getVPLMAccess();
    
		List m1idList = new ArrayList(1);
		   m1idList.add((String) requestMap.get("emxTableRowId"));
		    // en menu contextuel on doit récupérer emxTableRowId, en selection dans l'arbre, on doit récupérer objectId ...
		    if (1==m1idList.size() && null == m1idList.get(0))
		    {
		      m1idList.remove(0);
		      m1idList.add((String) requestMap.get("objectId"));
		    }

		String[] plmidArray = ((IVPLMProductNav) product).getPLMObjectIdentifiers(m1idList);

    		PLMxJResultSet plmxresult=_coreAccess.getProperties(plmidArray[0]);
    		PLMxReferenceEntity root = null;
    		if (plmxresult.next()) {
    			 root = (PLMxReferenceEntity) plmxresult.extractEntityFromRow();
    		} else {
    			throw new Exception("Error while accessing VPLM");
    		}
    
    	Hashtable publicRefAttributes;
		Hashtable  controlledRefAttributes;
		Hashtable publicInstAttributes;
		Hashtable  controlledInstAttributes;
		String tExternalID;
	
		String plmExternalID = "NewPart";
		String resultOuput = "";
	
		long _time=System.currentTimeMillis();
		Date _date=new Date(_time);
		DateFormat df=DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT);

		String datetime=df.format(_date);
						        		
		publicRefAttributes=new Hashtable(1); 
		if (paramName.length() == 0)
			tExternalID=plmExternalID+" "+datetime;
		else
			tExternalID=paramName;
		publicRefAttributes.put("PLM_ExternalID", tExternalID);
		Iterator itr = attrs.iterator();
		while (itr.hasNext()) {
			String attr = (String) itr.next();
			String value = (String) requestMap.get(attr);
			if (value != null && value.length() > 0)
				publicRefAttributes.put(attr, value);
		}
		//PLMxReferenceEntity part1=product.createPart(custo, publicRefAttributes,controlledRefAttributes);
		IPrd3DPartFactory prd3DPartfactory = ProductBrowseProvider.get3DPartFactory();
		IPLMDictionaryPublicItf dico = new IPLMDictionaryPublicFactory().getDictionary();
        IPLMDictionaryPublicClassItf class_PLMProduct = dico.getClass( _session.getContext() , "PLMProductDS" );
		INavBusObject part1=prd3DPartfactory.create3DPartFromType( _session.getContext(),class_PLMProduct,null, publicRefAttributes, null,null,null,null);
		resultOuput+="\""+tExternalID+"\" created in database<br>";
					
		publicInstAttributes=new Hashtable(1);
		if (paramName.length() == 0)
		tExternalID=plmExternalID+" -1- "+datetime;
		else
			tExternalID=paramName+" -1-";
		publicInstAttributes.put("PLM_ExternalID", tExternalID);
		//PLMxRefInstanceEntity insttart1=product.createPartInstance(root, part1, publicInstAttributes,controlledInstAttributes);
		
		IOxidService oxidService = IdentificationServicesProvider.getOxidService();
        Oxid oxidRoot = oxidService.getOxidFromPid( _session.getContext(), plmidArray[0] );
        INavBusObject rootNav = NavigationServicesProvider.getNavBusProvider().createNavBusObject( _session.getContext(), oxidRoot );

		IConnectionAuthoringServices cnxAuthoringServices = AuthoringServicesProvider.getConnectionAuthoringServices();
        INavBusConnection insttart1 = cnxAuthoringServices.insert(_session.getContext(), rootNav, part1, null, null, publicInstAttributes, null, null);
		//resultOuput+="\""+tExternalID+"\" created in database<br>";
	
		_session.commitSession(false);
	
		out.println("<br/>" + resultOuput + "<br/>");
		out.println("Please refresh your previous view...");
	
	}
	else {
		out.println("Selected Product Customization: " + custo + "<br/><br/>");

		out.println("<form style=\"font-family:verdana;font-size:0.8em;\" name=\"form1\" id=\"form1\" action=\"\" method=\"\" onsubmit=\"return false;\">");
		out.println("<TABLE BORDER=\"0\" VALIGN=\"MIDDLE\" style=\"font-family:verdana;font-size:0.8em;\">");
		out.println("<TR>");
		out.println("<TD>Part Number</TD><TD><input type=\"text\" name=\"name\" id=\"name\" style=\"width:25em;\"></TD>");
		out.println("</TR>");

		/*out.println("<TR>");
		out.println("<TD>Description</TD><TD><textarea name=\"desc\" id=\"desc\" rows=\"4\" style=\"width:25em;\"></textarea></TD>");
		out.println("</TR>");

		out.println("<TR>");
		out.println("<TD>Industry code</TD><TD><input type=\"text\" name=\"induscode\" id=\"induscode\" style=\"width:25em;\"></TD>");
		out.println("</TR>");

		out.println("<TR>");
		out.println("<TD>Standard Number</TD><TD><input type=\"text\" name=\"stdnum\" id=\"stdnum\" style=\"width:25em;\"></TD>");
		out.println("</TR>");
		
		out.println("<TR>");
		out.println("<TD>BOM</TD><TD><select name=\"bom\" id=\"bom\" style=\"width:25em;\">");
		out.println("<option value=\"\"></option>");
		out.println("<option selected value=\"Yes\">Yes</option>");
		out.println("<option value=\"No\">No</option>");
		out.println("</select></TD>");
		out.println("</TR>");

		out.println("<TR>");
		out.println("<TD>Sub-contracted</TD><TD><INPUT type=radio name=\"subc\" value=\"true\"/>True&nbsp;&nbsp;&nbsp;<INPUT type=radio name=\"subc\" value=\"false\" checked/>False</TD>");
		out.println("</TR>");
		
		out.println("<TR>");
		out.println("<TD>Supplier Name</TD><TD><input type=\"text\" name=\"suppl\" id=\"suppl\" style=\"width:25em;\"></TD>");
		out.println("</TR>");
		*/

		Iterator itr = attrs.iterator();
		while (itr.hasNext()) {
			String attr = (String) itr.next();
			
			out.print("<TR><TD>");
			out.print(attr);
			out.print("</TD><TD><input type=\"text\" name=\"");
			out.print(attr);
			out.print("\" id=\"");
			out.print(attr);
			out.print("\" style=\"width:25em;\"></TD>");
			out.println("</TR>");
		}


		out.println("</TABLE>");
		out.println("</form>");
		
	}

	} catch (Exception e) {
		out.println("<br/>An error occured during operation: " + e.getMessage() + "<br/>");
	} finally {
		if (_session != null) {
			try {
				_session.closeSession(true);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	out.println("</p>");
	out.println("</body>");

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>




