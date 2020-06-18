/* global define */
define('DS/StuCID/StuUIActorNA', ['DS/StuCID/StuUIActor'], function (UIActor) {
	'use strict';

	UIActor.prototype.getUIBinder = function () {
		return UI;
	};

	UIActor.prototype.getCtl = function () {
		return this.ctl;
	};

	UIActor.prototype.__parseProperties = function (iObject, iProperties, iSource) {
		var propertyType;

		// ES::Object: CATPixelImage <-> STU.PictureResource
		if (iProperties.__configurationName__ == "CXPImage") {
			Object.defineProperty(iObject, "image", {
				enumerable: true,
				configurable: true,
				get: function () {
					return iProperties["image"];
				},
				set: function (value) {
					iProperties["image"] = value;
					iSource["image"] = value.getPixelImage();
				}
			});
		}

		// parse all properties of given iObject
		for (var propertyName in iProperties) {
			// check if the property exist on the iSource
			if (iSource[propertyName] !== undefined) {
				if (typeof iProperties[propertyName] !== "object") {
					if (!(STU.isEKIntegrationActive()) || (propertyName !== "_varName")) {
						// property is a basic type (string, number, bool, ...)
						(function (iObject, iPropertyName, iSource) {
							Object.defineProperty(iObject, iPropertyName, {
								enumerable: true,
								configurable: true,
								get: function () {
									return iSource[iPropertyName];
								},
								set: function (value) {
									iSource[iPropertyName] = value;
								}
							});
						})(iObject, propertyName, iSource);
					}
				}
					// the property is a complex type (object, array, vector, color, ...)
				else {
					// read property type (property.name)
					propertyType = iProperties[propertyName].name;

					// Color_Spec: CATVidRGBA <-> STU.Color
					if (propertyType === "Color_Spec") {
						(function (iObject, iPropertyName, iSource) {
							Object.defineProperty(iObject, iPropertyName, {
								enumerable: true,
								configurable: true,
								get: function () {
									var colorRGBA = iSource[iPropertyName].split(" ").map(function (item) { return parseInt(item, 10) });
									return new STU.Color(colorRGBA[0], colorRGBA[1], colorRGBA[2]);
								},
								set: function (value) {
									iSource[iPropertyName] = value.r + " " + value.g + " " + value.b + " 255";
								}
							});
						})(iObject, propertyName, iSource);
					}

						// Vector2D_Spec: CATMathPoint2Df <-> DSMath.Vector2D
					else if (propertyType === "Vector2D_Spec") {
						(function (iObject, iPropertyName, iSource) {
							Object.defineProperty(iObject, iPropertyName, {
								enumerable: true,
								configurable: true,
								get: function () {
									var point2Df = iSource[iPropertyName].split(" ").map(function (item) { return parseFloat(item) });
									var vec2 = new DSMath.Vector2D();
									vec2.set(point2Df[0], point2Df[1]);
									return vec2;
								},
								set: function (value) {
									iSource[iPropertyName] = value.x + " " + value.y;
								}
							});
						})(iObject, propertyName, iSource);
					}

						// ES::Object: CATPixelImage <-> STU.PictureResource
					else if (iProperties[propertyName] instanceof STU.PictureResource) {
						(function (iObject, iPropertyName, iSource) {
							Object.defineProperty(iObject, iPropertyName, {
								enumerable: true,
								configurable: true,
								get: function () {
									return iProperties[iPropertyName];
								},
								set: function (value) {
									iProperties[iPropertyName] = value;
									iSource[iPropertyName] = value.getPixelImage();
								}
							});
						})(iObject, propertyName, iSource);
					}

						// ES::Object : ES::NativeObject <-> STU.Instance
					else if (iProperties[propertyName] instanceof STU.Instance) {
						(function (iObject, iPropertyName, iSource, iProperties) {
							Object.defineProperty(iObject, iPropertyName, {
								enumerable: true,
								configurable: true,
								get: function () {
									return iProperties[iPropertyName];
								},
								set: function (value) {
									iSource[iPropertyName] = value.CATI3DExperienceObject;
									iProperties[iPropertyName] = value;
								}
							});
						})(iObject, propertyName, iSource, iProperties);
					}

						// Array <-> Array (recursion)
					else if (iProperties[propertyName] instanceof Array) {
						if (iProperties[propertyName].length > 0 && iProperties[propertyName][0].name !== undefined) {
							iObject[propertyName] = new Array();
							for (var item in iProperties[propertyName]) {
								iObject[propertyName][item] = new Object();
								this.__parseProperties(iObject[propertyName][item], iProperties[propertyName][item], iSource[propertyName][item]);
							}
						}
						else {
							// default fallback, for array of basic type (e.g. list of string)
							iObject[propertyName] = iSource[propertyName];
						}
					}
				}
			}
		}

	};

	return UIActor;
});

define('StuCID/StuUIActorNA', ['DS/StuCID/StuUIActorNA'], function (UIActor) {
    'use strict';

    return UIActor;
});
