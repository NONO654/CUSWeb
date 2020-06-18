<%--  emxVPLMLogon.jsp   -   Role management
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxVPLMLogon.jsp.rca 1.12.1.1.1.2 Sun Oct 14 00:27:58 2007 przemek Experimental cmilliken przemek $

   Wk13 2010 - RCI - RI 44307 - Reprise - Check for CHK_RSC_LA value
   Wk10 2010 - RCI - RI 44307 - Explore resource with LA deliveries for resources
   Wk47 2010 - RCI - RI 81835 - Migration for NextGenUI ( seen with KCW )- setCategoryTree added
   Wk38 2011 - RCI - RI 115025 - 127965 - MyCtx + avoid setPreferredSecurityContext
   Wk48 2011 - RCI - RI 140431 - Contexte unique en utilisant registerContext
   Wk02 2012 - RCI - RI 146552 - Ctx Mgt
   Wk11 2012 - RCI - RI 158198 - Reprise pour "Transaction Aborted"
   Wk31 2012 - RCI - Migration Build Jsp .... on enleve le Prereq sur VPLMPosModeler ( code obsolete avec Common Login )
   Wk42 2012 - RCI - RI 177043 - categoryTreeName
   Wk22 2013 - RCI - RI 202511 - Reprise gestion ctx : remplacer getMainContext par getFrameContext

--%>

<%@ page import = "java.util.Set" %>
<%@ page import = "java.util.HashMap" %>
<%@ page import = "java.util.Map" %>
<%@ page import = "java.util.Iterator"%>
<%@ page import = "matrix.db.*" %>
<%@ page import = "java.util.ArrayList" %>
<%@ page import = "java.util.List" %>

<%@ page import = "matrix.util.StringList"%>
<%@ page import = "com.matrixone.apps.domain.util.i18nNow" %>
<%@ page import = "com.matrixone.apps.domain.util.PropertyUtil" %>
<%@ page import = "com.matrixone.apps.common.Person" %>
<%@ page import = "com.matrixone.apps.domain.util.MapList" %>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@ page import = "com.matrixone.vplmintegrationitf.util.VPLMIntegrationConstants" %>

<%@ page import = "com.dassault_systemes.vplm.interfaces.access.IPLMxCoreAccess" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.PLMCoreModelerSession" %>
<%@ page import = "com.dassault_systemes.vplm.data.PLMxJResultSet" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.entity.PLMxReferenceEntity" %>
<%@ page import = "com.dassault_systemes.vplm.productNav.interfaces.IVPLMProductNav" %>

<%@ page import = "com.dassault_systemes.WebNavTools.util.VPLMJWebToolsM1Util" %>

<%@include file = "emxNavigatorBaseInclude.inc"%>  <%--to manage context --%>
<%@include file = "../emxUILoadPropertyFiles.inc"%>  <%--to manage framesetObject --%> 
<%--  attention ne pas inclure emxUITopInclude.inc a cause de pb de context dans Framework.getFrameContext(session )--%>
 <HEAD> 
 <%@include  file="../emxUICommonHeaderBeginInclude.inc"%> 
  </HEAD> 

<%
    framesetObject fs = new framesetObject();

   // get info from URL
	// -----------------
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    String op = (String) requestMap.remove("op");
	String lang = (String)context.getSession().getLanguage();
	
	PLMCoreModelerSession sessionMdl = null;
	Context frameCtx = Framework.getFrameContext(session); 
//	System.out.println( "RCIIIIIIIIIIIII emxVPLMLogon, on recupère Frame Ctx - user = "+frameCtx.getUser());
//	System.out.println( "RCIIIIIIIIIIIII emxVPLMLogon, on recupère Frame Ctx - role = "+frameCtx.getRole());
//	System.out.println( "RCIIIIIIIIIIIII emxVPLMLogon, on recupère Frame Ctx - transaction = "+frameCtx.getTransactionType());


try {
     String role = frameCtx.getRole();
	 boolean isStartedByMe = false;
	
	// RI 146552
	frameCtx.setApplication("VPLM");
	VPLMJWebToolsM1Util  instM1UtilTools  =  VPLMJWebToolsM1Util.getM1UtilInstance();  
    isStartedByMe = instM1UtilTools.prepareContext(frameCtx);
	

	
 	//argument urlLogon de emxVPLMLogon peut être encodé 
 	// -------------------------------------------------
	String urlLogon = (String) requestMap.remove("urlLogon");	
	StringBuffer thisUrl = new StringBuffer( "");
	if(urlLogon != null)
         thisUrl.append(java.net.URLDecoder.decode(urlLogon));
	
	Iterator keyItr = requestMap.keySet().iterator();
	fs.setCategoryTree((String) requestMap.get("categoryTreeName"));   // RI 81835

	if (role != null && (!role.equals("null") || !role.equals("")|| !role.equals(" "))) {
	
	// --------------------------------------------------
	// The code below is executed only if (role != null)
	// --------------------------------------------------
      StringBuffer url = new StringBuffer("");

       // -----------------------------------------------------------------------------------------------------------------
       //   UTILISATION DE VPLMLogon avec "op" => gestion des produits etendus
       // -----------------------------------------------------------------------------------------------------------------
	    if ( null == urlLogon )
	    {
		  // from operation to action 
		  // ------------------------
		  if ("expand".equals(op)) {
              // on cherche à afficher table specifique pour les produits etendus
              // 1 - on est sur un expand => on a un produit particulier. Recuperation de ce product
              // 2 - sur ce produit, récupérer l'attribut "V_discipline" et sa valeur
              // 3 - chercher pour la valeur donnée, l'url correspondant dans le fichier de resources
              // 4 - si on le trouve, afficher la page de l'url donné
              // 5 - sinon ( et pour tous les cas d'erreur ), afficher la navigation par défaut.
              //	url.append("emxIndentedTable.jsp?expandProgramMenu=VPLMProdStrucDisplayFormat&table=VPLMIndentedSummary&header=emxEngineeringCentral.VPLM.ConfigTableProdStruc&reportType=BOM&sortColumnName=Name&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&editRootNode=false&massPromoteDemote=false&triggerValidation=false");

              // 1 - recuperation du product:
		      // ---------------------------

			// RI 146552
		 sessionMdl = PLMCoreModelerSession.getPLMCoreModelerSessionFromContext(frameCtx);
		 sessionMdl.openSession();
               IPLMxCoreAccess coreAccess=sessionMdl.getVPLMAccess(); 
               String m1Id = (String)requestMap.get("objectId"); 
                       
		   // 2 - recuperation des attributs et filtrage du V_discipline
		   // -----------------------------------------------------------

               IVPLMProductNav product = (IVPLMProductNav)sessionMdl.getModeler("com.dassault_systemes.vplm.productNav.implementation.VPLMProductNav");
               List m1idList = new ArrayList(1);
               m1idList.add(m1Id);
               String[] plmidArray = ((IVPLMProductNav) product).getPLMObjectIdentifiers(m1idList);
               if ( null == plmidArray || 0 == plmidArray.length)
                       throw new Exception ("The product modeler couldn't be retrieved : operation aborted.");
               PLMxJResultSet resultSet = coreAccess.getProperties(plmidArray); // recupere tous les attributs publics

               PLMxReferenceEntity refEntity = null;
               if ((resultSet != null) && (resultSet.next()))
		   {
                refEntity = (PLMxReferenceEntity)resultSet.extractEntityFromRow();
	          
                // on recupere l'attribut V_discipline
                try
                { 
	            Hashtable attrValueTable = refEntity.getAttributes();
                  String vDiscValue = (String) attrValueTable.get("V_discipline");
                  if ( null != vDiscValue)
                  {

                  // 3 - recherche l'existence d'url dans le fichier de resources
		      // ------------------------------------------------------------

                  lang = (String)context.getSession().getLanguage(); // pas besoin de Nls ... meilleur code ?
                  String resourceToUse = i18nNow.getI18nString(vDiscValue , "emxVPLMProductEditor",	lang);
                  
                  // 4 - affichage et gestion des erreurs
                  // ------------------------------------
                  try
                  {
                  if ( 0 == resourceToUse.compareTo(vDiscValue))
                   {
                   System.out.println("             v_Discipline without associated RESOURCE: "+vDiscValue);
 	       	 throw new Exception(" no RESOURCE for discipline = "+vDiscValue);
                     }
                  else
                     {
                      String CheckLA = i18nNow.getI18nString("CHK_RSC_LA" ,resourceToUse,	lang);

                      if ( 0 == CheckLA.compareToIgnoreCase("FALSE"))
                      {
                       String urlForExt = i18nNow.getI18nString(vDiscValue ,resourceToUse,	lang);
                       if ( 0 == urlForExt .compareTo(vDiscValue))
                       {
                       System.out.println("             v_Discipline without associated URL - GA delivery: "+vDiscValue);
 	       	     throw new Exception(" no URL for discipline = "+vDiscValue);
                       }
                       else
                       {
                       url.append(urlForExt);
                       }
                      }
                      else 
                      {
                        System.out.println("             resource not accessible - LA delivery: "+vDiscValue);
	       	     throw new Exception(" LA delivery for discipline = "+vDiscValue);
                      }
                   }
			 
		      }	
		      catch (Exception e)
		      {
		       url.append("emxIndentedTable.jsp?expandProgramMenu=VPLMProdStrucDisplayFormat&table=VPLMIndentedSummary&header=emxEngineeringCentral.VPLM.ConfigTableProdStruc&reportType=BOM&sortColumnName=Name&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&editRootNode=false&massPromoteDemote=false&triggerValidation=false");
		      }
                  } // V_discipline non nul
                 }
                 catch (Exception e)
                 {
		      url.append("emxIndentedTable.jsp?expandProgramMenu=VPLMProdStrucDisplayFormat&table=VPLMIndentedSummary&header=emxEngineeringCentral.VPLM.ConfigTableProdStruc&reportType=BOM&sortColumnName=Name&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&editRootNode=false&massPromoteDemote=false&triggerValidation=false");
                 }
               }// fin cas resultSet non nul
                // 5 - cas par defaut
		    // -------------------
               else
		    url.append("emxIndentedTable.jsp?expandProgramMenu=VPLMProdStrucDisplayFormat&table=VPLMIndentedSummary&header=emxEngineeringCentral.VPLM.ConfigTableProdStruc&reportType=BOM&sortColumnName=Name&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&editRootNode=false&massPromoteDemote=false&triggerValidation=false");
              
	  	  } else if ("create".equals(op)) {
			url.append("emxVPMProductCreateFS.jsp");
		  } else if ("delete".equals(op)) {
			url.append("emxVPMProductDelete.jsp");
		  } else if ("properties".equals(op)) {
    		//url.append("emxVPLMPublicAttributes.jsp?categoryTreeName"+(String) requestMap.get("categoryTreeName"));
			  url.append("emxForm.jsp?form=type_VPMReference&categoryTreeName"+(String) requestMap.get("categoryTreeName"));
		  } else if ("processExpand".equals(op)) {
             url.append("emxIndentedTable.jsp?expandProgramMenu=VPLMProcStrucDisplayFormat&table=VPLMProcIndentedSummary&header=emxEngineeringCentral.VPLM.ConfigTableProcStruc&reportType=BOM&sortColumnName=Name&HelpMarker=emxhelppartbom&massPromoteDemote=false&triggerValidation=false&editRootNode=false");
          } else if ("processProperties".equals(op)) {
             url.append("emxVPLMProcPublicAttributes.jsp");
          } else if ("processDataReq".equals(op)) {
             url.append("emxIndentedTable.jsp?expandProgramMenu=VPLMProcDataReqDisplayFormat&table=VPLMProcIndentedSummary&header=emxEngineeringCentral.VPLM.ConfigTableProcDataReq&reportType=BOM&sortColumnName=Name&HelpMarker=emxhelppartbom&massPromoteDemote=false&triggerValidation=false&editRootNode=false");
          } else if ("systemExpand".equals(op)) {
             url.append("emxIndentedTable.jsp?expandProgramMenu=VPLMSystStrucDisplayFormat&table=VPLMSystIndentedSummary&header=emxEngineeringCentral.VPLM.ConfigTableSystStruc&reportType=BOM&sortColumnName=Name&HelpMarker=emxhelppartbom&massPromoteDemote=false&triggerValidation=false&editRootNode=false");
          } else if ("systemProperties".equals(op)) {
             url.append("emxVPLMSystPublicAttributes.jsp");
          } else if ("operationExpand".equals(op)) {
             url.append("emxIndentedTable.jsp?expandProgramMenu=VPLMOpStrucDisplayFormat&table=VPLMSystIndentedSummary&header=emxEngineeringCentral.VPLM.ConfigTableOpStruc&reportType=BOM&sortColumnName=Name&HelpMarker=emxhelppartbom&massPromoteDemote=false&triggerValidation=false&editRootNode=false");
          } else if ("operationProperties".equals(op)) {
            url.append("emxVPLMSystPublicAttributes.jsp");
          }
		  url.append("?");
		    url.append(keyItr.next());
	        while (keyItr.hasNext()) {
			String key = (String) keyItr.next();
			url.append("&");
			url.append(key);
			url.append("=");
			url.append(requestMap.get(key)); 
	        }
	    }
       // -----------------------------------------------------------------------------------------------------------------
       //   UTILISATION DE VPLMLogon avec "urlLogon " => on dispatche l'url
       // -----------------------------------------------------------------------------------------------------------------

	    else // urlLogon not null => dispatch it
	    {
	      url.append(thisUrl);	
	    }
	 // -----------------------------------------------------------------------------------------------------------------
       //   gestion security context
       // -----------------------------------------------------------------------------------------------------------------

	    // set SecurityContext as default if needed
	    // ----------------------------------------
	   // if ( 0 != role.compareTo(context.getRole()) ) // setSecurityContext if arg role differs from context role
	   // VPLMSecurityContext.setPreferredSecurityContext(context, context.getUser(), role);  

		// dispatch URL for action
		// -----------------------
 
        // for existing apps , set role on the session
        // to remove after migration
        // -------------------------------------------
		session.setAttribute("role", role);
		// for later behaviour, set role on the context
        // -------------------------------------------
        //context.resetRole(role); ///////////////

		try {
			RequestDispatcher rd = request.getRequestDispatcher(url.toString());
			rd.forward(request, response);
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}// end case role !=null

}
finally
		{
		frameCtx.shutdown();
		}
  // ----------------- Do Not Edit Below ------------------------------

 // fs.writePage(out);

%>





