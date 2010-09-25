<cfcomponent displayname="core-bean" extends="mxunit.framework.TestCase">

	<cffunction name="setUp">
		<cfset variables.beanfactory = CreateObject('component','com.andreacfm.util.beanutils.DynamicXmlBeanFactory').init()/>
		<cfset variables.beanfactory.loadBeansFromDynamicXmlFile('/com/andreacfm/datax/tests/config/coldspring.xml.cfm') />
		<cfset variables.beanfactory.getBean('EventManager').getLogger().setOut('console')>
		<cfset var dm = variables.beanfactory.getbean('dataMgr')>
		<cfset dm.runsql('Delete from book')>
		<cfset dm.runsql('Delete from author')>				
	</cffunction>

	<cffunction name="tearDown">
		<cfscript>
		</cfscript>
	</cffunction>

	<cffunction name="test_basic_cache_via_id" returntype="void" output="false">
		<cfscript>
		var bf = variables.beanFactory;
		bf.getBean('CacheManager').setCacheWithin(createTimeSpan(0,0,1,0));
		
		// check via id that the q object is always the same		
		var sv = bf.getBean('dsManager').getService('bookService');
		var q = sv.list(cache=true);
		var id1 = getObjectId(q);
		var q2 = sv.list(cache=true);
		var id2 = getObjectId(q2);
		assertTrue(id1 eq id2);	
		</cfscript>
	</cffunction>	
 

	<cffunction name="test_basic_cache_with_db_interactions" returntype="void" output="false">
		<cfscript>
		transaction action="begin"{

			try{

				var bf = variables.beanFactory;
				bf.getBean('CacheManager').setCacheWithin(createTimeSpan(0,0,1,0));
				var sv = bf.getBean('dsManager').getService('bookService');
				
				var dbf = bf.getBean('dbFactory');
				var book = dbf.getBean('book');
				book.setBookName('one');
				book.create();

				var book = dbf.getBean('book');
				book.setBookName('two');
				book.create('two');
				
				var q = sv.list(cache=true);
				assertTrue(q.recordcount eq 2);
				
				bf.getBean('dataMgr').runsql("Delete from book where bookname = 'one'");
				
				//reload the cache		
				q = sv.list(cache=true);
				assertTrue(q.recordcount eq 2);
				
				//if no cache should be 1 record
				q = sv.list();
				assertTrue(q.recordcount eq 1);

			}
			catch(any e){
				transaction action="rollback";
				rethrow;		
			}
			transaction action="rollback";
		}	
			
		</cfscript>
	</cffunction>	
	
 
	<cffunction name="test_custom_key" returntype="void" output="false">
		<cfscript>
			transaction action="begin"{
				try{
					
					var bf = variables.beanFactory;
					bf.getBean('CacheManager').setCacheWithin(createTimeSpan(0,0,1,0));
					var sv = bf.getBean('dsManager').getService('bookService');
					var dbf = bf.getBean('dbFactory');
						 
					var key = 'mykey';
					
					for(var i = 0; i < 3;i++){
						var book = dbf.getBean('book');
						book.setBookName(i);
						book.create();			
					}
					
					var q = sv.read(cache=true,key=key);
					assertTrue(arraylen(q) eq 3);
					
					//remove all the records from db directly
					bf.getBean('dataMgr').runsql('Delete from book');
				
					//retest the cache
					var q = sv.read(cache=true,key=key);
					assertTrue(arraylen(q) eq 3);										
					
				}
				catch(any e){
					transaction action="rollback";
					rethrow;						
				}				
				transaction action="rollback";
			}
		</cfscript>
	</cffunction>

	<cffunction name="getObjectId" returntype="string" access="private" output="false" hint="Return the identityHashCode of the java object underling the cfc ">
		<cfreturn createObject("java", "java.lang.System").identityHashCode(this)/>
	</cffunction>
			
</cfcomponent>