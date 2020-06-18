
/*@quickreview d9u 7/22/2014 fixed bug that caused permission denied error when uploading in IE (created case with invalid dataset) */	

if(typeof $simjq=='undefined') {
	 $simjq = jQuery.noConflict();
}

// ---------------------------------------------------------
// creates a single row with file selection button and label;
// used from inside iFrame (smaAdviseImportDataSetBody.jsp)
// ---------------------------------------------------------
function createImportRow() {

	var contentDiv = $simjq("#resIntImportDataSetRootDiv");
	var form = $simjq('#importForm');
	var fileInput = form.find('input[type=file]');
	var caseTitle = form.find('input[name=caseTitle]');

	//-----------------------------
	// configure a change (selection) callback on the file input field
	//-----------------------------
	fileInput.change(function() {

		var filename = fileInput.val().split('\\').pop().split('/').pop();

		// this only happens when a file was previously selected,
		// and the user clicks Cancel on file selection dialog;
		// we don't need the alert msg, just return "invalid" signal here
		if (filename.length < 1) {
			//alert("File must be selected");
			return;
		} 

		// get file extension from name
		var extension = filename.split('.').pop().toLowerCase();

		// validate
		if (extension != 'zrf' && extension != 'csv' && extension != 'xls' && extension != 'xlsx' && extension != 'nrf' && extension != 'tsv' && extension != 'zip') {
			alert('Unsupported file type: "' + extension.toUpperCase() + '"' +
					'\n\nAllowed file types: "ZRF", "CSV", "XLS", XLSX", "NRF", "TSV", "ZIP"');
			$simjq('#fileNameDisplay').text('');
			return;
		};

		$simjq('#fileNameDisplay').text(filename);
	});

	// Create a table to hold and format content
	var contentTable = $simjq('<table class="sim-ui-importPage-contentTable">').appendTo(contentDiv);
	var tableBody = $simjq('<tbody>').appendTo(contentTable);

	// Create one table row with a button and file name label
	var importRow = $simjq('<tr style="height:28px;">').appendTo(tableBody);

	var importTitleCell = $simjq('<td class="contentCell" style="width:80px;">').appendTo(importRow);
	var fileInputID = fileInput.attr('id');
	if(typeof fileInputID === 'undefined'){
		fileInputID = 'ra-fileuploadinput';
		fileInput.attr('id',fileInputID);
	}
	var importButton = $simjq('<label />',{
		'for': fileInputID, 
		'text': 'Choose File', 
		'style': 'white-space: pre;color: #5b5d5e; margin: 0 3px 0 0;' +
			'padding: 2px; border: 1px solid #b4b6ba; border-radius: 2px; ' +
			'-moz-border-radius: 2px; -webkit-border-radius: 2px; box-sizing: ' +
			'border-box; font-family: Arial, Helvetica, sans-serif; line-height: 13px;' +
			'-webkit-align-items: flex-start; align-items: flex-start; text-align: center; cursor: default;' +
			'background-color: buttonface; display: inline-block; '
		}).appendTo(importTitleCell);
	// the above styles are attempting to make the label look like a button
	
	//var importButton = $simjq('<input type="button" value="Choose File">').appendTo(importTitleCell);
	// forward the click event from this button to the hidden input form;
	// the form will invoke a file selection dialog and store the file object
//	importButton.click(function(){
//		fileInput.trigger('click');
//	});

	importContentCell = $simjq('<td class="contentCell">').appendTo(importRow)
	$simjq('<label id="fileNameDisplay">').appendTo(importContentCell);

};

// ----------------------------------------------------
// main action routine - creates business objects for
// Analytics Case (when needed) and Document(s), and
// checks in all selected files into the Document(s);
//
// to check-in a file, each hidden single row form (inside an iFrame)
// is submitted; the forms call Enovia check-in webservice;
//
// this routine is called recursively multiple times to submit all forms
// (first call from Done button, following calls from
// checkForReceipt() function after each form is submitted
// and check-in receipt is received)
// ----------------------------------------------------
function submitForm(submitFormArgs) {
	
	// first call may have no arguments
	submitFormArgs = submitFormArgs || {};
	submitFormArgs.index = submitFormArgs.index || 0;
	if(submitFormArgs.separateDocuments == undefined) {
		submitFormArgs.separateDocuments = true;
	}
	
	// advance to the next file input iFrame
	submitFormArgs.index += 1;
	
	var frameName = 'checkinFrame' + submitFormArgs.index;
	var frameDiv = '#checkinDiv' + submitFormArgs.index;

	// return when all frames have been processed
	if( $simjq(frameDiv).length == 0 ) {
		// if document ID is not defined, we did not have any files selected
		// and did not create anything, no update needed
		if(submitFormArgs.documentOID) {
			// when invoked from "Import" dialog
			if(!submitFormArgs.documentOnly) {
				// simply refresh the "landing page", it will display the new case
				getTopWindow().opener.location.reload();
			}
			// when invoked from "Create" dialog
			else {
				// send document ID and title to the caller window
				var caller = $simjq(getTopWindow().opener.document);
				caller.find('#divPageBody table.form td input[name="Files on Disk"]').val(submitFormArgs.documentIdArray.join('; '));
				caller.find('#divPageBody table.form td input[name="Files on DiskOID"]').val(submitFormArgs.documentIdArray.join('; '));
				caller.find('#divPageBody table.form td input[name="Files on DiskDisplay"]').val(submitFormArgs.documentNameArray.join('; '));
			}
		}
		getTopWindow().close();
		return;
	}
	
	// select the next iFrame and get file from it (use the label instead of the
	// input form because the input form MAY have an incorrect/unsupported file
	// name selected while the label will show empty string!)
	var filename = window.frames[frameName].document.querySelector('label#fileNameDisplay').textContent;
	if(!filename) {
		// no file name in this frame, go to the next frame/file
		$simjq(frameDiv).hide();
		submitForm(submitFormArgs);
		return;
	}

	
	// file type (based on file name extension)
	var ftype = "binary";
	if(filename.split('.').pop().toLowerCase() == "csv") {
		ftype = "text"
	}
	
	// case title entry (may be empty)
	var caseTitle = null;
	if(!submitFormArgs.documentOnly) {
		caseTitle = $simjq('#sim-ui-importPage-caseTitle').val();
	} else {
		var caseTitleInput = getTopWindow().opener.document.querySelector('#divPageBody table.form td input[name=Title]');
		caseTitle = $simjq(caseTitleInput).val();
	}
	
	// tempDiv is used to execute a JSP file for getting a ticket
	var tempDiv = $simjq("<div>");

	// this JSP creates Analytics Case (when needed), Document object (when needed)
	// and gets a ticket for checking in a file into the Document
	var loadURL = "../simulationcentral/smaAdvisePreprocessDatasetImport.jsp?fname="+encodeURIComponent(filename)+"&ftype="+ftype;

	// document already created, we are only attaching another file to it;
	if(submitFormArgs.documentOID && !submitFormArgs.separateDocuments) {
		// send doc ID to the JSP; doc title is empty string (not used by JSP in this scenario)
		loadURL += '&documentOID='+submitFormArgs.documentOID+'&documentTitle=';
	}

	// we are creating a new document
	else {
		
		if(!submitFormArgs.separateDocuments) {

			// find out if there are multiple files selected;
			// go through all iFrames and count non-empty files;
			// this should be executed only once on the first form submission
			if(submitFormArgs.nFiles == undefined) {
				submitFormArgs.nFiles = 0;
				var nFrames = $simjq('.checkinWrapperDiv').length;
				for(var i=1; i<=nFrames; i++) {
					var frName = 'checkinFrame' + i;
					if(window.frames[frName].document.querySelector('label#fileNameDisplay').textContent) {
						submitFormArgs.nFiles++;
					}
				}
			};

			// generate Doc name (and case title if invoked from Import dialog)
			// if empty string, doc name will be generated by JSP from the data file name
			submitFormArgs.docName = '';
			var date = new Date();
			var dateString = date.toDateString() + ' ' + date.toLocaleTimeString();

			// when invoked from "Create" dialog, we must not create/alter case title
			if(submitFormArgs.documentOnly) {
				if(caseTitle) {
					submitFormArgs.docName = 'Doc - Data Files for ' + caseTitle;
				}
				else if(submitFormArgs.nFiles > 1) {
					submitFormArgs.docName = 'Doc - Data Files - ' + dateString;
				}
				else {
					submitFormArgs.docName = 'Doc - ' + filename.replace(/\./g,'_');
				}
				caseTitle = null;
			}
			// when invoked from "Import" dialog, we can generate case title also if needed
			else {
				if(!caseTitle) {
					caseTitle = 'Analytics Case - ' + dateString;
				}
				if(submitFormArgs.nFiles > 1) {
					submitFormArgs.docName = 'Doc - Data Files for ' + caseTitle;
				}
				else {
					submitFormArgs.docName = 'Doc - ' + filename.replace(/\./g,'_');
				}
			}
		}
		
		// separate documents for every file
		else {
			submitFormArgs.docName = 'Doc - ' + filename.replace(/\./g,'_');
			if(!caseTitle) {
				var date = new Date();
				var dateString = date.toDateString() + ' ' + date.toLocaleTimeString();
				caseTitle = 'Analytics Case - ' + dateString;
			}
		}

		loadURL += '&documentTitle='+encodeURIComponent(submitFormArgs.docName);
			
		if(!submitFormArgs.documentOnly && !submitFormArgs.caseOID) {
			$simjq('#sim-ui-importPage-caseTitle').hide();
			$simjq('#sim-ui-importPage-caseTitleCell').prepend('<p>Creating Analytics Case "' + caseTitle + '"...</p>');
		}

	}

	// invoked from "Create" dialog
	if(submitFormArgs.documentOnly) {
		loadURL += '&ctitle=NOCASECREATED'; // disable case creation, JSP checks for this
	}
	// invoked from "Import" dialog
	else {
		if(submitFormArgs.caseOID && submitFormArgs.separateDocuments) {
			loadURL += '&ctitle=NOCASECREATED'; // disable case creation, JSP checks for this
			loadURL += '&caseOID=' + submitFormArgs.caseOID; // connect to this case object
		}
		else {
			loadURL += '&ctitle='+encodeURIComponent(caseTitle);
		}
	}
	//console.log(loadURL);
	
	// call the JSP, wait for return;
	// this JSP creates Analytics Case (when needed), Document object (when needed)
	// and gets a ticket for checking in a file into the Document
	tempDiv.load(loadURL, function(response, status, xhr) {
		
		if ( status == 'error' ) {
			 alert('Error when getting a file checkin ticket for "' + filename + '" \n\n' + xhr.status + '\n' + xhr.statusText);
			 getTopWindow().close();
			 return;
		}

		//console.log(tempDiv.html());
		submitFormArgs.documentOID = $simjq(tempDiv).find(".documentID").text();
		//console.log(objectID);
		submitFormArgs.caseOID = $simjq(tempDiv).find(".caseID").text();
		//console.log(caseID);
		var fileName = $simjq(tempDiv).find(".fileName").text();
		//console.log(fileName);
		var ticket = $simjq(tempDiv).find(".ticket").find("ticket").attr("exportstring");
		//console.log(ticket);
		
		var actionURL = $simjq(tempDiv).find(".ticket").find("ticket").attr("actionurl");
		
		// set values in the form fields
		$simjq(window.frames[frameName].document).find('#objectIDField').val(submitFormArgs.documentOID);
		$simjq(window.frames[frameName].document).find('#ticketfield').val(ticket);
		
		// display a message instead of the file chooser button
		$simjq(frameDiv).hide();
		$simjq(frameDiv).before('<div><p style="margin-left:95px;margin-top:6px;height:30px;">Uploading file "' + fileName + '"...</p></div>');
	
		// launch a waiting loop for the receipt
		// aboutToSubmit(fileName, frameName, frameDiv, submitFormArgs);
		
		// submit the form - this calls the check-in servlet in Enovia
		// and fills in the body of the page (iFrame) with the receipt text
		// which is captured in the routine below
		var importForm = window.frames[frameName].document.querySelector('#importForm')

		$simjq(importForm).attr('action', actionURL);

		$simjq(importForm).submit(function(event){
			event.preventDefault();
			$simjq.support.cors = true;
			$simjq.ajax({
				url: $simjq(importForm).attr('action'),//or hardcode the FCS url here as 'http://server:8080/servlet/fcs/checkin'
				type: 'POST',
				data: new FormData($simjq(importForm)[0]),
				 xhr: function()
				  {
				    var xhr = new window.XMLHttpRequest();
				    //Upload progress
				    xhr.upload.addEventListener("progress", function(evt){
				      if (evt.lengthComputable) {
				        var percentComplete = parseInt(100 * evt.loaded / evt.total);
				        var message = 'Uploading file "' + fileName + '"... ('+percentComplete+'% done)'; 
				        if(percentComplete == 100) {
				        	message = 'File "' + fileName + '" uploaded.';
				        }
				        $simjq(frameDiv).prev().find('p').text(message);
				        console.log(percentComplete);
				      }
				    }, false);
				    return xhr;
				  },
				processData: false,
				contentType: false,
				success: function(data){
					console.log('form submitted.');
					console.log(data);
					commitReceipt(fileName, frameName, frameDiv, submitFormArgs, data) 
				}, 
				failure: function() {
					console.error("failed to submit the form");
					console.log(arguments);
				}
			});
			return false;
		});

		$simjq(importForm).submit();
		
	});
	
}
/*
 * sd4 - this is new code when FCS=/=MCS & FCS has cors enabled
 */
function commitReceipt(fileName, frameName, frameDiv, submitFormArgs, receipt) {
	if(receipt.length > 0 && receipt.toLowerCase().indexOf("error")<0) {
		//console.log("we seem to have a valid receipt");
		// stop the waiting loop
		receipt = receipt.trim();
		receipt = receipt.replace(/\+/g, "__");
		//console.log('===FCSreceipt:');
		//console.log(receipt);

		// call another JSP sending the receipt text to commit the check-in
		var commitURL = "../simulationcentral/smaAdvisePostprocessDatasetImport.jsp?receipt="+receipt+"&fname="+fileName;
		$simjq(frameDiv).load(commitURL, function(response, status, xhr) {
			
			if ( status == 'error' || $simjq(frameDiv).text().trim().toLowerCase().indexOf('error') >= 0) {
				 alert('Error when uploading file "' + fileName + '" \n\n' + xhr.status + '\n' + xhr.statusText);
				 getTopWindow().close();
				 return;
			}
			
			// successful upload/commit; append the new document ID and name to the lists
			submitFormArgs.documentIdArray = submitFormArgs.documentIdArray || [];
			submitFormArgs.documentNameArray = submitFormArgs.documentNameArray || [];
			submitFormArgs.documentIdArray.push(submitFormArgs.documentOID);
			submitFormArgs.documentNameArray.push(submitFormArgs.docName);

			// we are done  with this file;
			// upload the next file
			submitForm(submitFormArgs);
			return;
		});			
	}
}

//-------------------------------------------------------------------------------------
// launches a waiting loop for submitting a form and getting receipt from Enovia servlet
//-------------------------------------------------------------------------------------
function aboutToSubmit(fileName, frameName, frameDiv, submitFormArgs) {
	
	var waitLoop =  setInterval(function() {
		checkForReceipt(waitLoop, fileName, frameName, frameDiv, submitFormArgs);
	}, 200);

};

//-------------------------------------------------------------------------------------
// this function is called from the waiting loop above; checks the iFrame for
// receipt form Enovia, and commits the check-in, then calls submit on the next iFrame
//-------------------------------------------------------------------------------------
function checkForReceipt(waitLoop, fileName, frameName, frameDiv, submitFormArgs) {

	//console.log("checking for receipt");
	if(window.frames[frameName] && window.frames[frameName].document) {

		var doc = window.frames[frameName].document;
		
		// if we have input fields, the submission is not finished yet
		var inputs = doc.querySelectorAll('input');
		if(inputs.length && inputs.length>0){
			//console.log("We seem to be in the same old input form");
			return;
		}

		// when form submission is done, the servlet returns receipt and
		// it is stored in the 'body' of the iFrame
		var receipt = doc.querySelectorAll('body')[0].textContent;
		//console.log(receipt);
		if(receipt.length > 0 && receipt.toLowerCase().indexOf("error")<0) {
			//console.log("we seem to have a valid receipt");
			// stop the waiting loop
			clearInterval(waitLoop);
			receipt = receipt.trim();
			receipt = receipt.replace(/\+/g, "__");
			//console.log('===FCSreceipt:');
			//console.log(receipt);

			// call another JSP sending the receipt text to commit the check-in
			var commitURL = "../simulationcentral/smaAdvisePostprocessDatasetImport.jsp?receipt="+receipt+"&fname="+fileName;
			$simjq(frameDiv).load(commitURL, function(response, status, xhr) {
				
				if ( status == 'error' || $simjq(frameDiv).text().trim().toLowerCase().indexOf('error') >= 0) {
					 alert('Error when uploading file "' + fileName + '" \n\n' + xhr.status + '\n' + xhr.statusText);
					 getTopWindow().close();
					 return;
				}
				
				// successful upload/commit; append the new document ID and name to the lists
				submitFormArgs.documentIdArray = submitFormArgs.documentIdArray || [];
				submitFormArgs.documentNameArray = submitFormArgs.documentNameArray || [];
				submitFormArgs.documentIdArray.push(submitFormArgs.documentOID);
				submitFormArgs.documentNameArray.push(submitFormArgs.docName);

				// we are done  with this file;
				// upload the next file
				submitForm(submitFormArgs);
				return;
			});			
		}
	}
};

// ---------------------------------------------------------------------------
// callback for the "Add File" button; inserts a new iFrame for file selection
// ---------------------------------------------------------------------------
function addFileCallback() {
	// get index of the last frame, increment by 1
	var index = 1 + parseInt($simjq('.checkinWrapperDiv').last().attr('data-index'));
	// create new wrapper div, iframe
	var divId = 'checkinDiv' + index;
	var checkinWrapperDiv = $simjq('<div class="checkinWrapperDiv">').attr('id',divId).attr('data-index',index);
	var frameName = 'checkinFrame' + index;
	var checkinFrame = $simjq('<iframe src="smaAdviseImportDataSetBody.jsp">');
	checkinFrame.attr('name',frameName).attr('data-index',index).css({'width':'100%', 'height':'28px', 'min-height':'0px'});
	checkinWrapperDiv.append(checkinFrame);
	// append the checkin div to the end of the content wrapper frame
	$simjq('#sim-ui-importPage-iframeWrapperDiv').append(checkinWrapperDiv);

}

// ---------------------------------------------------------------------------
// callback for the "Submit" button of the "Create" dialog
// ---------------------------------------------------------------------------
function submitFormCreateFromFilesDialog() {
	submitForm({documentOnly:true, separateDocuments:true});
}

//---------------------------------------------------------------------------
// Added for IR-345257-3DEXPERIENCER2015x
// Timer function to allow the documents dialog buttons to load first before
// we create the buttons for files on disk form.
//---------------------------------------------------------------------------
function loadParentDialogAndCreateFilesDialog() {
	var timerFn = setInterval(function() {
		var bRow =  $simjq(getTopWindow().document).find('div#divPageFoot td.buttons').parent();
		if(bRow.find('.btn-primary').length > 0 &&
				bRow.find('.btn-default').length > 0){
			clearInterval(timerFn);
			configureCreateFromFilesDialog();
		}
	}, 500);
}

// ---------------------------------------------------------------------------
// initialization stuff for "Create" dialog only
// ---------------------------------------------------------------------------
function configureCreateFromFilesDialog() {
	
	// find the bottom table row with buttons
	var bottomRow = $simjq(getTopWindow().document).find('div#divPageFoot td.buttons').parent();
	var buttons2 = bottomRow.find('#sim-ui-createFromFiles-bottom-buttons');

	if(buttons2.length == 0) {
		// clone the buttons table and re-configure it
		buttons2 = bottomRow.find('td.buttons').clone();
		buttons2.attr('id','sim-ui-createFromFiles-bottom-buttons');
		buttons2.find('td:eq(0) a').attr('href','javascript:').click(submitFormCreateFromFilesDialog);
		buttons2.find('td:eq(0) a img').attr('src','../common/images/buttonDialogDone.gif');
		buttons2.find('td:eq(1) a').attr('href','javascript:').click(submitFormCreateFromFilesDialog);
		buttons2.find('td:eq(1) a').find('button').text('Submit');
		bottomRow.append(buttons2);
	}
	
	// hide the table cells with "Limit to..." and original buttons
	bottomRow.find('td.functions').hide();
	bottomRow.find('td.buttons').hide();
	// NOTE! the above also hides the new (cloned) buttons because they also have class="buttons";
	// show the new (cloned) table with buttons
	buttons2.show();
	
	// revert the change that we did above when our page is unloaded
	$simjq(window).unload(function () {
		bottomRow.find('td.functions').show();
		bottomRow.find('td.buttons').show();
		buttons2.hide();
	});
}

function closeTopWindow(){
	getTopWindow().closeWindow();
}
function submitFromFiles(){
	$simjq(document.body).append('<div class="blockingDiv" />');
	submitFormCreateFromFilesDialog();
}

