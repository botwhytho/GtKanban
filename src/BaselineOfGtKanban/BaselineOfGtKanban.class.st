Class {
	#name : #BaselineOfGtKanban,
	#superclass : #BaselineOf,
	#category : #BaselineOfGtKanban
}

{ #category : #loading }
BaselineOfGtKanban class >> loadLepiter [
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = 'GtKanban' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [
			self inform: 'Repository not found.' ]
]

{ #category : #baseline }
BaselineOfGtKanban >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'GtKanban'
		]
]
