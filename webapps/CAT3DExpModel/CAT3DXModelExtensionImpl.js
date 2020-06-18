/**
 * @exports DS/CAT3DExpModel/CAT3DXModelExtensionImpl
*/
define('DS/CAT3DExpModel/CAT3DXModelExtensionImpl',
[
	'UWA/Core'
],

// Declaration
function (
	UWA
	) {
	'use strict';


	/**
	* @name DS/CAT3DExpModel/CAT3DXModelExtensionImpl
	* @description 
	* Base Class to manage JSON dictionaries. Its main role is to store JSON dictionaries.
	*
	* <p>There are different kind of dictionaries : </p>
		<ul>
			<li><b>Model dictonary : </b>They describe components.
			For each component, the dictionary provides a name, a prototypal chain to define inheritance and variables.
			Use <i>GetComponents()</i></li>
			<li><b>Interface dictionary : </b>List Interfaces.
			Use <i>AddInterfaces()</i></li>
			<li><b>Component Extensions dictionary : </b>List interface implementations.
			Use <i>AddSpecExtensions()</i></li>
		</ul>
	* @constructor
	*/

	var CAT3DXModelExtensionImpl = UWA.Class.extend(
	/** @lends DS/CAT3DExpModel/CAT3DXModelExtensionImpl.prototype **/
	{
	    GetComponents: function () {
	    	return [];
	    },

	    GetInterfaces: function () {
	        return [];
	    },

	    GetExtensions:function(){
	        return [];
	    },

	    GetManagers :function(){
	        return [];
	    }
	});
	return CAT3DXModelExtensionImpl;
});
