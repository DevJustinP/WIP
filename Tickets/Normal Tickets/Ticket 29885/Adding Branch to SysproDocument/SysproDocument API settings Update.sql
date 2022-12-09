UPDATE SysproDocument.dbo.Setting
SET SettingDocument = '<Setting Type="Web API" Name="SYSPRO Document Web API" ApplicationId="1" ApplicationCode="SDA" EventLogPrefix="[SD-SDA]">
	<SqlConnection Environment="Production">
		<DataSource>SQL08</DataSource>
		<InitialCatalog>SysproDocument</InitialCatalog>
		<IntegratedSecurity>false</IntegratedSecurity>
		<PersistSecurityInfo>true</PersistSecurityInfo>
		<UserID>{0}</UserID>
		<Password>{1}</Password>
	</SqlConnection>
	<Sources>
		<Source>
			<Name>SuperCat Solutions</Name>
			<IpAddress>166.78.106.84</IpAddress>
			<Endpoint>https://web.summerclassics.com/SuperCat/sales_orders</Endpoint>
			<Authorization>Basic Authentication</Authorization>
			<ActiveDirectory>
				<Group>
					<Name>GWC_SGA_eCat-REST-POST-User</Name>
					<Description>eCat REST POST User</Description>
				</Group>
			</ActiveDirectory>
			<SqlUser>
				<Login>eCatRestPostUser</Login>
				<EncryptedPassword>sBLh3Dgsjx8h5rTo4wQCnMdOA5qywOH6wpXE9oR4Nw4=</EncryptedPassword>
				<PasswordKey>sweep-resort-ethan</PasswordKey>
			</SqlUser>
		</Source>
		<Source>
			<Name>SuperCat RMA Solutions</Name>
			<IpAddress>166.78.106.84</IpAddress>
			<Endpoint>https://web.summerclassics.com/SuperCat/return_requests</Endpoint>
			<Authorization>Basic Authentication</Authorization>
			<ActiveDirectory>
				<Group>
					<Name>GWC_SGA_eCat-REST-POST-User</Name>
					<Description>eCat REST POST User</Description>
				</Group>
			</ActiveDirectory>
			<SqlUser>
				<Login>eCatRestPostUser</Login>
				<EncryptedPassword>sBLh3Dgsjx8h5rTo4wQCnMdOA5qywOH6wpXE9oR4Nw4=</EncryptedPassword>
				<PasswordKey>sweep-resort-ethan</PasswordKey>
			</SqlUser>
		</Source>
		<Source>
			<Name>GWC WordPress</Name>
			<IpAddress>104.207.242.91</IpAddress>
			<Endpoint>https://web.summerclassics.com/SuperCat/rma</Endpoint>
			<Authorization>Basic Authentication</Authorization>
			<ActiveDirectory>
				<Group>
					<Name>GWC_SGA_WordPress-REST-POST-User</Name>
					<Description>WordPress REST POST User</Description>
				</Group>
			</ActiveDirectory>
			<SqlUser>
				<Login>WordPressRestPostUser</Login>
				<EncryptedPassword>SAHg7ZwinFvvwf5MEW+qeP15nDGGWBXmNEVDHUOkbn4=</EncryptedPassword>
				<PasswordKey>nodal-defy-adult</PasswordKey>
			</SqlUser>
		</Source>
	</Sources>
	<SqlException>
		<Failure>
			<ErrorNumber>
				<Minimum>60000</Minimum>
				<Maximum>69999</Maximum>
			</ErrorNumber>
		</Failure>
		<Error>
			<ErrorNumber>
				<Minimum>0</Minimum>
				<Maximum>59999</Maximum>
			</ErrorNumber>
		</Error>
	</SqlException>
	<Event>
		<Success>
			<EventLog>
				<WriteEntry>true</WriteEntry>
				<EventType>(none)</EventType>
			</EventLog>
			<Email>
				<Send>false</Send>
				<Priority>Normal</Priority>
				<IsBodyHtml>true</IsBodyHtml>
				<From>
					<Name>No Reply</Name>
					<Address>No_Reply@summerclassics.com</Address>
				</From>
			</Email>
		</Success>
		<Failure>
			<EventLog>
				<WriteEntry>true</WriteEntry>
				<EventType>Warning</EventType>
			</EventLog>
			<Email>
				<Send>true</Send>
				<Priority>Normal</Priority>
				<IsBodyHtml>true</IsBodyHtml>
				<Recipient Id="1">
					<Type>To</Type>
					<Name>Database Administrator</Name>
					<Address>DatabaseAdministrator@summerclassics.com</Address>
				</Recipient>
				<From>
					<Name>No Reply</Name>
					<Address>No_Reply@summerclassics.com</Address>
				</From>
			</Email>
		</Failure>
		<Error>
			<EventLog>
				<WriteEntry>true</WriteEntry>
				<EventType>Error</EventType>
			</EventLog>
			<Email>
				<Send>true</Send>
				<Priority>Normal</Priority>
				<IsBodyHtml>true</IsBodyHtml>
				<Recipient Id="1">
					<Type>To</Type>
					<Name>Database Administrator</Name>
					<Address>DatabaseAdministrator@summerclassics.com</Address>
				</Recipient>
				<Recipient Id="2">
					<Type>To</Type>
					<Name>Software Developer</Name>
					<Address>SoftwareDeveloper@summerclassics.com</Address>
				</Recipient>
				<From>
					<Name>No Reply</Name>
					<Address>No_Reply@summerclassics.com</Address>
				</From>
			</Email>
		</Error>
		<Information>
			<EventLog>
				<WriteEntry>true</WriteEntry>
				<EventType>Information</EventType>
			</EventLog>
			<Email>
				<Send>true</Send>
				<Priority>Normal</Priority>
				<IsBodyHtml>true</IsBodyHtml>
				<Recipient Id="1">
					<Type>To</Type>
					<Name>Database Administrator</Name>
					<Address>DatabaseAdministrator@summerclassics.com</Address>
				</Recipient>
				<From>
					<Name>No Reply</Name>
					<Address>No_Reply@summerclassics.com</Address>
				</From>
			</Email>
		</Information>
	</Event>
	<Log>
		<KeepDay>365</KeepDay>
	</Log>
	<OrderTypes>
		<OrderType>
			<Type>Confirmed</Type>
			<DocumentStatus>Staged</DocumentStatus>
			<ToBeProcessed>TRUE</ToBeProcessed>
		</OrderType>
		<OrderType>
			<Type>Quote</Type>
			<DocumentStatus>Ignored</DocumentStatus>
			<ToBeProcessed>TRUE</ToBeProcessed>
		</OrderType>
		<OrderType>
			<Type>Unknown</Type>
			<DocumentStatus>Ignored</DocumentStatus>
			<ToBeProcessed>FALSE</ToBeProcessed>
		</OrderType>
	</OrderTypes>
	<Sites>
		<Site>
			<Name>Gabby</Name>
			<FilterOrigin>FALSE</FilterOrigin>
			<EcatOrganizationID>55</EcatOrganizationID>
			<Origin>
				<Name>Gabby</Name>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>220</Branch>
			</Origin>
		</Site>
		<Site>
			<Name>Summer Classics Contract</Name>
			<FilterOrigin>FALSE</FilterOrigin>
			<EcatOrganizationID>88</EcatOrganizationID>
			<Origin>
				<Name>Summer Classics Contract</Name>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>210</Branch>
			</Origin>
		</Site>
		<Site>
			<Name>Summer Classics Retail</Name>
			<EcatOrganizationID>69</EcatOrganizationID>
			<FilterOrigin>TRUE</FilterOrigin>
			<Origin>
				<Name>Pelham Showroom</Name>
				<AltSuffix></AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>301</Branch>
			</Origin>
			<Origin>
				<Name>Pelham Outlet</Name>
				<AltSuffix></AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>302</Branch>
			</Origin>
			<Origin>
				<Name>Atlanta</Name>
				<AltSuffix>Store</AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>303</Branch>
			</Origin>
			<Origin>
				<Name>Charlotte</Name>
				<AltSuffix>Store</AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>304</Branch>
			</Origin>
			<Origin>
				<Name>Raleigh</Name>
				<AltSuffix>Store</AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>305</Branch>
			</Origin>
			<Origin>
				<Name>Nashville</Name>
				<AltSuffix>Store</AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>306</Branch>
			</Origin>
			<Origin>
				<Name>St. Louis</Name>
				<AltSuffix>Store</AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>307</Branch>
			</Origin>
			<Origin>
				<Name>San Antonio</Name>
				<AltSuffix>Store</AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>308</Branch>
			</Origin>
			<Origin>
				<Name>Richmond</Name>
				<AltSuffix>Store</AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>309</Branch>
			</Origin>
			<Origin>
				<Name>Jacksonville</Name>
				<AltSuffix>Store</AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>310</Branch>
			</Origin>
			<Origin>
				<Name>Winter Park</Name>
				<AltSuffix>Store</AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>311</Branch>
			</Origin>
			<Origin>
				<Name>Chestnut Hill</Name>
				<AltSuffix>Store</AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>312</Branch>
			</Origin>
			<Origin>
				<Name>Austin</Name>
				<AltSuffix>Store</AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>313</Branch>
			</Origin>
			<Origin>
				<Name>Atlanta Outlet</Name>
				<AltSuffix></AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>314</Branch>
			</Origin>
		</Site>
		<Site>
			<Name>Summer Classics Wholesale</Name>
			<EcatOrganizationID>87</EcatOrganizationID>
			<FilterOrigin>FALSE</FilterOrigin>
			<Origin>
				<Name>Summer Classics Wholesale</Name>
				<AltSuffix></AltSuffix>
				<DocumentStatus>Active</DocumentStatus>
				<Branch>200</Branch>
			</Origin>
		</Site>
		<Site>
			<Name>Unknown</Name>
			<FilterOrigin>FALSE</FilterOrigin>
			<Origin>
				<Name>Unknown</Name>
				<Active>false</Active>
				<Branch>Unknown</Branch>
			</Origin>
		</Site>
	</Sites>
</Setting>'
where ApplicationId = 1