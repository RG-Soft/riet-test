
//////////////////////////////////////////////////////////////////////////////////////
// ЗАГРУЗКА TRANSPORT REQUEST

// ДОДЕЛАТЬ
Функция ЗагрузитьTransportRequest(TransOrder) Экспорт
	
	// Загружает Export request из XDTO-объекта TransOrder
	// В случае обработанных ошибок - возвращает текст ошибок
	// В случае непредвиденных ошибок - выбрасывает исключения
	// В случае успеха - возвращает пустую строку
	
	// Загружаем только SHIP UNIT INTERNATIONAL
	OrderType = СокрЛП(TransOrder.TransOrderHeader.OrderTypeGid.Gid.Xid);
	Если OrderType <> "ONE TO ONE INTERNATIONAL" 
		И OrderType <> "EQ INTERNATIONAL"
		И OrderType <> "SHIP UNIT INTERNATIONAL" Тогда 
		Возврат "TransOrder with OrderType " + OrderType + " should not be processed via 1C";
	КонецЕсли;
	
	// Сконвертируем структуру XDTO в структуру текстовых значений 
	СтруктураТекстовыхЗначений = ПолучитьСтруктуруТекстовыхЗначений(TransOrder);	
	
	// Если вместо структуры вернулась строка - это ошибки - вернем их
	Если ТипЗнч(СтруктураТекстовыхЗначений) = Тип("Строка") Тогда
		Возврат СтруктураТекстовыхЗначений;
	КонецЕсли;
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	// Создадим объекты
	ExportRequestОбъект = СоздатьОбъекты(СтруктураТекстовыхЗначений);
	
	// Если вернулась строка, а не объект - значит произошли ошибки
	Если ТипЗнч(ExportRequestОбъект) = Тип("Строка") Тогда
		ОтменитьТранзакцию();
		Возврат ExportRequestОбъект;	
	КонецЕсли;
	   
	ЗафиксироватьТранзакцию();
	
	Возврат "";
	              	        
КонецФункции

// СТРУКТУРА ТЕКСТОВЫХ ЗНАЧЕНИЙ

Функция ПолучитьСтруктуруТекстовыхЗначений(TransOrder)
	
	// Возвращает структуру текстовых значений, полученную из объекта XDTO Shipment
	// При возникновении критических ошибок - возвращает текст ошибок
	ТекстОшибок = "";
	
	// Получим структуру текстовых значений шапки Export Request
	СтруктураТекстовыхЗначений = ПолучитьСтруктуруТекстовыхЗначенийExportRequest(TransOrder);
		
	// Если вернулась не структура, а строка - это строка ошибок
	Если ТипЗнч(СтруктураТекстовыхЗначений) = Тип("Строка") Тогда
		ДобавитьВComment(ТекстОшибок, СтруктураТекстовыхЗначений);
	КонецЕсли;

	// Получим структуры текстовых значений parcels, items.
	СтруктурыТекстовыхЗначенийParcels = ПолучитьМассивСтруктурТекстовыхЗначенийParcels(TransOrder);
	 	
	// Если вернулась не структура, а строка - это строка ошибок
	Если ТипЗнч(СтруктурыТекстовыхЗначенийParcels) = Тип("Строка") Тогда
		ДобавитьВComment(ТекстОшибок, СтруктурыТекстовыхЗначенийParcels);
	КонецЕсли;
	
	// Если были ошибки - вернем их
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда
		Возврат СокрЛП(ТекстОшибок);
	КонецЕсли;
	
	СтруктураТекстовыхЗначений.Вставить("Parcels", СтруктурыТекстовыхЗначенийParcels);	
			
	Возврат СтруктураТекстовыхЗначений;
	
КонецФункции

Функция ПолучитьСтруктуруТекстовыхЗначенийExportRequest(TransOrder)
	
	// Возвращает структуру текстовых значений Export Request
	// При возникновении критических ошибок - возвращает текст ошибок
	// При возникновении некритических ошибок - отражает их в свойстве структуры Comments
	
	ТекстОшибок = "";
	
	TransOrderHeader = TransOrder.TransOrderHeader;	
		
	СтруктураЗначений = Новый Структура("TransOrderGid, ReadyToShipDate, RequiredDeliveryDate, PickUpWarehouse_POD, DeliverTo, FromCountry, DestinationCountry, JobNumber, ExternalReference,
	|Incoterms, PayingEntity, AU, Activity, Segment, СтруктураLegalEntity, RechargeFlag, СтруктураRechargeLegalEntity, RechargeAU, RechargeActivity, Consignee, Shipper, 
	|ShipperContact, Requester, Priority, СоответствиеOtherInvolvedPartyLocations, СоответствиеOtherInvolvedPartyContacts, Comments");
	СтруктураЗначений.Comments = "";
	
	// TransOrder Gid 
	Попытка
		СтруктураЗначений.TransOrderGid = СокрЛП(TransOrderHeader.TransOrderGid.Gid.Xid);
	Исключение
		Возврат "Failed to find TransOrder Gid!
			|Path: TransOrder.TransOrderGid.Gid.Xid";
	КонецПопытки;
	
	// Remarks
	Попытка
		ДобавитьВComment(СтруктураЗначений.Comments, СокрЛП(TransOrderHeader.Remark.RemarkText));
	Исключение
	КонецПопытки;

	МассивOrderRefnum = ПолучитьМассивОбъектовXDTO(TransOrderHeader, "OrderRefnum");
	
	// Requester
	Попытка
		Requester = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_REQUESTER").OrderRefnumValue;
		СтруктураЗначений.Requester = СокрЛП(СтрЗаменить(Requester, "SLB.", ""));
	Исключение	
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Requester!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_REQUESTER");
	КонецПопытки;

	// Ready to ship date
	Попытка
		
		ReadyToShipDate = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_PICKUP_DT").OrderRefnumValue;
		Попытка
			СтруктураЗначений.ReadyToShipDate = ПреобразоватьСтрокуВДату(ReadyToShipDate);
		Исключение
			ДобавитьВComment(ТекстОшибок,
			"Failed to convert """ + ReadyToShipDate + """ to Ready to ship date!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_PICKUP_DT");	
		КонецПопытки;
		
	Исключение
		
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Ready to ship date!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_PICKUP_DT");
		
	КонецПопытки;
	
	// Required delivery date
	Попытка
		
		RequiredDeliveryDate = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_DELIVERY_DT").OrderRefnumValue;
		Попытка
			СтруктураЗначений.RequiredDeliveryDate = ПреобразоватьСтрокуВДату(RequiredDeliveryDate);
		Исключение
			ДобавитьВComment(ТекстОшибок,
			"Failed to convert """ + RequiredDeliveryDate + """ to Required delivery date!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_DELIVERY_DT");	
		КонецПопытки;
		
	Исключение
		
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Required delivery date!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_DELIVERY_DT");
		
	КонецПопытки;
	        				
	// From 
	Попытка
		СтруктураЗначений.PickUpWarehouse_POD = СокрЛП(TransOrderHeader.StuffLocation.LocationRef.LocationGid.Gid.Xid);
	Исключение
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Pick-Up Warehouse & POD!
			|Path: TransOrderHeader.StuffLocation.LocationRef.LocationGid.Gid.Xid");
	КонецПопытки;
                      	
	// To 
	Попытка
		СтруктураЗначений.DeliverTo = СокрЛП(TransOrderHeader.DestuffLocation.LocationRef.LocationGid.Gid.Xid);
	Исключение
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Deliver-To!
			|Path: TransOrderHeader.DestuffLocation.LocationRef.LocationGid.Gid.Xid");
	КонецПопытки;
		          		
	// Для удобства сконструируем соответсвие LocationXid -> Location
	Locations = ПолучитьМассивОбъектовXDTO(TransOrder, "Location");
	СоответствиеLocations = ПолучитьСоответствиеLocations(Locations);
	
	// From Country
	SourceLocationDetails = СоответствиеLocations[СтруктураЗначений.PickUpWarehouse_POD];
	Если SourceLocationDetails <> Неопределено Тогда
		Попытка
			СтруктураЗначений.FromCountry = СокрЛП(SourceLocationDetails.Address.CountryCode3Gid.Gid.Xid);
		Исключение
		КонецПопытки;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СтруктураЗначений.FromCountry) Тогда
		ДобавитьВComment(ТекстОшибок,
		"Failed to find Source Country!
		|Path: TransOrder.Location.Address.CountryCode3Gid.Gid.Xid with Location.LocationGid.Gid.Xid = " + СтруктураЗначений.PickUpWarehouse_POD);	
	КонецЕсли;
	
	// Destination Country
	DestinationLocationDetails = СоответствиеLocations[СтруктураЗначений.DeliverTo];
	Если DestinationLocationDetails <> Неопределено Тогда
		Попытка
			СтруктураЗначений.DestinationCountry = СокрЛП(DestinationLocationDetails.Address.CountryCode3Gid.Gid.Xid);
		Исключение
		КонецПопытки;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СтруктураЗначений.DestinationCountry) Тогда
		ДобавитьВComment(ТекстОшибок,
		"Failed to find Destination Country!
		|Path: TransOrder.Location.Address.CountryCode3Gid.Gid.Xid with Location.LocationGid.Gid.Xid = " + СтруктураЗначений.DeliverTo);	
	КонецЕсли;

	// Job Number
	Попытка
		СтруктураЗначений.JobNumber = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_JOB_NO").OrderRefnumValue;
	Исключение
	КонецПопытки;

	//External Reference
	Попытка
		СтруктураЗначений.ExternalReference = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "EXT_REF").OrderRefnumValue;
	Исключение
	КонецПопытки;
	
	// Incoterms
	Попытка
		СтруктураЗначений.Incoterms = СокрЛП(TransOrderHeader.CommercialTerms.IncoTermGid.Gid.Xid);
	Исключение
	КонецПопытки;

	// Finance Information
	ЗаполнитьFinanceInformationСтруктурыТекстовыхЗначенийExportRequest(СтруктураЗначений, МассивOrderRefnum, ТекстОшибок);
	
	// Involved Party
	
	// Для удобства сконструируем соответствие Involved party qualifier -> Involved party
	InvolvedParties = ПолучитьМассивОбъектовXDTO(TransOrderHeader, "InvolvedParty");
	
	Для Каждого Location из TransOrder.Location Цикл 
		LocationInvolvedParties = ПолучитьМассивОбъектовXDTO(Location.Corporation, "InvolvedParty");	
		InvolvedParties = РГСофтКлиентСервер.СложитьМассивы(InvolvedParties, LocationInvolvedParties);
	КонецЦикла;	
	
	СоответствиеInvolvedParties = ПолучитьСоответствиеInvolvedParties(InvolvedParties);	
	
	// Consignee
	Попытка
		Consignee = СоответствиеInvolvedParties["CONSIGNEE"];
		СтруктураЗначений.Consignee = СокрЛП(Consignee.InvolvedPartyLocationRef.LocationRef.LocationGid.Gid.Xid);
		СоответствиеInvolvedParties.Удалить("CONSIGNEE");
	Исключение	
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Consignee!
			|Path: InvolvedPartyLocationRef.LocationRef.LocationGid.Gid.Xid with InvolvedParty.InvolvedPartyQualifierGid.Gid.Xid = CONSIGNEE");
	КонецПопытки;	
	        	
	// Shipper
	Попытка
		Shipper = СоответствиеInvolvedParties["EXPORTER"];
		СтруктураЗначений.Shipper = СокрЛП(Shipper.InvolvedPartyLocationRef.LocationRef.LocationGid.Gid.Xid);
		СоответствиеInvolvedParties.Удалить("EXPORTER");
	Исключение	
		//ДобавитьВComment(ТекстОшибок,
		//	"Failed to find Shipper!
		//	|Path: InvolvedPartyLocationRef.LocationRef.LocationGid.Gid.Xid with InvolvedParty.InvolvedPartyQualifierGid.Gid.Xid = EXPORTER");
	КонецПопытки;
	
	// Shipper contact 
	Попытка
		ShipperContact = СоответствиеInvolvedParties["ORIGIN_SLS"];
		СтруктураЗначений.ShipperContact = СокрЛП(ShipperContact.ContactRef.Contact.ContactGid.Gid.Xid);
		СоответствиеInvolvedParties.Удалить("ORIGIN_SLS");
	Исключение	
		//ДобавитьВComment(ТекстОшибок,
		//	"Failed to find Shipper contact!
		//	|Path: ContactRef.Contact.ContactGid.Gid.Xid with InvolvedParty.InvolvedPartyQualifierGid.Gid.Xid = ORIGIN_SLS");
	КонецПопытки;

	// Requestor
	//Попытка
	//	Requestor = СоответствиеInvolvedParties["OB_REQUESTER"];
	//	СтруктураЗначений.RequestorEmail = СокрЛП(Requestor.ContactRef.Contact.EmailAddress);
	//	СоответствиеInvolvedParties.Удалить("OB_REQUESTER");
	//Исключение	
	//	ДобавитьВComment(ТекстОшибок,
	//		"Failed to find Requestor Email!
	//		|Path: ContactRef.Contact.EmailAddress with InvolvedParty.InvolvedPartyQualifierGid.Gid.Xid = REQUESTER");
	//КонецПопытки;
	
	// Priority
	Попытка
		СтруктураЗначений.Priority = СокрЛП(TransOrderHeader.OrderPriority);
	Исключение	
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Priority!
			|Path: TransOrderHeader.OrderPriority");
	КонецПопытки;
	
	// Other locations & contacts
	                                
	СоответствиеOtherInvolvedPartyLocations = Новый Соответствие();
	СоответствиеOtherInvolvedPartyContacts = Новый Соответствие();
	Для Каждого OtherInvolvedParty из СоответствиеInvolvedParties Цикл
		
		Попытка
			СоответствиеOtherInvolvedPartyContacts.Вставить(OtherInvolvedParty.Ключ, OtherInvolvedParty.Значение.InvolvedPartyLocationRef.LocationGid.Xid);
		Исключение	
		КонецПопытки;

		Попытка
			СоответствиеOtherInvolvedPartyContacts.Вставить(OtherInvolvedParty.Ключ, OtherInvolvedParty.Значение.ContactRef.Contact.ContactGid.Gid.Xid);
		Исключение	
		КонецПопытки;
				
	КонецЦикла;	
	
	СтруктураЗначений.СоответствиеOtherInvolvedPartyLocations = СоответствиеOtherInvolvedPartyLocations;
	СтруктураЗначений.СоответствиеOtherInvolvedPartyContacts = СоответствиеOtherInvolvedPartyContacts;
	
	Возврат ?(ЗначениеЗаполнено(ТекстОшибок), ТекстОшибок, СтруктураЗначений);
	 	
КонецФункции

Процедура ЗаполнитьFinanceInformationСтруктурыТекстовыхЗначенийExportRequest(СтруктураЗначений, МассивOrderRefnum, ТекстОшибок)
	
	// Finance Information
	
	// Paying entity
	Попытка
		СтруктураЗначений.PayingEntity = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_PAYING_ENTITY").OrderRefnumValue; 
	Исключение
	КонецПопытки;

	Если НЕ ЗначениеЗаполнено(СтруктураЗначений.PayingEntity) Тогда
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Paying entity!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_PAYING_ENTITY");
	КонецЕсли;	 
	
	// Структура Legal entity
	
	СтрокаСвойствLegalEntity = "CompanyCode, CountryCode, ERPID, FinanceLocCode, FinanceProcess";
	СтруктураLegalEntity = Новый Структура(СтрокаСвойствLegalEntity);
		
	Попытка
		СтруктураLegalEntity.CompanyCode = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_LEGAL_ENTITY").OrderRefnumValue;
	Исключение
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Company code of Legal entity!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_LEGAL_ENTITY");
	КонецПопытки;	
	
	Попытка
		СтруктураLegalEntity.CountryCode = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_COUNTRY_CODE").OrderRefnumValue;
	Исключение
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Country code of Legal entity!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_COUNTRY_CODE");
	КонецПопытки;
	
	Попытка
		СтруктураLegalEntity.ERPID = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_ERP_ID").OrderRefnumValue;
	Исключение
		ДобавитьВComment(ТекстОшибок,
			"Failed to find ERP ID of Legal entity!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_ERP_ID");
	КонецПопытки;

	Попытка
		СтруктураLegalEntity.FinanceLocCode = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_FIN_LOC_CODE").OrderRefnumValue;
	Исключение
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Finance loc code of Legal entity!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_FIN_LOC_CODE");
	КонецПопытки;

	Попытка
		СтруктураLegalEntity.FinanceProcess = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_FIN_PROCESS").OrderRefnumValue;
	Исключение
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Finance process of Legal entity!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_FIN_PROCESS");
	КонецПопытки;

	СтруктураЗначений.СтруктураLegalEntity = СтруктураLegalEntity;
	
	// Segment	
	Попытка
		СтруктураЗначений.Segment = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_SEGMENT").OrderRefnumValue;
	Исключение
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Segment!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_SEGMENT");
	КонецПопытки;

	// AU	
	Попытка
		СтруктураЗначений.AU = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_COST_CENTER").OrderRefnumValue;
	Исключение
		ДобавитьВComment(ТекстОшибок,
			"Failed to find AU!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_COST_CENTER");
	КонецПопытки;

	// Activity
	Попытка
		СтруктураЗначений.Activity = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_ACT_CODE").OrderRefnumValue;
	Исключение
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Activity!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_ACT_CODE");
	КонецПопытки;
	
	// Recharge Flag
	Попытка
		СтруктураЗначений.RechargeFlag = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_RECHARGE_FLAG").OrderRefnumValue;
	Исключение
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Recharge flag!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_RECHARGE_FLAG");
	КонецПопытки;
	
	//RechargeFlag, СтруктураRechargeLegalEntity, RechargeSegment, RechargeAU, RechargeActivity
	Если ЗначениеЗаполнено(СтруктураЗначений.RechargeFlag) И СтруктураЗначений.RechargeFlag = "I" Тогда
		
		СтруктураRechargeLegalEntity = Новый Структура(СтрокаСвойствLegalEntity);
		
		Попытка
			СтруктураRechargeLegalEntity.CompanyCode = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_R_LEGAL_ENTITY").OrderRefnumValue;
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Company code of Recharge legal entity!
				|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_R_LEGAL_ENTITY");
		КонецПопытки;	
		
		Попытка
			СтруктураRechargeLegalEntity.CountryCode = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_R_COUNTRY_CODE").OrderRefnumValue;
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Country code of Recharge legal entity!
				|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_R_COUNTRY_CODE");
		КонецПопытки;
		
		Попытка
			СтруктураRechargeLegalEntity.ERPID = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_R_ERP_ID").OrderRefnumValue;
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to find ERP ID of Rechage legal entity!
				|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_R_ERP_ID");
		КонецПопытки;

		Попытка
			СтруктураRechargeLegalEntity.FinanceLocCode = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_R_FIN_LOC_CODE").OrderRefnumValue;
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Finance loc code of Recharge legal entity!
				|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_R_FIN_LOC_CODE");
		КонецПопытки;

		Попытка
			СтруктураRechargeLegalEntity.FinanceProcess = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_R_FIN_PROCESS").OrderRefnumValue;
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Finance process of Recharge legal entity!
				|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_R_FIN_PROCESS");
		КонецПопытки;
			
		СтруктураЗначений.СтруктураRechargeLegalEntity = СтруктураRechargeLegalEntity;
		
		// Recharge to segment	
		Попытка
			RechargeSegment = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_R_SEGMENT").OrderRefnumValue;
			ДобавитьВComment(СтруктураЗначений.Comments, "Destination segment: " + RechargeSegment);
		Исключение
		КонецПопытки;
		
		// Recharge AU	
		Попытка
			СтруктураЗначений.RechargeAU = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_R_COST_CENTER").OrderRefnumValue;
		Исключение
			ДобавитьВComment(ТекстОшибок,
			"Failed to find Recharge AU!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_R_COST_CENTER");
		КонецПопытки;
		
		// Recharge Activity
		Попытка
			СтруктураЗначений.RechargeActivity = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_R_ACT_CODE").OrderRefnumValue;
		Исключение
			ДобавитьВComment(ТекстОшибок,
			"Failed to find Recharge Activity!
			|Path: TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid = OB_R_ACT_CODE");
		КонецПопытки;
				
	КонецЕсли;		
	 		 	
КонецПроцедуры

Функция ПолучитьМассивСтруктурТекстовыхЗначенийParcels(TransOrder)
	
	МассивСтруктур = Новый Массив;
	ТекстОшибокParcel = "";
	      	
	// Попробуем получить массив Ship units
	ShipUnits = ПолучитьМассивОбъектовXDTO(TransOrder.ShipUnitDetail, "ShipUnit");
	
	Если ShipUnits.Количество() = 0 Тогда
		Возврат "Failed to find Ship unit!
		|Path: TransOrder.ShipUnitDetail.ShipUnit";
	КонецЕсли;
	
	НомерПП = 0;
	Для Каждого ShipUnit из ShipUnits Цикл 
		
		ТекстОшибок = "";
		НомерПП = НомерПП + 1;
		
		СтруктураЗначений = Новый Структура(
		"PackingType, NumOfParcels, Length, Width, Height, DIMsUOM, GrossWeight, WeightUOM, ERPTreatment, SerialNo, ParcelLines");
		
		Префикс = "For Ship unit: " + НомерПП + ":";
		Попытка
			ShipUnitNo = СокрЛП(ShipUnit.ShipUnitGid.Gid.Xid);
			Префикс = "For Ship unit: " + ShipUnitNo + ":";
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Ship unit no.!
				|Path: ShipUnit.ShipUnitGid.Gid.Xid");
		КонецПопытки;
		
		//Packing type
		Попытка
			СтруктураЗначений.PackingType = СокрЛП(ShipUnit.TransportHandlingUnitRef.ShipUnitSpecRef.ShipUnitSpecGid.Gid.Xid);
		Исключение
			ДобавитьВComment(ТекстОшибок,
			"Failed to find Ship unit Transport Handling Unit!
			|Path: ShipUnit.TransportHandlingUnitRef.ShipUnitSpecRef.ShipUnitSpecGid.Gid.Xid");
		КонецПопытки;
		
		//Num. of parcels
		Попытка
			СтруктураЗначений.NumOfParcels = СокрЛП(ShipUnit.ShipUnitCount);
		Исключение
			ДобавитьВComment(ТекстОшибок,
			"Failed to find Ship unit count!
			|Path: ShipUnit.TransportHandlingUnitRef.ShipUnitSpecRef.ShipUnitSpecGid.Gid.Xid");
		КонецПопытки;
			    					
		//Legnth Width Height
		LengthWidthHeight = ПолучитьСвойствоВладельцаXDTO(ShipUnit, "LengthWidthHeight");
		
		Если LengthWidthHeight = Неопределено Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Dimensions!
				|Path: ShipUnit.LengthWidthHeight");
		Иначе 
			
			//Length
			Попытка
				СтруктураЗначений.Length = СокрЛП(LengthWidthHeight.Length.LengthValue);
			Исключение
			КонецПопытки;
			
			Если НЕ ЗначениеЗаполнено(СтруктураЗначений.Length) Тогда
				ДобавитьВComment(ТекстОшибок,
				"Failed to find Length!
				|Path: ShipUnit.LengthWidthHeight.Length.LengthValue");	
			КонецЕсли;
			
			LengthUOM = Неопределено;
			Попытка
				LengthUOM = СокрЛП(LengthWidthHeight.Length.LengthUOMGid.Gid.Xid);	
			Исключение
			КонецПопытки;
			
			Если НЕ ЗначениеЗаполнено(LengthUOM) Тогда
				ДобавитьВComment(ТекстОшибок,
				"Failed to find Length UOM!
				|Path: ShipUnit.LengthWidthHeight.Length.LengthUOMGid.Gid.Xid");	
			КонецЕсли;
			
			//Width
			Попытка
				СтруктураЗначений.Width = СокрЛП(LengthWidthHeight.Width.WidthValue);
			Исключение
			КонецПопытки;
			
			Если НЕ ЗначениеЗаполнено(СтруктураЗначений.Width) Тогда
				ДобавитьВComment(ТекстОшибок,
				"Failed to find Width!
				|Path: ShipUnit.LengthWidthHeight.Width.WidthValue");	
			КонецЕсли;
			
			WidthUOM = Неопределено;
			Попытка
				WidthUOM = СокрЛП(LengthWidthHeight.Width.WidthUOMGid.Gid.Xid);
			Исключение
			КонецПопытки;
			
			Если НЕ ЗначениеЗаполнено(WidthUOM) Тогда
				ДобавитьВComment(ТекстОшибок,
				"Failed to find Width UOM!
				|Path: ShipUnit.LengthWidthHeight.Width.WidthUOMGid.Gid.Xid");	
			КонецЕсли;
			
			//Height
			Попытка
				СтруктураЗначений.Height = СокрЛП(LengthWidthHeight.Height.HeightValue);
			Исключение
			КонецПопытки;
			
			Если НЕ ЗначениеЗаполнено(СтруктураЗначений.Height) Тогда
				ДобавитьВComment(ТекстОшибок,
				"Failed to find Height!
				|Path: ShipUnit.LengthWidthHeight.Height.HeightValue");	
			КонецЕсли;
			
			HeightUOM = Неопределено;
			Попытка
				HeightUOM = СокрЛП(LengthWidthHeight.Height.HeightUOMGid.Gid.Xid);
			Исключение
			КонецПопытки;
			
			Если НЕ ЗначениеЗаполнено(HeightUOM) Тогда
				ДобавитьВComment(ТекстОшибок,
				"Failed to find Height UOM!
				|Path: ShipUnit.LengthWidthHeight.Height.HeightUOMGid.Gid.Xid");	
			КонецЕсли;
			
			//DIMs UOM
			Если LengthUOM = WidthUOM И LengthUOM = HeightUOM Тогда
				СтруктураЗначений.DIMsUOM = LengthUOM;
			Иначе
				ДобавитьВComment(ТекстОшибок,
				"Length UOM """ + LengthUOM + """ differs from Width UOM """ + WidthUOM + """ or Height UOM """ + HeightUOM + "!");
			КонецЕсли;
			 			
		КонецЕсли;
			
		//Total gross weight
		Попытка
			СтруктураЗначений.GrossWeight = СокрЛП(ShipUnit.WeightVolume.Weight.WeightValue);
		Исключение
		КонецПопытки;
		
		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.GrossWeight) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Gross weight!
				|Path: ShipUnit.WeightVolume.Weight.WeightValue");	
		КонецЕсли;
		
		//Weight UOM
		Попытка
			СтруктураЗначений.WeightUOM = СокрЛП(ShipUnit.WeightVolume.Weight.WeightUOMGid.Gid.Xid);
		Исключение
		КонецПопытки;
	
		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.WeightUOM) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Gross weight UOM!
				|Path: ShipUnit.WeightVolume.Weight.WeightUOMGid.Gid.Xid");	
		КонецЕсли;
		
		// Serial No
		Попытка
			СтруктураЗначений.SerialNo = СокрЛП(ShipUnit.TagInfo.ItemTag1);
		Исключение
		КонецПопытки;
	
		// Items ERP treatment
		Попытка
			СтруктураЗначений.ERPTreatment = СокрЛП(ShipUnit.TagInfo.ItemTag3);
		Исключение
		КонецПопытки;
	
		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.ERPTreatment) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find ERP treatment!
				|Path: ShipUnit.TagInfo.ItemTag3");	
		КонецЕсли;
				
		// Parcel lines
		ParcelLines = ПолучитьМассивParcelLines(ShipUnit);
		Если ТипЗнч(ParcelLines) = Тип("Строка") Тогда
			ДобавитьВComment(ТекстОшибок, ParcelLines);
		Иначе
			СтруктураЗначений.ParcelLines = ParcelLines;
		КонецЕсли;
		
		МассивСтруктур.Добавить(СтруктураЗначений);
		
		Если ЗначениеЗаполнено(ТекстОшибок) Тогда
			ДобавитьВComment(ТекстОшибокParcel, СокрЛП(Префикс + Символы.ПС + ТекстОшибок));	
		КонецЕсли;
	
	КонецЦикла;
	
	Если ЗначениеЗаполнено(ТекстОшибокParcel) Тогда
		Возврат	ТекстОшибокParcel;	
	КонецЕсли;
 	
	Возврат МассивСтруктур;
	
КонецФункции

Функция ПолучитьМассивParcelLines(ShipUnit)
	
	МассивParcelLines = Новый Массив;
	ТекстОшибокParcelLines = "";
	            	
	ShipUnitContents = ПолучитьМассивОбъектовXDTO(ShipUnit, "ShipUnitContent");
	
	Если ShipUnitContents.Количество() = 0 Тогда
		Возврат "Failed to find Ship unit content!
		|Path: ShipUnit.ShipUnitContent";
	КонецЕсли;
	
	НомерСтроки = 0;
	Для Каждого ShipUnitContent из ShipUnitContents Цикл 
		
		ТекстОшибок = "";
		НомерСтроки = НомерСтроки + 1;
		
		СтруктураЗначений = Новый Структура(
		"LineNumber, PONo, PartNo, Description, SerialNo, QTY, QtyUOM, RAN, CountryOfOrigin, Currency, TotalPrice, NetWeight, NetWeightUOM");	
		
		// Line Number   
		Префикс = "For Ship unit content: " + НомерСтроки + ":";
		Попытка
			СтруктураЗначений.LineNumber = СокрЛП(ShipUnitContent.LineNumber);
			Префикс = "For Ship unit content: " + СтруктураЗначений.LineNumber + ":";
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Line number!
				|Path: ShipUnit.ShipUnitGid.Gid.Xid");
		КонецПопытки;
		
		// PO No
		ShipUnitLineRefnums = ПолучитьМассивОбъектовXDTO(ShipUnitContent, "ShipUnitLineRefnum"); 
		Для Каждого ShipUnitLineRefnum из ShipUnitLineRefnums Цикл
			
			Попытка
				Если ShipUnitLineRefnum.ShipUnitLineRefnumQualifierGid.Gid.Xid = "SLB_PO_NUMBER" Тогда 
					СтруктураЗначений.PONo = ShipUnitLineRefnum.ShipUnitLineRefnumValue;
				КонецЕсли;
			Исключение
			КонецПопытки;
			
		КонецЦикла;
			
		// Part No   
		Попытка                               
			СтруктураЗначений.PartNo = СокрЛП(ShipUnitContent.PackagedItemRef.PackagedItem.Packaging.PackagedItemGid.Gid.Xid);
		Исключение
			ДобавитьВComment(ТекстОшибок,
			"Failed to find Part no.!
			|Path: ShipUnitContent.PackagedItemRef.PackagedItem.Packaging.PackagedItemGid.Gid.Xid");
		КонецПопытки;
		
		// Description
		Попытка                               
			СтруктураЗначений.Description = СокрЛП(ShipUnitContent.PackagedItemRef.PackagedItem.Item.Description);
		Исключение
			ДобавитьВComment(ТекстОшибок,
			"Failed to find Description!
			|Path: ShipUnitContent.PackagedItemRef.PackagedItem.Item.Description");	
		КонецПопытки;
		
		// Serial number
		Попытка                               
			СтруктураЗначений.SerialNo = СокрЛП(ShipUnitContent.ItemQuantity.ItemTag1);
		Исключение
		КонецПопытки;

		// QTY
		Попытка                               
			СтруктураЗначений.QTY = СокрЛП(ShipUnitContent.ItemQuantity.PackagedItemCount);
		Исключение
			ДобавитьВComment(ТекстОшибок,
			"Failed to find Item Count!
			|Path: ShipUnitContent.ItemQuantity.PackagedItemCount");
		КонецПопытки;
		
		// QTY Uom
		Попытка                               
			СтруктураЗначений.QtyUOM = СокрЛП(ShipUnitContent.PackagedItemSpecRef.ShipUnitSpecRef.ShipUnitSpecGid.Gid.Xid);
		Исключение
			ДобавитьВComment(ТекстОшибок,
			"Failed to find Qty UOM!
			|Path: ShipUnitContent.PackagedItemSpecRef.ShipUnitSpecRef.ShipUnitSpecGid.Gid.Xid");
		КонецПопытки;
		
		// RAN
		Попытка
		СтруктураЗначений.RAN = СокрЛП(ShipUnitContent.ItemQuantity.ItemTag2);
		Исключение
		КонецПопытки;
		
		// COO
		Попытка
			СтруктураЗначений.CountryOfOrigin = СокрЛП(ShipUnitContent.ItemQuantity.ItemTag4);
		Исключение
			ДобавитьВComment(ТекстОшибок,
			"Failed to find Qty UOM!
			|Path: ShipUnitContent.ItemQuantity.ItemTag4");
		КонецПопытки;
		
		//Currency
		Попытка
			СтруктураЗначений.Currency = СокрЛП(ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount.GlobalCurrencyCode);
		Исключение
			ДобавитьВComment(ТекстОшибок,
			"Failed to find Currency!
			|Path: ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount.GlobalCurrencyCode");	
		КонецПопытки;

        //Total Price
		Попытка
			СтруктураЗначений.TotalPrice = СокрЛП(ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount.MonetaryAmount);
		Исключение
			ДобавитьВComment(ТекстОшибок,
			"Failed to find Total Price!
			|Path: ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount.MonetaryAmount");
		КонецПопытки;

		//Net Weight & Net Weight UOM
		Попытка
			СтруктураЗначений.NetWeight = СокрЛП(ShipUnitContent.ItemQuantity.WeightVolume.Weight.WeightValue);
			СтруктураЗначений.NetWeightUOM = СокрЛП(ShipUnitContent.ItemQuantity.WeightVolume.Volume.VolumeUOMGid.Gid.Xid);
		Исключение
		КонецПопытки;
		
		Если ЗначениеЗаполнено(ТекстОшибок) Тогда
			ДобавитьВComment(ТекстОшибокParcelLines, СокрЛП(Префикс + Символы.ПС + ТекстОшибок));	
		КонецЕсли;

		МассивParcelLines.Добавить(СтруктураЗначений);
		
	КонецЦикла;
	
	Если ЗначениеЗаполнено(ТекстОшибокParcelLines) Тогда
		Возврат ТекстОшибокParcelLines;	
	КонецЕсли;
	
	Возврат МассивParcelLines;
	
КонецФункции

Функция ПолучитьСвойствоВладельцаXDTO(ВладелецЭлементаXDTO, ИмяСвойства)
	
	Попытка
		Возврат ВладелецЭлементаXDTO[ИмяСвойства];
	Исключение		
		Возврат Неопределено;
	КонецПопытки;
	     	 		
КонецФункции

Функция ПолучитьМассивОбъектовXDTO(ВладелецЭлементаXDTO, ИмяЭлементаXDTO)
	
	МассивЭлементов = Новый Массив;
	
	ЭлементXDTO = ПолучитьСвойствоВладельцаXDTO(ВладелецЭлементаXDTO, ИмяЭлементаXDTO);
	
	Если ЭлементXDTO = Неопределено Тогда 
		Возврат МассивЭлементов;
	КонецЕсли;
	
	Если ТипЗнч(ЭлементXDTO) = Тип("ОбъектXDTO") Тогда 
		МассивЭлементов.Добавить(ЭлементXDTO);
	Иначе
		Для Каждого ЭлементСписка из ЭлементXDTO Цикл 
			МассивЭлементов.Добавить(ЭлементСписка);
		КонецЦикла;
	КонецЕсли;
	
	Возврат МассивЭлементов;
	
КонецФункции

Функция ПолучитьСоответствиеLocations(Locations)
	
	// Принимает список объектов xdto locations
	// Возвращает соответствие, где ключ - LocationXid, а значение - объект xdto location
	
	Соответствие = Новый Соответствие;
	
	Для Каждого Location Из Locations Цикл
		
		Попытка
			LocationXid = СокрЛП(Location.LocationGid.Gid.Xid);
		Исключение
			Продолжить;
		КонецПопытки;

		Соответствие.Вставить(LocationXid, Location);
		
	КонецЦикла;
	
	Возврат Соответствие;
	
КонецФункции

Функция ПолучитьСоответствиеInvolvedParties(InvolvedParties)
	
	// Принимает список объектов xdto Involved parites
	// Возвращает соответствие, где ключ - Involved party qualifier, а значение - объект xdto Involved party
	
	Соответствие = Новый Соответствие;
	
	Для Каждого InvolvedParty Из InvolvedParties Цикл
		
		Попытка
			InvolvedPartyQualifier = СокрЛП(InvolvedParty.InvolvedPartyQualifierGid.Gid.Xid);
		Исключение
			Продолжить;
		КонецПопытки;

		Соответствие.Вставить(InvolvedPartyQualifier, InvolvedParty);
		
	КонецЦикла;
	
	Возврат Соответствие;
	
КонецФункции

Процедура ДобавитьВComment(Comments, НовыйComment, Разделитель=Неопределено)
	
	Если Разделитель = Неопределено Тогда
		Разделитель = Символы.ПС + Символы.ПС;
	КонецЕсли;
	
	Comments = Comments + Разделитель + НовыйComment;
			  
КонецПроцедуры

Процедура ДобавитьВСтрокуЕслиЗаполнено(ИсходнаяСтрока, Добавление, Разделитель=Неопределено)
	
	Если НЕ ЗначениеЗаполнено(Добавление) Тогда
		Возврат;
	КонецЕсли;
	
	ДобавитьВComment(ИсходнаяСтрока, Добавление, Разделитель);
	
КонецПроцедуры

Функция ПреобразоватьСтрокуВДату(Знач стрЗначение)
	
	Если НЕ ЗначениеЗаполнено(стрЗначение) Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	стрЗначение = СтрЗаменить(стрЗначение, "-", "");
	стрЗначение = СтрЗаменить(стрЗначение, ":", "");
	стрЗначение = СтрЗаменить(стрЗначение, " ", "");
	
	Значение = Дата(стрЗначение);	
		
	Возврат Значение;
		
КонецФункции

Функция ПолучитьOrderRefnumИзМассива(Массив, ИскомыйQualifier)
	
	Для Каждого OrderRefnum Из Массив Цикл
		
		Попытка
			Qualifier = OrderRefnum.OrderRefnumQualifierGid.Gid.Xid;
		Исключение
			Продолжить;	
		КонецПопытки;
		
		Если Qualifier = ИскомыйQualifier Тогда
			Возврат OrderRefnum;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

//////////////////////////////////////////////////////////////////////////////////////
// СОЗДАНИЕ ОБЪЕКТОВ БАЗЫ

Функция СоздатьОбъекты(СтруктураЗначений) 
	
	ТекстОшибок = "";
	
	ERОбъект = Документы.ExportRequest.НайтиПоРеквизиту("TMSTransOrderGid", СтруктураЗначений.TransOrderGid);
	
	Если ЗначениеЗаполнено(ERОбъект) Тогда
		Возврат "Export request " + СокрЛП(ERОбъект.Номер) + " has already been loaded from TMS TransOrder " + СокрЛП(СтруктураЗначений.TransOrderGid) + "!";	
	КонецЕсли;
	
	ERОбъект = Документы.ExportRequest.СоздатьДокумент();
	
	ERОбъект.TMSTransOrderGid = СокрЛП(СтруктураЗначений.TransOrderGid);
	
	ERОбъект.ДополнительныеСвойства.Вставить("LoadingFromTMS");
	
	// Submitter
	Submitter = Справочники.Пользователи.НайтиПоКоду(СтруктураЗначений.Requester);
	Если НЕ ЗначениеЗаполнено(Submitter) Тогда
		Submitter = Справочники.Пользователи.СоздатьTrackerПоEmail(СтруктураЗначений.Requester + "@slb.com");	
	КонецЕсли;
	ERОбъект.Submitter = Submitter;
	
	ERОбъект.Submitted = ТекущаяДата();
	
	// Дата
	ERОбъект.Дата = ТекущаяДата();
	
	// Comments
	ERОбъект.Comments = СтруктураЗначений.Comments;
	
	// From country
	FromCountry = ImportExportСерверПовтИспСеанс.ПолучитьRCACountryПоTMSID(СтруктураЗначений.FromCountry);
	Если ЗначениеЗаполнено(FromCountry) Тогда
		ERОбъект.FromCountry = FromCountry;	
	Иначе
		ДобавитьСтроку(ТекстОшибок, "Failed to find Source country by TMS ID """ + СтруктураЗначений.FromCountry + """!");
	КонецЕсли;
	
	// Custom Union Transaction
	Если (СтруктураЗначений.FromCountry = "RUS" И СтруктураЗначений.DestinationCountry = "KAZ") 
		ИЛИ (СтруктураЗначений.FromCountry = "KAZ" И СтруктураЗначений.DestinationCountry = "RUS") Тогда
		ERОбъект.CustomUnionTransaction = Истина;
	КонецЕсли;
	
	// Legal entity
	СтруктураLegalEntity = СтруктураЗначений.СтруктураLegalEntity;
	FromLegalEntity = ImportExportСерверПовтИспСеанс.ПолучитьLegalEntityПоРеквизитамTMS(
	СтруктураLegalEntity.CompanyCode,
	СтруктураLegalEntity.CountryCode,
	СтруктураLegalEntity.ERPID,
	СтруктураLegalEntity.FinanceLocCode,
	СтруктураLegalEntity.FinanceProcess);
	
	// Legal entity, Company
	Если ЗначениеЗаполнено(FromLegalEntity) Тогда
		
		ERОбъект.FromLegalEntity = FromLegalEntity;
		
		ParentCompany = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(FromLegalEntity, "ParentCompany");
		Если ЗначениеЗаполнено(ParentCompany) Тогда
			ERОбъект.Company = ParentCompany;
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Parent company is empty in Legal entity """ + FromLegalEntity + """!");
		КонецЕсли;
		
	Иначе
		ДобавитьСтроку(ERОбъект.Comments, "! Failed to find TMS Legal entity by Company code """ + СтруктураLegalEntity.CompanyCode + 
		""", Country code """ + СтруктураLegalEntity.CountryCode + """, ERP ID """ + СтруктураLegalEntity.ERPID + 
		""", Finance loc code """ + СтруктураLegalEntity.FinanceLocCode + """ and Finance process """ 
		+ СтруктураLegalEntity.FinanceProcess + """!");	
	КонецЕсли;
	
	// AU
	Если ЗначениеЗаполнено(СтруктураЗначений.AU) Тогда
		
		AU = РГСофт.НайтиAU(ERОбъект.Дата, СтруктураЗначений.AU);
		Если ЗначениеЗаполнено(AU) Тогда
			ERОбъект.AU = AU;
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find AU by code """ + СтруктураЗначений.AU + """!");			
		КонецЕсли;
		
	КонецЕсли;
	
	// Segment
	Segment = Справочники.Сегменты.НайтиПоКоду(СтруктураЗначений.Segment);
	Если ЗначениеЗаполнено(Segment) Тогда
		
		ERОбъект.Segment = Segment;
		
		AUSegment = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(AU, "Segment");
		Если AUSegment <> Segment Тогда
			ДобавитьСтроку(ERОбъект.Comments, "! Segment in AU differs from Segment in TR """ + СтруктураЗначений.Segment + """!");			
		КонецЕсли;
		
	Иначе
		ДобавитьСтроку(ERОбъект.Comments, "! Failed to find AU by code """ + СтруктураЗначений.AU + """!");			
	КонецЕсли;
	
	// Activity
	Если ЗначениеЗаполнено(СтруктураЗначений.Activity) Тогда
		ERОбъект.Activity = СтруктураЗначений.Activity;
	КонецЕсли;
	
	// External reference
	Если ЗначениеЗаполнено(СтруктураЗначений.ExternalReference) Тогда
		ERОбъект.ExternalReference = СтруктураЗначений.ExternalReference;
	КонецЕсли;
	
	// Job number
	Если ЗначениеЗаполнено(СтруктураЗначений.JobNumber) Тогда
		ERОбъект.JobNumber = СтруктураЗначений.JobNumber;	
	КонецЕсли;
	
	// Urgency, Urgency Comment
	Если ЗначениеЗаполнено(СтруктураЗначений.Priority) Тогда
		
		Urgency = Перечисления.Urgencies.ПолучитьПоTMSName(СтруктураЗначений.Priority);
		Если ЗначениеЗаполнено(Urgency) Тогда
			
			// Решили, что Emeregency надо понижать до Urgent
			Если Urgency = Перечисления.Urgencies.Emergency Тогда
				Urgency = Перечисления.Urgencies.Urgent;
			КонецЕсли;
			
			ERОбъект.Urgency = Urgency;
			
			Если Urgency = Перечисления.Urgencies.Urgent Тогда
				ERОбъект.UrgencyComment = СтруктураЗначений.Priority;	
			КонецЕсли;
			
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Urgency by TMS Name """ + СтруктураЗначений.Priority + """!");
		КонецЕсли;
		
	КонецЕсли;
	
	// Required delivery date
	ERОбъект.RequiredDeliveryDate = СтруктураЗначений.RequiredDeliveryDate;
	
	// Ready to ship date
	ERОбъект.ReadyToShipDate = СтруктураЗначений.ReadyToShipDate;
	
	// Shipper
	Если ЗначениеЗаполнено(СтруктураЗначений.Shipper) Тогда
		
		Shipper = ImportExportСерверПовтИспСеанс.ПолучитьConsignToПоTMSID(СтруктураЗначений.Shipper);
		Если ЗначениеЗаполнено(Shipper) Тогда
			ERОбъект.Shipper = Shipper;
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Shipper by TMS ID """ + СтруктураЗначений.Shipper + """!");
		КонецЕсли;
		
	КонецЕсли;
	
	// Shipper contact
	Если ЗначениеЗаполнено(СтруктураЗначений.ShipperContact) Тогда
		
		ShipperContact = ImportExportСерверПовтИспСеанс.ПолучитьSLSRCAПоКоду(СтруктураЗначений.ShipperContact);
		Если ЗначениеЗаполнено(ShipperContact) Тогда
			ERОбъект.ShipperContact = ShipperContact;
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Shipper contact by alias '" + СтруктураЗначений.ShipperContact + "'!");	
		КонецЕсли;
		
	КонецЕсли;
	
	// Pick up warehouse & POD
	Если ЗначениеЗаполнено(СтруктураЗначений.PickUpWarehouse_POD) Тогда
		
		ERОбъект.PickUpWarehouse = Справочники.Warehouses.НайтиСоздатьПоTMSID(СтруктураЗначений.PickUpWarehouse_POD);
		
		ERОбъект.POD = Справочники.SeaAndAirPorts.ПолучитьПоTMSID(СтруктураЗначений.PickUpWarehouse_POD);
		
	КонецЕсли;
	
	// Consignee
	Если ЗначениеЗаполнено(СтруктураЗначений.Consignee) Тогда
		
		ERОбъект.Consignee = Справочники.Warehouses.НайтиСоздатьПоTMSID(СтруктураЗначений.Consignee); 
		
		РеквизитыConsignee = РГСофтСерверПовтИспСеанс.ЗначенияРеквизитовОбъекта(ERОбъект.Consignee, "ContactName, ContactPhone, ContactEmail");
		РГСофт.УстановитьЕслиЗаполнено(ERОбъект.ConsigneeContact, РеквизитыConsignee.ContactName);
		РГСофт.УстановитьЕслиЗаполнено(ERОбъект.ConsigneePhone, РеквизитыConsignee.ContactPhone); 		
		РГСофт.УстановитьЕслиЗаполнено(ERОбъект.ConsigneeEmail, РеквизитыConsignee.ContactEmail); 	
		
	КонецЕсли;
	
	// Deliver to
	Если ЗначениеЗаполнено(СтруктураЗначений.DeliverTo) Тогда
		
		ERОбъект.DeliverTo = Справочники.Warehouses.НайтиСоздатьПоTMSID(СтруктураЗначений.DeliverTo);
		
	КонецЕсли;
	
	// POA
	Если ЗначениеЗаполнено(ERОбъект.DeliverTo) Тогда
		
		DeliverToCountryCode = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ERОбъект.DeliverTo, "CountryCode");
		POA = ImportExportСерверПовтИспСеанс.ПолучитьCountryHUBПоTMSID(DeliverToCountryCode);
		Если ЗначениеЗаполнено(POA) Тогда
			ERОбъект.POA = POA;
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Country by code '" + DeliverToCountryCode + "' specified for deliver-to '" + ERОбъект.DeliverTo + "'!");	
		КонецЕсли;
		
	КонецЕсли;
	
	// Recharge
	ERОбъект.Recharge = СтруктураЗначений.RechargeFlag = "I";
	
	Если ERОбъект.Recharge Тогда
		
		// Recharge legal entity
		СтруктураRechargeLegalEntity = СтруктураЗначений.СтруктураRechargeLegalEntity;
		RechargeLegalEntity = ImportExportСерверПовтИспСеанс.ПолучитьLegalEntityПоРеквизитамTMS(
		СтруктураRechargeLegalEntity.CompanyCode,
		СтруктураRechargeLegalEntity.CountryCode,
		СтруктураRechargeLegalEntity.ERPID,
		СтруктураRechargeLegalEntity.FinanceLocCode,
		СтруктураRechargeLegalEntity.FinanceProcess);
		
		Если ЗначениеЗаполнено(RechargeLegalEntity) Тогда	
			ERОбъект.RechargeToLegalEntity = RechargeLegalEntity;			
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find TMS Recharge legal entity by Company code """ 
			+ СтруктураRechargeLegalEntity.CompanyCode + """, Country code """ + СтруктураRechargeLegalEntity.CountryCode + 
			""", ERP ID """ + СтруктураRechargeLegalEntity.ERPID + """, Finance loc code """ + 
			СтруктураRechargeLegalEntity.FinanceLocCode + """ and Finance process """ + СтруктураRechargeLegalEntity.FinanceProcess + """!");	
		КонецЕсли;
		
		// Recharge AU
		Если ЗначениеЗаполнено(СтруктураЗначений.RechargeAU) Тогда
			ERОбъект.RechargeToAU = СтруктураЗначений.RechargeAU;	
		КонецЕсли;
		
		// Recharge activity
		Если ЗначениеЗаполнено(СтруктураЗначений.RechargeActivity) Тогда
			ERОбъект.RechargeToActivity = СтруктураЗначений.RechargeActivity;	
		КонецЕсли;
		
	КонецЕсли;
	
	// Incoterms
	Если ЗначениеЗаполнено(СтруктураЗначений.Incoterms) Тогда
		
		Incoterms = ImportExportСерверПовтИспСеанс.ПолучитьIncotermsПоКоду(СтруктураЗначений.Incoterms);
		Если ЗначениеЗаполнено(Incoterms) Тогда
			ERОбъект.Incoterms = Incoterms;
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Incoterms by code """ + СтруктураЗначений.Incoterms + """!");
		КонецЕсли;
		
	КонецЕсли;
	
	// Paying Entity
	Если ЗначениеЗаполнено(СтруктураЗначений.PayingEntity) Тогда
		
		PayingEntity = Перечисления.PayingEntities[СтруктураЗначений.PayingEntity];
		Если ЗначениеЗаполнено(PayingEntity) Тогда
			ERОбъект.PayingEntity = PayingEntity;
		Иначе
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Paying entity by code """ + СтруктураЗначений.PayingEntity + """!");
		КонецЕсли;
		
	КонецЕсли;
	
	// Involved party locations и contacts
	
	Для Каждого OtherInvolvedPartyLocation Из СтруктураЗначений.СоответствиеOtherInvolvedPartyLocations Цикл
		
		НоваяСтрока = ERОбъект.OtherInvolvedLocations.Добавить();
		
		LocationQualifier = ImportExportСерверПовтИспСеанс.ПолучитьLocationQualifierПоКоду(OtherInvolvedPartyLocation.Ключ);
		Если НЕ ЗначениеЗаполнено(LocationQualifier) Тогда
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Location qualifier by code '" + OtherInvolvedPartyLocation.Ключ + "'!");	
		Иначе
			НоваяСтрока.LocationQualifier = LocationQualifier;	
		КонецЕсли;			
		
		НоваяСтрока.LocationId = OtherInvolvedPartyLocation.Значение;
		
	КонецЦикла;
	
	Для Каждого OtherInvolvedPartyContacts Из СтруктураЗначений.СоответствиеOtherInvolvedPartyContacts Цикл
		
		НоваяСтрока = ERОбъект.OtherInvolvedContacts.Добавить();
		
		ContactQualifier = ImportExportСерверПовтИспСеанс.ПолучитьContactQualifierПоDomainAndQualifier(OtherInvolvedPartyContacts.Ключ);
		Если НЕ ЗначениеЗаполнено(ContactQualifier) Тогда
			ДобавитьСтроку(ERОбъект.Comments, "! Failed to find Contact qualifier by code '" + OtherInvolvedPartyContacts.Ключ + "'!");	
		Иначе
			НоваяСтрока.ContactQualifier = ContactQualifier;	
		КонецЕсли;
		
		НоваяСтрока.ContactId = OtherInvolvedPartyContacts.Значение;
		
	КонецЦикла;
	
	// Если произошли критические ошибки - посылаем сообщение и уходим
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда
		Возврат ТекстОшибок;
	КонецЕсли;
	
	ERОбъектНовый = ERОбъект.ЭтоНовый();
	
	ERОбъект.Записать();
	
	СоздатьItemsИParcels(СтруктураЗначений, ERОбъект.Ссылка, ERОбъектНовый);	
	
	Возврат ERОбъект;
	
КонецФункции

Процедура СоздатьItemsИParcels(СтруктураЗначений, ERСсылка, ERОбъектНовый)
	
	Для Каждого СтруктураParcel из СтруктураЗначений.Parcels Цикл
		
		ParcelОбъект = Справочники.Parcels.СоздатьЭлемент();	
			
		ParcelОбъект.ExportRequest = ERСсылка;
		
		СоздатьItemsИЗаполнитьДеталиParcel(СтруктураParcel, ParcelОбъект);
		   				
		// Packing type
		Если ЗначениеЗаполнено(СтруктураParcel.PackingType) Тогда
			
			PackingType = ImportExportСерверПовтИспСеанс.ПолучитьPackingTypeПоTMSID(СтруктураParcel.PackingType);
			
			Если ЗначениеЗаполнено(PackingType) Тогда
				ParcelОбъект.PackingType = PackingType;
			Иначе
				ДобавитьСтроку(ParcelОбъект.Comment, "! Failed to find Packing type by TMS ID '" + СтруктураParcel.PackingType + "'!");	
			КонецЕсли;
			
		КонецЕсли;
		
		// Serial no.
		Если ЗначениеЗаполнено(СтруктураParcel.SerialNo) Тогда
			ParcelОбъект.SerialNo = СтруктураParcel.SerialNo;
		КонецЕсли;
		
		// Num Of Parcels
		Если ЗначениеЗаполнено(СтруктураParcel.NumOfParcels) Тогда
			
			NumOfParcels = ПреобразоватьСтрокуВЧисло(СтруктураParcel.NumOfParcels, ParcelОбъект.Comment, "Num. of parcels");
			Если ЗначениеЗаполнено(NumOfParcels) Тогда
				ParcelОбъект.NumOfParcels = NumOfParcels;
			КонецЕсли;	
			
		КонецЕсли;

		// Length
		Если ЗначениеЗаполнено(СтруктураParcel.Length) Тогда
			
			Length = ПреобразоватьСтрокуВЧисло(СтруктураParcel.Length, ParcelОбъект.Comment, "Length");
			Если ЗначениеЗаполнено(Length) Тогда
				ParcelОбъект.Length = Length;
			КонецЕсли;
			
		КонецЕсли;

		// Width
		Если ЗначениеЗаполнено(СтруктураParcel.Width) Тогда
			
			Width = ПреобразоватьСтрокуВЧисло(СтруктураParcel.Width, ParcelОбъект.Comment, "Width");
			Если ЗначениеЗаполнено(Width) Тогда
				ParcelОбъект.Width = Width;
			КонецЕсли;
			
		КонецЕсли;
		
		// Height
		Если ЗначениеЗаполнено(СтруктураParcel.Height) Тогда
			
			Height = ПреобразоватьСтрокуВЧисло(СтруктураParcel.Height, ParcelОбъект.Comment, "Height");
			Если ЗначениеЗаполнено(Height) Тогда
				ParcelОбъект.Height = Height;
			КонецЕсли;
			
		КонецЕсли;
		
		// DIMs UOM
		Если ЗначениеЗаполнено(СтруктураParcel.DIMsUOM) Тогда
			
			DIMsUOM = ImportExportСерверПовтИспСеанс.ПолучитьUOMПоTMSID(СтруктураParcel.DIMsUOM);
			Если ЗначениеЗаполнено(DIMsUOM) Тогда 
				ParcelОбъект.DIMsUOM = DIMsUOM;
	        Иначе
				ДобавитьСтроку(ParcelОбъект.Comment, "! Failed to find DIMs UOM by TMS Id """ + СтруктураParcel.DIMsUOM + """!");
			КонецЕсли;
	            						
		КонецЕсли;           
		
		// Total gross weight
		Если ЗначениеЗаполнено(СтруктураParcel.GrossWeight) Тогда
			
			GrossWeightPerParcel = ПреобразоватьСтрокуВЧисло(СтруктураParcel.GrossWeight, ParcelОбъект.Comment, "Total gross weight");
			Если ЗначениеЗаполнено(GrossWeightPerParcel) Тогда
				ParcelОбъект.GrossWeight = GrossWeightPerParcel * ParcelОбъект.NumOfParcels;
			КонецЕсли;
			
		КонецЕсли;
		
		// Weight UOM
		Если ЗначениеЗаполнено(СтруктураParcel.WeightUOM) Тогда
			
			WeightUOM = ImportExportСерверПовтИспСеанс.ПолучитьUOMПоTMSID(СтруктураParcel.WeightUOM);
			Если ЗначениеЗаполнено(WeightUOM) Тогда
				
				GrossKG = ПолучитьВKG(ParcelОбъект.GrossWeight, WeightUOM);
				Если GrossKG <> Неопределено Тогда
					
					ParcelОбъект.GrossWeight = GrossKG;
					ParcelОбъект.WeightUOM = Справочники.UOMs.KG;
					
				Иначе
					
					ДобавитьСтроку(ParcelОбъект.Comment, "! Failed to convert '" + СтруктураParcel.WeightUOM + "' to 'KG'!");	
					
				КонецЕсли;
								
			Иначе 
				ДобавитьСтроку(ParcelОбъект.Comment, "! Failed to find Weight UOM by TMS Id """ + СтруктураParcel.WeightUOM + """!");
			КонецЕсли; 
			
		КонецЕсли;

		// Total net weight
		ParcelОбъект.NetWeight = ParcelОбъект.Детали.Итог("NetWeight");

		ParcelОбъект.Записать();  
				
	КонецЦикла;
	       		
КонецПроцедуры

Процедура СоздатьItemsИЗаполнитьДеталиParcel(СтруктураParcel, ParcelОбъект)
	                    	    		
	Если ЗначениеЗаполнено(СтруктураParcel.ERPTreatment) Тогда
		
		ERPTreatment = Перечисления.ТипыЗаказа.ПолучитьПоTMSId(СтруктураParcel.ERPTreatment);
		Если НЕ ЗначениеЗаполнено(ERPTreatment) Тогда
			ДобавитьСтроку(ParcelОбъект.Comment, "! Failed to find ERP treatment """ + СтруктураParcel.ERPTreatment + """!");	
		КонецЕсли;
		
	КонецЕсли;
	
	ТЧДетали = ParcelОбъект.Детали;
	
	НомерItem = 1;
	Для Каждого СтруктураItem из СтруктураParcel.ParcelLines Цикл
		
		ItemComment = "";
		
		// создадим новый товар
		ItemОбъект = Справочники.СтрокиИнвойса.СоздатьЭлемент();	
				
		// Export request
		ItemОбъект.ExportRequest = ParcelОбъект.ExportRequest;
				
		// Part No
		ItemОбъект.КодПоИнвойсу = СтруктураItem.PartNo;
				
		// Item description
		ItemОбъект.НаименованиеТовара = СтруктураItem.Description;
				
		// Serial no.
		ItemОбъект.СерийныйНомер = СтруктураItem.SerialNo;
				
		// RAN
		ItemОбъект.RAN = СтруктураItem.RAN;
				       				
		// Country of origin
		Если ЗначениеЗаполнено(СтруктураItem.CountryOfOrigin) Тогда
			
			CountryOfOrigin = ImportExportСерверПовтИспСеанс.ПолучитьCountryHUBПоTMSID(СтруктураItem.CountryOfOrigin);
			Если НЕ ЗначениеЗаполнено(CountryOfOrigin) Тогда
				ДобавитьСтроку(ItemComment, "! Failed to find Country Of Origin by TMS Id '" + СтруктураItem.CountryOfOrigin + "'!");	
			Иначе
				ItemОбъект.СтранаПроисхождения = CountryOfOrigin;	
			КонецЕсли;
			
		КонецЕсли;
		
		// ERP treatment
		Если ЗначениеЗаполнено(ERPTreatment) Тогда
			ItemОбъект.Классификатор = ERPTreatment;	
		КонецЕсли;
		
		// UOM	
		Если ЗначениеЗаполнено(СтруктураItem.QTYUOM) Тогда
			
			QtyUOM = ImportExportСерверПовтИспСеанс.ПолучитьUOMПоTMSIDForItemUOM(СтруктураItem.QTYUOM);
			Если ЗначениеЗаполнено(QtyUOM) Тогда 
				ItemОбъект.ЕдиницаИзмерения = QtyUOM;
	        Иначе
				ДобавитьСтроку(ItemComment, "! Failed to find UOM by TMS Id for Item UOM '" + СтруктураItem.QTYUOM + "'!");
			КонецЕсли;
			
		КонецЕсли;
	  		
		// Currency
		Если ЗначениеЗаполнено(СтруктураItem.Currency) Тогда
			
			Currency = ImportExportСерверПовтИспСеанс.ПолучитьCurrencyПоНаименованиюEng(СтруктураItem.Currency);
			Если ЗначениеЗаполнено(Currency) Тогда 
				ItemОбъект.Currency = Currency;
			Иначе		
				ДобавитьСтроку(ItemComment, "! Failed to find Currency by TMS Id """ + СтруктураItem.Currency + """!");
			КонецЕсли;
			
		КонецЕсли;
		
		// QTY	
		Если ЗначениеЗаполнено(СтруктураItem.QTY) Тогда
			
			QTY = ПреобразоватьСтрокуВЧисло(СтруктураItem.QTY, ItemComment, "QTY");
			Если ЗначениеЗаполнено(QTY) Тогда
				ItemОбъект.Количество = QTY;
			КонецЕсли;
			
		КонецЕсли;
			
		// Total price
		Если ЗначениеЗаполнено(СтруктураItem.TotalPrice) Тогда
			
			TotalPrice = ПреобразоватьСтрокуВЧисло(СтруктураItem.TotalPrice, ItemComment, "Total price");
			Если ЗначениеЗаполнено(TotalPrice) Тогда
				ItemОбъект.Сумма = TotalPrice;
			КонецЕсли;
			
		КонецЕсли;
		
		// Unit Price
		ItemОбъект.Цена = ?(ItemОбъект.Количество = 0, 0, ItemОбъект.Сумма/ItemОбъект.Количество);
		
		// Net weight
		Если ЗначениеЗаполнено(СтруктураItem.NetWeight) Тогда
			
			NetWeight = ПреобразоватьСтрокуВЧисло(СтруктураItem.NetWeight, ItemComment, "Net weight");
			Если ЗначениеЗаполнено(NetWeight) Тогда
				ItemОбъект.NetWeight = NetWeight;
			КонецЕсли;
			
		КонецЕсли;

		// Weight UOM
		Если ЗначениеЗаполнено(СтруктураItem.NetWeightUOM) Тогда
			
			WeightUOM = ImportExportСерверПовтИспСеанс.ПолучитьUOMПоTMSID(СтруктураItem.NetWeightUOM);
			Если ЗначениеЗаполнено(WeightUOM) Тогда
				
				NetKG = ПолучитьВKG(ItemОбъект.NetWeight, WeightUOM);
				Если NetKG <> Неопределено Тогда
					
					ItemОбъект.NetWeight = NetKG;
					ItemОбъект.WeightUOM = Справочники.UOMs.KG;
					
				Иначе
					
					ДобавитьСтроку(ItemComment, "! Failed to convert '" + СтруктураItem.NetWeightUOM + "' to 'KG'!");	
					
				КонецЕсли;		
				
			Иначе
				ДобавитьСтроку(ItemComment, "! Failed to find Weight UOM by TMS Id '" + СтруктураItem.NetWeightUOM + "'!");
			КонецЕсли;
			
		КонецЕсли;
		
		// PO no.
		Если ЗначениеЗаполнено(СтруктураItem.PONo) Тогда
			ItemОбъект.НомерЗаявкиНаЗакупку = СтруктураItem.PONo;
		КонецЕсли;
		
		// PO line
		Если ЗначениеЗаполнено(СтруктураItem.PONo) И ЗначениеЗаполнено(СтруктураItem.POLine) Тогда
			
			POLineNo = Неопределено;
			Попытка
				POLineNo = Число(СтруктураItem.POLine);
			Исключение
				ДобавитьСтроку(ItemComment, "! Failed to convert '" + СтруктураItem.POLine + "' to PO line number!");		
			КонецПопытки;
			
			Если ЗначениеЗаполнено(POLineNo) Тогда
				
				ItemОбъект.СтрокаЗаявкиНаЗакупку = Справочники.СтрокиЗаявкиНаЗакупку.ПолучитьPOLineПоPOnoИPOLineNo(СтруктураItem.PONUM, POLineNo); 
				Если НЕ ЗначениеЗаполнено(ItemОбъект.СтрокаЗаявкиНаЗакупку) Тогда
					ДобавитьСтроку(ItemComment, "! Failed to find PO line by PO no '" + СтруктураItem.PONo + "' and PO line no. '" + POLineNo + "'!");	
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
		ItemОбъект.Записать();
			
		Если Не ПустаяСтрока(ItemComment) Тогда 
			ДобавитьСтроку(ParcelОбъект.Comment, "In Item " + НомерItem + ": " + ItemComment);
		КонецЕсли;
	
		//заполняем новую строку в табличной части Детали Parcel
		Если НомерItem <= ParcelОбъект.Детали.Количество() Тогда
			СтрокаДеталей = ТЧДетали[НомерItem-1];
		Иначе
			СтрокаДеталей = ТЧДетали.Добавить();
			СтрокаДеталей.СтрокаИнвойса = ItemОбъект.Ссылка;
		КонецЕсли;
				
		СтрокаДеталей.СерийныйНомер = ItemОбъект.СерийныйНомер;
		СтрокаДеталей.Qty = ItemОбъект.Количество;
		СтрокаДеталей.QtyUOM = ItemОбъект.ЕдиницаИзмерения;
		СтрокаДеталей.NetWeight = ItemОбъект.NetWeight;
		
		НомерItem = НомерItem + 1;
		
	КонецЦикла;
	      		
КонецПроцедуры

Процедура ДобавитьСтроку(ИсходнаяСтрока, НоваяСтрока)
	
	ИсходнаяСтрока = ИсходнаяСтрока + Символы.ПС + НоваяСтрока;
			  
КонецПроцедуры

Функция ПреобразоватьСтрокуВЧисло(Знач стрЗначение, Comments=Неопределено, ИмяПоля=Неопределено)
	
	Если НЕ ЗначениеЗаполнено(стрЗначение) Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	Попытка
		Значение = Число(стрЗначение);
		Возврат Значение;
	Исключение
		Если Comments <> Неопределено И ИмяПоля <> Неопределено Тогда 
			ДобавитьСтроку(Comments, "! Failed to convert """ + стрЗначение + """ to """ + ИмяПоля + """!");
		КонецЕсли;
	КонецПопытки;
	
	Возврат Неопределено;
	
КонецФункции

Функция ПолучитьВKG(Weight, WeightUOM)
	
	Если НЕ ЗначениеЗаполнено(WeightUOM) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	KG = Справочники.UOMs.KG;
	
	Если WeightUOM = KG Тогда
		Возврат Weight;	
	КонецЕсли;
	
	WeightUOMDetails = РГСофтСерверПовтИспСеанс.ЗначенияРеквизитовОбъекта(WeightUOM, "StandardUOM, ConversionFactor");
	Если WeightUOMDetails.StandardUOM <> KG Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Weight * WeightUOMDetails.ConversionFactor;
					
КонецФункции

/////////////////////////////////////////////////////////////////////
// ОСТАЛЬНЫЕ ПРОЦЕДУРЫ / ФУНКЦИИ НЕОБХОДИМЫЕ ДЛЯ РАБОТЫ ВЕБ-СЕРВИСА

Функция PushGenericStatusUpdate(TransOrderXid, ТекстОшибок) Экспорт
	
	// Отсылает в TMS GenericStatusUpdate - что-то типа отчета о загрузке
	
	WSСсылка = ПолучитьWSСсылкуДляGenericStatusUpdate();
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	
	TransmissionHeader = TMSСервер.ПолучитьTransmissionHeader(ФабрикаXDTOTMS);	
	GenericStatusUpdate = ПолучитьGenericStatusUpdate(ФабрикаXDTOTMS, TransOrderXid, ТекстОшибок);
	TransmissionBody = TMSСервер.ПолучитьTransmissionBody(ФабрикаXDTOTMS, "GenericStatusUpdate", GenericStatusUpdate);
	Payload = TMSСервер.ПолучитьPayload(ФабрикаXDTOTMS, TransmissionHeader, TransmissionBody);
	
	WSПрокси = СоздатьWSПроксиДляShipmentStatusUpdate(WSСсылка);	
	Возврат WSПрокси.process(Payload);
	
КонецФункции

Функция ПолучитьWSСсылкуДляGenericStatusUpdate()
	
	// Возвращает WSСсылку для отправки shipment status update в TMS
	// Для продакшн базы используется одна ссылка, для остальных баз - другая
	
	Если РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() Тогда
		Возврат WSСсылки.TMSPushShipmentStatusProd;
	Иначе
		Возврат WSСсылки.TMSPushShipmentStatusTest;	
	КонецЕсли;
	
КонецФункции

Функция СоздатьWSПроксиДляShipmentStatusUpdate(WSСсылка)
	
	// Анализирует WSСсылку и возвращает настроенный WSПрокси, полученной из этой WSСсылки
	
	URIПространстваИмен = "http://xmlns.oracle.com/apps/otm/IntXmlService";
	ИмяСервиса = "IntXmlService";	
	
	Если WSСсылка = WSСсылки.TMSPushShipmentStatusProd Тогда
		ИмяПорта = "IntXml-xbroker_304_DR";
	ИначеЕсли WSСсылка = WSСсылки.TMSPushShipmentStatusTest Тогда
		//ИмяПорта = "IntXml-QaXBroker_2-QaXBroker_2";
		ИмяПорта = "IntXml-QaXBroker_2";
	Иначе
		ВызватьИсключение "Failed to find port for WS reference '" + WSСсылка + "' to TransOrder status!";
	КонецЕсли;
	
	Возврат WSСсылка.СоздатьWSПрокси(URIПространстваИмен, ИмяСервиса, ИмяПорта);
	
КонецФункции

Функция ПолучитьGenericStatusUpdate(ФабрикаXDTOTMS, TransOrderXid, ТекстОшибок)
	
	GenericStatusUpdate = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GenericStatusUpdate");
	
	GenericStatusUpdate.GenericStatusObjectType = "OB_ORDER_BASE";
	
	GenericStatusUpdate.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, TransOrderXid);
	GenericStatusUpdate.Gid.DomainName = "SLB";
	
	GenericStatusUpdate.TransactionCode = "IU";
	   	
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда 
		
		Remark = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Remark");
		Remark.TransactionCode = "IU";
		Remark.RemarkSequence = "1";
		Remark.RemarkQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "RemarkQualifierGid");
		Remark.RemarkQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "OB 1C TRANSMISSION");
		Remark.RemarkQualifierGid.Gid.DomainName = "SLB";
		Remark.RemarkText = СокрЛП(ТекстОшибок);
		GenericStatusUpdate.Remark.Добавить(Remark);
		   		
		GenericStatusUpdate.Status.Добавить(ПолучитьStatus(ФабрикаXDTOTMS, "ORDER_BASE 1C TRANSMISSION", "ORDER_BASE 1C TRANSMISSION_INTEGRATION FAILED"));
				
	иначе	
		
		GenericStatusUpdate.Status.Добавить(ПолучитьStatus(ФабрикаXDTOTMS, "ORDER_BASE 1C TRANSMISSION", "ORDER_BASE 1C TRANSMISSION_INTEGRATION SUCCESS"));
		
	КонецЕсли;
	
	
	Возврат GenericStatusUpdate;
	
КонецФункции

Функция ПолучитьStatus(ФабрикаXDTOTMS, StatusTypeGid, StatusValueGid)
	    		
	Status = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Status");
	
	Status.StatusTypeGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "StatusTypeGid");
	Status.StatusTypeGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, StatusTypeGid);
	Status.StatusTypeGid.Gid.DomainName = "SLB";
	
	Status.StatusValueGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "StatusValueGid");
	Status.StatusValueGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, StatusValueGid);
	Status.StatusValueGid.Gid.DomainName = "SLB";
	
	Возврат Status;
	
КонецФункции

Функция ПолучитьTransmissionAck(TransmissionHeader, ТекстОшибок) Экспорт
 	
	URIПространстваИмен = TMSСервер.ПолучитьURIПространстваИменTMSLite();
	
	TransmissionAck = TMSСервер.ПолучитьОбъектXDTO(ФабрикаXDTO, URIПространстваИмен, "TransmissionAck");
	
	TransmissionAck.EchoedTransmissionHeader = TMSСервер.ПолучитьОбъектXDTO(ФабрикаXDTO, URIПространстваИмен, "EchoedTransmissionHeader");
 	TransmissionAck.EchoedTransmissionHeader.TransmissionHeader = TransmissionHeader;
	
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда
		TransmissionAck.TransmissionAckStatus = "ERROR";
		TransmissionAck.TransmissionAckReason = ТекстОшибок;
	Иначе
		TransmissionAck.TransmissionAckStatus = "PROCESSED";	
	КонецЕсли;

	Возврат TransmissionAck;
	
КонецФункции 
