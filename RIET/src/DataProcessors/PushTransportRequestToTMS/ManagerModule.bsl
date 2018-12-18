
////////////////////////////////////////////////////////////////////
// ВЫГРУЗКА OB В TMS

Процедура PushTransportRequestToTMS(TransportRequestОбъект) Экспорт
	             	
	WSСсылка = ПолучитьWSСсылку();
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	  		
	TransOrder = ПолучитьTransOrder(ФабрикаXDTOTMS, TransportRequestОбъект);
	
	Если TransOrder = Неопределено Тогда
		ВызватьИсключение "Failed to push transport request to TMS: failed to create TransOrder!";
	КонецЕсли;
		
	TransmissionAck = CallTMS(WSСсылка, ФабрикаXDTOTMS, TransOrder);
	 			   		
КонецПроцедуры

Функция ПолучитьTransOrder(ФабрикаXDTOTMS, TransportRequestОбъект) Экспорт
	
	DomesticInternational = ?(TransportRequestОбъект.Country = TransportRequestОбъект.DeliverToCountry, 
		Перечисления.DomesticInternational.Domestic, Перечисления.DomesticInternational.International);

	// Получим данные все данные из базы
	СтруктураДанных = ПолучитьСтруктуруДанных(TransportRequestОбъект.Ссылка);
	
	Если Не TMSСервер.СтруктураДанныхДляTMSПроверена(СтруктураДанных, Истина) Тогда 
		ВызватьИсключение "Failed to push transport request to TMS!";
	КонецЕсли;
	
	// Сформируем узел TransOrderHeader
	TransOrderHeader = ПолучитьTransOrderHeader(ФабрикаXDTOTMS, DomesticInternational, СтруктураДанных);
	
	// Сформируем узел ShipUnitDetail
	ShipUnitDetail = ПолучитьShipUnitDetail(ФабрикаXDTOTMS, DomesticInternational, СтруктураДанных);
	
	// Если что-то пошло не так - прекратим
	Если TransOrderHeader = Неопределено ИЛИ ShipUnitDetail = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	// Сформируем узел TransOrder
	TransOrder = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransOrder");
	TransOrder.TransOrderHeader = TransOrderHeader;
	TransOrder.ShipUnitDetail = ShipUnitDetail;
	
	Возврат TransOrder;
	
КонецФункции	

Функция ПолучитьСтруктуруДанных(TransportRequest)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("TransportRequest", TransportRequest);
	Запрос.Текст =
		"ВЫБРАТЬ
		|	TransportRequest.Номер,
		|	TransportRequest.ExternalReference,
		|	TransportRequest.LegalEntity.Наименование КАК LE_Name,
		|	TransportRequest.LegalEntity.CountryCode КАК LE_CountryCode,
		|	TransportRequest.LegalEntity.CompanyCode КАК LE_CompanyCode,
		|	TransportRequest.LegalEntity.ERPID КАК LE_ERPID,
		|	TransportRequest.LegalEntity.FinanceLocCode КАК LE_FinanceLocCode,
		|	TransportRequest.LegalEntity.FinanceProcess КАК LE_FinanceProcess,
		|	TransportRequest.CostCenter.NonLawson КАК AUNonLawson,
		|	TransportRequest.CostCenter.Код КАК AU,
		|	TransportRequest.ActivityLawson.Код КАК Activity,
		|	TransportRequest.Urgency,
		|	TransportRequest.Comments,
		|	TransportRequest.ReadyToShipLocalTime,
		|	TransportRequest.RequiredDeliveryLocalTime,
		|	TransportRequest.PickUpWarehouse.Код КАК PickUpWarehouseCode,
		|	TransportRequest.DeliverTo.Код КАК DeliverToCode,
		|	TransportRequest.Recharge,
		|	TransportRequest.RechargeType,
		|	TransportRequest.RechargeToLegalEntity.Наименование КАК R_LE_Name,
		|	TransportRequest.RechargeToLegalEntity.CompanyCode КАК R_LE_CompanyCode,
		|	TransportRequest.RechargeToLegalEntity.CountryCode КАК R_LE_CountryCode,
		|	TransportRequest.RechargeToLegalEntity.ERPID КАК R_LE_ERPID,
		|	TransportRequest.RechargeToLegalEntity.FinanceLocCode КАК R_LE_FinanceLocCode,
		|	TransportRequest.RechargeToLegalEntity.FinanceProcess КАК R_LE_FinanceProcess,
		|	TransportRequest.RechargeToAU КАК R_AU,
		|	TransportRequest.RechargeToActivity КАК R_Activity,
		|	TransportRequest.PayingEntity,
		|	TransportRequest.Requestor.Код КАК RequesterAlias,
		|	TransportRequest.Specialist.Код КАК SLSAlias,
		|	TransportRequest.Номер КАК TRNo,
		|	TransportRequest.TMSOBNumber,
		|	TransportRequest.SegmentLawson КАК Segment,
		|	TransportRequest.DeliverTo.Код КАК Consignee
		|ИЗ
		|	Документ.TransportRequest КАК TransportRequest
		|ГДЕ
		|	TransportRequest.Ссылка = &TransportRequest
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Parcels.Ссылка КАК Parcel,
		|	Parcels.Код КАК ParcelNo,
		|	Parcels.PackingType КАК PackingType,
		|	ВЫБОР
		|		КОГДА Parcels.PackingType.TMSID = """"
		|			ТОГДА ""EACH""
		|		ИНАЧЕ Parcels.PackingType.TMSID
		|	КОНЕЦ КАК PackingTypeTMSID,
		|	Parcels.SerialNo,
		|	Parcels.NumOfParcels,
		|	Parcels.LengthCM,
		|	Parcels.WidthCM,
		|	Parcels.HeightCM,
		|	Parcels.DIMsUOM.TMSId КАК DIMsUOM,
		|	Parcels.GrossWeightKG,
		|	Parcels.WeightUOM.TMSId КАК WeightUOM,
		|	Parcels.CubicMeters,
		|	Parcels.HazardClass КАК HazardClass
		|ИЗ
		|	Справочник.Parcels КАК Parcels
		|ГДЕ
		|	Parcels.TransportRequest = &TransportRequest
		|	И НЕ Parcels.ПометкаУдаления
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ParcelsLines.Ссылка КАК Parcel,
		|	ParcelsLines.НомерСтроки,
		|	ParcelsLines.СтрокаИнвойса.КодПоИнвойсу КАК PartNo,
		|	ParcelsLines.СтрокаИнвойса.ERPTreatmentNonLawson КАК ERPTreatment,
		|	ParcelsLines.Qty,
		|	ParcelsLines.QtyUOM КАК QtyUOM,
		|	ВЫБОР
		|		КОГДА ParcelsLines.QtyUOM.TMSIdForItemUOM = """"
		|			ТОГДА ""EACH""
		|		ИНАЧЕ ParcelsLines.QtyUOM.TMSIdForItemUOM
		|	КОНЕЦ КАК QtyUOMTMSIdForItemUOM,
		|	ParcelsLines.СерийныйНомер,
		|	ParcelsLines.СтрокаИнвойса.RAN КАК RAN,
		|	ParcelsLines.СтрокаИнвойса.СтранаПроисхождения.TMSID КАК CountryOfOrigin,
		|	ParcelsLines.СтрокаИнвойса.Currency.НаименованиеEng КАК Currency,
		|	ParcelsLines.СтрокаИнвойса.Сумма КАК Value,
		|	ParcelsLines.NetWeight,
		|	ParcelsLines.СтрокаИнвойса.WeightUOM.TMSId КАК NetWeightUOM,
		|	ParcelsLines.СтрокаИнвойса.ImportReference КАК ImportReference,
		|	ParcelsLines.СтрокаИнвойса.НомерЗаявкиНаЗакупку КАК PONo,
		|	ParcelsLines.СтрокаЗаявкиНаЗакупку КАК POLineNo,
		|	ParcelsLines.СтрокаИнвойса.Наименование КАК ItemName,
		|	ParcelsLines.СтрокаИнвойса КАК Item,
		|	"""" КАК BORGCode,
		|	ВЫРАЗИТЬ(ParcelsLines.СтрокаИнвойса.НаименованиеТовара КАК СТРОКА(300)) КАК ItemDescription
		|ИЗ
		|	Справочник.Parcels.Детали КАК ParcelsLines
		|ГДЕ
		|	ParcelsLines.Ссылка.TransportRequest = &TransportRequest
		|	И НЕ ParcelsLines.Ссылка.ПометкаУдаления";
		
	Результаты = Запрос.ВыполнитьПакет();	
		
	СтруктураДанных = Новый Структура("TransportRequest, Parcels, Items");

	СтруктураДанных.TransportRequest = Результаты[0].Выбрать();
	СтруктураДанных.TransportRequest.Следующий();

	СтруктураДанных.Parcels = Результаты[1].Выгрузить();
	
	СтруктураДанных.Items = Результаты[2].Выгрузить();
	
	Возврат СтруктураДанных;	
	
КонецФункции
      
Функция ПолучитьTransOrderHeader(ФабрикаXDTOTMS, DomesticInternational, СтруктураДанных)

	ВыборкаШапкаTR = СтруктураДанных.TransportRequest;
	TransOrderHeader = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransOrderHeader");
	
	// Номер
	OBNo = СокрЛП(ВыборкаШапкаTR.TMSOBNumber);	
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
	TransOrderHeader.StuffLocation.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, ВыборкаШапкаTR.PickUpWarehouseCode);
		
	// To (there is also to part in ship units)
	TransOrderHeader.DestuffLocation = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "DestuffLocation");
	TransOrderHeader.DestuffLocation.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, ВыборкаШапкаTR.DeliverToCode);
		
	// Legal entity, AU, Activity, Comments, Job Number, etc
	МассивOrderRefnum = ПолучитьМассивOrderRefnum(ФабрикаXDTOTMS, DomesticInternational, ВыборкаШапкаTR);
	Для Каждого OrderRefnum из МассивOrderRefnum Цикл 
		TransOrderHeader.OrderRefnum.Добавить(OrderRefnum);
	КонецЦикла;
		
	// Priority
	Urgencies = Справочники.DeliveryUrgency;
	Если ВыборкаШапкаTR.Urgency = Urgencies.Standard Тогда 
		TransOrderHeader.OrderPriority = "3";
	иначеЕсли ВыборкаШапкаTR.Urgency = Urgencies.Urgent Тогда 
		TransOrderHeader.OrderPriority = "2";
	иначеЕсли ВыборкаШапкаTR.Urgency = Urgencies.Emergency Тогда 
		TransOrderHeader.OrderPriority = "1";
	// { RGS AFokin 06.09.2018 23:59:59 S-I-0005830
	иначеЕсли ВыборкаШапкаTR.Urgency = Urgencies.Critical Тогда 
		TransOrderHeader.OrderPriority = "1";
	// } RGS AFokin 06.09.2018 23:59:59 S-I-0005830
	КонецЕсли;	

	// Total Net Weight Volume KG
	TransOrderHeader.TotalNetWeightVolume = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TotalNetWeightVolume");
	TransOrderHeader.TotalNetWeightVolume.Weight = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Weight");
	TransOrderHeader.TotalNetWeightVolume.Weight.WeightValue = СтруктураДанных.Parcels.Итог("GrossWeightKG");
	TransOrderHeader.TotalNetWeightVolume.Weight.WeightUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "WeightUOMGid");
	TransOrderHeader.TotalNetWeightVolume.Weight.WeightUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Справочники.UOMs.KG, "TMSId"));
	       		
	// Involved Party
	МассивInvolvedParty = ПолучитьМассивInvolvedParty(ФабрикаXDTOTMS, DomesticInternational, ВыборкаШапкаTR);
	Для Каждого InvolvedParty из МассивInvolvedParty Цикл 
		TransOrderHeader.InvolvedParty.Добавить(InvolvedParty);
	КонецЦикла;
	
	HazardousComment = "";
	Сч = 1;
	Для Каждого СтрокаТабParcels из СтруктураДанных.Parcels Цикл
		
		Если СтрокаТабParcels.HazardClass = Справочники.HazardClasses.NonHazardous Тогда 
			Продолжить;
		КонецЕсли;
		
		HazardousComment = "Request contains hazardous parcels.";
		Прервать;
		
	КонецЦикла;
	  	
	// Comments
	Если ЗначениеЗаполнено(ВыборкаШапкаTR.Comments) Тогда
		
		Remark = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Remark");
		Remark.RemarkText = СокрЛП(ВыборкаШапкаTR.Comments + "
		|" + HazardousComment);
				
		Remark.RemarkQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "RemarkQualifierGid");
		Remark.RemarkQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "REM");
		TransOrderHeader.Remark.Добавить(Remark);
		
	КонецЕсли;
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "REM", ВыборкаШапкаTR.Comments));
	
	Возврат TransOrderHeader;
		         	
КонецФункции

Функция ПолучитьМассивOrderRefnum(ФабрикаXDTOTMS, DomesticInternational, ВыборкаШапкаTR)
	
	МассивOrderRefnum = Новый Массив;
	
	// External ref.
	Если ЗначениеЗаполнено(ВыборкаШапкаTR.ExternalReference) Тогда
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "EXT_REF", ВыборкаШапкаTR.ExternalReference));
	КонецЕсли;
	
	// Pickup or delivery date
	ФорматДаты = "ДФ='гггг-ММ-дд HH:мм:сс'";
	//Если DomesticInternational = Перечисления.DomesticInternational.Domestic Тогда
		
		PickupDateText = Формат(ВыборкаШапкаTR.ReadyToShipLocalTime, ФорматДаты);
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_PICKUP_DT", PickupDateText));	
		
	//Иначе
		
		DeliveryDateText = Формат(ВыборкаШапкаTR.RequiredDeliveryLocalTime, ФорматДаты);
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_DELIVERY_DT", DeliveryDateText));
		
	//КонецЕсли;
	
	// Legal entity
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_COMP_NAME", ВыборкаШапкаTR.LE_Name));
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_COUNTRY_CODE", ВыборкаШапкаTR.LE_CountryCode));  
		
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_LEGAL_ENTITY", ВыборкаШапкаTR.LE_CompanyCode));  

	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_ERP_ID", ВыборкаШапкаTR.LE_ERPID));  

   	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_FIN_LOC_CODE", ВыборкаШапкаTR.LE_FinanceLocCode));
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_FIN_PROCESS", ВыборкаШапкаTR.LE_FinanceProcess));
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_PAYING_ENTITY", ?(ВыборкаШапкаTR.PayingEntity = Перечисления.PayingEntities.S, "S", "D")));
	                                                               
	// AU	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_COST_CENTER", СокрЛП(ВыборкаШапкаTR.AU)));

	// Activity
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_ACT_CODE", СокрЛП(ВыборкаШапкаTR.Activity)));
	
	// Segment
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_SEGMENT", СокрЛП(ВыборкаШапкаTR.Segment)));
	
	// Recharge
	Если ВыборкаШапкаTR.Recharge И ВыборкаШапкаTR.RechargeType = Перечисления.RechargeType.Internal Тогда
	
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_RECHARGE_FLAG", "I"));
		
		// Recharge Legal entity
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_COMP_NAME", ВыборкаШапкаTR.R_LE_Name));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_ERP_ID", ВыборкаШапкаTR.R_LE_ERPID));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_LEGAL_ENTITY", ВыборкаШапкаTR.R_LE_CompanyCode));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_COUNTRY_CODE", ВыборкаШапкаTR.R_LE_CountryCode));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_FIN_LOC_CODE", ВыборкаШапкаTR.R_LE_FinanceLocCode));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_FIN_PROCESS", ВыборкаШапкаTR.R_LE_FinanceProcess));
		
		// Recharge AU	
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_COST_CENTER", ВыборкаШапкаTR.R_AU));

		// Recharge Activity	
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_ACT_CODE", СокрЛП(ВыборкаШапкаTR.R_Activity)));
		
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

Функция ПолучитьМассивInvolvedParty(ФабрикаXDTOTMS, DomesticInternational, ВыборкаШапкаTR)
	
	МассивInvolvedParty = Новый Массив;
	
	Если DomesticInternational = Перечисления.DomesticInternational.International Тогда
		
		// Shipper / exportet
		//ShipperInvolvedParty = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "", "EXPORTER", СокрЛП(ВыборкаШапкаER.LEexportet), СокрЛП(ВыборкаШапкаER.LEexportet));
		//МассивInvolvedParty.Добавить(ShipperInvolvedParty);
		
		// Consignee	
		ConsigneeInvolvedParty = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "", "CONSIGNEE", ВыборкаШапкаTR.Consignee, ВыборкаШапкаTR.Consignee);
		МассивInvolvedParty.Добавить(ConsigneeInvolvedParty);
		     		
	КонецЕсли;

	// Requestor
	RequestorInvolvedParty = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "", "REQUESTER", , СокрЛП(ВыборкаШапкаTR.RequesterAlias));
	МассивInvolvedParty.Добавить(RequestorInvolvedParty);
	               		
	// Shipper contact (ORIGIN_SLS)
	ShipperContact = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "SLB", "ORIGIN_SLS", , СокрЛП(ВыборкаШапкаTR.SLSAlias));
	МассивInvolvedParty.Добавить(ShipperContact);
	
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

Функция ПолучитьShipUnitDetail(ФабрикаXDTOTMS, DomesticInternational, СтруктураДанных)
	
	ВыборкаШапкаTR = СтруктураДанных.TransportRequest;
	ТаблицаParcels = СтруктураДанных.Parcels;
	ТаблицаItems = СтруктураДанных.Items;
	
	// Prepare stuff fixed for all ship units
	
	// Earlist pick up and required delivery dates
	TimeWindow = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TimeWindow");
	
	TimeWindow.EarlyPickupDt = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogDateTimeType");
	TimeWindow.EarlyPickupDt.GLogDate = Формат(ВыборкаШапкаTR.ReadyToShipLocalTime, TMSСервер.ПолучитьФорматДатыTMS());
	
	TimeWindow.LateDeliveryDt = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogDateTimeType");
	TimeWindow.LateDeliveryDt.GLogDate = Формат(ВыборкаШапкаTR.RequiredDeliveryLocalTime, TMSСервер.ПолучитьФорматДатыTMS());
	
	// Source and destination locations
	ПеречислениеDomesticInternational = Перечисления.DomesticInternational;
	
	// Source location
	ShipFromLocationRefValue = ВыборкаШапкаTR.PickUpWarehouseCode;
		
	ShipFromLocationRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipFromLocationRef");
	ShipFromLocationRef.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, ShipFromLocationRefValue);
	
	// Destination location
	ShipToLocationRefValue = ВыборкаШапкаTR.DeliverToCode;
		
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
		ShipUnitNo = ПолучитьShipUnitNo(СтрокаТабParcels.ParcelNo, ВыборкаШапкаTR.TMSOBNumber, ВыборкаШапкаTR.TRNo);
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
	
	КонецЦикла;
	
	Возврат ShipUnitDetail;
		         	
КонецФункции

Процедура ПроверитьИЗаполнитьShipUnitContent(Отказ, ФабрикаXDTOTMS, ShipUnit, ТаблицаParcelItems, ParcelNo)
					
	// ERP treatment
	МассивERPTreatment = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаParcelItems, "ERPTreatment");
		
	ShipUnit.TagInfo.ItemTag3 = ?(МассивERPTreatment.Количество() = 1, Справочники.ERPTreatments.ПолучитьTMSId(МассивERPTreatment[0]), "EXPENSE");
	
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

		Если ЗначениеЗаполнено(СокрЛП(СтрокаТабItems.Currency)) и ЗначениеЗаполнено(СтрокаТабItems.Value) Тогда 
			//Currency
			ShipUnitContent.ItemQuantity.DeclaredValue = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "DeclaredValue");
			ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "FinancialAmount");
			ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount.GlobalCurrencyCode = СокрЛП(СтрокаТабItems.Currency);
			
			//Value
			ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount.MonetaryAmount = TMSСервер.ЧислоСтрокой(СтрокаТабItems.Value);
			ShipUnitContent.ItemQuantity.DeclaredValue.FinancialAmount.FuncCurrencyAmount = "0.0";
		КонецЕсли;  
		
		// PO no.
		Если ЗначениеЗаполнено(СтрокаТабItems.PONo) Тогда
			
			ShipUnitLineRefnum = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitLineRefnum");
			ShipUnitLineRefnum.ShipUnitLineRefnumQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitLineRefnumQualifierGid");
			ShipUnitLineRefnum.ShipUnitLineRefnumQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "DESCRIPTION_2");
			ShipUnitLineRefnum.ShipUnitLineRefnumValue = СокрЛП(СтрокаТабItems.PONo);
			ShipUnitContent.ShipUnitLineRefnum.Добавить(ShipUnitLineRefnum);
			
			ShipUnitLineRefnum = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitLineRefnum");
			ShipUnitLineRefnum.ShipUnitLineRefnumQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitLineRefnumQualifierGid");
			ShipUnitLineRefnum.ShipUnitLineRefnumQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "SLB_PO_NUMBER");
			ShipUnitLineRefnum.ShipUnitLineRefnumValue = СокрЛП(СтрокаТабItems.PONo);
			ShipUnitContent.ShipUnitLineRefnum.Добавить(ShipUnitLineRefnum);
			
			// PO line
			Если ЗначениеЗаполнено(СтрокаТабItems.POLineNo) Тогда
				ShipUnitLineRefnum = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitLineRefnum");
				ShipUnitLineRefnum.ShipUnitLineRefnumQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipUnitLineRefnumQualifierGid");
				ShipUnitLineRefnum.ShipUnitLineRefnumQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "SLB_PO_LINE");
				ShipUnitLineRefnum.ShipUnitLineRefnumValue = СокрЛП(СтрокаТабItems.POLineNo);
				ShipUnitContent.ShipUnitLineRefnum.Добавить(ShipUnitLineRefnum);
			КонецЕсли;
		
		КонецЕсли;
			
		ShipUnit.ShipUnitContent.Добавить(ShipUnitContent);
		     				
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьLocationRef(ФабрикаXDTOTMS, Xid)
	
	Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, Xid);
	Gid.DomainName = "SLB";
	
	LocationGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "LocationGid");
	LocationGid.Gid = Gid;
	
	LocationRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "LocationRef");
	LocationRef.LocationGid = LocationGid;
	
	Возврат LocationRef;
	
КонецФункции

Функция ПолучитьShipUnitNo(ParcelNo, TMSOBNumber, TRNo)
		
	Возврат СтрЗаменить(ParcelNo, TRNo, TMSOBNumber);
	
КонецФункции

//////////////////////////////////////////////////////////////////////

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
	
	TransmissionHeader = TMSСервер.ПолучитьTransmissionHeader(ФабрикаXDTOTMS, , "SIMS", "riet-support-ld@slb.com");	
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
