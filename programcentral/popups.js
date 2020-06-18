//=================================================================
// JavaScript Popups
// This page will be a single way of poping up pages
// from other pages. 
//
// all functions below must call the function showModalDialog
// found in modal.js. The paramters are as follows:
// showModalDialog(url,height,weight,scrollbar true/false)
//=================================================================

//details page
//-----------------------------------------------------------------
function showDetails(strURL) {
  var showDetails = window.open(strURL, (new Date()).getTime(), "width=875,height=550,resizable=yes");
  return showDetails; 
}



// Routes: View Routes
//-----------------------------------------------------------------
//
function popupViewRoutes(url) {
 var popupViewRoutes =  showModalDialog(url, 430, 220, true);
 return popupViewRoutes;
}


// Route View Screen
//-----------------------------------------------------------------
//
function popupReviewRoute(argRouteId, argBusId) {
 var url ="emxengchgCreateRouteDefiningFrameset.jsp?routeId="+argRouteId+"&busId="+argBusId+"&mode=review";
 var popupReviewRoute =  showModalDialog(url, 800, 620, true);
 return popupReviewRoute;
}


// Routes: View Life-Cycle Signatures
//-----------------------------------------------------------------
//
function popupViewSignatures(argBusId) { 
  var  url = "emxrouteSignatureStatus.jsp?busId=" + argBusId ;

//function popupViewSignatures(argBusId,argFromState,argToState,isInCurrentState,TargetPage) { 
//  var  url = "emxrouteSignatureStatus.jsp?busId=" + argBusId ;
//  url = url + "&fromState=" + argFromState + "&toState=" + argToState ;
//  url = url + "&isInCurrentState=" + isInCurrentState + "&targetPage=" + TargetPage ; 
 
 var popupViewSignatures =  showModalDialog(url, 630, 420, true);
 return popupViewSignatures;
}



//-----------------------------------------------------------------
//  
//  Help About Page
//
function popupUserProfile() { 
   showModalDialog("emxpersonBasicsView.jsp", 730, 520, false);
}


// Change Owner 
//-----------------------------------------------------------------
// emxProgramAbout.jsp 
//  Help About Page
//
function popupChangeOwner() { 
   showModalDialog("emxChangeOwner.jsp", 350, 300, false);
}


//Help About
//-----------------------------------------------------------------
// emxProgramAbout.jsp 
//  Help About Page
//
function popupHelpAbout() { 
   showModalDialog("emxProgramAbout.jsp", 730, 520, false);
}

//Send Mail Functions
//-----------------------------------------------------------------
// emxCompWriteMailDialog.jsp 
// Compose a new mail 
//
function popupWriteMailDialog() { 
   showModalDialog("emxCompWriteMailDialog.jsp", 730, 520, true);
}


//Send Mail Functions
//-----------------------------------------------------------------
// emxCompSendMail.jsp requires the following parameters
//  All parameters below are required 
//
//  busId = ArrayList containing all the attachments or BO to send
//  Message -   body of message 
//  txtToAddress - to list (comma)
//  txtCcAddress  - cc list
//  txtSubject - title of message
// 
// param = 'Message=ddddd&txtToAddress=&txtCcAddress&txtSubject='
function popupSendMail(param) {
 

  if ( param == null ) {
     showModalDialog("emxCompWriteMailDialog.jsp", 730, 520, true);
  } else { 
     showModalDialog("emxCompSendMail.jsp?" + param, 730, 520, true);
  }
}




//Project Basic View
//-----------------------------------------------------------------
// emxprojectBasicsView.jsp 
// Project Basic view page
// busId == project id
// params  = "&mode=view&page=1" 
//    mode = popup/view/edit
//
function popupProjectBasicView(busId, param) {
 var url = "emxprojectBasicsView.jsp?busId=" + busId; 
  if ( param != null ) {
     url = url + param; 
  }
  
     showModalDialog(url, 730, 520, true);
  
}



//Project Task View Page 
//-----------------------------------------------------------------
// emxprojectTasksView.jsp requires the following parameters
// 
//  busId = top level parent to display
//  param = concatenated string starting with the & 
//     parentId
//     displayType
//     ilevels
//     sTabName
//     message

function popupProjectWBS(busId, param) {
  var url = "emxprojectTasksView.jsp?busId=" + busId; 
  if ( param != null ) {
     url = url + param; 
  }
  
  showModalDialog(url, 600, 200, true);
}


//Discussions Popup
//-----------------------------------------------------------------
// emxMessageList.jsp requires the following parameters
// 
//  busId = top level parent to display
//  param = a concatanation of the following parameters
//     mode = null if view only, edit if edit moder
//     projectId = parent id
//     targetPage = page to foward to
//     isProject = boolean true/false if busId is the parent id 
//
 
function popupThreads(param) {
  var url = "emxMessageList.jsp"; 
  if ( param == null ) {
     alert("Error in page - busId is missing from parameter list. Please contact your system adminstrator.");
     return;
  }
  // showModalDialog(url, 710, 310, true);

  url = url + param; 
  openWindow(url,50,40);
}



//Task Deliverable Popup
//-----------------------------------------------------------------
// emxtaskDeliverableView.jsp requires the following parameters
// 
//  busId = top level parent to display
//  mode = null if view only, edit if edit mode
//  projectId = parent id
//  targetPage = page to foward to
//  isProject = boolean true/false if busId is the parent id 
//


function popupTaskDeliverables(busId, mode, projectId, isProject, targetPage) {
  var url = "emxtaskDeliverableView.jsp?mode=" + mode + "&busId=" + busId + "&projectId=" + projectId;
  url = url + "&targetPage=" + targetPage + "&isProject=" + isProject ;
  showModalDialog(url, 680, 280, true);
}


//Task Assignee Popup
//-----------------------------------------------------------------
// emxtaskAssigneeView.jsp requires the following parameters
// 
//  busId = top level parent to display
//  mode = null if view only, edit if edit mode
//  projectId = parent id
//  targetPage = page to foward to
//  isProject = boolean true/false if busId is the parent id 
//
function popupTaskAssignee(busId, mode, projectId, isProject, targetPage) {
  var url = "emxtaskAssigneeView.jsp?mode=" + mode + "&busId=" + busId + "&projectId=" + projectId;
  url = url + "&targetPage=" + targetPage + "&isProject=" + isProject ;
  showModalDialog(url, 710, 310, true);
  
}



//Assignee Pages Popup


//-----------------------------------------------------------------
// emxtaskAssigneesProjectMembersSearch.jsp requires the following parameters
// 
//  busId = top level parent to display
//  mode = null if view only, edit if edit mode
//  projectId = parent id
//  targetPage = page to foward to
//  isProject = boolean true/false if busId is the parent id 
//
function popupAssigneeMemberSearch(busId, mode, projectId, isProject, targetPage) {
  var url = "emxtaskAssigneesProjectMembersSearch.jsp?mode=" + mode + "&busId=" + busId + "&projectId=" + projectId;
  url = url + "&targetPage=" + targetPage + "&isProject=" + isProject ;
  var winDialog = showModalDialog(url, 680, 280, true);
  
}



//-----------------------------------------------------------------
// emxtaskAssigneesSearchDialog.jsp requires the following parameters
// 
//  busId = top level parent to display
//  mode = null if view only, edit if edit mode
//  projectId = parent id
//  targetPage = page to foward to
//  isProject = boolean true/false if busId is the parent id 
//
function popupAssigneeEmployeeSearch(busId, mode, projectId, isProject, targetPage) {
  var url = "emxtaskAssigneesSearchDialog.jsp?mode=" + mode + "&busId=" + busId + "&projectId=" + projectId;
  url = url + "&targetPage=" + targetPage + "&isProject=" + isProject ;
  showModalDialog(url, 680, 280, true);
  
}


