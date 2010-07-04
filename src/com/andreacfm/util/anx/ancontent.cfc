<!---
28/10/2008	-	6.5.2 update2b 
--->
<!---- CUSTOM CHANGES
@ Tree
* Argument skipHiddenControl:boolean(false);

@ pageContent
added t.tlanguage in query and check fot tLangauge in where clause

--->

<cfcomponent 
	name="Ancontent" 
	hint="Core methods for site tree and content access persisted in Application scope"
	extends="com.andreacfm.core.object">

<!---init--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="init" output="false" returntype="com.andreacfm.core.object">
		<cfreturn this />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!--- public methods --->
<cffunction name="tree" access="public" output="no" returntype="query" hint="Returns site tree">
	<cfargument name="tMode" type="string" required="no" default="0"/>
	<cfargument name="tNodeID" type="numeric" required="no" default="0"/>
	<cfargument name="tLevel" type="numeric" required="no" default="0"/>
	<cfargument name="children" type="boolean" required="no" default="false"/>
	<cfargument name="userID" type="numeric" required="no" default="#session.anuser.userID#"/>
	<cfargument name="userGroupIDs" type="string" required="no" default="#session.anuser.userGroupIDs#"/>
	<cfargument name="currentGroupID" type="string" required="no" default="#session.anuser.currentGroupID#"/>
	<!---------------------------   CUSTOM ------------------------------------->
	<cfargument name="skipHiddenControl" type="boolean" required="false" default="false" />
	<!-------------------------------------------------------------------------->
	
	<cfset var ts = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),1)))/>
	<cfset var q = ""/>
	<cfset var q1 = ""/>
	<cfset var q1lst = 0/>
	<cfset var q2 = ""/>
	<cfset var q2lst = 0/>
	<cfset var q3 = ""/>
	<cfset var q3lst = 0/>
	<cfset var q4 = ""/>
	<cfset var q4lst = 0/>
	<cfset var q5 = ""/>
	<cfset var q5lst = 0/>
	<cfset var q6 = ""/>
	<cfset var q6lst = 0/>
	<cfset var q7 = ""/>
	<cfset var q7lst = 0/>
	<cfset var q8 = ""/>
	<cfset var q8lst = 0/>
	<cfset var q9 = ""/>
	<cfset var q9lst = 0/>
	<cfset var q10 = ""/>
	<cfset var q10lst = 0/>
	<cfset var q11 = ""/>
	<cfset var q11lst = 0/>
	<!--- sync with editing changes (pos/level values) --->
	<cflock name="#application.applicationName#-TREE" type="readonly" timeout="120" throwontimeout="no">
		<!--- subqueries perform better for MS SQL Server when separated out --->
		<cfif arguments.tLevel gt 0>
			<cfquery name="q1" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select distinct p.tNodeID
				from tree p, tree s
				where p.tStatus not in (0,3,4,5) <!--- TODO: not necessary to restrict based on parent mode - and p.tMode in (#arguments.tMode#) --->
				and p.tLevel = #arguments.tLevel# - 1
				and s.tlPos >= p.tlPos
				and s.trPos <= p.trPos
				and s.tNodeID = #arguments.tNodeID#;
			</cfquery>
			<!--- ensure valid result set for use in main query --->
			<cfif q1.recordCount neq 0>
				<cfset q1lst = valueList(q1.tNodeID)/>
			</cfif>
		</cfif>

		<cfif arguments.tNodeID neq 0 and arguments.children> <!--- return all children of node --->
			<cfquery name="q2" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select distinct s.tNodeID
				from tree p, tree s
				where s.tStatus not in (0,3,4,5)
				and s.tMode in (#arguments.tMode#)
				and s.tlPos >= p.tlPos
				and s.trPos <= p.trPos
				and p.tNodeID = #arguments.tNodeID#;
			</cfquery>
			<cfif q2.recordCount neq 0>
				<cfset q2lst = valueList(q2.tNodeID)/>
			</cfif>
		<cfelseif arguments.tNodeID neq 0 and arguments.tLevel neq 0>
			<cfquery name="q2" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select distinct s.tNodeID
				from tree p, tree s
				where s.tStatus not in (0,3,4,5)
				and s.tMode in (#arguments.tMode#)
				and s.tLevel = #arguments.tLevel#
				and s.tlPos > p.tlPos
				and s.trPos < p.trPos
				and p.tNodeID in (#q1lst#);
			</cfquery>
			<cfif q2.recordCount neq 0>
				<cfset q2lst = valueList(q2.tNodeID)/>
			</cfif>
		</cfif>

		<cfquery name="q3" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct t.tNodeID
			from tree t, tree_content tc, content c, content_revisions cr, revisions rv
			where t.tStatus = 13 <!--- auto mode = must contain content --->
			and	rv.rvStatus = 1
			and	c.cContentID = tc.tcContent_ID
			and c.cContentID = cr.crContent_ID
			and	rv.rvRevisionID = cr.crRevision_ID
			and t.tNodeID = tc.tcNode_ID
			and (c.cContentID in (select distinct c.cContentID <!--- check content availability with/without group permissions --->
									from content c, groups g, content_groups cg
									where c.cContentID = cg.cgContent_ID
									and g.gGroupID = cg.cgGroup_ID
									and g.gGroupID = #session.anuser.currentGroupID#)
			   						or c.cContentID not in (select distinct c.cContentID
										from content c, groups g, content_groups cg
										where c.cContentID = cg.cgContent_ID
										and g.gGroupID = cg.cgGroup_ID)
				)
			and ((tc.tcStatus = 1 and #ts# >= tc.tcTSOn) or (tc.tcStatus = 2 and #ts# between tc.tcTSOn and tc.tcTSOff))
		</cfquery>

		<cfif q3.recordCount neq 0>
			<cfset q3lst = valueList(q3.tNodeID)/>
		</cfif>

		<cfquery name="q4" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct s.tNodeID
			from tree p, tree s
			where p.tStatus not in (1,2<cfif skiphiddenControl>,3</cfif>) <!--- exclude nodes with parent/ancestors that not on/scheduled --->
			and s.tlPos > p.tlPos
			and s.trPos < p.trPos
		</cfquery>

		<cfif q4.recordCount neq 0>
			<cfset q4lst = valueList(q4.tNodeID)/>
		</cfif>

		<cfquery name="q5" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct t.tNodeID
			from groups g, tree t, tree_groups tg
			where t.tPublic = 1
			and t.tNodeID = tg.tgNode_ID
			and	g.gGroupID = tg.tgGroup_ID
			and g.gIdentifier <> 'everyone'
			and tg.tgActions like '%1%'
		</cfquery>

		<cfif q5.recordCount neq 0>
			<cfset q5lst = valueList(q5.tNodeID)/>
		</cfif>

		<cfquery name="q6" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct t.tNodeID
			from groups g, tree t, tree_groups tg
			where t.tPublic = 1
			and t.tNodeID = tg.tgNode_ID
			and	g.gGroupID = tg.tgGroup_ID
			and g.gIdentifier <> 'everyone'
			and g.gAuthenticate = 0 <!--- anonymous group authentication --->
			and tg.tgActions like '%1%'
			and g.gRestrict = ''
		</cfquery>

		<cfif q6.recordCount neq 0>
			<cfset q6lst = valueList(q6.tNodeID)/>
		</cfif>

		<cfif not structIsEmpty(application.permissions.nodeUsers)>
			<cfquery name="q7" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select distinct t.tNodeID
				from users u, tree t, tree_users tu
				where t.tNodeID = tu.tuNode_ID
				and	u.uUserID = tu.tuUser_ID
				and tu.tuActions like '%1%'
			</cfquery>

			<cfif q7.recordCount neq 0>
				<cfset q7lst = valueList(q7.tNodeID)/>
			</cfif>
		</cfif>

		<cfquery name="q8" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct t.tNodeID
			from groups g, tree t, tree_groups tg
			where t.tPublic = 1
			and t.tNodeID = tg.tgNode_ID
			and	g.gGroupID = tg.tgGroup_ID
			and (g.gIdentifier = 'everyone' or g.gGroupID = #arguments.currentGroupID#)
			and tg.tgActions like '%1%'
		</cfquery>

		<cfif q8.recordCount neq 0>
			<cfset q8lst = valueList(q8.tNodeID)/>
		</cfif>

		<cfif session.anuser.userID neq 0 and not structIsEmpty(application.permissions.nodeUsers)>
			<cfquery name="q9" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select distinct t.tNodeID <!--- check user permissions --->
				from tree t, users u, tree_users tu
				where t.tPublic = 0
				and	u.uUserID = tu.tuUser_ID
				and	t.tNodeID = tu.tuNode_ID
				and	u.uUserID = #arguments.userID#
			</cfquery>

			<cfif q9.recordCount neq 0>
				<cfset q9lst = valueList(q9.tNodeID)/>
			</cfif>
		</cfif>

		<cfif not structIsEmpty(application.permissions.nodeGroups)>
			<cfquery name="q10" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select distinct t.tNodeID <!--- check group permissions --->
				from tree t, groups g, tree_groups tg
				where t.tPublic in (0,1)
				and	g.gStatus = 1
				and	g.gGroupID = tg.tgGroup_ID
				and	t.tNodeID = tg.tgNode_ID
				and	g.gGroupID in (#arguments.userGroupIDs#)
				and t.tNodeID not in (#q7lst#) <!--- exclude nodes with user permissions --->
			</cfquery>

			<cfif q10.recordCount neq 0>
				<cfset q10lst = valueList(q10.tNodeID)/>
			</cfif>
		</cfif>

		<cfquery name="q11" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct t.tNodeID
			from groups g, tree t, tree_groups tg
			where t.tPublic in (0,1)
			and (g.gIdentifier = 'everyone' or g.gGroupID in (#arguments.userGroupIDs#))
			and t.tNodeID = tg.tgNode_ID
			and	g.gGroupID = tg.tgGroup_ID
			and tg.tgActions like '%1%'
		</cfquery>

		<cfif q11.recordCount neq 0>
			<cfset q11lst = valueList(q11.tNodeID)/>
		</cfif>

		<!--- if requested node valid then get siblings, otherwise default root/level2 nodes --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			(select distinct tNodeID, tNode, tTitle, tTeaser, tlPos, trPos, tLevel, tMode, tStatus, tPublic, tTSUpdated, 0 as memberNode
			from tree
			where tStatus not in (0,3,4,5)
			and tMode in (#arguments.tMode#)
			and tNodeID not in (#q4lst#)
			<cfif arguments.tNodeID neq 0 and arguments.children> <!--- return all children of node --->
				and tNodeID in (#q2lst#)
			<cfelseif arguments.tNodeID neq 0 and arguments.tLevel neq 0>
				and tNodeID in (#q2lst#)
			<cfelseif arguments.tNodeID neq 0>
				and tNodeID = #arguments.tNodeID#
			<cfelseif arguments.tLevel neq 0>
				and tLevel = #arguments.tLevel#
			</cfif>
			and	(((tStatus = 1 and #ts# >= tTSOn) or (tStatus = 2 and #ts# between tTSOn and tTSOff)) or tNodeID in (#q3lst#))
			and	(tNodeID not in (#q5lst#) or tNodeID in (#q8lst#))
			<cfif not listFindNoCase(session.anuser.userRoles,'siteadmin')> <!--- no restrictions on siteadmin --->
				and ((tPublic = 1 and tNodeID not in (#q4lst#)) or tNodeID in (#q9lst#) or tNodeID in (#q10lst#))
			</cfif>
			)
			union
			(select distinct tNodeID, tNode, tTitle, tTeaser, tlPos, trPos, tLevel, tMode, tStatus, tPublic, tTSUpdated, 1 <!--- member node --->
			from tree
			where tStatus not in (0,3,4,5)
			and tMode in (#arguments.tMode#)
			and tNodeID not in (#q4lst#)
			<cfif arguments.tNodeID neq 0 and arguments.children> <!--- return all children of node --->
				and tNodeID in (#q2lst#)
			<cfelseif arguments.tNodeID neq 0 and arguments.tLevel neq 0>
				and tNodeID in (#q2lst#)
			<cfelseif arguments.tNodeID neq 0>
				and tNodeID = #arguments.tNodeID#
			<cfelseif arguments.tLevel neq 0>
				and tLevel = #arguments.tLevel#
			</cfif>
			and	(((tStatus = 1 and #ts# >= tTSOn) or (tStatus = 2 and #ts# between tTSOn and tTSOff)) or tNodeID in (#q3lst#))
			and	tNodeID in (#q6lst#)  <!---  has group read permissions, no restrictions --->
			and	tNodeID not in (#q11lst#) <!--- has group read permissions --->
			and	tNodeID not in (#q7lst#) <!--- has user read permissions --->
			)
			order by tlPos;
		</cfquery>
	</cflock>
	<cfreturn q/>
</cffunction>


<cffunction name="activeNode" access="public" output="no" returntype="boolean" hint="Returns true if node is active">
	<cfargument name="tNodeID" required="yes" type="numeric" default="0"/>
	<cfargument name="userID" type="numeric" required="no" default="#session.anuser.userID#"/>
	<cfargument name="userGroupIDs" type="string" required="no" default="#session.anuser.userGroupIDs#"/>
	<cfargument name="userRoles" type="string" required="no" default="#session.anuser.userRoles#"/>
	<cfset var q = accessNode(arguments.tNodeID,arguments.userID,arguments.userGroupIDs,arguments.userRoles)/>
	<cfset var isActive = false/>
	<cfif q neq 0>
		<cfset isActive = true/>
	</cfif>
	<cfreturn isActive/>
</cffunction>


<cffunction name="activeContent" access="public" output="no" returntype="boolean" hint="Returns true if content is active via reverse lookup">
	<cfargument name="cContentID" required="no" type="numeric" default="0"/>
	<cfargument name="userID" type="numeric" required="no" default="#session.anuser.userID#"/>
	<cfargument name="userGroupIDs" type="string" required="no" default="#session.anuser.userGroupIDs#"/>
	<cfargument name="userRoles" type="string" required="no" default="#session.anuser.userRoles#"/>
	<cfset var q = pageContent(0,arguments.cContentID,arguments.userID,arguments.userGroupIDs,arguments.userRoles)/>
	<cfset var isActive = false/>
	<cfif q.recordCount>
		<cfset isActive = true/>
	</cfif>
	<cfreturn isActive/>
</cffunction>


<cffunction name="publicNode" access="public" output="no" returntype="boolean" hint="Returns public/private status of node">
	<cfargument name="tNodeID" required="no" type="numeric" default="0"/>
	<cfset var q =""/>
	<cfset var isPublic = false/>
	<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
		select tPublic
		from tree
		where tNodeID = #accessNode(arguments.tNodeID)#
		and tNodeID = #arguments.tNodeID#;
	</cfquery>
	<cfif q.recordCount>
		<cfset isPublic = q.tPublic/>
	</cfif>
	<cfreturn isPublic/>
</cffunction>


<cffunction name="memberContent" access="public" output="no" returntype="boolean" hint="Returns member status of category or page">
	<cfargument name="tNodeID" required="yes" type="numeric" default="0"/>
	<cfargument name="cContentID" required="no" type="numeric" default="0"/>
	<cfargument name="gGroupID" required="no" type="numeric" default="0"/>
	<cfset var q = ""/>
	<cfset var isMember = false/>
	<cfif arguments.cContentID eq 0>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select g.gGroupID, g.gIdentifier, g.gRestrict
			from groups g, tree t, tree_groups tg
			where t.tPublic = 1
			and t.tNodeID = #arguments.tNodeID#
			and	g.gGroupID = #arguments.gGroupID#
			and t.tNodeID = tg.tgNode_ID
			and	g.gGroupID = tg.tgGroup_ID
			and g.gAuthenticate = 2 <!--- sign in access --->
			and tg.tgActions like '%1%'; <!--- has group read permissions --->
		</cfquery>
		<cfif q.recordCount neq 0>
			<!--- check if any group without restrictions, otherwise apply restrictions --->
			<cfloop query="q">
				<cfif listLen(q.gRestrict) eq 0>
					<cfset isMember = true/>
					<cfbreak/>
				<cfelseif listFindNoCase(session.anuser.userGroupIDs,q.gGroupID) neq 0>
					<cfset isMember = true/>
					<cfbreak/>
				</cfif>
			</cfloop>
		</cfif>
	<cfelse>
		<cfset q = nodeContent(arguments.tNodeID)/>
		<cfloop query="q">
			<cfif q.cContentID eq arguments.cContentID and q.gGroupID neq 0>
				<cfset isMember = true/>
				<cfbreak/>
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn isMember/>
</cffunction>


<cffunction name="memberRegistration" access="public" output="no" returntype="query" hint="Returns query with member registration and approval requirement">
	<cfargument name="tNodeID" required="no" type="numeric" default="0"/>
	<cfargument name="cContentID" required="no" type="numeric" default="0"/>
	<cfargument name="gGroupID" required="no" type="numeric" default="0"/>
	<cfset var ts = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),1)))/>
	<cfset var q = queryNew("gGroupID,gRegister,gApprove")/>
	<cfif arguments.tNodeID neq 0 and arguments.cContentID neq 0>
		<cfif memberContent(arguments.tNodeID,arguments.cContentID) eq true>
			<!--- get member content groups, default use first group = highest listorder --->
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select g.gGroupID, g.gRegister, g.gApprove
				from groups g, tree t, tree_groups tg
				where g.gGroupID = tg.tgGroup_ID
				and t.tNodeID = tg.tgNode_ID
				and t.tNodeID = #arguments.tNodeID#
				and g.gGroupID = #arguments.gGroupID#
				and	((g.gStatus = 1 and #ts# >= g.gTSOn) or (g.gStatus = 2 and #ts# between g.gTSOn and g.gTSOff)) <!--- check group status since not tied to login --->
				order by g.gListOrder DESC;
			</cfquery>
		</cfif>
	<cfelse>
		<!--- get member groups (no content requirement), default use first group = highest listorder --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select gGroupID, gRegister, gApprove
			from groups
			where gGroupID = #arguments.gGroupID#
			and	((gStatus = 1 and #ts# >= gTSOn) or (gStatus = 2 and #ts# between gTSOn and gTSOff))
			order by gListOrder DESC;
		</cfquery>
	</cfif>
	<cfreturn q/>
</cffunction>


<cffunction name="navigationPath" access="public" output="no" returntype="query" hint="Returns parents of node">
	<cfargument name="tNodeID" required="no" type="numeric" default="0"/>
	<cfargument name="root" required="no" type="boolean" default="false"/>
	<cfargument name="mode" required="no" type="boolean" default="true"/>
	<cfset var q = ""/>
	<cfif session.anuser.toolaccess and session.anmodule.appuuid eq "A40D51DA-C0A8-7D13-9310FA324A717E20">
		<cfset arguments.mode = false/> <!--- show path for any status when previewing from publishing tool --->
	</cfif>
	<cflock name="#application.applicationName#-TREE" type="readonly" timeout="120" throwontimeout="no">
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select p.tNodeID, p.tIdentifier, p.tNode, p.tTitle, p.tStatus, p.tMode, p.tLevel
			from tree p, tree c
			where c.tNodeID = #accessNode(arguments.tNodeID)#
			and c.tlPos >= p.tlPos
			and c.trPos <= p.trPos
			<cfif arguments.mode> <!--- allows approval to show path for any status --->
				and p.tStatus in (1,2,13) <!--- on, schedule, auto --->
			</cfif>
			<cfif arguments.root eq false>
				and p.tlPos <> 1  <!--- do not include root node --->
			</cfif>
			order by p.tlPos;
		</cfquery>
		<!--- if no parent then return root node --->
		<cfif q.recordCount eq 0 and arguments.root neq false>
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#"  cachedwithin="#createTimeSpan(0,0,1,0)#">
				select tNodeID, tIdentifier, tNode, tTitle, tStatus, tMode, tLevel
				from tree
				where tlPos = 1;
			</cfquery>
		</cfif>
	</cflock>
	<cfreturn q/>
</cffunction>


<cffunction name="metaData" access="public" output="no" returntype="query" hint="Node, content metadata">
	<cfargument name="tNodeID" type="numeric" required="no" default="0"/>
	<cfargument name="cContentID" type="numeric" required="no" default="0"/>
	<cfargument name="gGroupID" type="numeric" required="no" default="0"/>
	<cfargument name="previewID" type="numeric" required="no" default="0"/>
	<cfset var q = ""/>
	<cfset var objXml = ""/>
	<cfset var i = 0/>
	<cfset var ii = 0/>
	<cfif arguments.cContentID neq 0 and accessContent(arguments.tNodeID,arguments.cContentID,session.anuser.userID,session.anuser.userGroupIDs,session.anuser.userRoles,arguments.previewID)>
		<cflock name="#application.applicationName#-TREE" type="readonly" timeout="120" throwontimeout="no">
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select t.tNode as metaCategory, rv.rvTitle as metaTitle, rv.rvTeaser as metaTeaser, rv.rvTSRelease as metaTSRelease, rv.rvTSUpdated as metaTSUpdated, c.cAuthor as metaAuthor, c.cDescription as metaDescription, c.cKeywords as metaKeywords, tc.tcTemplate as metaTemplate, tc.tcCache as metaCache, t.tLanguage as metaLanguage, c.cRedirect as metaRedirect, t.tAssetCode as metaAssetCode, c.cOptions as metaOptions, c.cAdvanced as metaAdvanced, c.cTSReview as metaTSExpires, t.tLevel as metaLevel, t.tlPos as metaLPos, t.trPos as metaRPos, t.tDateTime as metaDateTime, t.tPublic as metaPublic, t.tFeedStatus as metaFeed, c.cSettings as metaSettings, c.cCommentStatus as metaCommentStatus, c.cCommentApprove as metaCommentApprove, 1 as metaTemplateType
				from content c, revisions rv, content_revisions cr, tree t, tree_content tc
				where t.tNodeID = #arguments.tNodeID#
				and c.cContentID = #arguments.cContentID#
				<cfif session.anuser.toolaccess and arguments.previewID neq 0 and listFindNoCase("A40D51DA-C0A8-7D13-9310FA324A717E20,B57CBB10-7323-11D3-8133005004A213F9",session.anmodule.appuuid) neq 0>
					and rv.rvRevisionID = #arguments.previewID#
				<cfelse>
				and	rv.rvStatus = 1
				</cfif>
				and	c.cContentID = tc.tcContent_ID
				and t.tNodeID = tc.tcNode_ID
				and	c.cContentID = cr.crContent_ID
				and	rv.rvRevisionID = cr.crRevision_ID;
			</cfquery>
		</cflock>
	<cfelseif arguments.tNodeID neq 0 and accessNode(arguments.tNodeID)>
		<cflock name="#application.applicationName#-TREE" type="readonly" timeout="120" throwontimeout="no">
			<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select tNode as metaCategory, tTitle as metaTitle, tTeaser as metaTeaser, tTSCreated as metaTSRelease, tTSUpdated as metaTSUpdated, '#application.config.SITE_NAME#' as metaAuthor, tDescription as metaDescription, tKeywords as metaKeywords, tTemplate as metaTemplate, tCache as metaCache, tLanguage as metaLanguage, tRedirect as metaRedirect, tAssetCode as metaAssetCode, tOptions as metaOptions, tAdvanced as metaAdvanced, '' as metaTSExpires, tLevel as metaLevel, tlPos as metaLPos, trPos as metaRPos, tDateTime as metaDateTime, tPublic as metaPublic, tFeedStatus as metaFeed, tSettings as metaSettings, 0 as metaCommentStatus, 0 as metaCommentApprove, 0 as metaTemplateType
				from tree
				where tNodeID = #arguments.tNodeID#;
			</cfquery>
		</cflock>
		<cfif len(trim(q.metaTitle[1])) eq 0> <!--- if category title empty then use category name --->
			<cfset q.metaTitle[1] = q.metaCategory[1]/>
		</cfif>
	<cfelse> <!--- TODO: could set default metadata below if required --->
		<cfset q = queryNew("metaCategory,metaTitle,metaTeaser,metaTSRelease,metaTSUpdated,metaAuthor,metaDescription,metaKeywords,metaTemplate,metaCache,metaLanguage,metaRedirect,metaAssetCode,metaOptions,metaAdvanced,metaTSExpires,metaLevel,metaLPos,metaRPos,metaDateTime,metaPublic,metaFeed,metaSettings,metaCommentStatus,metaCommentApprove,metaTemplateType")/>
		<cfset queryAddRow(q,1)/>
		<cfset querySetCell(q,"metaCategory","",1)/>
		<cfset querySetCell(q,"metaTitle","",1)/>
		<cfset querySetCell(q,"metaTeaser","",1)/>
		<cfset querySetCell(q,"metaTSRelease",dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),0)),1)/>
		<cfset querySetCell(q,"metaTSUpdated",dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),0)),1)/>
		<cfset querySetCell(q,"metaAuthor","",1)/>
		<cfset querySetCell(q,"metaDescription","",1)/>
		<cfset querySetCell(q,"metaKeywords","",1)/>
		<cfset querySetCell(q,"metaTemplate","",1)/>
		<cfset querySetCell(q,"metaCache",0,1)/>
		<cfset querySetCell(q,"metaLanguage",listFirst(application.config.SUPPORTED_LOCALES),1)/>
		<cfset querySetCell(q,"metaRedirect","",1)/>
		<cfset querySetCell(q,"metaAssetCode","",1)/>
		<cfset querySetCell(q,"metaOptions","",1)/>
		<cfset querySetCell(q,"metaAdvanced","",1)/>
		<cfset querySetCell(q,"metaTSExpires",0,1)/>
		<cfset querySetCell(q,"metaLevel",0,1)/>
		<cfset querySetCell(q,"metaLPos",0,1)/>
		<cfset querySetCell(q,"metaRPos",0,1)/>
		<cfset querySetCell(q,"metaDateTime",0,1)/>
		<cfset querySetCell(q,"metaPublic",1,1)/>
		<cfset querySetCell(q,"metaFeed",1,1)/>
		<cfset querySetCell(q,"metaSettings",0,1)/>
		<cfset querySetCell(q,"metaCommentStatus",0,1)/>
		<cfset querySetCell(q,"metaCommentApprove",0,1)/>
		<cfset querySetCell(q,"metaTemplateType",0,1)/>	<!--- 0 = category, 1 = content --->
	</cfif>
	<cfif not listFindNoCase(application.config.SUPPORTED_LOCALES,q.metaLanguage[1])>
		<cfset q.metaLanguage[1] = listFirst(application.config.SUPPORTED_LOCALES)/>
	</cfif>
	<cfif findNoCase("/anlink/",q.metaRedirect) eq 1> <!--- if local redirect then add site root path --->
		<cfset q.metaRedirect[1] = replaceNoCase(q.metaRedirect[1],",-1,html",",#session.anuser.currentGroupID#,html","one")/>
		<cfset q.metaRedirect[1] = replaceNoCase(q.metaRedirect[1],"/anlink/","#application.virtualPaths.ANROOT#/index.cfm/","one")/> <!--- process shortform links in redirect --->
	</cfif>
	<!--- if advanced metadata available then rewrite metadata --->
	<cfif len(q.metaAdvanced[1]) neq 0>
		<cftry>
			<cfxml variable="objXml"><cfoutput>#q.metaAdvanced[1]#</cfoutput></cfxml> <!--- create xml object --->
			<cfif isXml(q.metaAdvanced[1]) eq true>
				<!--- find matching group id --->
				<cfloop index="i" from="1" to="#arrayLen(objXml.groups.XmlChildren)#">
					<cfif objXml.groups.group[i].XmlAttributes.id eq arguments.gGroupID>
						<cfloop index="ii" from="1" to="#arrayLen(objXml.groups.group[i].XmlChildren)#">
							<cfif listFindNoCase(q.columnList,"meta#objXml.groups.group[i].XmlChildren[ii].XmlName#") neq 0>
								<cfset querySetCell(q,"meta#objXml.groups.group[i].XmlChildren[ii].XmlName#",objXml.groups.group[i].XmlChildren[ii].XmlText,1)/> <!--- must be already defined query meta column --->
							</cfif>
						</cfloop>
						<cfbreak/>
					</cfif>
				</cfloop>
			</cfif>
			<cfcatch/> <!--- handle errors silently --->
		</cftry>
	</cfif>
	<cfreturn q/>
</cffunction>


<cffunction name="nodeContent" access="public" output="no" returntype="query" hint="Return content in specified node. Checks public, user, group access permissions">
	<cfargument name="tNodeID" type="numeric" required="no" default="0"/>
	<cfargument name="tcMode" type="string" required="no" default="all"/> <!--- normally filter in output loop --->
	<cfargument name="tFeedStatus" type="string" required="no" default="all"/> <!--- feed status does not affect normal output --->
	<cfargument name="portal" type="boolean" required="no" default="false"/> <!--- categories that are portal pages = virtuals link to master --->
	<cfargument name="userID" type="numeric" required="no" default="#session.anuser.userID#"/>
	<cfargument name="userGroupIDs" type="string" required="no" default="#session.anuser.userGroupIDs#"/>
	<cfset var ts = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),1)))/>
	<cfset var q = ""/>
	<cfset var q1 = ""/>
	<cfset var q1lst = 0/>
	<cfset var q2 = ""/>
	<cfset var q2lst = 0/>
	<cfset var q3 = ""/>
	<cfset var q3lst = 0/>
	<cfset var q4 = ""/>
	<cfset var q4lst = 0/>
	<cfset var q5 = ""/>
	<cfset var q5lst = 0/>
	<cfset var q6 = ""/>
	<cfset var q6lst = 0/>

	<cfif not structIsEmpty(application.permissions.nodeGroups)>
		<cfquery name="q1" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct c.cContentID
			from groups g, content c, tree t, tree_content tc, content_groups cg
			where t.tNodeID = #arguments.tNodeID#
			and	t.tNodeID = tc.tcNode_ID
			and	c.cContentID = tc.tcContent_ID
			and	c.cContentID = cg.cgContent_ID
			and	g.gGroupID = cg.cgGroup_ID
		</cfquery>

		<cfif q1.recordCount neq 0>
			<cfset q1lst = valueList(q1.cContentID)/>
		</cfif>
	</cfif>

	<cfif not structIsEmpty(application.permissions.nodeUsers)>
		<cfquery name="q2" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct c.cContentID
			from users u, content c, tree t, tree_content tc, content_users cu
			where t.tNodeID = #arguments.tNodeID#
			and	t.tNodeID = tc.tcNode_ID
			and	c.cContentID = tc.tcContent_ID
			and	c.cContentID = cu.cuContent_ID
			and	u.uUserID = cu.cuUser_ID
		</cfquery>

		<cfif q2.recordCount neq 0>
			<cfset q2lst = valueList(q2.cContentID)/>
		</cfif>
	</cfif>

	<cfif not structIsEmpty(application.permissions.contentGroups)>
		<cfquery name="q3" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct c.cContentID
			from groups g, content c, tree t, tree_content tc, content_groups cg
			where t.tNodeID = #arguments.tNodeID#
			and g.gAuthenticate = 2 <!--- 2 = login required, 1 = link works as filter --->
			and	t.tNodeID = tc.tcNode_ID
			and	c.cContentID = tc.tcContent_ID
			and	c.cContentID = cg.cgContent_ID
			and	g.gGroupID = cg.cgGroup_ID
			and cg.cgActions like '%1%'
		</cfquery>

		<cfif q3.recordCount neq 0>
			<cfset q3lst = valueList(q3.cContentID)/>
		</cfif>

		<cfquery name="q5" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct c.cContentID
			from groups g, content c, tree t, tree_content tc, content_groups cg
			where t.tNodeID = #arguments.tNodeID#
			and	t.tNodeID = tc.tcNode_ID
			and	c.cContentID = tc.tcContent_ID
			and	c.cContentID = cg.cgContent_ID
			and	g.gGroupID = cg.cgGroup_ID
			and	g.gGroupID in (#arguments.userGroupIDs#)
		</cfquery>

		<cfif q5.recordCount neq 0>
			<cfset q5lst = valueList(q5.cContentID)/>
		</cfif>
	</cfif>

	<cfif not structIsEmpty(application.permissions.contentUsers)>
		<cfquery name="q4" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct c.cContentID
			from users u, content c, tree t, tree_content tc, content_users cu
			where t.tNodeID = #arguments.tNodeID#
			and	t.tNodeID = tc.tcNode_ID
			and	c.cContentID = tc.tcContent_ID
			and	c.cContentID = cu.cuContent_ID
			and	u.uUserID = cu.cuUser_ID
			and cu.cuActions like '%1%'
		</cfquery>

		<cfif q4.recordCount neq 0>
			<cfset q4lst = valueList(q4.cContentID)/>
		</cfif>
	</cfif>


	<cfif session.anuser.userID neq 0 and not structIsEmpty(application.permissions.contentUsers)>
		<cfquery name="q6" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct c.cContentID
			from users u, content c, tree t, tree_content tc, content_users cu
			where t.tNodeID = #arguments.tNodeID#
			and	t.tNodeID = tc.tcNode_ID
			and	c.cContentID = tc.tcContent_ID
			and	c.cContentID = cu.cuContent_ID
			and	u.uUserID = cu.cuUser_ID
			and	u.uUserID = #arguments.userID#
		</cfquery>

		<cfif q6.recordCount neq 0>
			<cfset q6lst = valueList(q6.cContentID)/>
		</cfif>
	</cfif>

	<!--- if user has access permissions for node then get content, no need to reference content table as only valid content ids in tree_content --->
	<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
	<cfif arguments.portal> <!--- portal = virtuals link to master --->
		(select t.tNodeID, t.tNode, t.tPublic, c.cContentID, c.cRedirect, c.cAuthor, c.cOptions, rv.rvRevisionID, rv.rvTitle, rv.rvTeaser, rv.rvBodySize, rv.rvImage, rv.rvFile, rv.rvFileSize, rv.rvTSUpdated, rv.rvTSRelease, tc.tcStatus, tc2.tcMode, tc.tcTSOn, tc.tcTSOff, tc2.tcListOrder, 0 as gGroupID, '' as gGroup, 0 as gListOrder, 0 as gAuthenticate
		from tree t, tree_content tc, content c, content_revisions cr, revisions rv, tree_content tc2
		where tc2.tcNode_ID = #accessNode(arguments.tNodeID)#
		and	tc2.tcContent_ID = c.cContentID
		and tc.tcMaster = 1
		and ((tc2.tcStatus in (1,3) and #ts# >= tc2.tcTSOn) or (tc2.tcStatus = 2 and #ts# between tc2.tcTSOn and tc2.tcTSOff))
		<cfif arguments.tcMode neq "all">
			and tc2.tcMode in (#arguments.tcMode#)
		</cfif>
		and ((t.tStatus in (1,3,13) and #ts# >= t.tTSOn) or (t.tStatus = 2 and #ts# between t.tTSOn and t.tTSOff))
	<cfelse>
		(select t.tNodeID, t.tNode, t.tPublic, c.cContentID, c.cRedirect, c.cAuthor, c.cOptions, rv.rvRevisionID, rv.rvTitle, rv.rvTeaser, rv.rvBodySize, rv.rvImage, rv.rvFile, rv.rvFileSize, rv.rvTSUpdated, rv.rvTSRelease, tc.tcStatus, tc.tcMode, tc.tcTSOn, tc.tcTSOff, tc.tcListOrder, 0 as gGroupID, '' as gGroup, 0 as gListOrder, 0 as gAuthenticate
		from tree t, tree_content tc, content c, content_revisions cr, revisions rv
		where t.tNodeID = #accessNode(arguments.tNodeID)#
		<cfif arguments.tcMode neq "all">
			and tc.tcMode in (#arguments.tcMode#)
		</cfif>
	</cfif>
		<cfif arguments.tFeedStatus neq "all"> <!--- all = return despite feed status --->
			and t.tFeedStatus in (#arguments.tFeedStatus#)
		</cfif>
		and	rv.rvStatus = 1
		and	c.cContentID = tc.tcContent_ID
		and c.cContentID = cr.crContent_ID
		and	rv.rvRevisionID = cr.crRevision_ID
		and t.tNodeID = tc.tcNode_ID
		and ((tc.tcStatus = 1 and #ts# >= tc.tcTSOn) or (tc.tcStatus = 2 and #ts# between tc.tcTSOn and tc.tcTSOff))
		and ((t.tStatus in (1,3,13) and #ts# >= t.tTSOn) or (t.tStatus = 2 and #ts# between t.tTSOn and t.tTSOff))
		<!--- enforce group / user permissions --->
		<cfif not listFindNoCase(session.anuser.userRoles,'siteadmin')> <!--- no restrictions on siteadmin --->
		and ((c.cContentID not in (#q1lst#) or c.cContentID in (#q5lst#)) and (c.cContentID not in (#q2lst#) or c.cContentID in (#q6lst#)))
		</cfif>
		)
		union
		<!--- member content = content in a public category with group read permissions but no user permissions, virtual content cannot have permissions --->
		(select t.tNodeID, t.tNode, t.tPublic, c.cContentID, c.cRedirect, c.cAuthor, c.cOptions, rv.rvRevisionID, rv.rvTitle, rv.rvTeaser, rv.rvBodySize, rv.rvImage, rv.rvFile, rv.rvFileSize, rv.rvTSUpdated, rv.rvTSRelease, tc.tcStatus, tc.tcMode, tc.tcTSOn, tc.tcTSOff, tc.tcListOrder, g.gGroupID, g.gGroup, g.gListOrder, g.gAuthenticate
		from tree t, tree_content tc, content c, content_revisions cr, revisions rv, content_groups cg, groups g
		where t.tNodeID = #accessNode(arguments.tNodeID)#
		and t.tPublic = 1
		<cfif arguments.tcMode neq "all"> <!--- all = get all node content in single query --->
			and tc.tcMode in (#arguments.tcMode#)
		</cfif>
		<cfif arguments.tFeedStatus neq "all">
			and t.tFeedStatus in (#arguments.tFeedStatus#)
		</cfif>
		and	rv.rvStatus = 1
		and g.gAuthenticate not in (0,1) <!--- sign in authorization --->
		and g.gRestrict = ''
		and c.cContentID = cg.cgContent_ID
		and g.gGroupID = cg.cgGroup_ID
		and	c.cContentID = tc.tcContent_ID
		and c.cContentID = cr.crContent_ID
		and	rv.rvRevisionID = cr.crRevision_ID
		and t.tNodeID = tc.tcNode_ID
		and ((tc.tcStatus = 1 and #ts# >= tc.tcTSOn) or (tc.tcStatus = 2 and #ts# between tc.tcTSOn and tc.tcTSOff))
		and ((t.tStatus in (1,3,13) and #ts# >= t.tTSOn) or (t.tStatus = 2 and #ts# between t.tTSOn and t.tTSOff))
		and	(c.cContentID in (#q3lst#)) <!--- has group read permissions --->
		and	(c.cContentID not in (#q4lst#)) <!--- has user read permissions --->
		)
		order by tcListOrder DESC, gAuthenticate ASC, gListOrder DESC;
	</cfquery>
	<cfreturn q/>
</cffunction>


<cffunction name="pageContent" access="public" output="no" returntype="query" hint="Return html content record and check permissions">
	<cfargument name="tNodeID" type="numeric" required="no" default="0"/> <!--- zero used for reverse lookup --->
	<cfargument name="cContentID" type="numeric" required="no" default="0"/>
	<cfargument name="userID" type="numeric" required="no" default="#session.anuser.userID#"/>
	<cfargument name="userGroupIDs" type="string" required="no" default="#session.anuser.userGroupIDs#"/>
	<cfargument name="userRoles" type="string" required="no" default="#session.anuser.userRoles#"/>
	<cfargument name="previewID" type="numeric" required="no" default="0"/>
	<cfset var q = ""/>
	<cfset var q1 = ""/>
	<cfset var q1lst = 0/>
	<cfset var q2 = ""/>
	<cfset var q2lst = 0/>
	<cfset var q3 = ""/>
	<cfset var q3lst = 0/>
	<cfset var q4 = ""/>
	<cfset var q4lst = 0/>
	<cfset var i = 0/>
	<cfset var activeContent = 0/>
	<cfset var redirectUrl = ""/>

	<cfif not structIsEmpty(application.permissions.contentGroups)>
		<cfquery name="q1" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct c.cContentID
			from groups g, content c, tree t, tree_content tc, content_groups cg
			where t.tNodeID = tc.tcNode_ID
			<cfif arguments.tNodeID neq 0>
				and	t.tNodeID = #arguments.tNodeID#
			</cfif>
			and	c.cContentID = tc.tcContent_ID
			and	c.cContentID = cg.cgContent_ID
			and	g.gGroupID = cg.cgGroup_ID
		</cfquery>

		<cfif q1.recordCount neq 0>
			<cfset q1lst = valueList(q1.cContentID)/>
		</cfif>

		<cfquery name="q3" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct c.cContentID
			from groups g, content c, tree t, tree_content tc, content_groups cg
			where t.tNodeID = tc.tcNode_ID
			<cfif arguments.tNodeID neq 0>
				and	t.tNodeID = #arguments.tNodeID#
			</cfif>
			and	c.cContentID = tc.tcContent_ID
			and	c.cContentID = cg.cgContent_ID
			and	g.gGroupID = cg.cgGroup_ID
			and	g.gGroupID in (#arguments.userGroupIDs#)
		</cfquery>

		<cfif q3.recordCount neq 0>
			<cfset q3lst = valueList(q3.cContentID)/>
		</cfif>
	</cfif>

	<cfif not structIsEmpty(application.permissions.contentUsers)>
		<cfquery name="q2" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct c.cContentID
			from users u, content c, tree t, tree_content tc, content_users cu
			where t.tNodeID = tc.tcNode_ID
			<cfif arguments.tNodeID neq 0>
				and	t.tNodeID = #arguments.tNodeID#
			</cfif>
			and	c.cContentID = tc.tcContent_ID
			and	c.cContentID = cu.cuContent_ID
			and	u.uUserID = cu.cuUser_ID
		</cfquery>

		<cfif q2.recordCount neq 0>
			<cfset q2lst = valueList(q2.cContentID)/>
		</cfif>
	</cfif>


	<cfif session.anuser.userID neq 0 and not structIsEmpty(application.permissions.contentUsers)>
		<cfquery name="q4" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct c.cContentID
			from users u, content c, tree t, tree_content tc, content_users cu
			where t.tNodeID = tc.tcNode_ID
			<cfif arguments.tNodeID neq 0>
				and	t.tNodeID = #arguments.tNodeID#
			</cfif>
			and	c.cContentID = tc.tcContent_ID
			and	c.cContentID = cu.cuContent_ID
			and	u.uUserID = cu.cuUser_ID
			and	u.uUserID = #arguments.userID#
		</cfquery>

		<cfif q4.recordCount neq 0>
			<cfset q4lst = valueList(q4.cContentID)/>
		</cfif>
	</cfif>

	<!--- access permissions for node applied in url parsing, only need to check for specific content permissions --->
	<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
		select t.tNodeID, t.tLanguage, c.cContentID, c.cRedirect, c.cAuthor, c.cOptions, c.cSettings, c.cCommentStatus, c.cCommentApprove, rv.rvRevisionID, rv.rvIdentifier, rv.rvTitle, rv.rvTeaser, rv.rvBody, rv.rvBodySize, rv.rvImage, rv.rvFile, rv.rvFileSize, rv.rvTSUpdated, rv.rvTSRelease, tc.tcStatus, tc.tcMode
		from content c, revisions rv, content_revisions cr, tree t, tree_content tc
		where c.cContentID = #arguments.cContentID#
		<cfif arguments.tNodeID neq 0>
			<!--- TODO:	and t.tNodeID = #accessNode(arguments.tNodeID,arguments.userID,arguments.userGroupIDs,arguments.userRoles)# --->
			and t.tNodeID = #arguments.tNodeID#
		</cfif>
		<cfif session.anuser.toolaccess and arguments.previewID neq 0 and listFindNoCase("A40D51DA-C0A8-7D13-9310FA324A717E20,B57CBB10-7323-11D3-8133005004A213F9",session.anmodule.appuuid) neq 0>
			and rv.rvRevisionID = #arguments.previewID#
		<cfelse>
			and	rv.rvStatus = 1
			and tc.tcStatus in (1,2,3,4)
		</cfif>
		and	c.cContentID = tc.tcContent_ID
		and t.tNodeID = tc.tcNode_ID
		and	c.cContentID = cr.crContent_ID
		and	rv.rvRevisionID = cr.crRevision_ID
		
		
		<!-------------------------------------------- custom ---------------------------------------------->
		<cfif structKeyExists(arguments,"language") and arguments.language neq "">
		and t.tLanguage = '#arguments.language#'
		</cfif>
		<!--------------------------------------------------------------------------------------------------->
		
		
		<cfif not listFindNoCase(arguments.userRoles,"siteadmin")> <!--- no restrictions on siteadmin --->
		and ((c.cContentID not in (#q1lst#) or c.cContentID in (#q3lst#)) and (c.cContentID not in (#q2lst#) or c.cContentID in (#q4lst#)))
		</cfif>;
	</cfquery>
	<!--- find first active node containing content item --->
	<cfloop index="i" from="1" to="#q.recordCount#">
		<cfif activeNode(q.tNodeID[i])>
			<cfset activeContent = i/>
			<cfbreak/>
		</cfif>
	</cfloop>
	<!--- not active then return empty query --->
	<cfif activeContent eq 0>
		<cfset q = queryNew("tNodeID,cContentID,cRedirect,cSettings,cCommentStatus,cCommentApprove,rvRevisionID,rvIdentifier,rvTitle,rvTeaser,rvBody,rvBodySize,rvImage,rvFile,rvFileSize,rvTSUpdated,rvTSRelease,tcStatus,tcMode")/> <!--- clear result set --->
	<cfelse>
		<cfif findNoCase("/anlink/",q.cRedirect) eq 1> <!--- if local redirect then add site root path --->
			<cfset redirectUrl = replaceNoCase(q.cRedirect,",-1,html",",#session.anuser.currentGroupID#,html","one")/>
			<cfset redirectUrl = replaceNoCase(redirectUrl,"/anlink/","#application.virtualPaths.ANROOT#/index.cfm/","one")/> <!--- process shortform links in redirect --->
			<cfset querySetCell(q,"cRedirect",redirectUrl)/>
		</cfif>
		<cfset querySetCell(q,"rvBody",parseHTML(q.rvBody[activeContent],q.tNodeID[activeContent],q.cContentID[activeContent],q.rvRevisionID[activeContent]))/> <!--- parse html to set image,link,file paths --->
	</cfif>
	<cfreturn q/>
</cffunction>


<cffunction name="periodContent" access="public" output="no" returntype="query" hint="Return new/updated content in period - typically used for feeds">
	<cfargument name="tNodeID" type="numeric" required="no" default="0"/> <!--- 0 = all --->
	<cfargument name="children" type="boolean" required="no" default="false"/> <!--- true = get all node children as well --->
	<cfargument name="maxrows" required="no" type="numeric" default="20"/> <!--- set number of results returned --->
	<cfargument name="userID" type="numeric" required="no" default="#session.anuser.userID#"/>
	<cfargument name="userGroupIDs" type="string" required="no" default="#session.anuser.authGroupIDs#"/>
	<cfargument name="userRoles" type="string" required="no" default="#session.anuser.userRoles#"/>
	<cfargument name="currentGroupID" type="string" required="no" default="0"/>
	<cfargument name="delay" required="no" type="numeric" default="-1"/> <!--- allows delay window for feeds -1 = set to system delay --->
	<cfargument name="days" type="numeric" required="no" default="0"/>
	<cfargument name="start" type="date" required="no" default="#createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),0)#"/>
	<cfargument name="end" type="date" required="no" default="#arguments.start#"/>
	<cfset var q = ""/>
	<cfset var delayTS = createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),0)/>
	<cfset var q2 = queryNew("tNodeID,tNode,tTitle,tLevel,tlPos,cContentID,cRedirect,rvRevisionID,rvTitle,rvTeaser,rvBodySize,rvImage,rvFile,rvFileSize,rvTSUpdated,rvTSRelease,gGroupID")/>
	<cfset var i = 0/>
	<cfset var outputPageIDs = 0/>
	<cfif arguments.delay lt 0>
		<cfset arguments.delay = application.config.FEED_DELAY_MINUTES/>
	</cfif>
	<cfif arguments.days neq 0>
		<cfset arguments.start = dateAdd("d",-arguments.days,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),0))/>
		<cfset arguments.end = createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),0)/>
	</cfif>
	<cfset arguments.start = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,arguments.start))/>
	<cfset arguments.end = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,arguments.end))/>
	<cfif arguments.delay neq 0>
		<cfset delayTS = createODBCDateTime(dateAdd("n",-arguments.delay,dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),1))))/>
	</cfif>
	<cflock name="#application.applicationName#-TREE" type="readonly" timeout="120" throwontimeout="no">
		<!--- access permissions for node applied in url parsing, only need to check for specific content permissions --->
		<cfquery name="q" maxrows="#arguments.maxrows#" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select t.tNodeID, t.tNode, t.tTitle, t.tLevel, t.tlPos, c.cContentID, c.cRedirect, rv.rvRevisionID, rv.rvTitle, rv.rvTeaser, rv.rvBodySize, rv.rvImage, rv.rvFile, rv.rvFileSize, rv.rvTSUpdated, rv.rvTSRelease
			from content c, revisions rv, content_revisions cr, tree t, tree_content tc, tree p
			where t.tFeedStatus = 1
			and tc.tcMode = 0
			and p.tNodeID = #arguments.tNodeID#
			<cfif arguments.children>
				and p.tlPos <= t.tlPos and p.trPos >= t.trPos
			<cfelse>
				and t.tlPos = p.tlPos and t.trPos = p.trPos
			</cfif>
			<cfif arguments.tNodeID neq 0 and arguments.children eq false>
				and t.tNodeID = #arguments.tNodeID#
			<cfelse>
				and tc.tcMaster = 1 <!--- do not feed all virtual instances --->
			</cfif>
			<cfif arguments.start neq arguments.end>
				and rv.rvTSUpdated between #arguments.start# and #arguments.end#
			</cfif>
			<cfif arguments.delay neq 0>
				and rv.rvTSUpdated <= #delayTS#
			</cfif>
			and	rv.rvStatus = 1
			and tc.tcStatus in (1,2) <!--- on, scheduled --->
			and t.tStatus in (1,2,13) <!--- on, scheduled, auto --->
			and	c.cContentID = tc.tcContent_ID
			and t.tNodeID = tc.tcNode_ID
			and	c.cContentID = cr.crContent_ID
			and	rv.rvRevisionID = cr.crRevision_ID
			<cfif not listFindNoCase(arguments.userRoles,"siteadmin")> <!--- no restrictions on siteadmin --->
			and (
				((c.cContentID not in (select c.cContentID
										from users u, content c, tree t, tree_content tc, content_users cu
										where t.tNodeID = tc.tcNode_ID
										and	c.cContentID = tc.tcContent_ID
										and	c.cContentID = cu.cuContent_ID
										and	u.uUserID = cu.cuUser_ID)
				)
				or
				(c.cContentID in (select c.cContentID
										from users u, content c, tree t, tree_content tc, content_users cu
										where t.tNodeID = tc.tcNode_ID
										and	c.cContentID = tc.tcContent_ID
										and	c.cContentID = cu.cuContent_ID
										and	u.uUserID = cu.cuUser_ID
										and	u.uUserID = #arguments.userID#)
				))
				and
				((c.cContentID not in (select c.cContentID
										from groups g, content c, tree t, tree_content tc, content_groups cg
										where t.tNodeID = tc.tcNode_ID
										and	c.cContentID = tc.tcContent_ID
										and	c.cContentID = cg.cgContent_ID
										and	g.gGroupID = cg.cgGroup_ID)
				)
				or
				(c.cContentID in (select c.cContentID
										from groups g, content c, tree t, tree_content tc, content_groups cg
										where t.tNodeID = tc.tcNode_ID
										and	c.cContentID = tc.tcContent_ID
										and	c.cContentID = cg.cgContent_ID
										and	g.gGroupID = cg.cgGroup_ID
										<cfif arguments.currentGroupID neq 0>
											and g.gGroupID = #arguments.currentGroupID#
										</cfif>
										and	g.gGroupID in (#arguments.userGroupIDs#))
				))
				)
			</cfif>
			order by rvTSUpdated DESC, cContentID DESC;
		</cfquery>
	</cflock>
	<!--- build result set without duplicates due to group permissions --->
	<cfloop index="i" from="1" to="#q.recordCount#">
		<cfif listFindNoCase(outputPageIDs,q.cContentID[i]) eq 0 and i lte arguments.maxRows and (accessContent(q.tNodeID[i],q.cContentID[i],arguments.userID,arguments.userGroupIDs,arguments.userRoles) or listFindNoCase(arguments.userRoles,"siteadmin"))>
			<cfset outputPageIDs = listAppend(outputPageIDs,q.cContentID[i])/>
			<cfset queryAddRow(q2,1)/>
			<cfset querySetCell(q2,"tNodeID",q.tNodeID[i])/>
			<cfset querySetCell(q2,"tNode",q.tNode[i])/>
			<cfset querySetCell(q2,"tTitle",q.tTitle[i])/>
			<cfset querySetCell(q2,"tLevel",q.tLevel[i])/>
			<cfset querySetCell(q2,"tlPos",q.tlPos[i])/>
			<cfset querySetCell(q2,"cContentID",q.cContentID[i])/>
			<cfset querySetCell(q2,"cRedirect",q.cRedirect[i])/>
			<cfset querySetCell(q2,"rvRevisionID",q.rvRevisionID[i])/>
			<cfset querySetCell(q2,"rvTitle",q.rvTitle[i])/>
			<cfset querySetCell(q2,"rvTeaser",q.rvTeaser[i])/>
			<cfset querySetCell(q2,"rvBodySize",q.rvBodySize[i])/>
			<cfset querySetCell(q2,"rvImage",q.rvImage[i])/>
			<cfset querySetCell(q2,"rvFile",q.rvFile[i])/>
			<cfset querySetCell(q2,"rvFileSize",q.rvFileSize[i])/>
			<cfset querySetCell(q2,"rvTSUpdated",q.rvTSUpdated[i])/>
			<cfset querySetCell(q2,"rvTSRelease",q.rvTSRelease[i])/>
			<cfset querySetCell(q2,"gGroupID",arguments.currentGroupID)/>
			<!--- TBD: not required to pass marker group id
			<cfif arguments.currentGroupID eq 0>
				<cfset querySetCell(q2,"gGroupID",-1)/>
			<cfelse>
				<cfset querySetCell(q2,"gGroupID",arguments.currentGroupID)/>
			</cfif>
			--->
		</cfif>
	</cfloop>
	<cfreturn q2/>
</cffunction>


<cffunction name="periodComments" access="public" output="no" returntype="query" hint="Return new/updated comments in period - typically used for feeds">
	<cfargument name="tNodeID" type="numeric" required="no" default="0"/> <!--- 0 = all --->
	<cfargument name="cContentID" type="numeric" required="no" default="0"/> <!--- 0 = all --->
	<cfargument name="children" type="boolean" required="no" default="true"/> <!--- true = get all node children as well --->
	<cfargument name="maxrows" required="no" type="numeric" default="50"/> <!--- set number of results returned --->
	<cfargument name="userID" type="numeric" required="no" default="#session.anuser.userID#"/>
	<cfargument name="userGroupIDs" type="string" required="no" default="#session.anuser.authGroupIDs#"/>
	<cfargument name="userRoles" type="string" required="no" default="#session.anuser.userRoles#"/>
	<cfargument name="days" type="numeric" required="no" default="0"/>
	<cfargument name="start" type="date" required="no" default="#createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),0)#"/>
	<cfargument name="end" type="date" required="no" default="#arguments.start#"/>
	<cfargument name="delay" required="no" type="numeric" default="#application.config.FEED_DELAY_MINUTES#"/> <!--- allows delay window for feeds --->
	<cfset var q = ""/>
	<cfset var delayTS = createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),0)/>
	<cfset var q2 = queryNew("tNodeID,tNode,cContentID,rvTitle,gGroupID,coCommentID,coName,coComment,coTSCreated,coComment_ID")/>
	<cfset var i = 0/>
	<cfset var currCommentID = 0/>
	<cfif arguments.days neq 0>
		<cfset arguments.start = dateAdd("d",-arguments.days,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),0))/>
		<cfset arguments.end = createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),0)/>
	</cfif>
	<cfset arguments.start = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,arguments.start))/>
	<cfset arguments.end = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,arguments.end))/>
	<cfif arguments.delay neq 0>
		<cfset delayTS = createODBCDateTime(dateAdd("n",-arguments.delay,dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),1))))/>
	</cfif>
	<cflock name="#application.applicationName#-TREE" type="readonly" timeout="120" throwontimeout="no">
		<!--- access permissions for node applied in url parsing, only need to check for specific content permissions --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#">
			select t.tNodeID, t.tNode, c.cContentID, rvTitle, co.coName, co.coCommentID, co.coComment, co.coTSCreated, co.coComment_ID
			from content c, revisions rv, content_revisions cr, tree t, tree_content tc, tree p, comments co
			where c.cCommentStatus <> 0
			and co.coStatus = 1
			and c.cContentID = co.coContent_ID
			and t.tFeedStatus = 1
			and p.tNodeID = #arguments.tNodeID#
			<cfif arguments.children>
				and p.tlPos <= t.tlPos and p.trPos >= t.trPos
			<cfelse>
				and t.tlPos = p.tlPos and t.trPos = p.trPos
			</cfif>
			<cfif arguments.tNodeID neq 0 and arguments.children eq false>
				and t.tNodeID = #arguments.tNodeID#
			<cfelse>
				and tc.tcMaster = 1 <!--- do not feed all virtual instances --->
			</cfif>
			<cfif arguments.cContentID neq 0>
				and c.cContentID = #arguments.cContentID#
			<cfelse>
				and tc.tcMode = 0 <!--- only feed normal mode pages --->
			</cfif>
			<cfif arguments.start neq arguments.end>
				and rv.rvTSUpdated between #arguments.start# and #arguments.end#
			</cfif>
			<cfif arguments.delay neq 0>
				and co.coTSCreated <= #delayTS#
			</cfif>
			and	rv.rvStatus = 1
			and tc.tcStatus in (1,2) <!--- on, scheduled --->
			and	c.cContentID = tc.tcContent_ID
			and t.tNodeID = tc.tcNode_ID
			and	c.cContentID = cr.crContent_ID
			and	rv.rvRevisionID = cr.crRevision_ID
			<cfif not listFindNoCase(arguments.userRoles,"siteadmin")> <!--- no restrictions on siteadmin --->
			and (
				((c.cContentID not in (select c.cContentID
										from users u, content c, tree t, tree_content tc, content_users cu
										where t.tNodeID = tc.tcNode_ID
										and	c.cContentID = tc.tcContent_ID
										and	c.cContentID = cu.cuContent_ID
										and	u.uUserID = cu.cuUser_ID)
				)
				or
				(c.cContentID in (select c.cContentID
										from users u, content c, tree t, tree_content tc, content_users cu
										where t.tNodeID = tc.tcNode_ID
										and	c.cContentID = tc.tcContent_ID
										and	c.cContentID = cu.cuContent_ID
										and	u.uUserID = cu.cuUser_ID
										and	u.uUserID = #arguments.userID#)
				))
				and
				((c.cContentID not in (select c.cContentID
										from groups g, content c, tree t, tree_content tc, content_groups cg
										where t.tNodeID = tc.tcNode_ID
										and	c.cContentID = tc.tcContent_ID
										and	c.cContentID = cg.cgContent_ID
										and	g.gGroupID = cg.cgGroup_ID)
				)
				or
				(c.cContentID in (select c.cContentID
										from groups g, content c, tree t, tree_content tc, content_groups cg
										where t.tNodeID = tc.tcNode_ID
										and	c.cContentID = tc.tcContent_ID
										and	c.cContentID = cg.cgContent_ID
										and	g.gGroupID = cg.cgGroup_ID
										and	g.gGroupID in (#arguments.userGroupIDs#))
				))
				)
			</cfif>
			order by coTSCreated DESC, coCommentID DESC;
		</cfquery>
	</cflock>
	<!--- build result set without duplicates due to group permissions --->
	<cfloop index="i" from="1" to="#q.recordCount#">
		<cfif currCommentID neq q.coCommentID[i] and accessContent(q.tNodeID[i],q.cContentID[i],arguments.userID,arguments.userGroupIDs,arguments.userRoles) and i lte arguments.maxRows>
			<cfset currCommentID = q.coCommentID[i]/>
			<cfset queryAddRow(q2,1)/>
			<cfset querySetCell(q2,"tNodeID",q.tNodeID[i])/>
			<cfset querySetCell(q2,"tNode",q.tNode[i])/>
			<cfset querySetCell(q2,"cContentID",q.cContentID[i])/>
			<cfset querySetCell(q2,"rvTitle",q.rvTitle[i])/>
			<cfset querySetCell(q2,"gGroupID",-1)/>
			<cfset querySetCell(q2,"coCommentID",q.coCommentID[i])/>
			<cfset querySetCell(q2,"coName",q.coName[i])/>
			<cfset querySetCell(q2,"coComment","#mid(q.coComment[i],1,255)# ...")/>
			<cfset querySetCell(q2,"coTSCreated",q.coTSCreated[i])/>
			<cfset querySetCell(q2,"coComment_ID",q.coComment_ID[i])/>
		</cfif>
	</cfloop>
	<cfreturn q2/>
</cffunction>


<cffunction name="accessNode" access="public" output="no" returntype="numeric" hint="Returns node id if user has permission to access specified node, otherwise returns 0">
	<cfargument name="tNodeID" type="numeric" required="yes"/>
	<cfargument name="userID" type="numeric" required="no" default="#session.anuser.userID#"/>
	<cfargument name="userGroupIDs" type="string" required="no" default="#session.anuser.authGroupIDs#"/>
	<cfargument name="userRoles" type="string" required="no" default="#session.anuser.userRoles#"/>
	<cfset var ts = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),1)))/>
	<cfset var access = 0/>
	<cfset var q = ""/>
	<cfset var q1 = ""/>
	<cfset var q1lst = 0/>
	<cfset var q2 = ""/>
	<cfset var q2lst = 0/>
	<cfset var q3 = ""/>
	<cfset var q3lst = 0/>
	<cfset var q4 = ""/>
	<cfset var q4lst = 0/>
	<cfset var q5 = ""/>
	<cfset var q5lst = 0/>
	<cfset var q6 = ""/>
	<cfset var q6lst = 0/>
	<cfset var q7 = ""/>
	<cfset var q7lst = 0/>
	<cfset var q8 = ""/>
	<cfset var q8lst = 0/>

	<!--- subqueries perform better for SQL Server when separated out --->
	<cfquery name="q1" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
		select distinct t.tNodeID
		from groups g, tree t, tree_groups tg
		where t.tPublic = 1
		and t.tNodeID = tg.tgNode_ID
		and	g.gGroupID = tg.tgGroup_ID
		and tg.tgActions like '%1%' <!--- has group read permissions --->
	</cfquery>
	<!--- ensure valid result set for use in main query --->
	<cfif q1.recordCount neq 0>
		<cfset q1lst = valueList(q1.tNodeID)/>
	</cfif>

	<cfif structKeyExists(application.permissions.nodeGroups,arguments.tNodeID)>
		<cfquery name="q2" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct t.tNodeID
			from groups g, tree t, tree_groups tg
			where t.tNodeID = #arguments.tNodeID#
			and t.tPublic = 1
			and t.tNodeID = tg.tgNode_ID
			and	g.gGroupID = tg.tgGroup_ID
			and (g.gGroupID in (#arguments.userGroupIDs#) or g.gAuthenticate = 0) <!--- has group/anonymous permissions --->
		</cfquery>

		<cfif q2.recordCount neq 0>
			<cfset q2lst = valueList(q2.tNodeID)/>
		</cfif>

		<cfquery name="q5" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct t.tNodeID
			from tree t, groups g, tree_groups tg
			where t.tNodeID = #arguments.tNodeID#
			and t.tPublic = 0
			and	((g.gStatus = 1 and #ts# >= g.gTSOn) or (g.gStatus = 2 and #ts# between g.gTSOn and g.gTSOff))
			and	g.gGroupID = tg.tgGroup_ID
			and	t.tNodeID = tg.tgNode_ID
			and	g.gGroupID in (#arguments.userGroupIDs#) <!--- check user group permissions --->
		</cfquery>

		<cfif q5.recordCount neq 0>
			<cfset q5lst = valueList(q5.tNodeID)/>
		</cfif>
	</cfif>

	<cfquery name="q3" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
		select distinct s.tNodeID
		from tree p, tree s
		where p.tPublic = 0 <!--- exclude nodes with parent/ancestors that are private --->
		and s.tlPos > p.tlPos
		and s.trPos < p.trPos
	</cfquery>

	<cfif q3.recordCount neq 0>
		<cfset q3lst = valueList(q3.tNodeID)/>
	</cfif>

	<cfquery name="q4" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
		select distinct s.tNodeID
		from tree p, tree s
		where p.tStatus = 0 <!--- exclude nodes with parent/ancestors that are OFF --->
		and s.tlPos > p.tlPos
		and s.trPos < p.trPos
	</cfquery>

	<cfif q4.recordCount neq 0>
		<cfset q4lst = valueList(q4.tNodeID)/>
	</cfif>


	<cfif arguments.userID neq 0 and structKeyExists(application.permissions.nodeUsers,arguments.tNodeID)>
		<cfquery name="q6" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct t.tNodeID <!--- check for nodes with user permissions --->
			from tree t, users u, tree_users tu
			where t.tNodeID = #arguments.tNodeID#
			and t.tPublic = 0
			and	u.uUserID = tu.tuUser_ID
			and	t.tNodeID = tu.tuNode_ID
			and	((u.uStatus = 1 and #ts# >= u.uTSOn) or (u.uStatus = 2 and #ts# between u.uTSOn and u.uTSOff));
		</cfquery>

		<cfif q6.recordCount neq 0>
			<cfset q6lst = valueList(q6.tNodeID)/>
		</cfif>

		<cfquery name="q7" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct t.tNodeID <!--- check specific user permissions --->
			from tree t, users u, tree_users tu
			where t.tNodeID = #arguments.tNodeID#
			and t.tPublic = 0
			and	u.uUserID = #arguments.userID#
			and	u.uUserID = tu.tuUser_ID
			and	t.tNodeID = tu.tuNode_ID
			and	((u.uStatus = 1 and #ts# >= u.uTSOn) or (u.uStatus = 2 and #ts# between u.uTSOn and u.uTSOff));
		</cfquery>

		<cfif q7.recordCount neq 0>
			<cfset q7lst = valueList(q7.tNodeID)/>
		</cfif>
	</cfif>

	<cfquery name="q8" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
		select distinct t.tNodeID
		from tree t, tree_content tc, content c, content_revisions cr, revisions rv
		where t.tStatus = 13 <!--- auto status = must contain active content --->
		<cfif session.anuser.toolaccess and session.anmodule.appuuid eq "A40D51DA-C0A8-7D13-9310FA324A717E20">
			and 1 = 1
		<cfelse>
			and	rv.rvStatus = 1
		</cfif>
		and	c.cContentID = tc.tcContent_ID
		and c.cContentID = cr.crContent_ID
		and	rv.rvRevisionID = cr.crRevision_ID
		and t.tNodeID = tc.tcNode_ID
		and ((tc.tcStatus in (1,3) and #ts# >= tc.tcTSOn) or (tc.tcStatus = 2 and ((#ts# between tc.tcTSOn and tc.tcTSOff) or (tc.tcOffAction in (3,4) and #ts# > tc.tcTSOff))))
	</cfquery>

	<cfif q8.recordCount neq 0>
		<cfset q8lst = valueList(q8.tNodeID)/>
	</cfif>

	<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
		select tNodeID
		from tree
		where tNodeID = #arguments.tNodeID#
		<cfif session.anuser.toolaccess and session.anmodule.appuuid eq "A40D51DA-C0A8-7D13-9310FA324A717E20">
			and 1 = 1 <!--- status does not matter for preview --->
		<cfelse>
			and tNodeID not in (#q4lst#)
			and ((tStatus <> 0 and #ts# >= tTSOn) and not (tStatus = 2 and #ts# > tTSOff)) <!--- scheduled off --->
		</cfif>
		<cfif not listFindNoCase(arguments.userRoles,"siteadmin")> <!--- no restrictions on siteadmin --->
			and	(tNodeID not in (#q1lst#) or tNodeID in (#q2lst#))
			and ((tPublic = 1 and tNodeID not in (#q3lst#)) or (tPublic = 0	and ((tNodeID in (#q5lst#) and tNodeID not in (#q6lst#)) or tNodeID in (#q7lst#))))
			and ((
				<cfif session.anuser.toolaccess and session.anmodule.appuuid eq "A40D51DA-C0A8-7D13-9310FA324A717E20">
					1 = 1
				<cfelse>
					(tStatus in (1,3) and #ts# >= tTSOn) or (tStatus = 2 and (#ts# between tTSOn and tTSOff))
				</cfif>
				)
				or (tStatus = 13 and tNodeID in (#q8lst#))
				)
		</cfif>;
	</cfquery>
	<cfif q.recordCount>
		<cfset access = q.tNodeID/>
	</cfif>
	<cfreturn access/>
</cffunction>


<cffunction name="accessContent" access="public" output="no" returntype="numeric" hint="Returns revision id if content permissions and status active, otherwise returns 0">
	<cfargument name="tNodeID" type="numeric" required="yes"/>
	<cfargument name="cContentID" type="numeric" required="yes"/>
	<cfargument name="userID" type="numeric" required="no" default="#session.anuser.userID#"/>
	<cfargument name="userGroupIDs" type="string" required="no" default="#session.anuser.authGroupIDs#"/>
	<cfargument name="userRoles" type="string" required="no" default="#session.anuser.userRoles#"/>
	<cfargument name="previewID" type="numeric" required="no" default="0"/>
	<cfset var ts = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),1)))/>
	<cfset var access = 0/>
	<cfset var q = ""/>
	<cfset var q1 = ""/>
	<cfset var q1lst = 0/>
	<cfset var q2 = ""/>
	<cfset var q2lst = 0/>
	<cfset var q3 = ""/>
	<cfset var q3lst = 0/>
	<cfset var q4 = ""/>
	<cfset var q4lst = 0/>
	<cfset var q5 = ""/>
	<cfset var q5lst = 0/>
	<cfset var q6 = ""/>
	<cfset var q6lst = 0/>
	<!--- tool user access --->
	<cfif arguments.previewID neq 0 and session.anuser.toolAccess eq true and (listFindNoCase(arguments.userRoles,"siteadmin") or structKeyExists(session.anuser.accessNode,arguments.tNodeID) and structKeyExists(session.anuser.accessContent,arguments.cContentID))>
		<cfset access = arguments.previewID/> <!--- not validating revision id, return the requested one --->
	<cfelseif accessNode(arguments.tNodeID,arguments.userID,arguments.userGroupIDs,arguments.userRoles) neq 0>	<!--- IMPORTANT! First check for node permissions (eg: listing files etc. outside node: search sitemap etc) --->
		<!--- subqueries perform better for SQL Server when separated out --->
		<cfquery name="q1" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select distinct t.tNodeID
			from groups g, tree t, tree_groups tg
			where t.tPublic = 1
			and t.tNodeID = tg.tgNode_ID
			and	g.gGroupID = tg.tgGroup_ID
			and tg.tgActions like '%1%'
		</cfquery>
		<!--- ensure valid result set for use in main query --->
		<cfif q1.recordCount neq 0>
			<cfset q1lst = valueList(q1.tNodeID)/>
		</cfif>

		<cfif structKeyExists(application.permissions.nodeGroups,arguments.tNodeID)>
			<cfquery name="q2" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select distinct t.tNodeID
				from groups g, tree t, tree_groups tg
				where t.tNodeID = #arguments.tNodeID#
				and t.tPublic = 1
				and t.tNodeID = tg.tgNode_ID
				and	g.gGroupID = tg.tgGroup_ID
				and (g.gGroupID in (#arguments.userGroupIDs#) or g.gAuthenticate = 0) <!--- TODO: do we need to restrict to specific group for say search results --->
			</cfquery>

			<cfif q2.recordCount neq 0>
				<cfset q2lst = valueList(q2.tNodeID)/>
			</cfif>
		</cfif>

		<cfif structKeyExists(application.permissions.contentUsers,arguments.cContentID)>
			<cfquery name="q3" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select distinct c.cContentID
				from users u, content c, tree t, tree_content tc, content_users cu
				where t.tNodeID = #arguments.tNodeID#
				and	t.tNodeID = tc.tcNode_ID
				and	c.cContentID = tc.tcContent_ID
				and	c.cContentID = cu.cuContent_ID
				and	u.uUserID = cu.cuUser_ID
			</cfquery>

			<cfif q3.recordCount neq 0>
				<cfset q3lst = valueList(q3.cContentID)/>
			</cfif>
		</cfif>

		<cfif structKeyExists(application.permissions.contentGroups,arguments.cContentID)>
			<cfquery name="q4" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select distinct c.cContentID
				from groups g, content c, tree t, tree_content tc, content_groups cg
				where t.tNodeID = #arguments.tNodeID#
				and	t.tNodeID = tc.tcNode_ID
				and	c.cContentID = tc.tcContent_ID
				and	c.cContentID = cg.cgContent_ID
				and	g.gGroupID = cg.cgGroup_ID
			</cfquery>

			<cfif q4.recordCount neq 0>
				<cfset q4lst = valueList(q4.cContentID)/>
			</cfif>

			<cfquery name="q6" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select distinct c.cContentID
				from groups g, content c, tree t, tree_content tc, content_groups cg
				where t.tNodeID = #arguments.tNodeID#
				and	t.tNodeID = tc.tcNode_ID
				and	c.cContentID = tc.tcContent_ID
				and	c.cContentID = cg.cgContent_ID
				and	g.gGroupID = cg.cgGroup_ID
				and	g.gGroupID in (#arguments.userGroupIDs#)
			</cfquery>

			<cfif q6.recordCount neq 0>
				<cfset q6lst = valueList(q6.cContentID)/>
			</cfif>
		</cfif>

		<cfif arguments.userID neq 0 and structKeyExists(application.permissions.contentUsers,arguments.cContentID)>
			<cfquery name="q5" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
				select distinct c.cContentID
				from users u, content c, tree t, tree_content tc, content_users cu
				where t.tNodeID = #arguments.tNodeID#
				and	t.tNodeID = tc.tcNode_ID
				and	c.cContentID = tc.tcContent_ID
				and	c.cContentID = cu.cuContent_ID
				and	u.uUserID = cu.cuUser_ID
				and	u.uUserID = #arguments.userID#
			</cfquery>

			<cfif q5.recordCount neq 0>
				<cfset q5lst = valueList(q5.cContentID)/>
			</cfif>
		</cfif>


		<!--- if user has access permissions for node then get content (content read access not subject to individual users) --->
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select rv.rvRevisionID
			from tree t, content c, revisions rv, content_revisions cr, tree_content tc
			where c.cContentID = #arguments.cContentID#
			and t.tNodeID  = #arguments.tNodeID#
			and	t.tNodeID = tc.tcNode_ID
			and	c.cContentID = tc.tcContent_ID
			and	c.cContentID = cr.crContent_ID
			and	rv.rvRevisionID = cr.crRevision_ID
			and	rv.rvStatus = 1
			and ((tc.tcStatus in (1,3,4) and #ts# >= tc.tcTSOn) or (tc.tcStatus = 2 and ((#ts# between tc.tcTSOn and tc.tcTSOff) or (tc.tcOffAction in (3,4) and #ts# > tc.tcTSOff))))
			and (t.tNodeID not in (#q1lst#) or t.tNodeID in (#q2lst#))
			and ((c.cContentID not in (#q3lst#) or c.cContentID in (#q5lst#)) and (c.cContentID not in (#q4lst#) or c.cContentID in (#q6lst#)));
		</cfquery>
		<cfif q.recordCount>
			<cfset access = q.rvRevisionID/>
		</cfif>
	<cfelse>
		<cfset access = 0/>
	</cfif>

	<cfreturn access/>
</cffunction>


<!--- determines access to element based on nodeid, contentid, permissions (a list of permissions), roles (All optional) compared to the current user's permissions (user, group, inherit)  --->
<cffunction name="accessAllow" access="public" output="no" returntype="boolean" hint="Returns true if current user has access permissions to specified node, content or roles">
	<cfargument name="tNodeID" required="no" type="numeric" default="0"/>
	<cfargument name="cContentID" required="no" type="numeric" default="0"/>
	<cfargument name="permissions" required="no" type="string" default="All"/>
	<cfargument name="roles" required="no" type="string" default=""/>
	<cfargument name="uUserID" required="no" type="numeric" default="#session.anuser.userID#"/>
	<cfargument name="userGroupIDs" required="no" type="string" default="#session.anuser.userGroupIDs#"/>
	<cfargument name="userRoles" required="no" type="string" default="#session.anuser.userRoles#"/>
	<cfargument name="nodeAccess" required="no" type="boolean" default="false"/> <!--- flag if only validating node access --->
	<cfargument name="toolAccess" required="no" type="boolean" default="true"/> <!--- flag if validating for tool or site permissions --->
	<cfset var ts = createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),1)))/>
	<cfset var q =""/>
	<cfset var actions = ""/>
	<cfset var currentActions = ""/>
	<cfset var i = ""/>
	<cfset var access = false/>
	<cfset var contentAccess = false/>
	<!--- convert permissions to equivalent numeric value --->
	<cfset arguments.permissions = replaceList(lcase(arguments.permissions),"read,edit,add,delete,restore,approve,admin","1,2,3,4,5,6,7")/>
	<!--- admin always has access --->
	<cfif listFindNoCase(arguments.userRoles,"siteadmin") neq 0>
		<cfset access = true/>
	<cfelse>
		<!--- tool user = use persistent tool user permission settings --->
		<cfif arguments.toolAccess and arguments.nodeAccess eq false and structKeyExists(session.anuser,"accessContent") and structKeyExists(session.anuser,"accessNode")>
			<!--- get content permissions first since they have priority over node permissions --->
			<cfif arguments.cContentID neq 0 and structKeyExists(session.anuser.accessContent,arguments.cContentID)>
				<cfset actions = session.anuser.accessContent[arguments.cContentID]/>
				<cfset contentAccess = true/>
			</cfif>
			<!--- if no content permissions required and no content permissions then get node permissions - check for user permissions --->
			<cfif contentAccess eq false and arguments.tNodeID neq 0 and structKeyExists(session.anuser.accessNode,arguments.tNodeID) and not structKeyExists(application.permissions.contentGroups,arguments.cContentID) and not structKeyExists(application.permissions.contentUsers,arguments.cContentID)>
				<cfset actions = session.anuser.accessNode[arguments.tNodeID]/>
				<cfset contentAccess = true/>
			</cfif>
		<cfelseif arguments.cContentID neq 0 and arguments.nodeAccess eq false>
			<cfif structKeyExists(session.anuser.accessContent,arguments.cContentID)>
				<cfset actions = session.anuser.accessContent[arguments.cContentID]/>
				<cfset contentAccess = true/>
			<cfelse>
				<!--- get user permissions --->
				<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
					select cu.cuActions
					from content c, content_users cu, users u
					where c.cContentID = #arguments.cContentID#
					and	u.uUserID = #arguments.uUserID#
					and	c.cContentID = cu.cuContent_ID
					and	u.uUserID = cu.cuUser_ID
					and	((u.uStatus = 1 and #ts# >= u.uTSOn) or (u.uStatus = 2 and #ts# between u.uTSOn and u.uTSOff));
				</cfquery>
				<!--- if user permissions then return them, otherwise check group permissions --->
				<cfif q.recordCount>
					<cfset actions = q.cuActions/>
					<cfset contentAccess = true/>
				<cfelse>
					<!--- get group permissions --->
					<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
						select cg.cgActions
						from content c, content_groups cg, groups g
						where c.cContentID = #arguments.cContentID#
						and	g.gGroupID in (#arguments.userGroupIDs#)
						and	c.cContentID = cg.cgContent_ID
						and	g.gGroupID = cg.cgGroup_ID
						and	((g.gStatus = 1 and #ts# >= g.gTSOn) or (g.gStatus = 2 and #ts# between g.gTSOn and g.gTSOff));
					</cfquery>
					<!--- if records then combine permissions (since user may belong to more than one group) --->
					<cfif q.recordCount>
						<cfloop query="q">
							<cfset currentActions = q.cgActions/>
							<cfloop index="i" list="#currentActions#">
								<cfif not listFind(actions,i)>
									<cfset actions = listAppend(actions,i)/>
								</cfif>
							</cfloop>
						</cfloop>
						<cfset contentAccess = true/>
					</cfif>
				</cfif>
					<cfset session.anuser.accessContent[arguments.cContentID] = actions/>
				</cfif>

			<!--- if no content permissions (highest priority) then check node permissions --->
			<cfif (arguments.nodeAccess eq true or contentAccess eq false) and arguments.tNodeID neq 0>
				<cfif structKeyExists(session.anuser.accessNode,arguments.tNodeID)>
					<cfset actions = session.anuser.accessNode[arguments.tNodeID]/>
					<cfset contentAccess = true/>
				<cfelse>
					<!--- get user node permissions --->
					<cfif arguments.nodeAccess eq false>
						<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
							select tu.tuActions
							from tree t, tree_users tu, users u
							where t.tNodeID = #arguments.tNodeID#
							and	u.uUserID = #arguments.uUserID#
							and	t.tNodeID = tu.tuNode_ID
							and	u.uUserID = tu.tuUser_ID
							and	((u.uStatus = 1 and #ts# >= u.uTSOn) or (u.uStatus = 2 and #ts# between u.uTSOn and u.uTSOff));
						</cfquery>
						<!--- set permissions --->
						<cfif q.recordCount>
							<cfset actions = q.tuActions/>
							<cfset contentAccess = true/>
						</cfif>
					</cfif>
						<!--- get group node permissions --->
					<cfif arguments.nodeAccess eq true or contentAccess eq false>
						<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
							select tg.tgActions
							from tree t, tree_groups tg, groups g
							where t.tNodeID = #arguments.tNodeID#
							and	g.gGroupID in (#arguments.userGroupIDs#)
							and	t.tNodeID = tg.tgNode_ID
							and	g.gGroupID = tg.tgGroup_ID
							and	((g.gStatus = 1 and #ts# >= g.gTSOn) or (g.gStatus = 2 and #ts# between g.gTSOn and g.gTSOff));
						</cfquery>
						<!--- if records then combine permissions (since user may belong to more than one group) --->
						<cfif q.recordCount>
							<cfloop query="q">
								<cfset currentActions = q.tgActions/>
								<cfloop index="i" list="#currentActions#">
									<cfif not listFind(actions,i)>
										<cfset actions = listAppend(actions,i)/>
									</cfif>
								</cfloop>
							</cfloop>
						</cfif>
					</cfif>
						<cfset session.anuser.accessNode[arguments.tNodeID] = actions/>
					</cfif>
				</cfif>
			</cfif>

		<!--- compare permissions with required permissions list --->
		<cfif listLen(actions) and arguments.permissions eq "All">
			<cfset access = true/>
		<cfelseif listLen(actions) and listLen(arguments.permissions)>
			<cfloop index="i" list="#actions#">
				<cfif listFindNoCase(arguments.permissions,i)>
					<cfset access = true/>
					<cfbreak/> <!--- match found no need to continue --->
				</cfif>
			</cfloop>
		</cfif>

		<!--- if access = false check role permissions --->
		<cfif not access and listLen(arguments.roles)>
			<cfloop index="i" list="#arguments.userRoles#">
				<cfif listFindNoCase(arguments.roles,i)>
					<cfset access = true/>
					<cfbreak/> <!--- match found no need to continue --->
				</cfif>
			</cfloop>
		</cfif>
	</cfif>
	<cfreturn access/>
</cffunction>


<cffunction name="authGroupID" access="public" output="no" returntype="boolean" hint="Authorize group access by groupID or UUID and add to session">
	<cfargument name="gGroupID" type="numeric" required="no" default="0"/>
	<cfargument name="gIdentifier" type="string" required="no" default=""/>
	<cfargument name="exclusive" type="boolean" required="no" default="true"/> <!--- true = only one link auth'd group at any time --->
	<cfargument name="updateSession" type="boolean" required="no" default="true"/> <!--- false = allows testing of group auth without setting session --->
	<cfargument name="ipAddress" type="string" required="no" default="#cgi.remote_addr#"/>
	<cfset var authenticated = false/>
	<cfset var q = ""/>
	<cfset var i = 0/>
	<cfset var j = 0/>
	<cfset var allowAccess = false/>
	<cfset var authGroupID = 0/>
	<cfset var authGroup = ""/>
	<cfset var lstGroupIDs = ""/>
	<cfset var lstGroups = ""/>
	<!--- if default groupid and not signed in then reset anonymous group permissions --->
	<cfif arguments.gGroupID eq 0 and session.anuser.userID eq 0>
	<!--- TODO: overwrites anonymous permissions set at session start by anuser cfc
		<cfset session.anuser.userGroupIDs = application.assetnow.everyoneGroupID/>
		<cfset session.anuser.userGroups = "everyone"/>
	--->
		<cfset authenticated = true/>
	<!--- group not already added to session then validate link authorization for group and add --->
	<cfelseif arguments.updateSession and listFindNoCase(session.anuser.userGroupIDs,arguments.gGroupID) neq 0 or listFindNoCase(session.anuser.userGroups,arguments.gIdentifier) neq 0>
		<cfset authenticated = true/>
	<!--- check group auth and restrictions --->
	<cfelseif arguments.gGroupID neq 0 or len(arguments.gIdentifier) neq 0>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select gGroupID, gIdentifier, gRestrict
			from groups
			where gAuthenticate = 1 <!--- anonymous access groups with link authorization --->
			<cfif len(arguments.gIdentifier) neq 0>
				and gIdentifier = '#arguments.gIdentifier#'
			<cfelse>
				and gGroupID = #arguments.gGroupID#
			</cfif>
			and (gStatus = 1 or (gStatus = 2 and #createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),1)))# between gTSOn and gTSOff));
		</cfquery>
		<cfif q.recordCount neq 0>
			<cfif len(q.gRestrict[1]) eq 0>
				<cfset authGroupID = q.gGroupID[1]/>
				<cfset authGroup = q.gIdentifier[1]/>
				<cfset authenticated = true/>
			<cfelseif len(arguments.ipAddress) neq 0>
				<cfset allowAccess = false/>
				<cftry> <!--- apply restrictions --->
					<cfscript>
						for (j=1; j lte listLen(q.gRestrict[1]); j=j+1) {
							if (reFindNoCase(listGetAt(q.gRestrict[1],j),arguments.ipAddress)) allowAccess = true;
						}
					</cfscript>
					<cfcatch type="any">
						<cfset allowAccess = false/> <!--- any errors then deny access --->
					</cfcatch>
				</cftry>
				<cfif allowAccess>
					<cfset authGroupID = q.gGroupID[1]/>
					<cfset authGroup = q.gIdentifier[1]/>
					<cfset authenticated = true/>
				</cfif>
			</cfif>
			<!--- if exclusive then reset user groups and add url group --->
			<cfif authenticated and arguments.exclusive and arguments.updateSession>
				<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
					select distinct g.gGroupID, g.gIdentifier, g.gRestrict
					from users u, groups g, users_groups ug
					where u.uUserID = #session.anuser.userID#
					and	g.gGroupID = ug.ugGroup_ID
					and	u.uUserID = ug.ugUser_ID
					and	(g.gStatus = 1 or (g.gStatus = 2 and #createODBCDateTime(dateAdd("n",application.config.SERVER_TIME_OFFSET_MINUTES,createDateTime(datePart("yyyy",now()),datePart("m",now()),datePart("d",now()),datePart("h",now()),datePart("n",now()),1)))# between g.gTSOn and g.gTSOff));
				</cfquery>
				<!--- built auth'd group list based on restrictions, no restrictions on siteadmin --->
				<cfloop index="i" from="1" to="#q.recordCount#">
					<cfif len(q.gRestrict[i]) eq 0 or listFindNoCase(session.anuser.userRoles,"siteadmin") neq 0>
						<cfset lstGroupIDs = listAppend(lstGroupIDs,q.gGroupID[i])/>
						<cfset lstGroups = listAppend(lstGroups,q.gIdentifier[i])/>
					<cfelse>
						<cfset allowAccess = false/>
						<cftry> <!--- apply restrictions --->
							<cfscript>
								for (j=1; j lte listLen(q.gRestrict[i]); j=j+1) {
									if (reFindNoCase(listGetAt(q.gRestrict[i],j),arguments.ipAddress)) allowAccess = true;
								}
							</cfscript>
							<cfcatch type="any">
								<cfset allowAccess = false/> <!--- any errors then deny access --->
							</cfcatch>
						</cftry>
						<cfif allowAccess>
							<cfset lstGroupIDs = listAppend(lstGroupIDs,q.gGroupID[i])/>
							<cfset lstGroups = listAppend(lstGroups,q.gIdentifier[i])/>
						</cfif>
					</cfif>
				</cfloop>
				<cfif updateSession>
					<!--- reset user permissions and add auth'd group --->
					<cfif authGroupID neq 0>
						<cfset session.anuser.userGroupIDs = listAppend(lstGroupIDs,authGroupID)/>
						<cfset session.anuser.userGroups = listAppend(lstGroups,authGroup)/>
					</cfif>
					<!--- add everyone anonymous group --->
					<cfset session.anuser.userGroupIDs = listAppend(session.anuser.userGroupIDs,application.assetnow.everyoneGroupID)/>
					<cfset session.anuser.userGroups = listAppend(session.anuser.userGroups,"everyone")/>
				</cfif>
			</cfif>
		</cfif>
	</cfif>
	<cfreturn authenticated/>
</cffunction>


<cffunction name="feedEnabled" access="public" output="no" returntype="boolean" hint="Returns true if feed enabled for category">
	<cfargument name="tNodeID" required="no" type="numeric" default="0"/>
	<cfargument name="cContentID" required="no" type="numeric" default="0"/>
	<cfset var feedOn = false/>
	<cfset var r = 0/>
	<cfset var q = ""/>
	<cfif arguments.tNodeID neq 0 and arguments.cContentID eq 0>
		<cfset r = accessNode(arguments.tNodeID)/>
	<cfelse>
		<cfset r = accessContent(arguments.tNodeID,arguments.cContentID)/>
	</cfif>
	<cfif r neq 0>
		<cfquery name="q" username="#application.config.DSN_USERNAME#" password="#application.config.DSN_PASSWORD#" datasource="#application.config.DSN#" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select tFeedStatus
			from tree
			where tNodeID = #arguments.tNodeID#
		</cfquery>
		<cfif q.recordCount neq 0 and q.tFeedStatus[1] neq 0>
			<cfset feedOn = true/>
		<cfelse>
			<cfset feedOn = false/>
		</cfif>
	</cfif>
	<cfreturn feedOn/>
</cffunction>


<cffunction name="parseHTML" access="public" output="no" returntype="string" hint="Parses HTML for link references and returns updated string">
	<cfargument name="str" type="string" required="yes"/>
	<cfargument name="nodeid" type="numeric" required="no" default="0"/> <!--- if nodeid = 0 then we are saving to db --->
	<cfargument name="contentid" type="numeric" required="no" default="0"/> <!--- used to resolve embedded assets --->
	<cfargument name="revisionid" type="numeric" required="no" default="0"/> <!--- used to resolve embedded assets --->
	<cfargument name="edit" type="boolean" required="no" default="false"/> <!--- set to true to when editing --->
	<cfset var xslt = ""/>
	<cfset var temp = ""/>
	<cfset var nameSpaces = "xmlns:widget='http://assetnow.com' xmlns:widget-nocache='http://assetnow.com' #application.config.XS_CUSTOM_NAMESPACES#"/> <!--- trim whitespace to ensure correct mid() removal of top level --->
	<cfset var sTag = "<anxparsehtml #trim(nameSpaces)#>"/>
	<cfset var eTag = "</anxparsehtml>"/>
	<cfset arguments.str = trim(arguments.str)/>
	<cfif len(arguments.str) neq 0>
		<cfif arguments.nodeid eq 0>
			<!--- XSL to transform content is faster than regex --->					
			<cfxml variable="xslt"><cfoutput>
			<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
				<xsl:output method="xml" indent="yes" cdata-section-elements="script" encoding="UTF-8" omit-xml-declaration="yes"/>
			
				<!--- apply root template --->
				<xsl:template match="/">
					<xsl:apply-templates/>
				</xsl:template>
			
				<!--- copy all attributes and nodes --->
				<xsl:template match="@*|node()">
					<xsl:copy>
						<xsl:apply-templates select="@*|node()"/>
					</xsl:copy>
				</xsl:template>

				<!--- remove url encoding --->
				<xsl:template match="@*"> <!--- note: can restrict to hrefs/src using @href|@src --->
					<xsl:variable name="replaceUrlDash">
						<xsl:call-template name="replace-string">
							<xsl:with-param name="text" select="."/>
							<xsl:with-param name="replace" select="'%20'"/>
							<xsl:with-param name="with" select="'-'"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="replaceUrlUnderScore">
						<xsl:call-template name="replace-string">
							<xsl:with-param name="text" select="$replaceUrlDash"/>
							<xsl:with-param name="replace" select="'%5F'"/>
							<xsl:with-param name="with" select="'_'"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:attribute name="{name()}">
						<xsl:value-of select="$replaceUrlUnderScore"/>		
					</xsl:attribute>
					<xsl:apply-templates/>					
				</xsl:template>

				<!--- convert absolute to ANX short form paths --->
				<xsl:template match="@*[starts-with(.,'#application.virtualPaths.IMAGES#/library/')]">
					<xsl:attribute name="{name()}">
						<xsl:value-of select="concat('/anlibimage/',substring-after(.,'#application.virtualPaths.IMAGES#/library/'))"/>		
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>
	
				<xsl:template match="@*[starts-with(.,'#application.virtualPaths.IMAGES#/category/') or starts-with(.,'#application.virtualPaths.IMAGES#/content/')]">
					<xsl:attribute name="{name()}">
						<xsl:call-template name="concat-with-substring-after-last">
							<xsl:with-param name="str" select="'/animage/'"/>
							<xsl:with-param name="input" select="."/>
							<xsl:with-param name="marker" select="'/'"/>
						</xsl:call-template>				
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>
		
				<xsl:template match="@*[starts-with(.,'#application.virtualPaths.ASSETS#/content/')]">
					<xsl:attribute name="{name()}">
						<xsl:call-template name="concat-with-substring-after-last">
							<xsl:with-param name="str" select="'/anassetpath/'"/>
							<xsl:with-param name="input" select="."/>
							<xsl:with-param name="marker" select="'/'"/>
						</xsl:call-template>				
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<xsl:template match="@*[starts-with(.,'#application.virtualPaths.ASSETS#/library/')]">
					<xsl:attribute name="{name()}">
						<xsl:call-template name="concat-with-substring-after-last">
							<xsl:with-param name="str" select="'/anlibassetpath/'"/>
							<xsl:with-param name="input" select="."/>
							<xsl:with-param name="marker" select="'/'"/>
						</xsl:call-template>				
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<xsl:template match="@*[starts-with(.,'#application.virtualPaths.ANROOT#/index.cfm/3,')]">
					<xsl:attribute name="{name()}">
						<xsl:call-template name="concat-with-substring-after-last">
							<xsl:with-param name="str" select="'/anasset/'"/>
							<xsl:with-param name="input" select="."/>
							<xsl:with-param name="marker" select="'/'"/>
						</xsl:call-template>				
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<xsl:template match="@*[starts-with(.,'#application.virtualPaths.ANROOT#/index.cfm/14,')]">
					<xsl:attribute name="{name()}">
						<xsl:call-template name="concat-with-substring-after-last">
							<xsl:with-param name="str" select="'/andataasset/'"/>
							<xsl:with-param name="input" select="."/>
							<xsl:with-param name="marker" select="'/'"/>
						</xsl:call-template>				
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<xsl:template match="@*[starts-with(.,'#application.virtualPaths.ANROOT#/index.cfm/8,')]">
					<xsl:attribute name="{name()}">
						<xsl:call-template name="concat-with-substring-after-last">
							<xsl:with-param name="str" select="'/anlibasset/'"/>
							<xsl:with-param name="input" select="."/>
							<xsl:with-param name="marker" select="','"/> <!--- match on , to preserve library ID --->
						</xsl:call-template>				
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<!--- NOTE: this template must have lowest priority as it is less specific match (xslt default template priority = 1) --->
				<xsl:template match="@*[starts-with(.,'#application.virtualPaths.ANROOT#/index.cfm/')]" priority="0"> 
					<xsl:attribute name="{name()}">
						<xsl:value-of select="concat('/anlink/',substring-after(.,'#application.virtualPaths.ANROOT#/index.cfm/'))"/>		
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>
			
				<!--- match complete urls - typically these are inserted via editor --->
				<xsl:template match="@href[contains(.,'#application.config.XS_WEB_SERVICES_URL##application.virtualPaths.ANROOT#/')]">
					<xsl:attribute name="{name()}">
						<xsl:value-of select="concat('/anroot/',substring-after(.,'#application.config.XS_WEB_SERVICES_URL##application.virtualPaths.ANROOT#/'))"/>		
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>
		
				<xsl:template match="@href[contains(.,'#cgi.SERVER_NAME##application.virtualPaths.ANROOT#/')]">
					<xsl:attribute name="{name()}">
						<xsl:value-of select="concat('/anroot/',substring-after(.,'#cgi.SERVER_NAME##application.virtualPaths.ANROOT#/'))"/>		
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<xsl:template match="@src[contains(.,'#application.config.XS_WEB_SERVICES_URL##application.virtualPaths.ANROOT#/img/') or contains(.,'#cgi.SERVER_NAME##application.virtualPaths.ANROOT#/img/')]">
					<xsl:attribute name="{name()}">
						<xsl:call-template name="concat-with-substring-after-last">
							<xsl:with-param name="str" select="'/animage/'"/>
							<xsl:with-param name="input" select="."/>
							<xsl:with-param name="marker" select="'/'"/>
						</xsl:call-template>				
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<!--- custom function templates --->
				<xsl:template name="concat-with-substring-after-last">
					<xsl:param name="str" />
					<xsl:param name="input" />
					<xsl:param name="marker" />
					<xsl:choose>
						<xsl:when test="contains($input,$marker)">
							<xsl:call-template name="concat-with-substring-after-last">
								<xsl:with-param name="str" select="$str" />
								<xsl:with-param name="input" select="substring-after($input,$marker)" />
								<xsl:with-param name="marker" select="$marker" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($str,$input)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:template>

				<xsl:template name="replace-string">
					<xsl:param name="text"/>
					<xsl:param name="replace"/>
					<xsl:param name="with"/>
					<xsl:choose>
						<xsl:when test="contains($text,$replace)">
							<xsl:value-of select="substring-before($text,$replace)"/>
							<xsl:value-of select="$with"/>
							<xsl:call-template name="replace-string">
								<xsl:with-param name="text" select="substring-after($text,$replace)"/>
								<xsl:with-param name="replace" select="$replace"/>
								<xsl:with-param name="with" select="$with"/>
								</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$text"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:template>

			</xsl:stylesheet></cfoutput>
			</cfxml>
		<cfelse>
			<!--- XSL to transform links (faster than regex and correctly handles multiple attributes with same shortform) --->
			<cfxml variable="xslt"><cfoutput>
			<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
				<xsl:output method="xml" indent="yes" cdata-section-elements="script" encoding="UTF-8" omit-xml-declaration="yes"/>
			
				<!--- apply root template --->
				<xsl:template match="/">
					<xsl:apply-templates/>
				</xsl:template>
			
				<!--- match all attributes and nodes --->
				<xsl:template match="@*|node()">
					<xsl:copy>
						<xsl:apply-templates select="@*|node()"/>
					</xsl:copy>
				</xsl:template>

				<!--- convert ANX short form paths to absolute --->
				<xsl:template match="@*[starts-with(.,'/anroot/')]">
					<xsl:attribute name="{name()}">
						<xsl:value-of select="concat('#application.virtualPaths.ANROOT#/',substring-after(.,'/anroot/'))"/>		
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<xsl:template match="@*[starts-with(.,'/anlink/')]">
					<xsl:attribute name="{name()}">
						<xsl:value-of select="concat('#application.virtualPaths.ANROOT#/index.cfm/',substring-after(.,'/anlink/'))"/>		
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<cfif arguments.contentid eq 0>
					<xsl:template match="@*[starts-with(.,'/animage/')]">
						<xsl:attribute name="{name()}">
							<xsl:value-of select="concat('#application.virtualPaths.IMAGES#/category/#arguments.nodeid#/',substring-after(.,'/animage/'))"/>		
						</xsl:attribute>	
						<xsl:apply-templates/>					
					</xsl:template>
				<cfelse>
					<xsl:template match="@*[starts-with(.,'/animage/')]">
						<xsl:attribute name="{name()}">
							<xsl:value-of select="concat('#application.virtualPaths.IMAGES#/content/#arguments.contentid#/#arguments.revisionid#/',substring-after(.,'/animage/'))"/>		
						</xsl:attribute>	
						<xsl:apply-templates/>					
					</xsl:template>
				</cfif>
				
				<xsl:template match="@*[starts-with(.,'/anlibimage/')]">
					<xsl:attribute name="{name()}">
						<xsl:value-of select="concat('#application.virtualPaths.IMAGES#/library/',substring-after(.,'/anlibimage/'))"/>		
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<xsl:template match="@*[starts-with(.,'/anasset/')]">
					<xsl:attribute name="{name()}">
						<xsl:value-of select="concat('#application.virtualPaths.ANROOT#/index.cfm/3,#arguments.nodeid#,#arguments.contentid#/',substring-after(.,'/anasset/'))"/>		
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<xsl:template match="@*[starts-with(.,'/anlibasset/')]">
					<xsl:attribute name="{name()}">
						<xsl:value-of select="concat('#application.virtualPaths.ANROOT#/index.cfm/8,#arguments.nodeid#,#arguments.contentid#,',substring-after(.,'/anlibasset/'))"/>		
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<xsl:template match="@*[starts-with(.,'/andataasset/')]">
					<xsl:attribute name="{name()}">
						<xsl:value-of select="concat('#application.virtualPaths.ANROOT#/index.cfm/14,#arguments.nodeid#,#arguments.contentid#/',substring-after(.,'/andataasset/'))"/>		
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>
				
				<xsl:template match="@*[starts-with(.,'/anassetpath/')]">
					<xsl:attribute name="{name()}">
						<xsl:value-of select="concat('#application.virtualPaths.ASSETS#/content/#arguments.contentid#/#arguments.revisionid#/',substring-after(.,'/anassetpath/'))"/>		
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<xsl:template match="@*[starts-with(.,'/anlibassetpath/')]">
					<xsl:attribute name="{name()}">
						<xsl:value-of select="concat('#application.virtualPaths.ASSETS#/library/',substring-after(.,'/anlibassetpath/'))"/>		
					</xsl:attribute>	
					<xsl:apply-templates/>					
				</xsl:template>

				<!--- restrict CFML that can be used in content --->					
				<cfif application.config.EXECUTE_CFML eq 0>
					<!--- if all CFML disabled strip cf tags without trace --->
					<xsl:template match="*[starts-with(name(),'cf')]" priority="0">
						<xsl:apply-templates/>																	
					</xsl:template>
				<cfelse>
					<!--- check for valid/allowed CF tags --->
					<xsl:template match="#listChangeDelims(application.config.DISALLOW_CFML_TAGS,'|')#">
						<xsl:comment>
							<xsl:value-of select="concat(' DISABLED CF TAG: ',name(),' ')"/> <!--- show DISABLED CF TAG and tag name inside html comment --->				
							<xsl:apply-templates/>											
						</xsl:comment>
					</xsl:template>
				</cfif>					

				<!--- remove comments (used for notes by editor) --->
				<cfif arguments.edit eq false>				
					<xsl:template match="comment()"/>
				</cfif>
			</xsl:stylesheet></cfoutput>
			</cfxml>
		</cfif>	

		<!--- create well formed XML string and transform shortform links --->
		<cfset temp = sTag & arguments.str & eTag/>
		<cfset temp = trim(xmlTransform(temp,xslt))/>
		
		<!--- remove container tags required for valid transformation namespaces - mid is a faster than regex but whitespace sensitive --->
		<!--- <cfset arguments.str = reReplaceNoCase(temp,"</?anxparsehtml.*?>","","all")/> --->
		<cfset arguments.str = mid(temp,len(sTag)+1,len(temp)-len(sTag)-len(eTag))/>
	</cfif>
	<cfreturn arguments.str/>
</cffunction>


<cffunction name="sesPathFormat" output="no" returntype="string" hint="Returns valid OS directory path">
	<cfargument name="str" required="yes" type="string"/>
	<cfargument name="maxLength" required="no" type="numeric" default="255"/>
	<!--- NOTE: add special chars to the replace lists (src/out) as required - must replace srcLst chars with a-z,0-9,-,_ to ensure OS valid dir/path --->
	<cfargument name="srcLst" required="no" type="string" default="à,á,â,ã,ä,å,ç,è,é,ê,ë,ì,í,î,ï,ñ,ò,ó,ô,õ,ö,ù,ú,û,ü,ý,ÿ"/>
	<cfargument name="outLst" required="no" type="string" default="a,a,a,a,a,a,c,e,e,e,e,i,i,i,i,n,o,o,o,o,o,u,u,u,u,y,y"/>
	<!--- remove any x/html entities and apos/quotes --->
	<cfset arguments.str = reReplaceNoCase(arguments.str,"&.*?;|['""]","","all")/>
	<cfif len(trim(arguments.str)) neq 0 and reFindNoCase("[a-z0-9_]",arguments.str) neq 0>
		<cfset arguments.str = mid(trim(arguments.str),1,arguments.maxLength)/> <!--- enforce max length --->
		<cfset arguments.str = replaceList(arguments.str,arguments.srcLst,arguments.outLst)/>
		<cfset arguments.str = reReplaceNoCase(arguments.str,"[^a-z0-9_\-\s]","-","All")/> <!--- only allow a-z,0-9,-,space --->
		<cfset arguments.str = reReplaceNoCase(arguments.str,"\W{1,}","-","All")/> <!--- replace dash, spaces with single dash --->
		<!--- trim to max length and remove leading/trailing/multiple dashes --->
		<cfset arguments.str = listChangeDelims(mid(arguments.str,1,arguments.maxLength),"-","-")/>
	<cfelse>
		<cfset arguments.str = ""/> <!--- if invalid input then return empty string --->
	</cfif>
	<cfreturn arguments.str/>
</cffunction>


</cfcomponent>