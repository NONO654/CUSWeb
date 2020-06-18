<%-- emxProgramCentralResourceDialogFS.jsp

  Displays a window for creating a Calendar event.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralResourceDialogFS.jsp.rca 1.8 Wed Oct 22 15:49:41 2008 przemek Experimental przemek $";

--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>

<%
  com.matrixone.apps.program.ProjectSpace project =
    (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context,
    DomainConstants.TYPE_PROJECT_SPACE, "PROGRAM");
   
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String initSource = emxGetParameter(request,"initSource");
  String objectId   = emxGetParameter(request,"objectId");
  String type   = emxGetParameter(request,"type");
  String Directory  = appDirectory;
  String sStart =      emxGetParameter(request,"start"); 
  String sEnd =      emxGetParameter(request,"end");  
  String sStartDtHidden =      emxGetParameter(request,"start_msvalue"); 
  String sEndDtHidden   =      emxGetParameter(request,"end_msvalue");  
  String selected   =      emxGetParameter(request,"selected");
  String searchMode   =      emxGetParameter(request,"searchMode");  
  if(selected == null || "null".equals(selected))
  {
    selected = "";
  }
  boolean validSelection = true;
  
  if(sStart==null)
    sStart="";
  if(sEnd==null)
    sEnd="";
  if(sStartDtHidden==null)
  sStartDtHidden="";
  if(sEndDtHidden==null)
  sEndDtHidden="";
  framesetObject fs = new framesetObject();
  fs.setDirectory(Directory);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if (initSource == null){
    initSource = "";
  }
 
  String[] emxTableRowId =      emxGetParameterValues(request,"emxTableRowId");
  
  if(emxTableRowId.length==1){
	  
		    matrix.util.StringList lstTokens = com.matrixone.apps.domain.util.FrameworkUtil.split(emxTableRowId[0],"~");
		    emxTableRowId = new String[lstTokens.size()];
		    for(int index=0; index<lstTokens.size(); index++)
		    {
		    	emxTableRowId [index] = (String)lstTokens.get(index);
		    }
  }else{
  
  emxTableRowId = ProgramCentralUtil.parseTableRowId(context,emxTableRowId);
  
  }
  for(int i=0; i<emxTableRowId.length;i++ ){
	  if(emxTableRowId[i].contains(":")){
		  	StringList valueList = StringUtil.split(emxTableRowId[i], ":");
		  	String personName = (String)valueList.get(2);
		  	if(personName.contains("_PRJ")){
		  		personName = personName.substring(0,personName.indexOf("_PRJ"));
		  		emxTableRowId[i] = PersonUtil.getPersonObjectID(context, personName);
		  	}else{
		  		validSelection = false;
		  		break;
		  	}
		  	
		  }
  }
  
  if(!validSelection){
	  %>
	             <script language="javascript" type="text/javaScript">  
	             alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.MemberTransfer.selectPerson</emxUtil:i18nScript>");
	             window.closeWindow();
	             </script>
	  <%
	        return;
}
  
  String hiddenParams = "";

   //modified:18-March-09:yox:R207:PRG:Bug :369197
  if(searchMode!=null && searchMode.equals("GeneralPeopleTypeMode")){
    
      for(int i=0;i<emxTableRowId.length;i++){
          matrix.util.StringList lstTokens = com.matrixone.apps.domain.util.FrameworkUtil.split(emxTableRowId[i],"|");
          if(i==emxTableRowId.length-1)
              hiddenParams += lstTokens.get(0);
            else
              hiddenParams += lstTokens.get(0)+ "~"; //Modified:nr2:PRG:R212:20 May 2011:IR-030958V6R2012x  
      }
  }
  else{
     if(emxTableRowId !=null)
       {
    	 if(emxTableRowId.length==1)
    	 {
    		    matrix.util.StringList lstTokens = com.matrixone.apps.domain.util.FrameworkUtil.split(emxTableRowId[0],"~");
    		    emxTableRowId = new String[lstTokens.size()];
    		    for(int index=0; index<lstTokens.size(); index++)
    		    {
    		    	emxTableRowId [index] = (String)lstTokens.get(index);
    		    }
    	 }
       for(int k=0;k<emxTableRowId.length;k++){
         String itemId = emxTableRowId[k];
         if(k==emxTableRowId.length-1)
           hiddenParams += itemId;
         else
           hiddenParams += itemId + "~"; //Modified:nr2:PRG:R212:20 May 2011:IR-030958V6R2012x
       }
     }
  }
  //End:yox:R207:PRG:Bug :369197
  // ----------------- Do Not Edit Above ------------------------------
    //Added:nr2:PRG:R212:IR-05370,IR-030958:20 May 2011
    //Modification done for IR-05370 was erraneous. Did the correction below.
    //Selection can be done from 
    //Project->Member or Project->Role,Group or Company->People. 1st and 3rd cases are valid.
  //Start:ak4:R210:PRG:Bug :053704
  String identifier = "";
  
   for(int i=0;i<emxTableRowId.length;i++){
	    identifier = emxTableRowId[i];
	   	if(!identifier.contains("|")){ //Selected group or role or member
           if(identifier.contains("personid_"))
        	   identifier = identifier.replace("personid_","");
           
	   	   if(!identifier.matches("[0-9]{3,5}.[0-9]{3,5}.[0-9]{3,5}.[0-9]{3,5}")){
	   		  validSelection = false;
	   	      break;
                }
            }
       }

   if(!validSelection){
%>
           <script language="javascript" type="text/javaScript">  
           alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.MemberTransfer.selectPerson</emxUtil:i18nScript>");
           window.closeWindow();
           </script>
<%
      return;
    }
  //End:nr2:PRG:R212:IR-05370,IR-030958:20 May 2011
  //Added for Bug#312083 - Begin
  if(session.getAttribute("emxTableRowId") != null){
      session.removeAttribute("emxTableRowId");
  }
  session.setAttribute("emxTableRowId", hiddenParams); //hiddenParams is delimited by '~' character. //Modified:nr2:PRG:R212:20 May 2011:IR-030958V6R2012x
  // Specify URL to come in middle of frameset
  String contentURL = "emxProgramCentralResourceLoadingDialog.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&jsTreeID=" + jsTreeID + "&objectId=" + objectId;
  //contentURL += "&emxTableRowId=" + hiddenParams;
  contentURL += "&type=" + type; 
  contentURL += "&start=" + sStart;  
  contentURL += "&end=" + sEnd;
  contentURL += "&start_msvalue=" + sStartDtHidden;
  contentURL += "&end_msvalue=" + sEndDtHidden + "&optionSelected="+selected;
 
  project.setId(objectId);
  String PageHeading = "emxProgramCentral.Common.ResourceLoading.PeriodSelection";
  String HelpMarker = "emxhelpresourceloadingselection";
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,false,false,false);
  
  
  String submitStr = "emxProgramCentral.Button.Done";
  String cancelStr = "emxProgramCentral.Button.Cancel";
  fs.createFooterLink(submitStr, "submitFormCreate()", "role_GlobalUser",
                      false, true, "emxUIButtonDone.gif", 0);

  fs.createFooterLink(cancelStr, "parent.window.closeWindow()", "role_GlobalUser",
                      false, true, "emxUIButtonCancel.gif", 0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);
%>
