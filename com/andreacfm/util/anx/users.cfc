<cfcomponent hint="Model layer for Users tool module">

	<!--- init() method --->
	<cffunction name="init" access="public" output="no" returntype="void" hint="initialize user object">
		<cfargument name="uUserID" required="no" type="numeric" default="0"/>
		<cfset var q = ""/>
		<cfif arguments.uUserID neq 0>
			<cfset q = get(arguments.uUserID)/>
			<!--- set results in this scope --->
			<cfscript>
				application.anlock.lockRecord(q.uIdentifier);
				session.anmodule.appRecord = q.uIdentifier;
				session.anmodule.appTitle = "#q.uFirstName# #q.uLastName#";
				this.uUserID = q.uUserID;
				this.uIdentifier = q.uIdentifier;
				this.uUsername = q.uUsername;
				this.uPassword = q.uPassword;
				this.uTitle = q.uTitle;
				this.uFirstName = q.uFirstName;
				this.uLastName = q.uLastName;
				this.uAlias = q.uAlias;
				this.uCompany = q.uCompany;
				this.uPosition = q.uPosition;
				this.uAddress1 = q.uAddress1;
				this.uAddress2 = q.uAddress2;
				this.uCity = q.uCity;
				this.uPostalCode = q.uPostalCode;
				this.uState = q.uState;
				this.uPhone = q.uPhone;
				this.uMobile = q.uMobile;
				this.uFax = q.uFax;
				this.uEmail = q.uEmail;
				this.uLanguage = q.uLanguage;
				this.uOptions = q.uOptions;
				this.uStatus = q.uStatus;
				this.uNotify = q.uNotify;
				this.uAccessCount = q.uAccessCount;
				this.uTSCreated = q.uTSCreated;
				this.uTSUpdated = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,now()));
				this.uTSLastAccess = q.uTSLastAccess;
				this.uTSCycle = q.uTSCycle;
				this.uTSOn = q.uTSOn;
				this.uTSOff = q.uTSOff;
				this.uCountry_ID = q.uCountry_ID;
				this.FullName = "#q.uFirstName# #q.uLastName#";
				/* get user group and role assignments */
				q = getUserGroups(arguments.uUserID);
				this.UserGroupIDs = valueList(q.gGroupID);
				q = getRolesUser(arguments.uUserID);
				this.UserRoleIDs = valueList(q.rRoleID);
			</cfscript>
		<cfelse>
			<cfscript>
				application.anlock.unlockRecord();
				this.uUserID = 0;
				this.uIdentifier = createUUID();
				this.uUsername = "";
				this.uPassword = newPassword();
				this.uTitle = 0;
				this.uFirstName = "";
				this.uLastName = "";
				this.uAlias = "";
				this.uCompany = "";
				this.uPosition = "";
				this.uAddress1 = "";
				this.uAddress2 = "";
				this.uCity = "";
				this.uPostalCode = "";
				this.uState = "";
				this.uPhone = "";
				this.uMobile = "";
				this.uFax = "";
				this.uEmail = "";
				this.uLanguage = listFirst(application.config.SUPPORTED_LOCALES);
				this.uOptions = "";
				this.uStatus = 0; /* status = off */
				this.uNotify = 1;
				this.uAccessCount = 0;
				this.uTSCreated = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,now()));
				this.uTSUpdated = this.uTSCreated;
				this.uTSLastAccess = this.uTSCreated;
				this.uTSCycle = this.uTSCreated;
				this.uTSOn = this.uTSCreated;
				this.uTSOff = this.uTSCreated;
				this.uCountry_ID = application.config.DEFAULT_COUNTRY_ID; /* 153 = New Zealand */
				this.FullName = "";
				this.UserGroupIDs = "";
				this.UserRoleIDs = "";
			</cfscript>
		</cfif>
	</cffunction>


<!--- L I N E D methods - (L)ist (I)nfo (N)ew (E)dit (D)elete --->

	<!--- list() method --->
	<cffunction name="list" access="public" output="no" returntype="query" hint="Returns query of all users with group assignment">
		<cfargument name="criteria" default="" required="no" type="string"/>
		<cfargument name="orderBy" default="0" required="no" type="numeric"/>
		<cfargument name="showStatus" default="-1" required="no" type="numeric"/>
		<cfargument name="showGroupID" default="0" required="no" type="numeric"/>
		<cfset var q = ""/>
		<cfset var w = ""/>
		<cfset var siteAdminIDs = getSiteAdminIDs()/>
		<!--- only administrator can access deleted user records --->
		<cfif arguments.showStatus eq 5 and not listFind(session.anuser.userroles,"siteadmin")>
			<cfset arguments.showStatus = -1/>
		</cfif>
		<!--- query based on search word/id and user permissions --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				(select distinct u.uUserID, u.uIdentifier, u.uTSUpdated, u.uFirstName, u.uLastName, u.uAlias, u.uCompany, u.uStatus, u.uTSOn, u.uTSOff, u.uAccessCount, u.uTSLastAccess
				from users u, groups g, users_groups ug
				where u.uUserID = ug.ugUser_ID
				and	g.gGroupID = ug.ugGroup_ID
				<cfif arguments.showStatus eq -1>
					and u.uStatus <> 5
				<cfelse>
					and u.uStatus = #arguments.showStatus#
				</cfif>
				<cfif arguments.showGroupID neq 0>
					and	g.gGroupID = #arguments.showGroupID#
				</cfif>
				<!--- if not siteadmin then limit to users groups --->
				<cfif not listFindNoCase(session.anuser.userRoles,"siteadmin")>
					and	g.gGroupID in (select g.gGroupID
										from users u, groups, users_groups ug
										where u.uUserID = ug.ugUser_ID
										and	g.gGroupID = ug.ugGroup_ID
										and	u.uStatus <> 5
										and	u.uUserID = #session.anuser.userID#)
					and u.uUserID not in (#siteAdminIDs#)
				</cfif>
				<cfif len(arguments.criteria)>
					<cfloop  index="w" list="#arguments.criteria#" delimiters=" ">
						and	(u.uUsername like '%#w#%' or u.uEmail like '%#w#%' or u.uFirstName like '%#w#%' or u.uLastName like '%#w#%' or u.uAlias like '%#w#%' or u.uCompany like '%#w#%'<cfif isNumeric(w)> or u.uUserID = #w#</cfif>)
					</cfloop>
				</cfif>)

			union

				(select uUserID, uIdentifier, uTSUpdated, uLastName, uFirstName, uAlias, uCompany, uStatus, uTSOn, uTSOff, uAccessCount, uTSLastAccess
				from users
				where uUserID not in (select distinct ugUser_ID from users_groups) <!--- user not in groups join table --->
				<cfif not listFindNoCase(session.anuser.userRoles,"siteadmin")>
					and uUserID not in (#siteAdminIDs#)
				</cfif>
				<cfif arguments.showGroupID neq 0>
					and	0 = 1
				</cfif>
				<cfif arguments.showStatus eq -1>
					and uStatus <> 5
				<cfelse>
					and uStatus = #arguments.showStatus#
				</cfif>
				<cfif len(arguments.criteria)>
					<cfloop index="w" list="#arguments.criteria#" delimiters=" ">
						and	(uUsername like '%#w#%' or uEmail like '%#w#%' or uFirstName like '%#w#%' or uLastName like '%#w#%' or uAlias like '%#w#%' or uCompany like '%#w#%'<cfif isNumeric(w)> or uUserID = #w#</cfif>)
					</cfloop>
				</cfif>)
			<cfswitch expression="#arguments.orderBy#">
				<cfcase value="1">order by uUserID DESC</cfcase>
				<cfcase value="-1">order by uUserID ASC</cfcase>
				<cfcase value="2">order by uStatus DESC, uUserID DESC</cfcase>
				<cfcase value="-2">order by uStatus ASC, uUserID DESC</cfcase>
				<cfcase value="3">order by uFirstName DESC, uLastName DESC, uUserID DESC</cfcase>
				<cfcase value="-3">order by uFirstName ASC, uLastName ASC, uUserID DESC</cfcase>
				<cfcase value="4">order by uCompany DESC, uUserID DESC</cfcase>
				<cfcase value="-4">order by uCompany ASC, uUserID DESC</cfcase>
				<cfcase value="5">order by uTSLastAccess DESC, uUserID DESC</cfcase>
				<cfcase value="-5">order by uTSLastAccess ASC, uUserID DESC</cfcase>
				<cfcase value="6">order by uAccessCount DESC, uUserID DESC</cfcase>
				<cfcase value="-6">order by uAccessCount ASC, uUserID DESC</cfcase>
				<cfdefaultcase>order by uTSUpdated DESC</cfdefaultcase>
			</cfswitch>
		</cfquery>
		<cfreturn q/>
	</cffunction>


	<cffunction name="listRole" access="public" output="no" returntype="query" hint="Returns query of all users in role">
		<cfargument name="searchWord" default="" required="no" type="string"/>
		<cfargument name="orderBy" default="0" required="no" type="numeric"/>
		<cfargument name="showStatus" default="-1" required="no" type="numeric"/>
		<cfargument name="showRoleID" default="0" required="no" type="numeric">
		<cfset var q = ""/>
		<cfset var currentWord = ""/>
		<!--- only administrator can access deleted user records --->
		<cfif arguments.showStatus eq 5 and not listFind(session.anuser.userroles,"siteadmin")>
			<cfset arguments.showStatus = -1/>
		</cfif>
		<!--- query based on search word/id and user permissions --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select distinct u.uUserID, u.uIdentifier, u.uTSUpdated, u.uLastName, u.uFirstName, u.uAlias, u.uCompany, u.uStatus, u.uTSOn, u.uTSOff, u.uAccessCount, u.uTSLastAccess
				from users u, roles r, users_roles ur
				where u.uUserID = ur.urUser_ID
				and	r.rRoleID = ur.urRole_ID
				<cfif arguments.showStatus eq -1>
					and u.uStatus <> 5
				<cfelse>
					and u.uStatus = #arguments.showStatus#
				</cfif>
				<cfif arguments.showRoleID neq 0>
					and	r.rRoleID = #arguments.showRoleID#
				</cfif>
				<!--- if not siteadmin then limit to users roles --->
				<cfif not listFindNoCase(session.anuser.userRoles,"siteadmin")>
					and	r.rRoleID in (select r.rRoleID
										from users u, roles, users_roles ur
										where u.uUserID = ur.urUser_ID
										and	r.rRoleID = ur.urRole_ID
										and	r.rIdentifier not in ('siteadmin')
										and	u.uStatus <> 5
										and	u.uUserID = #session.anuser.userID#)
				</cfif>
				<cfif len(arguments.searchWord)>
					<cfloop list="#arguments.searchWord#" index="CurrentWord" delimiters=" ">
						and	(u.uFirstName like '%#currentWord#%' or u.uLastName like '%#currentWord#%' or u.uAlias like '%#currentWord#%' or u.uCompany like '%#currentWord#%'<cfif IsNumeric(currentWord)> or u.uUserID = #currentWord#</cfif>)
					</cfloop>
				</cfif>
			<cfswitch expression="#arguments.orderBy#">
				<cfcase value="1">order by u.uUserID DESC</cfcase>
				<cfcase value="-1">order by u.uUserID ASC</cfcase>
				<cfcase value="2">order by u.uStatus DESC, u.uUserID DESC</cfcase>
				<cfcase value="-2">order by u.uStatus ASC, u.uUserID DESC</cfcase>
				<cfcase value="3">order by u.uFirstName DESC, u.uLastName DESC, u.uUserID DESC</cfcase>
				<cfcase value="-3">order by u.uFirstName ASC, u.uLastName ASC, u.uUserID DESC</cfcase>
				<cfcase value="4">order by u.uCompany DESC, u.uUserID DESC</cfcase>
				<cfcase value="-4">order by u.uCompany ASC, u.uUserID DESC</cfcase>
				<cfcase value="5">order by u.uTSLastAccess DESC, u.uUserID DESC</cfcase>
				<cfcase value="-5">order by u.uTSLastAccess ASC, u.uUserID DESC</cfcase>
				<cfcase value="6">order by u.uAccessCount DESC, u.uUserID DESC</cfcase>
				<cfcase value="-6">order by u.uAccessCount ASC, u.uUserID DESC</cfcase>
				<cfdefaultcase>order by u.uTSUpdated DESC</cfdefaultcase>
			</cfswitch>
		</cfquery>
		<cfreturn q/>
	</cffunction>


	<cffunction name="listUnassigned" access="public" output="no" returntype="query" hint="Returns query of users without group assignments">
		<cfargument name="searchWord" default="" required="no" type="string">
		<cfargument name="orderBy" default="0" required="no" type="numeric">
		<cfargument name="showStatus" default="All" required="no" type="string">
		<cfset var q = ""/>
		<cfset var currentWord = ""/>
		<!--- query based on search word/id and user permissions --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select distinct uUserID, uIdentifier, uTSUpdated, uLastName, uFirstName, uCompany, uStatus, uTSOn, uTSOff, uAccessCount
				from users
				where 1 = 1
				<cfif arguments.showStatus eq "All">
					and u.uStatus <> 5
				<cfelse>
					and u.uStatus in ('#arguments.showStatus#')
				</cfif>
				<cfif len(arguments.searchWord)>
					<cfloop list="#arguments.searchWord#" index="CurrentWord" delimiters=" ">
						and		(uFirstName like '%#currentWord#%' or uLastName like '%#currentWord#%' or uCompany like '%#currentWord#%'<cfif IsNumeric(currentWord)> or uUserID = #currentWord#</cfif>)
					</cfloop>
				</cfif>
			<cfswitch expression="#arguments.orderBy#">
				<cfcase value="1">order by uUserID DESC</cfcase>
				<cfcase value="-1">order by uUserID ASC</cfcase>
				<cfcase value="2">order by uStatus DESC, u.uUserID DESC</cfcase>
				<cfcase value="-2">order by uStatus ASC, u.uUserID DESC</cfcase>
				<cfcase value="3">order by uFirstName DESC, u.uLastName DESC, u.uUserID DESC</cfcase>
				<cfcase value="-3">order by uFirstName ASC, u.uLastName ASC, u.uUserID DESC</cfcase>
				<cfcase value="4">order by uCompany DESC, u.uUserID DESC</cfcase>
				<cfcase value="-4">order by uCompany ASC, u.uUserID DESC</cfcase>
				<cfcase value="5">order by uTSUpdated DESC, u.uUserID DESC</cfcase>
				<cfcase value="-5">order by uTSUpdated ASC, u.uUserID DESC</cfcase>
				<cfcase value="6">order by uAccessCount DESC, u.uUserID DESC</cfcase>
				<cfcase value="-6">order by uAccessCount ASC, u.uUserID DESC</cfcase>
				<cfdefaultcase>order by uTSUpdated DESC</cfdefaultcase>
			</cfswitch>
		</cfquery>
		<cfreturn q/>
	</cffunction>

	<!--- get() method --->
	<cffunction name="get" access="public" output="no" returntype="query" hint="Copy requested record into object">
		<cfargument name="uUserID" required="yes" type="numeric">
		<cfset var q = ""/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select  *
			from    users
			where   uUserID = <cfqueryparam value="#arguments.uUserID#" cfsqltype="cf_sql_integer">;
		</cfquery>
		<cfreturn q/>
	</cffunction>


	<!--- new() method --->
	<cffunction name="new" access="public" output="no" returntype="void" hint="Save new object values in database">
		<cfset var q = 0/>
		<!--- if duplicate username/password then replace unique one --->
		<cfset uniqueUNPW()/>
		<cflock name="#application.applicationName#-new-user" type="exclusive" timeout="30" throwontimeout="yes">
			<cftransaction action="begin">
				<cftry>
					<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.users" method="insertRec" argumentcollection="#this#"/>
					<!--- get new record primary key --->
					<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
						select max(uUserID) as NewID
						from users
					</cfquery>
					<cfset this.uUserID = q.NewID/>
					<!--- insert user groups and roles --->
					<cfset join()/>
					<cfcatch>
						<cftransaction action="rollback"/>
						<cfrethrow/>
					</cfcatch>
				</cftry>
			</cftransaction>
		</cflock>
		<!--- update object --->
		<cfset init(this.uUserID)/>
		<cfif this.uStatus eq 10>
			<cfset session.anmodule.appStatus = "AN_NO_GROUPS_ASSIGNED"/>
		<cfelse>
			<cfset session.anmodule.appStatus = "AN_SAVED"/>
		</cfif>
	</cffunction>


	<!--- edit() method --->
	<cffunction name="edit" access="public" output="no" returntype="void" hint="Save object in database">
		<!--- if duplicate username/password then replace unique one --->
		<cfset uniqueUNPW()/>
		<cftransaction action="begin">
			<cftry>
				<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.users" method="updateRec" argumentcollection="#this#"/>
				<!--- clear / insert user groups and roles --->
				<cfset join()/>
				<cfset resetPermissions()/>
				<cfcatch>
					<cftransaction action="rollback"/>
					<cfrethrow/>
				</cfcatch>
			</cftry>
		</cftransaction>
		<!--- update object --->
		<cfset init(this.uUserID)/>
		<!--- update status message --->
		<cfif this.uStatus eq 10>
			<!--- if user has no groups then reset any checkout ids held by user --->
			<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.tree" method="updateRecCheckOutIDs">
				<cfinvokeargument name="tCheckOut_ID" value="#this.uUserID#"/>
			</cfinvoke>
			<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.content" method="updateRecCheckOutIDs">
				<cfinvokeargument name="cCheckOut_ID" value="#this.uUserID#"/>
			</cfinvoke>
			<cfset session.anmodule.appStatus = "AN_NO_GROUPS_ASSIGNED"/>
		<cfelseif len(session.anmodule.appStatus) eq 0>
			<cfset session.anmodule.appStatus = "AN_SAVED"/>
		</cfif>
	</cffunction>


	<!--- delete() method --->
	<cffunction name="delete" access="public" output="no" returntype="void" hint="Delete object from database">
		<!--- do not delete users recs - set to delete status --->
		<cfset this.uStatus = 5/>
		<cfset edit()/>
		<cftransaction action="begin">
			<cftry>
				<!--- delete users_roles --->
				<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.users_roles" method="deleteRec">
					<cfinvokeargument name="uUserID" value="#this.uUserID#"/>
				</cfinvoke>
				<!--- delete user_groups --->
				<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.users_groups" method="deleteRec">
					<cfinvokeargument name="uUserID" value="#this.uUserID#"/>
				</cfinvoke>
				<!--- tree_users joins --->
				<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.tree_users" method="deleteRec">
					<cfinvokeargument name="uUserID" value="#this.uUserID#"/>
				</cfinvoke>
				<!--- content_users joins --->
				<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.content_users" method="deleteRec">
					<cfinvokeargument name="uUserID" value="#this.uUserID#"/>
				</cfinvoke>
				<!--- reset any checkout ids held by user --->
				<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.tree" method="updateRecCheckOutIDs">
					<cfinvokeargument name="tCheckOut_ID" value="#this.uUserID#"/>
				</cfinvoke>
				<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.content" method="updateRecCheckOutIDs">
					<cfinvokeargument name="cCheckOut_ID" value="#this.uUserID#"/>
				</cfinvoke>
				<!--- approvals_users joins --->
				<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.approvals_users" method="deleteRec">
					<cfinvokeargument name="uUserID" value="#this.uUserID#"/>
				</cfinvoke>
				<!--- TODO: do not delete record to retain ref integrity
				<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.users" method="deleteRec">
					<cfinvokeargument name="uUserID" value="#this.uUserID#"/>
				</cfinvoke>		--->
				<cfcatch>
					<cftransaction action="rollback"/>
					<cfrethrow/>
				</cfcatch>
			</cftry>
		</cftransaction>
		<!--- update status message --->
		<cfset session.anmodule.appStatus = "AN_DELETED"/>
	</cffunction>


	<!--- only delete user from specific groups - used for group admin delete --->
	<cffunction name="deleteUserFromGroups" access="public" output="no" returntype="void" hint="Removes group join for delete by group admin">
		<cfargument name="uUserID" type="numeric" required="yes"/>
		<cfargument name="DeleteGroupIDs" type="string" required="yes" default=""/>
		<cfset var entity = createObject("component","#application.config.CFCOMPONENTS_PREFIX#.entities.users_groups")/>
		<cfset var i = ""/>
		<!--- groups --->
		<cfif listLen(arguments.DeleteGroupIDs) neq 0>
			<cfloop index="i" list="#DeleteGroupIDs#">
				<cfset entity.deleteRec(arguments.uUserID,i)/> <!--- TODO: this could be better by passing a list of ids directly to the group delete --->
			</cfloop>
		</cfif>
	</cffunction>


<!--- join tables = relationships methods --->

	<!--- join() method --->
	<cffunction name="join" access="private" output="no" returntype="void" hint="Process table join relationships">
		<cfargument name="action" required="no" default="save"/> <!--- save = delete + insert, delete = delete --->
		<cfset var entity = ""/>
		<cfset var i = ""/>
		<!--- groups --->
		<cfset entity = createObject("component","#application.config.CFCOMPONENTS_PREFIX#.entities.users_groups")/>
		<cfset entity.deleteRec(this.uUserID)/>
		<cfif arguments.action eq "save" and listLen(this.UserGroupIDs)>
			<cfloop index="i" list="#this.UserGroupIDs#">
				<cfset entity.insertRec(this.uUserID,i)/>
			</cfloop>
		</cfif>
		<!--- roles --->
		<cfset entity = createObject("component","#application.config.CFCOMPONENTS_PREFIX#.entities.users_roles")/>
		<cfset entity.deleteRec(this.uUserID)/>
		<cfif arguments.action eq "save" and listLen(this.UserRoleIDs)>
			<cfloop index="i" list="#this.UserRoleIDs#">
				<cfset entity.insertRec(this.uUserID,i)/>
			</cfloop>
		</cfif>
	</cffunction>


<!--- permissions --->
	<cffunction name="resetPermissions" access="public" output="no" returntype="void" hint="Check content permisions with node permissions">
		<cfargument name="uUserID" required="yes" default="#this.uUserID#" type="numeric"/>
		<cfset var module = createObject("component","#application.config.CFCOMPONENTS_PREFIX#.modules.category")/>
		<cfset var q = ""/>
		<!--- get all nodes user is active in --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select t.tNodeID
			from users u, tree t, tree_users tu
			where u.uUserID = tu.tuUser_ID
			and	t.tNodeID = tu.tuNode_ID
			and u.uUserID = <cfqueryparam value="#arguments.uUserID#" cfsqltype="cf_sql_integer">;
		</cfquery>
		<!--- for each content item check/reset permissions --->
		<cfif q.recordCount neq 0>
			<cfloop query="q">
				<cfset module.resetUserPermissions(q.tNodeID)/>
			</cfloop>
		</cfif>

		<cfset module = createObject("component","#application.config.CFCOMPONENTS_PREFIX#.modules.content")/>
		<!--- get all content user is active in --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select c.cContentID
			from users u, content c, content_users cu
			where u.uUserID = cu.cuUser_ID
			and	c.cContentID = cu.cuContent_ID
			and u.uUserID = <cfqueryparam value="#arguments.uUserID#" cfsqltype="cf_sql_integer">;
		</cfquery>
		<!--- for each content item check/reset permissions --->
		<cfif q.recordCount neq 0>
			<cfloop query="q">
				<cfset module.resetUserPermissions(q.cContentID)/>
			</cfloop>
		</cfif>
	</cffunction>


<!--- count users --->
	<cffunction name="countUsersStatus" access="public" output="no" returntype="numeric" hint="Copy requested record into object">
		<cfargument name="uStatus" required="yes" type="numeric">
		<cfset var q = ""/>
		<cfset var total = 0/>
		<cfif listFindNoCase(session.anuser.userRoles,"siteadmin") or arguments.uStatus eq 10> <!--- unassigned users --->
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select uUserID
				from users
				where uStatus = <cfqueryparam value="#arguments.uStatus#" cfsqltype="cf_sql_tinyint">;
			</cfquery>
		<cfelse>
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select distinct(u.uUserID)
				from users u, groups g, users_groups ug
				where u.uUserID = ug.ugUser_ID
				and	g.gGroupID = ug.ugGroup_ID
				and u.uStatus = <cfqueryparam value="#arguments.uStatus#" cfsqltype="cf_sql_tinyint">
				and	g.gGroupID in (select g.gGroupID
									from users u, groups, users_groups ug
									where u.uUserID = ug.ugUser_ID
									and	g.gGroupID = ug.ugGroup_ID
									and	u.uStatus <> 5
									and	u.uUserID = #session.anuser.userID#)
				and u.uUserID not in (#getSiteAdminIDs()#);
			</cfquery>
		</cfif>
		<cfif q.recordCount neq 0>
			<cfset total = q.recordCount/>
		</cfif>
		<cfreturn total/>
	</cffunction>


	<cffunction name="countUsersGroup" access="public" output="no" returntype="numeric" hint="Copy requested record into object">
		<cfargument name="gGroupID" required="yes" type="numeric">
		<cfset var q = ""/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select  count(u.uUserID) as countUsers
			from users u, groups g, users_groups ug
			where u.uUserID = ug.ugUser_ID
			and	g.gGroupID = ug.ugGroup_ID
			and g.gGroupID = <cfqueryparam value="#arguments.gGroupID#" cfsqltype="cf_sql_integer">;
		</cfquery>
		<cfreturn q.countUsers/>
	</cffunction>


	<cffunction name="countUsersRole" access="public" output="no" returntype="numeric" hint="Copy requested record into object">
		<cfargument name="rRoleID" required="yes" type="numeric">
		<cfset var q = ""/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select  count(u.uUserID) as countUsers
			from users u, roles r, users_roles ur
			where u.uUserID = ur.urUser_ID
			and	r.rRoleID = ur.urRole_ID
			and r.rRoleID = <cfqueryparam value="#arguments.rRoleID#" cfsqltype="cf_sql_integer">;
		</cfquery>
		<cfreturn q.countUsers/>
	</cffunction>

<!--- GET queries --->
	<cffunction name="getPermissionUsers" access="public" output="no" returntype="query" hint="Returns user records based on group permissions">
		<cfargument name="uUserID" required="no" default="0" type="numeric"/>
		<cfset var q = ""/>
		<cfset var lstUserGroupIDs = 0/>
		<cfif arguments.uUserID eq 0 or listFindNoCase(session.anuser.userRoles,"siteadmin")>
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select uUserID, uFirstName, uLastName, uStatus
				from users
				where uStatus not in (5,10)
				order by uLastName, uFirstName;
			</cfquery>
		<cfelse> <!--- enforce user group permissions --->
			<cfset q = getPermissionGroups(arguments.uUserID)>
			<cfif q.recordCount>
				<cfset lstUserGroupIDs = valueList(q.gGroupID)>
			</cfif>
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select distinct u.uUserID, u.uFirstName, u.uLastName, uStatus
				from users u, users_groups ug, groups g
				where u.uStatus not in (5,10)
				and	u.uUserID = ug.ugUser_ID
				and	g.gGroupID = ug.ugGroup_ID
				and	g.gGroupID in (#lstUserGroupIDs#)
				and u.uUserID not in (#getSiteAdminIDs()#)
				order by u.uLastName, u.uFirstName;
			</cfquery>
		</cfif>
		<cfreturn q/>
	</cffunction>


	<!--- getPermissionGroups() method --->
	<cffunction name="getPermissionGroups" returntype="query" output="no" hint="Get groups for list filter">
		<cfargument name="uUserID" type="numeric" default="0" required="no"/>
		<cfargument name="allGroups" type="boolean" default="true" required="no"/>
		<cfset var q = ""/>
		<cfif arguments.uUserID eq 0 or listFindNoCase(session.anuser.userRoles,"siteadmin")>
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select	gGroupID, gIdentifier, gGroup, gStatus, gAuthenticate
				from groups
				where gStatus <> 5
				<cfif arguments.allGroups eq false>
					and gIdentifier <> 'everyone'
				</cfif>
				order by gListOrder DESC
			</cfquery>
		<cfelse> <!--- get users own groups --->
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select	distinct g.gGroupID, g.gIdentifier, g.gGroup, g.gStatus, g.gAuthenticate, g.gListOrder
				from users u, groups g, users_groups ug
				where g.gStatus <> 5
				<cfif arguments.allGroups eq false>
					and g.gIdentifier <> 'everyone'
				</cfif>
				and	u.uStatus not in (5,10)
				and	u.uUserID = ug.ugUser_ID
				and	g.gGroupID = ug.ugGroup_ID
				and	u.uUserID = #arguments.uUserID#
				order by g.gListOrder DESC
			</cfquery>
		</cfif>
		<cfreturn q/>
	</cffunction>


	<!--- getPermissionRoles() method --->
	<cffunction name="getPermissionRoles" returntype="query" output="no" hint="Get roles for list filter">
		<cfargument name="uUserID" type="numeric" default="0" required="no"/>
		<cfset var q = ""/>
		<cfif arguments.uUserID eq 0 or listFindNoCase(session.anuser.userRoles,"siteadmin")>
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select	rRoleID, rIdentifier, rRole, rStatus
				from roles
				where rStatus <> 5
				and rIdentifier not in ('anonymous')
				order by rListOrder DESC
			</cfquery>
		<cfelseif arguments.uUserID eq 0 or listFindNoCase(session.anuser.userRoles,"groupadmin")>
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select	rRoleID, rIdentifier, rRole, rStatus
				from roles
				where rStatus not in (5,10)
				and rIdentifier not in ('siteadmin','anonymous')
				order by rListOrder DESC
			</cfquery>
		<cfelse>
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select	r.rRoleID, r.rIdentifier, r.rRole, r.rStatus
				from users u, roles r, users_roles ur
				where r.rStatus <> 5
				and rIdentifier not in ('anonymous')
				and u.uStatus not in (5,10)
				and	u.uUserID = ur.urUser_ID
				and	r.rRoleID = ur.urRole_ID
				and	u.uUserID = #arguments.uUserID#
				order by r.rListOrder DESC
			</cfquery>
		</cfif>
		<cfreturn q/>
	</cffunction>


<!--- users groups roles methods () --->

	<!--- getUserGroups() method --->
	<cffunction name="getUserGroups" returntype="query" output="no" hint="Get groups a user belongs">
		<cfargument name="uUserID" type="numeric" required="yes"/>
		<cfset var q = ""/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select	distinct g.gGroupID, g.gGroup, g.gListOrder, g.gStatus
			from users u, groups g, users_groups ug
			where g.gStatus <> 5
			and	g.gGroupID = ug.ugGroup_ID
			and	u.uUserID = ug.ugUser_ID
			and	u.uUserID = #arguments.uUserID#
			order by g.gListOrder DESC;
		</cfquery>
		<cfreturn q/>
	</cffunction>

	<cffunction name="getRolesUser" returntype="query" output="no" hint="Get roles a user belongs to">
		<cfargument name="uUserID" type="numeric" required="yes"/>
		<cfset var q = ""/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select	distinct r.rRoleID, r.rRole, r.rListOrder, r.rStatus
			from users u, roles r, users_roles ur
			where r.rRoleID = ur.urRole_ID
			and	u.uUserID = ur.urUser_ID
			and	u.uUserID = #arguments.uUserID#
			order by r.rListOrder DESC;
		</cfquery>
		<cfreturn q/>
	</cffunction>

	<!--- getToolRoleIDs() method --->
	<cffunction name="getToolRoleIDs" returntype="string" output="no" hint="Get IDS for all roles with tool applications">
		<cfset var q = ""/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select distinct r.rRoleID
			from roles r, webapplications wa, roles_webapplications rw
			where r.rRoleID = rw.rwRole_ID
			and	wa.waWebApplicationID = rw.rwWebApplication_ID
		</cfquery>
		<cfreturn valueList(q.rRoleID)/>
	</cffunction>

	<!--- getSiteAdminRoleID() method --->
	<cffunction name="getSiteAdminRoleID" returntype="numeric" output="no" hint="Get id of siteadmin role">
		<cfset var q = ""/>
		<cfquery name="q" maxrows="1" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select rRoleID
			from roles
			where rIdentifier in ('siteadmin')
		</cfquery>
		<cfreturn q.rRoleID/>
	</cffunction>


	<cffunction name="getUserSettings" returntype="query" output="no" hint="Returns user settings for help called via Ajax">
		<cfargument name="uUserID" type="numeric" required="yes"/>
		<cfset var q = ""/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select uUsername, uPassword, uEmail, uLanguage, uNotify
			from users
			where uUserID = #arguments.uUserID#
		</cfquery>
		<cfreturn q/>
	</cffunction>


	<!--- toolAccess does not check role/application scheduling --->
	<cffunction name="toolAccess" access="public" output="no" returntype="boolean" hint="True if user has tool access">
		<cfargument name="uUserID" type="numeric" required="yes"/>
		<cfset var q = ""/>
		<cfset var hasAccess = false/>
		<cfset var ts = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,now()))/>
		<!--- get active tool applications assigned to user role --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select wa.waWebApplicationID
			from users u, roles r, users_roles ur, roles_webapplications rw, webapplications wa, webapplicationsregister wr
			where u.uUserID = <cfqueryparam value="#arguments.uUserID#" cfsqltype="cf_sql_integer"/>
			and	wr.wrStatus = 1
			and wa.waStatus = 1
			and r.rStatus = 1
			and	u.uStatus not in (5,10)
			and	wa.waWebAppReg_ID = wr.wrWebAppRegID
			and	wa.waWebApplicationID = rw.rwWebApplication_ID
			and	rw.rwRole_ID = r.rRoleID
			and	r.rRoleID = ur.urRole_ID
			and	u.uUserID = ur.urUser_ID;
		</cfquery>
		<cfif q.recordCount neq 0>
			<cfset hasAccess = true/>
		</cfif>
		<cfreturn hasAccess/>
	</cffunction>


<!--- miscellaneous validation methods --->

	<!--- addNewUser() method --->
	<cffunction name="addNewUser" returntype="boolean" output="no" hint="Check number of users against maximum allowed">
		<cfset var q = ""/>
		<cfset var anx = application.assetnow.anxlic()/>
		<!--- get current number of users --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select count(uUserID) as CurrentUsers
			from users
			where uStatus <> 5
		</cfquery>
		<cfif q.CurrentUsers lt application.config.LICENSE_USERS or application.config.LICENSE_USERS eq "unlimited">
			<cfreturn true/>
		<cfelse>
			<cfreturn false/>
		</cfif>
	</cffunction>


	<!--- allowDelete() method --->
	<cffunction name="allowDelete" returntype="boolean" output="no" access="public" hint="Check if siteadmin user account can be deleted">
		<cfargument name="uUserID" type="numeric" required="yes"/>
		<cfset var lstsiteadminIDs = getSiteAdminIDs()/>
		<cfif listLen(lstsiteadminIDs) gt 1>
			<cfreturn true/>
		<cfelseif lstsiteadminIDs eq arguments.uUserID>
			<cfreturn false/>
		<cfelse>
			<cfreturn true/>
		</cfif>
	</cffunction>


	<!--- getSiteAdminIDs() method --->
	<cffunction name="getSiteAdminIDs" returntype="string" output="no" access="public" hint="Get user IDs for all system administrators">
		<cfset var q = ""/>
		<cfquery blockfactor="30" name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select distinct u.uUserID
			from users u, roles r, users_roles ur
			where u.uStatus <> 5
			and	u.uUserID = ur.urUser_ID
			and	r.rRoleID = ur.urRole_ID
			and	r.rIdentifier in ('siteadmin');
		</cfquery>
		<cfreturn valueList(q.uUserID)/>
	</cffunction>


	<!--- getGroupAdminIDs() method --->
	<cffunction name="getGroupAdminIDs" returntype="string" output="no" access="public" hint="Get user IDs for all group administrators">
		<cfset var q = ""/>
		<cfquery blockfactor="30" name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select distinct u.uUserID
			from users u, roles r, users_roles ur
			where u.uStatus <> 5
			and	u.uUserID = ur.urUser_ID
			and	r.rRoleID = ur.urRole_ID
			and	r.rIdentifier in ('groupadmin');
		</cfquery>
		<cfreturn valueList(q.uUserID)/>
	</cffunction>


	<!--- getCountries() method --->
	<cffunction name="getCountries" access="public" output="no" returntype="query" hint="Returns countries">
		<cfset var q = ""/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select	cyCountryID, cyCountry
			from	countries
			where	cyDisplay = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
			order by cyListOrder DESC, cyCountry
		</cfquery>
		<cfreturn q/>
	</cffunction>


	<!--- getCountry() method --->
	<cffunction name="getCountry" access="public" output="no" returntype="string" hint="Returns a country name">
		<cfargument name="countryID" type="numeric" required="yes"/>
		<cfset var q = ""/>
		<cfquery name="q" maxrows="1" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select cyCountry
			from countries
			where cyCountryID = #arguments.CountryID#
		</cfquery>
		<cfreturn q.cyCountry/>
	</cffunction>


<!---  username and password methods --->

	<!--- uniqueUNPW() method --->
	<cffunction name="uniqueUNPW" access="private" output="no" returntype="void" hint="Tests for unique un/pw and changes them if required">
		<!--- if duplicate username/password then replace unique one --->
		<cfif isDuplicateUN() and isDuplicatePW()>
			<cfset session.anmodule.appStatus = "AN_ERROR_USERNAME_PASSWORD"/>
			<cfset this.uUsername = newUsername(this.uFirstName,this.uLastName)/>
			<cfset this.uPassword = newPassword()/>
		<cfelseif isDuplicateUN()>
			<cfset session.anmodule.appStatus = "AN_ERROR_USERNAME"/>
			<cfset this.uUsername = newUsername(this.uFirstName)/>
		<cfelseif isDuplicatePW()>
			<cfset session.anmodule.appStatus = "AN_ERROR_PASSWORD"/>
			<cfset this.uPassword = newPassword()/>
		<cfelse>
			<cfset session.anmodule.appStatus = ""/>
		</cfif>
		<cfif isDuplicateAlias()>
			<cfset this.uAlias = newAlias(this.uFirstName,this.uLastName)/>
		</cfif>
	</cffunction>


	<!--- isDuplicateUN() method --->
	<cffunction name="isDuplicateUN" access="private" output="no" returntype="boolean" hint="Check for duplicate username">
		<cfset var q = ""/>
		<cfset var dup = true/>
		<cfif len(this.uUsername) gte 5> <!--- username must be 5 chars min --->
			<cfquery name="q" maxrows="1" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select uUserID
				from users
				where uUsername = <cfqueryparam value="#this.uUsername#" cfsqltype="cf_sql_varchar">
				<cfif this.uUserID neq 0>
					and	uUserID <> <cfqueryparam value="#this.uUserID#" cfsqltype="cf_sql_integer">
				</cfif>
			</cfquery>
			<cfif q.recordCount eq 0>
				<cfset dup = false/>
			</cfif>
		</cfif>
		<cfreturn dup/>
	</cffunction>


	<!--- isDuplicatePW() method --->
	<cffunction name="isDuplicatePW" access="private" output="no" returntype="boolean" hint="Check for duplicate password">
		<cfset var q = ""/>
		<cfset var c = 0/>
		<cfset var n = 0/>
		<cfset var i = 0/>
		<cfquery name="q" maxrows="1" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select uUserID
			from users
			where uPassword = <cfqueryparam value="#this.uPassword#" cfsqltype="cf_sql_varchar">
			<cfif this.uUserID neq 0>
				and	uUserID <> <cfqueryparam value="#this.uUserID#" cfsqltype="cf_sql_integer">
			</cfif>
		</cfquery>
		<!--- check if pw equals or exceeds mask reqirements, ensure resonable mask to allow unique pw generation --->
		<!---
		<cfif len(application.config.PASSWORD_FORMAT) lt 7>
			<cfset application.config.PASSWORD_FORMAT = "xxxxxxx"/>
		</cfif>
		--->
		<cfloop index="i" from="1" to="#len(application.config.PASSWORD_FORMAT)#">
			<cfif mid(application.config.PASSWORD_FORMAT,i,1) eq "n">
				<cfset n = n + 1/> <!--- number of numbers required in pw --->
			<cfelseif mid(application.config.PASSWORD_FORMAT,i,1) eq "c">
				<cfset c = c + 1/> <!--- number of alphas required in pw --->
			</cfif>
		</cfloop>
		<cfloop index="i" from="1" to="#len(this.uPassword)#">
			<cfif isNumeric(mid(this.uPassword,i,1))>
				<cfset n = n - 1/> <!--- 0 = sufficent numbers in pw --->
			<cfelse>
				<cfset c = c - 1/>	<!--- 0 = sufficient alphas in pw --->
			</cfif>
		</cfloop>
		<cfif q.recordCount or (n gt 0) or (c gt 0) or (len(this.uPassword) lt len(application.config.PASSWORD_FORMAT))>
			<cfreturn true/>
		<cfelse>
			<cfreturn false/>
		</cfif>
	</cffunction>


	<cffunction name="isDuplicateAlias" access="private" output="no" returntype="boolean" hint="Check for duplicate alias">
		<cfset var q = ""/>
		<cfset var dup = true/>
		<cfif len(this.uAlias) gte 5> <!--- alias must be 5 chars min --->
			<cfquery name="q" maxrows="1" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select uUserID
				from users
				where uAlias = <cfqueryparam value="#this.uAlias#" cfsqltype="cf_sql_varchar">
				<cfif this.uUserID neq 0>
					and	uUserID <> <cfqueryparam value="#this.uUserID#" cfsqltype="cf_sql_integer">
				</cfif>
			</cfquery>
			<cfif q.recordCount eq 0>
				<cfset dup = false/>
			</cfif>
		</cfif>
		<cfreturn dup/>
	</cffunction>


	<!--- newUsername() method --->
	<cffunction name="newUsername" returntype="string" output="no" access="public" hint="Generate unique username">
		<cfargument name="unFirstName" type="string" required="no" default="#this.uFirstName#"/>
		<cfargument name="unLastName" type="string" required="no" default="#this.uLastName#"/> <!--- do not specify lastName for numeric format username --->
		<cfset var unUnique = false/>
		<cfset var i = 0/>
		<cfset var str1 = arguments.unFirstName/>
		<cfset var str2 = arguments.unLastName/>
		<!--- ramdomize CF random number generator --->
		<cfset randomize(timeFormat(now(),"HHmmss"))/>
		<!--- base lastname / firstname order on length --->
		<cfif len(str2) gte len(str1)>
			<cfset str1 = arguments.unLastName/>
			<cfset str2 = arguments.unFirstName/>
		</cfif>
		<cfloop condition="not unUnique">
			<cfset i = i + 1/>
			<cftry>
				<cfif i lte len(str2)>
					<cfset this.uUsername = str1 & mid(str2,1,i)/> <!--- build unique un from last name and firstname chars --->
				<cfelse>
					<cfset this.uUsername = str1 & mid(str2,1,1) & this.uUserID/>
					<cfset unUnique = true/> <!--- uUserID always unique --->
				</cfif>
				<cfif len(this.uUsername) lt 5 or this.uUserID eq 0>
					<cfset this.uUsername = this.uUsername & replaceList(randRange(10000,99999),"0,1","x,z")/>
				</cfif>
				<cfcatch>
					<cfset this.uUsername = str1 & str2 & replaceList(randRange(10000,99999),"0,1","x,z")/>
				</cfcatch>
			</cftry>
			<cfset this.uUsername = lcase(this.uUsername)/>
			<cfif unUnique eq false and isDuplicateUN()>
				<cfset unUnique = false/>
			<cfelse>
				<cfset unUnique = true/>
			</cfif>
		</cfloop>
		<cfreturn this.uUsername/>
	</cffunction>


	<!--- newPassword() method --->
	<cffunction name="newPassword" returntype="string" output="no" access="public" hint="Generate unique password">
		<cfset var pwAlphabet = "b,c,d,f,g,h,j,k,m,n,p,q,r,s,t,v,w,x,y,z"/> <!--- alpha chars to use in password --->
		<cfset var pwMask = application.config.PASSWORD_FORMAT/> <!--- mask c = character, n = number, x = either --->
		<cfset var pwLen = len(pwMask)/> <!--- length of password --->
		<cfset var getChar = "x"/>
		<cfset var pwUnique = false/>
		<cfset var hasNumbers = false/>
		<cfset var hasChars = false/>
		<cfset var i = 0/>
		<cfset var j = 0/>
		<!--- ramdomize CF random number generator --->
		<cfset randomize(timeFormat(now(),"HHmmss"))/>
		<!--- check if pw equals or exceeds mask reqirements, ensure resonable mask to allow unique pw generation --->
		<!---
		<cfif pwLen lt 7>
			<cfset application.config.PASSWORD_FORMAT = "xxxxxxx"/>
			<cfset pwMask = application.config.PASSWORD_FORMAT/>
			<cfset pwLen = len(pwMask)/>
		</cfif>
		--->
		<cfloop condition="not pwUnique">
			<cfset j = j + 1/>
			<!--- max 100 attempts --->
			<cfif j lt 100>
				<cfset this.uPassword = ""/>
				<!--- use config mask --->
				<cfloop index="i" from="1" to="#len(pwMask)#">
					<cfset getChar = mid(pwMask,i,1)/>
					<!--- x = either number of alpha --->
					<cfif getChar eq "x">
						<cfset getChar = listGetAt("n,c",randRange(1,2))/>
					</cfif>
					<cfif getChar eq "n">
						<cfset this.uPassword = this.uPassword & "#randRange(2,9)#"/>
					<cfelse>
						<cfset this.uPassword = this.uPassword & "#listGetAt(pwAlphabet,randRange(1,listLen(pwAlphabet)))#"/>
					</cfif>
				</cfloop>
			<cfelse>
				<cfif this.uUserID eq 0>
					<cfset this.uUsername = this.uPassword & replaceList(randRange(10000,99999),"0,1","x,z")/>
				<cfelse>
					<cfset this.uPassword = this.uPassword & this.uUserID/>
				</cfif>
				<cfset pwUnique = true/> <!--- uUserID always unique --->
			</cfif>
			<!--- if no matching passwords were found exit loop --->
			<cfif pwUnique eq false and isDuplicatePW()>
				<cfset pwUnique = false/>
			<cfelse>
				<cfset pwUnique = true/>
			</cfif>
		</cfloop>
		<cfreturn this.uPassword/>
	</cffunction>


	<cffunction name="newAlias" returntype="string" output="no" access="public" hint="Generate unique alias">
		<cfargument name="unFirstName" type="string" required="no" default="#this.uFirstName#"/>
		<cfargument name="unLastName" type="string" required="no" default="#this.uLastName#"/>
		<cfset var alUnique = false/>
		<cfset var i = 0/>
		<!--- ramdomize CF random number generator --->
		<cfset randomize(timeFormat(now(),"HHmmss"))/>
		<cfloop condition="not alUnique">
			<cfset i = i + 1/>
			<cfif i lte len(arguments.unLastName)>
				<cfset this.uAlias = arguments.unFirstName & mid(arguments.unLastName,1,i)/> <!--- build unique un from last name and firstname chars --->
			<cfelse>
				<cfset this.uAlias = arguments.unFirstName & mid(arguments.unLastName,1,1) & this.uUserID/>
				<cfset alUnique = true/> <!--- uUserID always unique --->
			</cfif>
			<cfif len(this.uAlias) lt 5 or this.uUserID eq 0>
				<cfset this.uAlias = this.uAlias & randRange(10000,99999)/>
			</cfif>
			<cfif alUnique eq false and isDuplicateAlias()>
				<cfset alUnique = false/>
			<cfelse>
				<cfset alUnique = true/>
			</cfif>
		</cfloop>
		<cfreturn this.uAlias/>
	</cffunction>


	<!--- password encrypt/decrypt/hash functions --->

	<cffunction name="hashPW" access="public" output="no" returntype="string" hint="Encrypt pw">
		<cfargument name="uPassword" type="string" required="no" default="#this.uPassword#"/>
		<cfargument name="uIdentifier" type="string" required="no" default="#this.uIdentifier#"/>
		<cfreturn hash(arguments.uIdentifier & arguments.uPassword)/>
	</cffunction>


	<cffunction name="encryptPW" access="public" output="no" returntype="string" hint="Encrypt pw">
		<cfargument name="uPassword" type="string" required="no" default="#this.uPassword#"/>
		<cfargument name="encryptKey" type="string" required="no" default="#this.uIdentifier#"/>
		<cfreturn encrypt(arguments.uPassword,arguments.encryptKey)/>
	</cffunction>


	<cffunction name="decryptPW" access="public" output="no" returntype="string" hint="Decrypt pw">
		<cfargument name="uPassword" type="string" required="no" default="#this.uPassword#"/>
		<cfargument name="encryptKey" type="string" required="no" default="#this.uIdentifier#"/>
		<cfreturn decrypt(arguments.uPassword,arguments.encryptKey)/>
	</cffunction>


<!--- getters --->

	<cffunction name="getUserID" access="public" output="no" returntype="numeric">
		<cfreturn this.uUserID/>
	</cffunction>

	<cffunction name="getName" access="public" output="no" returntype="string">
		<cfreturn "#this.uFirstName# #this.uLastName#"/>
	</cffunction>

</cfcomponent>