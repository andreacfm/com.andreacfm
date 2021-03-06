<cfcomponent name="AbstractEvent" extends="com.andreacfm.cfem.util.IObservable">

	<cfproperty name="name" type="string"/>
	<cfproperty name="data" type="struct"/>
	<cfproperty name="target" type="any"/>
	<cfproperty name="isActive" type="boolean"/>
	<cfproperty name="type" type="string"/>
	<cfproperty name="mode" type="string"/>
	
	<cfscript>
	variables.instance.state = true ;
	variables.instance.point = "";
	variables.instance.observers = createObject('java','java.util.ArrayList').init();
	</cfscript>
	
	<!---   constructor   --->
	<cffunction name="init" output="false" returntype="com.andreacfm.cfem.events.AbstractEvent">
		<cfthrow type="com.andreacfm.cfem.InitAbstractClassException" message="Abstract class [abstractEvent] cannot be initialized" />
	</cffunction>

	<!-----------------------------   public   ----------------------------------->
	
	<!---   name   --->
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.instance.name/>
	</cffunction>

	<!---   data   --->
	<cffunction name="getData" access="public" output="false" returntype="struct">
		<cfreturn variables.instance.data/>
	</cffunction>
	<cffunction name="setData" access="public" output="false" returntype="void">
		<cfargument name="data" type="struct" required="true"/>
		<cfset variables.instance.data = arguments.data/>
	</cffunction>

	<!---   target   --->
	<cffunction name="getTarget" access="public" output="false" returntype="any">
		<cfreturn variables.instance.target/>
	</cffunction>

	<!---   type   --->
	<cffunction name="getType" access="public" output="false" returntype="string">
		<cfreturn variables.instance.type/>
	</cffunction>

	<!---   mode   --->
	<cffunction name="getMode" access="public" output="false" returntype="string">
		<cfreturn variables.instance.mode/>
	</cffunction>

	<!---   stopPropagation   --->
	<cffunction name="stopPropagation" access="public" output="false" returntype="void">
		<cfset variables.instance.state = false />
	</cffunction>

	<!---   isActive   --->
	<cffunction name="isActive" access="public" output="false" returntype="boolean">
		<cfreturn variables.instance.state />
	</cffunction>

	<!---   EM   --->
	<cffunction name="getEM" access="public" output="false" returntype="com.andreacfm.cfem.EventManager">
		<cfreturn variables.instance.EM/>
	</cffunction>
	<cffunction name="setEM" access="public" output="false" returntype="void">
		<cfargument name="EM" type="com.andreacfm.cfem.EventManager" required="true"/>
		<cfset variables.instance.EM = arguments.EM/>	
	</cffunction>

	<!---getEventId--->
	<cffunction name="getEventId" returntype="string" output="false" hint="Return the identityHashCode of the java object underling the cfc instance.">
		<cfreturn createObject("java", "java.lang.System").identityHashCode(this)/>
	</cffunction>



	<!--- INTERCEPTIONS SUPPORT --->
	
	<!--- 
	isObserved
	 --->
	<cffunction name="isObserved" returntype="Boolean" output="false" access="public">
		<cfreturn javaCast("boolean",variables.instance.observers.size()) />
	</cffunction>
	
	<!--- 
	getObservers
	 --->
	<cffunction name="getObservers" returntype="Array" output="false" access="public">
		<cfreturn variables.instance.observers />
	</cffunction>
	
	<!---updatePoint--->
	<cffunction name="updatePoint" output="false" returntype="void">
		<cfargument name="point" type="String" />
		<cfset variables.instance.point = arguments.point/>
		<cfset notifyObservers(this) />
	</cffunction>

	<!---getPoint--->
	<cffunction name="getPoint" returntype="string" output="false">
		<cfreturn variables.instance.point />
	</cffunction>
	

	
	<!--- IMPLEMENT IOBSERVABLE --->
	<cffunction name="notifyObservers" output="false" access="public">
		<cfloop array="#getObservers()#" index="int">
			<cfif int.getPoint() eq getPoint()>
				<cfset int.update(this) />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="registerObserver" output="false" access="public">
		<cfargument name="observer" type="com.andreacfm.cfem.util.IObserver"/>
		<cfset variables.instance.observers.add(observer) />
	</cffunction>
	
</cfcomponent>