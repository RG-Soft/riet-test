
// ДОДЕЛАТЬ
Процедура PushExportToTMS(ExportRequest, DomesticInternational) Экспорт
	
	WSСсылка = ПолучитьWSСсылку();
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	
	TransOrder = ПолучитьTransOrder(ФабрикаXDTOTMS, ExportRequest, DomesticInternational);
	
	// НАДО ИНФОРМИРОВАТЬ О НЕУДАЧЕ
	Если TransOrder = Неопределено Тогда
		ВызватьИсключение "Failed to push export to TMS: failed to create TransOrder!";
	КонецЕсли;
		
	TransmissionAck = CallTMS(WSСсылка, ФабрикаXDTOTMS, TransOrder);
	
	Если TransmissionAck.TransmissionAckStatus = "ERROR" Тогда
		ВызватьИсключение "Failed to push export to TMS:
			|Unfortunately we do not already now how to show error description :-(";	
	КонецЕсли;
			   		
КонецПроцедуры

// ДОДЕЛАТЬ
Функция ПолучитьTransOrder(ФабрикаXDTOTMS, ExportRequest, DomesticInternational) Экспорт
	
	// Получим данные все данные из базы
	СтруктураДанных = ПолучитьСтруктуруДанных(ExportRequest);
	
	Если Не TMSСервер.СтруктураДанныхДляTMSПроверена(СтруктураДанных, Истина) Тогда 
		ВызватьИсключение "Failed to push Trip to TMS!";
	КонецЕсли;
	
	// Сформируем узел TransOrderHeader
	TransOrderHeader = ПолучитьTransOrderHeader(ФабрикаXDTOTMS, DomesticInternational, СтруктураДанных);
	
	// Сформируем узел ShipUnitDetail
	ShipUnitDetail = ПолучитьShipUnitDetail(ФабрикаXDTOTMS, DomesticInternational, СтруктураДанных);
	
	// Если что-то пошло не так - прекратим
	// ЧТО МОЖЕТ ПОЙТИ НЕ ТАК?
	Если TransOrderHeader = Неопределено ИЛИ ShipUnitDetail = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	// Сформируем узел TransOrder
	TransOrder = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransOrder");
	TransOrder.TransOrderHeader = TransOrderHeader;
	TransOrder.ShipUnitDetail = ShipUnitDetail;
	
	Возврат TransOrder;
	
КонецФункции	

Функция ПолучитьСтруктуруДанных(ExportRequest)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ExportRequest", ExportRequest);
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ExportRequest.Номер,
		|	ExportRequest.ExternalReference,
		|	ExportRequest.FromLegalEntity.Наименование КАК LE_Name,
		|	ExportRequest.FromLegalEntity.CountryCode КАК LE_CountryCode,
		|	ExportRequest.FromLegalEntity.CompanyCode КАК LE_CompanyCode,
		|	ExportRequest.FromLegalEntity.ERPID КАК LE_ERPID,
		|	ExportRequest.FromLegalEntity.FinanceLocCode КАК LE_FinanceLocCode,
		|	ExportRequest.FromLegalEntity.FinanceProcess КАК LE_FinanceProcess,
		|	ExportRequest.AU.NonLawson КАК AUNonLawson,
		|	ExportRequest.AU.Код КАК AU,
		|	ExportRequest.Activity КАК Activity,
		|	ExportRequest.Urgency,
		|	ExportRequest.Comments,
		|	ExportRequest.ReadyToShipDate,
		|	ExportRequest.RequiredDeliveryDate,
		|	ExportRequest.PickUpWarehouse.Код КАК PickUpWarehouseCode,
		|	ExportRequest.LocalWarehouseTo.Код КАК LocalWarehouseToCode,
		|	ExportRequest.POD.TMSID КАК PODTMSID,
		|	ExportRequest.JobNumber,
		|	ExportRequest.Incoterms.Код КАК IncotermsCode,
		|	ExportRequest.DeliverTo.Код КАК DeliverToCode,
		|	ExportRequest.Submitter.Код КАК SubmitterAlias,
		|	ExportRequest.Shipper.TMSID КАК Shipper,
		|	ExportRequest.ShipperContact.Код КАК ShipperContactAlias,
		|	ExportRequest.Consignee.Код КАК ConsigneeCode,
		|	ExportRequest.Recharge,
		|	ExportRequest.RechargeToLegalEntity.Наименование КАК R_LE_Name,
		|	ExportRequest.RechargeToLegalEntity.CompanyCode КАК R_LE_CompanyCode,
		|	ExportRequest.RechargeToLegalEntity.CountryCode КАК R_LE_CountryCode,
		|	ExportRequest.RechargeToLegalEntity.ERPID КАК R_LE_ERPID,
		|	ExportRequest.RechargeToLegalEntity.FinanceLocCode КАК R_LE_FinanceLocCode,
		|	ExportRequest.RechargeToLegalEntity.FinanceProcess КАК R_LE_FinanceProcess,
		|	ExportRequest.RechargeToAU КАК R_AU,
		|	ExportRequest.RechargeToActivity КАК R_Activity,
		|	ExportRequest.PayingEntity,
		|	ExportRequest.CustomUnionTransaction
		|ИЗ
		|	Документ.ExportRequest КАК ExportRequest
		|ГДЕ
		|	ExportRequest.Ссылка = &ExportRequest
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ExportRequestOtherInvolvedLocations.LocationQualifier.Код КАК LocationQualifierCode,
		|	ExportRequestOtherInvolvedLocations.LocationId
		|ИЗ
		|	Документ.ExportRequest.OtherInvolvedLocations КАК ExportRequestOtherInvolvedLocations
		|ГДЕ
		|	ExportRequestOtherInvolvedLocations.Ссылка = &ExportRequest
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ExportRequestOtherInvolvedContacts.ContactQualifier.Код КАК ContactQualifierCode,
		|	ExportRequestOtherInvolvedContacts.ContactQualifier.Domain КАК ContactQualifierDomain,
		|	ExportRequestOtherInvolvedContacts.ContactId
		|ИЗ
		|	Документ.ExportRequest.OtherInvolvedContacts КАК ExportRequestOtherInvolvedContacts
		|ГДЕ
		|	ExportRequestOtherInvolvedContacts.Ссылка = &ExportRequest
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Parcels.Ссылка КАК Parcel,
		|	Parcels.Код КАК ParcelNo,
		|	Parcels.PackingType КАК PackingType,
		|	Parcels.PackingType.TMSID КАК PackingTypeTMSID,
		|	Parcels.SerialNo,
		|	Parcels.NumOfParcels,
		|	Parcels.Length,
		|	Parcels.Width,
		|	Parcels.Height,
		|	Parcels.DIMsUOM.TMSId КАК DIMsUOM,
		|	Parcels.GrossWeight,
		|	Parcels.WeightUOM.TMSId КАК WeightUOM,
		|	Parcels.CubicMeters
		|ИЗ
		|	Справочник.Parcels КАК Parcels
		|ГДЕ
		|	Parcels.ExportRequest = &ExportRequest
		|	И НЕ Parcels.ПометкаУдаления
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ParcelsLines.Ссылка КАК Parcel,
		|	ParcelsLines.НомерСтроки,
		|	ParcelsLines.СтрокаИнвойса.КодПоИнвойсу КАК PartNo,
		|	ParcelsLines.СтрокаИнвойса.Классификатор КАК ERPTreatment,
		|	ParcelsLines.Qty,
		|	ParcelsLines.QtyUOM КАК QtyUOM,
		|	ParcelsLines.QtyUOM.TMSIdForItemUOM КАК QtyUOMTMSIdForItemUOM,
		|	ParcelsLines.СерийныйНомер,
		|	ParcelsLines.СтрокаИнвойса.RAN КАК RAN,
		|	ParcelsLines.СтрокаИнвойса.СтранаПроисхождения.TMSID КАК CountryOfOrigin,
		|	ParcelsLines.СтрокаИнвойса.Currency.НаименованиеEng КАК Currency,
		|	ParcelsLines.СтрокаИнвойса.Сумма КАК Value,
		|	ParcelsLines.NetWeight,
		|	ParcelsLines.СтрокаИнвойса.WeightUOM.TMSId КАК NetWeightUOM,
		|	ParcelsLines.СтрокаИнвойса.ImportReference КАК ImportReference,
		|	ParcelsLines.СтрокаИнвойса.НомерЗаявкиНаЗакупку КАК PONo,
		|	ParcelsLines.СтрокаИнвойса.Наименование КАК ItemName,
		|	ParcelsLines.СтрокаИнвойса КАК Item,
		|	ВЫРАЗИТЬ(ParcelsLines.СтрокаИнвойса.НаименованиеТовара КАК СТРОКА(300)) КАК ItemDescription
		|ИЗ
		|	Справочник.Parcels.Детали КАК ParcelsLines
		|ГДЕ
		|	ParcelsLines.Ссылка.ExportRequest = &ExportRequest
		|	И НЕ ParcelsLines.Ссылка.ПометкаУдаления";
		
	Результаты = Запрос.ВыполнитьПакет();	
		
	СтруктураДанных = Новый Структура("ExportRequest, Locations, Contacts, Parcels, Items");

	СтруктураДанных.ExportRequest = Результаты[0].Выбрать();
	СтруктураДанных.ExportRequest.Следующий();
	
	СтруктураДанных.Locations = Результаты[1].Выгрузить();
	
	СтруктураДанных.Contacts = Результаты[2].Выгрузить();
	
	СтруктураДанных.Parcels = Результаты[3].Выгрузить();
	
	СтруктураДанных.Items = Результаты[4].Выгрузить();
	
	Возврат СтруктураДанных;	
	
КонецФункции
      
Функция ПолучитьTransOrderHeader(ФабрикаXDTOTMS, DomesticInternational, СтруктураДанных)

	ВыборкаШапкаER = СтруктураДанных.ExportRequest;
	TransOrderHeader = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransOrderHeader");
	
	// Номер
	OBNo = ПолучитьOBNoПоERNo(ВыборкаШапкаER.Номер, DomesticInternational);	
	TransOrderHeader.TransOrderGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransOrderGid");
	TransOrderHeader.TransOrderGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, OBNo);
	TransOrderHeader.TransOrderGid.Gid.DomainName = "SLB";
                 		
	// TransactionCode and other fixed stuff
	TransOrderHeader.TransactionCode = "IU";
	
	TransOrderHeader.ReleaseMethodGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ReleaseMethodGid");
	TransOrderHeader.ReleaseMethodGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "SHIP_UNITS");
	
	Если DomesticInternational = Перечисления.DomesticInternational.Domestic Тогда
		OrderTypeGidGid = "SHIP UNIT DOMESTIC";
	ИначеЕсли DomesticInternational = Перечисления.DomesticInternational.International Тогда
		OrderTypeGidGid = "SHIP UNIT INTERNATIONAL";	
	КонецЕсли;
	
	TransOrderHeader.OrderTypeGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "OrderTypeGid");
	TransOrderHeader.OrderTypeGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, OrderTypeGidGid);
	TransOrderHeader.OrderTypeGid.Gid.DomainName = "SLB";
	
	// From (there is also from part in ship units)
	TransOrderHeader.StuffLocation = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "StuffLocation");
	Если DomesticInternational = Перечисления.DomesticInternational.Domestic 
		ИЛИ ВыборкаШапкаER.CustomUnionTransaction Тогда
		TransOrderHeader.StuffLocation.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, ВыборкаШапкаER.PickUpWarehouseCode);
	Иначе
		TransOrderHeader.StuffLocation.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, ВыборкаШапкаER.PODTMSID);	
	КонецЕсли;
	
	// To (there is also to part in ship units)
	TransOrderHeader.DestuffLocation = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "DestuffLocation");
	Если DomesticInternational = Перечисления.DomesticInternational.Domestic Тогда
		TransOrderHeader.DestuffLocation.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, ВыборкаШапкаER.LocalWarehouseToCode);	
	Иначе
		TransOrderHeader.DestuffLocation.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, ВыборкаШапкаER.DeliverToCode);
	КонецЕсли;
	
	// Legal entity, AU, Activity, Comments, Job Number, etc
	МассивOrderRefnum = ПолучитьМассивOrderRefnum(ФабрикаXDTOTMS, DomesticInternational, ВыборкаШапкаER);
	Для Каждого OrderRefnum из МассивOrderRefnum Цикл 
		TransOrderHeader.OrderRefnum.Добавить(OrderRefnum);
	КонецЦикла;
		
	// Priority
	Urgencies = Перечисления.Urgencies;
	Если ВыборкаШапкаER.Urgency = Urgencies.Standard Тогда 
		TransOrderHeader.OrderPriority = "3";
	иначеЕсли ВыборкаШапкаER.Urgency = Urgencies.Urgent Тогда 
		TransOrderHeader.OrderPriority = "2";
	иначеЕсли ВыборкаШапкаER.Urgency = Urgencies.Emergency Тогда 
		TransOrderHeader.OrderPriority = "1";
	КонецЕсли;
	
	// Incoterms
	Если ЗначениеЗаполнено(ВыборкаШапкаER.IncotermsCode) Тогда 
		TransOrderHeader.CommercialTerms = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "CommercialTerms");
		TransOrderHeader.CommercialTerms.IncoTermGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "IncoTermGid");
		TransOrderHeader.CommercialTerms.IncoTermGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, ВыборкаШапкаER.IncotermsCode);
	КонецЕсли;

	// Total Net Weight Volume
	// Проверим, что все parcels содержат одинаковое значение Weight UOM
	ТаблицаParcels = СтруктураДанных.Parcels;
	МассивWeightUOM = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаParcels, "WeightUOM");
	Если МассивWeightUOM.Количество() > 1 Тогда 
		Сообщить("There are parcels with different Weight UOM!");
		Возврат Неопределено;
	ИначеЕсли МассивWeightUOM.Количество() = 1 Тогда
		TransOrderHeader.TotalNetWeightVolume = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TotalNetWeightVolume");
		TransOrderHeader.TotalNetWeightVolume.Weight = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Weight");
		TransOrderHeader.TotalNetWeightVolume.Weight.WeightValue = ТаблицаParcels.Итог("GrossWeight");
		TransOrderHeader.TotalNetWeightVolume.Weight.WeightUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "WeightUOMGid");
		TransOrderHeader.TotalNetWeightVolume.Weight.WeightUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, МассивWeightUOM[0]);
	КонецЕсли;
       		
	// Involved Party
	МассивInvolvedParty = ПолучитьМассивInvolvedParty(ФабрикаXDTOTMS, ВыборкаШапкаER, СтруктураДанных.Locations, СтруктураДанных.Contacts);
	Для Каждого InvolvedParty из МассивInvolvedParty Цикл 
		TransOrderHeader.InvolvedParty.Добавить(InvolvedParty);
	КонецЦикла;
	  	
	// Comments
	Если ЗначениеЗаполнено(ВыборкаШапкаER.Comments) Тогда
		
		Remark = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Remark");
		Remark.RemarkText = ВыборкаШапкаER.Comments;
				
		Remark.RemarkQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "RemarkQualifierGid");
		Remark.RemarkQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "REM");
		TransOrderHeader.Remark.Добавить(Remark);
		
	КонецЕсли;
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "REM", ВыборкаШапкаER.Comments));
	
	Возврат TransOrderHeader;
		         	
КонецФункции

Функция ПолучитьМассивOrderRefnum(ФабрикаXDTOTMS, DomesticInternational, ВыборкаШапкаER)
	
	МассивOrderRefnum = Новый Массив;
	
	// External ref.
	Если ЗначениеЗаполнено(ВыборкаШапкаER.ExternalReference) Тогда
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "EXT_REF", ВыборкаШапкаER.ExternalReference));
	КонецЕсли;
	
	// Pickup or delivery date
	ФорматДаты = "ДФ='гггг-ММ-дд чч:мм:сс'";
	Если DomesticInternational = Перечисления.DomesticInternational.Domestic Тогда
		
		PickupDateText = Формат(ВыборкаШапкаER.ReadyToShipDate, ФорматДаты);
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_PICKUP_DT", PickupDateText));	
		
	Иначе
		
		DeliveryDateText = Формат(ВыборкаШапкаER.RequiredDeliveryDate, ФорматДаты);
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_DELIVERY_DT", DeliveryDateText));
		
	КонецЕсли;
	
	// Legal entity
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_COMP_NAME", ВыборкаШапкаER.LE_Name));
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_COUNTRY_CODE", ВыборкаШапкаER.LE_CountryCode));  
		
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_LEGAL_ENTITY", ВыборкаШапкаER.LE_CompanyCode));  

	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_ERP_ID", ВыборкаШапкаER.LE_ERPID));  

   	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_FIN_LOC_CODE", ВыборкаШапкаER.LE_FinanceLocCode));
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_FIN_PROCESS", ВыборкаШапкаER.LE_FinanceProcess));
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_PAYING_ENTITY", ?(ВыборкаШапкаER.PayingEntity = Перечисления.PayingEntities.S, "S", "D")));
	
	// AU	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_COST_CENTER", СокрЛП(ВыборкаШапкаER.AU)));

	// Activity
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_ACT_CODE", СокрЛП(ВыборкаШапкаER.Activity)));
	
	// Job Number
	Если ЗначениеЗаполнено(ВыборкаШапкаER.JobNumber) Тогда 
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_JOB_NO", ВыборкаШапкаER.JobNumber));
	КонецЕсли;
	
	// Recharge
	Если ВыборкаШапкаER.Recharge Тогда
	
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_RECHARGE_FLAG", "I"));
		
		// Recharge Legal entity
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_COMP_NAME", ВыборкаШапкаER.R_LE_Name));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_ERP_ID", ВыборкаШапкаER.R_LE_ERPID));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_LEGAL_ENTITY", ВыборкаШапкаER.R_LE_CompanyCode));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_COUNTRY_CODE", ВыборкаШапкаER.R_LE_CountryCode));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_FIN_LOC_CODE", ВыборкаШапкаER.R_LE_FinanceLocCode));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_FIN_PROCESS", ВыборкаШапкаER.R_LE_FinanceProcess));
		
		// Recharge AU	
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_COST_CENTER", ВыборкаШапкаER.R_AU));

		// Recharge Activity	
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_ACT_CODE", ВыборкаШапкаER.R_Activity));
		
	иначе
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_RECHARGE_FLAG", "N"));
		
	КонецЕсли;

    Возврат МассивOrderRefnum;
	
КонецФункции

Функция ПолучитьOrderRefnum(ФабрикаXDTOTMS, Xid, Value)
	
	OrderRefnum = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "OrderRefnum");
	OrderRefnum.OrderRefnumQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "OrderRefnumQualifierGid");
	OrderRefnum.OrderRefnumQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, Xid);
	OrderRefnum.OrderRefnumValue = СокрЛП(Value);
	
	Возврат OrderRefnum;
	
КонецФункции

Функция ПолучитьМассивInvolvedParty(ФабрикаXDTOTMS, ВыборкаШапкаER, Locations, Contacts)
	
	МассивInvolvedParty = Новый Массив;
	
	// Requestor
	RequestorInvolvedParty = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "", "REQUESTER", , ВыборкаШапкаER.SubmitterAlias);
	МассивInvolvedParty.Добавить(RequestorInvolvedParty);
	
	// Shipper
	ShipperInvolvedParty = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "", "EXPORTER", ВыборкаШапкаER.Shipper, ВыборкаШапкаER.Shipper);
	МассивInvolvedParty.Добавить(ShipperInvolvedParty);
	
	// Shipper contact (ORIGIN_SLS)
	ShipperContact = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "SLB", "ORIGIN_SLS", , СокрЛП(ВыборкаШапкаER.ShipperContactAlias));
	МассивInvolvedParty.Добавить(ShipperContact);
	
	// Consignee	
	ConsigneeInvolvedParty = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "", "CONSIGNEE", ВыборкаШапкаER.ConsigneeCode, ВыборкаШапкаER.ConsigneeCode);
	МассивInvolvedParty.Добавить(ConsigneeInvolvedParty);
	
	// Other locations
	Для Каждого СтрокаLocations Из Locations Цикл
		
		InvolvedParty = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "", СтрокаLocations.LocationQualifierCode, СтрокаLocations.LocationId, СтрокаLocations.LocationId);
		МассивInvolvedParty.Добавить(InvolvedParty);
		
	КонецЦикла;
	
	// Other contacts
	Для Каждого СтрокаContacts Из Contacts Цикл
		
		InvolvedParty = ПолучитьInvolvedParty(ФабрикаXDTOTMS, СтрокаContacts.ContactQualifierDomain, СтрокаContacts.ContactQualifierCode, , СтрокаContacts.ContactID);
		МассивInvolvedParty.Добавить(InvolvedParty);	
		
	КонецЦикла;
		
    Возврат МассивInvolvedParty;
	
КонецФункции

Функция ПолучитьInvolvedParty(ФабрикаXDTOTMS, QualifierDomain, QualifierXid, LocationId, ContactId)
	
	InvolvedParty = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "InvolvedParty");
		
	InvolvedParty.InvolvedPartyQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "InvolvedPartyQualifierGid");
	InvolvedParty.InvolvedPartyQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, QualifierXid);
	Если ЗначениеЗаполнено(QualifierDomain) Тогда
		InvolvedParty.InvolvedPartyQualifierGid.Gid.DomainName = QualifierDomain;	
	КонецЕсли;
	
	Если ЗначениеЗаполнено(LocationId) Тогда
		InvolvedParty.InvolvedPartyLocationRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "InvolvedPartyLocationRef");
		InvolvedParty.InvolvedPartyLocationRef.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, LocationId);
	КонецЕсли;
	
	InvolvedParty.ContactRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ContactRef");
	InvolvedParty.ContactRef.Contact = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Contact");
	InvolvedParty.ContactRef.Contact.ContactGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ContactGid");
	InvolvedParty.ContactRef.Contact.ContactGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, ContactId);
	InvolvedParty.ContactRef.Contact.ContactGid.Gid.DomainName = "SLB";
		
	InvolvedParty.ComMethodGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ComMethodGid");
	InvolvedParty.ComMethodGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "EMAIL");
	
	Возврат InvolvedParty;
	
КонецФункции

// ДОДЕЛАТЬ
Функция ПолучитьShipUnitDetail(ФабрикаXDTOTMS, DomesticInternational, СтруктураДанных)
	
	ВыборкаШапкаER = СтруктураДанных.ExportRequest;
	ТаблицаParcels = СтруктураДанных.Parcels;
	ТаблицаItems = СтруктураДанных.Items;
	
	// Prepare stuff fixed for all ship units
	
	// Earlist pick up and required delivery dates
	TimeWindow = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TimeWindow");
	
	TimeWindow.EarlyPickupDt = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogDateTimeType");
	TimeWindow.EarlyPickupDt.GLogDate = Формат(ВыборкаШапкаER.ReadyToShipDate, TMSСервер.ПолучитьФорматДатыTMS());
	
	TimeWindow.LateDeliveryDt = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogDateTimeType");
	TimeWindow.LateDeliveryDt.GLogDate = Формат(ВыборкаШапкаER.RequiredDeliveryDate, TMSСервер.ПолучитьФорматДатыTMS());
	
	// Source and destination locations
	ПеречислениеDomesticInternational = Перечисления.DomesticInternational;
	
	// Source location
	Если DomesticInternational = ПеречислениеDomesticInternational.Domestic 
		ИЛИ ВыборкаШапкаER.CustomUnionTransaction Тогда
		ShipFromLocationRefValue = ВыборкаШапкаER.PickUpWarehouseCode;
	ИначеЕсли DomesticInternational = ПеречислениеDomesticInternational.International Тогда
		ShipFromLocationRefValue = ВыборкаШапкаER.PODTMSID;
	КонецЕсли;
	
	ShipFromLocationRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipFromLocationRef");
	ShipFromLocationRef.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, ShipFromLocationRefValue);
	
	// Destination location
	Если DomesticInternational = ПеречислениеDomesticInternational.Domestic Тогда
		ShipToLocationRefValue = ВыборкаШапкаER.LocalWarehouseToCode;
	ИначеЕсли DomesticInternational = ПеречислениеDomesticInternational.International Тогда
		ShipToLocationRefValue = ВыборкаШапкаER.DeliverToCode;
	КонецЕсли;	
	
	ShipToLocationRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipToLocationRef");
	ShipToLocationRef.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, ShipToLocationRefValue);
			
	СтруктураОтбораItems = Новый Структура("Parcel");
	
	ShipUnitDetail = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitDetail");
	  	
	Для Каждого СтрокаТабParcels из ТаблицаParcels Цикл 
		
		ShipUnit = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnit");
		
		// Stuff fixed for all ship units
		ShipUnit.TransactionCode = "IU";
		ShipUnit.TimeWindow = TimeWindow;
		ShipUnit.ShipFromLocationRef = ShipFromLocationRef;
		ShipUnit.ShipToLocationRef = ShipToLocationRef;
	
		// No.		
		ShipUnitNo = ПолучитьOBNoПоERNo(СтрокаТабParcels.ParcelNo, DomesticInternational);
		ShipUnit.ShipUnitGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitGid");
		ShipUnit.ShipUnitGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, ShipUnitNo);
		ShipUnit.ShipUnitGid.Gid.DomainName = "SLB";
		
		ShipUnit.TagInfo = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TagInfo");
		
		// Serial no
		ShipUnit.TagInfo.ItemTag1 = СокрЛП(СтрокаТабParcels.SerialNo);  
		
		// Ship unit qty
		ShipUnit.ShipUnitCount = СокрЛП(СтрокаТабParcels.NumOfParcels);
		
		// Packing type
		ShipUnit.TransportHandlingUnitRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransportHandlingUnitRef");
		ShipUnit.TransportHandlingUnitRef.ShipUnitSpecRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitSpecRef");
		ShipUnit.TransportHandlingUnitRef.ShipUnitSpecRef.ShipUnitSpecGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitSpecGid");
		ShipUnit.TransportHandlingUnitRef.ShipUnitSpecRef.ShipUnitSpecGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, СтрокаТабParcels.PackingTypeTMSID);
		ShipUnit.TransportHandlingUnitRef.ShipUnitSpecRef.ShipUnitSpecGid.Gid.DomainName = "SLB";
		
		// Length Width Height
		ShipUnit.LengthWidthHeight = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "LengthWidthHeight");
		
		// Length
		ShipUnit.LengthWidthHeight.Length = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Length");
		ShipUnit.LengthWidthHeight.Length.LengthValue = TMSСервер.ЧислоСтрокой(СтрокаТабParcels.Length);
		ShipUnit.LengthWidthHeight.Length.LengthUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "LengthUOMGid");
		ShipUnit.LengthWidthHeight.Length.LengthUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, СтрокаТабParcels.DIMsUOM);
				
		// Width
		ShipUnit.LengthWidthHeight.Width = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Width");
		ShipUnit.LengthWidthHeight.Width.WidthValue = TMSСервер.ЧислоСтрокой(СтрокаТабParcels.Width);
		ShipUnit.LengthWidthHeight.Width.WidthUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "WidthUOMGid");
		ShipUnit.LengthWidthHeight.Width.WidthUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, СтрокаТабParcels.DIMsUOM);
		
		// Height
		ShipUnit.LengthWidthHeight.Height = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Height");
		ShipUnit.LengthWidthHeight.Height.HeightValue = TMSСервер.ЧислоСтрокой(СтрокаТабParcels.Height);
		ShipUnit.LengthWidthHeight.Height.HeightUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "HeightUOMGid");
		ShipUnit.LengthWidthHeight.Height.HeightUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, СтрокаТабParcels.DIMsUOM);
		
		// Gross weight
        ShipUnit.WeightVolume = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "WeightVolume");
        ShipUnit.WeightVolume.Weight = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Weight");
        ShipUnit.WeightVolume.Weight.WeightValue = TMSСервер.ЧислоСтрокой(СтрокаТабParcels.GrossWeight);
		ShipUnit.WeightVolume.Weight.WeightUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "WeightUOMGid");
        ShipUnit.WeightVolume.Weight.WeightUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, СтрокаТабParcels.WeightUOM);

		// Volume
		ShipUnit.WeightVolume.Volume = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Volume");
        ShipUnit.WeightVolume.Volume.VolumeValue = TMSСервер.ЧислоСтрокой(СтрокаТабParcels.CubicMeters);
		ShipUnit.WeightVolume.Volume.VolumeUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "VolumeUOMGid");
        ShipUnit.WeightVolume.Volume.VolumeUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "CUMTR");
		
		// Получим таблицу Items для текущего Parcel
		СтруктураОтбораItems.Parcel = СтрокаТабParcels.Parcel;
		ТаблицаParcelItems = ТаблицаItems.Скопировать(СтруктураОтбораItems);
		
		Отказ = Ложь;
		ПроверитьИЗаполнитьShipUnitContent(Отказ, ФабрикаXDTOTMS, ShipUnit, ТаблицаParcelItems, СтрокаТабParcels.ParcelNo);
		Если Отказ Тогда 
			Возврат Неопределено;
		КонецЕсли;
						                    		
		ShipUnitDetail.ShipUnit.Добавить(ShipUnit);
		
	КонецЦикла;
	
	Возврат ShipUnitDetail;
		         	
КонецФункции

Процедура ПроверитьИЗаполнитьShipUnitContent(Отказ, ФабрикаXDTOTMS, ShipUnit, ТаблицаParcelItems, ParcelNo)
					
	// Проверим, что все Items содержат одинкаовое значение ERP treatment
	МассивERPTreatment = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаParcelItems, "ERPTreatment");
	Если МассивERPTreatment.Количество() > 1 Тогда 
		Сообщить("There are items with different ERP treatment in Parcel " + СокрЛП(ParcelNo) + "!");
		Отказ = Истина;
	КонецЕсли;	
	
	//// Проверим, что все Items содержат одинкаовое значение Currency
	//МассивCurrencies = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаParcelItems, "Currency");
	//Если МассивCurrencies.Количество() > 1 Тогда 
	//	Сообщить("There are items with different currencies in Parcel " + СокрЛП(ParcelNo) + "!");
	//	Отказ = Истина;
	//КонецЕсли;
	
	Если Отказ Тогда 
		Возврат;
	КонецЕсли;
	
	// ERP treatment
	ShipUnit.TagInfo.ItemTag3 = Перечисления.ТипыЗаказа.ПолучитьTMSId(МассивERPTreatment[0]);
	
	//// Value
	//ShipUnit.DeclaredValue = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "DeclaredValue");
	//ShipUnit.DeclaredValue.FinancialAmount = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "FinancialAmount");
	//ShipUnit.DeclaredValue.FinancialAmount.MonetaryAmount = TMSСервер.ЧислоСтрокой(ТаблицаParcelItems.Итог("Value"));
	//ShipUnit.DeclaredValue.FinancialAmount.GlobalCurrencyCode = СокрЛП(МассивCurrencies[0]);
	//ShipUnit.DeclaredValue.FinancialAmount.FuncCurrencyAmount = "0.0";
	
	Для Каждого СтрокаТабItems из ТаблицаParcelItems Цикл 
		
		ShipUnitContent = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitContent");
		
		ShipUnitContent.LineNumber = СтрокаТабItems.НомерСтроки;
		
		ShipUnitContent.PackagedItemRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "PackagedItemRef");
		
		// Part No. (в TMS должен создаваться новый Item, если не найден)
		     		
		TMSСервер.СоздатьПолучитьTMSPartNumber(ФабрикаXDTOTMS, ShipUnitContent, СтрокаТабItems.Item, СтрокаТабItems.PartNo, 
			СтрокаТабItems.ItemName, СтрокаТабItems.ItemDescription, СтрокаТабItems.PONo);
		
		// QTY
        ShipUnitContent.ItemQuantity = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ItemQuantity");
        ShipUnitContent.ItemQuantity.PackagedItemCount = Окр(TMSСервер.ЧислоСтрокой(СтрокаТабItems.QTY));

		// QTY Uom
		ShipUnitContent.PackagedItemSpecRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "PackagedItemSpecRef");
        ShipUnitContent.PackagedItemSpecRef.ShipUnitSpecRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitSpecRef");
        ShipUnitContent.PackagedItemSpecRef.ShipUnitSpecRef.ShipUnitSpecGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitSpecGid");
        ShipUnitContent.PackagedItemSpecRef.ShipUnitSpecRef.ShipUnitSpecGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, СтрокаТабItems.QtyUOMTMSIdForItemUOM);
		ShipUnitContent.PackagedItemSpecRef.ShipUnitSpecRef.ShipUnitSpecGid.Gid.DomainName = "SLB";
		
		// Serial number
        ShipUnitContent.ItemQuantity.ItemTag1 = СокрЛП(СтрокаТабItems.СерийныйНомер);
		
		// RAN 
		ShipUnitContent.ItemQuantity.ItemTag2 = СокрЛП(СтрокаТабItems.RAN);
				
		// COO
		ShipUnitContent.ItemQuantity.ItemTag4 = СокрЛП(СтрокаТабItems.CountryOfOrigin);

		//Currency
        ShipUnitContent.ItemQuantity.DeclaredValue = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "DeclaredValue");
        ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "FinancialAmount");
        ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount.GlobalCurrencyCode = СокрЛП(СтрокаТабItems.Currency);
		
		//Value
		ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount.MonetaryAmount = TMSСервер.ЧислоСтрокой(СтрокаТабItems.Value);
		ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount.FuncCurrencyAmount = "0.0";
		
		//Net Weight
        ShipUnitContent.ItemQuantity.WeightVolume = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "WeightVolume");
        ShipUnitContent.ItemQuantity.WeightVolume.Weight = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Weight");
        ShipUnitContent.ItemQuantity.WeightVolume.Weight.WeightValue = TMSСервер.ЧислоСтрокой(СтрокаТабItems.NetWeight);
		
		//Net Weight UOM
		ShipUnitContent.ItemQuantity.WeightVolume.Weight.WeightUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "WeightUOMGid");
        ShipUnitContent.ItemQuantity.WeightVolume.Weight.WeightUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, СтрокаТабItems.NetWeightUOM);

		ShipUnitContent.ItemQuantity.WeightVolume.Volume = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Volume");
        ShipUnitContent.ItemQuantity.WeightVolume.Volume.VolumeValue = 0;
		ShipUnitContent.ItemQuantity.WeightVolume.Volume.VolumeUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "VolumeUOMGid");
        ShipUnitContent.ItemQuantity.WeightVolume.Volume.VolumeUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "CUMTR");
		
		//Import Reference
		//ShipUnitContent.ReleaseLineGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ReleaseLineGid");
        //ShipUnitContent.ReleaseLineGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, СтрокаТабItems.ImportReference);
		
		// PO no.
		Если ЗначениеЗаполнено(СтрокаТабItems.PONo) Тогда
			ShipUnitLineRefnum = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitLineRefnum");
			ShipUnitLineRefnum.ShipUnitLineRefnumQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitLineRefnumQualifierGid");
			ShipUnitLineRefnum.ShipUnitLineRefnumQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "DESCRIPTION_2");
			ShipUnitLineRefnum.ShipUnitLineRefnumValue = СтрокаТабItems.PONo;
			ShipUnitContent.ShipUnitLineRefnum.Добавить(ShipUnitLineRefnum);
		КонецЕсли;
			
		ShipUnit.ShipUnitContent.Добавить(ShipUnitContent);
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьOBNoПоERNo(ERNo, DomesticInternational)
		
	Если НЕ ЗначениеЗаполнено(DomesticInternational) Тогда
		ВызватьИсключение "Domestic / international is empty!";
	КонецЕсли;
	
	ПеречислениеDomesticInternational = Перечисления.DomesticInternational;
	Если DomesticInternational = ПеречислениеDomesticInternational.Domestic Тогда
		Возврат TMSСервер.ПолучитьDomesticOBNoПоERNo(ERNo);
	ИначеЕсли DomesticInternational = ПеречислениеDomesticInternational.International Тогда
		Возврат TMSСервер.ПолучитьInternationslOBNoПоERNo(ERNo);
	Иначе
		ВызватьИсключение "Unknown Domestic / international type '" + DomesticInternational + "'!";
	КонецЕсли;
	
КонецФункции

Функция ПолучитьLocationRef(ФабрикаXDTOTMS, Xid)
	
	Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, Xid);
	Gid.DomainName = "SLB";
	
	LocationGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "LocationGid");
	LocationGid.Gid = Gid;
	
	LocationRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "LocationRef");
	LocationRef.LocationGid = LocationGid;
	
	Возврат LocationRef;
	
КонецФункции

Функция CallTMS(WSСсылка, ФабрикаXDTOTMS, TransOrder)
	
	// Пушает TR в TMS
	// Возвращает ответ - TransmissionAck
	
	Payload = ПолучитьPayload(ФабрикаXDTOTMS, TransOrder);	
	WSПрокси = СоздатьWSПрокси(WSСсылка);		
	Возврат WSПрокси.process(Payload); 
	
КонецФункции

Функция ПолучитьWSСсылку() Экспорт
	
	// Возвращает WSСсылку для отправки Export request в TMS
	// Для продакшн базы используется одна ссылка, для остальных баз - другая
	
	Если РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() Тогда
		Возврат WSСсылки.TMSPushTRProd;
	Иначе
		Возврат WSСсылки.TMSPushTRTest;
	КонецЕсли;
	
КонецФункции

Функция СоздатьWSПрокси(WSСсылка)
	
	// Анализирует WSСсылку и возвращает настроенный WSПрокси, полученной из этой WSСсылки
	
	URIПространстваИмен = "http://xmlns.oracle.com/apps/otm/IntXmlService";
	ИмяСервиса = "IntXmlService";	
	
	Если WSСсылка = WSСсылки.TMSPushTRProd Тогда
		ИмяПорта = "IntXml-xbroker_304_DR";
	ИначеЕсли WSСсылка = WSСсылки.TMSPushTRTest Тогда
		ИмяПорта = "IntXml-QaXBroker_2";
	Иначе
		ВызватьИсключение "Failed to find port for WS reference '" + WSСсылка + "' to push Export request to TMS!";
	КонецЕсли;
	
	Возврат WSСсылка.СоздатьWSПрокси(URIПространстваИмен, ИмяСервиса, ИмяПорта);
	
КонецФункции

Функция ПолучитьPayload(ФабрикаXDTOTMS, TransOrder) Экспорт
	
	TransmissionHeader = TMSСервер.ПолучитьTransmissionHeader(ФабрикаXDTOTMS, , "SIMS");	
	TransmissionBody = ПолучитьTransmissionBody(ФабрикаXDTOTMS, TransOrder);
	Возврат TMSСервер.ПолучитьPayload(ФабрикаXDTOTMS, TransmissionHeader, TransmissionBody);
	
КонецФункции

Функция ПолучитьTransmissionBody(ФабрикаXDTOTMS, TransOrder)
	
	GLogXMLElement = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogXMLElement");
	GLogXMLElement.TransOrder = TransOrder;
	
	TransmissionBody = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransmissionBody");
	TransmissionBody.GLogXMLElement.Добавить(GLogXMLElement);
	
	Возврат TransmissionBody;
	
КонецФункции

