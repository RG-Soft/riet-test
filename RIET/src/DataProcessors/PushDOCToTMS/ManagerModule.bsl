
/////////////////////////////////////////////////////////////////////
// ВЫГРУЗКА OB В TMS

Процедура PushDOCToTMS(DOC) Экспорт
	
	Если DOC.TMS_OB.Количество() = 0 Тогда
		ВызватьИсключение "DOCs TMS OB list is empty!";
	КонецЕсли;
	
	WSСсылка = ПолучитьWSСсылку();
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	
	МассивTransOrder = ПолучитьМассивTransOrder(ФабрикаXDTOTMS, DOC);
	
	Если МассивTransOrder = Неопределено Тогда
		ВызватьИсключение "Failed to push DOC to TMS: failed to create TransOrder!";
	КонецЕсли;
		
	TransmissionAck = CallTMS(WSСсылка, ФабрикаXDTOTMS, МассивTransOrder);
	
	Если TransmissionAck.TransmissionAckStatus = "ERROR" Тогда
		ВызватьИсключение "Failed to push DOC to TMS: " + ОписаниеОшибки();	
	КонецЕсли;
			   		
КонецПроцедуры
 
Функция ПолучитьМассивTransOrder(ФабрикаXDTOTMS, DOC) Экспорт
	
	// Получим данные все данные из базы
	СтруктураДанных = ПолучитьСтруктуруДанных(DOC);
	
	ТаблицаOB = DOC.TMS_OB.Выгрузить();
	
	Если Не TMSСервер.СтруктураДанныхДляTMSПроверена(СтруктураДанных, , Истина) Тогда
		ВызватьИсключение "Failed to push Trip to TMS!";
	КонецЕсли;
	
	МассивTransOrder = Новый Массив;
	
	СтруктураОтбора = Новый Структура("AU,Activity");
			
	Для Каждого СтрокаOB из ТаблицаOB Цикл 
		
		СтруктураДанныхOB = Новый Структура("DOC_OB,Items,Parcels");
		
		ЗаполнитьЗначенияСвойств(СтруктураОтбора, СтрокаOB);

		СтруктураДанныхOB.DOC_OB = СтруктураДанных.DOC_OB.Скопировать(СтруктураОтбора);				
		СтруктураДанныхOB.Items = СтруктураДанных.Items.Скопировать(СтруктураОтбора);
		СтруктураДанныхOB.Parcels = СтруктураДанных.Parcels.Скопировать(СтруктураОтбора);		
		
		// Сформируем узел TransOrderHeader
		TransOrderHeader = ПолучитьTransOrderHeader(ФабрикаXDTOTMS, СтруктураДанныхOB, СтрокаOB);
		
		// Сформируем узел ShipUnitDetail
		ShipUnitDetail = ПолучитьShipUnitDetail(ФабрикаXDTOTMS, СтруктураДанныхOB, СтрокаOB);
		
		// Если что-то пошло не так - прекратим
		Если TransOrderHeader = Неопределено ИЛИ ShipUnitDetail = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
		
		// Сформируем узел TransOrder
		TransOrder = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransOrder");
		TransOrder.TransOrderHeader = TransOrderHeader;
		TransOrder.ShipUnitDetail = ShipUnitDetail;
		
		МассивTransOrder.Добавить(TransOrder);
		
	КонецЦикла;

	Возврат МассивTransOrder;
	
КонецФункции
    
Функция ПолучитьСтруктуруДанных(DOC)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("DOC", DOC);
	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	DOC_TMS_OB.Ссылка.Номер КАК ExternalReference,
		|	DOC_TMS_OB.Ссылка.LegalEntity.Наименование КАК LE_Name,
		|	DOC_TMS_OB.Ссылка.LegalEntity.CountryCode КАК LE_CountryCode,
		|	DOC_TMS_OB.Ссылка.LegalEntity.CompanyCode КАК LE_CompanyCode,
		|	DOC_TMS_OB.Ссылка.LegalEntity.ERPID КАК LE_ERPID,
		|	DOC_TMS_OB.Ссылка.LegalEntity.FinanceLocCode КАК LE_FinanceLocCode,
		|	DOC_TMS_OB.Ссылка.LegalEntity.FinanceProcess КАК LE_FinanceProcess,
		|	DOC_TMS_OB.Ссылка.Urgency,
		|	DOC_TMS_OB.OBNo,
		|	DOC_TMS_OB.AU,
		|	DOC_TMS_OB.Activity,
		|	DOC_TMS_OB.AU.Segment КАК Segment,
		|	DOC_TMS_OB.Ссылка.CurrentComment КАК Comment,
		|	DOC_TMS_OB.Ссылка.Дата КАК ReadyToShipDate,
		|	DOC_TMS_OB.Ссылка.SourceLocation.Код КАК SourceLocation_TMSID,
		|	DOC_TMS_OB.Ссылка.SourceLocation КАК SourceLocation,
		|	DOC_TMS_OB.Ссылка.RequestedPOA.TMSID КАК POA_TMSID,
		|	DOC_TMS_OB.Ссылка.RequestedPOA КАК RequestedPOA,
		|	DOC_TMS_OB.Ссылка.Coordinator,
		|	DOC_TMS_OB.Ссылка.ConsignTo КАК ConsignTo,
		|	DOC_TMS_OB.Ссылка.ConsignTo.TMSID КАК ConsigneeCode,
		|	МИНИМУМ(КонсолидированныйПакетЗаявокНаПеревозкуParcels.Parcel.RDD) КАК RequiredDeliveryDate,
		|	МАКСИМУМ(КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Инвойс.УсловияПоставки.Код) КАК IncotermsCode,
		|	DOC_TMS_OB.Ссылка.LegalEntity.InTMS КАК LegalEntityInTMS,
		|	DOC_TMS_OB.Ссылка.LegalEntity КАК LegalEntity,
		|	DOC_TMS_OB.Ссылка.SourceLocation.InTMS КАК SourceLocationInTMS
		|ИЗ
		|	Документ.КонсолидированныйПакетЗаявокНаПеревозку.TMS_OB КАК DOC_TMS_OB
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Parcels КАК КонсолидированныйПакетЗаявокНаПеревозкуParcels
		|		ПО DOC_TMS_OB.Ссылка = КонсолидированныйПакетЗаявокНаПеревозкуParcels.Ссылка
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы
		|		ПО DOC_TMS_OB.Ссылка = КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка
		|ГДЕ
		|	DOC_TMS_OB.Ссылка = &DOC
		|	И КонсолидированныйПакетЗаявокНаПеревозкуParcels.Ссылка = &DOC
		|	И КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка = &DOC
		|
		|СГРУППИРОВАТЬ ПО
		|	DOC_TMS_OB.Ссылка.Номер,
		|	DOC_TMS_OB.Ссылка.LegalEntity.Наименование,
		|	DOC_TMS_OB.Ссылка.LegalEntity.CountryCode,
		|	DOC_TMS_OB.Ссылка.LegalEntity.CompanyCode,
		|	DOC_TMS_OB.Ссылка.LegalEntity.ERPID,
		|	DOC_TMS_OB.Ссылка.LegalEntity.FinanceLocCode,
		|	DOC_TMS_OB.Ссылка.LegalEntity.FinanceProcess,
		|	DOC_TMS_OB.Ссылка.Urgency,
		|	DOC_TMS_OB.OBNo,
		|	DOC_TMS_OB.AU,
		|	DOC_TMS_OB.Activity,
		|	DOC_TMS_OB.AU.Segment,
		|	DOC_TMS_OB.Ссылка.CurrentComment,
		|	DOC_TMS_OB.Ссылка.Дата,
		|	DOC_TMS_OB.Ссылка.SourceLocation.Код,
		|	DOC_TMS_OB.Ссылка.SourceLocation,
		|	DOC_TMS_OB.Ссылка.RequestedPOA.TMSID,
		|	DOC_TMS_OB.Ссылка.RequestedPOA,
		|	DOC_TMS_OB.Ссылка.Coordinator,
		|	DOC_TMS_OB.Ссылка.ConsignTo,
		|	DOC_TMS_OB.Ссылка.ConsignTo.TMSID,
		|	DOC_TMS_OB.Ссылка.LegalEntity.InTMS,
		|	DOC_TMS_OB.Ссылка.LegalEntity,
		|	DOC_TMS_OB.Ссылка.SourceLocation.InTMS
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ParcelsLines.Ссылка КАК Parcel,
		|	ParcelsLines.СтрокаИнвойса.КостЦентр КАК AU,
		|	ВЫБОР
		|		КОГДА ParcelsLines.СтрокаИнвойса.Активити = """"
		|			ТОГДА ParcelsLines.СтрокаИнвойса.КостЦентр.DefaultActivity
		|		ИНАЧЕ ParcelsLines.СтрокаИнвойса.Активити
		|	КОНЕЦ КАК Activity,
		|	ParcelsLines.Ссылка.Код КАК ParcelNo,
		|	ParcelsLines.Ссылка.PackingType КАК PackingType,
		|	ParcelsLines.Ссылка.PackingType.TMSID КАК PackingTypeTMSID,
		|	ParcelsLines.Ссылка.SerialNo,
		|	ParcelsLines.Ссылка.NumOfParcels,
		|	ParcelsLines.Ссылка.LengthCM,
		|	ParcelsLines.Ссылка.WidthCM,
		|	ParcelsLines.Ссылка.HeightCM,
		|	ParcelsLines.Ссылка.GrossWeightKG,
		|	ParcelsLines.Ссылка.CubicMeters,
		|	ParcelsLines.Ссылка.HazardClass,
		|	ParcelsLines.Ссылка.RDD КАК RequiredDeliveryDate
		|ИЗ
		|	Документ.КонсолидированныйПакетЗаявокНаПеревозку.Parcels КАК КонсолидированныйПакетЗаявокНаПеревозкуParcels
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsLines
		|		ПО КонсолидированныйПакетЗаявокНаПеревозкуParcels.Parcel = ParcelsLines.Ссылка
		|ГДЕ
		|	НЕ ParcelsLines.Ссылка.ПометкаУдаления
		|	И НЕ ParcelsLines.СтрокаИнвойса.ПометкаУдаления
		|	И КонсолидированныйПакетЗаявокНаПеревозкуParcels.Ссылка = &DOC
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ParcelsLines.Ссылка КАК Parcel,
		|	ParcelsLines.НомерСтроки,
		|	ParcelsLines.СтрокаИнвойса.КодПоИнвойсу КАК PartNo,
		|	ПОДСТРОКА(ParcelsLines.СтрокаИнвойса.НомерЗаявкиНаЗакупку, 1, 2) КАК BORGcode,
		|	ParcelsLines.СтрокаИнвойса.КостЦентр КАК AU,
		|	ParcelsLines.СтрокаИнвойса.КостЦентр.NonLawson КАК AUNonLawson,
		|	ВЫБОР
		|		КОГДА ParcelsLines.СтрокаИнвойса.Активити = """"
		|			ТОГДА ParcelsLines.СтрокаИнвойса.КостЦентр.DefaultActivity
		|		ИНАЧЕ ParcelsLines.СтрокаИнвойса.Активити
		|	КОНЕЦ КАК Activity,
		|	ParcelsLines.СтрокаИнвойса.Классификатор КАК ERPTreatment,
		|	ParcelsLines.Qty,
		|	ParcelsLines.QtyUOM КАК QtyUOM,
		|	ParcelsLines.QtyUOM.TMSIdForItemUOM КАК QtyUOMTMSIdForItemUOM,
		|	ParcelsLines.СерийныйНомер,
		|	ParcelsLines.СтрокаИнвойса.СтранаПроисхождения.TMSID КАК CountryOfOrigin,
		|	ParcelsLines.СтрокаИнвойса.Currency.НаименованиеEng КАК Currency,
		|	ParcelsLines.СтрокаИнвойса.Сумма КАК Value,
		|	ParcelsLines.NetWeight,
		|	ParcelsLines.СтрокаИнвойса.WeightUOM.TMSId КАК NetWeightUOM,
		|	ParcelsLines.СтрокаИнвойса.НомерЗаявкиНаЗакупку КАК PONo,
		|	ParcelsLines.СтрокаИнвойса.Наименование КАК ItemName,
		|	ParcelsLines.СтрокаИнвойса.RAN КАК RAN,
		|	ParcelsLines.СтрокаИнвойса КАК Item,
		|	ВЫРАЗИТЬ(ParcelsLines.СтрокаИнвойса.НаименованиеТовара КАК СТРОКА(300)) КАК ItemDescription
		|ИЗ
		|	Документ.КонсолидированныйПакетЗаявокНаПеревозку.Parcels КАК КонсолидированныйПакетЗаявокНаПеревозкуParcels
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsLines
		|		ПО КонсолидированныйПакетЗаявокНаПеревозкуParcels.Parcel = ParcelsLines.Ссылка
		|ГДЕ
		|	НЕ ParcelsLines.Ссылка.ПометкаУдаления
		|	И НЕ ParcelsLines.СтрокаИнвойса.ПометкаУдаления
		|	И КонсолидированныйПакетЗаявокНаПеревозкуParcels.Ссылка = &DOC";
		
	Результаты = Запрос.ВыполнитьПакет();	
		
	СтруктураДанных = Новый Структура("DOC_OB,Parcels,Items");

	СтруктураДанных.DOC_OB = Результаты[0].Выгрузить();
	
	СтруктураДанных.Parcels = Результаты[1].Выгрузить();
	
	СтруктураДанных.Items = Результаты[2].Выгрузить();
	СтруктураДанных.Items.Индексы.Добавить("PartNo");
	
	Возврат СтруктураДанных;
	
КонецФункции
     
Функция ПолучитьTransOrderHeader(ФабрикаXDTOTMS, СтруктураДанныхOB, СтрокаOB)

	СтрокаDOC_OB = СтруктураДанныхOB.DOC_OB[0];
	TransOrderHeader = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransOrderHeader");
	
	// Номер
	TransOrderHeader.TransOrderGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransOrderGid");
	TransOrderHeader.TransOrderGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, СтрокаOB.OBNo);
	TransOrderHeader.TransOrderGid.Gid.DomainName = "SLB";
                 		
	// TransactionCode and other fixed stuff
	TransOrderHeader.TransactionCode = "IU";
	
	TransOrderHeader.ReleaseMethodGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ReleaseMethodGid");
	TransOrderHeader.ReleaseMethodGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "SHIP_UNITS");
	
	OrderTypeGidGid = "SHIP UNIT INTERNATIONAL";			
	TransOrderHeader.OrderTypeGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "OrderTypeGid");
	TransOrderHeader.OrderTypeGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, OrderTypeGidGid);
	TransOrderHeader.OrderTypeGid.Gid.DomainName = "SLB";
	
	// From (there is also from part in ship units)
	TransOrderHeader.StuffLocation = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "StuffLocation");
	TransOrderHeader.StuffLocation.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, СокрЛП(СтрокаDOC_OB.SourceLocation_TMSID));	
	
	// To (there is also to part in ship units)
	TransOrderHeader.DestuffLocation = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "DestuffLocation");
	TransOrderHeader.DestuffLocation.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, СтрокаDOC_OB.POA_TMSID);
		
	// Legal entity, AU, Activity, Comments, Job Number, etc
	МассивOrderRefnum = ПолучитьМассивOrderRefnum(ФабрикаXDTOTMS, СтрокаDOC_OB);
	Для Каждого OrderRefnum из МассивOrderRefnum Цикл 
		TransOrderHeader.OrderRefnum.Добавить(OrderRefnum);
	КонецЦикла;
		
	// Priority
	Urgencies = Перечисления.Urgencies;
	Если СтрокаDOC_OB.Urgency = Urgencies.Standard Тогда 
		TransOrderHeader.OrderPriority = "3";
	иначеЕсли СтрокаDOC_OB.Urgency = Urgencies.Urgent Тогда 
		TransOrderHeader.OrderPriority = "2";
	иначеЕсли СтрокаDOC_OB.Urgency = Urgencies.Emergency Тогда 
		TransOrderHeader.OrderPriority = "1";
	КонецЕсли;
	
	// Incoterms
	Если ЗначениеЗаполнено(СтрокаDOC_OB.IncotermsCode) Тогда 
		TransOrderHeader.CommercialTerms = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "CommercialTerms");
		TransOrderHeader.CommercialTerms.IncoTermGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "IncoTermGid");
		TransOrderHeader.CommercialTerms.IncoTermGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, СтрокаDOC_OB.IncotermsCode);
	КонецЕсли;

	// Total Net Weight Volume KG
	TransOrderHeader.TotalNetWeightVolume = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TotalNetWeightVolume");
	TransOrderHeader.TotalNetWeightVolume.Weight = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Weight");
	TransOrderHeader.TotalNetWeightVolume.Weight.WeightValue = СтруктураДанныхOB.Parcels.Итог("GrossWeightKG");
	TransOrderHeader.TotalNetWeightVolume.Weight.WeightUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "WeightUOMGid");
	TransOrderHeader.TotalNetWeightVolume.Weight.WeightUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Справочники.UOMs.KG, "TMSId"));
	           	       		
	// Involved Party
	МассивInvolvedParty = ПолучитьМассивInvolvedParty(ФабрикаXDTOTMS, СтрокаDOC_OB);
	Для Каждого InvolvedParty из МассивInvolvedParty Цикл 
		TransOrderHeader.InvolvedParty.Добавить(InvolvedParty);
	КонецЦикла;
	  	
	HazardousComment = "";
	Сч = 1;
	Для Каждого СтрокаТабParcels из СтруктураДанныхOB.Parcels Цикл
		
		Если СтрокаТабParcels.HazardClass = Справочники.HazardClasses.NonHazardous Тогда 
			Продолжить;
		КонецЕсли;
		
		HazardousComment = ?(HazardousComment = "", "Request contains hazardous parcels: ", ", ") + СокрЛП(СтрокаOB.OBNo) + "-" + ?(Сч < 10, "0", "") + СокрЛП(Сч);
		
	КонецЦикла;
	
	// Comments
	Если ЗначениеЗаполнено(СтрокаDOC_OB.Comment) ИЛИ ЗначениеЗаполнено(HazardousComment) Тогда
		
		Remark = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Remark");
		Remark.RemarkText = СокрЛП(СтрокаDOC_OB.Comment + ?(ЗначениеЗаполнено(СтрокаDOC_OB.Comment), Символы.ПС, "") + HazardousComment);
				
		Remark.RemarkQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "RemarkQualifierGid");
		Remark.RemarkQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "REM");
		TransOrderHeader.Remark.Добавить(Remark);
		
	КонецЕсли;    
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "REM", СтрокаDOC_OB.Comment));
	
	Возврат TransOrderHeader;
		         	
КонецФункции

Функция ПолучитьМассивOrderRefnum(ФабрикаXDTOTMS, СтрокаDOC_OB)
	
	МассивOrderRefnum = Новый Массив;
	
	// External ref.
	Если ЗначениеЗаполнено(СтрокаDOC_OB.ExternalReference) Тогда
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "EXT_REF", СокрЛП(СтрокаDOC_OB.ExternalReference)));
	КонецЕсли;
	
	// Pickup or delivery date
	ФорматДаты = "ДФ='гггг-ММ-дд чч:мм:сс'";
	
	PickupDateText = Формат(СтрокаDOC_OB.ReadyToShipDate, ФорматДаты);
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_PICKUP_DT", PickupDateText));	
	
	DeliveryDateText = Формат(СтрокаDOC_OB.RequiredDeliveryDate, ФорматДаты);
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_DELIVERY_DT", DeliveryDateText));
	
	// Legal entity
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_COMP_NAME", СтрокаDOC_OB.LE_Name));
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_COUNTRY_CODE", СтрокаDOC_OB.LE_CountryCode));  
		
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_LEGAL_ENTITY", СтрокаDOC_OB.LE_CompanyCode));  

	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_ERP_ID", СтрокаDOC_OB.LE_ERPID));  

   	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_FIN_LOC_CODE", СтрокаDOC_OB.LE_FinanceLocCode));
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_FIN_PROCESS", СтрокаDOC_OB.LE_FinanceProcess));
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_PAYING_ENTITY", "S"));
	
	// AU	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_COST_CENTER", СтрокаDOC_OB.AU));

	// Activity
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_ACT_CODE", СокрЛП(СтрокаDOC_OB.Activity)));
	            		
	// Recharge
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_RECHARGE_FLAG", "N"));
		
	Возврат МассивOrderRefnum;
	
КонецФункции

Функция ПолучитьМассивInvolvedParty(ФабрикаXDTOTMS, СтрокаDOC_OB)
	
	МассивInvolvedParty = Новый Массив;
	
	// Requestor
	RequestorInvolvedParty = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "", "REQUESTER", , СокрЛП(СтрокаDOC_OB.Coordinator));
	МассивInvolvedParty.Добавить(RequestorInvolvedParty);
	                           		
	// Shipper contact (ORIGIN_SLS)
	ShipperContact = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "SLB", "ORIGIN_SLS", , СокрЛП(СтрокаDOC_OB.Coordinator));
	МассивInvolvedParty.Добавить(ShipperContact);
	
	// Consignee	
	ConsigneeInvolvedParty = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "", "CONSIGNEE", СтрокаDOC_OB.ConsigneeCode, СтрокаDOC_OB.ConsigneeCode);
	МассивInvolvedParty.Добавить(ConsigneeInvolvedParty);
	  		
    Возврат МассивInvolvedParty;
	
КонецФункции

Функция ПолучитьShipUnitDetail(ФабрикаXDTOTMS, СтруктураДанныхOB, СтрокаOB)

	СтрокаDOC_OB = СтруктураДанныхOB.DOC_OB[0];

	ТаблицаParcels = СтруктураДанныхOB.Parcels;
	ТаблицаItems = СтруктураДанныхOB.Items;
	
	// Prepare stuff fixed for all ship units
	
	// Earlist pick up and required delivery dates
	TimeWindow = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TimeWindow");
	
	TimeWindow.EarlyPickupDt = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogDateTimeType");
	TimeWindow.EarlyPickupDt.GLogDate = Формат(СтрокаDOC_OB.ReadyToShipDate, TMSСервер.ПолучитьФорматДатыTMS());
	
	TimeWindow.LateDeliveryDt = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogDateTimeType");
	TimeWindow.LateDeliveryDt.GLogDate = Формат(СтрокаDOC_OB.RequiredDeliveryDate, TMSСервер.ПолучитьФорматДатыTMS());
	
	// Source location
	ShipFromLocationRefValue = СокрЛП(СтрокаDOC_OB.SourceLocation_TMSID);     	
	ShipFromLocationRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipFromLocationRef");
	ShipFromLocationRef.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, ShipFromLocationRefValue);
	
	// Destination location
	ShipToLocationRefValue = СтрокаDOC_OB.POA_TMSID; 		
	
	ShipToLocationRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipToLocationRef");
	ShipToLocationRef.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, ShipToLocationRefValue);
			
	СтруктураОтбораItems = Новый Структура("Parcel");
	
	ShipUnitDetail = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitDetail");
	  	
	Сч = 1;
	Для Каждого СтрокаТабParcels из ТаблицаParcels Цикл 
		
		ShipUnit = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnit");
		
		// Stuff fixed for all ship units
		ShipUnit.TransactionCode = "IU";
		ShipUnit.TimeWindow = TimeWindow;
		ShipUnit.ShipFromLocationRef = ShipFromLocationRef;
		ShipUnit.ShipToLocationRef = ShipToLocationRef;
	
		// No.		
		ShipUnitNo = СокрЛП(СтрокаOB.OBNo) + "-" + ?(Сч < 10, "0", "") + СокрЛП(Сч);
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
		ShipUnit.LengthWidthHeight.Length.LengthValue = TMSСервер.ЧислоСтрокой(СтрокаТабParcels.LengthCM);
		ShipUnit.LengthWidthHeight.Length.LengthUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "LengthUOMGid");
		ShipUnit.LengthWidthHeight.Length.LengthUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Справочники.UOMs.CM, "TMSId"));
				
		// Width
		ShipUnit.LengthWidthHeight.Width = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Width");
		ShipUnit.LengthWidthHeight.Width.WidthValue = TMSСервер.ЧислоСтрокой(СтрокаТабParcels.WidthCM);
		ShipUnit.LengthWidthHeight.Width.WidthUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "WidthUOMGid");
		ShipUnit.LengthWidthHeight.Width.WidthUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Справочники.UOMs.CM, "TMSId"));
		
		// Height
		ShipUnit.LengthWidthHeight.Height = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Height");
		ShipUnit.LengthWidthHeight.Height.HeightValue = TMSСервер.ЧислоСтрокой(СтрокаТабParcels.HeightCM);
		ShipUnit.LengthWidthHeight.Height.HeightUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "HeightUOMGid");
		ShipUnit.LengthWidthHeight.Height.HeightUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Справочники.UOMs.CM, "TMSId"));
		
		// Gross weight KG
        ShipUnit.WeightVolume = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "WeightVolume");
        ShipUnit.WeightVolume.Weight = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Weight");
        ShipUnit.WeightVolume.Weight.WeightValue = TMSСервер.ЧислоСтрокой(СтрокаТабParcels.GrossWeightKG);
		ShipUnit.WeightVolume.Weight.WeightUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "WeightUOMGid");
        ShipUnit.WeightVolume.Weight.WeightUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Справочники.UOMs.KG, "TMSId"));

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
		
		Сч = Сч + 1;
		
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
	
	Если Отказ Тогда 
		Возврат;
	КонецЕсли;
	
	// ERP treatment
	ShipUnit.TagInfo.ItemTag3 = Перечисления.ТипыЗаказа.ПолучитьTMSId(МассивERPTreatment[0]);
	
	Для Каждого СтрокаТабItems из ТаблицаParcelItems Цикл 
		
		ShipUnitContent = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitContent");
		
		ShipUnitContent.LineNumber = СтрокаТабItems.НомерСтроки;
		
		ShipUnitContent.PackagedItemRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "PackagedItemRef");
		
		// Part No. (в TMS должен создаваться новый Item, если не найден)
		     		
		TMSСервер.СоздатьПолучитьTMSPartNumber(ФабрикаXDTOTMS, ShipUnitContent, СтрокаТабItems.Item, СтрокаТабItems.PartNo, 
			СтрокаТабItems.ItemName, СтрокаТабItems.ItemDescription, СтрокаТабItems.PONo);
		
		// QTY
        ShipUnitContent.ItemQuantity = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ItemQuantity");
		
		// S-I-0000742 - округляем до целого числа
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

		Если ЗначениеЗаполнено(СокрЛП(СтрокаТабItems.Currency)) и ЗначениеЗаполнено(СтрокаТабItems.Value) Тогда 
			//Currency
			ShipUnitContent.ItemQuantity.DeclaredValue = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "DeclaredValue");
			ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "FinancialAmount");
			ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount.GlobalCurrencyCode = СокрЛП(СтрокаТабItems.Currency);
			
			//Value
			ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount.MonetaryAmount = TMSСервер.ЧислоСтрокой(СтрокаТабItems.Value);
			ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount.FuncCurrencyAmount = "0.0";
		КонецЕсли;  
		 			          			
		ShipUnit.ShipUnitContent.Добавить(ShipUnitContent);
		
	КонецЦикла;
	
КонецПроцедуры


// ВЫНЕСТИ В ОБЩИЙ МОДУЛЬ

Функция ПолучитьOrderRefnum(ФабрикаXDTOTMS, Xid, Value)
	
	OrderRefnum = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "OrderRefnum");
	OrderRefnum.OrderRefnumQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "OrderRefnumQualifierGid");
	OrderRefnum.OrderRefnumQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, Xid);
	OrderRefnum.OrderRefnumValue = СокрЛП(Value);
	
	Возврат OrderRefnum;
	
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

Функция CallTMS(WSСсылка, ФабрикаXDTOTMS, МассивTransOrder)
	
	// Пушает TR в TMS
	// Возвращает ответ - TransmissionAck
	
	Payload = ПолучитьPayload(ФабрикаXDTOTMS, МассивTransOrder);	
	WSПрокси = СоздатьWSПрокси(WSСсылка);		
	Возврат WSПрокси.process(Payload); 
	
КонецФункции

Функция ПолучитьWSСсылку() Экспорт
	
	// Возвращает WSСсылку для отправки в TMS
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

Функция ПолучитьPayload(ФабрикаXDTOTMS, МассивTransOrder) Экспорт
	
	TransmissionHeader = TMSСервер.ПолучитьTransmissionHeader(ФабрикаXDTOTMS, , "SIMS", "riet-support-ld@slb.com");	
	TransmissionBody = ПолучитьTransmissionBody(ФабрикаXDTOTMS, МассивTransOrder);
	Возврат TMSСервер.ПолучитьPayload(ФабрикаXDTOTMS, TransmissionHeader, TransmissionBody);
	
КонецФункции

Функция ПолучитьTransmissionBody(ФабрикаXDTOTMS, МассивTransOrder)
	
	TransmissionBody = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransmissionBody");

	Для Каждого TransOrder из МассивTransOrder Цикл 
		
		GLogXMLElement = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogXMLElement");
		GLogXMLElement.TransOrder = TransOrder;
		
		TransmissionBody.GLogXMLElement.Добавить(GLogXMLElement);
		
	КонецЦикла;

	Возврат TransmissionBody;
	
КонецФункции
