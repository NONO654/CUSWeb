define('DS/StuModel/StuCollection', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
	'use strict';

    /**
     * Describe a STU.Collection which is a set object references.
     * Any experience object can be put in a collection, and retrieved from it.
     * The user can iterate on each object from a collection, for some specific usage.
     *     
     *
     * @exports Collection
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends STU.Instance
     * @memberof STU
	 * @alias STU.Collection
     */
	var Collection = function () {
		Instance.call(this);

		this.references = [];
		this.name = "Collection";
	};

	Collection.prototype = new Instance();
	Collection.prototype.constructor = Collection;
	
    /**
    * Add an object to this collection.
    * If this object is already in the collection, then this method does nothing.
    *
    * @method
    * @public
    * @param {STU.Instance} iObject the object that should be added to the collection
    * @return {STU.Collection} this collection
    * @see STU.Collection#removeObject
    */
	Collection.prototype.addObject = function ( iObject ) {
		STU.pushUnique(this.references, iObject);	
		return this;
	};

    /**
    * Remove an object from this collection.
    * If this object is not in the collection, then this method does nothing.
    *
    * @method
    * @public
    * @param {STU.Instance} iObject the object that should be removed from the collection
    * @return {STU.Collection} this collection
    * @see STU.Collection#addObject
    */
	Collection.prototype.removeObject = function ( iObject ) {
		STU.remove(this.references, iObject);	
		return this;
	};

    /**
    * Remove an object at a given position from this collection.
    * If this object is not in the collection, then this method does nothing.
    *
    * @method
    * @public
    * @param {number} iIndex index the object that should be removed from the collection
    * @return {STU.Collection} this collection
    * @see STU.Collection#addObject
    * @see STU.Collection#removeObject
    */
	Collection.prototype.removeObjectAt = function ( iIndex ) {	 
		this.references.splice(iIndex, 1);
		return this;
	};

    /**
    * Get the content of that collection in an array.
    *
    * @method
    * @public    
    * @return {Array.<STU.Instance>} content of the collection
    * @see STU.Collection#addObject
    * @see STU.Collection#removeObject
    */
	Collection.prototype.getObjects = function () {
	    return this.references.slice(0);
	};

    /**
    * Set the content of that collection with an array of objects.
    *
    * @method
    * @public    
    * @param {Array.<STU.Instance>} iObjects new content of the collection
    * @return {STU.Collection} this collection
    * @see STU.Collection#addObject
    * @see STU.Collection#removeObject
    */
	Collection.prototype.setObjects = function (iObjects) {
		this.references = iObjects;
		return this;
	};

    /**
    * Get the number of object within that collection.
    *
    * @method
    * @public        
    * @return {number} object count
    * @see STU.Collection#getObjectAt    
    */
	Collection.prototype.getObjectCount = function () {
		return this.references.length;
	};

    /**
    * Get an object at a given position in the collection.
    *
    * @method
    * @public    
    * @param {number} iIndex position of the desired object
    * @return {STU.Instance} object at given position
    * @see STU.Collection#getObjectCount    
    */
	Collection.prototype.getObjectAt = function (iIndex) {
		return this.references[iIndex];
	};

    /**
    * Return the experience
    * @method
    * @public
    * @return {STU.Experience} instance object corresponding to the experience
    */
	Collection.prototype.getExperience = function () {
	    return STU.Experience.getCurrent();
	};

    /**
    * Empties the collection.
    *
    * @method
    * @public        
    * @return {STU.Collection} this collection    
    */
	Collection.prototype.empty = function () {
	    this.references = [];
	    return this;
	};

    /**
    * Tells if the collection contains an object.
    *
    * @method
    * @public        
    * @param {STU.Instance} iObject the object
    * @return {boolean} object count    
    */
	Collection.prototype.contains = function (iObject) {
	    for (var i = 0; i < this.references.length; i++) {
	        if (this.references[i] === iObject) {
	            return true;	            
	        }
	    }
	    return false;
	};
	
	// Expose in STU namespace.
	STU.Collection = Collection;

	return Collection;
});

define('StuModel/StuCollection', ['DS/StuModel/StuCollection'], function (Collection) {
    'use strict';

    return Collection;
});
