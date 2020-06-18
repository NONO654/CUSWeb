//=================================================================
// JavaScript Object Manager
// Version 1.1
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================
// History
//-----------------------------------------------------------------
// January 18, 2002 (Version 1.1)
// 	- Removed file/directory references.
//  - Removed browser detection.
//  - Removed tree functions.
// July 27, 2001 (Version 1.0)
// 	- Works in Netscape 4.x and IE 4.0+
//=================================================================

//=================================================================
// Part 1: Object Definitions
//=================================================================
// This section defines the objects that control the navbar
// and should not be modified in any way.  Doing so could cause
// the navbar to malfunction.
//=================================================================

//-----------------------------------------------------------------
// Object jsObjectManager
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 7/27/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This object manages other objects in the application.
//
// PARAMETERS
//  (none)
//-----------------------------------------------------------------
function jsObjectManager() {

	//navbars
	this.navbars = new Array;
	
	//application name
	this.appID = "";
	
	//URL store - used to store URLs for navbar, tree, content, etc.
	this.URLs = new Array;
	
	//navbar methods
	this.getNavBar = _jsObjectManager_getNavBar;
	this.createNavBar = _jsObjectManager_createNavBar;
	this.eraseNavBar = _jsObjectManager_eraseNavBar;
	this.isNavBar = _jsObjectManager_isNavBar;
	
}

//-----------------------------------------------------------------
// Method jsObjectManager.getNavBar()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 7/27/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This method gets a pointer to a navbar with a given name.
//
// PARAMETERS
//  strName (String) - the name of the navbar to retrieve.
//
// RETURNS
//  A pointer to a jsNavBar object, null if the name is not found.
//-----------------------------------------------------------------
function _jsObjectManager_getNavBar(strName) {
	return this.navbars[strName];
}

//-----------------------------------------------------------------
// Method jsObjectManager.isNavBar()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 7/27/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This method returns true if the navbar with the given name exists,
//  false if it doesn't.
//
// PARAMETERS
//  strName (String) - the name of the navbar to check.
//
// RETURNS
//  A boolean: true if the navbar with the given name exists, false if it doesn't.
//-----------------------------------------------------------------
function _jsObjectManager_isNavBar(strName) {
	return this.navbars[strName] != null;
}

//-----------------------------------------------------------------
// Method jsObjectManager.isNavBar()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 7/27/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This method erases a navbar with the given name from memory.
//
// PARAMETERS
//  strName (String) - the name of the navbar to erase.
//
// RETURNS
//  (nothing)
//-----------------------------------------------------------------
function _jsObjectManager_eraseNavBar(strName) {
	
	//delete the navbar (NCZ, 7/27/01)
	delete this.navbars[strName];
	
	//set the pointer to null (NCZ, 7/27/01)
	this.navbars[strName] = null;
}

//-----------------------------------------------------------------
// Method jsObjectManager.createNavBar()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 7/27/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This method creates a navbar with the given name.
//
// PARAMETERS
//  strName (String) - the name of the navbar to create.
//  strStylesheet (String) - the stylesheet file (without path) to use.
//
// RETURNS
//  A pointer to a jsNavBar object.
//-----------------------------------------------------------------
function _jsObjectManager_createNavBar(strName, strStylesheet) {
	this.navbars[strName] = new jsNavBar(strName, strStylesheet);
	return this.navbars[strName];
}

//=================================================================
// Part 2: Object Creation
//=================================================================

//instantiate object manager
var objMgr = new jsObjectManager;
