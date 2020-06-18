<% response.setContentType("text/xml");
   response.setContentType("charset=UTF-8");
   response.setHeader("Content-Type", "text/xml");
   response.setHeader("Cache-Control", "no-cache");
   response.getWriter().write("<?xml version='1.0' encoding='iso-8859-1'?>");
%>
<%--
//@fullReview  ZUR 10/04/22 HL XP Params
//@quickReview ZUR 10/06/01 HL XP Params
//@fullReview ZUR 10/07/02 HL Param V6R2012
//@quickReview ZUR 10/07/21 HL XP Params : integrating hadProblemsoccured : no freeze
//@quickReview ZUR 10/09/10 Paremetrization Enhancements, adding new parameters
//@quickReview ZUR 10/10/19 included emxNavigatorNoDocTypeInclude instead of emxNavigatorInclude for the new gen UI 
//@fullReview  ZUR 10/11/05 HL XP Params Enh. V6R2012 - Handle the split of Access Rights and Identifications
//@quickReview ZUR 11/01/11 modifications for WEBLOGIC compatibility
//@quickReview ZUR 11/02/04 V62012x : Integrating the Attributes Synchronizations HL 
//@quickReview ZUR 11/06/20 Integrating StrictOwnership On Evaluation Parameter
//@quickReview ZUR 12/06/06 Removing PromotionRulesHandle 
--%>
<%@ page import="com.dassault_systemes.vplmposadminservices.HtmlCatalogHandler" %> 
<%@ page import="java.util.*"%>
<%@ page import="java.lang.Integer"%>

<%@ page import="matrix.util.StringList"%>
<%@ page import ="com.matrixone.vplm.FreezeServerParamsSMB.FreezeServerParamsSMB"%>

<%@ page import ="com.matrixone.vplm.TeamAttributeSynchronization.TeamAttributeSynchronization"%>
<%@ page import ="com.matrixone.vplm.TeamAttributeSynchronization.SynchronizationParameter"%>

<%@ page import ="com.matrixone.apps.domain.util.ContextUtil"%>
<%@ page import ="com.matrixone.apps.framework.ui.UICache"%>
<%@ page import ="com.matrixone.apps.framework.ui.CacheManager"%>

<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
		
<%

//String finalNameString="<?xml version='1.0' encoding='iso-8859-1'?><root>";
String finalNameString="<root>";

String iSourceJSP="";
String fStatus = "";
String commandtofreeze="";

iSourceJSP=emxGetParameter(request,"iSourceJSP");
fStatus=emxGetParameter(request,"frzStatus");

int hadProblemsoccured=0;

if (iSourceJSP.equalsIgnoreCase("DataSynch"))
{
	//Synchronization 2012x HL
	
	String iNbOfSetSynch="";
	iNbOfSetSynch=emxGetParameter(request,"iNbSetSynch_");	
	commandtofreeze="APPXPParametrizationDataTree";
	
	
	String prefixPrd="iCustPrdAtt_";
	String prefixPart="iChoosenPartAtt_";
	String custPrdAttName="";
	String correspPartAttName="";
	int iretSync=0;
	String retSynchro="S_OK";
	String retDeployType="StoreAndDeploy";
	
	TeamAttributeSynchronization TAS = new TeamAttributeSynchronization(context);	
	SynchronizationParameter synchParamList[] = null;
		
	if (iNbOfSetSynch.length()>0 )
	{		

		int i;
		int nbSetSynch =Integer.parseInt(iNbOfSetSynch);		
		
		String iDeployType=emxGetParameter(request,"iDeployType");
		retDeployType=iDeployType;
		
		synchParamList = new SynchronizationParameter[nbSetSynch];
		
		for (i=0; i<synchParamList.length;i++)
			synchParamList[i] = new SynchronizationParameter();
				
	
		for (i=0; i<nbSetSynch; i++)
		{
			prefixPrd=prefixPrd+String.valueOf(i);
			prefixPart=prefixPart+String.valueOf(i);
		
			custPrdAttName=emxGetParameter(request,prefixPrd);
			correspPartAttName=emxGetParameter(request,prefixPart);
			
			synchParamList[i].setProductAttributeName(custPrdAttName);
			synchParamList[i].setPartAttributeName(correspPartAttName);
			synchParamList[i].setSynchroDirection(0);//BIDIRECTIONNAL			
			
			prefixPrd="iCustPrdAtt_";
			prefixPart="iChoosenPartAtt_";
			
		}		
		
		if ("StoreAndDeploy".equalsIgnoreCase(iDeployType))			
			iretSync=TAS.setSynchronizationParameters(context, synchParamList);
		else//StoreOnly
			iretSync = TAS.resetAndStore(context, synchParamList);
			
		
		
		if (iretSync==TAS.S_SUCCESS)
		{
			retSynchro="S_OK";
			
			// reload cache
			try
			{
				ContextUtil.startTransaction(context, false);
				UICache.loadUserRoles(context, session);
				StringList errAppSeverList = CacheManager.resetRemoteAPPServerCache(context, pageContext);
				CacheManager.resetRMIServerCache(context);
				ContextUtil.commitTransaction(context);
			}
			catch (Exception e)
			{
				ContextUtil.abortTransaction(context);
			}
			
		}
		else if (iretSync==TAS.E_INTERNAL_ERROR)
		{
			retSynchro="E_Internal";
			hadProblemsoccured=1;
		}
		
	}

	finalNameString=finalNameString+"<SynchAttRet>"+retSynchro+"</SynchAttRet>";	
	finalNameString=finalNameString+"<SynchType>"+retDeployType+"</SynchType>";	
}


int iret4=0;

if ( (fStatus.equalsIgnoreCase("true"))&&(hadProblemsoccured==0) )
{
	FreezeServerParamsSMB Frz4 = new FreezeServerParamsSMB();
	iret4 = Frz4.SetServerFreezeStatusDB(context,commandtofreeze);

	String retmessage="";

	if (iret4==Frz4.S_SUCCESS)
		retmessage="S_OK";
	else if (iret4==Frz4.E_INTERNAL_ERROR)
		retmessage="E_Internal";
	else
		retmessage="E_Frozen";

	finalNameString=finalNameString+"<Freezeret>"+retmessage+"</Freezeret>";	
	
}


finalNameString = finalNameString+"</root>";

response.getWriter().write(finalNameString);


%>
