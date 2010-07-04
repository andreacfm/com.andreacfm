<!--- 1.5 (Build 24) --->
<!--- Last Updated: 2007-04-11 --->
<!--- Created by Steve Bryant 2004-12-08 --->
<cfcomponent 
	displayname="Mailer" 
	hint="I handle sending of email notices. The advantage of using Mailer instead of cfmail is that I can be instantiated with information and then passed as an object to a component that sends email, circumventing the need to pass a bunch of email-related information to each component that sends email.">

<cffunction name="init" access="public" returntype="com.andreacfm.net.Mailer" output="no" hint="I instantiate and return this object.">
	
	<cfargument name="mailServer" type="string" required="yes">
	<cfargument name="username" type="string" default="">
	<cfargument name="password" type="string" default="">
	
	<cfargument name="From" type="string" default="">
	<cfargument name="To" type="string" default="">
	<cfargument name="RootData" type="struct" default="#StructNew()#">
	<cfargument name="options" type="struct" default="#StructNew()#">
	<cfargument name="notices" type="array" default="#arrayNew(1)#" />
	<cfargument name="testmode" type="boolean" default="false" />
	
	<cfset variables.instance.MailServer = arguments.MailServer>
	<cfset variables.instance.DefaultFrom = arguments.From>
	<cfset variables.instance.DefaultTo = arguments.To>
	<cfset variables.instance.username = arguments.username>
	<cfset variables.instance.password = arguments.password>
	<cfset variables.instance.RootData = arguments.RootData>
	<cfset variables.instance.options = arguments.options>
	<cfset variables.instance.testmode = arguments.testmode>
	
	<cfset variables.instance.Notices = StructNew()>
	<cfset variables.instance.isLogging = false>

	<cfif not arrayIsEmpty(arguments.notices)>
		<cfloop from="1" to="#arraylen(arguments.notices)#" index="i">
			<cfset addNotice(argumentCollection=arguments.notices[i]) />
		</cfloop>		
	</cfif>
	
	<cfif StructKeyExists(arguments,"DataMgr")>
		<cfset variables.instance.DataMgr = arguments.DataMgr>
		<cfset startLogging() />
	</cfif>
	
	<cfreturn this>
</cffunction>

<!--- 
Contents can be a string or a fiel where the string is stored.
 --->
<cffunction name="addNotice" access="public" returntype="void" output="no" hint="I add a notice to the mailer.">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="Subject" type="string" required="yes">
	<cfargument name="Contents" type="string" required="no">
	<cfargument name="To" type="string" default="">
	<cfargument name="From" type="string" default="">
	<cfargument name="datakeys" type="string" default="">
	<cfargument name="type" type="string" default="text">
	<cfargument name="CC" type="string" default="">
	<cfargument name="BCC" type="string" default="">
	<cfargument name="ReplyTo" type="string" default="">
	<cfargument name="Attachments" type="string" default="">
	<cfargument name="html" type="string" default="">
	<cfargument name="text" type="string" default="">
	<cfargument name="username" type="string" default="">
	<cfargument name="password" type="string" default="">
	<cfargument name="FailTo" type="string" default="">
	<cfargument name="mailerID" type="string" default="ColdFusion Application Server">
	<cfargument name="wraptext" type="string" default="800">
	
	<cfset var cont = "" />
	
	<cfif NOT
		(
				( StructKeyExists(arguments,"Contents") AND Len(arguments.Contents) )
			OR	( StructKeyExists(arguments,"html") AND Len(arguments.html) )
			OR	( StructKeyExists(arguments,"text") AND Len(arguments.text) )
		)
	>
		<cfthrow message="If Contents argument is not provided than either html or text arguments must be." type="Mailer" errorcode="ContentsRequired">
	</cfif>

	<cfif fileExists(expandPath(arguments.Contents))>
		<cffile action="read" file="#expandPath(arguments.Contents)#" variable="cont">
		<cfset arguments.Contents = cont />
	</cfif>
	
	<cfset variables.instance.Notices[arguments.name] = Duplicate(arguments)>
	
</cffunction>

<cffunction name="getData" access="public" returntype="struct" output="no" hint="I get the data stored in the Mailer component.">
	<cfreturn variables.instance.RootData>
</cffunction>

<cffunction name="getOptions" access="public" returntype="struct" output="no" hint="I get the options stored in the Mailer component.">
	<cfreturn variables.instance.options>
</cffunction>

<cffunction name="getDataKeys" access="public" returntype="string" output="no" hint="I get the datakeys for the given email notice. The datakeys are the items that can/should be overridden by incoming data.">
	<cfargument name="name" type="string" required="yes">
	
	<cfset var result = "">
	
	<cfif StructKeyExists(variables.instance.Notices, arguments.name)>
		<cfset result = variables.instance.Notices[arguments.name].DataKeys>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getFrom" access="public" returntype="string" output="no">
	<cfreturn variables.instance.DefaultFrom>
</cffunction>

<cffunction name="getNotices" access="public" returntype="struct" output="no">
	<cfreturn variables.instance.Notices>
</cffunction>

<cffunction name="removeNotice" access="public" returntype="void" output="no" hint="I remove a notice from the mailer.">
	<cfargument name="name" type="string" required="yes">
	
	<cfset StructDelete(variables.instance.Notices,arguments.name)>
	
</cffunction>

<cffunction name="send" access="public" returntype="boolean" output="no" hint="I send an email message and indicate if the send was successful.">
	<cfargument name="To" type="string" default="#variables.instance.DefaultTo#">
	<cfargument name="Subject" type="string" required="no">
	<cfargument name="Contents" type="string" required="no">
	<cfargument name="From" type="string" default="#variables.instance.DefaultFrom#">
	<cfargument name="CC" type="string" default="">
	<cfargument name="BCC" type="string" default="">
	<cfargument name="type" type="string" default="text">
	<cfargument name="ReplyTo" type="string" default="">
	<cfargument name="Attachments" type="string" default="">
	<cfargument name="html" type="string" default="">
	<cfargument name="text" type="string" default="">
	<cfargument name="username" type="string" default="#variables.instance.username#">
	<cfargument name="password" type="string" default="#variables.instance.password#">
	<cfargument name="FailTo" type="string" default="">
	<cfargument name="mailerID" type="string" default="ColdFusion MX Application Server">
	<cfargument name="wraptext" type="string" default="800">
	
	<cfset var sent = false>
	<cfset var attachment = "">
	
	<cfif variables.instance.testmode>
		<cfset sent = true />
	</cfif>

	<cfif NOT StructKeyExists(arguments,"Contents") AND NOT (Len(arguments.html) OR Len(arguments.text))>
		<cfthrow message="Send method requires Contents argument or html or text arguments.">
	</cfif>
	
	<!---
	If contents isn't passed in but only one of text/html is, set contents to the one passed in.
	(to avoid CF trying to send multi-part email)
	--->
	<cfif NOT StructKeyExists(arguments,"Contents")>
		<cfif Len(arguments.text) AND NOT Len(arguments.html)>
			<cfset arguments.Contents = arguments.text>
			<cfset arguments.type = "text">
			<cfset arguments.text = "">
		</cfif>
		<cfif Len(arguments.html) AND NOT Len(arguments.text)>
			<cfset arguments.Contents = arguments.html>
			<cfset arguments.type = "HTML">
			<cfset arguments.html = "">
		</cfif>
	</cfif>
	
	<cfif not variables.instance.testmode>
		<cfloop list="#arguments.to#" index="t">
			<cfif StructKeyExists(arguments,"Contents")>
				<cfif Len(arguments.username) AND Len(arguments.password)>
					<cfmail to="#t#" from="#arguments.From#" type="#arguments.type#" subject="#arguments.Subject#" cc="#arguments.CC#" bcc="#arguments.BCC#" server="#variables.instance.MailServer#" failto="#arguments.failto#" mailerID="#arguments.mailerID#" wraptext="#arguments.wraptext#" username="#arguments.username#" password="#arguments.password#"><cfif Len(Trim(arguments.ReplyTo))><cfmailparam name="Reply-To" value="#Trim(arguments.ReplyTo)#"></cfif>#arguments.Contents#<cfif Len(arguments.Attachments)><cfloop index="Attachment" list="#arguments.Attachments#"><cfmailparam file="#Attachment#"></cfloop></cfif></cfmail>
				<cfelse>
					<cfmail to="#t#" from="#arguments.From#" type="#arguments.type#" subject="#arguments.Subject#" cc="#arguments.CC#" bcc="#arguments.BCC#" server="#variables.instance.MailServer#" failto="#arguments.failto#" mailerID="#arguments.mailerID#" wraptext="#arguments.wraptext#"><cfif Len(Trim(arguments.ReplyTo))><cfmailparam name="Reply-To" value="#Trim(arguments.ReplyTo)#"></cfif>#arguments.Contents#<cfif Len(arguments.Attachments)><cfloop index="Attachment" list="#arguments.Attachments#"><cfmailparam file="#Attachment#"></cfloop></cfif></cfmail>
				</cfif>
				<cfset sent = true>
			<cfelse>
				<cfif Len(arguments.username) AND Len(arguments.password)>
					<cfmail to="#t#" from="#arguments.From#" subject="#arguments.Subject#" cc="#arguments.CC#" bcc="#arguments.BCC#" server="#variables.instance.MailServer#" failto="#arguments.failto#" mailerID="#arguments.mailerID#" wraptext="#arguments.wraptext#" username="#arguments.username#" password="#arguments.password#"><cfif Len(Trim(arguments.ReplyTo))><cfmailparam name="Reply-To" value="#Trim(arguments.ReplyTo)#"></cfif>
						<cfif Len(arguments.text)>
							<cfmailpart type="text" charset="utf-8" wraptext="#arguments.wraptext#">#arguments.text#</cfmailpart>
						</cfif>
						<cfif Len(arguments.html)>
							<cfmailpart type="html" charset="utf-8" wraptext="#arguments.wraptext#">#arguments.html#</cfmailpart>
						</cfif>
						<cfif Len(arguments.Attachments)><cfloop index="Attachment" list="#arguments.Attachments#"><cfmailparam file="#Attachment#"></cfloop></cfif>
					</cfmail>
				<cfelse>
					<cfmail to="#t#" from="#arguments.From#" subject="#arguments.Subject#" cc="#arguments.CC#" bcc="#arguments.BCC#" server="#variables.instance.MailServer#" failto="#arguments.failto#" mailerID="#arguments.mailerID#" wraptext="#arguments.wraptext#"><cfif Len(Trim(arguments.ReplyTo))><cfmailparam name="Reply-To" value="#Trim(arguments.ReplyTo)#"></cfif>
						<cfif Len(arguments.text)>
							<cfmailpart type="text" charset="utf-8" wraptext="#arguments.wraptext#">#arguments.text#</cfmailpart>
						</cfif>
						<cfif Len(arguments.html)>
							<cfmailpart type="html" charset="utf-8" wraptext="#arguments.wraptext#">#arguments.html#</cfmailpart>
						</cfif>
						<cfif Len(arguments.Attachments)><cfloop index="Attachment" list="#arguments.Attachments#"><cfmailparam file="#Attachment#"></cfloop></cfif>
					</cfmail>
				</cfif>
				<cfset sent = true>
			</cfif>
		</cfloop>
	</cfif>
		
	<cfset logSend(argumentCollection=arguments)>
	
	<cfreturn sent>
</cffunction>

<cffunction name="sendNotice" access="public" returntype="Boolean" output="no" hint="I send set/override any data based on the data given and send the given notice.">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="data" type="struct">
	<cfargument name="To" type="string" default="">
	
	<cfset var key = 0>
	<cfset var thisNotice = StructNew()>
	<cfset var missingkeys = "">
	<cfset var fields = "Subject,Contents,html,text">
	<cfset var field = "">
	<cfset var info = StructNew()>
	<cfset var k = "" />
	
	<cfif StructKeyExists(arguments,"data")>
		<cfloop collection="#data#" item="k">
			<cfif isSimpleValue(data[k])>
				<cfset info[k] = data[k] />
			</cfif>
		</cfloop>
	</cfif>
	
	<!--- Put in RootData, if any --->
	<cfset StructAppend(info, variables.instance.RootData , false)>
	
	<cflock timeout="40" throwontimeout="yes" name="Mailer_SendNotice" type="EXCLUSIVE">
		<cfset thisNotice = Duplicate(variables.instance.Notices[arguments.name])>
	</cflock>
	
	<!--- If this notice should have incoming data, make sure all keys are present --->
	<cfif Len(thisNotice.datakeys)>
		<cfloop index="key" list="#thisNotice.datakeys#">
			<cfif NOT StructKeyExists(info,key)>
				<cfset missingkeys = ListAppend(missingkeys,key)>
			</cfif>
		</cfloop>
		<cfif Len(missingkeys)>
			<cfthrow message="This Mailer Notice (#arguments.name#) is missing the following required keys: #missingkeys#." type="MailerErr">
		</cfif>
	</cfif>
	
	<cfif StructKeyExists(arguments,"data")>
		<!--- If any data is passed, reset values and modify contents accordingly. --->
		<cfloop collection="#info#" item="key">
			<!--- If this data key matches a key in the main struct for this notice, replace it --->
			<cfif StructKeyExists(thisNotice, key) AND key neq "username" AND key neq "password">
				<cfset thisNotice[key] = info[key]>
			</cfif>
			<!--- Modify any parameters for arguments that can have them modified --->
			<cfloop index="field" list="#fields#">
				<cfif FindNoCase("[#key#]", thisNotice[field])>
					<cfset thisNotice[field] = ReplaceNoCase(thisNotice[field], "[#key#]", info[key], "ALL")>
				</cfif>
			</cfloop>
		</cfloop>
	</cfif>
	<cfloop collection="#arguments#" item="key">
		<cfif key neq "name" AND key neq "data" AND isSimpleValue(arguments[key]) AND key neq "username" AND key neq "password">
			<cfset thisNotice[key] = arguments[key]>
		</cfif>
	</cfloop>
	
	<!--- replace custom values --->
	<cfif len(arguments.to)><cfset thisNotice.to = arguments.to /></cfif>
		
	<!--- Setting defaults here instead of in addNotice() in case variables.instance change between addNotice and sendNotice --->
	<cfif NOT Len(thisNotice.To)><cfset thisNotice.To = variables.instance.DefaultTo></cfif>
	<cfif NOT Len(thisNotice.From)><cfset thisNotice.From = variables.instance.DefaultFrom></cfif>
	<cfif NOT Len(thisNotice.username)><cfset thisNotice.username = variables.instance.username></cfif>
	<cfif NOT Len(thisNotice.password)><cfset thisNotice.password = variables.instance.password></cfif>
	
	<cfreturn this.send(argumentCollection=thisNotice) />
</cffunction>

<cffunction name="startLogging" access="public" returntype="void" output="no" hint="I make sure that all email sent from Mailer is logged in the mailerLogs table of the datasource managed by the given DataMgr.">
	<cfargument name="DataMgr" type="any" required="false" default="">
	<cfargument name="tablename" type="string" default="mailerLogs">
	
	<cfset var dbXml = getDbXml(arguments.tablename)>
	
	<cfif not structKeyExists(variables.instance,"datamgr") and arguments.dataMgr eq "">
		<cfthrow message="No dataMgr instance available for starting logging.">
	<cfelseif not structKeyExists(variables.instance,"datamgr") and isObject(arguments.dataMgr)>	
		<cfset variables.instance.DataMgr = arguments.DataMgr>
	</cfif>
		
	<cfset variables.instance.DataMgr.loadXml(dbXml,true,true)>
	
	<cfset variables.instance.isLogging = true>
	
</cffunction>

<cffunction name="stopLogging" access="public" returntype="void" output="no" hint="I stop the logging of email sent from Mailer.">
	
	<cfset variables.instance.isLogging = false>
	
</cffunction>

<cffunction name="isEmail" access="public" returntype="boolean" output="no">
	<cfargument name="string" type="string" required="yes">
	
	<cfreturn ReFindNoCase("^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$",string)>
</cffunction>

<cffunction name="logSend" access="private" returntype="void" output="no">
	
	<cfif variables.instance.isLogging>
		<cfset arguments.DateSent = now()>
		<cfset res = variables.instance.DataMgr.insertRecord("mailerLogs",variables.instance.DataMgr.truncate("mailerLogs",arguments))>
	</cfif>
	
</cffunction>

<cffunction name="getDbXml" access="private" returntype="string" output="no" hint="I return the XML for the tables needed for Searcher to work.">
	<cfargument name="tablename" type="string" default="mailerLogs">
	
	<cfset var tableXML = "">
	
	<cfsavecontent variable="tableXML"><cfoutput>
	<tables>
		<table name="#arguments.tablename#">
			<field ColumnName="LogID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
			<field ColumnName="DateSent" CF_DataType="CF_SQL_DATE" Special="CreationDate" />
			<field ColumnName="To" CF_DataType="CF_SQL_VARCHAR" Length="250" />
			<field ColumnName="Subject" CF_DataType="CF_SQL_VARCHAR" Length="180" />
			<field ColumnName="Contents" CF_DataType="CF_SQL_LONGVARCHAR" />
			<field ColumnName="From" CF_DataType="CF_SQL_VARCHAR" Length="180" />
			<field ColumnName="CC" CF_DataType="CF_SQL_VARCHAR" Length="250" />
			<field ColumnName="BCC" CF_DataType="CF_SQL_VARCHAR" Length="250" />
			<field ColumnName="type" CF_DataType="CF_SQL_VARCHAR" Length="30" />
			<field ColumnName="ReplyTo" CF_DataType="CF_SQL_VARCHAR" Length="180" />
			<field ColumnName="Attachments" CF_DataType="CF_SQL_LONGVARCHAR" />
			<field ColumnName="html" CF_DataType="CF_SQL_LONGVARCHAR" />
			<field ColumnName="text" CF_DataType="CF_SQL_LONGVARCHAR" />
			<field ColumnName="username" CF_DataType="CF_SQL_VARCHAR" Length="180" />
			<field ColumnName="password" CF_DataType="CF_SQL_VARCHAR" Length="180" />
			<field ColumnName="FailTo" CF_DataType="CF_SQL_VARCHAR" Length="180" />
			<field ColumnName="mailerID" CF_DataType="CF_SQL_VARCHAR" Length="250" />
			<field ColumnName="wraptext" CF_DataType="CF_SQL_VARCHAR" Length="40" />
		</table>
	</tables>
	</cfoutput></cfsavecontent>
	
	<cfreturn tableXML>
</cffunction>

</cfcomponent>
