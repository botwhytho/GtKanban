Class {
	#name : #LeExampleCustomPageTypeExamples,
	#superclass : #Object,
	#category : #'GtKanban-Examples'
}

{ #category : #example }
LeExampleCustomPageTypeExamples >> databaseWithSamplePage [
	<gtExample>
	| database |
	database := LeDatabaseWithLocalMonitorExamples new databaseWithMonitor.
	database monitor
		storage: (LeMockLocalJsonV4StorageWithMissingDeserializers new
				deserializersToRemove: {LeExampleCustomPageType}).
	database addPage: LeExampleCustomPageType samplePage.
	self assert: database pages size = 1.
	^ database
]

{ #category : #example }
LeExampleCustomPageTypeExamples >> deregisterCustomPageTypeAndReloadPage [
	<gtExample>
	| database exception |
	database := self reloadPage.
	database monitor storage leJsonV4 disableDeserializers.
	[database monitor reloadPage: database pages first] on: LeDBLoadError do: [ :ex | exception := ex].
	self assert: exception isNotNil.
	self flag: #TODO. "Remove above error handling"
	self
		assert: (database pages first type isKindOf: LeExampleCustomPageType"LeUnknownNamedPageType")
		description: 'A page with a title and an unknown page type most be loaded into the database as a page with type `LeUnknownNamedPageType`'.
	^ database
]

{ #category : #example }
LeExampleCustomPageTypeExamples >> reloadPage [
	<gtExample>
	| database |
	database := self databaseWithSamplePage.
	database monitor reloadPage: database pages first.
	self assert: (database pages first type isKindOf: LeExampleCustomPageType).
	^ database
]
