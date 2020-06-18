/*
   emxLifeCycleUtil.js   - This Page is the javascript include to support Lifecycle
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

*/

//-----------------------------------------------------------------
// Method openHelp()
// This function opens a window and requests context sensitive help.
//
// Parameters:
//   pageTopic - The Helpmarker to index into page with
//   directory - Directory Pages are under
//   langStr - The language To Use
// Returns:
//  nothing.
//-----------------------------------------------------------------

                        var printDialog = null;
            
            function openPrinterFriendlyPage(){
                var strURL = "";
                currentURL = frames['pagecontent'].document.location.href;
                if (currentURL.indexOf("?") == -1){
                    strURL = currentURL + "?PFmode=true";
                }else{
                    strURL = currentURL + "&PFmode=true";
                }
            
                //make sure that there isn't a window already open
                if (!printDialog || printDialog.closed){
                    var strFeatures = "scrollbars=yes,toolbar=yes,location=no,resizable=yes";
                    printDialog = window.open(strURL, "PF" + (new Date()).getTime(), strFeatures);
            
                    //set focus to the dialog
                    printDialog.focus();
                }else{
                    //if there is already a window open, just bring it to the forefront (NCZ, 6/4/01)
                    if (printDialog){
                        printDialog.focus();
                    }
                }
            }
                        
						function lockPromote(promotelink)
						{               
														turnOnProgress();
														lockDoubleClick(promotelink);
						}

						function lockDemote(demotelink)
						{
														turnOnProgress();
														lockDoubleClick(demotelink);
						}

						function lockDoubleClick(promote_demote_link)
						{
														if (jsDblClick()) 
														{  
																						var hiddenLifecycle;
																						var lifecycleFrame;
																						var detailsDisplayFrame = getTopWindow().findFrame(getTopWindow(), "detailsDisplay");
																						if(detailsDisplayFrame){
																							hiddenLifecycle = getTopWindow().findFrame(detailsDisplayFrame, "hiddenLifecycle");
																							lifecycleFrame = getTopWindow().findFrame(detailsDisplayFrame, "pagecontent");
																						}else{
																							hiddenLifecycle = getTopWindow().findFrame(getTopWindow(), "hiddenLifecycle");
																							lifecycleFrame = getTopWindow().findFrame(getTopWindow(), "pagecontent");
																						}

																						var link = promote_demote_link;

																						if (hiddenLifecycle && lifecycleFrame) {

																							 lifecycleFrame.document.lifecycledialog.target=hiddenLifecycle.name;
																							 lifecycleFrame.document.lifecycledialog.action=link;
																							 lifecycleFrame.document.lifecycledialog.submit();
																						}
														}
						}                     
