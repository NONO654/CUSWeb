<%--
  emxVPMCreateVPMAction.inc

  Methods used for popup selection, for use with win9x clients
  Workaround for limitation of the number of SELECT statements on a browser
  in win9x platform, see Microsoft Knowledge Base Article - 265489

  Copyright (c) 1992-2008 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxVPMCreateVPMAction.inc.rca 1.4 Wed Oct 22 15:49:35 2008 przemek Experimental przemek przemek $
--%>

<%@ page import="com.dassault_systemes.vplmcoredictionaryinterfaces.IVPLMCoreDictionary"%>
<%@ page import="com.dassault_systemes.vplmcoredictionaryinterfaces.IVPLMCoreDictionaryModeler"%>
<%@ page import="com.dassault_systemes.vplmcoredictionaryinterfaces.IVPLMCoreDictionaryType"%>
<%@ page import="com.dassault_systemes.vplmcoredictionaryinterfaces.VPLMCoreDictionaryFactory"%>
<%!
    public static String getDomainFromPLMType(String vplmType)
    {
        return vplmType.substring(0, vplmType.indexOf("/"));
    }

    public static String convertMatrixTypeToVPLMType(String matrixType)
    {
        String inputMatrixType=matrixType;
        String plmtype = matrixType;
        	
        matrixType = matrixType.substring(matrixType.lastIndexOf('/') + 1);
            
        plmtype = scanDictionaryForType(matrixType);

        return plmtype;
    }

    public static String scanDictionaryForType(String typeToFind)
    {
        String plmtype = null;
        //Get the Dictionary
        VPLMCoreDictionaryFactory dicoMgr = VPLMCoreDictionaryFactory.createInstance();
        IVPLMCoreDictionary dico=dicoMgr.getDictionary();
        
        //Go through all the modelers
        java.util.List modelers= (java.util.List)dico.getModelers();
        Iterator iModeler=modelers.iterator();
        while(iModeler.hasNext())
        {
            IVPLMCoreDictionaryModeler modeler=(IVPLMCoreDictionaryModeler)iModeler.next();
            if(modeler!=null)
            {
                //Look for the type
                IVPLMCoreDictionaryType modelertype = modeler.getType(typeToFind);
                if (modelertype != null)
                {
                    StringBuffer sb = new StringBuffer(modeler.getName());
                    sb.append("/");
                    sb.append(modelertype.getName());
                    plmtype=sb.toString();
                    break;
                }
            }
        }
        
        return plmtype;
    }
%>

<%--
  boolean isWin9x;

  String userAgent = request.getHeader("User-Agent"); 
 
  if ( userAgent.toLowerCase().indexOf("windows 9") >= 0 ) {
    isWin9x = true;
  } else {
    isWin9x = false;
  }
--%>
