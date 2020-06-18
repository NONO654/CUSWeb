define('DS/DEL3DLeanViews/assets/enums/CollectionViewsEnum',
		[
			'DS/DEL3DLeanCollectionViews/ElementCollectionView',
			'DS/DEL3DLeanCollectionViews/FloatableCollectionView',
			'DS/DEL3DLeanCollectionViews/StaticCollectionView',
			'DS/DEL3DLeanCollectionViews/StaticCollectionViews/MapStaticCollectionView',
			'DS/DEL3DLeanCollectionViews/StaticCollectionViews/PageStaticCollectionView',
			'DS/DEL3DLeanCollectionViews/StaticCollectionViews/TeamPadStaticCollectionView'
		 ], function (
			 ElementCollectionView,
			 FloatableCollectionView,
			 StaticCollectionView,
			 MapStaticCollectionView,
			 PageStaticCollectionView,
			 TeamPadStaticCollectionView
		 ) {

	'use strict';

	/**
	 * @enum COLLECTIONVIEW
	 *
	 * Enum of the different collection view types
	 *
	 */
	var COLLECTIONVIEW = {

		ELEMENTCOLLECTIONVIEW:				ElementCollectionView,
		FLOATABLECOLLECTIONVIEW:			FloatableCollectionView,
		STATICCOLLECTIONVIEW:					StaticCollectionView,
		MAPSTATICCOLLECTIONVIEW:			MapStaticCollectionView,
		PAGESTATICCOLLECTIONVIEW:			PageStaticCollectionView,
		TEAMPADSTATICCOLLECTIONVIEW:	TeamPadStaticCollectionView

	};

	return COLLECTIONVIEW;
});
