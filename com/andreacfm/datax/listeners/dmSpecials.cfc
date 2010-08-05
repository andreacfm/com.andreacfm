<cfcomponent>

	<cffunction name="init" access="public" output="false" returntype="com.andreacfm.datax.listeners.dmSpecials">		
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="ModelBeforeUpdate" access="public" returntype="void">
		<cfargument name="event" required="true" type="EventManager.events.Event">	
		
		<cfset var bean = event.getData().bean />
		
		<!--- look for updateOn --->
		<cfif structkeyexists(bean.getmemento(),'updateOn')>
			<cfset bean.setUpdateOn(now()) />
		</cfif>
	
	</cffunction>

	
</cfcomponent>