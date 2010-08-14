<cfcomponent output="false">
	
	<cfset variables.severityScale = {off=-1,fatal=1,error=2,warn=3,info=4,debug=5} />
	
	<cffunction name="init" access="public" output="false" returntype="com.andreacfm.logging.appenders.AbstractAppender">		
		<cfreturn this/>
	</cffunction>

	<!--- 
	debug
	 --->
	<cffunction name="debug" returntype="void" output="false" access="public">
		<cfargument name="msg" required="true" type="String">
		<cfset logMessage('debug',arguments.msg) />
	</cffunction>
	
	<!--- 
	info
	 --->
	<cffunction name="info" returntype="void" output="false" access="public">
		<cfargument name="msg" required="true" type="String">
		<cfset logMessage('info',arguments.msg) />
	</cffunction>
	
	<!--- 
	warn
	 --->
	<cffunction name="warn" returntype="void" output="false" access="public">
		<cfargument name="msg" required="true" type="String">
		<cfset logMessage('warn',arguments.msg) />
	</cffunction>

	<!--- 
	error
	 --->
	<cffunction name="error" returntype="void" output="false" access="public">
		<cfargument name="msg" required="true" type="String">
		<cfset logMessage('error',arguments.msg) />		
	</cffunction>

	<!--- 
	fatal
	 --->
	<cffunction name="fatal" returntype="void" output="false" access="public">
		<cfargument name="msg" required="true" type="String">
		<cfset logMessage('fatal',arguments.msg) />		
	</cffunction>

	<!--- 
	logMessage
	 --->
	<cffunction name="logMessage" returntype="void" output="false" access="public">
		<cfargument name="severity" required="true" type="string">
		<cfargument name="msg" required="true" type="String">
		<cfargument name="async" required="false" type="Boolean" default="false">
		
		<cfscript>
		var timestamp = now();	
		var entry = '"#arguments.severity#","#dateformat(timestamp,"MM/DD/YYYY")#","#timeformat(timestamp,"HH:MM:SS")#","#msg#"';
		var out = getOut();
		
		// log only over the fixed minimum
		if(variables.severityScale[arguments.severity] gte getminLevel()){
			if(out eq 'file'){
				writeLogFile(entry,arguments.async);
			}else if(out eq 'console'){
				variables.instance.console.println(entry);
			}		
		}
		</cfscript>		

	</cffunction>	

	<!--- minLevel--->
	<cffunction name="setminLevel" access="public" returntype="void">
		<cfargument name="minLevel" type="String" required="true"/>
	
		<cfif not structKeyExists(variables.severityScale,arguments.minLevel)>
			<cfthrow type="com.andreacfm.logging.MinLevelDoNotExists" message="The min level logging [#arguments.minLevel#] is not valid.">
		<cfelse>
			<cfset variables.instance.minLevel = variables.severityScale[arguments.minLevel] />	
		</cfif>

	</cffunction>
	<cffunction name="getminLevel" access="public" returntype="String">
		<cfreturn variables.instance.minLevel/>
	</cffunction>	
	<cffunction name="getTranslatedMinLevel" access="public" returntype="String">
		<cfset var key = "" />
		<cfset var min = getMinLevel() />	
		<cfloop collection="#variables.severityScale#" item="key">
			<cfif variables.severityScale[key] eq min>
				<cfreturn key />
			</cfif>
		</cfloop>
		<cfreturn "" />
	</cffunction>	

</cfcomponent>