<cfinterface displayName="ICacheManager">
	
	<cffunction name="init" output="false" returntype="com.andreacfm.caching.ICacheManager">
		<cfargument name="cachewithin" type="string" required="false">
		<cfargument name="timeidle" type="string" required="false">		
		<cfargument name="cachename" type="string" required="false">
		
	</cffunction>
	
	<cffunction name="put" output="false" returntype="void">
		<cfargument name="key" type="string" required="true">
		<cfargument name="value" type="any" required="true">
		<cfargument name="cachewithin" type="string" required="false">
		<cfargument name="timeidle" type="string" required="false">		
		<cfargument name="cachename" type="string" required="false">
		
		
	</cffunction>

	<cffunction name="get" output="false" returntype="any">
		<cfargument name="key" type="string" required="true">
		<cfargument name="cachename" type="string" required="false">
		
		
	</cffunction>

	<cffunction name="exists" output="false" returntype="boolean">
		<cfargument name="key" type="string" required="true">
		<cfargument name="cachename" type="string" required="false">
		
	</cffunction>
	
	<cffunction name="remove" output="false" returntype="void">
		<cfargument name="key" type="string" required="false" default="">
		<cfargument name="cachename" type="string" required="false">
		<cfargument name="criteria" type="any" required="false" default="">
		
		
	</cffunction>
	
	<cffunction name="flush" output="false" returntype="void">
		<cfargument name="cachename" type="string" required="false">
		
		
	</cffunction>

</cfinterface>