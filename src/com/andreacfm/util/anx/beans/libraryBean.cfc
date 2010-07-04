<!---
/*
	lType:
	1 = images
	2 files
*/	
--->
<cfcomponent 
	output="false" 
	name="Anx Library Bean" 
	extends="cfops.core.bean">

	
<cfproperty name="lLibraryId" type="numeric"/>
<cfproperty name="lLibrary" type="string"/>
<cfproperty name="lDescription" type="string"/>
<cfproperty name="lStatus" type="numeric"/>
<cfproperty name="lType" type="numeric"/>
<cfproperty name="folder" type="string"/>


<!---------------------------	CONSTRUCTOR	--------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="com.andreacfm.core.bean">	
		<!---------------default properties---------------------->
		<cfargument name="lLibraryId" default="0" type="numeric" required="false">
		<cfargument name="lLibrary" default="" type="string" required="false">
		<cfargument name="lDescription" default="0" type="string" required="false">
		<cfargument name="lStatus" default="0" type="numeric" required="false">
		<cfargument name="lType" default="0" type="numeric" required="false">
		
		<cfset var i = "">
		
	 		<cfloop collection="#arguments#" item="i">
	 			<cfset evaluate( "set#i# ( arguments[ i ] )" ) />	
			 </cfloop>
			
		<cfreturn this/>	
	</cffunction>

<!---lLibraryId--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getlLibraryId" access="public" output="false" returntype="numeric">
		<cfreturn variables.instance.lLibraryId/>
	</cffunction>
	<cffunction name="setlLibraryId" access="public" output="false" returntype="void">
		<cfargument name="lLibraryId" type="numeric" required="true"/>
		<cfset variables.instance.lLibraryId = arguments.lLibraryId/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---lLibrary--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getlLibrary" access="public" output="false" returntype="string">
		<cfreturn variables.instance.lLibrary/>
	</cffunction>
	<cffunction name="setlLibrary" access="public" output="false" returntype="void">
		<cfargument name="lLibrary" type="string" required="true"/>
		<cfset variables.instance.lLibrary = arguments.lLibrary/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---lDescription--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getlDescription" access="public" output="false" returntype="string">
		<cfreturn variables.instance.lDescription/>
	</cffunction>
	<cffunction name="setlDescription" access="public" output="false" returntype="void">
		<cfargument name="lDescription" type="string" required="true"/>
		<cfset variables.instance.lDescription = arguments.lDescription/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---lType--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getlType" access="public" output="false" returntype="numeric">
		<cfreturn variables.instance.lType/>
	</cffunction>
	<cffunction name="setlType" access="public" output="false" returntype="void">
		<cfargument name="lType" type="numeric" required="true"/>
		<cfset variables.instance.lType = arguments.lType/>
		<!--- set the folder type ( img or ass ) after that lType has been setted --->
		<cfset setFolder() />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---lStatus--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getlStatus" access="public" output="false" returntype="numeric">
		<cfreturn variables.instance.lStatus/>
	</cffunction>
	<cffunction name="setlStatus" access="public" output="false" returntype="void">
		<cfargument name="lStatus" type="numeric" required="true"/>
		<cfset variables.instance.lStatus = arguments.lStatus/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---Folder--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getFolder" access="public" output="false" returntype="string">
		<cfreturn variables.instance.Folder/>
	</cffunction>
	<cffunction name="setFolder" access="public" output="false" returntype="void">
		<cfif getlType() eq 1>
			<cfset variables.instance.Folder = 'img'/>
		<cfelse>	
			<cfset variables.instance.Folder = 'ass'/>
		</cfif>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!------------------------------------------  PUBLIC  ----------------------------------------------------------------->	
<!---getFiles--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getFiles" output="false" returntype="array">
		<cfargument name="filter" required="false" type="string" default="" />
		<cfargument name="metadata" required="false" type="boolean" default="false" />
		
		<cfset var result = arrayNew(1)>
		<cfset var qDir = "" />
		<cfset var s = {} />
		<cfset var facade = getFacade() />
		<cfset var conv = facade.getObject('converter') />
		<cfset var meta = "" />
		
		<cfif directoryExists(getAbsPath())>
			
			<cfdirectory action="list" directory="#getAbsPath()#" name="qDir" filter="#arguments.filter#" type="file"/>
			
			<cfif qDir.recordcount gt 0 >
				<cfloop query="qDir">
					<cfset s = { name = qDir.name , size = qDir.size , type = qDir.type , mime = listLast(qDir.name,'.') , url = "#getRelPath()#/#qDir.name#" , dir = qDir.directory , folder = getFolder()} />
					<cfif arguments.metadata>
						<cfset meta = application.ancontent.getFileMetadata('library',this.getlLibraryId(),qDir.name) />
						<cfset meta = conv.queryToArray(meta) />
						<cfset s.meta = meta />
					</cfif>
					<cfset arrayAppend( result , s ) />
				</cfloop>
			</cfif>
	
		</cfif>

		<cfreturn result />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!------------------------------------------  PRIVATE  ---------------------------------------------------------------->	
<!---getAbsPath--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getAbsPath" output="false" returntype="string" access="private">
		<cfscript>
			var absPath = "#application.physicalPaths.ANROOT##getFolder()#\library\#getlLibraryId()#\";
			return absPath;
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!------------------------------------------  PRIVATE  ---------------------------------------------------------------->	
<!---getRelPath--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getRelPath" output="false" returntype="string" access="private">
		<cfscript>
			var absPath = "#application.virtualPaths.ANROOT#/#getFolder()#/library/#getlLibraryId()#";
			return absPath;
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

</cfcomponent>