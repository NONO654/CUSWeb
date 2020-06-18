<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>Accesses</title>
<!--meta name="Microsoft Theme" content="network 1011"-->
<link rel="stylesheet" type="text/css" href="styles/emxUIHelp.css">
</head>

<body>
<div class="h1">
<img src="images/iconAccesses.gif" width="24" height="24">
</div>
<h1>Accesses</h1>
<h2>Definition</h2>
<p>Accesses are made of several components: <span class="keyword">Policies, Rules, Commands</span> and <span class="keyword">Masks</span></p>
<h3>Policies</h3>
<img class="h3" src="images/iconPolicies.gif">
<p>A Policy defines the lifecycle 
of objects (with states and branches) and their accesses. <br>
Each State of the lifecycle may have several Accesses, granting access to a P&amp;O 
object (Person, Context, Project, etc.) to perform some operations (Create, 
Read, Modify, etc.) under some condition (filter).</p>
<h3>Rules</h3>
<img class="h3" src="images/iconRules.gif" width="23" height="26">
<p>A Rule defines accesses to given relationships, like PLM Instances.<br>
&nbsp;</p>
<h3>Command</h3>
<img class="h3" src="images/iconCommands.gif">
<p>A VPLM Command is checked on the client side and is secured through a Matrix<span class="keyword"> 
Command</span> having the <span class="code">vplm::</span> prefix, and granting 
access to P&amp;O objects (Person, Context, Project, Role or Organization).</p>
<h3>Mask</h3>
<img class="h3" src="images/iconMasks.gif">
<p>A Mask is currently used to secure (restrict) access to 
objects attributes in the GUI.<br>
&nbsp;</p>
<p>Two aspects are managed:</p>
<h4>operation-independent access</h4>
<ul>
	<li>mandatory flag (a non mandatory attribute can be set as mandatory in 
	mask)</li>
<li>default value</li>
	<li>authorized (or help) values</li>
</ul>
<h4>operation-dependent access</h4>
<p>Given an operation (create, read, write, query, easy query, tree and list), </p>
<ul>
	<li>attributes list order</li>
<li>attribute's modifiable flag</li>
</ul>
<p>The public mask (delivered out-of-the-box) is named DEFAULT.<br>
It 
cannot be assigned to any P&amp;O object (because it does not need to).<br>
It is used when no other customized mask is defined on the current person's 
profile.</p>
<p>A customized mask is defined through a Matrix<span class="keyword"> 
Command</span> having the <span class="code">mask::</span> prefix, and granting 
access to P&amp;O objects (Person, Context, Project, Role or Organization).</p>
<!--
<h2>Related information</h2>
<ul class="related">
	<li><a href="emxPLMOnlineHelpOotbSMBAccess.jsp">Out-of-the-box SMB Accesses</a></li>
</ul>
-->

<p>&nbsp;</p>
</body>

</html>
