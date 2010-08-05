<?xml version="1.0" encoding="UTF-8"?>
<beans dafault-autowire="false">				
             
    <!-- 
        DATA
        * Data Manager Instance	 
    -->		
    <bean id="dataMgr" class="com.andreacfm.datax.dataMgr.dataMgr_MYSQL" singleton="true">
        
        <constructor-arg name="datasource">
            <value>books</value>
        </constructor-arg>
        
        <constructor-arg name="smartCache">
            <value>false</value>
        </constructor-arg>
		
        <constructor-arg name="xmlPath">
            <value>/com/andreacfm/datax/tests/config/dataMgr.xml.cfm</value>
        </constructor-arg>
      
    </bean>
    
    <bean id="EventManager" class="com.andreacfm.cfem.EventManager">
        <constructor-arg name="events">
            <list>
                <map>
                    <entry key="name">
                        <value>ModelBeforeCreate</value>
                    </entry>
                </map>             
                <map>
                    <entry key="name">
                        <value>ModelAfterCreate</value>
                    </entry>
                </map>             
                <map>
                    <entry key="name">
                        <value>ModelBeforeDelete</value>
                    </entry>
                </map>             
                <map>
                    <entry key="name">
                        <value>ModelAfterDelete</value>
                    </entry>
                </map>             
                <map>
                    <entry key="name">
                        <value>ModelBeforeUpdate</value>
                    </entry>
                </map>             
                <map>
                    <entry key="name">
                        <value>ModelAfterUpdate</value>
                    </entry>
                </map>             
                <map>
                    <entry key="name">
                        <value>ModelOnInvalidBean</value>
                    </entry>
                </map>                             
                <map>
                    <entry key="name"><value>GatewayBeforeRead</value></entry>
                </map>                                             
                <map>
                    <entry key="name"><value>GatewayAfterRead</value></entry>
                </map>                                                             
                <map>
                    <entry key="name"><value>GatewayBeforeList</value></entry>
                </map>                                             
                <map>
                    <entry key="name"><value>GatewayAfterList</value></entry>
                </map>                                             
                
            </list>
        </constructor-arg>
        
    </bean>
    
    <!-- 		
        MODEL
    -->		
    <bean id="bookConfig" singleton="true" class="com.andreacfm.datax.ModelConfig">
        
        <constructor-arg name="id">
            <value>book</value>
        </constructor-arg>
        
        <constructor-arg name="table">
            <value>book</value>
        </constructor-arg>
        
        <constructor-arg name="beanclass">
            <value>com.andreacfm.datax.tests.model.book</value>
        </constructor-arg>
        
        <constructor-arg name="defaultOrderBy">
            <value>bookId</value>
        </constructor-arg>
        
        <constructor-arg name="pk">
            <value>bookId</value>
        </constructor-arg>
        
        <constructor-arg name="defaults">
            <map>
            </map>
        </constructor-arg>
        
    </bean> 
    
    <bean id="authorConfig" singleton="true" class="com.andreacfm.datax.ModelConfig">
        
        <constructor-arg name="id">
            <value>author</value>
        </constructor-arg>
        
        <constructor-arg name="table">
            <value>author</value>
        </constructor-arg>
        
        <constructor-arg name="beanclass">
            <value>com.andreacfm.datax.tests.model.author</value>
        </constructor-arg>
        
        <constructor-arg name="defaultOrderBy">
            <value>authorid</value>
        </constructor-arg>
        
        <constructor-arg name="pk">
            <value>authorid</value>
        </constructor-arg>
        
        <constructor-arg name="skipfields">
            <value/>
        </constructor-arg>
        
    </bean>
    
    <!-- simulate passing object ( decorator ) instead of class name -->
    <bean id="bookDao" class="com.andreacfm.datax.tests.model.bookdao" autowire="byName">
        <constructor-arg name="ModelConfig">
            <ref bean="bookConfig"></ref>
        </constructor-arg>
    </bean>
    
    <bean id="bookValidator" class="com.andreacfm.datax.tests.model.bookValidator"/>
    
    <bean id="dbFactory" class="com.andreacfm.datax.dbFactory" singleton="true" autowire="byName">
        
        <constructor-arg name="dataMgr">
            <ref bean="dataMgr"/>
        </constructor-arg>	
    	
    	<constructor-arg name="testmode">
    		<value>true</value>
    	</constructor-arg>
        
        <constructor-arg name="config">
            <list>
                <map>
                    <entry key="ModelConfig">
                        <ref bean="bookConfig"/>
                    </entry>
                    <!-- Dao can be a class name or an object from this factory -->
                    <entry key="dao">
                        <ref bean="bookDao"/>
                    </entry>
                    <!-- Validator can be a class name or an object from this factory -->
                    <entry key="validator">
                        <ref bean="bookValidator"/>
                    </entry>					
                </map>
                <map>
                    <entry key="ModelConfig">
                        <ref bean="authorConfig"/>
                    </entry>
                    <!-- Doa can be a class name or an object from this factory -->
                    <entry key="dao">
                        <value>com.andreacfm.datax.tests.model.authordao</value>
                    </entry>
                    <!-- Validator can be a class name or an object from this factory -->
                    <entry key="validator">
                        <value>com.andreacfm.datax.tests.model.authorvalidator</value>
                    </entry>
                </map>
            </list>
        </constructor-arg>
    </bean>
    
    <bean id="dsManager" class="com.andreacfm.datax.DsManager" singleton="true" autowire="byName" lazy-init="false">
        
        <constructor-arg name="dataMgr">
            <ref bean="dataMgr"/>
        </constructor-arg>	
        
        <constructor-arg name="dbFactory">
            <ref bean="dbFactory"/>
        </constructor-arg>	
        
        <constructor-arg name="config">
            <list>
                <map>
                    <!-- conventional id -->
                    <entry key="modelConfig">
                        <ref bean="bookConfig"/>
                    </entry>
                    <entry key="decorator">
                        <value>com.andreacfm.datax.tests.model.bookservicedecorator</value>
                    </entry>
                    <entry key="gateway">
                        <value>com.andreacfm.datax.tests.model.bookgateway</value>
                    </entry>
                </map>
                <map>
                    <entry key="id">
                        <value>authorService</value>
                    </entry>
                    <entry key="modelConfig">
                        <ref bean="authorConfig"/>
                    </entry>
                </map>
            </list>
        </constructor-arg>
    </bean>
    
    
</beans>		

