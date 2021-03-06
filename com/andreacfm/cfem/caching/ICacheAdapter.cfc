<cfcomponent>

	<cffunction name="init" access="public" output="false" returntype="com.andreacfm.cfem.caching.ICacheAdapter">
		<cfargument name="EventManager" type="com.andreacfm.cfem.EventManager" />		
	</cffunction>

	<cffunction name="put" output="false" returntype="void">	
		<cfargument name="key" type="string" required="true" />
		<cfargument name="value" type="any" required="true" />
		<cfargument name="timespan" type="numeric" required="false"/>
				
	</cffunction>
	
	<cffunction name="get" output="false" returntype="any">	
		<cfargument name="key" type="string" required="true" />
				
	</cffunction>
	
	<cffunction name="flush" output="false" returntype="void">	
				
	</cffunction>
	
	<cffunction name="exists" output="false" returntype="Boolean">	
		<cfargument name="key" type="string" required="true" />
				
	</cffunction>
	
	<cffunction name="remove" output="false" returntype="void">	
		<cfargument name="key" type="string" required="true" />
				
	</cffunction>
		

</cfcomponent>