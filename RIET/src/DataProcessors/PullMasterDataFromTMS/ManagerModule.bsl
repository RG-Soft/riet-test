
///////////////////////////////////////////////////////////////////////////////////////////////////////
// CONTACT

Функция ПолучитьРеквизитыContact(ContactGid) Экспорт
	
	// Получает структуру реквизитов контакта из TMS
	
	WSСсылка = ПолучитьWSСсылку();	
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	
	Payload = ПолучитьPayloadForContact(ФабрикаXDTOTMS, ContactGid);	
	GLogXMLElements = CallTMS(WSСсылка, Payload);
	
	Contact = GLogXMLElements[0].Contact;	
	СтруктураContact = Новый Структура("EmailAddress, Phone1, Phone2");
	СтруктураContact.EmailAddress = Contact.EmailAddress;
	СтруктураContact.Phone1 = Contact.Phone1;
	СтруктураContact.Phone2 = Contact.Phone2;
	
	Возврат СтруктураContact;
	
КонецФункции

Функция ПолучитьPayloadForContact(ФабрикаXDTOTMS, ContactGid) Экспорт
	                                                               
	Возврат ПолучитьPayload(ФабрикаXDTOTMS, "Contact", "INT_CONTACT", "CONTACT_GID", "SLB." + ContactGid);
	//Возврат ПолучитьPayload(ФабрикаXDTOTMS, "Contact", "INT_CONTACT_TEST_SAMPLE", "CONTACT_GID", "SLB." + ContactGid);
	
КонецФункции


///////////////////////////////////////////////////////////////////////////////////////////////////////
// LOCATION

Функция ПолучитьРеквизитыLocation(LocationGid) Экспорт
	
	// Получает структуру реквизитов location из TMS
	
	WSСсылка = ПолучитьWSСсылку();	
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	
	Payload = ПолучитьPayloadForLocation(ФабрикаXDTOTMS, LocationGid);	
	GLogXMLElements = CallTMS(WSСсылка, Payload);
	
	LocationNode = GLogXMLElements[0].Location;
	
	СтруктураLocation = Новый Структура("Code, Name, CountryCode, ProcessLevel, City, Address1, Address2, Address3, ContactName, ContactPhone, ContactEmail, Roles");
	
	СтруктураLocation.Code = LocationGid;
	
	СтруктураLocation.Name = СокрЛП(LocationNode.LocationName);
	
	AddressNode = LocationNode.Address;

	СтруктураLocation.CountryCode = СокрЛП(AddressNode.CountryCode3Gid.Gid.Xid);
	
	СтруктураLocation.City = СокрЛП(AddressNode.City);

	AddressLines = AddressNode.AddressLines;
	
	Если AddressLines.Количество() > 0 Тогда
		СтруктураLocation.Address1 = СокрЛП(AddressLines[0].AddressLine);	
	Иначе
		СтруктураLocation.Address1 = "";	
	КонецЕсли;
	
	Если AddressLines.Количество() > 1 Тогда
		СтруктураLocation.Address2 = СокрЛП(AddressLines[1].AddressLine);	
	Иначе
		СтруктураLocation.Address2 = "";	
	КонецЕсли;

	Если AddressLines.Количество() > 2 Тогда
		СтруктураLocation.Address3 = СокрЛП(AddressLines[2].AddressLine);	
	Иначе
		СтруктураLocation.Address3 = "";	
	КонецЕсли;
					
	Если LocationNode.Corporation <> Неопределено Тогда
		СтруктураLocation.ProcessLevel = СокрЛП(LocationNode.Corporation.CorporationGid.Gid.Xid);
	Иначе
		СтруктураLocation.ProcessLevel = Справочники.ProcessLevels.ПустаяСсылка();
	КонецЕсли;
	
	Contacts = LocationNode.Contact;
	Если Contacts.Количество() > 0 Тогда
		
		Contact = Contacts[0];
		СтруктураLocation.ContactName = СокрЛП(СокрЛП(Contact.FirstName) + " " + СокрЛП(Contact.LastName));
		СтруктураLocation.ContactPhone = СокрЛП(Contact.Phone1);
		СтруктураLocation.ContactEmail = СокрЛП(Contact.EMailAddress);
		
	КонецЕсли;
	
	СтруктураLocation.Roles = Новый Массив;
	Для Каждого RoleNode Из LocationNode.LocationRole Цикл
		СтруктураLocation.Roles.Добавить(СокрЛП(RoleNode.LocationRoleGid.Gid.Xid));
	КонецЦикла;	
	
	Возврат СтруктураLocation;
	
КонецФункции

Функция ПолучитьPayloadForLocation(ФабрикаXDTOTMS, LocationGid) Экспорт
	
	Возврат ПолучитьPayload(ФабрикаXDTOTMS,"Location", "INT_LOCATION", "LOCATION_GID", "SLB." + LocationGid);
	
КонецФункции


///////////////////////////////////////////////////////////////////////////////////////////////////////
// ITEM

Функция ПолучитьРеквизитыItem(ItemGid) Экспорт
	
	// Получает структуру реквизитов товара из TMS
	
	WSСсылка = ПолучитьWSСсылку();	
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	
	Payload = ПолучитьPayloadForItem(ФабрикаXDTOTMS, ItemGid);	
	GLogXMLElements = CallTMS(WSСсылка, Payload);
	
	Item = GLogXMLElements[0].ItemMaster.Item;
	СтруктураItem = Новый Структура("Description");
	СтруктураItem.Description = Item.Description;
	
	Возврат СтруктураItem;
	
КонецФункции

Функция ПолучитьPayloadForItem(ФабрикаXDTOTMS, ItemGid) Экспорт
	
	Возврат ПолучитьPayload(ФабрикаXDTOTMS, "ItemMaster", "INT_ITEM", "ITEM_GID", "SLB." + ItemGid);
	
КонецФункции


///////////////////////////////////////////////////////////////////////////////////////////////////////
// RELEASE

Функция ПолучитьReleaseNo(TRNo) Экспорт
	
	// Получает массив Release no. по TR no.
	
	WSСсылка = ПолучитьWSСсылку();	
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	
	Payload = ПолучитьPayloadForReleaseNo(ФабрикаXDTOTMS, TRNo);	
	GLogXMLElements = CallTMS(WSСсылка, Payload);
	
	МассивReleaseNo = Новый Массив;
	Для Каждого GLogXMLElement Из GLogXMLElements Цикл
		МассивReleaseNo.Добавить(GLogXMLElement.Release.ReleaseGid.Gid.Xid);	
	КонецЦикла;
	
	Возврат МассивReleaseNo;
	
КонецФункции

Функция ПолучитьPayloadForReleaseNo(ФабрикаXDTOTMS, TRNo) Экспорт
	
	Возврат ПолучитьPayload(ФабрикаXDTOTMS, "Release", "INT_ORDER_RELEASE", "ORDER_BASE_GID", "SLB." + TRNo);
	
КонецФункции

///////////////////////////////////////////////////////////////////////////////////////////////////////
// SHIPMENT

Функция ПолучитьСтруктуруShipmentNoИStatus(TRNo) Экспорт
	
	// Получает массив Shipment no. по TRNo.
	СтруктураShipmentNoИStatus = Новый Структура();
	
	WSСсылка = ПолучитьWSСсылку();	
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	
	Payload = ПолучитьPayloadForShipmentNo(ФабрикаXDTOTMS, TRNo);	
	GLogXMLElements = CallTMS(WSСсылка, Payload);
	
	МассивShipmentNo = Новый Массив;
	МассивShipmentStatus = Новый Массив;
	
	Для Каждого GLogXMLElement Из GLogXMLElements Цикл
		МассивShipmentNo.Добавить(GLogXMLElement.PlannedShipment.Shipment.ShipmentHeader.ShipmentGid.Gid.Xid);
		МассивShipmentStatus.Добавить(ПолучитьShipmentStatus(GLogXMLElement.PlannedShipment.Shipment.ShipmentHeader));
	КонецЦикла;
	
	СтруктураShipmentNoИStatus.Вставить("МассивShipmentNo", МассивShipmentNo);
	СтруктураShipmentNoИStatus.Вставить("МассивShipmentStatus", МассивShipmentStatus);
	
	Возврат СтруктураShipmentNoИStatus;
	
КонецФункции

Функция ПолучитьPayloadForShipmentNo(ФабрикаXDTOTMS, TRNo) Экспорт
	
	Возврат ПолучитьPayload(ФабрикаXDTOTMS, "PlannedShipment", "INT_OB_SHIPMENT", "ORDER_BASE_GID", "SLB." + TRNo);
	
КонецФункции

Функция ПолучитьShipmentStatus(ShipmentHeader) 
	
	Status = "";
	
	Для Каждого InternalShipmentStatus из ShipmentHeader.InternalShipmentStatus Цикл
		
		StatusType = InternalShipmentStatus.StatusTypeGid.Gid.Xid;
		
		Если StatusType = "SECURE RESOURCES" Тогда 
		   Status = InternalShipmentStatus.StatusValueGid.Gid.Xid;
		   Продолжить;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Status;
	
КонецФункции

///////////////////////////////////////////////////////////////////////////////////////////////////////
// ОБЩЕЕ

Функция ПолучитьWSСсылку() Экспорт
	
	// Возвращает WSСсылку для получения master data из TMS
	// Для продакшн базы используется одна ссылка, для остальных баз - другая
	
	Если РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() Тогда
		Возврат WSСсылки.TMSPullMasterDataProd;
	Иначе
		Возврат WSСсылки.TMSPullMasterDataTest;
	КонецЕсли;
	
КонецФункции

Функция ПолучитьPayload(ФабрикаXDTOTMS, ElementName, IntSavedQueryGidXid, ArgName, ArgValue) 
	
	TransmissionHeader = TMSСервер.ПолучитьTransmissionHeader(ФабрикаXDTOTMS, "QUERY");
	
	TransmissionBody = ПолучитьTransmissionBody(ФабрикаXDTOTMS, ElementName, IntSavedQueryGidXid, ArgName, ArgValue); 
	
	Возврат TMSСервер.ПолучитьPayload(ФабрикаXDTOTMS, TransmissionHeader, TransmissionBody);
	
КонецФункции

Функция ПолучитьTransmissionBody(ФабрикаXDTOTMS, ElementName, IntSavedQueryGidXid, ArgName, ArgValue)
	
	// Получает TransmissionBody типа RemoteQuery
	
	GLogXMLElement = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogXMLElement");
	
	GLogXMLElement.RemoteQuery = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "RemoteQuery");
	
	GLogXMLElement.RemoteQuery.GenericQuery = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GenericQuery");
	GLogXMLElement.RemoteQuery.GenericQuery.ElementName = ElementName;
	
	GLogXMLElement.RemoteQuery.GenericQuery.IntSavedQuery = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "IntSavedQuery");
	GLogXMLElement.RemoteQuery.GenericQuery.IntSavedQuery.IntSavedQueryGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "IntSavedQueryGid");	
	GLogXMLElement.RemoteQuery.GenericQuery.IntSavedQuery.IntSavedQueryGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, IntSavedQueryGidXid);
	GLogXMLElement.RemoteQuery.GenericQuery.IntSavedQuery.IntSavedQueryGid.Gid.DomainName = "SLB";
		
	IntSavedQueryArg = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "IntSavedQueryArg");
	IntSavedQueryArg.ArgName = ArgName;
	IntSavedQueryArg.ArgValue = ArgValue;	
	GLogXMLElement.RemoteQuery.GenericQuery.IntSavedQuery.IntSavedQueryArg.Добавить(IntSavedQueryArg);
	
	GLogXMLElement.RemoteQuery.GenericQuery.IntSavedQuery.IsMultiMatch = "Y";
	
	TransmissionBody = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransmissionBody");
	TransmissionBody.GLogXMLElement.Добавить(GLogXMLElement);
	
	Возврат TransmissionBody;
	
КонецФункции

Функция CallTMS(WSСсылка, Payload)
	
	WSПрокси = СоздатьWSПрокси(WSСсылка);
	
	TransmissionAck = WSПрокси.process(Payload);
		
	Возврат TransmissionAck.QueryResultInfo.GLogXMLElement;
	
КонецФункции

Функция СоздатьWSПрокси(WSСсылка)
	
	// Анализирует WSСсылку и возвращает настроенный WSПрокси, полученной из этой WSСсылки
	
	URIПространстваИмен = "http://xmlns.oracle.com/apps/otm/IntXmlService";
	ИмяСервиса = "IntXmlService";	
	
	Если WSСсылка = WSСсылки.TMSPullMasterDataProd Тогда
		ИмяПорта = "IntXml-xbroker_304_DR";
	ИначеЕсли WSСсылка = WSСсылки.TMSPullMasterDataTest Тогда
		ИмяПорта = "IntXml-QaXBroker_2";
	Иначе
		ВызватьИсключение "Failed to find port for WS reference '" + WSСсылка + "' to query TMS master data!";
	КонецЕсли;
	
	Возврат WSСсылка.СоздатьWSПрокси(URIПространстваИмен, ИмяСервиса, ИмяПорта);
	
КонецФункции
