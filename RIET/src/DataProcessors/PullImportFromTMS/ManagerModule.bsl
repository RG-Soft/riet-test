
//////////////////////////////////////////////////////////////////////////////////////
// ЗАГРУЗКА PLANNED SHIPMENT

// ДОДЕЛАТЬ
Функция ЗагрузитьPlannedShipment(PlannedShipment) Экспорт
	
	// Загружает DOC, Invoices и Parcels из XDTO-объекта PlannedShipment
	// В случае обработанных ошибок - возвращает текст ошибок
	// В случае непредвиденных ошибок - выбрасывает исключения
	// В случае успеха - возвращает пустую строку
	
	Shipment = PlannedShipment.Shipment;
	           		
	// Сконвертируем структуру XDTO в структуру текстовых значений 
	СтруктураТекстовыхЗначений = ПолучитьСтруктуруТекстовыхЗначений(Shipment);	
	
	// Если вместо структуры вернулась строка - это ошибки - вернем их
	Если ТипЗнч(СтруктураТекстовыхЗначений) = Тип("Строка") Тогда
		Возврат СтруктураТекстовыхЗначений;
	КонецЕсли;
	
	// ИЗБАВИТЬСЯ ОТ СТРУКТУРЫ ОБЪЕКТОВ БАЗЫ И ПЕРЕНЕСТИ ТРАНЗАКЦИЮ В ФУНКЦИЮ СОЗДАНИЯ И ОБНОВЛЕНИЯ ОБЪЕКТОВ
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	СтруктураОбъектовБазы = ПолучитьСтруктуруОбъектовБазы(СтруктураТекстовыхЗначений);
	
	// Создадим / обновим объекты базы
	ТекстОшибок = СоздатьОбновитьОбъекты(СтруктураТекстовыхЗначений, СтруктураОбъектовБазы);
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда
		ОтменитьТранзакцию();
		Возврат ТекстОшибок;	
	КонецЕсли;
	   
	// ПЕРЕНЕСТИ В СОЗДАНИЕ ОБЪЕКТОВ
	ЗафиксироватьТранзакцию();
	
	Возврат "";
	              	        
КонецФункции


// СТРУКТУРА ТЕКСТОВЫХ ЗНАЧЕНИЙ

Функция ПолучитьСтруктуруТекстовыхЗначений(Shipment)
	
	// Возвращает структуру текстовых значений, полученную из объекта XDTO Shipment
	// При возникновении критических ошибок - возвращает текст ошибок
	ТекстОшибок = "";
	
	// Получим структуру текстовых значений шапки DOC
	СтруктураРезультатов = ПолучитьСтруктуруТекстовыхЗначенийDOC(Shipment);
	СтруктураТекстовыхЗначений = СтруктураРезультатов.СтруктураТекстовыхЗначений;
	СтруктураТекстовыхЗначенийПолная = СтруктураРезультатов.СтруктураТекстовыхЗначенийПолная;
	
	// Если вернулась не структура, а строка - это строка ошибок
	Если ТипЗнч(СтруктураТекстовыхЗначений) = Тип("Строка") Тогда
		ДобавитьВComment(ТекстОшибок, СтруктураТекстовыхЗначений);
	КонецЕсли;
	
	//проверим условие RU-KZ или KZ-RU
	// Если условия загрузки не подходят - вернем их
	ТекстОшибкиRussiaKazakhstan = ПроверитьRussiaKazakhstan(СтруктураТекстовыхЗначенийПолная);
	Если ЗначениеЗаполнено(ТекстОшибкиRussiaKazakhstan) Тогда
		Возврат ТекстОшибкиRussiaKazakhstan;
	КонецЕсли;
	
	// Получим структуры текстовых значений invoices, parcels, etc.
	СтруктурыТекстовыхЗначенийInvoices = ПолучитьМассивСтруктурТекстовыхЗначенийInvoices(Shipment);
	 	
	// Если вернулась не структура, а строка - это строка ошибок
	Если ТипЗнч(СтруктурыТекстовыхЗначенийInvoices) = Тип("Строка") Тогда
		
		ДобавитьВComment(ТекстОшибок, СтруктурыТекстовыхЗначенийInvoices);
		
	Иначе 
		
		ТекстОшибкиPOD_TMSIDиWHCountryCode = ПроверитьPOD_TMSIDиWHCountryCode(СтруктураТекстовыхЗначенийПолная, СтруктурыТекстовыхЗначенийInvoices);
		Если ЗначениеЗаполнено(ТекстОшибкиPOD_TMSIDиWHCountryCode) Тогда
			Возврат ТекстОшибкиPOD_TMSIDиWHCountryCode;
		КонецЕсли;
		
	КонецЕсли;
	
	// Если были ошибки - вернем их
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда
		Возврат СокрЛП(ТекстОшибок);
	КонецЕсли;
	
	СтруктураТекстовыхЗначений.Вставить("Invoices", СтруктурыТекстовыхЗначенийInvoices);	
			
	Возврат СтруктураТекстовыхЗначений;
	
КонецФункции

Функция ПроверитьRussiaKazakhstan(СтруктураТекстовыхЗначений)
	
	//“Shipment from Russia to Kazakhstan should not be processed via 1C”
	//“Shipment from Kazakhstan to Russia should not be processed via 1C”

	SourceLocationCountryCode = СтруктураТекстовыхЗначений.POD;
	DestinationLocationCountryCode = СтруктураТекстовыхЗначений.RequestedPOACountryCode;
	
	Если SourceLocationCountryCode = "RUS" и DestinationLocationCountryCode = "KAZ" Тогда
		Возврат "Shipment from Russia to Kazakhstan should not be processed via 1C";	
	ИначеЕсли SourceLocationCountryCode = "KAZ" и DestinationLocationCountryCode = "RUS" Тогда   
		Возврат "Shipment from Kazakhstan to Russia should not be processed via 1C";	
	КонецЕсли;
	
КонецФункции

Функция ПроверитьPOD_TMSIDиWHCountryCode(СтруктураТекстовыхЗначений, СтруктурыТекстовыхЗначенийInvoices)
	
	//in case POD TMS ID (KAZ or RUS) is the same as Country Code in Parcel WH-to (KAZ or RUS)
	//“Shipment should not be processed via 1C”
	
	POD_TMSID = СокрЛП(СтруктураТекстовыхЗначений.POD);
	
	МассивCountryCodeWHTo = Новый Массив;
	Для Каждого СтруктураInvoice из СтруктурыТекстовыхЗначенийInvoices Цикл 
		
		WarehouseTo_TMSID = СокрЛП(СтруктураInvoice.WarehouseTo); 
		СтруктураWHTo_TMS = Обработки.PullMasterDataFromTMS.ПолучитьРеквизитыLocation(WarehouseTo_TMSID);
	    CountryCodeWHTo = СокрЛП(СтруктураWHTo_TMS.CountryCode);
		
		Если МассивCountryCodeWHTo.Найти(CountryCodeWHTo) = Неопределено Тогда 
			МассивCountryCodeWHTo.Добавить(CountryCodeWHTo);	
		КонецЕсли;
		
	КонецЦикла;

	Если МассивCountryCodeWHTo.Количество() > 1 Тогда 
		Возврат "";
	КонецЕсли;
	
	Если POD_TMSID = МассивCountryCodeWHTo[0] Тогда
		Возврат "POD TMS_ID (SourceLocationCountryCode) is the same as Country Code in Warehouse-To (DestuffLocation). Shipment should not be processed via 1C";	
	КонецЕсли;
	
КонецФункции

Функция ПолучитьСтруктуруТекстовыхЗначенийDOC(Shipment)
	
	// Возвращает структуру текстовых значений DOC
	// При возникновении критических ошибок - возвращает текст ошибок
	// При возникновении некритических ошибок - отражает их в свойстве структуры Comments
	
	ТекстОшибок = "";
	
	ShipmentHeader = Shipment.ShipmentHeader;
		
	СтруктураЗначений = Новый Структура("No, POD, RequestedPOA, RequestedPOACountryCode, RequestedPOACorporation, MOT, ConsignTo, Comments");
	СтруктураЗначений.Comments = "";
	
	// No.
	СтруктураЗначений.No = СокрЛП(ShipmentHeader.ShipmentGid.Gid.Xid);
	
	// Без номера мы не сможем найти или создать DOC, поэтому прекращаем загрузку
	Если НЕ ЗначениеЗаполнено(СтруктураЗначений.No) Тогда
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Shipment no.!
			|Path: ShipmentHeader.ShipmentGid.Gid.Xid");
	КонецЕсли;
	
	// Remarks
	Попытка
		ДобавитьВComment(СтруктураЗначений.Comments, СокрЛП(ShipmentHeader.Remark.RemarkText));
	Исключение
	КонецПопытки;
	
	TransOrders = ПолучитьМассивОбъектовXDTO(Shipment, "TransOrder");
		                 		
	Для Каждого TransOrder из TransOrders Цикл 
		
		Попытка
			ShipUnitDetail = TransOrder.ShipUnitDetail;
		Исключение
			Продолжить;
		КонецПопытки;
		
		ShipUnits = ПолучитьМассивОбъектовXDTO(ShipUnitDetail, "ShipUnit");		
		Для Каждого ShipUnit Из ShipUnits Цикл 
			
			ShipUnitContents = ПолучитьМассивОбъектовXDTO(ShipUnit, "ShipUnitContent");
			
			Для Каждого ShipUnitContent из ShipUnitContents Цикл
				
				ShipUnitLineRefnums = ПолучитьМассивОбъектовXDTO(ShipUnitContent, "ShipUnitLineRefnum"); 
				
				Для Каждого ShipUnitLineRefnum из ShipUnitLineRefnums Цикл
					
					Попытка
						Если ShipUnitLineRefnum.ShipUnitLineRefnumQualifierGid.Gid.Xid = "DESCRIPTION_2" Тогда 
							ДобавитьВComment(СтруктураЗначений.Comments, ShipUnitLineRefnum.ShipUnitLineRefnumValue);
						КонецЕсли;
					Исключение
					КонецПопытки;
					
				КонецЦикла;
				
			КонецЦикла;
			       			
		КонецЦикла;
		
	КонецЦикла;
	
	// Для удобства сконструироем соответсвие LocationXid -> Location
	Locations = ПолучитьМассивОбъектовXDTO(Shipment, "Location");
	СоответствиеLocations = ПолучитьСоответствиеLocations(Locations);
	
	// Source Location
	SourceLocation = Неопределено;
	Попытка
		SourceLocation = СокрЛП(ShipmentHeader.SourceLocationRef.LocationRef.LocationGid.Gid.Xid);		
	Исключение	
	КонецПопытки;
	
	Если НЕ ЗначениеЗаполнено(SourceLocation) Тогда
		
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Source location!
			|Path: ShipmentHeader.SourceLocationRef.LocationRef.LocationGid.Gid.Xid");
		
	Иначе
		
		ДобавитьВComment(СтруктураЗначений.Comments, "Ship from: " + SourceLocation);
		
		// POD - Source location country
		SourceLocationDetails = СоответствиеLocations[SourceLocation];
		Если SourceLocationDetails <> Неопределено Тогда
			
			Попытка
				СтруктураЗначений.POD = СокрЛП(SourceLocationDetails.Address.CountryCode3Gid.Gid.Xid);
			Исключение
			КонецПопытки;
			
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.POD) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Country of departure!
				|Path: Shipment.Location.AddressCountryCode3Gid.Gid.Xid with Location.LocationGid.Gid.Xid = " + SourceLocation);	
		КонецЕсли;
		
	КонецЕсли;
		
	// Requested POA
	Попытка
		СтруктураЗначений.RequestedPOA = СокрЛП(ShipmentHeader.DestinationLocationRef.LocationRef.LocationGid.Gid.Xid);
	Исключение
	КонецПопытки;
	
	Если НЕ ЗначениеЗаполнено(СтруктураЗначений.RequestedPOA) Тогда
		
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Destination location!
			|Path: ShipmentHeader.DestinationLocationRef.LocationRef.LocationGid.Gid.Xid");	
			
	Иначе
		
		// Destination country и Corporation - реквизиты RequestedPOA
		RequestedPOADetails = СоответствиеLocations[СтруктураЗначений.RequestedPOA];
		Если RequestedPOADetails <> Неопределено Тогда
			
			Попытка
				СтруктураЗначений.RequestedPOACountryCode = СокрЛП(RequestedPOADetails.Address.CountryCode3Gid.Gid.Xid);
			Исключение
			КонецПопытки;
		
			Попытка
				СтруктураЗначений.RequestedPOACorporation = СокрЛП(RequestedPOADetails.Corporation.CorporationGid.Gid.Xid);
			Исключение
			КонецПопытки;
				
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.RequestedPOACountryCode) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find destination country!
				|Path: Shipment.Location.Address.CountryCode3Gid.Gid.Xid with Location.LocationGid.Gid.Xid = " + СтруктураЗначений.RequestedPOA);	
		КонецЕсли;

		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.RequestedPOACorporation) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find destination corporation!
				|Path: Shipment.Location.Corporation.CorporationGid.Gid.Xid with Location.LocationGid.Gid.Xid = " + СтруктураЗначений.RequestedPOA);	
		КонецЕсли;
		
	КонецЕсли;
	      	
	// MOT 
	Попытка
		СтруктураЗначений.MOT = СокрЛП(ShipmentHeader.PlannedShipmentInfo.TransportModeGid.Gid.Xid);
	Исключение	
	КонецПопытки;		
	
	Если НЕ ЗначениеЗаполнено(СтруктураЗначений.MOT) Тогда
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Trasport mode!
			|Path: ShipmentHeader.PlannedShipmentInfo.TransportModeGid.Gid.Xid");	
	КонецЕсли;
	
	// Для удобства сконструируем соответствие Involved party qualifier -> Involved party
	InvolvedParties = ПолучитьМассивОбъектовXDTO(ShipmentHeader, "InvolvedParty");
	СоответствиеInvolvedParties = ПолучитьСоответствиеInvolvedParties(InvolvedParties);
	
	// Consign-to
	Consignee = СоответствиеInvolvedParties["CONSIGNEE"];
	Если Consignee <> Неопределено Тогда
		Попытка                               
			СтруктураЗначений.ConsignTo = СокрЛП(Consignee.InvolvedPartyLocationRef.LocationRef.LocationGid.Gid.Xid);
		Исключение	
		КонецПопытки;	
	КонецЕсли;
	
	// Contacts
	Releases = ПолучитьМассивОбъектовXDTO(Shipment, "Release");
	Для Каждого Release из Releases Цикл
		ContactsText = ПолучитьContactsText(Release, СокрЛП(Release.ReleaseGid.Gid.Xid));
		ДобавитьВСтрокуЕслиЗаполнено(СтруктураЗначений.Comments, ContactsText);
	КонецЦикла;
	
	// { RGS AGorlenko 02.03.2015 18:45:35 - нужна также и полученная структура значений
	//Если ЗначениеЗаполнено(ТекстОшибок) Тогда
	//	Возврат ТекстОшибок;
	//Возврат СтруктураЗначений;
	//КонецЕсли;
	СтруктураРезультата = Новый Структура("СтруктураТекстовыхЗначений, СтруктураТекстовыхЗначенийПолная");
	СтруктураРезультата.СтруктураТекстовыхЗначений = ?(ЗначениеЗаполнено(ТекстОшибок), ТекстОшибок, СтруктураЗначений);
	СтруктураРезультата.СтруктураТекстовыхЗначенийПолная = СтруктураЗначений;
	Возврат СтруктураРезультата;
	// } RGS AGorlenko 02.03.2015 18:45:59 - нужна также и полученная структура значений
	
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

// ДОДЕЛАТЬ
Функция ПолучитьМассивСтруктурТекстовыхЗначенийInvoices(Shipment)
	
	// Возвращает массив структур текстовых значений Invoices, полученных из объектов XDTO
	// При возникновении критических ошибок - возвращает текст ошибок
	
	Releases = ПолучитьМассивОбъектовXDTO(Shipment, "Release");
	
	Если Releases.Количество() = 0 Тогда
		Возврат "Failed to find Releases
			|Path: Shipment.Release!";	
	КонецЕсли;
	
	МассивСтруктур = Новый Массив;
	ТекстОшибок = "";
	      	         	
	//заполняем структуру для каждого инвойса и добавляем в массив
	Для Каждого Release из Releases Цикл 
		
		СтруктураЗначений = Новый Структура("No, LegalEntity, RechargeLegalEntity, Incoterms, TotalPrice, Currency, Rate, Urgency, AU, Activity, WarehouseTo, PayingEntity, RDD, Comments, Items, Parcels");
		СтруктураЗначений.Comments = "";
		 		
		// No.
		Попытка
			СтруктураЗначений.No = СокрЛП(Release.ReleaseGid.Gid.Xid);
		Исключение
		КонецПопытки;
		
		// Без номера не сможем найти/создать Invoice, поэтому сразу переходим к следующему релизу
		Если Не ЗначениеЗаполнено(СтруктураЗначений.No) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Release no.!
				|Path: Release.ReleaseGid.Gid.Xid");
			Продолжить;
		КонецЕсли;			
		
		// Remarks
		Попытка
			ДобавитьВСтрокуЕслиЗаполнено(СтруктураЗначений.Comments, "Trans order remark:" + Символы.ПС + СокрЛП(Release.TransOrder.TransOrderHeader.Remark.RemarkText));
		Исключение
		КонецПопытки;
		
		Попытка
			ДобавитьВСтрокуЕслиЗаполнено(СтруктураЗначений.Comments, "Release remark:" + Символы.ПС + СокрЛП(Release.Remark.RemarkText));
		Исключение
		КонецПопытки;
		
		// Urgency
		Попытка
			СтруктураЗначений.Urgency = СокрЛП(Release.ReleaseHeader.OrderPriority);
		Исключение
		КонецПопытки;                                   
		
		// Legal entity, Recharge legal entity, Source Segment, source AU, source Activity, Segment, AU, Activity, RDD
		СтрокаСвойствLegalEntity = ПолучитьСтрокуСвойствLegalEntity();
		СтруктураЗначений.LegalEntity = Новый Структура(СтрокаСвойствLegalEntity);
					
		// Переберем refnums в поисках этих реквизитов
		ReleaseRefnums = ПолучитьСвойствоВладельцаXDTO(Release, "ReleaseRefnum");		
		Если ReleaseRefnums = Неопределено Тогда
			
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Legal entity, Segment, AU, Activity and RDD!
				|Release #" + СтруктураЗначений.No + "
				|Path: Release.ReleaseRefnum");	
				
		Иначе
			
			СтруктураReleaseRefnums = ПолучитьСтруктуруReleaseRefnums(ReleaseRefnums);
			
			// Required delivery date
			Если СтруктураReleaseRefnums.Свойство("OB_DELIVERY_DT")
				И ЗначениеЗаполнено(СтруктураReleaseRefnums.OB_DELIVERY_DT) Тогда
				
				Попытка
					СтруктураЗначений.RDD = ПреобразоватьСтрокуВДату(СтруктураReleaseRefnums.OB_DELIVERY_DT);
				Исключение
					ДобавитьВComment(ТекстОшибок,
						"Failed to convert """ + СтруктураReleaseRefnums.OB_DELIVERY_DT + """ to Required delivery date!
						|Release: " + СтруктураЗначений.No + "
						|Path: ReleaseRefnum.ReleaseRefnumValue with ReleaseRefnum.ReleaseRefnumQualifierGid.Gid.Xid = OB_DELIVERY_DT");	
				КонецПопытки;
				
			КонецЕсли;
			
			// Source segment
			ДобавитьВComment(СтруктураЗначений.Comments, "Source info:");
			Если СтруктураReleaseRefnums.Свойство("OB_SEGMENT") Тогда
				ДобавитьВComment(СтруктураЗначений.Comments, "Segment: " + СтруктураReleaseRefnums.OB_SEGMENT, Символы.ПС);
			КонецЕсли;
			
			// Source AU
			Если СтруктураReleaseRefnums.Свойство("OB_COST_CENTER") Тогда
				ДобавитьВComment(СтруктураЗначений.Comments, "AU: " + СтруктураReleaseRefnums.OB_COST_CENTER, Символы.ПС);
			КонецЕсли;
			
			// Source Activity
			Если СтруктураReleaseRefnums.Свойство("OB_AC_CODE") Тогда
				ДобавитьВComment(СтруктураЗначений.Comments, "Activity: " + СтруктураReleaseRefnums.OB_AC_CODE, Символы.ПС);
			КонецЕсли;

			// Legal entity
			LegalEntity = СтруктураЗначений.LegalEntity;
			
			СтруктураReleaseRefnums.Свойство("OB_ERP_ID", LegalEntity.ERPID);
			Если НЕ ЗначениеЗаполнено(LegalEntity.ERPID) Тогда
				ДобавитьВComment(ТекстОшибок,
					"Failed to find ERP ID of Legal entity!
					|Release: " + СтруктураЗначений.No + "
					|Path: ReleaseRefnum.ReleaseRefnumValue with ReleaseRefnum.ReleaseRefnumQualifierGid.Gid.Xid = OB_ERP_ID");	
			КонецЕсли;
			
			СтруктураReleaseRefnums.Свойство("OB_LEGAL_ENTITY", LegalEntity.CompanyCode);
			Если НЕ ЗначениеЗаполнено(LegalEntity.CompanyCode) Тогда
				ДобавитьВComment(ТекстОшибок,
					"Failed to find Company code of Legal entity!
					|Release: " + СтруктураЗначений.No + "
					|Path: ReleaseRefnum.ReleaseRefnumValue with ReleaseRefnum.ReleaseRefnumQualifierGid.Gid.Xid = OB_LEGAL_ENTITY");	
			КонецЕсли;
			
			СтруктураReleaseRefnums.Свойство("OB_COUNTRY_CODE", LegalEntity.CountryCode);
			Если НЕ ЗначениеЗаполнено(LegalEntity.CountryCode) Тогда
				ДобавитьВComment(ТекстОшибок,
					"Failed to find Country code of Legal entity!
					|Release: " + СтруктураЗначений.No + "
					|Path: ReleaseRefnum.ReleaseRefnumValue with ReleaseRefnum.ReleaseRefnumQualifierGid.Gid.Xid = OB_COUNTRY_CODE");	
			КонецЕсли;
			
			СтруктураReleaseRefnums.Свойство("OB_FIN_LOC_CODE", LegalEntity.FinanceLocCode);
			Если НЕ ЗначениеЗаполнено(LegalEntity.FinanceLocCode) Тогда
				ДобавитьВComment(ТекстОшибок,
					"Failed to find Finance loc code of Legal entity!
					|Release: " + СтруктураЗначений.No + "
					|Path: ReleaseRefnum.ReleaseRefnumValue with ReleaseRefnum.ReleaseRefnumQualifierGid.Gid.Xid = OB_FIN_LOC_CODE");
			КонецЕсли;
			
			СтруктураReleaseRefnums.Свойство("OB_FIN_PROCESS", LegalEntity.FinanceProcess);
			Если НЕ ЗначениеЗаполнено(LegalEntity.FinanceProcess) Тогда
				ДобавитьВComment(ТекстОшибок,
					"Failed to find Finance process of Legal entity!
					|Release: " + СтруктураЗначений.No + "
					|Path: ReleaseRefnum.ReleaseRefnumValue with ReleaseRefnum.ReleaseRefnumQualifierGid.Gid.Xid = OB_FIN_PROCESS");	
			КонецЕсли;
			
			Если СтруктураReleaseRefnums.Свойство("OB_RECHARGE_FLAG") И СтруктураReleaseRefnums.OB_RECHARGE_FLAG = "I" Тогда
				
				СтруктураЗначений.RechargeLegalEntity = Новый Структура(СтрокаСвойствLegalEntity);
				
				// Recharge segment
				Если СтруктураReleaseRefnums.Свойство("OB_R_SEGMENT") Тогда
					ДобавитьВComment(СтруктураЗначений.Comments, "Destination segment: " + СтруктураReleaseRefnums.OB_R_SEGMENT);
				КонецЕсли;
				
				// Recharge AU
				СтруктураReleaseRefnums.Свойство("OB_R_COST_CENTER", СтруктураЗначений.AU);
				Если НЕ ЗначениеЗаполнено(СтруктураЗначений.AU) Тогда
					ДобавитьВComment(ТекстОшибок,
						"Failed to find Rechage cost center!
						|Release: " + СтруктураЗначений.No + "
						|Path: ReleaseRefnum.ReleaseRefnumValue with ReleaseRefnum.ReleaseRefnumQualifierGid.Gid.Xid = OB_R_COST_CENTER");	
				КонецЕсли;
				
				// Recharge Activity
				СтруктураReleaseRefnums.Свойство("OB_R_ACT_CODE", СтруктураЗначений.Activity);
				
				// Recharge Legal entity
				RechargeLegalEntity = СтруктураЗначений.RechargeLegalEntity;
				
				СтруктураReleaseRefnums.Свойство("OB_R_ERP_ID", RechargeLegalEntity.ERPID);
				Если НЕ ЗначениеЗаполнено(RechargeLegalEntity.ERPID) Тогда
					ДобавитьВComment(ТекстОшибок,
						"Failed to find ERP ID of Rechage legal entity!
						|Release: " + СтруктураЗначений.No + "
						|Path: ReleaseRefnum.ReleaseRefnumValue with ReleaseRefnum.ReleaseRefnumQualifierGid.Gid.Xid = OB_R_ERP_ID");	
				КонецЕсли;
				
				СтруктураReleaseRefnums.Свойство("OB_R_LEGAL_ENTITY", RechargeLegalEntity.CompanyCode);
				Если НЕ ЗначениеЗаполнено(RechargeLegalEntity.CompanyCode) Тогда
					ДобавитьВComment(ТекстОшибок,
						"Failed to find Company code of Recharge legal entity!
						|Release: " + СтруктураЗначений.No + "
						|Path: ReleaseRefnum.ReleaseRefnumValue with ReleaseRefnum.ReleaseRefnumQualifierGid.Gid.Xid = OB_R_LEGAL_ENTITY");	
				КонецЕсли;
				
				СтруктураReleaseRefnums.Свойство("OB_R_COUNTRY_CODE", RechargeLegalEntity.CountryCode);
				Если НЕ ЗначениеЗаполнено(RechargeLegalEntity.CountryCode) Тогда
					ДобавитьВComment(ТекстОшибок,
						"Failed to find Country code of Recharge legal entity!
						|Release: " + СтруктураЗначений.No + "
						|Path: ReleaseRefnum.ReleaseRefnumValue with ReleaseRefnum.ReleaseRefnumQualifierGid.Gid.Xid = OB_R_COUNTRY_CODE");	
				КонецЕсли;
				
				СтруктураReleaseRefnums.Свойство("OB_R_FIN_LOC_CODE", RechargeLegalEntity.FinanceLocCode);
				Если НЕ ЗначениеЗаполнено(RechargeLegalEntity.FinanceLocCode) Тогда
					ДобавитьВComment(ТекстОшибок,
						"Failed to find Finance loc code of Recharge legal entity!
						|Release: " + СтруктураЗначений.No + "
						|Path: ReleaseRefnum.ReleaseRefnumValue with ReleaseRefnum.ReleaseRefnumQualifierGid.Gid.Xid = OB_R_FIN_LOC_CODE");	
				КонецЕсли;
				
				СтруктураReleaseRefnums.Свойство("OB_R_FIN_PROCESS", RechargeLegalEntity.FinanceProcess);
				Если НЕ ЗначениеЗаполнено(RechargeLegalEntity.FinanceProcess) Тогда
					ДобавитьВComment(ТекстОшибок,
						"Failed to find Finance process of Recharge legal entity!
						|Release: " + СтруктураЗначений.No + "
						|Path: ReleaseRefnum.ReleaseRefnumValue with ReleaseRefnum.ReleaseRefnumQualifierGid.Gid.Xid = OB_R_FIN_PROCESS");	
				КонецЕсли;
				
			КонецЕсли;		
			
		КонецЕсли;
		
		// Paying entity
		МассивOrderRefnum = ПолучитьМассивОбъектовXDTO(Release.TransOrder.TransOrderHeader, "OrderRefnum");
		Попытка
			СтруктураЗначений.PayingEntity = ПолучитьOrderRefnumИзМассива(МассивOrderRefnum, "OB_PAYING_ENTITY").OrderRefnumValue; 
		Исключение
		КонецПопытки;

		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.PayingEntity) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Paying entity!
				|Release: " + СтруктураЗначений.No + "
				|Path: Release.TransOrder.TransOrderHeader.OrderRefnum.OrderRefnumQualifierGid.Gid.Xid.");
		КонецЕсли;	
			
		// Для удобства сконструируем соответствие LocationXid -> Location
		TransOrderLocations = ПолучитьМассивОбъектовXDTO(Release.TransOrder, "Location");
		СоответствиеLocations = ПолучитьСоответствиеLocations(TransOrderLocations);	
		
		// Warehouse to
		Попытка
			СтруктураЗначений.WarehouseTo = СокрЛП(Release.TransOrder.TransOrderHeader.DestuffLocation.LocationRef.LocationGid.Gid.Xid);
		Исключение
		КонецПопытки;
		
		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.WarehouseTo) Тогда
			
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Destuff location!
				|Release: " + СтруктураЗначений.No + "
				|Path: Release.TransOrder.TransOrderHeader.DestuffLocation.LocationRef.LocationGid.Gid.Xid.");	
				
		Иначе
			
			// Положим некоторую информацию из Destuff location в комментарии
			DestuffLocation = СоответствиеLocations[СтруктураЗначений.WarehouseTo];
			Если DestuffLocation = Неопределено Тогда
				
				ДобавитьВComment(ТекстОшибок,
					"Failed to find Destuff location details!
					|Release: " + СтруктураЗначений.No + "
					|Path: Release.TransOrder.Location with LocationGid.Gid.Xid = " + СтруктураЗначений.WarehouseTo);
					
			Иначе
				
				DestuffLocationText = ПолучитьLocationText(DestuffLocation);
				ДобавитьВComment(СтруктураЗначений.Comments, "Destuff location: " + DestuffLocationText);
														
			КонецЕсли;
			
		КонецЕсли;
				
		// Contacts
		ContactsText = ПолучитьContactsText(Release);
		ДобавитьВСтрокуЕслиЗаполнено(СтруктураЗначений.Comments, ContactsText);
			
		// Incoterms
		Попытка                               
			СтруктураЗначений.Incoterms = СокрЛП(Release.ReleaseHeader.CommercialTerms.IncoTermGid.Gid.Xid);
		Исключение	
		КонецПопытки;
				
		// Total price
		Попытка
			TotalPrice = СокрЛП(Release.DeclaredValue.FinancialAmount.MonetaryAmount);
		Исключение
		КонецПопытки;
		
		Если ЗначениеЗаполнено(TotalPrice) Тогда
			
			// ПРЕОБРАЗОВЫВАТЬ В ЧИСЛО ПРЯМО ЗДЕСЬ
			СтруктураЗначений.TotalPrice = TotalPrice;
						
		Иначе
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Release Total price!
				|Release: " + СтруктураЗначений.No + "
				|Path: Release.DeclaredValue.FinancialAmount.MonetaryAmount");	
		КонецЕсли;
					
		// Currency
		Попытка                               
			СтруктураЗначений.Currency = СокрЛП(Release.DeclaredValue.FinancialAmount.GlobalCurrencyCode);
		Исключение	
		КонецПопытки;
		
		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.Currency) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Release Currency!
				|Release: " + СтруктураЗначений.No + "
				|Path: Release.DeclaredValue.FinancialAmount.GlobalCurrencyCode");	
		КонецЕсли;
		
		// Rate
		Попытка
			// ПРЕОБРАЗОВЫВАТЬ В ЧИСЛО ПРЯМО ЗДЕСЬ
			СтруктураЗначений.Rate = СокрЛП(Release.DeclaredValue.FinancialAmount.RateToBase);
		Исключение
		КонецПопытки;		
		
		// Comments
		СтруктураЗначений.Comments = СокрЛП(СтруктураЗначений.Comments);	
		
		// Items
		СтруктурыЗначенийItems = ПолучитьМассивСтруктурТекстовыхЗначенийInvoiceItems(Release);
		Если ТипЗнч(СтруктурыЗначенийItems) = Тип("Строка") Тогда
			ДобавитьВComment(ТекстОшибок, СтруктурыЗначенийItems);
		Иначе
			СтруктураЗначений.Items = СтруктурыЗначенийItems;
		КонецЕсли;
						
		// Parcels
		СтруктурыЗначенийParcels = ПолучитьМассивСтруктурТекстовыхЗначенийParcels(Release);
		Если ТипЗнч(СтруктурыЗначенийParcels) = Тип("Строка") Тогда
			ДобавитьВComment(ТекстОшибок, СтруктурыЗначенийParcels);
		Иначе
			СтруктураЗначений.Parcels = СтруктурыЗначенийParcels;	
		КонецЕсли;
		
		МассивСтруктур.Добавить(СтруктураЗначений);
		
	КонецЦикла;
	
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда
		Возврат ТекстОшибок;
	КонецЕсли;
	
	Возврат МассивСтруктур;
	
КонецФункции

Функция ПолучитьСтруктуруReleaseRefnums(ReleaseRefnums)
	
	СтруктураReleaseRefnums = Новый Структура;
	
	Для Каждого ReleaseRefnum Из ReleaseRefnums Цикл
				
		Попытка
			
			QualifierXid = СокрЛП(ReleaseRefnum.ReleaseRefnumQualifierGid.Gid.Xid);
			Value = СокрЛП(ReleaseRefnum.ReleaseRefnumValue);
			СтруктураReleaseRefnums.Вставить(QualifierXid, Value);

		Исключение	
		КонецПопытки;
					
	КонецЦикла;
			
	Возврат СтруктураReleaseRefnums;		
	
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

Функция ПолучитьContactsText(Release, ReleaseNo = Неопределено)
	
	ContactsText = "";
	
	// Requester
	Попытка
		OrderRefnums = ПолучитьМассивОбъектовXDTO(Release.TransOrder.TransOrderHeader, "OrderRefnum");
	Исключение
		OrderRefnums = Новый Массив;
	КонецПопытки;
	
	RequesterRefnum = ПолучитьOrderRefnumИзМассива(OrderRefnums, "OB_REQUESTER");
	Если RequesterRefnum <> Неопределено Тогда
		
		ДобавитьВComment(ContactsText, "REQUESTER: " + RequesterRefnum.OrderRefnumValue, Символы.ПС);
		
	КонецЕсли;

	// Involved parties
	InvolvedParties = ПолучитьМассивОбъектовXDTO(Release, "InvolvedParty");		
	Для Каждого InvolvedParty Из InvolvedParties Цикл
		
		Попытка
			Contact = InvolvedParty.ContactRef.Contact;
		Исключение
			Продолжить;
		КонецПопытки;
		
		Попытка
			Qualifier = InvolvedParty.InvolvedPartyQualifierGid.Gid.Xid;
		Исключение
			Qualifier = "Unqualified";
		КонецПопытки;
		ДобавитьВComment(ContactsText, Qualifier + ":", Символы.ПС);
		
		FirstName = ПолучитьСвойствоВладельцаXDTO(Contact, "FirstName");
		ДобавитьВСтрокуЕслиЗаполнено(ContactsText, FirstName, " ");
				
		LastName = ПолучитьСвойствоВладельцаXDTO(Contact, "LastName");
		ДобавитьВСтрокуЕслиЗаполнено(ContactsText, LastName, " ");
		
		EMail = ПолучитьСвойствоВладельцаXDTO(Contact, "EmailAddress");
		ДобавитьВСтрокуЕслиЗаполнено(ContactsText, EMail, " ");
		
		Phone = ПолучитьСвойствоВладельцаXDTO(Contact, "Phone1");
		ДобавитьВСтрокуЕслиЗаполнено(ContactsText, Phone, " ");
		
	КонецЦикла;
	
	Если НЕ ЗначениеЗаполнено(ContactsText) Тогда
		Возврат "";
	КонецЕсли;
	
	Если ReleaseNo = Неопределено Тогда 
		Возврат "Contacts:" + ContactsText;
	иначе
		Возврат "Contacts of Release No. " + ReleaseNo + ":" + ContactsText;
	КонецЕсли;
	
КонецФункции

Функция ПолучитьLocationText(Location)
	
	Text = "";
	
	LocationName = ПолучитьСвойствоВладельцаXDTO(Location, "LocationName");
	ДобавитьВСтрокуЕслиЗаполнено(Text, LocationName, "");
	
	Address = ПолучитьСвойствоВладельцаXDTO(Location, "Address");
	Если Address <> Неопределено Тогда
				
		AddressLines = ПолучитьМассивОбъектовXDTO(Address, "AddressLines");
		Для Каждого AddressLine Из AddressLines Цикл		
			ДобавитьВСтрокуЕслиЗаполнено(Text, AddressLine.AddressLine, Символы.ПС);		
		КонецЦикла;
		
		City = ПолучитьСвойствоВладельцаXDTO(Location, "City");
		ДобавитьВСтрокуЕслиЗаполнено(Text, City, Символы.ПС);
		
	КонецЕсли;
	
	Возврат СокрЛП(Text);
		
КонецФункции

// ДОДЕЛАТЬ
Функция ПолучитьМассивСтруктурТекстовыхЗначенийInvoiceItems(Release)
	
	МассивСтруктур = Новый Массив;
	ТекстОшибок = "";
	ReleaseNo = Release.ReleaseGid.Gid.Xid;
	
	ReleaseLines = ПолучитьМассивОбъектовXDTO(Release, "ReleaseLine");
	Если ReleaseLines.Количество() = 0 Тогда 
		Возврат "Failed to find Release lines!
			|Release: " + ReleaseNo + "
			|Path: Release.ReleaseLines";
	КонецЕсли;
	     	
	// Сформируем соответствие Part no. и Description, а также Part no. и HTS
	СоответствиеDescriptions = Новый Соответствие;
	СоответствиеPartNoCountryHTS = Новый Соответствие;
	
	TransOrder = ПолучитьСвойствоВладельцаXDTO(Release, "TransOrder");	
	Если TransOrder = Неопределено Тогда
		Возврат "Failed to find Trans order!
			|Release: " + ReleaseNo + "
			|Path: Release.TransOrder";	
	КонецЕсли;
	
	PackagedItems = ПолучитьМассивОбъектовXDTO(TransOrder, "PackagedItem");
	Если PackagedItems.Количество() = 0 Тогда
		Возврат "Failed to find Package items of Trans order!
			|Release: " + ReleaseNo + "
			|Path: Release.TransOrder.PackagedItem";
	КонецЕсли;

	// СДЕЛАТЬ С ИСКЛЮЧЕНИЯМИ
	Для Каждого PackagedItem Из PackagedItems Цикл 
			
		Попытка
			ItemNode = PackagedItem.Item;
		Исключение
			Продолжить;
		КонецПопытки;
		
		Попытка
			PartNo = СокрЛП(ItemNode.ItemGid.Gid.Xid);
		Исключение
			// Нет PartNo - нет и соответствия
			Продолжить;
		КонецПопытки;
		
		Попытка
			Description = СокрЛП(ItemNode.Description);
			СоответствиеDescriptions.Вставить(PartNo, Description);
		Исключение
		КонецПопытки;
		
		// С HTC сложнее, так как один Part no может соответствовать разным HTC в разных странах
		СоответствиеCountryHTS = СоответствиеPartNoCountryHTS.Получить(PartNo);
		Если СоответствиеCountryHTS = Неопределено Тогда
			СоответствиеCountryHTS = Новый Соответствие;
			СоответствиеPartNoCountryHTS.Вставить(PartNo, СоответствиеCountryHTS);
		КонецЕсли;
		
		GtmItemClassifications = ПолучитьМассивОбъектовXDTO(ItemNode, "GtmItemClassification");
		
		Для Каждого GtmItemClassification Из GtmItemClassifications Цикл
			
			Попытка
				HTSCountry = СокрЛП(GtmItemClassification.GtmProdClassTypeGid.Gid.Xid);
			Исключение
				Продолжить;
			КонецПопытки;
			
			Попытка
				HTSCode = СокрЛП(GtmItemClassification.ClassificationCode);
				СоответствиеCountryHTS.Вставить(HTSCountry, HTSCode);
			Исключение
			КонецПопытки;
			
		КонецЦикла;
			
	КонецЦикла;
			
	// Сформируем соответствие Import Reference и ERP Treatment, чтобы затем найти по Import Reference строки нужное значение ERP Treatment 
	СоответствиеERPTreatments = Новый Соответствие;
	
	// То, что ERP treatment хранится на уровне ShipUnit - это временных косяк TMS. Потом должно быть правильно и просто.
	ShipUnits = ПолучитьМассивОбъектовXDTO(Release, "ShipUnit");
	Если ShipUnits.Количество() = 0 Тогда
		ДобавитьВComment(ТекстОшибок,
			"Failed to find Ship units!
			|Release: " + ReleaseNo + "
			|Path: Release.ShipUnit");
		Возврат СокрЛП(ТекстОшибок);
	КонецЕсли;
	
	// СДЕЛАТЬ С ИСКЛЮЧЕНИЯМИ
	Для Каждого ShipUnit Из ShipUnits Цикл 
		
		Попытка
			ImportReference = СокрЛП(ShipUnit.ShipUnitContent.ReleaseLineGid.Gid.Xid);
			ERPTreatment = СокрЛП(ShipUnit.TagInfo.ItemTag3);
			СоответствиеERPTreatments.Вставить(ImportReference, ERPTreatment);
		Исключение
		КонецПопытки;
		
	КонецЦикла;
		         			
    НомерСтроки = 0;
	Для Каждого ReleaseLine из ReleaseLines Цикл 
		
		НомерСтроки = НомерСтроки + 1;
		
		СтруктураЗначений = Новый Структура(
			"ImportReference, PONo, PartNo, Description, SerialNo, QTY, QtyUOM, TotalPrice, ERPTreatment, CountryOfOrigin, TotalNetWeight, NetWeightUOM, TotalPrice, Rate, МассивСтруктурFreight, СоответствиеCountryHTS");	
			
		// Import reference   
		Попытка                               
			ReleaseLineNo = СокрЛП(ReleaseLine.ReleaseLineGid.Gid.Xid);
		Исключение
		КонецПопытки;
				
		Если НЕ ЗначениеЗаполнено(ReleaseLineNo) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Release line no.!
				|Release: " + ReleaseNo + "
				|Path: ReleaseLine.ReleaseLineGid.Gid.Xid");
			Продолжить;
		КонецЕсли;
		
		// Import reference
		СтруктураЗначений.ImportReference = ReleaseLineNo;
		
		// ERP treatment
		СтруктураЗначений.ERPTreatment = СоответствиеERPTreatments.Получить(ReleaseLineNo);

		// PO No   
		Попытка                               
			СтруктураЗначений.PONo = СокрЛП(ReleaseLine.OrderBaseGid.Gid.Xid);
		Исключение
		КонецПопытки;
		
		// Part No   
		Попытка                               
			СтруктураЗначений.PartNo = СокрЛП(ReleaseLine.PackagedItemRef.PackagedItemGid.Gid.Xid);
		Исключение
		КонецПопытки;
		
		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.PartNo) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Part no.!
				|Release line: " + ReleaseLineNo + "
				|Path: ReleaseLine.PackagedItemRef.PackagedItemGid.Gid.Xid");	
		КонецЕсли;
		
		// Description, СоответствиеCountryHTS
		
		СтруктураЗначений.Description = СоответствиеDescriptions.Получить(СтруктураЗначений.PartNo);
		
		// ПОНЯТЬ ПОЧЕМУ ИНОГДА НЕТ И РАСКОММЕНТИРОВАТЬ
		//Если НЕ ЗначениеЗаполнено(СтруктураЗначений.Description) Тогда
		//	ВызватьИсключение "Failed to find Description of Item #" + СтруктураЗначений.PartNo + "!";	
		//КонецЕсли;
		
		СтруктураЗначений.СоответствиеCountryHTS = СоответствиеPartNoCountryHTS.Получить(СтруктураЗначений.PartNo);
		
		Если СтруктураЗначений.СоответствиеCountryHTS = Неопределено Тогда
			СтруктураЗначений.СоответствиеCountryHTS = Новый Соответствие;
		КонецЕсли;
		
		// Получим структуру ItemQuantity, т.к. будем часто к ней обращаться
		ItemQuantity = ПолучитьСвойствоВладельцаXDTO(ReleaseLine, "ItemQuantity");
		Если ItemQuantity = Неопределено Тогда
			
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Item quantity!
				|Release line: " + ReleaseLineNo + "
				|Path: ReleaseLine.ItemQuantity");
			Продолжить;
			
		КонецЕсли;
			
		// Serial no.     
		Попытка                               
			СтруктураЗначений.SerialNo = СокрЛП(ItemQuantity.ItemTag1);
		Исключение
		КонецПопытки;
		
		// QTY                                      
		QtyСтрока = ПолучитьСвойствоВладельцаXDTO(ItemQuantity, "PackagedItemCount");
		Если НЕ ЗначениеЗаполнено(QtyСтрока) Тогда
			
			ДобавитьВComment(ТекстОшибок,
				"Failed to find item quantity!
				|Release line: " + ReleaseLineNo + "
				|Path: ReleaseLine.ItemQuantity.PackagedItemCount");	
				
		Иначе
			
			// СДЕЛАТЬ БЕЗ ПОПЫТКИ
			Попытка
				СтруктураЗначений.QTY = ПреобразоватьСтрокуВЧисло(QtyСтрока);
			Исключение
				
				ДобавитьВComment(ТекстОшибок,
					"Failed to convert '" + QtyСтрока + "' to item quantity!
					|Release line: " + ReleaseLineNo + "
					|Path: ReleaseLine.ItemQuantity.PackagedItemCount");
				
			КонецПопытки;
			
		КонецЕсли;		
				
		// Qty UOM             
		Попытка                               
			СтруктураЗначений.QtyUOM = СокрЛП(ReleaseLine.PackagedItemSpecRef.ShipUnitSpecRef.ShipUnitSpecGid.Gid.Xid);
		Исключение
		КонецПопытки;
		
		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.QtyUOM) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Quantity UOM!
				|Release line: " + ReleaseLineNo + "
				|Path: ReleaseLine.PackagedItemSpecRef.ShipUnitSpecRef.ShipUnitSpecGid.Gid.Xid");	
		КонецЕсли;
		
		// Total price             
		Попытка                               
			СтруктураЗначений.TotalPrice = СокрЛП(ReleaseLine.ItemQuantity.DeclaredValue.FinancialAmount.MonetaryAmount);
		Исключение		
		КонецПопытки;		
		
		// ПЫТАТЬСЯ ПРЕОБРАЗОВАТЬ В ЧИСЛО
		
		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.TotalPrice) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Total price!
				|Release line: " + ReleaseLineNo + "
				|Path: ReleaseLine.ItemQuantity.DeclaredValue.FinancialAmount.MonetaryAmount");	
		КонецЕсли;
		
		// Rate
		Попытка                               
			СтруктураЗначений.Rate = СокрЛП(ReleaseLine.ItemQuantity.DeclaredValue.FinancialAmount.RateToBase);
			// ПЫТАТЬСЯ ПРЕОБРАЗОБВАТЬ В ЧИСЛО
		Исключение		
		КонецПопытки;
				
		// Country Of Origin             
		Попытка                               
			СтруктураЗначений.CountryOfOrigin = СокрЛП(ItemQuantity.ItemTag4);
		Исключение	
		КонецПопытки;
				
		// Total Net Weight             
		Попытка                               
			СтруктураЗначений.TotalNetWeight = СокрЛП(ItemQuantity.WeightVolume.Weight.WeightValue);
			// ПЫТАТЬСЯ ПРЕОБРАЗОВАТЬ В ЧИСЛО
		Исключение
		КонецПопытки;

		// Net Weight UOM             
		Попытка                               
			СтруктураЗначений.NetWeightUOM = СокрЛП(ItemQuantity.WeightVolume.Weight.WeightUOMGid.Gid.Xid);
		Исключение
		КонецПопытки;
				
		// Freight
		СтруктураЗначений.МассивСтруктурFreight = Новый Массив;
		
		// ПОДУМАТЬ, ГДЕ МОГУТ БЫТЬ ОШИБКИ СО СТОРОНЫ TMS
		ReleaseLineAllocationInfo = ПолучитьСвойствоВладельцаXDTO(ReleaseLine, "ReleaseLineAllocationInfo");		
		Если ReleaseLineAllocationInfo <> Неопределено Тогда
			
			ReleaseLineAllocByTypes = ПолучитьМассивОбъектовXDTO(ReleaseLineAllocationInfo, "ReleaseLineAllocByType");			
			Для Каждого ReleaseLineAllocByType Из ReleaseLineAllocByTypes Цикл
				
				ReleaseAllocShipments = ПолучитьМассивОбъектовXDTO(ReleaseLineAllocByType, "ReleaseAllocShipment");
				
				Для Каждого ReleaseAllocShipment Из ReleaseAllocShipments Цикл
					Попытка
						FinancialAmount = ReleaseAllocShipment.TotalAllocCost.FinancialAmount;
						СтруктураFreight = Новый Структура;
						СтруктураFreight.Вставить("MonetaryAmount", FinancialAmount.MonetaryAmount);
						СтруктураFreight.Вставить("RateToBase", FinancialAmount.RateToBase); 
						СтруктураЗначений.МассивСтруктурFreight.Добавить(СтруктураFreight);
					Исключение
					КонецПопытки;
				КонецЦикла;
				
			КонецЦикла;
			
		КонецЕсли;
				
		МассивСтруктур.Добавить(СтруктураЗначений);
		
	КонецЦикла;
	
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда
		Возврат ТекстОшибок;
	КонецЕсли;
	
	Возврат МассивСтруктур;
	
КонецФункции

// ДОДЕЛАТЬ
Функция ПолучитьМассивСтруктурТекстовыхЗначенийParcels(Release)
	
	МассивСтруктур = Новый Массив;
	ТекстОшибок = "";
	ReleaseNo = СокрЛП(Release.ReleaseGid.Gid.Xid);
	
	// Попробуем получить массив Ship units
	ShipUnits = ПолучитьМассивОбъектовXDTO(Release, "ShipUnit");	
	Если ShipUnits.Количество() = 0 Тогда
		Возврат "Failed to find Ship units!
			|Release: " + ReleaseNo + "
			|Path: Release.ShipUnit";
	КонецЕсли;
	
	Для Каждого ShipUnit из ShipUnits Цикл 
					
		СтруктураЗначений = Новый Структура(
			"No, DONo, PackingType, NumOfParcels, Length, Width, Height, DIMsUOM, GrossWeight, WeightUOM, ParcelLines");
					
		Попытка
			ShipUnitNo = СокрЛП(ShipUnit.ShipUnitGid.Gid.Xid);
		Исключение
		КонецПопытки;

		// без номера не сможем найти/создать Parcel, поэтому переходим к следующему ShipUnit
		Если Не ЗначениеЗаполнено(ShipUnitNo) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Ship unit no.!
				|Release: " + ReleaseNo + "
				|Path: ShipUnit.ShipUnitGid.Gid.Xid");
			Продолжить;
		КонецЕсли;
		
		// Parcel no.
		СтруктураЗначений.No = ShipUnitNo;
				
		// DO no.
		СтруктураЗначений.DONo = ReleaseNo;
		
		//Packing type
		Попытка
			СтруктураЗначений.PackingType = СокрЛП(ShipUnit.TransportHandlingUnitRef.ShipUnitSpecRef.ShipUnitSpecGid.Gid.Xid);
		Исключение
		КонецПопытки;
		
		//Num. of parcels
		Попытка
			СтруктураЗначений.NumOfParcels = СокрЛП(ShipUnit.ShipUnitCount);
		Исключение
		КонецПопытки;
		
		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.NumOfParcels) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Ship unit count!
				|Ship unit: " + ShipUnit + "
				|Path: ShipUnit.ShipUnitCount");	
		КонецЕсли;
		
		//Legnth Width Height
		LengthWidthHeight = ПолучитьСвойствоВладельцаXDTO(ShipUnit, "LengthWidthHeight");
		
		// Без этого узла не имеет смысла дальше продолжать - перейдем к следующему Ship unit
		Если LengthWidthHeight = Неопределено Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Dimensions!
				|Ship unit: " + ShipUnitNo + "
				|Path: ShipUnit.LengthWidthHeight");
			Продолжить;
		КонецЕсли;
			
		//Length
		Попытка
			СтруктураЗначений.Length = СокрЛП(LengthWidthHeight.Length.LengthValue);
		Исключение
		КонецПопытки;
		
		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.Length) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Length!
				|Ship unit: " + ShipUnitNo + "
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
				|Ship unit: " + ShipUnitNo + "
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
				|Ship unit: " + ShipUnitNo + "
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
				|Ship unit: " + ShipUnitNo + "
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
				|Ship unit: " + ShipUnitNo + "
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
				|Ship unit: " + ShipUnitNo + "
				|Path: ShipUnit.LengthWidthHeight.Height.HeightUOMGid.Gid.Xid");	
		КонецЕсли;
		
		//DIMs UOM
		Если LengthUOM = WidthUOM И LengthUOM = HeightUOM Тогда
			СтруктураЗначений.DIMsUOM = LengthUOM;
		Иначе
			ДобавитьВComment(ТекстОшибок,
				"Length UOM """ + LengthUOM + """ differs from Width UOM """ + WidthUOM + """ or Height UOM """ + HeightUOM + """!
				|Ship unit: " + ShipUnitNo);
		КонецЕсли;
			
		//Total gross weight
		Попытка
			СтруктураЗначений.GrossWeight = СокрЛП(ShipUnit.WeightVolume.Weight.WeightValue);
		Исключение
		КонецПопытки;
		
		Если НЕ ЗначениеЗаполнено(СтруктураЗначений.GrossWeight) Тогда
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Gross weight!
				|Ship unit: " + ShipUnitNo + "
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
				|Ship unit: " + ShipUnitNo + "
				|Path: ShipUnit.WeightVolume.Weight.WeightUOMGid.Gid.Xid");	
		КонецЕсли;
		
		// Parcel lines
		ParcelLines = ПолучитьМассивParcelLines(ShipUnit);
		Если ТипЗнч(ParcelLines) = Тип("Строка") Тогда
			ДобавитьВComment(ТекстОшибок, ParcelLines);
		Иначе
			СтруктураЗначений.ParcelLines = ParcelLines;
		КонецЕсли;
		   						
		МассивСтруктур.Добавить(СтруктураЗначений);
		
	КонецЦикла;
	
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда
		Возврат СокрЛП(ТекстОшибок);	
	КонецЕсли;
	
	Возврат МассивСтруктур;
	
КонецФункции

Функция ПолучитьМассивParcelLines(ShipUnit)
	
	МассивParcelLines = Новый Массив;
	ТекстОшибок = "";
	
	ShipUnitNo = СокрЛП(ShipUnit.ShipUnitGid.Gid.Xid);
	
	ShipUnitContents = ПолучитьМассивОбъектовXDTO(ShipUnit, "ShipUnitContent");
	
	Если ShipUnitContents.Количество() = 0 Тогда
		Возврат "Failed to find Ship unit content!
			|Ship unit: " + ShipUnitNo + "
			|Path: ShipUnit.ShipUnitContent";
	КонецЕсли;
	
	Для Каждого ShipUnitContent Из ShipUnitContents Цикл 
		
		Попытка
			МассивParcelLines.Добавить(ShipUnitContent.ReleaseLineGid.Gid.Xid);
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to find Release line!
				|Ship unit: " + ShipUnitNo + "
				|Path: ShipUnit.ShipUnitContent.ReleaseLineGid.Gid.Xid");
		КонецПопытки;
		
	КонецЦикла;
	
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда
		Возврат ТекстОшибок;
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


// СТРУКТУРА РЕЗУЛЬТАТОВ ЗАПРОСОВ

Функция ПолучитьСтруктуруОбъектовБазы(СтруктураТекстовыхЗначений)
	
	// Сформируем пакет запросов
	СтруктураПараметров = Новый Структура;
	СтруктураТекстов = Новый Структура;
	
	СтруктураПараметров.Вставить("DOCNo", СтруктураТекстовыхЗначений.No);
	СтруктураТекстов.Вставить("DOC",
		"ВЫБРАТЬ
		|	DOCs.Ссылка
		|ИЗ
		|	Документ.КонсолидированныйПакетЗаявокНаПеревозку КАК DOCs
		|ГДЕ
		|	DOCs.Номер = &DOCNo
		|	И НЕ DOCs.Отменен");
		
	// КАНДИДАТ НА ПЕРЕНОС В МОДУЛЬ МЕНЕДЖЕРА СПРАВОЧНИКА
	СтруктураПараметров.Вставить("POD", СтруктураТекстовыхЗначений.POD);
	СтруктураТекстов.Вставить("POD",
		"ВЫБРАТЬ
		|	CountriesHUBs.Ссылка,
		|	CountriesHUBs.Код
		|ИЗ
		|	Справочник.CountriesHUBs КАК CountriesHUBs
		|ГДЕ
		|	НЕ CountriesHUBs.ПометкаУдаления
		|	И CountriesHUBs.TMSID = &POD");
		
	// НЕ НАДО МУЧИТЬСЯ С ОДНИМ ПАКЕТОМ, ПУСТЬ ВСЕ БУДЕТ ПОНЯТНЕЕ
	
	Invoices	= Новый Массив;
	Parcels		= Новый Массив;
    
	// Перебираем Invoices
	Для Каждого СтруктураИнвойса Из СтруктураТекстовыхЗначений.Invoices Цикл
		
		Invoices.Добавить(СтруктураИнвойса.No);
						
		// Перебираем Parcels 
		Для Каждого СтруктураParcel Из СтруктураИнвойса.Parcels Цикл

			Parcels.Добавить(СтруктураParcel.No);
						
		КонецЦикла;

	КонецЦикла;	
		
	СтруктураПараметров.Вставить("Invoices", Invoices);
	СтруктураТекстов.Вставить("TempImportInvoices",
		"ВЫБРАТЬ
		|	ImportInvoices.Ссылка КАК Ссылка,
		|	ВЫРАЗИТЬ(ImportInvoices.Номер КАК СТРОКА(25)) КАК Номер,
		|	КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка КАК DOC
		|ПОМЕСТИТЬ ImportInvoices
		|ИЗ
		|	Документ.Инвойс КАК ImportInvoices
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы
		|		ПО ImportInvoices.Ссылка = КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Инвойс
		|			И (НЕ КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка.Отменен)
		|ГДЕ
		|	ImportInvoices.Номер В(&Invoices)
		|	И НЕ ImportInvoices.Отменен
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Ссылка");
			
	СтруктураТекстов.Вставить("Invoices",		
		"ВЫБРАТЬ
		|	ImportInvoices.Ссылка,
		|	ImportInvoices.Номер,
		|   ImportInvoices.DOC
		|ИЗ
		|	ImportInvoices КАК ImportInvoices");
			
	СтруктураТекстов.Вставить("Items",
	    "ВЫБРАТЬ
	    |	Items.Ссылка,
		|	Items.Инвойс КАК Invoice,
	    |	Items.ImportReference
	    |ИЗ
	    |	ImportInvoices КАК ImportInvoices
	    |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК Items
	    |		ПО (ImportInvoices.Ссылка = Items.Инвойс)
	    |			И (НЕ Items.ПометкаУдаления)");
					
	СтруктураПараметров.Вставить("Parcels", Parcels);
	СтруктураТекстов.Вставить("Parcels",
		"ВЫБРАТЬ
		|	Parcels.Ссылка,
		|	ВЫРАЗИТЬ(Parcels.Код КАК СТРОКА(30)) КАК Код,
		|	КонсолидированныйПакетЗаявокНаПеревозкуParcels.Ссылка КАК DOC
		|ИЗ
		|	Справочник.Parcels КАК Parcels
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Parcels КАК КонсолидированныйПакетЗаявокНаПеревозкуParcels
		|		ПО Parcels.Ссылка = КонсолидированныйПакетЗаявокНаПеревозкуParcels.Parcel
		|			И (НЕ КонсолидированныйПакетЗаявокНаПеревозкуParcels.Ссылка.Отменен)
		|ГДЕ
		|	Parcels.Код В(&Parcels)
		|	И НЕ Parcels.Отменен");
	
	// Выполним пакет запросов
	УстановитьПривилегированныйРежим(Истина);	
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	// Разберем результаты
	СтруктураОбъектовБазы = Новый Структура("DOC, POD, PODCode, Invoices, Items, Parcels");
	
	// DOC
	СтруктураОбъектовБазы.Вставить("DOC");
	ВыборкаDOC = СтруктураРезультатов.DOC.Выбрать();
	Если ВыборкаDOC.Следующий() Тогда
		СтруктураОбъектовБазы.DOC = ВыборкаDOC.Ссылка;
	КонецЕсли;
		
	// POD
	Если СтруктураРезультатов.Свойство("POD") Тогда
		
		ВыборкаPOD = СтруктураРезультатов.POD.Выбрать();
		Если ВыборкаPOD.Следующий() Тогда
			СтруктураОбъектовБазы.POD = ВыборкаPOD.Ссылка;
			СтруктураОбъектовБазы.PODCode = СокрЛП(ВыборкаPOD.Код);
		КонецЕсли;
		
	КонецЕсли;
								
	// Invoices	
	СтруктураОбъектовБазы.Вставить("Invoices", СтруктураРезультатов.Invoices.Выгрузить());
	РГСофтКлиентСервер.СокрЛПКолонокВТаблице(СтруктураОбъектовБазы.Invoices, "Номер");
	СтруктураОбъектовБазы.Invoices.Индексы.Добавить("Номер");
		
	// Items	
	СтруктураОбъектовБазы.Вставить("Items", СтруктураРезультатов.Items.Выгрузить());
	СтруктураОбъектовБазы.Items.Индексы.Добавить("Invoice");
		
	// Parcels		
	СтруктураОбъектовБазы.Вставить("Parcels", СтруктураРезультатов.Parcels.Выгрузить());
	РГСофтКлиентСервер.СокрЛПКолонокВТаблице(СтруктураОбъектовБазы.Parcels, "Код");
	СтруктураОбъектовБазы.Parcels.Индексы.Добавить("Код");
	
	Возврат СтруктураОбъектовБазы;
	
КонецФункции


// СОЗДАНИЕ/ЗАПОЛНЕНИЕ ДОКУМЕНТОВ И СПРАВОЧНИКОВ

// ДОДЕЛАТЬ
Функция СоздатьОбновитьОбъекты(СтруктураТекстовыхЗначений, СтруктураОбъектовБазы)
	
	// Создает или обновляет DOC, Invoices, Parcels.
	// В случае ошибки - возвращает текст ошибок
	// В случае успеха - пустую строку
	
	// ИЗБАВИТЬСЯ ОТ СТРУКТУРЫ ОБЪЕКТОВ БАЗЫ
	
	ТекстОшибок = "";
	
	Если ЗначениеЗаполнено(СтруктураОбъектовБазы.DOC) Тогда
		
		DOCОбъект = СтруктураОбъектовБазы.DOC.ПолучитьОбъект();
		Если ЗначениеЗаполнено(DOCОбъект.Granted) Тогда
			Возврат "Green light was already granted for DOC #" + СокрЛП(DOCОбъект.Номер);	
		КонецЕсли;
		
	Иначе
		DOCОбъект = Документы.КонсолидированныйПакетЗаявокНаПеревозку.СоздатьДокумент();
		DOCОбъект.Номер = СтруктураТекстовыхЗначений.No;
	КонецЕсли;
	
	DOCОбъект.CurrentComment = СокрЛП(СтруктураТекстовыхЗначений.Comments);
	
	// Date 
	DOCОбъект.Дата = ТекущаяДата();	
	
	Если Не ЗначениеЗаполнено(DOCОбъект.Дата) Тогда 
		DOCОбъект.Дата = ТекущаяДата();
	КонецЕсли;

	// Process level
	ProcessLevel = ImportExportСерверПовтИспСеанс.ПолучитьProcessLevelПоCountryCodeИTMSID(СтруктураТекстовыхЗначений.RequestedPOACountryCode, СтруктураТекстовыхЗначений.RequestedPOACorporation);
	Если ЗначениеЗаполнено(ProcessLevel) Тогда
		DOCОбъект.ProcessLevel = ProcessLevel;
	Иначе
		DOCОбъект.ProcessLevel = Справочники.ProcessLevels.RUWE;
		ДобавитьВComment(DOCОбъект.CurrentComment, "! Failed to find Process level by Country code '" + СтруктураТекстовыхЗначений.RequestedPOACountryCode + "' and TMS Id '" + СтруктураТекстовыхЗначений.RequestedPOACorporation + "'!");			
	КонецЕсли;
	
	// POD
	Если ЗначениеЗаполнено(СтруктураТекстовыхЗначений.POD) Тогда
		
		Если ЗначениеЗаполнено(СтруктураОбъектовБазы.POD) Тогда
			DOCОбъект.POD = СтруктураОбъектовБазы.POD;
		Иначе
			ДобавитьВComment(DOCОбъект.CurrentComment, "! Failed to find POD by TMS Id """ + СтруктураТекстовыхЗначений.POD + """!");
		КонецЕсли;
		
	КонецЕсли;
	
	// Requested POA
	Если ЗначениеЗаполнено(СтруктураТекстовыхЗначений.RequestedPOA) Тогда
		
		RequestedPOA = ImportExportСерверПовтИспСеанс.ПолучитьPortПоTMSID(СтруктураТекстовыхЗначений.RequestedPOA);
		Если ЗначениеЗаполнено(RequestedPOA) Тогда
			DOCОбъект.RequestedPOA = RequestedPOA;
		Иначе
			ДобавитьВComment(DOCОбъект.CurrentComment, "! Failed to find Requested POA by TMS Id '" + СтруктураТекстовыхЗначений.RequestedPOA + "'!");
		КонецЕсли;
		
	КонецЕсли;
	
	// MOT	
	MOT = ImportExportСерверПовтИспСеанс.ПолучитьMOTПоTMSID(СтруктураТекстовыхЗначений.MOT);
	Если ЗначениеЗаполнено(MOT) Тогда
		DOCОбъект.MOT = MOT;
	Иначе
		ДобавитьВComment(DOCОбъект.CurrentComment, "! Failed to find MOT by TMS Id """ + СтруктураТекстовыхЗначений.MOT + """!");
	КонецЕсли;

	// Urgency
	Urgency = 3;
	Для Каждого Invoice из СтруктураТекстовыхЗначений.Invoices Цикл
		
		// КОНВЕРТИРОВАТЬ ПРИ РАЗБОРЕ XDTO, А НЕ ЗДЕСЬ
		Попытка
			NewUrgency = ПреобразоватьСтрокуВЧисло(Invoice.Urgency);
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to convert """ + Invoice.Urgency + """ to urgency!");
			Продолжить;
		КонецПопытки; 
			
		Если NewUrgency < Urgency Тогда 
			Urgency = NewUrgency;
		КонецЕсли;
				
	КонецЦикла;
	    	
	Если Urgency = 1 Тогда 
		DOCОбъект.Urgency = Перечисления.Urgencies.Emergency;
	ИначеЕсли Urgency = 2 Тогда 
		DOCОбъект.Urgency = Перечисления.Urgencies.Urgent;
	Иначе
		DOCОбъект.Urgency = Перечисления.Urgencies.Standard;
	КонецЕсли;
	
	DOCОбъект.Инвойсы.Очистить();
	DOCОбъект.Parcels.Очистить();
	
	// Создаддим / обновим Invoices и Parcels
	ТекстОшибокПриСозданииОбновленииInvoicesИParcels = СоздатьОбновитьInvoicesИParcels(СтруктураТекстовыхЗначений, СтруктураОбъектовБазы, DOCОбъект);
	Если ЗначениеЗаполнено(ТекстОшибокПриСозданииОбновленииInvoicesИParcels) Тогда
		ДобавитьВComment(ТекстОшибок, ТекстОшибокПриСозданииОбновленииInvoicesИParcels);	
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда
		Возврат ТекстОшибок;
	КонецЕсли;
	
	РежимЗаписи = ?(DOCОбъект.Проведен, РежимЗаписиДокумента.Проведение, РежимЗаписиДокумента.Запись);
	DOCОбъект.Записать(РежимЗаписи);
		
	Возврат ТекстОшибок;
	
КонецФункции

Функция СоздатьОбновитьInvoicesИParcels(СтруктураТекстовыхЗначений, СтруктураОбъектовБазы, DOCОбъект)
	
	ТекстОшибок = "";
	
	МассивСтруктурТекстовыхЗначенийInvoices = СтруктураТекстовыхЗначений.Invoices;
	
	Для Каждого СтруктураТекстовыхЗначенийInvoice Из МассивСтруктурТекстовыхЗначенийInvoices Цикл 
		
		// Invoice
		СтрокаInvoices = СтруктураОбъектовБазы.Invoices.Найти(СтруктураТекстовыхЗначенийInvoice.No, "Номер");
		Если СтрокаInvoices = Неопределено Тогда
			
			InvoiceОбъект = Документы.Инвойс.СоздатьДокумент();
			InvoiceСсылка = Документы.Инвойс.ПолучитьСсылку();
			InvoiceОбъект.УстановитьСсылкуНового(InvoiceСсылка);
			InvoiceОбъект.Номер = СтруктураТекстовыхЗначенийInvoice.No;
			
		Иначе
			
			Если ЗначениеЗаполнено(СтрокаInvoices.DOC) и СтрокаInvoices.DOC <> DOCОбъект.Ссылка Тогда 
				ДобавитьВComment(ТекстОшибок, "! Release " + СтруктураТекстовыхЗначенийInvoice.No 
					+ " is already used in Planned Shipment " + СокрЛП(СтрокаInvoices.DOC.Номер) + "!");		
				Продолжить;
			КонецЕсли;
			
			InvoiceОбъект = СтрокаInvoices.Ссылка.ПолучитьОбъект();
			InvoiceСсылка = СтрокаInvoices.Ссылка;
						
		КонецЕсли;
		
		// Добавим в ТЧ DOC.Invoices
		НоваяСтрокаDOCInvoices = DOCОбъект.Инвойсы.Добавить();
		НоваяСтрокаDOCInvoices.Инвойс = InvoiceСсылка;
		
		InvoiceОбъект.АрхивИмпортЭкспорт = Перечисления.ИмпортЭкспорт.Import;
		
		InvoiceОбъект.TMS = Истина;
		
		// Comment
		InvoiceОбъект.Comment = СокрЛП(СтруктураТекстовыхЗначенийInvoice.Comments);	
			
		// Date   
		InvoiceОбъект.Дата = DOCОбъект.Дата;
			
		// Process level
		Если ЗначениеЗаполнено(DOCОбъект.ProcessLevel) Тогда
			InvoiceОбъект.ProcessLevel = DOCОбъект.ProcessLevel;
		КонецЕсли;	
						
		// DO no.
		InvoiceОбъект.НомерЗаявкиНаДоставку = СтруктураТекстовыхЗначенийInvoice.No;
		
		// Seller
		СтруктураSeller = СтруктураТекстовыхЗначенийInvoice.LegalEntity;
		Seller = ImportExportСерверПовтИспСеанс.ПолучитьLegalEntityПоРеквизитамTMS(
			СтруктураSeller.CompanyCode,
			СтруктураSeller.CountryCode,
			СтруктураSeller.ERPID,
			СтруктураSeller.FinanceLocCode,
			СтруктураSeller.FinanceProcess);
			
		Если ЗначениеЗаполнено(Seller) Тогда
			InvoiceОбъект.Продавец = Seller;
		Иначе
			ДобавитьВComment(InvoiceОбъект.Comment, "! Failed to find Seller by Company code """ + СтруктураSeller.CompanyCode + """, Country code """ + СтруктураSeller.CountryCode + """, ERP ID """ + СтруктураSeller.ERPID + """, Finance loc code """ + СтруктураSeller.FinanceLocCode + """, Finance process """ + СтруктураSeller.FinanceProcess + """!");		
		КонецЕсли;
		
		// Sold-to
		Если СтруктураТекстовыхЗначенийInvoice.RechargeLegalEntity <> Неопределено Тогда

			СтруктураRechargeLegalEntity = СтруктураТекстовыхЗначенийInvoice.RechargeLegalEntity;
			RechargeLegalEntity = ImportExportСерверПовтИспСеанс.ПолучитьLegalEntityПоРеквизитамTMS(
				СтруктураRechargeLegalEntity.CompanyCode,
				СтруктураRechargeLegalEntity.CountryCode,
				СтруктураRechargeLegalEntity.ERPID,
				СтруктураRechargeLegalEntity.FinanceLocCode,
				СтруктураRechargeLegalEntity.FinanceProcess);
				
			Если ЗначениеЗаполнено(RechargeLegalEntity) Тогда
				
				ParentCompany = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(RechargeLegalEntity, "ParentCompany");
				Если ЗначениеЗаполнено(ParentCompany) Тогда
					InvoiceОбъект.Покупатель = ParentCompany;
				Иначе
					ДобавитьВComment(InvoiceОбъект.Comment, "! Failed to find Sold-to because Parent company is empty in Legal entity """ + RechargeLegalEntity + """!");	
				КонецЕсли;
				
			Иначе
				ДобавитьВComment(InvoiceОбъект.Comment, "! Failed to find TMS recharge legal entity by Company code """ + СтруктураRechargeLegalEntity.CompanyCode + """, Country code """ + СтруктураRechargeLegalEntity.CountryCode + """, ERP ID """ + СтруктураRechargeLegalEntity.ERPID + """, Finance loc code """ + СтруктураRechargeLegalEntity.FinanceLocCode + """, Finance process """ + СтруктураRechargeLegalEntity.FinanceProcess + """!");
			КонецЕсли;
									
		КонецЕсли;
		
		// Consign to + Parent company	
		Если ЗначениеЗаполнено(СтруктураТекстовыхЗначений.ConsignTo) Тогда
			
			ConsignTo = ImportExportСерверПовтИспСеанс.ПолучитьConsignToПоTMSID(СтруктураТекстовыхЗначений.ConsignTo);
			Если ЗначениеЗаполнено(ConsignTo) Тогда
				
				InvoiceОбъект.Декларант = ConsignTo;
				
				Если НЕ ЗначениеЗаполнено(InvoiceОбъект.Покупатель) Тогда		
					InvoiceОбъект.Покупатель = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ConsignTo, "Владелец");
				КонецЕсли;
				
			Иначе
				ДобавитьВComment(InvoiceОбъект.Comment, "! Failed to find Consign-to by TMS Id """ + СтруктураТекстовыхЗначений.ConsignTo + """!");
			КонецЕсли;
			
		КонецЕсли;
		
		// Incoterms
		Если ЗначениеЗаполнено(СтруктураТекстовыхЗначенийInvoice.Incoterms) Тогда
			
			Incoterms = ImportExportСерверПовтИспСеанс.ПолучитьIncotermsПоКоду(СтруктураТекстовыхЗначенийInvoice.Incoterms);
			Если НЕ ЗначениеЗаполнено(Incoterms) Тогда 
				ДобавитьВComment(InvoiceОбъект.Comment, "! Failed to find Incoterms by code '" + СтруктураТекстовыхЗначенийInvoice.Incoterms + "'!");
			иначе
				InvoiceОбъект.УсловияПоставки = Incoterms;
			КонецЕсли;
			
		КонецЕсли;
		
		// Paying entity
		Если ЗначениеЗаполнено(СтруктураТекстовыхЗначенийInvoice.PayingEntity) Тогда
			
			Попытка
				InvoiceОбъект.PayingEntity = Перечисления.PayingEntities[СтруктураТекстовыхЗначенийInvoice.PayingEntity];
			Исключение
				ДобавитьВComment(InvoiceОбъект.Comment, "! Failed to find Paying entity by code '" + СтруктураТекстовыхЗначенийInvoice.PayingEntity + "'!");
			КонецПопытки;
			
		КонецЕсли;
		
		// Currency
		Если ЗначениеЗаполнено(СтруктураТекстовыхЗначенийInvoice.Currency) Тогда
			
			Currency = ImportExportСерверПовтИспСеанс.ПолучитьCurrencyПоНаименованиюEng(СтруктураТекстовыхЗначенийInvoice.Currency);
			Если НЕ ЗначениеЗаполнено(Currency) Тогда 
				ДобавитьВComment(InvoiceОбъект.Comment, "! Failed to find Currency by eng. name '" + СтруктураТекстовыхЗначенийInvoice.Currency + "'!");
			Иначе 
				InvoiceОбъект.Валюта = Currency;
			КонецЕсли;
			
		КонецЕсли;
		
		// AU
		AU = Неопределено;
		Если ЗначениеЗаполнено(СтруктураТекстовыхЗначенийInvoice.AU) Тогда
			
			//-> RG-Soft VIvanov 2015/02/18
			//AU = ImportExportСерверПовтИспСеанс.ПолучитьAUПоКоду(СтруктураТекстовыхЗначенийInvoice.AU);
			AU = РГСофт.НайтиAU(InvoiceОбъект.Дата, СтруктураТекстовыхЗначенийInvoice.AU);
			//<- RG-Soft VIvanov
			Если НЕ ЗначениеЗаполнено(AU) Тогда 
				ДобавитьВComment(InvoiceОбъект.Comment, "! Failed to find AU by code '" + СтруктураТекстовыхЗначенийInvoice.AU + "'!");
			КонецЕсли;
			
		КонецЕсли;
		
		// Total price
		// КОНВЕРТИРОВАТЬ ПРИ РАЗБОРЕ XDTO, А НЕ ЗДЕСЬ
		Попытка
			TotalPrice = ПреобразоватьСтрокуВЧисло(СтруктураТекстовыхЗначенийInvoice.TotalPrice);
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to convert """ + СтруктураТекстовыхЗначенийInvoice.TotalPrice + """ to release total price!");	
		КонецПопытки;
		
		Если ЗначениеЗаполнено(TotalPrice) Тогда
			InvoiceОбъект.СуммаДокумента = TotalPrice;
		КонецЕсли;
		
		// Rate
		// НЕ НАДО В ДОПОЛНИТЕЛЬНЫЕ СТВОЙСТВА НАДО В СТРУКТУРУ ЗНАЧЕНИЙ!
		// КОНВЕРТИРОВАТЬ ПРИ РАЗБОРЕ XDTO, А НЕ ЗДЕСЬ
		InvoiceОбъект.ДополнительныеСвойства.Вставить("Rate");
		Попытка
			InvoiceОбъект.ДополнительныеСвойства.Rate = ПреобразоватьСтрокуВЧисло(СтруктураТекстовыхЗначенийInvoice.Rate);
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to convert """ + СтруктураТекстовыхЗначенийInvoice.Rate + """ to release currency rate!");
		КонецПопытки;
		
		// ДОДЕЛАТЬ ФРАХТ
	
		// Items
		СоответствиеImportReferenceИItemОбъект = СоздатьОбновитьItems(СтруктураТекстовыхЗначенийInvoice, СтруктураОбъектовБазы, AU, InvoiceОбъект, InvoiceСсылка);
		
		// Если вернулась строка, а не соответствие - это текст ошибок
		Если ТипЗнч(СоответствиеImportReferenceИItemОбъект) = Тип("Строка") Тогда
			ДобавитьВComment(ТекстОшибок, СоответствиеImportReferenceИItemОбъект);
		КонецЕсли;
		
		// Parcels
		ТекстОшибокПриСозданииОбновленииParcels = СоздатьОбновитьParcels(СтруктураТекстовыхЗначенийInvoice, СтруктураОбъектовБазы, DOCОбъект, СоответствиеImportReferenceИItemОбъект);
		Если ЗначениеЗаполнено(ТекстОшибокПриСозданииОбновленииParcels) Тогда
			ДобавитьВComment(ТекстОшибок, ТекстОшибокПриСозданииОбновленииParcels);	
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ТекстОшибок;
	
КонецФункции

Функция СоздатьОбновитьItems(СтруктураТекстовыхЗначенийInvoice, СтруктураОбъектовБазы, AU, InvoiceОбъект, InvoiceСсылка)
	
	// Создает или обновляет Items
	// В случае обработанных ошибок - возращает текст ошибок
	// В случае успеха - соответствие Import reference и объектов Items
	
	ТекстОшибок = "";
	
	СтруктураОтбора = Новый Структура("Invoice", InvoiceСсылка);	
	ТаблицаItems = СтруктураОбъектовБазы.Items.Скопировать(СтруктураОтбора);
	
	Activity = СтруктураТекстовыхЗначенийInvoice.Activity;
	
	TotalFreight = 0;
	
	НомерСтроки = 0;
	
	МассивЗаписываемыхItems = Новый Массив;
	
	Для Каждого СтруктураЗначенийItem Из СтруктураТекстовыхЗначенийInvoice.Items Цикл
		
		НомерСтроки = НомерСтроки + 1;
		
		СтрокаТаблицыItems = ТаблицаItems.Найти(СтруктураЗначенийItem.ImportReference, "ImportReference");
		Если СтрокаТаблицыItems = Неопределено Тогда 
			
			ItemОбъект = Справочники.СтрокиИнвойса.СоздатьЭлемент();
			ItemОбъект.Инвойс = InvoiceСсылка;
			ItemОбъект.ImportReference = СтруктураЗначенийItem.ImportReference;
		
		Иначе
			
			ItemОбъект = СтрокаТаблицыItems.Ссылка.ПолучитьОбъект();
			ТаблицаItems.Удалить(СтрокаТаблицыItems);
			
		КонецЕсли;
		
		// Invoice line no.
		ItemОбъект.НомерСтрокиИнвойса = НомерСтроки;
		
		// Currency
		ItemОбъект.Currency = InvoiceОбъект.Валюта;
		
		// Parent company
		ItemОбъект.SoldTo = InvoiceОбъект.Покупатель;
		
		// AU
		Если ЗначениеЗаполнено(AU) Тогда
			ItemОбъект.КостЦентр = AU;
		КонецЕсли;
		
		// Activity
		Если ЗначениеЗаполнено(СтруктураТекстовыхЗначенийInvoice.Activity) Тогда
			ItemОбъект.Активити = Activity;
		КонецЕсли;

		// PO no.
		Если ЗначениеЗаполнено(СтруктураЗначенийItem.PONo) Тогда
			ItemОбъект.НомерЗаявкиНаЗакупку = СтруктураЗначенийItem.PONo;
		КонецЕсли;
		
		// Part no.
		Если ЗначениеЗаполнено(СтруктураЗначенийItem.PartNo) Тогда
			ItemОбъект.КодПоИнвойсу = СтруктураЗначенийItem.PartNo;
		КонецЕсли;
		
		// Description
		Если ЗначениеЗаполнено(СтруктураЗначенийItem.Description) Тогда
			ItemОбъект.НаименованиеТовара = СтруктураЗначенийItem.Description;
		КонецЕсли;
		
		// Serial no.
		Если ЗначениеЗаполнено(СтруктураЗначенийItem.SerialNo) Тогда
			ItemОбъект.СерийныйНомер = СтруктураЗначенийItem.SerialNo;
		КонецЕсли;
		
		// Qty 			
		Если ЗначениеЗаполнено(СтруктураЗначенийItem.QTY) Тогда
			ItemОбъект.Количество = СтруктураЗначенийItem.QTY;
		КонецЕсли;
		
		// Qty UOM
		Если ЗначениеЗаполнено(СтруктураЗначенийItem.QtyUOM) Тогда
			
			QtyUOM = ImportExportСерверПовтИспСеанс.ПолучитьUOMПоTMSIDForItemUOM(СтруктураЗначенийItem.QtyUOM);
			Если НЕ ЗначениеЗаполнено(QtyUOM) Тогда 
				ДобавитьВComment(InvoiceОбъект.Comment, "! Failed to find UOM by TMS ID for Item UOM '" + СтруктураЗначенийItem.QtyUOM + "'!");
			Иначе
				ItemОбъект.ЕдиницаИзмерения = QtyUOM;
			КонецЕсли;
			
		КонецЕсли;
		
		// Total price, price, freight (требуют пересчета из валюты строки в валюту инвойса)
		Если ЗначениеЗаполнено(InvoiceОбъект.ДополнительныеСвойства.Rate) Тогда
			
			// Total price
			// КОНВЕРТИРОВАТЬ ПРИ РАЗБОРЕ XDTO, А НЕ ЗДЕСЬ
			TotalPrice = Неопределено;
			Попытка
				TotalPrice = ПреобразоватьСтрокуВЧисло(СтруктураЗначенийItem.TotalPrice);
			Исключение
				ДобавитьВComment(ТекстОшибок,
					"Failed to convert """ + СтруктураЗначенийItem.TotalPrice + """ to item total price!");
			КонецПопытки;
			
			// КОНВЕРТИРОВАТЬ ПРИ РАЗБОРЕ XDTO, А НЕ ЗДЕСЬ
			Rate = Неопределено;
			Попытка
				Rate = ПреобразоватьСтрокуВЧисло(СтруктураЗначенийItem.Rate);
			Исключение
				ДобавитьВComment(ТекстОшибок,
					"Failed to convert """ + СтруктураЗначенийItem.Rate + """ to item currency rate!");
			КонецПопытки;
			
			Если ЗначениеЗаполнено(TotalPrice) И ЗначениеЗаполнено(Rate) Тогда
				ItemОбъект.Сумма = TotalPrice * Rate / InvoiceОбъект.ДополнительныеСвойства.Rate;
			КонецЕсли;
		
			// Price
			Если ЗначениеЗаполнено(ItemОбъект.Сумма) И ЗначениеЗаполнено(ItemОбъект.Количество) Тогда
				ItemОбъект.Цена = ItemОбъект.Сумма / ItemОбъект.Количество;
			КонецЕсли;
			
			// Freight
			Если ЗначениеЗаполнено(Rate) Тогда
				
				Для Каждого СтруктураFreight Из СтруктураЗначенийItem.МассивСтруктурFreight Цикл
					
					// КОНВЕРТИРОВАТЬ ПРИ РАЗБОРЕ XDTO, А НЕ ЗДЕСЬ
					Freight = Неопределено;
					Попытка
						Freight = ПреобразоватьСтрокуВЧисло(СтруктураFreight.MonetaryAmount);
					Исключение
						ДобавитьВComment(ТекстОшибок,
							"Failed to convert """ + СтруктураFreight.MonetaryAmount + """ to freight!");
					КонецПопытки;
					
					Если ЗначениеЗаполнено(Freight) Тогда
						TotalFreight = TotalFreight + Freight * Rate / InvoiceОбъект.ДополнительныеСвойства.Rate;
					КонецЕсли;
					
				КонецЦикла;
				
			КонецЕсли;
			
		КонецЕсли;
			
		// ERP treatment
		Если ЗначениеЗаполнено(СтруктураЗначенийItem.ERPTreatment) Тогда
			
			ERPTreatment = Перечисления.ТипыЗаказа.ПолучитьПоTMSId(СтруктураЗначенийItem.ERPTreatment);
			Если ЗначениеЗаполнено(ERPTreatment) Тогда
				ItemОбъект.Классификатор = ERPTreatment;
			Иначе
				ДобавитьВComment(InvoiceОбъект.Comment, "! Failed to find ERP treatment by TMS Id """ + СтруктураЗначенийItem.ERPTreatment + """!");	
			КонецЕсли;
			
		КонецЕсли;
		
		// Country of origin
		Если ЗначениеЗаполнено(СтруктураЗначенийItem.CountryOfOrigin) Тогда
			ItemОбъект.СтранаПроисхождения = СтруктураЗначенийItem.CountryOfOrigin;
		КонецЕсли;
		
		// HTS
		Если ЗначениеЗаполнено(СтруктураОбъектовБазы.PODCode) Тогда
			
			HTS = СтруктураЗначенийItem.СоответствиеCountryHTS.Получить("HTS " + СтруктураОбъектовБазы.PODCode);
			Если ЗначениеЗаполнено(HTS) Тогда
				ItemОбъект.МеждународныйКодТНВЭД = HTS;
			КонецЕсли;
			
		КонецЕсли;
		
		// Total Net Weight
		TotalNetWeight = Неопределено;
		Попытка
			TotalNetWeight = ПреобразоватьСтрокуВЧисло(СтруктураЗначенийItem.TotalNetWeight);
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to convert """ + СтруктураЗначенийItem.TotalNetWeight + """ to item total net weight!");
		КонецПопытки;
		
		Если ЗначениеЗаполнено(TotalNetWeight) Тогда
			ItemОбъект.NetWeight = TotalNetWeight;
		КонецЕсли;
	
		// Net weight UOM
		Если ЗначениеЗаполнено(СтруктураЗначенийItem.NetWeightUOM) Тогда
			
			NetWeightUOM = ImportExportСерверПовтИспСеанс.ПолучитьUOMПоTMSID(СтруктураЗначенийItem.NetWeightUOM);
			Если НЕ ЗначениеЗаполнено(NetWeightUOM) Тогда 
				ДобавитьВComment(InvoiceОбъект.Comment, "! Failed to find Net weight UOM by TMS Id '" + СтруктураЗначенийItem.NetWeightUOM + "'!");
			иначе
				ItemОбъект.WeightUOM = NetWeightUOM;
			КонецЕсли;
			
		КонецЕсли;
		
		МассивЗаписываемыхItems.Добавить(ItemОбъект);
					
	КонецЦикла;
	
	// Удалим ненужные строки
	Для Каждого СтрокаТаблицыItems Из ТаблицаItems Цикл
		
		ItemОбъект = СтрокаТаблицыItems.Ссылка.ПолучитьОбъект();
		ItemОбъект.УстановитьПометкуУдаления(Истина);
				
	КонецЦикла;
	
	InvoiceОбъект.Фрахт = TotalFreight;
	
	// Запишем инвойс
	РежимЗаписи = ?(InvoiceОбъект.Проведен, РежимЗаписиДокумента.Проведение, РежимЗаписиДокумента.Запись);
	InvoiceОбъект.Записать(РежимЗаписи); 
	
	// Запишем Items
	СоответствиеImportReferenceИItemОбъект = Новый Соответствие;
	
	Для Каждого ItemОбъект Из МассивЗаписываемыхItems Цикл
		
		ItemОбъект.Записать();		
		СоответствиеImportReferenceИItemОбъект.Вставить(ItemОбъект.ImportReference, ItemОбъект);
		
	КонецЦикла;
	
	Возврат СоответствиеImportReferenceИItemОбъект;
	
КонецФункции

Функция СоздатьОбновитьParcels(СтруктураТекстовыхЗначенийInvoice, СтруктураОбъектовБазы, DOCОбъект, СоответствиеImportReferenceИItemОбъект)
	
	// Создает или обновляет Parcels
	// Возвращает текст ошибок
	
	ТекстОшибок = "";
	
	// Warehouse to
	Попытка
		WarehouseTo = Справочники.Warehouses.НайтиСоздатьПоTMSID(СтруктураТекстовыхЗначенийInvoice.WarehouseTo)			
	Исключение
		Возврат "Failed to find or create location """ + СтруктураТекстовыхЗначенийInvoice.WarehouseTo + """!
			|Additional tech info:
			|" + ОписаниеОшибки();	
	КонецПопытки;
	
	Для Каждого СтруктураТекстовыхЗначенийParcel из СтруктураТекстовыхЗначенийInvoice.Parcels Цикл
		
		//создаем новый Parcel, если не найден
		СтрокаТаблицыParcels = СтруктураОбъектовБазы.Parcels.Найти(СтруктураТекстовыхЗначенийParcel.No, "Код");
		Если СтрокаТаблицыParcels = Неопределено Тогда
			ParcelОбъект = Справочники.Parcels.СоздатьЭлемент();
			ParcelОбъект.Код = СтруктураТекстовыхЗначенийParcel.No;
		Иначе
			
			Если ЗначениеЗаполнено(СтрокаТаблицыParcels.DOC) и СтрокаТаблицыParcels.DOC <> DOCОбъект.Ссылка Тогда 
				ДобавитьВComment(ТекстОшибок, "! ShipUnit " + СтрокаТаблицыParcels.No 
					+ " is already used in Planned Shipment " + СокрЛП(СтрокаТаблицыParcels.DOC.Номер) + "!");		
				Продолжить;
			КонецЕсли;
			
			ParcelОбъект = СтрокаТаблицыParcels.Ссылка.ПолучитьОбъект();
			ParcelОбъект.Comment = "";
		КонецЕсли;
		
		// DO no.
		Если ЗначениеЗаполнено(СтруктураТекстовыхЗначенийParcel.DONo) Тогда
			ParcelОбъект.DOno = СтруктураТекстовыхЗначенийParcel.DONo;
		КонецЕсли;
		
		// Packing type
		Если ЗначениеЗаполнено(СтруктураТекстовыхЗначенийParcel.PackingType) Тогда
			
			PackingType = ImportExportСерверПовтИспСеанс.ПолучитьPackingTypeПоTMSID(СтруктураТекстовыхЗначенийParcel.PackingType);
			
			Если ЗначениеЗаполнено(PackingType) Тогда
				ParcelОбъект.PackingType = PackingType;	
			Иначе
				ДобавитьВComment(ParcelОбъект.Comment, "! Failed to find Packing type by TMS ID '" + СтруктураТекстовыхЗначенийParcel.PackingType + "'!"); 
			КонецЕсли;
			
		КонецЕсли;
		
		ParcelОбъект.WarehouseTo = WarehouseTo;
					
		// Num. of Parcels
		NumOfParcels = Неопределено;
		Попытка
			NumOfParcels = ПреобразоватьСтрокуВЧисло(СтруктураТекстовыхЗначенийParcel.NumOfParcels);
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to convert """ + СтруктураТекстовыхЗначенийParcel.NumOfParcels + """ to number of ship units!");
		КонецПопытки;
		
		Если ЗначениеЗаполнено(NumOfParcels) Тогда
			ParcelОбъект.NumOfParcels = NumOfParcels;
		КонецЕсли;
		
		//Length
		Length = Неопределено;
		Попытка
			Length = ПреобразоватьСтрокуВЧисло(СтруктураТекстовыхЗначенийParcel.Length);
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to convert """ + СтруктураТекстовыхЗначенийParcel.Length + """ to ship unit length!");
		КонецПопытки;
		
		Если ЗначениеЗаполнено(Length) Тогда
			ParcelОбъект.Length = Length;	
		КонецЕсли;
		
		//Width
		Width = Неопределено;
		Попытка
			Width = ПреобразоватьСтрокуВЧисло(СтруктураТекстовыхЗначенийParcel.Width);
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to convert """ + СтруктураТекстовыхЗначенийParcel.Width + """ to ship unit width!");	
		КонецПопытки;
		
		Если ЗначениеЗаполнено(Width) Тогда
			ParcelОбъект.Width = Width;	
		КонецЕсли;
		
		//Height
		Height = Неопределено;
		Попытка
			Height = ПреобразоватьСтрокуВЧисло(СтруктураТекстовыхЗначенийParcel.Height);
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to convert """ + СтруктураТекстовыхЗначенийParcel.Height + """ to ship unit height!");	
		КонецПопытки;
			
		Если ЗначениеЗаполнено(Height) Тогда
			ParcelОбъект.Height = Height;	
		КонецЕсли;
		
		// DIMs UOM
		Если ЗначениеЗаполнено(СтруктураТекстовыхЗначенийParcel.DIMsUOM) Тогда
			
			DIMsUOM = ImportExportСерверПовтИспСеанс.ПолучитьUOMПоTMSID(СтруктураТекстовыхЗначенийParcel.DIMsUOM);
			Если НЕ ЗначениеЗаполнено(DIMsUOM) Тогда 
				ДобавитьВComment(ParcelОбъект.Comment, "! Failed to find DIMs UOM by TMS Id '" + СтруктураТекстовыхЗначенийParcel.DIMsUOM + "'!");
			Иначе
				ParcelОбъект.DIMsUOM = DIMsUOM;
			КонецЕсли;
			
		КонецЕсли;

		// Gross Weight
		GrossWeight = Неопределено;
		Попытка
			GrossWeight = ПреобразоватьСтрокуВЧисло(СтруктураТекстовыхЗначенийParcel.GrossWeight);
		Исключение
			ДобавитьВComment(ТекстОшибок,
				"Failed to convert """ + СтруктураТекстовыхЗначенийParcel.GrossWeight + """ to ship unit gross weight!");	
		КонецПопытки;
		
		Если ЗначениеЗаполнено(GrossWeight) Тогда
			ParcelОбъект.GrossWeight = GrossWeight;
		КонецЕсли;
					
		// Weight UOM
		Если ЗначениеЗаполнено(СтруктураТекстовыхЗначенийParcel.WeightUOM) Тогда
			
			WeightUOM = ImportExportСерверПовтИспСеанс.ПолучитьUOMПоTMSID(СтруктураТекстовыхЗначенийParcel.WeightUOM);
			Если НЕ ЗначениеЗаполнено(WeightUOM) Тогда 
				ДобавитьВComment(ParcelОбъект.Comment, "! Failed to find Weight UOM by TMS Id '" + СтруктураТекстовыхЗначенийParcel.WeightUOM + "'!");
			иначе
				ParcelОбъект.WeightUOM = WeightUOM;
			КонецЕсли;
			
		КонецЕсли;

		Если ЗначениеЗаполнено(СтруктураТекстовыхЗначенийInvoice.RDD) Тогда
			ParcelОбъект.RDD = СтруктураТекстовыхЗначенийInvoice.RDD;	
		КонецЕсли;
				
		ParcelОбъект.Детали.Очистить();
		
		Для Каждого Receiver из СтруктураТекстовыхЗначенийParcel.ParcelLines Цикл 
		
			ItemОбъект = СоответствиеImportReferenceИItemОбъект.Получить(Receiver);
			Если ItemОбъект = Неопределено Тогда 
				ДобавитьВComment(ParcelОбъект.Comment, "! Failed to find Item with Import reference """ + Receiver + """!"); 
				Продолжить;
			КонецЕсли;
			
			НоваяСтрока = ParcelОбъект.Детали.Добавить();
			НоваяСтрока.СтрокаИнвойса = ItemОбъект.Ссылка;
			НоваяСтрока.НомерЗаявкиНаЗакупку = ItemОбъект.НомерЗаявкиНаЗакупку;
			НоваяСтрока.Receiver      = ItemОбъект.ImportReference;
			НоваяСтрока.СерийныйНомер = ItemОбъект.СерийныйНомер;
	        НоваяСтрока.Qty			  = ItemОбъект.Количество;
			НоваяСтрока.QtyUOM 		  = ItemОбъект.ЕдиницаИзмерения;
	        НоваяСтрока.NetWeight     = ItemОбъект.NetWeight;
			
		КонецЦикла;
		
		ParcelОбъект.NetWeight = ParcelОбъект.Детали.Итог("NetWeight");
	
		ParcelОбъект.Записать();  
				
		НоваяСтрокаDOCParcels = DOCОбъект.Parcels.Добавить();
		НоваяСтрокаDOCParcels.Parcel = ParcelОбъект.Ссылка;	
		
	КонецЦикла;
	
	Возврат ТекстОшибок;
	
КонецФункции


// ОБЩИЕ ПРОЦЕДУРЫ / ФУНКЦИИ

Функция ПолучитьСтрокуСвойствLegalEntity()
	
	Возврат "CompanyCode, CountryCode, ERPID, FinanceLocCode, FinanceProcess";
	
КонецФункции

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

Функция ПреобразоватьСтрокуВЧисло(стрЗначение)
	
	Если НЕ ЗначениеЗаполнено(стрЗначение) Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Число(стрЗначение);
	
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


/////////////////////////////////////////////////////////////////////
// ОСТАЛЬНЫЕ ПРОЦЕДУРЫ / ФУНКЦИИ НЕОБХОДИМЫЕ ДЛЯ РАБОТЫ ВЕБ-СЕРВИСА

Функция PushGenericStatusUpdate(PlannedShipmentXid, ТекстОшибок) Экспорт
	
	// Отсылает в TMS GenericStatusUpdate - что-то типа отчета о загрузке
	
	WSСсылка = ПолучитьWSСсылкуДляGenericStatusUpdate();
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	
	TransmissionHeader = TMSСервер.ПолучитьTransmissionHeader(ФабрикаXDTOTMS);	
	GenericStatusUpdate = ПолучитьGenericStatusUpdate(ФабрикаXDTOTMS, PlannedShipmentXid, ТекстОшибок);
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
		ВызватьИсключение "Failed to find port for WS reference '" + WSСсылка + "' to push shipment status!";
	КонецЕсли;
	
	Возврат WSСсылка.СоздатьWSПрокси(URIПространстваИмен, ИмяСервиса, ИмяПорта);
	
КонецФункции

Функция ПолучитьGenericStatusUpdate(ФабрикаXDTOTMS, PlannedShipmentXid, ТекстОшибок)
	
	GenericStatusUpdate = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GenericStatusUpdate");
	
	GenericStatusUpdate.GenericStatusObjectType = "SHIPMENT";
	
	GenericStatusUpdate.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, PlannedShipmentXid);
	GenericStatusUpdate.Gid.DomainName = "SLB";
	
	GenericStatusUpdate.TransactionCode = "IU";
	   	
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда 
		
		Remark = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Remark");
		Remark.TransactionCode = "IU";
		Remark.RemarkSequence = "1";
		Remark.RemarkQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "RemarkQualifierGid");
		Remark.RemarkQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "1C TRANSMISSION");
		Remark.RemarkQualifierGid.Gid.DomainName = "SLB";
		Remark.RemarkText = СокрЛП(ТекстОшибок);
		GenericStatusUpdate.Remark.Добавить(Remark);
		   		
		GenericStatusUpdate.Status.Добавить(ПолучитьStatus(ФабрикаXDTOTMS, "1C TRANSMISSION", "INTEGRATION FAILED"));
		GenericStatusUpdate.Status.Добавить(ПолучитьStatus(ФабрикаXDTOTMS, "DEST_GREENLIGHT", ПолучитьСтатусDEST_GREENLIGHT(ТекстОшибок)));
		
	иначе	
		
		GenericStatusUpdate.Status.Добавить(ПолучитьStatus(ФабрикаXDTOTMS, "1C TRANSMISSION", "INTEGRATION SUCCESS"));
		
	КонецЕсли;
	         	
	Возврат GenericStatusUpdate;
	
КонецФункции

Функция ПолучитьСтатусDEST_GREENLIGHT(ТекстОшибок)
	
	Если ТекстОшибок = "Shipment from Russia to Kazakhstan should not be processed via 1C"
		ИЛИ ТекстОшибок = "Shipment from Kazakhstan to Russia should not be processed via 1C"
		ИЛИ ТекстОшибок = "POD TMS_ID (SourceLocationCountryCode) is the same as Country Code in Warehouse-To (DestuffLocation). Shipment should not be processed via 1C" Тогда 
		Возврат "DEST_RELEASED";
	Иначе 
		Возврат "DEST_REJECTED";
	КонецЕсли;
	
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
