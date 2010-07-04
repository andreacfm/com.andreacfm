<!--- 
messagesToBody must be called manually before rendering
 --->
<cfcomponent 
	output="false"
	name="messageBox"
	extends="com.andreacfm.Object">

	<cfproperty name="header" type="string"/>
	<cfproperty name="body" type="string"/>
	<cfproperty name="footer" type="string"/>
	<cfproperty name="containerClass" type="string"/>
	<cfproperty name="skin" type="string"/>
	<cfproperty name="type" type="string"/>
	<cfproperty name="mapping" type="string"/>

	<cfset variables.instance.messages = createObject('java','java.util.ArrayList').init() />

<!---------------------------CONSTRUCTOR------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="com.andreacfm.ui.Box">	
		<cfargument name="header" required="false" type="string" default="">
		<cfargument name="body" required="false" type="string" default="">
		<cfargument name="footer" required="false" type="string" default="">
		<cfargument name="containerClass" required="false" type="string" default="ac_box">
		<cfargument name="skin" required="false" type="string" default="bp">
		<cfargument name="mapping" required="false" type="string" default="">
		<cfargument name="type" required="false" type="string" default="error"><!--- error,warning,info,question --->				

		<cfscript>
		setmapping(arguments.mapping);
		setHeader(arguments.header);	
		setBody(arguments.body);	
		setfooter(arguments.footer);
		setSkin(arguments.skin);					
		// skin must be available to container class so keep it last to load	
		setcontainerClass(arguments.containerClass & ' ' & arguments.containerClass & '_' & arguments.type );
		</cfscript>
		<cfreturn this/>	
	</cffunction>

	<!------------------------------------			PUBLIC   		----------------------------------------------------->

	<!---render--->
	<cffunction name="render" output="false" returntype="string">
		<cfset var resource = 'hash(#getSkin()#)' />
		<cfset var data = structNew() />
		
		<cfparam name="request.cfopsSkin" default=""/>
		
		<cfset messagesToBody() />
		
		<cfsavecontent variable="output">
		<cfoutput>
			<cfif listFind(request.cfopsSkin,resource) eq 0>
				<link rel="stylesheet" href="#getMapping()#/com/andreacfm/ui/css/#getSkin()#.css" />
				<cfset request.cfopsSkin = listAppend(request.cfopsSkin,resource) />
			</cfif>
			<div class="#getContainerClass()#">
				<div>#getHeader()#</div>
				<div>#getBody()#</div>
				<div>#getFooter()#</div>
			</div>
		</cfoutput>
		</cfsavecontent>
		
		<cfreturn output />
	</cffunction>

	<!--- resetAll --->
	<cffunction name="resetAll" returntype="void" output="false">
		<cfset resetMessages() />
		<cfset setBody("") />	
	</cffunction>

	<!--- addMessage --->
	<cffunction name="addMessage" returntype="void" output="false">
		<cfargument name="message" type="string" required="true" />
		<cfset variables.instance.messages.add(message) />
	</cffunction>

	<!--- getMessages --->
	<cffunction name="getMessages" returntype="Array" output="false">
		<cfreturn variables.instance.messages />
	</cffunction>

	<!--- addMessages --->
	<cffunction name="addMessages" returntype="void" output="false">
		<cfargument name="message" type="Array" required="true" />
		<cfset variables.instance.messages.addAll(message) />
	</cffunction>
	
	<!--- resetMessages --->
	<cffunction name="resetMessages" returntype="void" output="false">
		<cfset variables.instance.messages.clear() />
	</cffunction>

	<!--- hasMessages --->
	<cffunction name="hasMessages" returntype="Boolean" output="false">
		<cfset var res = true />
		<cfif variables.instance.messages.isEmpty()>
			<cfset res = false />
		</cfif>
		<cfreturn res />
	</cffunction>	

	<!--- messagesToBody --->
    <cffunction name="messagesToBody" returntype="void" output="false">
		<cfset var temp = "" />
		<cfif hasMessages()>
			<cfsavecontent variable="temp">
				<cfoutput>
				<cfset iterator = variables.instance.messages.iterator()/>
				<cfoutput>
				<ul>
					<cfloop condition="#iterator.hasNext()#">
						<cfset err = iterator.next() />
						<li>#err#</li> 
					</cfloop>
				</ul>
				</cfoutput>	
				</cfoutput>	
			</cfsavecontent>
		</cfif>
    	<cfset setbody(temp) />	
    </cffunction>
	
	<!---header--->
	<cffunction name="getheader" access="public" output="false" returntype="string">
		<cfreturn variables.instance.header/>
	</cffunction>
	<cffunction name="setheader" access="public" output="false" returntype="void">
		<cfargument name="header" type="string" required="true"/>
		<cfset variables.instance.header = arguments.header/>
	</cffunction>

	<!---body--->
	<cffunction name="getbody" access="public" output="false" returntype="string">
		<cfreturn variables.instance.body/>
	</cffunction>
	<cffunction name="setbody" access="public" output="false" returntype="void">
		<cfargument name="body" type="string" required="true"/>
		<cfset variables.instance.body = arguments.body/>
	</cffunction>

	<!---footer--->
	<cffunction name="getfooter" access="public" output="false" returntype="string">
		<cfreturn variables.instance.footer/>
	</cffunction>
	<cffunction name="setfooter" access="public" output="false" returntype="void">
		<cfargument name="footer" type="string" required="true"/>
		<cfset variables.instance.footer = arguments.footer/>
	</cffunction>

	<!---containerClass--->
	<cffunction name="getcontainerClass" access="public" output="false" returntype="string">
		<cfreturn variables.instance.containerClass/>
	</cffunction>
	<cffunction name="setcontainerClass" access="public" output="false" returntype="void">
		<cfargument name="containerClass" type="string" required="true"/>
		<cfset variables.instance.containerClass = arguments.containerClass/>
	</cffunction>

	<!---   skin   --->
	<cffunction name="getskin" access="public" output="false" returntype="string">
		<cfreturn variables.instance.skin/>
	</cffunction>
	<cffunction name="setskin" access="public" output="false" returntype="void">
		<cfargument name="skin" type="string" required="true"/>
		<cfset variables.instance.skin = arguments.skin/>
	</cffunction>

	<!--- mapping--->
     <cffunction name="setmapping" access="public" returntype="void">
		<cfargument name="mapping" type="String" required="true"/>
		<cfset variables.instance.mapping = mapping />
	</cffunction> 
	<cffunction name="getmapping" access="public" returntype="String">
		<cfreturn variables.instance.mapping/>
	</cffunction>	

</cfcomponent>