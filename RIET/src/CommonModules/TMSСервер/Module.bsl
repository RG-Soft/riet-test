
////////////////////////////////////////////////////////////////////////////////////////////
// УНИВЕРСАЛЬНЫЕ

Функция ПолучитьОбъектXDTO(ИспользуемаяФабрикаXDTO, URIПространстваИмен, Имя) Экспорт
	
	// Конструирует объект XDTO типа Имя с помощью ФабрикиXDTO и URIПространстваИмен
	
	ТипПоля = ИспользуемаяФабрикаXDTO.Тип(URIПространстваИмен, Имя);
	Возврат ИспользуемаяФабрикаXDTO.Создать(ТипПоля);
	
КонецФункции


////////////////////////////////////////////////////////////////////////////////////////////
// УНИВЕРСАЛЬНЫЕ ДЛЯ TMS

Функция ПолучитьURIПространстваИменTMS() Экспорт
	
	// Получает URI пространства имен TMS web-сервиса
	
	Возврат "http://xmlns.oracle.com/apps/otm";
	
КонецФункции

Функция ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, Имя) Экспорт
	
	// Конструирует объект XDTO типа ИмяТипа с помощью ФабрикиXDTOTMS
	
	ТипПоля = ФабрикаXDTOTMS.Тип(ПолучитьURIПространстваИменTMS(), Имя);
	Возврат ПолучитьОбъектXDTO(ФабрикаXDTOTMS, ПолучитьURIПространстваИменTMS(), Имя);
	
КонецФункции

Функция ПолучитьФорматДатыTMS() Экспорт
	
	Возврат "ДФ=ггггММддHHммсс";
	
КонецФункции

Функция ЧислоСтрокой(Число) Экспорт
	
	ЧислоСтрокой = Формат(Число, "ЧРД=.");
	Возврат СтрЗаменить(ЧислоСтрокой, Символы.НПП, "");
	
КонецФункции

Функция ПолучитьTransmissionHeader(ФабрикаXDTOTMS, TransmissionType=Неопределено, SenderHostName=Неопределено, EmailAddress="riet-support@slb.com") Экспорт
	
	// Конструирует TransmissionHeader для вызова веб-сервиса TMS
	
	TransmissionHeader = ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransmissionHeader");
	
	Если TransmissionType <> Неопределено Тогда
		TransmissionHeader.TransmissionType = TransmissionType;
	КонецЕсли;
	
	Если SenderHostName <> Неопределено Тогда
		TransmissionHeader.SenderHostName = SenderHostName;
	КонецЕсли;
	
	Если РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() Тогда
		UserName = "SLB.INTERFACEPROD";
		Password = "SLB-INTERFACEPROD";
	Иначе
		UserName = "SLB.INTERFACESTAGE";
		Password = "SLB-INTERFACESTAGE";	
	КонецЕсли;
		
	TransmissionHeader.UserName = UserName;
	
	TransmissionHeader.Password = ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "PasswordType");
	TransmissionHeader.Password.__content = Password;

	TransmissionHeader.AckSpec = ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "AckSpec");
		
	TransmissionHeader.AckSpec.ComMethodGid = ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ComMethodGid");
	
	TransmissionHeader.AckSpec.ComMethodGid.Gid = ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Gid");
	
	TransmissionHeader.AckSpec.ComMethodGid.Gid.Xid = "EMAIL";
	
	TransmissionHeader.AckSpec.EmailAddress = EmailAddress;  
	
	TransmissionHeader.AckSpec.AckOption = "YES";
			
	Возврат TransmissionHeader;
	
КонецФункции

Функция ПолучитьTransmissionBody(ФабрикаXDTOTMS, ИмяТипаОбъектаXDTO, ОбъектXDTO) Экспорт
	
	// Возвращает объект XDTO TransmissionBody, в который обернут передаваемый объект XDTO
	
	GLogXMLElement = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogXMLElement");	
	GLogXMLElement[ИмяТипаОбъектаXDTO] = ОбъектXDTO;
		
	TransmissionBody = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransmissionBody");
	TransmissionBody.GLogXMLElement.Добавить(GLogXMLElement);
	
	Возврат TransmissionBody;
	
КонецФункции

Функция ПолучитьPayload(ФабрикаXDTOTMS, TransmissionHeader, TransmissionBody) Экспорт
	
	// Конструирует Payload из TransmissionHeader и TransmissionBody
	
	payload = ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Transmission");
	
	payload.TransmissionHeader = TransmissionHeader;
	
	payload.TransmissionBody = TransmissionBody;
	
	Возврат payload;
	
КонецФункции

Функция ПолучитьGid(ФабрикаXDTOTMS, Xid) Экспорт
	
	// Возвращает объект XDTO Gid, в который обернут Xid
	// Domain при этом пустой, если надо - его можно установить вручную
	
	Gid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Gid");
    Gid.Xid = СокрЛП(Xid);
	
	Возврат Gid;
	
КонецФункции

Функция ПолучитьМассивНедопустимыхСимволовДляTMS() Экспорт
	
	МассивНедопустимыхСимволовДляTMS = Новый Массив;
	МассивНедопустимыхСимволовДляTMS.Добавить("“");
	МассивНедопустимыхСимволовДляTMS.Добавить("&");
	МассивНедопустимыхСимволовДляTMS.Добавить("#");
	МассивНедопустимыхСимволовДляTMS.Добавить("*");
	МассивНедопустимыхСимволовДляTMS.Добавить("$");
	МассивНедопустимыхСимволовДляTMS.Добавить("£");
	
	Возврат МассивНедопустимыхСимволовДляTMS;
	
КонецФункции

Процедура СоздатьПолучитьTMSPartNumber(ФабрикаXDTOTMS, ShipUnitContent, Item, PartNo, ItemName, ItemDescription, PONo) Экспорт
	
	// Part No. (в TMS должен создаваться новый Item, если не найден)
	
	Попытка
		
		Структура = Обработки.PullMasterDataFromTMS.ПолучитьРеквизитыItem(PartNo);  
		
		ShipUnitContent.PackagedItemRef.PackagedItemGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "PackagedItemGid");
		ShipUnitContent.PackagedItemRef.PackagedItemGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, PartNo);
		ShipUnitContent.PackagedItemRef.PackagedItemGid.Gid.DomainName = "SLB";
		
	Исключение
		
		ShipUnitContent.PackagedItemRef.PackagedItem = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "PackagedItem");
		
		ShipUnitContent.PackagedItemRef.PackagedItem.Packaging = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Packaging");
		ShipUnitContent.PackagedItemRef.PackagedItem.Packaging.PackagedItemGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "PackagedItemGid");
		ShipUnitContent.PackagedItemRef.PackagedItem.Packaging.PackagedItemGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, PartNo);
		ShipUnitContent.PackagedItemRef.PackagedItem.Packaging.PackagedItemGid.Gid.DomainName = "SLB";
		
		ShipUnitContent.PackagedItemRef.PackagedItem.Item = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Item");
		ShipUnitContent.PackagedItemRef.PackagedItem.Item.TransactionCode = "IU";
		
		ShipUnitContent.PackagedItemRef.PackagedItem.Item.ItemGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ItemGid");
		ShipUnitContent.PackagedItemRef.PackagedItem.Item.ItemGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, PartNo);
		ShipUnitContent.PackagedItemRef.PackagedItem.Item.ItemGid.Gid.DomainName = "SLB";
		
		ShipUnitContent.PackagedItemRef.PackagedItem.Item.ItemName = ItemName;
		ShipUnitContent.PackagedItemRef.PackagedItem.Item.Description = 
			?(ЗначениеЗаполнено(PONo), (PONo + "_"), "") + ItemDescription;
		
		//ShipUnitContent.PackagedItemRef.PackagedItem.Item.ManufacturedCountryCode3Gid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ManufacturedCountryCode3Gid");
		//ShipUnitContent.PackagedItemRef.PackagedItem.Item.ManufacturedCountryCode3Gid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "CHN");
		//ShipUnitContent.PackagedItemRef.PackagedItem.Item.ManufacturedCountryCode3Gid.Gid.DomainName = "SLB";
		
		Refnum = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Refnum");
		Refnum.RefnumQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "RefnumQualifierGid");
		Refnum.RefnumQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "HARMONIZED_SHIPPING_CODE");
		Refnum.RefnumValue = "84314300";
		ShipUnitContent.PackagedItemRef.PackagedItem.Item.Refnum.Добавить(Refnum);
		
	КонецПопытки;
	
КонецПроцедуры

Функция СтруктураДанныхДляTMSПроверена(СтруктураДанных, ЭтоЭкспорт=Ложь, ЭтоИмпорт=Ложь)   Экспорт 
	
	ТаблицаItems = СтруктураДанных.Items;
	ТаблицаParcels = СтруктураДанных.Parcels;
		
	ПроверкаВыполненаУспешно = Истина;
	
	Если ЭтоИмпорт Тогда
		
		СтрокаDOC_OB = СтруктураДанных.DOC_OB[0];
		
		Если Не СтрокаDOC_OB.LegalEntityInTMS Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Legal entity '" + СокрЛП(СтрокаDOC_OB.LegalEntity) + "' is not in TMS!"
			, СтрокаDOC_OB.LegalEntity);
			ПроверкаВыполненаУспешно = Ложь;
		КонецЕсли;

		Если Не СтрокаDOC_OB.SourceLocationInTMS Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Source Location '" + СокрЛП(СтрокаDOC_OB.SourceLocation) + "' is not in TMS!"
			, СтрокаDOC_OB.SourceLocation);
			ПроверкаВыполненаУспешно = Ложь;
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(СтрокаDOC_OB.POA_TMSID) Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"TMS ID in Requested POA '" + СокрЛП(СтрокаDOC_OB.RequestedPOA) + "' is empty!"
			, СтрокаDOC_OB.RequestedPOA);
			ПроверкаВыполненаУспешно = Ложь;
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(СтрокаDOC_OB.ConsigneeCode) Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"TMS ID in Consign To '" + СокрЛП(СтрокаDOC_OB.ConsignTo) + "' is empty!"
			, СтрокаDOC_OB.ConsignTo);
			ПроверкаВыполненаУспешно = Ложь;
		КонецЕсли;

	КонецЕсли;

	Если ЭтоЭкспорт Тогда 
		
		Если СтруктураДанных.Свойство("ExportRequest") Тогда 
			ВыборкаRequest = СтруктураДанных.ExportRequest;
		иначе
			ВыборкаRequest = СтруктураДанных.TransportRequest;
		КонецЕсли;

		// {Вопрос S-I-0000606
		Если ВыборкаRequest.AU = "8001002" Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"AU 8001002 сan not be sent to TMS!");
			ПроверкаВыполненаУспешно = Ложь;
		КонецЕсли;
		
		Если ВыборкаRequest.Recharge И ВыборкаRequest.R_AU = "8001002" Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Recharge AU 8001002 сan not be sent to TMS!");
			ПроверкаВыполненаУспешно = Ложь;
		КонецЕсли;
		// }Вопрос S-I-0000606
		
		Если ВыборкаRequest.AUNonLawson Тогда   //S-I-0001010
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"AU '" + СокрЛП(ВыборкаRequest.AU) + "' is non-Lawson and сan not be sent to TMS!");
			ПроверкаВыполненаУспешно = Ложь;
		КонецЕсли;   
		
	КонецЕсли;
	
	МассивНедопустимыхСимволовДляTMS = TMSСервер.ПолучитьМассивНедопустимыхСимволовДляTMS();
	
	//проверяем parcels
	
	Для Каждого СтрокаТабParcels из ТаблицаParcels Цикл  
		
		Если ЭтоЭкспорт ИЛИ ЭтоИмпорт Тогда
			Если Не ЗначениеЗаполнено(СтрокаТабParcels.PackingTypeTMSID) Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"TMS ID in Packing type '" + СокрЛП(СтрокаТабParcels.PackingType) + "' is empty!"
					, СтрокаТабParcels.PackingType);
				ПроверкаВыполненаУспешно = Ложь;
			КонецЕсли;
		КонецЕсли;
		
		Если ЭтоИмпорт И Не ЗначениеЗаполнено(СтрокаТабParcels.RequiredDeliveryDate) Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"RDD in Parcel '" + СокрЛП(СтрокаТабParcels.Parcel) + "' is empty!"
					, СтрокаТабParcels.Parcel);
				ПроверкаВыполненаУспешно = Ложь;
		КонецЕсли;
		
		Для Каждого НедопустимыйСимвол из МассивНедопустимыхСимволовДляTMS Цикл 
			Если СтрНайти(СтрокаТабParcels.SerialNo, НедопустимыйСимвол) > 0 Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Serial no. for Parcel '" + СокрЛП(СтрокаТабParcels.Parcel) + "' contains special character '" + НедопустимыйСимвол + "'!"
					, СтрокаТабParcels.Parcel);
				ПроверкаВыполненаУспешно = Ложь;
			КонецЕсли;
		КонецЦикла;
		
	КонецЦикла;
	
	//проверяем items
	
	Если Не ЭтоЭкспорт Тогда 
		
		ТаблицаAUs = ТаблицаItems.Скопировать(, "AU,AUNonLawson");
		ТаблицаAUs.Свернуть("AU,AUNonLawson");
		
		Для Каждого СтрокаAU из ТаблицаAUs Цикл
			Если СтрокаAU.AUNonLawson Тогда    //S-I-0001010
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"AU '" + СокрЛП(СтрокаAU.AU) + "' is non-Lawson and сan not be sent to TMS!"
				, СтрокаAU.AU);
				ПроверкаВыполненаУспешно = Ложь;
			КонецЕсли;
		КонецЦикла;	
		
		СтруктураПоиска = Новый Структура("ERPTreatment", Перечисления.ТипыЗаказа.ПустаяСсылка());
		СтрокиСПустымERPTreatment = ТаблицаItems.НайтиСтроки(СтруктураПоиска);
		Для каждого СтрокаСПустымERPTreatment Из СтрокиСПустымERPTreatment Цикл
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"ERP treatment for Item '" + СокрЛП(СтрокаСПустымERPTreatment.ItemName) + "' is empty!"
			, СтрокаСПустымERPTreatment.Item);
			ПроверкаВыполненаУспешно = Ложь;
		КонецЦикла;
		
	КонецЕсли; 
	
	Для Каждого СтрокаТабItems из ТаблицаItems Цикл  
		             				
		Если Не ЗначениеЗаполнено(СтрокаТабItems.QtyUOMTMSIdForItemUOM) Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"TMS ID for Item UOM '" + СокрЛП(СтрокаТабItems.QtyUOM) + "' is empty!"
				, СтрокаТабItems.QtyUOM);
			ПроверкаВыполненаУспешно = Ложь;
		КонецЕсли;
		
		Если ЭтоИмпорт И Не ЗначениеЗаполнено(СтрокаТабItems.CountryOfOrigin) Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"TMS ID for Item Country Of Origin '" + СокрЛП(СтрокаТабItems.ItemName) + "' is empty!"
				, СтрокаТабItems.Item);
			ПроверкаВыполненаУспешно = Ложь;
		КонецЕсли;
		
		PartNoForTMS = СтрокаТабItems.PartNo; 
		SerialNoForTMS = СтрокаТабItems.СерийныйНомер;
		
		Для Каждого НедопустимыйСимвол из МассивНедопустимыхСимволовДляTMS Цикл 
			                			
			Если СтрНайти(PartNoForTMS, НедопустимыйСимвол) > 0 Тогда 
				PartNoForTMS = СтрЗаменить(PartNoForTMS, НедопустимыйСимвол, "");
			КонецЕсли;
			
			Если СтрНайти(SerialNoForTMS, НедопустимыйСимвол) > 0 Тогда 
				SerialNoForTMS = СтрЗаменить(SerialNoForTMS, НедопустимыйСимвол, "");
			КонецЕсли;
			
		КонецЦикла;

		Если PartNoForTMS <> СтрокаТабItems.PartNo
			ИЛИ SerialNoForTMS <> СтрокаТабItems.СерийныйНомер Тогда 
			
			УстановитьПривилегированныйРежим(Истина);
			
			//отдельный регистр соответствий Part no. and Serial no. товара в TMS
			НЗ = РегистрыСведений.ItemsInTMS.СоздатьНаборЗаписей();
			НЗ.Отбор.Item.Установить(СтрокаТабItems.Item);
			
			НоваяСтрока = НЗ.Добавить();
			НоваяСтрока.Item = СтрокаТабItems.Item;
			НоваяСтрока.PartNoInTMS = PartNoForTMS;
			НоваяСтрока.SerialNoInTMS = SerialNoForTMS;
			
			Попытка
				НЗ.Записать();
			Исключение
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Failed to save Part no. and Serial no. without special characters for Item '" + СокрЛП(СтрокаТабItems.Item) + "'!"
					, СтрокаТабItems.Item);
				ПроверкаВыполненаУспешно = Ложь;
			КонецПопытки;
			
			СтрокаТабItems.PartNo = PartNoForTMS; 
			СтрокаТабItems.СерийныйНомер = SerialNoForTMS;

		КонецЕсли;
		
		Если Не ЭтоЭкспорт И ЗначениеЗаполнено(СтрокаТабItems.BORGcode) 
			И Лев(СтрокаТабItems.BORGcode, 1) = "7" Тогда
			
			//S-I-0002231
			Справочники.BORGs.ПодменитьAU_ACДля7BORGcodes(СтрокаТабItems, "AU",  "Activity", СтрокаТабItems.BORGcode);
			
		КонецЕсли;
		
	КонецЦикла;   
	
	Возврат ПроверкаВыполненаУспешно;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////////////////
// НАШ ВЕБ СЕРВИС FROM TMS

// ТОЧНО НУЖНО?
Функция ПолучитьURIПространстваИменTMSLite() Экспорт
	
	Возврат "http://xmlns.oracle.com/apps/otm";
	
КонецФункции


////////////////////////////////////////////////////////////////////////////////////////////
// EXPORT

Функция ПолучитьDomesticOBNoПоERNo(ERNo) Экспорт
		
	Возврат "OBEL" + ПолучитьERNoБезПрефикса(ERNo);
	
КонецФункции 

Функция ПолучитьInternationslOBNoПоERNo(ERNo) Экспорт
		
	Возврат "OBEI" + ПолучитьERNoБезПрефикса(ERNo);
	
КонецФункции

Функция ПолучитьERNoБезПрефикса(ERNo)  Экспорт
	
	Если НЕ ЗначениеЗаполнено(ERNo) Тогда
		ВызватьИсключение "ER no. is empty!";
	КонецЕсли;
	
	Возврат СокрЛП(Сред(ERNo, 2));
	
КонецФункции


////////////////////////////////////////////////////////////////////////////////////////////
// CLEARANCE EVENTS

Процедура ЗарегистрироватьClearanceEventПриНеобходимости(НаборЗаписей, Shipment, EventType, OldEventDate, NewEventDate, User) Экспорт
	
	Если OldEventDate = NewEventDate Тогда
		Возврат;
	КонецЕсли;
	
	НаборЗаписей.Отбор.Shipment.Установить(Shipment);
	НаборЗаписей.Отбор.EventType.Установить(EventType);
		
	Если ЗначениеЗаполнено(NewEventDate) Тогда
		
		ТекЗапись = НаборЗаписей.Добавить();
		ТекЗапись.Shipment = Shipment;
		ТекЗапись.EventType = EventType;		
		ТекЗапись.EventDate = NewEventDate;
		ТекЗапись.LastModified = ТекущаяДата();
		ТекЗапись.User = User;
		
	КонецЕсли;
	
	НаборЗаписей.Записать(Истина);
	
КонецПроцедуры

Процедура УдалитьЗаписьClearanceEvent(НаборЗаписей, Shipment, EventType) Экспорт
	
	Если НЕ ЗначениеЗаполнено(Shipment) Тогда
		ВызватьИсключение "Shipment is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(EventType) Тогда
		ВызватьИсключение "Event type is empty!";
	КонецЕсли;
		
	НаборЗаписей.Отбор.Shipment.Установить(Shipment);
	НаборЗаписей.Отбор.EventType.Установить(EventType);	
	НаборЗаписей.Записать(Истина);
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////////////////
// РЕГЛАМЕНТНЫЕ ЗАДАНИЯ

Процедура LoadNewExportRequestsFromEmail() Экспорт
	
	// Процедура для одноименного регламентного задания
	УстановитьПривилегированныйРежим(Истина);
	
	ИнтернетПочтовыйПрофиль = ImportExportСерверПовтИспСеанс.ПолучитьИнтернетПочтовыйПрофиль();
 	ИнтернетПочта = ImportExportСервер.ПодключитьсяКИнтернетПочте(ИнтернетПочтовыйПрофиль);
	
	// { RGS VChaplygin 15.04.2016 8:42:22 - Добавим аварийный почтовый аккаунт
	ИспользоватьСистемнуюУчетнуюЗапись = Истина;
	ИнтернетПочтовыйПрофильRCA = ImportExportСерверПовтИспСеанс.ПолучитьИнтернетПочтовыйПрофиль(ИспользоватьСистемнуюУчетнуюЗапись);
 	ИнтернетПочтаRCA = ImportExportСервер.ПодключитьсяКИнтернетПочте(ИнтернетПочтовыйПрофильRCA);
	
	ДанныеДляОтправкиОтвета = Новый Структура;
	ДанныеДляОтправкиОтвета.Вставить("ИнтернетПочта", ИнтернетПочта);
	ДанныеДляОтправкиОтвета.Вставить("ИнтернетПочтаRCA", ИнтернетПочтаRCA);
	ДанныеДляОтправкиОтвета.Вставить("АдресОтправителя", ИнтернетПочтовыйПрофиль.ПользовательSMTP); 
	ДанныеДляОтправкиОтвета.Вставить("АдресПолучателя", "");
	ДанныеДляОтправкиОтвета.Вставить("ТемаИсходногоПисьма", "");
	// } RGS VChaplygin 15.04.2016 8:42:40 - Добавим аварийный почтовый аккаунт
	
	// Что бы дальше не произошло - нам нужно гарантированно отключиться
	// Поэтому перехватим описание ошибки, чтобы потом вызывать ее после отключения
	ОбработанныеПисьма = Новый Массив;
	ОписаниеОшибки = Неопределено;
	Попытка
		
		НовыеПисьма = ImportExportСервер.ПолучитьUnprocessedEmails(ИнтернетПочта, ИнтернетПочтовыйПрофиль.ПользовательIMAP);
		// { RGS VChaplygin 15.04.2016 8:42:22 - Добавим аварийный почтовый аккаунт
		//ОбработанныеПисьма = Обработки.PullExportRequestsFromTMSEmails.ОбработатьПисьма(НовыеПисьма, ИнтернетПочта, ИнтернетПочтовыйПрофиль.ПользовательSMTP);
		ОбработанныеПисьма = Обработки.PullExportRequestsFromTMSEmails.ОбработатьПисьма(НовыеПисьма, ДанныеДляОтправкиОтвета);
		// } RGS VChaplygin 15.04.2016 8:42:40 - Добавим аварийный почтовый аккаунт
			
	Исключение
		
		ОписаниеОшибки = "Failed to load Export requests from e-mails:
			|" + ОписаниеОшибки();
			
	КонецПопытки;
	
	ИнтернетПочта.Отключиться();
	
	// Зарегистрируем обработанные письма
	МассивИдентификаторов = Новый Массив;
	Для Каждого ОбработанноеПисьмо Из ОбработанныеПисьма Цикл
		МассивИдентификаторов.Добавить(ОбработанноеПисьмо.Идентификатор[0]);		
	КонецЦикла;

	Если МассивИдентификаторов.Количество() Тогда
		РегистрыСведений.UIDsOfProcessedEmails.ДобавитьНесколько(МассивИдентификаторов, ИнтернетПочтовыйПрофиль.ПользовательIMAP);
	КонецЕсли;
	
	Если ОписаниеОшибки <> Неопределено Тогда
		ВызватьИсключение ОписаниеОшибки;	
	КонецЕсли;
	
КонецПроцедуры

Процедура PushImportClearanceEventsToTMS() Экспорт
	
	Обработки.PushClearanceEventsToTMS.PushReadyImport();	
	
КонецПроцедуры

Процедура PushExportClearanceEventsToTMS() Экспорт
	
	Обработки.PushClearanceEventsToTMS.PushReadyExport();	
	
КонецПроцедуры

Процедура PushLocalExportGateInGateOutEventsToTMS() Экспорт
	
	Обработки.PushGateInGateOutEventsToTMS.PushLocalExportGateInGateOut();	
	
КонецПроцедуры

Процедура PushInternationalExportGateInGateOutEventsToTMS() Экспорт
	
	Обработки.PushGateInGateOutEventsToTMS.PushInternationalExportGateInGateOut();	
	
КонецПроцедуры

