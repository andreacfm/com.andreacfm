<cfcomponent output="false"
	hint="Look for listener into a specified directory.Add listeners and implicit events.">
	
	<cfset variables.instance = {} />
	
	<cffunction name="init" access="public" output="false" returntype="com.andreacfm.cfem.listener.Parser">
		<cfargument name="eventManager" required="true" type="com.andreacfm.cfem.EventManager">
		<cfargument name="path" required="true" type="string" hint="relative path to the directory to be scanned">
		<cfargument name="recurse" required="false" type="Boolean" default="false">
		
		<cfset variables.instance.basecfcpath = arguments.path />
		<cfset setEventManager(arguments.eventManager) />
		<cfset setPath(arguments.path) />
		<cfset setRecurse(arguments.recurse) />
				
		<cfreturn this/>
	</cffunction>
	
	<!--- 
	findListeners
	 --->
	<cffunction name="run" returntype="void" output="false" access="public">
		
		<cfset var dir = getPath() />
		<cfset var recurse = getRecurse() />
		<cfset _scanDirectory(directory = dir, recurse = recurse) />
		
	</cffunction>

	<!--- 
	scanDirectory
	 --->
	<cffunction name="_scanDirectory" returntype="void" output="false" access="private">
		<cfargument name="directory" required="true" type="string" >
		<cfargument name="recurse" required="true" type="Boolean" >
		<cfargument name="cfcPathMapping" required="false" type="String" default="">
		
		<cfset var q = "" />
		<cfset var class = "" />
		<cfset var basecfcpath = getbasecfcpath()>
		
		<cfdirectory action="list" name="q" directory="#arguments.directory#" sort="type desc"/>
		
		<cfloop query="q">
			<cfif q.type eq "File" and listLast(q.name,'.') eq 'cfc'>
				<cfset var fullPath = basecfcpath & arguments.cfcPathMapping />
				<cfset class = reReplaceNocase(fullPath,'//','/') />
				<cfset class = reReplaceNocase(fullPath,'^/','') />
				<cfset class = reReplaceNocase(class,'/','.','All') & reReplaceNocase(q.name,'.cfc','','All') />
				<cfset _processObject(class)/>
			<cfelseif q.type eq "Dir" and arguments.recurse>
				<cfset var dir = "#q.directory#/#q.name#" />
				<cfset var diff = replace(dir,expandPath(basecfcpath),'') & '/' />
				<cfset _scanDirectory(dir,true,diff)/>
			</cfif>
		</cfloop>
			
	</cffunction>	

	<!--- 
	processObject
	 --->
	<cffunction name="_processObject" returntype="void" output="false" access="private">
		<cfargument name="class" required="true" type="String">
		
		<cfset var em = getEventManager() />
		<cfset var obj = createObject('component',arguments.class) />
		<cfset var meta = getmetadata(obj) />
		<cfset var functions = meta.functions />
		<cfset var event = "" />
		<cfset var params = {} />
		
		<cfloop array="#functions#" index="f">
				
			<cfif structKeyExists(f,'event') and len(f.event)>
				<cftry>
					<cfset event = em.getEvent(f.event) />
					<cfcatch type="com.andreacfm.cfem.noSuchEventExeption">
						<cfset em.addEvent(f.event) />
					</cfcatch>
				</cftry>
				<cfset params = duplicate(f) />
				<cfset params.listener = arguments.class />
				<cfset params.method = f.name />
				<cfset em.addEventListener(argumentCollection=params) />
			</cfif>
			
		</cfloop>
				
	</cffunction>
		
	
	<!--- EventManager--->
	<cffunction name="setEventManager" access="public" returntype="void">
		<cfargument name="EventManager" type="com.andreacfm.cfem.EventManager" required="true"/>
		<cfset variables.instance.EventManager = EventManager />
	</cffunction> 
	<cffunction name="getEventManager" access="public" returntype="com.andreacfm.cfem.EventManager">
		<cfreturn variables.instance.EventManager/>
	</cffunction>
	
	<!--- Recurse--->
	<cffunction name="setRecurse" access="public" returntype="void">
		<cfargument name="Recurse" type="Boolean" required="true"/>
		<cfset variables.instance.Recurse = Recurse />
	</cffunction> 
	<cffunction name="getRecurse" access="public" returntype="Boolean">
		<cfreturn variables.instance.Recurse/>
	</cffunction>	
	
	<!--- base--->
	<cffunction name="getbasecfcpath" access="public" returntype="String">
		<cfreturn variables.instance.basecfcpath/>
	</cffunction>
		
	<!--- path ( store the expanded base path )--->
	<cffunction name="setpath" access="public" returntype="void">
		<cfargument name="path" type="String" required="true"/>
		<cfscript>
		if(not directoryexists(expandPath(arguments.path))){
			getEventManager().throw(message = "Directory [#arguments.path#] does not exists", type="com.andreacfm.cfem.directoryDoesNotExists");
		}
		variables.instance.path = expandPath(path);
		</cfscript>
	</cffunction> 
	<cffunction name="getpath" access="public" returntype="String">
		<cfreturn variables.instance.path/>
	</cffunction>
	

</cfcomponent>