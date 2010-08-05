<cfcomponent 
		name="Library" 
		hint="Model layer for Library tool module">

	<!--- init() method --->
	<cffunction name="init" access="public" output="no" returntype="void" hint="initialize library object">
		<cfargument name="lLibraryID" required="no" type="numeric" default="0"/>
		<cfset var q = ""/>
		<cfif arguments.lLibraryID neq 0>
			<cfset q = get(arguments.lLibraryID)/>
			<!--- set results in this scope --->
			<cfscript>
				application.anlock.lockRecord(q.lIdentifier);
				session.anmodule.appRecord = q.lIdentifier;
				session.anmodule.appTitle = q.lLibrary;
				this.lLibraryID = q.lLibraryID;
				this.lIdentifier = q.lIdentifier;
				this.lLibrary = q.lLibrary;
				this.lDescription = q.lDescription;
				this.lType = q.lType;
				this.lLibrary_ID = q.lLibrary_ID;
				this.lStatus = q.lStatus;
				this.lListOrder = q.lListOrder;
				this.lTSUpdated = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,now()));
				/* get group assignments */
				q = getLibraryGroups(arguments.lLibraryID);
				this.assignedGroupIDs = valueList(q.gGroupID);
			</cfscript>
		<cfelse>
			<cfscript>
				application.anlock.unlockRecord();
				this.lLibraryID = 0;
				this.lIdentifier = createUUID();
				this.lLibrary = "";
				this.lDescription = "";
				this.lType = 0;
				this.lLibrary_ID = 0;
				this.lStatus = 0;
				this.lListOrder = 0;
				this.lTSUpdated = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,now()));
				this.assignedGroupIDs = "";
			</cfscript>
		</cfif>
	</cffunction>


<!--- L I N E D methods - (L)ist (I)nfo (N)ew (E)dit (D)elete --->

	<!--- list() method --->
	<cffunction name="list" access="public" output="no" returntype="query" hint="Returns query of all libraries">
		<cfargument name="lType" default="0" required="no" type="numeric"/>
		<cfargument name="lLibraryID" default="-1" required="no" type="numeric"/>
		<cfargument name="criteria" default="" required="no" type="string"/>
		<cfset var q = ""/>
		<cfset var w = ""/>
		<!--- query based on search word/id and user permissions --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select lLibraryID, lIdentifier, lLibrary, lDescription, lStatus, lType, lTSUpdated, lLibrary_ID
			from library
			where 1 = 1
			<cfif arguments.lType neq 0>
				and lType = #arguments.lType#
			</cfif>
			<cfif arguments.lLibraryID gte 0>
				and lLibrary_ID = #arguments.lLibraryID#
			</cfif>
			<cfif len(arguments.criteria)>
				<cfloop index="w" list="#arguments.criteria#" delimiters=" ">
					and	(lLibrary like '%#w#%'<cfif isNumeric(w)> or lLibraryID = #w#</cfif>)
				</cfloop>
			</cfif>
			order by lListOrder DESC, lTSUpdated DESC;
		</cfquery>
		<cfreturn q/>
	</cffunction>


	<!--- get() method --->
	<cffunction name="get" access="public" output="no" returntype="query" hint="Copy requested record into object">
		<cfargument name="lLibraryID" required="yes" type="numeric"/>
		<cfset var q = ""/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select  *
			from    library
			where   lLibraryID = <cfqueryparam value="#arguments.lLibraryID#" cfsqltype="cf_sql_integer"/>;
		</cfquery>
		<cfreturn q/>
	</cffunction>


	<!--- new() method --->
	<cffunction name="new" access="public" output="no" returntype="void" hint="Save new object values in database">
		<cfset var q = 0/>
		<cfset this.lListOrder = getMaxListOrder(this.lType) + 1/>
		<cflock name="#application.applicationName#-new-library" type="exclusive" timeout="30" throwontimeout="yes">
			<cftransaction action="begin">
				<cftry>
					<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.library" method="insertRec" argumentcollection="#this#"/>
					<!--- get new record primary key --->
					<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
						select max(lLibraryID) as NewID
						from library
					</cfquery>
					<cfset this.lLibraryID = q.NewID/>
					<cfset join()/>
					<cfcatch>
						<cftransaction action="rollback"/>
						<cfrethrow/>
					</cfcatch>
				</cftry>
			</cftransaction>
		</cflock>
		<!--- update object --->
		<cfset init(this.lLibraryID)/>
		<cfset session.anmodule.appStatus = "AN_SAVED"/>
	</cffunction>


	<!--- edit() method --->
	<cffunction name="edit" access="public" output="no" returntype="void" hint="Save object in database">
		<cftransaction action="begin">
			<cftry>
				<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.library" method="updateRec" argumentcollection="#this#"/>
				<cfset join()/>
				<cfcatch>
					<cftransaction action="rollback"/>
					<cfrethrow/>
				</cfcatch>
			</cftry>
		</cftransaction>
		<!--- update object --->
		<cfset init(this.lLibraryID)/>
		<cfset session.anmodule.appStatus = "AN_SAVED"/>
	</cffunction>


	<!--- delete() method --->
	<cffunction name="delete" access="public" output="no" returntype="boolean" hint="Delete object from database">
		<cfargument name="lLibraryID" type="numeric" required="yes"/>
		<cfset var q = activeLibrary(arguments.lLibraryID)/>
		<cfset var deleted = false/>
		<!--- if not active the delete it --->
		<cfif q.recordCount eq 0>
			<cfset init(arguments.lLibraryID)/>
			<cftransaction action="begin">
				<cftry>
					<!--- delete library_group joins --->
					<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.library_groups" method="deleteRec">
						<cfinvokeargument name="lLibraryID" value="#arguments.lLibraryID#">
					</cfinvoke>
					<!--- delete library_revisions joins --->
					<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.library_revisions" method="deleteRec">
						<cfinvokeargument name="lLibraryID" value="#arguments.lLibraryID#">
					</cfinvoke>
					<!--- delete library_revisions joins --->
					<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.library_tree" method="deleteRec">
						<cfinvokeargument name="lLibraryID" value="#arguments.lLibraryID#">
					</cfinvoke>
					<!--- delete library item --->
					<cfinvoke component="#application.config.CFCOMPONENTS_PREFIX#.entities.library" method="deleteRec">
						<cfinvokeargument name="lLibraryID" value="#arguments.lLibraryID#">
					</cfinvoke>
					<cfcatch>
						<cftransaction action="rollback"/>
						<cfrethrow/>
					</cfcatch>
				</cftry>
			</cftransaction>
			<cfset normalizeListOrders(this.lLibrary_ID)/>
			<!--- update status message --->
			<cfset session.anmodule.appStatus = "AN_DELETED"/>
			<cfset deleted = true/>
		<cfelse>
			<cfset session.anmodule.appStatus = "AN_ERROR_RESERVED_CANNOT_BE_DELETED"/>
			<cfset deleted = false/>
		</cfif>
		<cfreturn deleted/>
	</cffunction>


	<!--- join() method --->
	<cffunction name="join" access="private" output="no" returntype="void" hint="Process table join relationships">
		<cfargument name="action" required="no" default="save"/> <!--- save = delete + insert, delete = delete --->
		<cfset var entity = createObject("component","#application.config.CFCOMPONENTS_PREFIX#.entities.library_groups")/>
		<cfset var i = ""/>
		<cfset var lst = getAllChildrenIDs(this.lLibraryID)/>
		<cfset var q2 = ""/>
		<!--- groups --->
		<cfset entity.deleteRec(this.lLibraryID)/>
		<cfif arguments.action eq "save" and listLen(this.assignedGroupIDs)>
			<cfloop index="i" list="#this.assignedGroupIDs#">
				<cfset entity.insertRec(this.lLibraryID,i)/>
			</cfloop>
		</cfif>
		<!--- propogate permissions, children must be a subset of parent permissions --->
		<cfloop index="i" list="#lst#">
			<cfquery name="q2" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select *
				from library_groups
				where lgLibrary_ID = #i#
			</cfquery>
			<cfloop query="q2">
				<cfif listFindNoCase(this.assignedGroupIDs,q2.lgGroup_ID) eq 0>
					<cfset entity.deleteRec(q2.lgLibrary_ID,q2.lgGroup_ID)/>
				</cfif>
			</cfloop>
		</cfloop>
	</cffunction>


	<cffunction name="move" access="public" output="no" returntype="void" hint="Move category">
		<cfargument name="lLibraryID" type="numeric" required="no" default="0"/>
		<cfargument name="toLibraryID" type="numeric" required="no" default="0"/>
		<cfset init(arguments.lLibraryID)/>
		<cfset this.lLibrary_ID = arguments.toLibraryID/>
		<cfset this.assignedGroupIDs = ""/> <!--- clear permissions --->
		<cfset edit()/>
		<cfset normalizeListOrders(this.lLibrary_ID)/>
	</cffunction>

	<cffunction name="up" access="public" output="no" returntype="void" hint="Move category up">
		<cfargument name="lLibraryID" type="numeric" required="no" default="0"/>
		<cfset init(arguments.lLibraryID)/>
		<!--- get category above and decrease list order --->
		<cfquery username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			update library
			set lListOrder = #this.lListOrder#
			where lLibrary_ID = #this.lLibrary_ID#
			and lListOrder = #this.lListOrder + 1#
		</cfquery>
		<!--- get category and increase list order --->
		<cfquery username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			update library
			set lListOrder = #this.lListOrder + 1#
			where lLibraryID = #this.lLibraryID#
		</cfquery>
		<cfset normalizeListOrders(this.lLibrary_ID)/>
	</cffunction>

	<cffunction name="down" access="public" output="no" returntype="void" hint="Move category down">
		<cfargument name="lLibraryID" type="numeric" required="no" default="0"/>
		<cfset init(arguments.lLibraryID)/>
		<!--- get category below and increase list order --->
		<cfquery username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			update library
			set lListOrder = #this.lListOrder#
			where lLibrary_ID = #this.lLibrary_ID#
			and lListOrder = #this.lListOrder - 1#
		</cfquery>
		<!--- get category and decrease list order --->
		<cfquery username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			update library
			set lListOrder = #this.lListOrder - 1#
			where lLibraryID = #this.lLibraryID#
		</cfquery>
		<cfset normalizeListOrders(this.lLibrary_ID)/>
	</cffunction>

	<cffunction name="getMaxListOrder" access="public" output="no" returntype="numeric" hint="Gets maximum list order for library">
		<cfargument name="lType" type="numeric" required="no" default="0"/>
		<cfset var q = ""/>
		<cfset var maxListOrder = 0/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select max(lListOrder) as maxListOrder
			from library
			where lType = #arguments.lType#
		</cfquery>
		<cfif q.recordCount neq 0>
			<cfset maxListOrder = val(q.maxListOrder)/>
		</cfif>
		<cfreturn maxListOrder/>
	</cffunction>


	<cffunction name="normalizeListOrders" access="public" output="no" returntype="void" hint="Normalizes listorders typically used after delete">
		<cfargument name="lLibrary_ID" type="numeric" required="no" default="0"/>
		<cfset var q = ""/>
		<cfset var i = 0/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select lLibraryID, lListOrder
			from library
			where lLibrary_ID = #arguments.lLibrary_ID#
			order by lListOrder
		</cfquery>
		<cfloop index="i" from="1" to="#q.recordCount#">
			<cfquery username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				update library
				set lListOrder = #i#
				where lLibraryID = #q.lLibraryID[i]#
			</cfquery>
		</cfloop>
	</cffunction>


	<cffunction name="getAllChildrenIDs" access="public" output="no" returntype="string" hint="Gets all nodes below specified">
		<cfargument name="lLibraryID" type="numeric" required="no" default="0"/>
		<cfset var q = getChildren(arguments.lLibraryID)/>
		<cfset var lst = valueList(q.lLibraryID)/>
		<cfset var i = 0/>
		<cfset var lst2 = ""/>
		<cfloop index="i" list="#lst#">
			<cfset lst2 = getAllChildrenIDs(i)/>
			<cfif listLen(lst2) neq 0>
				<cfset lst = listAppend(lst,lst2)/>
			</cfif>
		</cfloop>
		<cfreturn lst/>
	</cffunction>


	<cffunction name="getChildren" access="public" output="no" returntype="query" hint="Gets child nodes of specified node">
		<cfargument name="lLibraryID" type="numeric" required="no" default="0"/>
		<cfargument name="lType" type="numeric" required="no" default="0"/>
		<cfset var q = ""/>
		<!--- check record is not in use --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select lLibraryID, lLibrary, lStatus
			from library
			where lLibrary_ID = #arguments.lLibraryID#
			<cfif arguments.lType neq 0>
				and lType = #arguments.lType#
			</cfif>;
		</cfquery>
		<cfreturn q/>
	</cffunction>


	<cffunction name="getChildrenWithPermissions" access="public" output="no" returntype="query" hint="Gets child nodes within user group permissions">
		<cfargument name="lLibraryID" type="numeric" required="no" default="0"/>
		<cfargument name="lType" type="numeric" required="no" default="0"/>
		<cfargument name="userGroupIDs" type="string" required="no" default="#session.anuser.userGroupIDs#"/>
		<cfargument name="userRoles" type="string" required="no" default="#session.anuser.userGroupIDs#"/>
		<cfset var q = ""/>
		<!--- no limits on site admin --->
		<cfif listFindNoCase(arguments.userRoles,"siteadmin")>
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				select lLibraryID, lLibrary, lStatus
				from library
				where lStatus = 1
				<cfif arguments.lLibraryID neq 0>
					and	lLibrary_ID = #arguments.lLibraryID#
				</cfif>
				and lType = #arguments.lType#
			</cfquery>
		<cfelse>
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
				(select distinct l.lLibraryID, l.lLibrary, l.lStatus
				from library l, groups g, library_groups lg
				where l.lStatus = 1
				and l.lLibraryID = lg.lgLibrary_ID
				and g.gGroupID = lg.lgGroup_ID
				and g.gStatus <> 5
				and g.gGroupID in (#arguments.userGroupIDs#)
				<cfif arguments.lLibraryID neq 0>
					and l.lLibrary_ID = #arguments.lLibraryID#
				</cfif>
				and l.lType = #arguments.lType#)
				union
				(select distinct lLibraryID, lLibrary, lStatus
				from library
				where lStatus = 1
				and lLibraryID not in (select lgLibrary_ID from library_groups)
				<cfif arguments.lLibraryID neq 0>
					and lLibrary_ID = #arguments.lLibraryID#
				</cfif>
				and lType = #arguments.lType#)
			</cfquery>
		</cfif>
		<cfreturn q/>
	</cffunction>


	<cffunction name="activeLibrary" access="public" output="no" returntype="query" hint="Gets joins from database for library items used in content/category">
		<cfargument name="lLibraryID" type="numeric" required="yes"/>
		<cfset var q = ""/>
		<!--- check record is not in use --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			(select c.cContentID as cContentID, 0 as tNodeID
				from content c, library l, revisions rv, content_revisions cr, library_revisions lr
				where c.cContentID = cr.crContent_ID
				and rv.rvRevisionID = cr.crRevision_ID
				and l.lLibraryID = lr.lrLibrary_ID
				and	rv.rvRevisionID = lr.lrRevision_ID
				and	l.lLibraryID = <cfqueryparam value="#arguments.lLibraryID#" cfsqltype="cf_sql_integer">
			)
			union
			(select 0 as cContentID, t.tNodeID as tNodeID
				from tree t, library l, library_tree lt
				where t.tNodeID = lt.ltNode_ID
				and l.lLibraryID = lt.ltLibrary_ID
				and	l.lLibraryID = <cfqueryparam value="#arguments.lLibraryID#" cfsqltype="cf_sql_integer">
			);
		</cfquery>
		<cfreturn q/>
	</cffunction>

	<cffunction name="activeRevision" access="public" output="no" returntype="query" hint="Gets joins from database for library items used in content/category">
		<cfargument name="lLibraryID" type="numeric" required="yes"/>
		<cfargument name="fileName" type="string" required="yes"/>
		<cfset var q = ""/>
		<!--- check record is not in use --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select c.cContentID
			from content c, library l, revisions rv, content_revisions cr, library_revisions lr
			where c.cContentID = cr.crContent_ID
			and rv.rvRevisionID = cr.crRevision_ID
			and l.lLibraryID = lr.lrLibrary_ID
			and	rv.rvRevisionID = lr.lrRevision_ID
			and	l.lLibraryID = <cfqueryparam value="#arguments.lLibraryID#" cfsqltype="cf_sql_integer">
			and	lr.lrFileName = <cfqueryparam value="#arguments.fileName#" cfsqltype="cf_sql_varchar">;
		</cfquery>
		<cfreturn q/>
	</cffunction>

	<cffunction name="activeNode" access="public" output="no" returntype="query" hint="Gets joins from database for library items used in content/category">
		<cfargument name="lLibraryID" type="numeric" required="yes"/>
		<cfargument name="fileName" type="string" required="yes"/>
		<cfset var q = ""/>
		<!--- check record is not in use --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			 select 0 as cContentID, t.tNodeID as tNodeID
			from tree t, library l, library_tree lt
			where t.tNodeID = lt.ltNode_ID
			and l.lLibraryID = lt.ltLibrary_ID
			and	l.lLibraryID = <cfqueryparam value="#arguments.lLibraryID#" cfsqltype="cf_sql_integer">
			and	lt.ltFileName = <cfqueryparam value="#arguments.fileName#" cfsqltype="cf_sql_varchar">;
		</cfquery>
		<cfreturn q/>
	</cffunction>

	<cffunction name="libraryCount" access="public" output="no" returntype="numeric" hint="Gets count of files in library">
		<cfargument name="lLibraryID" type="numeric" required="yes"/>
		<cfset var q = get(arguments.lLibraryID)/>
		<cfset var q2 = ""/>
		<cfset var count = 0/>
		<cfset var d = ""/>
		<!--- count of dir content --->
		<cfif q.lType[1] eq 1>
			<cfset d = application.libs.formatOSPath("images/library/#q.lLibraryID[1]#")/>
		<cfelse>
			<cfset d = application.libs.formatOSPath("assets/library/#q.lLibraryID[1]#")/>
		</cfif>
		<cfdirectory action="list" name="q2" directory="#d#"/>
		<cfloop query="q2">
			<cfif q2.type eq "file">
				<cfset count = count + 1/>
			</cfif>
		</cfloop>
		<cfreturn count/>
	</cffunction>

	<cffunction name="libraryEmpty" access="public" output="no" returntype="boolean" hint="True if library empty">
		<cfargument name="lLibraryID" type="numeric" required="yes"/>
		<cfset var count = libraryCount(arguments.lLibraryID)/>
		<cfset var q = activeLibrary(arguments.lLibraryID)/>
		<cfset var q2 = getChildren(arguments.lLibraryID)/>
		<cfset var empty = false/>
		<cfif count eq 0 and q.recordCount eq 0 and q2.recordCount eq 0>
			<cfset empty = true/>
		</cfif>
		<cfreturn empty/>
	</cffunction>

	<cffunction name="getPermissionGroups" returntype="query" output="no" hint="Get groups library may be assigned to">
		<cfargument name="lLibraryID" type="numeric" required="yes"/>
		<cfset var q = getLibraryGroups(arguments.lLibraryID)/>
		<cfset var q2 = getPublisherGroups()/>
		<cfif q.recordCount neq 0>
			<cfreturn q/>
		<cfelse>
			<cfreturn q2/>
		</cfif>
	</cffunction>

	<cffunction name="getLibraryGroups" returntype="query" output="no" hint="Get groups library is assigned to">
		<cfargument name="lLibraryID" type="numeric" required="yes"/>
		<cfset var q = ""/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select	distinct g.gGroupID, g.gGroup, g.gListOrder, g.gStatus
			from library l, groups g, library_groups lg
			where g.gStatus <> 5
			and	g.gGroupID = lg.lgGroup_ID
			and	l.lLibraryID = lg.lgLibrary_ID
			and	l.lLibraryID = #arguments.lLibraryID#
			order by g.gListOrder DESC;
		</cfquery>
		<cfreturn q/>
	</cffunction>

	<cffunction name="getLibraryGroupIDs" returntype="string" output="no" hint="Return list of groupids library assigned to">
		<cfargument name="lLibraryID" type="numeric" required="yes"/>
		<cfset var q = ""/>
		<cfset var lst = ""/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select	distinct g.gGroupID
			from library l, groups g, library_groups lg
			where g.gStatus <> 5
			and	g.gGroupID = lg.lgGroup_ID
			and	l.lLibraryID = lg.lgLibrary_ID
			and	l.lLibraryID = #arguments.lLibraryID#;
		</cfquery>
		<cfif q.recordCount neq 0>
			<cfset lst = valueList(q.gGroupID)/>
		</cfif>
		<cfreturn lst/>
	</cffunction>

	<cffunction name="libraryAccess" returntype="boolean" output="no" hint="Return true if user has group access permissions">
		<cfargument name="lLibraryID" type="numeric" required="yes"/>
		<cfargument name="userGroupIDs" type="string" required="no" default="#session.anuser.userGroupIDs#"/>
		<cfset var lst = getLibraryGroupIDs(arguments.lLibraryID)/>
		<cfset var access = false/>
		<cfset var i = ""/>
		<cfif listLen(lst) and listLen(arguments.userGroupIDs)>
			<cfloop index="i" list="#lst#">
				<cfif listFindNoCase(arguments.userGroupIDs,i)>
					<cfset access = true/>
					<cfbreak/> <!--- match found no need to continue --->
				</cfif>
			</cfloop>
		<cfelseif listLen(lst) eq 0>
			<cfset access = true/> <!--- no permissions --->
		</cfif>
		<cfreturn access/>
	</cffunction>

	<cffunction name="getPublisherGroups" returntype="query" output="no" hint="Get groups with publishing access">
		<cfset var q = ""/>
		<cfset var ts = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,now()))/>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select	distinct g.gGroupID, g.gGroup, g.gListOrder, g.gStatus
			from users u, groups g, roles r, webapplications wa, webapplicationsregister wr, users_groups ug, users_roles ur, roles_webapplications rw
			where g.gStatus <> 5
			and u.uStatus <> 5
			and r.rStatus <> 5
			and g.gGroupID = ug.ugGroup_ID
			and u.uUserID = ug.ugUser_ID
			and u.uUserID = ur.urUser_ID
			and r.rRoleID = ur.urRole_ID
			and r.rRoleID = rw.rwRole_ID
			and wa.waWebApplicationID = rw.rwWebApplication_ID
			and wa.waWebAppReg_ID = wr.wrWebAppRegID
			and wr.wrIdentifier = 'A40D51DA-C0A8-7D13-9310FA324A717E20'
			<!--- TODO: do not restrict based on user/role or app status
			and	(u.uStatus = 1 or (u.uStatus = 2 and #ts# between u.uTSOn and u.uTSOff))
			and	(r.rStatus = 1 or (r.rStatus = 2 and #ts# between r.rTSOn and r.rTSOff))
			and	(wa.waStatus = 1 or (wa.waStatus = 2 and #ts# between wa.waTSOn and wa.waTSOff))
			--->
			order by g.gListOrder DESC;
		</cfquery>
		<cfreturn q/>
	</cffunction>

</cfcomponent>