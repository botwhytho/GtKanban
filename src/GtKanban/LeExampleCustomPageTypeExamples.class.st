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
	"database monitor
		storage: (LeMockLocalJsonV4StorageWithMissingSerializers new
				removeSerializers: {LeExampleCustomPageType})."
	database addPage: LeExampleCustomPageType samplePage.
	self assert: database pages size = 1.
	^ database
]

{ #category : #example }
LeExampleCustomPageTypeExamples >> deregisterCustomPageTypeAndReloadDatabase [
	<gtExample>
	| database |
	database := self databaseWithSamplePage.
"	database pagesByType removeKey: LeExampleCustomPageType."
	database reload.
	^ database
]
