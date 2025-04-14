Class {
	#name : #LeMockLocalJsonV4StorageWithMissingSerializers,
	#superclass : #LeLocalJsonV4Storage,
	#instVars : [
		'removeSerializers'
	],
	#category : #'GtKanban-LocalJSON-Store'
}

{ #category : #accessing }
LeMockLocalJsonV4StorageWithMissingSerializers >> removeSerializers [
	^ removeSerializers
]

{ #category : #accessing }
LeMockLocalJsonV4StorageWithMissingSerializers >> removeSerializers: aCollection [
	removeSerializers := aCollection
]

{ #category : #saving }
LeMockLocalJsonV4StorageWithMissingSerializers >> serialize: anObject on: aStream prettyPrint: aBoolean [
	| aWriter |
	aWriter := LeJsonV4 uniqueInstance newWriter.
	self removeSerializers do: [ :each | aWriter mappings removeKey: each ].
	aWriter
		on: aStream;
		prettyPrint: aBoolean;
		nextPut: anObject
]
