<cfcomponent output="false">

	<cffunction name="alert1" returntype="any" output="false">
		<cfargument name="event" required="true" type="cfops.events.IEvent">
		<cfset var data = event.getData() />		
		<cfset var cbEvent = data.cbEvent />
		
		<cfsavecontent variable="temp">
		<cfoutput>
			<cfdump var="#event.getmemento()#">	
		</cfoutput>
		</cfsavecontent>		
		
		<cfset cbEvent.setValue('alert1', temp) />
		
		<cfif structKeyExists(data,'stopEvent')>
			<cfset event.stopPropagation() />
		</cfif>
		
	</cffunction>

	<cffunction name="alert2" returntype="any" output="false">
		<cfargument name="event" required="true" type="cfops.events.IEvent">	
		<cfset var cbEvent = event.getData().cbEvent />	
		
		<cfsavecontent variable="temp">
		<cfoutput>
			<cfdump var="#event.getmemento()#">	
		</cfoutput>
		</cfsavecontent>		
		
		<cfset cbEvent.setValue('alert2', temp) />
		
	</cffunction>

	<cffunction name="alert3" returntype="any" output="false">
		<cfargument name="event" required="true" type="cfops.events.IEvent">	
		
		<cfsavecontent variable="temp">
			<cfoutput>
				<cfdump var="#event.getmemento()#">	
			</cfoutput>
		</cfsavecontent>		
		
		<cfset request.alert3 = temp />
		
	</cffunction>

	<cffunction name="alert4" returntype="any" output="false">
		<cfargument name="event" required="true" type="cfops.events.IEvent">	
		
		<cfsavecontent variable="temp">
			<cfoutput>
				<cfdump var="#event.getmemento()#">	
			</cfoutput>
		</cfsavecontent>		
		
		<cfset request.alert4 = temp />
		
	</cffunction>

</cfcomponent>