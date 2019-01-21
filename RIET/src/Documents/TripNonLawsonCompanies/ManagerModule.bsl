
// ПЕЧАТНЫЕ ФОРМЫ

Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "NonPO") тогда
		
		ТабДокумент = ПечатьNonPO(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "NonPO",
		"Non-PO", ТабДокумент);
		
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "APPLICATIONTOTHEFORWARDER") тогда
		
		ТабДокумент = ПечатьПорученийЭкспедитору(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "APPLICATIONTOTHEFORWARDER",
		"APPLICATION TO THE FORWARDER", ТабДокумент);
		
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "CMR") тогда
		
		ТабДокумент = ПечатьCMR(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "CMR",
		"CMR", ТабДокумент);
		
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "WorkOrder") тогда
		
		ТабДокумент = ПечатьWorkOrder(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "WorkOrder",
		"Work Order", ТабДокумент);
		
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ТранспортнаяНакладная") тогда
		
		ТабДокумент = ПечатьТранспортнаяНакладная(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "ТранспортнаяНакладная",
		"Транспортная накладная N4", ТабДокумент);
		
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ЗаявкаНаТранспортировкуПоРоссии") тогда
		
		ТабДокумент = ПечатьЗаявкаНаТранспортировкуПоРоссии(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "ЗаявкаНаТранспортировкуПоРоссии",
		"Transport request", ТабДокумент);
		
	КонецЕсли;
	
КонецПроцедуры

// Non-PO

Функция ПечатьNonPO(МассивОбъектов, ОбъектыПечати) 
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "NonPO";
	
	Макет = ПолучитьМакет("NonPO");
	
	Для Каждого Trip из МассивОбъектов Цикл
		
		СтруктураSecondary = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Trip, "Secondary,Primary,");
		ТекстОшибок = "";	
		
		Запрос = Новый Запрос;
		Если СтруктураSecondary.Secondary Тогда
			Запрос.Текст = "ВЫБРАТЬ
			               |	TripNonLawsonCompaniesParcels.Parcel КАК Parcel,
			               |	TripNonLawsonCompaniesParcels.NumOfParcels КАК NumOfParcels,
			               |	TripNonLawsonCompaniesParcels.Ссылка.TotalCostsSum КАК TotalCostsSum,
			               |	Second_Trip.SecondaryCompany КАК SecondaryCompany,
			               |	Second_Trip.SecondaryLegalEntity КАК SecondaryLegalEntity,
			               |	Second_Trip.SecondarySegment КАК SecondarySegment,
			               |	Second_Trip.SecondarySegmentLawson КАК SecondarySegmentLawson,
			               |	Second_Trip.SecondaryCostCenter КАК SecondaryCostCenter,
			               |	Second_Trip.SecondaryProductLine КАК SecondaryProductLine,
			               |	Second_Trip.SecondaryTotalCostsSum КАК SecondaryTotalCostsSum
			               |ПОМЕСТИТЬ Parcels
			               |ИЗ
			               |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels,
			               |	(ВЫБРАТЬ
			               |		TripNonLawsonCompanies.SecondaryCompany КАК SecondaryCompany,
			               |		TripNonLawsonCompanies.SecondaryLegalEntity КАК SecondaryLegalEntity,
			               |		TripNonLawsonCompanies.SecondarySegment КАК SecondarySegment,
			               |		TripNonLawsonCompanies.SecondarySegmentLawson КАК SecondarySegmentLawson,
			               |		TripNonLawsonCompanies.SecondaryCostCenter КАК SecondaryCostCenter,
			               |		TripNonLawsonCompanies.SecondaryProductLine КАК SecondaryProductLine,
			               |		TripNonLawsonCompanies.TotalCostsSum КАК SecondaryTotalCostsSum
			               |	ИЗ
			               |		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
			               |	ГДЕ
			               |		TripNonLawsonCompanies.Ссылка = &SecondaryTrip) КАК Second_Trip
			               |ГДЕ
			               |	TripNonLawsonCompaniesParcels.Ссылка = &Trip
			               |;
			               |
			               |////////////////////////////////////////////////////////////////////////////////
			               |ВЫБРАТЬ
			               |	TripNonLawsonCompanies.Номер КАК TripNo,
			               |	TripNonLawsonCompanies.Дата КАК TripDate,
			               |	TripNonLawsonCompanies.ServiceProvider.ContactName КАК SPContactName,
			               |	TripNonLawsonCompanies.ServiceProvider.ContactPhone КАК SPContactPhone,
			               |	TripNonLawsonCompanies.ServiceProvider.ContactEMail КАК SPContactEmail,
			               |	TripNonLawsonCompanies.ServiceProvider.NameRus КАК SPNameRus,
			               |	TripNonLawsonCompanies.ServiceProvider.Наименование КАК SPNameEng,
			               |	TripNonLawsonCompanies.Specialist КАК Specialist,
			               |	TripNonLawsonCompanies.Specialist.Код КАК SpecialistName,
			               |	TripNonLawsonCompanies.Specialist.EMail КАК SpecialistEmail,
			               |	ВложенныйЗапрос.Currency КАК Currency,
			               |	ВложенныйЗапрос.SecondaryTotalCostsSum КАК TotalCostsSum
			               |ИЗ
			               |	Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies,
			               |	(ВЫБРАТЬ
			               |		TripNonLawsonCompanies.TotalCostsSum КАК SecondaryTotalCostsSum,
			               |		TripNonLawsonCompanies.Currency КАК Currency
			               |	ИЗ
			               |		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
			               |	ГДЕ
			               |		TripNonLawsonCompanies.Ссылка = &SecondaryTrip) КАК ВложенныйЗапрос
			               |ГДЕ
			               |	TripNonLawsonCompanies.Ссылка = &Trip
			               |;
			               |
			               |////////////////////////////////////////////////////////////////////////////////
			               |ВЫБРАТЬ РАЗЛИЧНЫЕ
			               |	Parcels.SecondaryLegalEntity КАК LegalEntity,
			               |	Parcels.SecondaryCompany КАК Company,
			               |	Parcels.SecondaryCompany.NameRus КАК ParentCompanyNameRus,
			               |	Parcels.SecondaryCompany.Наименование КАК ParentCompanyNameEng,
			               |	Parcels.SecondaryCompany.Код КАК ParentCompanyCode,
			               |	Parcels.SecondaryCompany.Lawson КАК LawsonCompany,
			               |	Parcels.SecondaryLegalEntity.NameRus КАК LegalEntityNameRus,
			               |	Parcels.SecondaryLegalEntity.Наименование КАК LegalEntityNameEng,
			               |	Parcels.SecondarySegment.NameEng КАК SegmentNameEng,
			               |	Parcels.SecondarySegment.Наименование КАК SegmentNameRus,
			               |	Parcels.SecondarySegment.SegmentCode КАК SegmentCode,
			               |	Parcels.SecondarySegment КАК Segment,
			               |	Parcels.SecondaryProductLine.Наименование КАК ProductLineName,
			               |	Parcels.SecondaryProductLine.Код КАК ProductLineCode,
			               |	Parcels.SecondaryProductLine КАК ProductLine,
			               |	Parcels.SecondaryLegalEntity.CostCenter КАК LegalEntityCostCenter,
			               |	Parcels.SecondaryCostCenter КАК AU,
			               |	Parcels.Parcel.TransportRequest.Activity КАК Activity,
			               |	Parcels.Parcel.TransportRequest.Company.PostalAddressForInvoiceAndSupportingDocuments КАК FinancialAddressEng,
			               |	Parcels.Parcel.TransportRequest.Company.PostalAddressForInvoiceAndSupportingDocumentsRus КАК FinancialAddressRus,
			               |	Parcels.Parcel.TransportRequest.RechargeToLegalEntity КАК RechargeToLegalEntity,
			               |	Parcels.Parcel.TransportRequest.RechargeToAU КАК RechargeToAU,
			               |	Parcels.Parcel.TransportRequest.RechargeToActivity КАК RechargeToActivity,
			               |	Parcels.Parcel.TransportRequest.RechargeType КАК RechargeType,
			               |	Parcels.Parcel.TransportRequest.ClientForRecharge КАК ClientForRecharge,
			               |	Parcels.Parcel.TransportRequest.AgreementForRecharge КАК AgreementForRecharge,
			               |	Parcels.Parcel.TransportRequest.Recharge КАК Recharge,
			               |	Parcels.Parcel.TransportRequest.RechargeDetails КАК RechargeDetails
			               |ИЗ
			               |	Parcels КАК Parcels
			               |;
			               |
			               |////////////////////////////////////////////////////////////////////////////////
			               |ВЫБРАТЬ
			               |	Parcels.Parcel.TransportRequest КАК TransportRequest,
			               |	TripNonLawsonCompaniesStopsSource.ActualDepartureLocalTime КАК PickUpActualDepartureLocalTime,
			               |	Parcels.Parcel.TransportRequest.PickUpWarehouse КАК PickUpWarehouse,
			               |	TripNonLawsonCompaniesStopsDestination.ActualArrivalLocalTime КАК DeliverToActualArrivalLocalTime,
			               |	Parcels.Parcel.TransportRequest.DeliverTo КАК DeliverTo,
			               |	СУММА(Parcels.Parcel.GrossWeightKG / Parcels.Parcel.NumOfParcels * Parcels.NumOfParcels) КАК GrossWeightKG,
			               |	Parcels.Parcel.TransportRequest.Requestor.EMail КАК RequestorEMail,
			               |	Parcels.Parcel.TransportRequest.Requestor.Код КАК RequestorName,
			               |	Parcels.Parcel.TransportRequest.Номер КАК TRNo,
			               |	Parcels.SecondaryLegalEntity КАК LegalEntity,
			               |	Parcels.SecondarySegment КАК Segment,
			               |	Parcels.SecondaryProductLine КАК ProductLine,
			               |	Parcels.SecondaryLegalEntity.CostCenter КАК LegalEntityCostCenter,
			               |	Parcels.SecondaryCostCenter КАК AU,
			               |	Parcels.Parcel.TransportRequest.Activity КАК Activity,
			               |	Parcels.SecondaryTotalCostsSum КАК Cost,
			               |	Parcels.Parcel.TransportRequest.RechargeToLegalEntity КАК RechargeToLegalEntity,
			               |	Parcels.Parcel.TransportRequest.RechargeToAU КАК RechargeToAU,
			               |	Parcels.Parcel.TransportRequest.RechargeToActivity КАК RechargeToActivity,
			               |	Parcels.Parcel.TransportRequest.RechargeType КАК RechargeType,
			               |	Parcels.Parcel.TransportRequest.ClientForRecharge КАК ClientForRecharge,
			               |	Parcels.Parcel.TransportRequest.AgreementForRecharge КАК AgreementForRecharge,
			               |	Parcels.Parcel.TransportRequest.Recharge КАК Recharge,
			               |	Parcels.Parcel.TransportRequest.RechargeDetails КАК RechargeDetails
			               |ИЗ
			               |	Parcels КАК Parcels
			               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStopsSource
			               |		ПО (TripNonLawsonCompaniesStopsSource.Location = Parcels.Parcel.TransportRequest.PickUpWarehouse)
			               |			И (TripNonLawsonCompaniesStopsSource.Type <> ЗНАЧЕНИЕ(Перечисление.StopsTypes.Destination))
			               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStopsDestination
			               |		ПО Parcels.Parcel.TransportRequest.DeliverTo = TripNonLawsonCompaniesStopsDestination.Location
			               |			И (TripNonLawsonCompaniesStopsDestination.Type <> ЗНАЧЕНИЕ(Перечисление.StopsTypes.Source))
			               |ГДЕ
			               |	TripNonLawsonCompaniesStopsDestination.Ссылка = &Trip
			               |	И TripNonLawsonCompaniesStopsSource.Ссылка = &Trip
			               |
			               |СГРУППИРОВАТЬ ПО
			               |	Parcels.Parcel.TransportRequest,
			               |	TripNonLawsonCompaniesStopsSource.ActualDepartureLocalTime,
			               |	Parcels.Parcel.TransportRequest.PickUpWarehouse,
			               |	TripNonLawsonCompaniesStopsDestination.ActualArrivalLocalTime,
			               |	Parcels.Parcel.TransportRequest.DeliverTo,
			               |	Parcels.Parcel.TransportRequest.Requestor.EMail,
			               |	Parcels.Parcel.TransportRequest.Requestor.Код,
			               |	Parcels.Parcel.TransportRequest.Номер,
			               |	Parcels.Parcel.TransportRequest.Activity,
			               |	Parcels.Parcel.TransportRequest.RechargeToLegalEntity,
			               |	Parcels.Parcel.TransportRequest.RechargeToAU,
			               |	Parcels.Parcel.TransportRequest.RechargeToActivity,
			               |	Parcels.Parcel.TransportRequest.RechargeType,
			               |	Parcels.Parcel.TransportRequest.ClientForRecharge,
			               |	Parcels.Parcel.TransportRequest.AgreementForRecharge,
			               |	Parcels.Parcel.TransportRequest.Recharge,
			               |	Parcels.Parcel.TransportRequest.RechargeDetails,
			               |	Parcels.SecondaryTotalCostsSum,
			               |	Parcels.SecondaryLegalEntity,
			               |	Parcels.SecondarySegment,
			               |	Parcels.SecondaryProductLine,
			               |	Parcels.SecondaryLegalEntity.CostCenter,
			               |	Parcels.SecondaryCostCenter
			               |;
			               |
			               |////////////////////////////////////////////////////////////////////////////////
			               |ВЫБРАТЬ
			               |	СтрокиИнвойса.TransportRequest КАК TransportRequest,
			               |	СтрокиИнвойса.КодПоИнвойсу КАК PartNo,
			               |	ВЫРАЗИТЬ(СтрокиИнвойса.НаименованиеТовара КАК СТРОКА(500)) КАК DescriptionEng,
			               |	СтрокиИнвойса.DescriptionRus КАК DescriptionRus,
			               |	ParcelsДетали.Ссылка.LengthCM КАК LengthCM,
			               |	ParcelsДетали.Ссылка.WidthCM КАК WidthCM,
			               |	ParcelsДетали.Ссылка.HeightCM КАК HeightCM
			               |ИЗ
			               |	Справочник.Parcels.Детали КАК ParcelsДетали
			               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
			               |		ПО ParcelsДетали.СтрокаИнвойса = СтрокиИнвойса.Ссылка
			               |ГДЕ
			               |	ParcelsДетали.Ссылка В
			               |			(ВЫБРАТЬ
			               |				Parcels.Parcel
			               |			ИЗ
			               |				Parcels КАК Parcels)
			               |	И НЕ СтрокиИнвойса.ПометкаУдаления";
			Запрос.УстановитьПараметр("Trip", СтруктураSecondary.Primary);
			Запрос.УстановитьПараметр("SecondaryTrip", Trip);
		Иначе
			Запрос.Текст = "ВЫБРАТЬ
			               |	TripNonLawsonCompaniesParcels.Parcel,
			               |	TripNonLawsonCompaniesParcels.NumOfParcels,
			               |	TripNonLawsonCompaniesParcels.Ссылка.TotalCostsSum КАК TotalCostsSum
			               |ПОМЕСТИТЬ Parcels
			               |ИЗ
			               |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
			               |ГДЕ
			               |	TripNonLawsonCompaniesParcels.Ссылка = &Trip
			               |;
			               |
			               |////////////////////////////////////////////////////////////////////////////////
			               |ВЫБРАТЬ
			               |	TripNonLawsonCompanies.Номер КАК TripNo,
			               |	TripNonLawsonCompanies.Дата КАК TripDate,
			               |	TripNonLawsonCompanies.ServiceProvider.ContactName КАК SPContactName,
			               |	TripNonLawsonCompanies.ServiceProvider.ContactPhone КАК SPContactPhone,
			               |	TripNonLawsonCompanies.ServiceProvider.ContactEMail КАК SPContactEmail,
			               |	TripNonLawsonCompanies.ServiceProvider.NameRus КАК SPNameRus,
			               |	TripNonLawsonCompanies.ServiceProvider.Наименование КАК SPNameEng,
			               |	TripNonLawsonCompanies.Specialist КАК Specialist,
			               |	TripNonLawsonCompanies.Specialist.Код КАК SpecialistName,
			               |	TripNonLawsonCompanies.Specialist.EMail КАК SpecialistEmail,
			               |	TripNonLawsonCompanies.Currency,
			               |	TripNonLawsonCompanies.TotalCostsSum
			               |ИЗ
			               |	Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
			               |ГДЕ
			               |	TripNonLawsonCompanies.Ссылка = &Trip
			               |;
			               |
			               |////////////////////////////////////////////////////////////////////////////////
			               |ВЫБРАТЬ РАЗЛИЧНЫЕ
			               |	Parcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
			               |	Parcels.Parcel.TransportRequest.Company КАК Company,
			               |	Parcels.Parcel.TransportRequest.Company.NameRus КАК ParentCompanyNameRus,
			               |	Parcels.Parcel.TransportRequest.Company.Наименование КАК ParentCompanyNameEng,
			               |	Parcels.Parcel.TransportRequest.Company.Код КАК ParentCompanyCode,
			               |	Parcels.Parcel.TransportRequest.Company.Lawson КАК LawsonCompany,
			               |	Parcels.Parcel.TransportRequest.LegalEntity.NameRus КАК LegalEntityNameRus,
			               |	Parcels.Parcel.TransportRequest.LegalEntity.Наименование КАК LegalEntityNameEng,
			               |	Parcels.Parcel.TransportRequest.Segment.NameEng КАК SegmentNameEng,
			               |	Parcels.Parcel.TransportRequest.Segment.Наименование КАК SegmentNameRus,
			               |	Parcels.Parcel.TransportRequest.Segment.SegmentCode КАК SegmentCode,
			               |	Parcels.Parcel.TransportRequest.Segment КАК Segment,
			               |	Parcels.Parcel.TransportRequest.ProductLine.Наименование КАК ProductLineName,
			               |	Parcels.Parcel.TransportRequest.ProductLine.Код КАК ProductLineCode,
			               |	Parcels.Parcel.TransportRequest.ProductLine КАК ProductLine,
			               |	Parcels.Parcel.TransportRequest.LegalEntity.CostCenter КАК LegalEntityCostCenter,
			               |	Parcels.Parcel.TransportRequest.CostCenter КАК AU,
			               |	Parcels.Parcel.TransportRequest.Activity КАК Activity,
			               |	Parcels.Parcel.TransportRequest.Company.PostalAddressForInvoiceAndSupportingDocuments КАК FinancialAddressEng,
			               |	Parcels.Parcel.TransportRequest.Company.PostalAddressForInvoiceAndSupportingDocumentsRus КАК FinancialAddressRus,
			               |	Parcels.Parcel.TransportRequest.RechargeToLegalEntity КАК RechargeToLegalEntity,
			               |	Parcels.Parcel.TransportRequest.RechargeToAU КАК RechargeToAU,
			               |	Parcels.Parcel.TransportRequest.RechargeToActivity КАК RechargeToActivity,
			               |	Parcels.Parcel.TransportRequest.RechargeType КАК RechargeType,
			               |	Parcels.Parcel.TransportRequest.ClientForRecharge КАК ClientForRecharge,
			               |	Parcels.Parcel.TransportRequest.AgreementForRecharge КАК AgreementForRecharge,
			               |	Parcels.Parcel.TransportRequest.Recharge КАК Recharge,
			               |	Parcels.Parcel.TransportRequest.RechargeDetails КАК RechargeDetails
			               |ИЗ
			               |	Parcels КАК Parcels
			               |;
			               |
			               |////////////////////////////////////////////////////////////////////////////////
			               |ВЫБРАТЬ
			               |	Parcels.Parcel.TransportRequest КАК TransportRequest,
			               |	TripNonLawsonCompaniesStopsSource.ActualDepartureLocalTime КАК PickUpActualDepartureLocalTime,
			               |	Parcels.Parcel.TransportRequest.PickUpWarehouse КАК PickUpWarehouse,
			               |	TripNonLawsonCompaniesStopsDestination.ActualArrivalLocalTime КАК DeliverToActualArrivalLocalTime,
			               |	Parcels.Parcel.TransportRequest.DeliverTo КАК DeliverTo,
			               |	СУММА(Parcels.Parcel.GrossWeightKG / Parcels.Parcel.NumOfParcels * Parcels.NumOfParcels) КАК GrossWeightKG,
			               |	Parcels.Parcel.TransportRequest.Requestor.EMail КАК RequestorEMail,
			               |	Parcels.Parcel.TransportRequest.Requestor.Код КАК RequestorName,
			               |	Parcels.Parcel.TransportRequest.Номер КАК TRNo,
			               |	Parcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
			               |	Parcels.Parcel.TransportRequest.Segment КАК Segment,
			               |	Parcels.Parcel.TransportRequest.ProductLine КАК ProductLine,
			               |	Parcels.Parcel.TransportRequest.LegalEntity.CostCenter КАК LegalEntityCostCenter,
			               |	Parcels.Parcel.TransportRequest.CostCenter КАК AU,
			               |	Parcels.Parcel.TransportRequest.Activity КАК Activity,
			               |	Parcels.TotalCostsSum КАК Cost,
			               |	Parcels.Parcel.TransportRequest.RechargeToLegalEntity КАК RechargeToLegalEntity,
			               |	Parcels.Parcel.TransportRequest.RechargeToAU КАК RechargeToAU,
			               |	Parcels.Parcel.TransportRequest.RechargeToActivity КАК RechargeToActivity,
			               |	Parcels.Parcel.TransportRequest.RechargeType КАК RechargeType,
			               |	Parcels.Parcel.TransportRequest.ClientForRecharge КАК ClientForRecharge,
			               |	Parcels.Parcel.TransportRequest.AgreementForRecharge КАК AgreementForRecharge,
			               |	Parcels.Parcel.TransportRequest.Recharge КАК Recharge,
			               |	Parcels.Parcel.TransportRequest.RechargeDetails КАК RechargeDetails
			               |ИЗ
			               |	Parcels КАК Parcels
			               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStopsSource
			               |		ПО (TripNonLawsonCompaniesStopsSource.Location = Parcels.Parcel.TransportRequest.PickUpWarehouse)
			               |			И (TripNonLawsonCompaniesStopsSource.Type <> ЗНАЧЕНИЕ(Перечисление.StopsTypes.Destination))
			               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStopsDestination
			               |		ПО Parcels.Parcel.TransportRequest.DeliverTo = TripNonLawsonCompaniesStopsDestination.Location
			               |			И (TripNonLawsonCompaniesStopsDestination.Type <> ЗНАЧЕНИЕ(Перечисление.StopsTypes.Source))
			               |ГДЕ
			               |	TripNonLawsonCompaniesStopsDestination.Ссылка = &Trip
			               |	И TripNonLawsonCompaniesStopsSource.Ссылка = &Trip
			               |
			               |СГРУППИРОВАТЬ ПО
			               |	Parcels.Parcel.TransportRequest,
			               |	TripNonLawsonCompaniesStopsSource.ActualDepartureLocalTime,
			               |	Parcels.Parcel.TransportRequest.PickUpWarehouse,
			               |	TripNonLawsonCompaniesStopsDestination.ActualArrivalLocalTime,
			               |	Parcels.Parcel.TransportRequest.DeliverTo,
			               |	Parcels.Parcel.TransportRequest.Requestor.EMail,
			               |	Parcels.Parcel.TransportRequest.Requestor.Код,
			               |	Parcels.Parcel.TransportRequest.Номер,
			               |	Parcels.Parcel.TransportRequest.LegalEntity,
			               |	Parcels.TotalCostsSum,
			               |	Parcels.Parcel.TransportRequest.Segment,
			               |	Parcels.Parcel.TransportRequest.ProductLine,
			               |	Parcels.Parcel.TransportRequest.LegalEntity.CostCenter,
			               |	Parcels.Parcel.TransportRequest.CostCenter,
			               |	Parcels.Parcel.TransportRequest.Activity,
			               |	Parcels.Parcel.TransportRequest.RechargeToLegalEntity,
			               |	Parcels.Parcel.TransportRequest.RechargeToAU,
			               |	Parcels.Parcel.TransportRequest.RechargeToActivity,
			               |	Parcels.Parcel.TransportRequest.RechargeType,
			               |	Parcels.Parcel.TransportRequest.ClientForRecharge,
			               |	Parcels.Parcel.TransportRequest.AgreementForRecharge,
			               |	Parcels.Parcel.TransportRequest.Recharge,
			               |	Parcels.Parcel.TransportRequest.RechargeDetails
			               |;
			               |
			               |////////////////////////////////////////////////////////////////////////////////
			               |ВЫБРАТЬ
			               |	СтрокиИнвойса.TransportRequest,
			               |	СтрокиИнвойса.КодПоИнвойсу КАК PartNo,
			               |	ВЫРАЗИТЬ(СтрокиИнвойса.НаименованиеТовара КАК СТРОКА(500)) КАК DescriptionEng,
			               |	СтрокиИнвойса.DescriptionRus,
			               |	ParcelsДетали.Ссылка.LengthCM,
			               |	ParcelsДетали.Ссылка.WidthCM,
			               |	ParcelsДетали.Ссылка.HeightCM
			               |ИЗ
			               |	Справочник.Parcels.Детали КАК ParcelsДетали
			               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
			               |		ПО ParcelsДетали.СтрокаИнвойса = СтрокиИнвойса.Ссылка
			               |ГДЕ
			               |	ParcelsДетали.Ссылка В
			               |			(ВЫБРАТЬ
			               |				Parcels.Parcel
			               |			ИЗ
			               |				Parcels КАК Parcels)
			               |	И НЕ СтрокиИнвойса.ПометкаУдаления";
			Запрос.УстановитьПараметр("Trip", Trip);
		КонецЕсли;
		
		Результат = Запрос.ВыполнитьПакет();
		
		ВыборкаTrip = Результат[1].Выбрать();
		ВыборкаTrip.Следующий();
		
		ТЗLegalEntities = Результат[2].Выгрузить();
		//МассивLegalEntity = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТЗLegalEntities, "LegalEntity");
		
		ТЗTRs = Результат[3].Выгрузить();
		
		УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗTRs.ВыгрузитьКолонку("GrossWeightKG"), ВыборкаTrip.TotalCostsSum, ТЗTRs, "Cost");
		
		ТЗItems = Результат[4].Выгрузить();
		
		НомерLE = 1;
		СтруктураОтбораLE = Новый Структура("LegalEntity,ProductLine,Segment,LegalEntityCostCenter,AU,Activity,
		|Recharge,RechargeDetails,RechargeType,RechargeToLegalEntity,RechargeToAU,RechargeToActivity,ClientForRecharge,AgreementForRecharge");
		
		Для Каждого СтрLegalEntity из ТЗLegalEntities Цикл
			
			Если СтрLegalEntity.LawsonCompany Тогда 
				Продолжить;
			КонецЕсли;
			
			Если ТабличныйДокумент.ВысотаТаблицы > 0 Тогда
				ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			КонецЕсли;
			
			ЗаполнитьЗначенияСвойств(СтруктураОтбораLE, СтрLegalEntity);
			//ТЗHeader = ТЗLegalEntities.Скопировать(СтруктураОтбораLE);
			
			РеквизитыLE = СтрLegalEntity;
			
			НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
			
			/////////////////////////////////////////////////////////////////////
			// Header
			ОбластьМакетаHeader = Макет.ПолучитьОбласть("Header");
			
			ПостфиксНомера = СокрЛ(НомерLE);
			Пока СтрДлина(ПостфиксНомера) < 3 Цикл 
				ПостфиксНомера = "0" + СокрЛ(ПостфиксНомера);
			КонецЦикла;
			
			ОбластьМакетаHeader.Параметры.TripNoLE = СокрЛП(ВыборкаTrip.TripNo) + "-" + ПостфиксНомера;
			ОбластьМакетаHeader.Параметры.TripDate = ВыборкаTrip.TripDate;
			
			// Service Provider
			ОбластьМакетаHeader.Параметры.SPName = СокрЛП(ВыборкаTrip.SPNameRus) + "/" + СокрЛП(ВыборкаTrip.SPNameEng);
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Service provider name (Rus)", СокрЛП(ВыборкаTrip.SPNameRus));
			
			ОбластьМакетаHeader.Параметры.SPContactName  = СокрЛП(ВыборкаTrip.SPContactName);
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Service provider contact name", СокрЛП(ВыборкаTrip.SPContactName));
			ОбластьМакетаHeader.Параметры.SPContactEmail = СокрЛП(ВыборкаTrip.SPContactEmail);
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Service provider contact Email", СокрЛП(ВыборкаTrip.SPContactEmail));
			ОбластьМакетаHeader.Параметры.SPContactPhone = СокрЛП(ВыборкаTrip.SPContactPhone);
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Service provider contact Phone", СокрЛП(ВыборкаTrip.SPContactPhone));
			
			ОбластьМакетаHeader.Параметры.FinancialAddress = СокрЛП(РеквизитыLE.FinancialAddressRUS) + "/" + СокрЛП(РеквизитыLE.FinancialAddressEng);
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Company financial address Rus", СокрЛП(РеквизитыLE.FinancialAddressRUS));
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Company financial address Eng", СокрЛП(РеквизитыLE.FinancialAddressEng));
			
			//Company	
			ОбластьМакетаHeader.Параметры.ParentCompanyName = СокрЛП(РеквизитыLE.ParentCompanyNameRus) + "/" + СокрЛП(РеквизитыLE.ParentCompanyNameEng);
			ОбластьМакетаHeader.Параметры.ParentCompanyCode = СокрЛП(РеквизитыLE.ParentCompanyCode);
			
			//LEName
			ОбластьМакетаHeader.Параметры.LEName = СокрЛП(РеквизитыLE.LegalEntityNameRus) + "/" + СокрЛП(РеквизитыLE.LegalEntityNameEng);
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Legal entity name (Rus)", СокрЛП(РеквизитыLE.LegalEntityNameRus));
			
			//Segment / Product line
			Если ЗначениеЗаполнено(РеквизитыLE.ProductLineName) Тогда 
				ОбластьМакетаHeader.Параметры.SegmentProductLine = СокрЛП(РеквизитыLE.ProductLineCode) + " " + СокрЛП(РеквизитыLE.ProductLineName);
			иначе
				ОбластьМакетаHeader.Параметры.SegmentProductLine = СокрЛП(РеквизитыLE.SegmentNameRus) + "/" + СокрЛП(РеквизитыLE.SegmentNameEng) 
				+ ?(ЗначениеЗаполнено(РеквизитыLE.SegmentCode), " /" + СокрЛП(РеквизитыLE.SegmentCode), "");
			КонецЕсли;
			
			//CostCenter 
			// { RGS AArsentev S-I-0001800 22.28.2016 10:22:52
			//Если ЗначениеЗаполнено(РеквизитыLE.CostCenter) Тогда 
			//	ОбластьМакетаHeader.Параметры.CostCenter = СокрЛП(РеквизитыLE.CostCenter);
			//иначе
			//	ОбластьМакетаHeader.Параметры.CostCenter = СокрЛП(РеквизитыLE.AU);
			//КонецЕсли;
			CompanySettings = Документы.TransportRequest.ПолучитьСтруктуруCompanySettings(РеквизитыLE.Company, ВыборкаTrip.TripDate);
			Если CompanySettings.UseCostCenterFromLegalEntityForNON_PO Тогда
				 ОбластьМакетаHeader.Параметры.CostCenter = СокрЛП(РеквизитыLE.LegalEntityCostCenter);
			Иначе
				 ОбластьМакетаHeader.Параметры.CostCenter = СокрЛП(РеквизитыLE.AU);
			КонецЕсли;
			// } RGS AArsentev S-I-0001800 22.28.2016 10:22:52
			
			//Activity				
			ОбластьМакетаHeader.Параметры.Activity = СокрЛП(РеквизитыLE.Activity);
			
			ТабличныйДокумент.Вывести(ОбластьМакетаHeader);
			
			//////////////////////////////////////////////////////////////////////////////
			// TableLine 
			ОбластьМакетаTableLine = Макет.ПолучитьОбласть("TableLine");
			
			ТЗTRsLE = ТЗTRs.Скопировать(СтруктураОтбораLE);
			
			СтруктураОтбораTR = Новый Структура("TransportRequest");
			МассивRequestorName = Новый Массив;
			МассивRequestorEmail = Новый Массив;
			
			Для Каждого СтрTRLE из ТЗTRsLE Цикл 
				
				ОбластьМакетаTableLine.Параметры.TRNo = СокрЛП(СтрTRLE.TRNo);
				ОбластьМакетаTableLine.Параметры.PickUp = СокрЛП(СтрTRLE.PickUpWarehouse);
				ОбластьМакетаTableLine.Параметры.DeliverTo = СокрЛП(СтрTRLE.DeliverTo);
				ОбластьМакетаTableLine.Параметры.GrossWeight = СокрЛП(СтрTRLE.GrossWeightKG);
				ОбластьМакетаTableLine.Параметры.TimeOfDeparture = СокрЛП(СтрTRLE.PickUpActualDepartureLocalTime);
				ОбластьМакетаTableLine.Параметры.TimeOfArrival = СокрЛП(СтрTRLE.DeliverToActualArrivalLocalTime);
				
				СтруктураОтбораTR.TransportRequest = СтрTRLE.TransportRequest;
				
				ТЗDimsLE = ТЗItems.Скопировать(СтруктураОтбораTR, "LengthCM,WidthCM,HeightCM");
				ТЗDimsLE.Свернуть("LengthCM,WidthCM,HeightCM");
				
				ТЗItemsLE = ТЗItems.Скопировать(СтруктураОтбораTR, "PartNo,DescriptionEng,DescriptionRus");
				ТЗItemsLE.Свернуть("PartNo,DescriptionEng,DescriptionRus");
				
				CargoDescription = "";
				сч = 1;
				Для Каждого СтрItemsLE из ТЗItemsLE Цикл 
					Если сч > 3 Тогда 
						Прервать;
					КонецЕсли;
					CargoDescription = СокрЛП(СтрItemsLE.PartNo) + ":" + СокрЛП(СтрItemsLE.DescriptionRus) + "/" + СокрЛП(СтрItemsLE.DescriptionEng); 
					сч = сч + 1;
				КонецЦикла;
				ОбластьМакетаTableLine.Параметры.CargoDescription = СокрЛП(CargoDescription);
				
				PackageDims = "";
				сч = 1;
				Для Каждого СтрDimsLE из ТЗDimsLE Цикл 
					Если сч > 3 Тогда                 
						Прервать;
					КонецЕсли;
					PackageDims = PackageDims + ?(PackageDims = "", "", ";") + СокрЛП(СтрDimsLE.LengthCM) + "x" + СокрЛП(СтрDimsLE.WidthCM) + "x" + СокрЛП(СтрDimsLE.HeightCM) + " CM";
					сч = сч + 1;
				КонецЦикла;
				ОбластьМакетаTableLine.Параметры.PackageDims = СокрЛП(PackageDims);
				
				ОбластьМакетаTableLine.Параметры.Currency = СокрЛП(ВыборкаTrip.Currency);
				ОбластьМакетаTableLine.Параметры.Cost = СтрTRLE.Cost;
				     								
				Если МассивRequestorName.Найти(СтрTRLE.RequestorName) = Неопределено Тогда 
					МассивRequestorName.Добавить(СтрTRLE.RequestorName); 
				КонецЕсли;
				Если МассивRequestorEmail.Найти(СтрTRLE.RequestorEmail) = Неопределено Тогда 
					МассивRequestorEmail.Добавить(СтрTRLE.RequestorEmail); 
				КонецЕсли;
				
				ТабличныйДокумент.Вывести(ОбластьМакетаTableLine);
				
			КонецЦикла;
			
			//////////////////////////////////////////////////////////////////////////////
			// Footer 
			ОбластьМакетаFooter = Макет.ПолучитьОбласть("Footer");
			
			RechargeInfo = "";
			
			Если РеквизитыLE.Recharge Тогда
				
				Если РеквизитыLE.RechargeType = Перечисления.RechargeType.Internal Тогда
					RechargeInfo = СокрЛП(РеквизитыLE.RechargeToLegalEntity) + ", AU:" + СокрЛП(РеквизитыLE.RechargeToAU) 
						+ ", AC:" + СокрЛП(РеквизитыLE.RechargeToActivity);
				иначе
					RechargeInfo = ?(ЗначениеЗаполнено(РеквизитыLE.ClientForRecharge), СокрЛП(РеквизитыLE.ClientForRecharge) + " ", "") 
						+ ?(ЗначениеЗаполнено(РеквизитыLE.AgreementForRecharge), СокрЛП(РеквизитыLE.AgreementForRecharge), "");
				КонецЕсли;
				
				RechargeInfo = RechargeInfo + ?(ЗначениеЗаполнено(РеквизитыLE.RechargeDetails), "; " + СокрЛП(РеквизитыLE.RechargeDetails), "");

			КонецЕсли;
		
			ОбластьМакетаFooter.Параметры.RechargeInfo = RechargeInfo;
			ОбластьМакетаFooter.Параметры.SpecialistName = ВыборкаTrip.SpecialistName;
			ОбластьМакетаFooter.Параметры.SpecialistEmail = ВыборкаTrip.SpecialistEmail;
			ОбластьМакетаFooter.Параметры.RequestorName = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(МассивRequestorName);
			ОбластьМакетаFooter.Параметры.RequestorEmail = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(МассивRequestorEmail);
			
			ДвоичныеДанныеКартинки = LocalDistributionForNonLawsonСервер.ПолучитьКартинкуПодписи(ВыборкаTrip.Specialist);
			Если ДвоичныеДанныеКартинки = Неопределено Тогда
				ОбластьМакетаFooter.Рисунки.Удалить(ОбластьМакетаFooter.Рисунки.КартинкаПодписи);
			Иначе
				ОбластьМакетаFooter.Рисунки.КартинкаПодписи.Картинка = Новый Картинка(ДвоичныеДанныеКартинки);
			КонецЕсли;
			
			ТабличныйДокумент.Вывести(ОбластьМакетаFooter);
			
			УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, Trip);
			
			НомерLE = НомерLE + 1;
			
		КонецЦикла;  // LE
		
		Если НомерLE = 1 Тогда
			Сообщить("Non-PO can be generated only for Non-Lawson companies!", СтатусСообщения.Внимание);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ТекстОшибок) Тогда
			Сообщить(СокрЛП(Trip)+ ": 
			|" + СокрЛП(ТекстОшибок));
		КонецЕсли;
		
	КонецЦикла;  // Trip
	
	Возврат ТабличныйДокумент;
	
КонецФункции


// ПОРУЧЕНИЕ ЭКСПЕДИТОРУ

Функция ПечатьПорученийЭкспедитору(МассивОбъектов, ОбъектыПечати) 
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "APPLICATIONTOTHEFORWARDER";
	
	Макет = ПолучитьМакет("APPLICATIONTOTHEFORWARDER");
	
	СтруктураПараметров = Новый Структура;
	
	Для Каждого Trip из МассивОбъектов Цикл 
		
		ТекстОшибок = "";
		
		ТекстЗапроса = 
		"ВЫБРАТЬ
		|	TripNonLawsonCompaniesParcels.Parcel,
		|	TripNonLawsonCompaniesParcels.NumOfParcels,
		|	TripNonLawsonCompaniesParcels.Ссылка КАК Ссылка
		|ПОМЕСТИТЬ Parcels
		|ИЗ
		|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		|ГДЕ
		|	TripNonLawsonCompaniesParcels.Ссылка = &Trip
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Parcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
		|	Parcels.Parcel.TransportRequest.LegalEntity.NameRus КАК Client,
		|	Parcels.Parcel.TransportRequest.ConsignTo.NameRus КАК ConsignTo,
		|	Parcels.Ссылка.ServiceProvider.NameRus КАК Forwarder,
		|	СУММА(Parcels.Parcel.GrossWeightKG / Parcels.Parcel.NumOfParcels * Parcels.NumOfParcels) КАК ParcelsGrossWeight,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.NameRus КАК Consignor,
		|	Parcels.Parcel.TransportRequest.DeliverToAddress КАК DeliverToAddress,
		|	СУММА(Parcels.Parcel.CubicMeters / Parcels.Parcel.NumOfParcels * Parcels.NumOfParcels) КАК ParcelsCubicMeters,
		|	Parcels.Ссылка.Номер КАК TripNo,
		|	Parcels.Ссылка КАК Trip,
		|	Parcels.Ссылка.Дата КАК DOCDate,
		|	Parcels.Ссылка.Equipment.NameRus КАК TransporationType,
		|	Parcels.Parcel.TransportRequest.Company КАК Company,
		|	ВЫРАЗИТЬ(Parcels.Parcel.TransportRequest.LegalEntity.SoldToAddressRus КАК СТРОКА(300)) КАК LegalEntitySoldToAddressRus,
		|	Parcels.Parcel.TransportRequest.PickUpFromContact КАК PickUpFromContact,
		|	Parcels.Parcel.TransportRequest.PickUpFromPhone КАК PickUpFromPhone,
		|	Parcels.Parcel.TransportRequest.PickUpFromAddress КАК PickUpFromAddress,
		|	Parcels.Parcel.TransportRequest.Loading КАК Loading,
		|	Parcels.Parcel.TransportRequest.DeliverToContact КАК DeliverToContact,
		|	Parcels.Parcel.TransportRequest.DeliverToPhone КАК DeliverToPhone,
		|	Parcels.Parcel.TransportRequest.RequiredDeliveryLocalTime КАК RDD,
		|	Parcels.Parcel.TransportRequest.CustomUnionTransaction КАК CustomUnionTransaction,
		|	Parcels.Parcel.TransportRequest.DeliverTo.NameRus КАК Грузополучатель,
		|	Parcels.Parcel.TransportRequest.Номер КАК TRNo
		|ИЗ
		|	Parcels КАК Parcels
		|
		|СГРУППИРОВАТЬ ПО
		|	Parcels.Parcel.TransportRequest.LegalEntity,
		|	Parcels.Ссылка.ServiceProvider.NameRus,
		|	Parcels.Parcel.TransportRequest.LegalEntity.NameRus,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.NameRus,
		|	Parcels.Parcel.TransportRequest.DeliverToAddress,
		|	Parcels.Ссылка.TotalCostsSum,
		|	Parcels.Ссылка.Currency,
		|	Parcels.Ссылка.Номер,
		|	Parcels.Ссылка.Дата,
		|	Parcels.Ссылка,
		|	Parcels.Parcel.TransportRequest.Company,
		|	Parcels.Ссылка.Equipment.NameRus,
		|	ВЫРАЗИТЬ(Parcels.Parcel.TransportRequest.LegalEntity.SoldToAddressRus КАК СТРОКА(300)),
		|	Parcels.Parcel.TransportRequest.PickUpFromContact,
		|	Parcels.Parcel.TransportRequest.PickUpFromPhone,
		|	Parcels.Parcel.TransportRequest.PickUpFromAddress,
		|	Parcels.Parcel.TransportRequest.Loading,
		|	Parcels.Parcel.TransportRequest.DeliverToContact,
		|	Parcels.Parcel.TransportRequest.DeliverToPhone,
		|	Parcels.Parcel.TransportRequest.RequiredDeliveryLocalTime,
		|	Parcels.Parcel.TransportRequest.ConsignTo.NameRus,
		|	Parcels.Parcel.TransportRequest.CustomUnionTransaction,
		|	Parcels.Parcel.TransportRequest.DeliverTo.NameRus,
		|	Parcels.Parcel.TransportRequest.Номер
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Parcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
		|	СУММА(Parcels.NumOfParcels) КАК NumOfParcels,
		|	Parcels.Parcel.PackingType.CodeRus КАК PackingType,
		|	Parcels.Parcel.HazardClass КАК HazardClass,
		|	Parcels.Parcel.TransportRequest.PickUpFromContact КАК PickUpFromContact,
		|	Parcels.Parcel.TransportRequest.PickUpFromPhone КАК PickUpFromPhone,
		|	Parcels.Parcel.TransportRequest.PickUpFromAddress КАК PickUpFromAddress,
		|	Parcels.Parcel.TransportRequest.Loading КАК Loading,
		|	Parcels.Parcel.TransportRequest.DeliverToContact КАК DeliverToContact,
		|	Parcels.Parcel.TransportRequest.DeliverToPhone КАК DeliverToPhone,
		|	Parcels.Parcel.TransportRequest.DeliverToAddress КАК DeliverToAddress,
		|	Parcels.Parcel.TransportRequest.RequiredDeliveryLocalTime КАК RDD,
		|	Parcels.Parcel.LengthCM КАК LengthCM,
		|	Parcels.Parcel.WidthCM КАК WidthCM,
		|	Parcels.Parcel.HeightCM КАК HeightCM,
		|	Parcels.Parcel.GrossWeightKG / Parcels.Parcel.NumOfParcels * Parcels.NumOfParcels КАК GrossWeightKG
		|ИЗ
		|	Parcels КАК Parcels
		|
		|СГРУППИРОВАТЬ ПО
		|	Parcels.Parcel.TransportRequest.LegalEntity,
		|	Parcels.Parcel.PackingType.CodeRus,
		|	Parcels.Parcel.HazardClass,
		|	Parcels.Parcel.TransportRequest.PickUpFromContact,
		|	Parcels.Parcel.TransportRequest.PickUpFromPhone,
		|	Parcels.Parcel.TransportRequest.PickUpFromAddress,
		|	Parcels.Parcel.TransportRequest.Loading,
		|	Parcels.Parcel.TransportRequest.DeliverToContact,
		|	Parcels.Parcel.TransportRequest.DeliverToPhone,
		|	Parcels.Parcel.TransportRequest.DeliverToAddress,
		|	Parcels.Parcel.TransportRequest.RequiredDeliveryLocalTime,
		|	Parcels.Parcel.LengthCM,
		|	Parcels.Parcel.WidthCM,
		|	Parcels.Parcel.HeightCM,
		|	Parcels.Parcel.GrossWeightKG / Parcels.Parcel.NumOfParcels * Parcels.NumOfParcels
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	BarcodeOfTrip.Barcode КАК ШтрихКод
		|ИЗ
		|	РегистрСведений.BarcodeOfTrip КАК BarcodeOfTrip
		|ГДЕ
		|	BarcodeOfTrip.Trip = &Trip";
		
		Запрос = Новый Запрос(ТекстЗапроса);
		Запрос.УстановитьПараметр("Trip", Trip);
		
		Результат = Запрос.ВыполнитьПакет();
		
		ТЗ = Результат[1].Выгрузить();
		ТЗParcels = Результат[2].Выгрузить();
		
		ВыборкаШтрихкод = Результат[3].Выбрать();
		ЕстьШтрихкод = ВыборкаШтрихкод.Следующий();
		
		СтруктураОтбораLE = Новый Структура(
		"LegalEntity,PickUpFromContact,PickUpFromPhone,PickUpFromAddress,Loading,DeliverToContact,DeliverToPhone,DeliverToAddress,RDD"); 	
		НомерLE = 1;
		МассивHazardClass = Новый Массив;
		
		ПервыйДокумент = Истина;
		КоличествоСтрокТЗ = ТЗ.Количество();
		ПредыдущийТрип = ?(КоличествоСтрокТЗ = 0, Неопределено, ТЗ[0].Trip);
		НомерСтрокиНачало = Неопределено;
		
		Для Каждого РеквизитыLE из ТЗ Цикл
			
			Если ТабличныйДокумент.ВысотаТаблицы > 0 Тогда
				ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			КонецЕсли;
			
			Если Не ПервыйДокумент И РеквизитыLE.Trip <> ПредыдущийТрип Тогда
				УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, ПредыдущийТрип);
			КонецЕсли;
			
			Если ПервыйДокумент ИЛИ РеквизитыLE.Trip <> ПредыдущийТрип Тогда
				НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
				Если ПервыйДокумент Тогда
					ПервыйДокумент = Ложь;
				КонецЕсли;
				Если РеквизитыLE.Trip <> ПредыдущийТрип Тогда
					ПредыдущийТрип = РеквизитыLE.Trip;
				КонецЕсли;
			КонецЕсли;
			
			ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
			
			ЗаполнитьЗначенияСвойств(ОбластьМакета.Параметры, РеквизитыLE);
			
			Если РеквизитыLE.CustomUnionTransaction Тогда 
				ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Client/Consign-to: Legal entity name (Rus)", СокрЛП(РеквизитыLE.ConsignTo));
			иначе
				ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Client: Legal entity name (Rus)", СокрЛП(РеквизитыLE.Client));
			КонецЕсли;

			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Client: Legal entity Sold to address (Rus)", СокрЛП(РеквизитыLE.LegalEntitySoldToAddressRus));
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Forwarder: Service provider name (Rus)", СокрЛП(РеквизитыLE.Forwarder));
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Consignor: Pick-up warehouse name (Rus)", СокрЛП(РеквизитыLE.Consignor));        
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Transporation type (Rus)", СокрЛП(РеквизитыLE.TransporationType));        
			
			ОбластьМакета.Параметры.Client = СокрЛП(РеквизитыLE.Client) + ?(ПустаяСтрока(РеквизитыLE.LegalEntitySoldToAddressRus), "", ",
			|" + СокрЛП(РеквизитыLE.LegalEntitySoldToAddressRus));
			
			Если РеквизитыLE.CustomUnionTransaction Тогда 
				ОбластьМакета.Параметры.Consignee = СокрЛП(РеквизитыLE.ConsignTo);
			иначе
				// { RGS AArsentev 19.12.2017 S-I-0003934
				//ОбластьМакета.Параметры.Consignee = СокрЛП(РеквизитыLE.Client);
				ОбластьМакета.Параметры.Consignee = СокрЛП(РеквизитыLE.Грузополучатель);
				// } RGS AArsentev 19.12.2017 S-I-0003934
			КонецЕсли;
			ПостфиксНомера = СокрЛ(НомерLE);
			Пока СтрДлина(ПостфиксНомера) < 3 Цикл 
				ПостфиксНомера = "0" + СокрЛ(ПостфиксНомера);
			КонецЦикла;
			ОбластьМакета.Параметры.DOCNo = СокрЛП(РеквизитыLE.TripNo) + "-" + ПостфиксНомера;
			// { RGS AArsentev 25.12.2017 S-I-0004290
			ОбластьМакета.Параметры.TRNo = СокрЛП(РеквизитыLE.TRNo);
			// } RGS AArsentev 25.12.2017 S-I-0004290
			
			ЗаполнитьЗначенияСвойств(СтруктураОтбораLE, РеквизитыLE);
			ТЗParcels_LE = ТЗParcels.Скопировать(СтруктураОтбораLE);
			
			NumOfParcels_PackingType = "";
			
			//{ RGS AArsentev 03.03.2017 S-I-0002656
			//Для Каждого СтрPacking из ТЗParcels_LE Цикл 
			//	
			//	NumOfParcels_PackingType = NumOfParcels_PackingType + ?(NumOfParcels_PackingType = "", "", ", ") +
			//	СтрPacking.NumOfParcels + " " + СокрЛП(СтрPacking.PackingType);
			//	
			//	Если СтрPacking.HazardClass <> Справочники.HazardClasses.NonHazardous
			//		И МассивHazardClass.Найти(СтрPacking.HazardClass) = Неопределено Тогда 
			//		МассивHazardClass.Добавить(СтрPacking.HazardClass); 
			//	КонецЕсли;
			//	
			//КонецЦикла;
			
			ГрузовыеМеста = ТЗParcels_LE.Скопировать();
			ГрузовыеМеста.Свернуть("LengthCM, WidthCM, HeightCM, PackingType", "NumOfParcels, GrossWeightKG");
			
			Для Каждого Место ИЗ ГрузовыеМеста Цикл
				
				NumOfParcels_PackingType = NumOfParcels_PackingType + ?(NumOfParcels_PackingType = "", "", "; " + Символы.ПС) +
				Место.NumOfParcels + " " + РГСофт.ФормаМножественногоЧисла("упаковка", "упаковки", "упаковок", Место.NumOfParcels) + ": тип "  + """" + нрег(СокрЛП(Место.PackingType)) + """" + ", " + Место.LengthCM + "x" + Место.WidthCM + "x" + Место.HeightCM + " см, " + Место.GrossWeightKG + " kg";
				
			КонецЦикла;
				
			Для Каждого СтрPacking из ТЗParcels_LE Цикл 
				
				Если СтрPacking.HazardClass <> Справочники.HazardClasses.NonHazardous
					И МассивHazardClass.Найти(СтрPacking.HazardClass) = Неопределено Тогда 
					МассивHazardClass.Добавить(СтрPacking.HazardClass); 
				КонецЕсли;
				
			КонецЦикла;
			//} RGS AArsentev 03.03.2017 S-I-0002656
			
			ОбластьМакета.Параметры.NumOfParcels_PackingType = NumOfParcels_PackingType;
			
			ОбластьМакета.Параметры.Marking = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(МассивHazardClass);
			
			ОбластьМакета.Параметры.GoodsReadyForShipmentPlaceDate = СокрЛП(РеквизитыLE.PickUpFromAddress) 
			+ ", " + СокрЛП(РеквизитыLE.PickUpFromContact) 
			+ ", " + СокрЛП(РеквизитыLE.PickUpFromPhone); 
			
			ОбластьМакета.Параметры.PointOfDestination = СокрЛП(РеквизитыLE.DeliverToAddress) 
			+ ", " + СокрЛП(РеквизитыLE.DeliverToContact) 
			+ ", " + СокрЛП(РеквизитыLE.DeliverToPhone);
			
			ОбластьМакета.Параметры.RDD = "Доставка не позднее " + Формат(РеквизитыLE.RDD, "ДФ=""дд.ММ.гггг"""); 
			
			ОбластьМакета.Параметры.Comments = ?(ЗначениеЗаполнено(РеквизитыLE.Loading), 
			"загрузка кузова: " + Перечисления.LoadingTypes.ПолучитьПредставлениеLoadingTypeRU(РеквизитыLE.Loading), "");	
			
			// Штрих-код
			Если ЕстьШтрихкод Тогда                                     
				ОбластьШтрихКода = ОбластьМакета.Рисунки.ШтрихКод;
				Если ЗначениеЗаполнено(ВыборкаШтрихкод.ШтрихКод) Тогда
					ПараметрыШтрихкода = Новый Структура;
					ПараметрыШтрихкода.Вставить("Ширина",			ОбластьШтрихКода.Ширина);
					ПараметрыШтрихкода.Вставить("Высота",			40);
					ПараметрыШтрихкода.Вставить("Штрихкод",			ВыборкаШтрихкод.ШтрихКод);
					ПараметрыШтрихкода.Вставить("ТипКода",			4); // Code 128
					ПараметрыШтрихкода.Вставить("ОтображатьТекст",	Истина);
					ПараметрыШтрихкода.Вставить("РазмерШрифта",		12);
					Попытка
						ОбластьШтрихКода.Картинка = LocalDistributionForNonLawsonСервер.ПолучитьКартинкуШтрихкода(ПараметрыШтрихкода);
					Исключение
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось сформировать ШтрихКод");
					КонецПопытки
				КонецЕсли;
			Иначе
				ОбластьМакета.Рисунки.Удалить(ОбластьМакета.Рисунки.ШтрихКод);
			КонецЕсли;
			
			// Штрих-код пароля
			ПользовательWebDB = LocalDistributionForNonLawsonСервер.НайтиПользователяWebDBПоПоставке(Trip);
			Если ЗначениеЗаполнено(ПользовательWebDB) И Не ПустаяСтрока(ПользовательWebDB.Пароль) Тогда
				
				ОбластьШтрихКода = ОбластьМакета.Рисунки.ШтрихКодПароля;
				
				ПараметрыШтрихкода = Новый Структура;
				ПараметрыШтрихкода.Вставить("Ширина",			ОбластьШтрихКода.Ширина);
				ПараметрыШтрихкода.Вставить("Высота",			40);
				ПараметрыШтрихкода.Вставить("Штрихкод",			ПользовательWebDB.Пароль);
				ПараметрыШтрихкода.Вставить("ТипКода",			4); // Code 128
				ПараметрыШтрихкода.Вставить("ОтображатьТекст",	Истина);
				ПараметрыШтрихкода.Вставить("РазмерШрифта",		12);
				Попытка
					ОбластьШтрихКода.Картинка = LocalDistributionForNonLawsonСервер.ПолучитьКартинкуШтрихкода(ПараметрыШтрихкода);
				Исключение
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось сформировать ШтрихКод");
				КонецПопытки
			Иначе
				ОбластьМакета.Рисунки.Удалить(ОбластьМакета.Рисунки.ШтрихКодПароля);
			КонецЕсли;
			
			ТабличныйДокумент.Вывести(ОбластьМакета);
			
			НомерLE = НомерLE + 1;
			
		КонецЦикла;
		
		Если КоличествоСтрокТЗ > 0 Тогда
			УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, РеквизитыLE.Trip);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ТекстОшибок) Тогда
			Сообщить(СокрЛП(Trip)+ ": 
			|" + СокрЛП(ТекстОшибок));
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ТабличныйДокумент;
	
КонецФункции

// CMR

Функция ПечатьCMR(МассивОбъектов, ОбъектыПечати) 
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "CMR";
	
	Макет = ПолучитьМакет("CMR");
	
	Для Каждого Trip из МассивОбъектов Цикл 
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331  ++
		НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
		// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331  ++
		ТекстОшибок = "";	
		
		ТекстЗапроса = 	
		"ВЫБРАТЬ
		|	TripNonLawsonCompaniesParcels.Parcel,
		|	TripNonLawsonCompaniesParcels.NumOfParcels,
		|	TripNonLawsonCompaniesParcels.Ссылка.Дата КАК TripDate,
		|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider.NameRus КАК ServiceProviderNameRus,
		|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider.Address КАК ServiceProviderAddress,
		|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider.Ссылка КАК ServiceProvider
		|ПОМЕСТИТЬ Parcels
		|ИЗ
		|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		|ГДЕ
		|	TripNonLawsonCompaniesParcels.Ссылка = &Trip
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331
		//|	Parcels.Parcel.TransportRequest.Company.NameRus КАК CompanyNameRus,
		|	Parcels.Parcel.TransportRequest.Shipper.NameRus КАК CompanyNameRus,
		// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 
		|	Parcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
		//|	ВЫРАЗИТЬ(Parcels.Parcel.TransportRequest.LegalEntity.SoldToAddressRus КАК СТРОКА(500)) КАК LegalEntityAddressRus,
		|	ВЫРАЗИТЬ(Parcels.Parcel.TransportRequest.Shipper.SoldToAddressRus КАК СТРОКА(500)) КАК LegalEntityAddressRus,
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331
		//|	  Parcels.Parcel.TransportRequest.LegalEntity.NameRus КАК LegalEntityNameRus,
		|	Parcels.Parcel.TransportRequest.Shipper.NameRus КАК LegalEntityNameRus,
		// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 
		|	Parcels.Parcel.TransportRequest.DeliverTo.AddressRus КАК DeliverToAddressRus,
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331
		//|	Parcels.Parcel.TransportRequest.DeliverToContact КАК DeliverToContact,
		//|	Parcels.Parcel.TransportRequest.DeliverToPhone КАК DeliverToPhone,
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331
		|	Parcels.Parcel.TransportRequest.DeliverTo.City КАК DeliverToCity, 
		|	Parcels.Parcel.TransportRequest.DeliverTo.RCACountry.Наименование КАК DeliverToRCACountryName,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.City КАК PickUpCity,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.RCACountry.Наименование КАК PickUpRCACountryName, 
		|	Parcels.TripDate,
		|	Parcels.ServiceProviderNameRus,  
		|	Parcels.ServiceProviderAddress,  
		|	Parcels.ServiceProvider,        
		|	СУММА(Parcels.NumOfParcels) КАК NumOfParcels,
		|	СУММА(Parcels.Parcel.GrossWeightKG / Parcels.Parcel.NumOfParcels * Parcels.NumOfParcels) КАК ParcelsGrossWeight,
		|	СУММА(Parcels.Parcel.CubicMeters / Parcels.Parcel.NumOfParcels * Parcels.NumOfParcels) КАК ParcelsCubicMeters,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse КАК PickUpWarehouse,
		|	Parcels.Parcel.TransportRequest.DeliverTo КАК DeliverTo,
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331
		//|	Parcels.Parcel.TransportRequest.DeliverToAddress КАК DeliverToAddress,
		// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331
		|	Parcels.Parcel.TransportRequest.ConsignTo КАК ConsignTo,
		|	ВЫРАЗИТЬ(Parcels.Parcel.TransportRequest.ConsignTo.SoldToAddressRus КАК СТРОКА(500)) КАК ConsignToAddressRus,
		|	Parcels.Parcel.TransportRequest.ConsignTo.NameRus КАК ConsignToNameRus
		|ИЗ
		|	Parcels КАК Parcels
		|
		|СГРУППИРОВАТЬ ПО
		|	Parcels.TripDate,
		|	Parcels.ServiceProviderNameRus,
		|	Parcels.ServiceProviderAddress,
		|	Parcels.ServiceProvider,
		|	Parcels.Parcel.TransportRequest.Company.NameRus,
		|	Parcels.Parcel.TransportRequest.LegalEntity,
		//|	Parcels.Parcel.TransportRequest.DeliverToContact,
		//|	Parcels.Parcel.TransportRequest.DeliverToPhone,
		|	Parcels.Parcel.TransportRequest.DeliverTo.City,
		|	Parcels.Parcel.TransportRequest.DeliverTo.RCACountry.Наименование,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.City,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.RCACountry.Наименование,
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331
		//|	Parcels.Parcel.TransportRequest.LegalEntity.NameRus,
		|	Parcels.Parcel.TransportRequest.Shipper.NameRus,
		// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331
		|	ВЫРАЗИТЬ(Parcels.Parcel.TransportRequest.LegalEntity.SoldToAddressRus КАК СТРОКА(500)),
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse,
		|	Parcels.Parcel.TransportRequest.DeliverTo,
		|	Parcels.Parcel.TransportRequest.DeliverTo.AddressRus,
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331
		//|	Parcels.Parcel.TransportRequest.DeliverToAddress,
		// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331
		|	Parcels.Parcel.TransportRequest.ConsignTo,
		|	ВЫРАЗИТЬ(Parcels.Parcel.TransportRequest.ConsignTo.SoldToAddressRus КАК СТРОКА(500)),
		|	Parcels.Parcel.TransportRequest.ConsignTo.NameRus,
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
		|   ВЫРАЗИТЬ(Parcels.Parcel.TransportRequest.Shipper.SoldToAddressRus КАК СТРОКА(500)),
		|  Parcels.Parcel.TransportRequest.Shipper.NameRus
		// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВЫРАЗИТЬ(СтрокиИнвойса.НаименованиеТовара КАК СТРОКА(500)) КАК DescriptionEng,
		|	СтрокиИнвойса.DescriptionRus,
		|	СУММА(ParcelsДетали.Qty) КАК Qty,
		|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ParcelsДетали.QtyUOM.NameRus) КАК QtyUOMNameRus,
		|	СтрокиИнвойса.СерийныйНомер,
		|	МАКСИМУМ(ParcelsДетали.Ссылка.PackingType.CodeRus) КАК PackingTypeCodeRus,
		|	СтрокиИнвойса.TransportRequest.PickUpWarehouse КАК PickUpWarehouse,
		|	СтрокиИнвойса.TransportRequest.DeliverTo КАК DeliverTo,
		|	СтрокиИнвойса.TransportRequest.LegalEntity КАК LegalEntity,
		|	СтрокиИнвойса.TransportRequest.ConsignTo КАК ConsignTo,
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
		|	МАКСИМУМ(ParcelsДетали.Ссылка.TransportRequest) КАК TransportRequest,
		|	Parcels.NumOfParcels КАК NumOfParcels,
		|	МАКСИМУМ(ParcelsДетали.Ссылка.LengthCM) КАК LengthCM,
		|	МАКСИМУМ(ParcelsДетали.Ссылка.WidthCM) КАК WidthCM,
		|	МАКСИМУМ(ParcelsДетали.Ссылка.HeightCM) КАК HeightCM,
		|	МАКСИМУМ(ParcelsДетали.Ссылка.GrossWeightKG) КАК GrossWeightKG,
		|	МАКСИМУМ(ParcelsДетали.Ссылка.CubicMeters) КАК CubicMeters
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
		|ИЗ
		|	Справочник.Parcels.Детали КАК ParcelsДетали
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
		|		ПО ParcelsДетали.СтрокаИнвойса = СтрокиИнвойса.Ссылка
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Parcels КАК Parcels
		|		ПО ParcelsДетали.Ссылка = Parcels.Parcel
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
		|ГДЕ
		|	ParcelsДетали.Ссылка В
		|			(ВЫБРАТЬ
		|				Parcels.Parcel
		|			ИЗ
		|				Parcels КАК Parcels)
		|	И НЕ СтрокиИнвойса.ПометкаУдаления
		|
		|СГРУППИРОВАТЬ ПО
		|	ВЫРАЗИТЬ(СтрокиИнвойса.НаименованиеТовара КАК СТРОКА(500)),
		|	СтрокиИнвойса.DescriptionRus,
		|	СтрокиИнвойса.СерийныйНомер,
		|	СтрокиИнвойса.TransportRequest.DeliverTo,
		|	СтрокиИнвойса.TransportRequest.PickUpWarehouse,
		|	СтрокиИнвойса.TransportRequest.LegalEntity,
		|	СтрокиИнвойса.TransportRequest.ConsignTo,
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
		|	Parcels.NumOfParcels
		// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
		|;
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331
		//|
		//|////////////////////////////////////////////////////////////////////////////////
		//|ВЫБРАТЬ РАЗЛИЧНЫЕ
		//|	TripNonLawsonCompaniesПрисоединенныеФайлы.Наименование КАК Attachment
		//|ИЗ
		//|	Справочник.TripNonLawsonCompaniesПрисоединенныеФайлы КАК TripNonLawsonCompaniesПрисоединенныеФайлы
		//|ГДЕ
		//|	НЕ TripNonLawsonCompaniesПрисоединенныеФайлы.ПометкаУдаления
		//|	И TripNonLawsonCompaniesПрисоединенныеФайлы.ВладелецФайла = &Trip";
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Parcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
		|	СУММА(Parcels.NumOfParcels) КАК NumOfParcels,
		|	Parcels.Parcel.PackingType.CodeRus КАК PackingType,
		|	Parcels.Parcel.TransportRequest.PickUpFromContact КАК PickUpFromContact,
		|	Parcels.Parcel.TransportRequest.PickUpFromPhone КАК PickUpFromPhone,
		|	Parcels.Parcel.TransportRequest.PickUpFromAddress КАК PickUpFromAddress,
		|	Parcels.Parcel.TransportRequest.DeliverToContact КАК DeliverToContact,
		|	Parcels.Parcel.TransportRequest.DeliverToPhone КАК DeliverToPhone,
		|	Parcels.Parcel.TransportRequest.DeliverToAddress КАК DeliverToAddress,
		|	Parcels.Parcel.LengthCM КАК LengthCM,
		|	Parcels.Parcel.WidthCM КАК WidthCM,
		|	Parcels.Parcel.HeightCM КАК HeightCM,
		|	СУММА(Parcels.Parcel.GrossWeightKG / Parcels.Parcel.NumOfParcels * Parcels.NumOfParcels) КАК GrossWeightKG,
		|	Parcels.Parcel.TransportRequest.ConsignTo КАК ConsignTo,
		|	Parcels.Parcel.TransportRequest КАК TransportRequest,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse КАК PickUpWarehouse,
		|	Parcels.Parcel.TransportRequest.DeliverTo КАК DeliverTo,
		|	Parcels.Parcel.TransportRequest.Номер КАК TransportRequestНомер
		|ИЗ
		|	Parcels КАК Parcels
		|
		|СГРУППИРОВАТЬ ПО
		|	Parcels.Parcel.TransportRequest.LegalEntity,
		|	Parcels.Parcel.PackingType.CodeRus,
		|	Parcels.Parcel.TransportRequest.PickUpFromContact,
		|	Parcels.Parcel.TransportRequest.PickUpFromPhone,
		|	Parcels.Parcel.TransportRequest.PickUpFromAddress,
		|	Parcels.Parcel.TransportRequest.DeliverToContact,
		|	Parcels.Parcel.TransportRequest.DeliverToPhone,
		|	Parcels.Parcel.TransportRequest.DeliverToAddress,
		|	Parcels.Parcel.LengthCM,
		|	Parcels.Parcel.WidthCM,
		|	Parcels.Parcel.HeightCM,
		|	Parcels.Parcel.TransportRequest.ConsignTo,
		|	Parcels.Parcel.TransportRequest,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse,
		|	Parcels.Parcel.TransportRequest.DeliverTo,
		|	Parcels.Parcel.TransportRequest.Номер";
		// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331
		
		Запрос = Новый Запрос(ТекстЗапроса);
		Запрос.УстановитьПараметр("Trip", Trip);
		
		Результат = Запрос.ВыполнитьПакет();
		
		ТЗLE_WH = Результат[1].Выгрузить();
		ТЗItems = Результат[2].Выгрузить();
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
		Парсели = Результат[3].Выгрузить();
		// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
		НомерLE = 1;
		//ConsignTo - добавлен по S-I-0002403 
		СтруктураОтбора = Новый Структура("LegalEntity,DeliverTo,PickUpWarehouse,ConsignTo");   
		
		Для Каждого СтрТЗLE_WH из ТЗLE_WH Цикл
			
			Если ТабличныйДокумент.ВысотаТаблицы > 0 Тогда
				ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			КонецЕсли;
			// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 Закомментировал
			//НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
			// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 Закомментировал
			/////////////////////////////////////////////////////////////////////
			// Header
			ОбластьМакетаHeader = Макет.ПолучитьОбласть("Header");
			ПостфиксНомера = СокрЛ(НомерLE);
			Пока СтрДлина(ПостфиксНомера) < 2 Цикл 
				ПостфиксНомера = "0" + СокрЛ(ПостфиксНомера);
			КонецЦикла;
			
			ОбластьМакетаHeader.Параметры.Number = СокрЛП(Формат(СтрТЗLE_WH.TripDate, "ДФ=""ггММдд""")) + "-" + ПостфиксНомера;
			
			ЗаполнитьЗначенияСвойств(ОбластьМакетаHeader.Параметры, СтрТЗLE_WH); 
			
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Legal entity name(Rus)", СокрЛП(СтрТЗLE_WH.LegalEntityNameRus));
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Legal entity address(Rus)", СокрЛП(СтрТЗLE_WH.LegalEntityAddressRus));
			
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Service provider name (Rus)", СокрЛП(СтрТЗLE_WH.ServiceProviderNameRus));
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Service provider address", СокрЛП(СтрТЗLE_WH.ServiceProviderAddress));
			
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Consign-to name(Rus)", СокрЛП(СтрТЗLE_WH.ConsignToNameRus));
			ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Consign-to address(Rus)", СокрЛП(СтрТЗLE_WH.ConsignToAddressRus));
			
			//////////////////////////////////////////////////////////////////////////////
			// Item 
			ЗаполнитьЗначенияСвойств(СтруктураОтбора, СтрТЗLE_WH);
			
			// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++ 
			ГрузовыеМеста = Парсели.Скопировать(СтруктураОтбора);
			
			DeliverToContact = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ГрузовыеМеста, "DeliverToContact"),", ");
			DeliverToPhone = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ГрузовыеМеста, "DeliverToPhone"),", ");
			
			AttachmentsList = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ГрузовыеМеста, "TransportRequestНомер"),", ");
			
			ОбластьМакетаHeader.Параметры.DeliverToContact = DeliverToContact;
			ОбластьМакетаHeader.Параметры.DeliverToPhone   = DeliverToPhone;
			// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
			
			// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331  Закомментировал
			
			//ТЗItemsLE = ТЗItems.Скопировать(СтруктураОтбора);
			
			//Descriptions = "";
			//Для Каждого СтрTRLE из ТЗItemsLE Цикл 
			//	
			//	Descriptions = "
			//	|" + СокрЛП(СтрTRLE.DescriptionEng) + ", " + СокрЛП(СтрTRLE.DescriptionRus) + ", " + СокрЛП(СтрTRLE.Qty) + " " 
			//	+ СокрЛП(СтрTRLE.QtyUOMNameRus) +"Серийный номер: " + СокрЛП(СтрTRLE.СерийныйНомер);
			//	
			//КонецЦикла;
			//
			//ОбластьМакетаHeader.Параметры.Description = СокрЛП(Descriptions);
			//
			//ОбластьМакетаHeader.Параметры.PackingTypesCodeRus = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(
			//РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТЗItemsLE, "PackingTypeCodeRus"),", ");
			// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 Закомментировал
			
			//NumOfParcels = 0;
			//NumOfParcels = NumOfParcels + СтрТЗLE_WH.NumOfParcels;//ParcelsGrossWeight = СтрТЗLE_WH.ParcelsGrossWeightKG;
			
			
			//ОбластьМакетаHeader.Параметры.Attachments = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(
			//РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТЗAttachments, "Attachment"),", ");
			// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331  Закомментировал
			
			// { RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
			
			ГрузовыеМеста.Свернуть("LengthCM, WidthCM, HeightCM, PackingType, LegalEntity, PickUpWarehouse, DeliverTo, ConsignTo", "NumOfParcels, GrossWeightKG");	
			ТипыУпаковокРазмерыУпаковок = "";									
			
			Для Каждого ГрузоМесто ИЗ ГрузовыеМеста Цикл
				
				ТипыУпаковокРазмерыУпаковок = ТипыУпаковокРазмерыУпаковок + ?(ТипыУпаковокРазмерыУпаковок = "", "", "; ") +
				ГрузоМесто.NumOfParcels + " " + РГСофт.ФормаМножественногоЧисла("упаковка", "упаковки", "упаковок", ГрузоМесто.NumOfParcels) + ": тип "  + """" + нрег(СокрЛП(ГрузоМесто.PackingType))+ """" +
				": " + нрег(СокрЛП(ГрузоМесто.GrossWeightKG)) + " кг, " + ГрузоМесто.LengthCM + "x" + ГрузоМесто.WidthCM + "x" + ГрузоМесто.HeightCM + " см ";
				
			КонецЦикла;
			
			ОбластьМакетаHeader.Параметры.PackingTypesCodeRus = ТипыУпаковокРазмерыУпаковок;
			
			ОбластьМакетаHeader.Параметры.Attachments =  "Invoice " + СокрЛП(AttachmentsList);			
			// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
			
			ТабличныйДокумент.Вывести(ОбластьМакетаHeader);
			// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 Закомментировал
			//УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, Trip);
			// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 Закомментировал
			НомерLE = НомерLE + 1;
			
		КонецЦикла;  // LE	
		
		//  RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, Trip);
		// } RGS ASeryakov 28/11/2017 18:00:00 PM - S-I-0003331 ++
		
		Если ЗначениеЗаполнено(ТекстОшибок) Тогда
			Сообщить(СокрЛП(Trip)+ ": 
			|" + СокрЛП(ТекстОшибок));
		КонецЕсли;
		
	КонецЦикла;  // Trip
	
	Возврат ТабличныйДокумент;
	
КонецФункции

// ОБЩЕЕ ДЛЯ ПЕЧАТИ

Процедура ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, ИмяПараметра, Параметр)
	
	Если ЗначениеЗаполнено(Параметр) Тогда 
		Возврат;
	КонецЕсли;
	
	НоваяОшибка = "Не заполнен параметр "+ ИмяПараметра +"!";
	
	Если СтрНайти(ТекстОшибок, НоваяОшибка) = 0 Тогда 
		ТекстОшибок = ТекстОшибок + "
		|" + НоваяОшибка;
	КонецЕсли;
	
КонецПроцедуры

Процедура SentToServiceProviderDate(TripСсылка) Экспорт 
	
	УстановитьПривилегированныйРежим(Истина);
	
	TripОбъект = TripСсылка.ПолучитьОбъект();
	TripОбъект.ОбменДанными.Загрузка = Истина;
	TripОбъект.SentToServiceProviderDate = ТекущаяДата();
	TripОбъект.Записать();
	
	УстановитьПривилегированныйРежим(Ложь);

КонецПроцедуры

// Work Order
Функция ПечатьWorkOrder(МассивОбъектов, ОбъектыПечати) Экспорт
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "WorkOrder";
	
	Макет = ПолучитьМакет("WorkOrder");
	
	ПервыйДокумент = Истина;
	КоличествоСтрокТЗ = МассивОбъектов.Количество();
	ПредыдущийТрип = ?(КоличествоСтрокТЗ = 0, Неопределено, МассивОбъектов[0]);
	НомерСтрокиНачало = Неопределено;
	ТекстОшибок = "";
	Для Каждого Trip из МассивОбъектов Цикл
		
		Если ТабличныйДокумент.ВысотаТаблицы > 0 Тогда
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		Если Не ПервыйДокумент И Trip <> ПредыдущийТрип Тогда
			УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, ПредыдущийТрип);
		КонецЕсли;
		
		Если ПервыйДокумент ИЛИ Trip <> ПредыдущийТрип Тогда
			НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
			Если ПервыйДокумент Тогда
				ПервыйДокумент = Ложь;
			КонецЕсли;
			Если Trip <> ПредыдущийТрип Тогда
				ПредыдущийТрип = Trip;
			КонецЕсли;
		КонецЕсли;		
		
		ОбластьМакетаHeader = Макет.ПолучитьОбласть("Шапка");
		ОбластьМакетаHeader.Параметры.Номер = Trip.Номер;
		ОбластьМакетаHeader.Параметры.Дата = Формат(Trip.Дата, "ДФ=dd.MM.yyyy");
		ОбластьМакетаHeader.Параметры.Специалист = Trip.Specialist;
		ОбластьМакетаHeader.Параметры.Телефон = "RCA-DL-HUB-Planners@slb.com";
		ОбластьМакетаHeader.Параметры.Наименование = Trip.ServiceProvider;
		ОбластьМакетаHeader.Параметры.Equipment = Trip.Equipment;
		ОбластьМакетаHeader.Параметры.MOT = Trip.MOT;
		// { RGS AArsentev 09.01.2018 S-I-0004344
		Equipment = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip, "Equipment");
		Driver = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip, "Driver");
		ContactPhoneNumberOfTheDriver = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip, "ContactPhoneNumberOfTheDriver");
		Transport = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip, "Transport");
		ОбластьМакетаHeader.Параметры.Driver = "" + Driver + ?(ЗначениеЗаполнено(Driver) И ЗначениеЗаполнено(ContactPhoneNumberOfTheDriver), ", " + ContactPhoneNumberOfTheDriver, ContactPhoneNumberOfTheDriver);
		Если Equipment <> Перечисления.TypesOfTransport.CallOut Тогда
			Если ЗначениеЗаполнено(Transport) Тогда
				Марка = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Transport, "Brand");
				ГосНомер = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Transport, "Код");
				ОбластьМакетаHeader.Параметры.Truck = "" + СокрЛП(Марка) + " " + СокрЛП(ГосНомер);
			КонецЕсли;
		КонецЕсли;
		// } RGS AArsentev 09.01.2018 S-I-0004344
		
		Запрос = новый запрос;
		Запрос.текст = 
		"ВЫБРАТЬ
		|	BarcodeOfTrip.Barcode КАК ШтрихКод
		|ИЗ
		|	РегистрСведений.BarcodeOfTrip КАК BarcodeOfTrip
		|ГДЕ
		|	BarcodeOfTrip.Trip = &Trip";
		
		Запрос.УстановитьПараметр("Trip", Trip);
		
		Результат = Запрос.Выполнить().Выгрузить();
		Если Результат.Количество()>0 тогда 	
			ОбластьШтрихКода = ОбластьМакетаHeader.Рисунки.ШтрихКод;
			Если ЗначениеЗаполнено(Результат[0].ШтрихКод) Тогда
				ПараметрыШтрихкода = Новый Структура;
				ПараметрыШтрихкода.Вставить("Ширина",			ОбластьШтрихКода.Ширина);
				ПараметрыШтрихкода.Вставить("Высота",			40);
				ПараметрыШтрихкода.Вставить("Штрихкод",			Результат[0].ШтрихКод);
				ПараметрыШтрихкода.Вставить("ТипКода",			4); // Code 128
				ПараметрыШтрихкода.Вставить("ОтображатьТекст",	Истина);
				ПараметрыШтрихкода.Вставить("РазмерШрифта",		12);
				Попытка
					ОбластьШтрихКода.Картинка = LocalDistributionForNonLawsonСервер.ПолучитьКартинкуШтрихкода(ПараметрыШтрихкода);
				Исключение
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось сформировать ШтрихКод");
				КонецПопытки
			КонецЕсли;
		иначе
			ОбластьМакетаHeader.Рисунки.Удалить(ОбластьМакетаHeader.Рисунки.ШтрихКод);
		КонецЕсли;
		
		// Штрих-код пароля
		ПользовательWebDB = LocalDistributionForNonLawsonСервер.НайтиПользователяWebDBПоПоставке(Trip);
		Если ЗначениеЗаполнено(ПользовательWebDB) И Не ПустаяСтрока(ПользовательWebDB.Пароль) Тогда
			
			ОбластьШтрихКода = ОбластьМакетаHeader.Рисунки.ШтрихКодПароля;
			
			ПараметрыШтрихкода = Новый Структура;
			ПараметрыШтрихкода.Вставить("Ширина",			ОбластьШтрихКода.Ширина);
			ПараметрыШтрихкода.Вставить("Высота",			40);
			ПараметрыШтрихкода.Вставить("Штрихкод",			ПользовательWebDB.Пароль);
			ПараметрыШтрихкода.Вставить("ТипКода",			4); // Code 128
			ПараметрыШтрихкода.Вставить("ОтображатьТекст",	Истина);
			ПараметрыШтрихкода.Вставить("РазмерШрифта",		12);
			Попытка
				ОбластьШтрихКода.Картинка = LocalDistributionForNonLawsonСервер.ПолучитьКартинкуШтрихкода(ПараметрыШтрихкода);
			Исключение
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось сформировать ШтрихКод");
			КонецПопытки
		Иначе
			ОбластьМакетаHeader.Рисунки.Удалить(ОбластьМакетаHeader.Рисунки.ШтрихКодПароля);
		КонецЕсли;
		
		ТабличныйДокумент.Вывести(ОбластьМакетаHeader);
		
		ОбластьМакетаПустая = Макет.ПолучитьОбласть("ПустаяСтрока");
		ТабличныйДокумент.Вывести(ОбластьМакетаПустая);
		
		Запрос = новый запрос;
		Запрос.Текст = "ВЫБРАТЬ
		               |	TripNonLawsonCompaniesParcels.Parcel КАК Parcel,
		               |	TripNonLawsonCompaniesParcels.NumOfParcels
		               |ПОМЕСТИТЬ Parcels
		               |ИЗ
		               |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		               |ГДЕ
		               |	TripNonLawsonCompaniesParcels.Ссылка = &Trip
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ
		               |	СтрокиИнвойса.TransportRequest КАК TransportRequest,
		               |	СтрокиИнвойса.КодПоИнвойсу КАК PartNo,
		               |	ВЫРАЗИТЬ(СтрокиИнвойса.НаименованиеТовара КАК СТРОКА(500)) КАК DescriptionEng,
		               |	СтрокиИнвойса.DescriptionRus КАК DescriptionRus,
		               |	ParcelsДетали.Ссылка.LengthCM КАК LengthCM,
		               |	ParcelsДетали.Ссылка.WidthCM КАК WidthCM,
		               |	ParcelsДетали.Ссылка.HeightCM КАК HeightCM,
		               |	ParcelsДетали.Qty КАК Qty,
		               |	ParcelsДетали.GrossWeightKG КАК GrossWeightKG,
		               |	СтрокиИнвойса.КодПоИнвойсу КАК КодПоИнвойсу,
		               |	СтрокиИнвойса.НаименованиеТовара КАК НаименованиеТовара,
		               |	СтрокиИнвойса.СерийныйНомер КАК СерийныйНомер,
		               |	СтрокиИнвойса.TransportRequest.DeliverTo КАК Куда,
		               |	СтрокиИнвойса.TransportRequest.PickUpWarehouse КАК Откуда,
		               |	ParcelsДетали.Ссылка.Код КАК Код,
		               |	ParcelsДетали.Ссылка.HazardClass КАК HazardClass,
		               |	ParcelsДетали.Ссылка.SpecialHandling КАК SpecialHandling,
		               |	Parcels.NumOfParcels,
		               |	ВЫБОР
		               |		КОГДА ParcelsДетали.Qty = 0
		               |			ТОГДА 0
		               |		ИНАЧЕ ParcelsДетали.GrossWeightKG / ParcelsДетали.Qty * Parcels.NumOfParcels
		               |	КОНЕЦ КАК ВесПоставки
		               |ИЗ
		               |	Parcels КАК Parcels
		               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
		               |			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
		               |			ПО ParcelsДетали.СтрокаИнвойса = СтрокиИнвойса.Ссылка
		               |		ПО Parcels.Parcel = ParcelsДетали.Ссылка
		               |ГДЕ
		               |	НЕ СтрокиИнвойса.ПометкаУдаления";
		
		Запрос.УстановитьПараметр("Trip",Trip);
		РезультатСтопы = Запрос.Выполнить().Выгрузить();
		
		НомерСтопа = 1;
		Для каждого Стоп из  Trip.Stops цикл
			
			ВыводимыеОбласти = Новый Массив();
			
			ОбластьМакетаСтопы = Макет.ПолучитьОбласть("Стопы");
			ОбластьМакетаСтопы.Параметры.Номер = НомерСтопа;
			ОбластьМакетаСтопы.Параметры.Склад = Стоп.Location; 
			ОбластьМакетаСтопы.Параметры.СкладАдрес = Стоп.Location.Address1 + ", " + Стоп.Location.Address2 + ", " + Стоп.Location.Address3;
			ОбластьМакетаСтопы.Параметры.Контакт = Стоп.Location.ContactName;
			ОбластьМакетаСтопы.Параметры.КонтактТелефон = Стоп.Location.ContactPhone;
			ОбластьМакетаСтопы.Параметры.ДатаОтбытия = Лев(строка(Формат(Стоп.PlannedDepartureLocalTime, "ДЛФ=DT")),16);
			ОбластьМакетаСтопы.Параметры.ДатаПрибытия = Лев(Строка(Формат(Стоп.ActualDepartureLocalTime, "ДЛФ=DT")),16);	
			
			ВыводимыеОбласти.Добавить(ОбластьМакетаСтопы);
			//ТабличныйДокумент.Вывести(ОбластьМакетаСтопы);
			
			Если Стоп.Type <> Перечисления.StopsTypes.Transit тогда
				
				Отбор = новый структура;
				
				Если Стоп.Type = Перечисления.StopsTypes.Source тогда 				
					Отбор.Вставить("Откуда",Стоп.Location);								
				Иначе		                                                            
					Отбор.Вставить("Куда",Стоп.Location);							
				КонецЕсли;
				
				Парсели = РезультатСтопы.Скопировать(Отбор);
				
			Иначе
				
				ОтборТранзитКуда = новый структура;
				ОтборТранзитОткуда = новый структура;
				ОтборТранзитКуда.Вставить("Куда",Стоп.Location);
				ОтборТранзитОткуда.Вставить("Откуда",Стоп.Location);
				ПарселиТранзитКуда = РезультатСтопы.Скопировать(ОтборТранзитКуда);
				ПарселиТранзитОткуда = РезультатСтопы.Скопировать(ОтборТранзитОткуда);
				
				Парсели = ЗагрузитьВТаблицуЗначений(ПарселиТранзитКуда, ПарселиТранзитОткуда);				
				
			КонецЕсли;
			
			Если Парсели.количество() > 0 тогда
				ВесОткуда = 0;
				КоличествоОткуда = 0;
				ВесКуда = 0;
				КоличествоКуда = 0;
				Для каждого СтрокаПарсель Из Парсели цикл					
					ОбластьМакетаПарсель = Макет.ПолучитьОбласть("Парсель");	
					ОбластьМакетаПарсель.Параметры.ПарсельОписание = ?(СтрокаПарсель.Откуда = Стоп.Location, "Pick up ", "Drop off ") + "Parcel No.: " + СокрЛП(СтрокаПарсель.Код) +  " EACH " + СтрокаПарсель.GrossWeightKG + "KG, " + СтрокаПарсель.LengthCM + "х" + СтрокаПарсель.WidthCM + "х" + СтрокаПарсель.HeightCM + " СМ";
					ОбластьМакетаПарсель.Параметры.Опасность = СтрокаПарсель.HazardClass;
					ОбластьМакетаПарсель.Параметры.НомерПартии = СтрокаПарсель.КодПоИнвойсу;
					ОбластьМакетаПарсель.Параметры.Наименование = СтрокаПарсель.DescriptionRus + " / " + СтрокаПарсель.НаименованиеТовара; 
					ОбластьМакетаПарсель.Параметры.SpecialHandling = ?(ЗначениеЗаполнено(СтрокаПарсель.SpecialHandling),СтрокаПарсель.SpecialHandling, "Special handling: NA");            
					ОбластьМакетаПарсель.Параметры.Вес = СтрокаПарсель.ВесПоставки;
					ОбластьМакетаПарсель.Параметры.Количество = СтрокаПарсель.NumOfParcels;
					ОбластьМакетаПарсель.Параметры.СерийныйНомер = СтрокаПарсель.СерийныйНомер;
					Если СтрокаПарсель.Откуда = Стоп.Location тогда						
						ВесОткуда = ВесОткуда + СтрокаПарсель.ВесПоставки;                                          
						КоличествоОткуда = КоличествоОткуда + СтрокаПарсель.NumOfParcels; 
					Иначе
						ВесКуда = ВесКуда + СтрокаПарсель.ВесПоставки;                                          
						КоличествоКуда = КоличествоКуда + СтрокаПарсель.NumOfParcels;
					КонецЕсли;
					ВыводимыеОбласти.Добавить(ОбластьМакетаПарсель);
					//ТабличныйДокумент.Вывести(ОбластьМакетаПарсель);                              
				КонецЦикла;
				Если ВесОткуда <> 0 тогда
					ОбластьМакетаИтого = Макет.ПолучитьОбласть("ИтогоПарсель");
					ОбластьМакетаИтого.Параметры.Итого = "Total pick up - " + КоличествоОткуда + " Shipping unit - " + ВесОткуда + " KG";
					ВыводимыеОбласти.Добавить(ОбластьМакетаИтого);
				КонецЕсли;
				
				Если ВесКуда <> 0 тогда
					ОбластьМакетаИтого = Макет.ПолучитьОбласть("ИтогоПарсель");
					ОбластьМакетаИтого.Параметры.Итого = "Total drop off - " + КоличествоКуда + " Shipping unit - " + ВесКуда + " KG";
					ВыводимыеОбласти.Добавить(ОбластьМакетаИтого);
				КонецЕсли;
				
				
				//ТабличныйДокумент.Вывести(ОбластьМакетаИтого);
			КонецЕсли;			
			
			Если не ОбщегоНазначения.ПроверитьВыводТабличногоДокумента(ТабличныйДокумент, ВыводимыеОбласти) и НомерСтопа <> 1 тогда
				ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
				Для каждого элемент из ВыводимыеОбласти цикл
					ТабличныйДокумент.Вывести(элемент);
				КонецЦикла;
			Иначе
				
				ОбластьМакетаПустая = Макет.ПолучитьОбласть("ПустаяСтрока");
				ТабличныйДокумент.Вывести(ОбластьМакетаПустая);
				
				Для каждого элемент из ВыводимыеОбласти цикл
					ТабличныйДокумент.Вывести(элемент);
				КонецЦикла;
				ОбластьМакетаПустая = Макет.ПолучитьОбласть("ПустаяСтрока");
				ТабличныйДокумент.Вывести(ОбластьМакетаПустая);
			КонецЕсли;
			НомерСтопа = НомерСтопа + 1;
		КонецЦикла;
		
		ОбластьМакетаПустая = Макет.ПолучитьОбласть("ПустаяСтрока");
		ТабличныйДокумент.Вывести(ОбластьМакетаПустая);
		
		ОбластьМакетаИтог = Макет.ПолучитьОбласть("Итог");
		ОбластьМакетаИтог.Параметры.ВалютаСумма =  СокрЛП(Trip.TotalCostsSum) + " " + СокрЛП(Trip.Currency.НаименованиеEng);
		ТабличныйДокумент.Вывести(ОбластьМакетаИтог);
		
		ОбластьМакетаПустая = Макет.ПолучитьОбласть("ПустаяСтрока");
		ТабличныйДокумент.Вывести(ОбластьМакетаПустая);
		
		ОбластьМакетаПодвал = Макет.ПолучитьОбласть("Подвал");
		ТабличныйДокумент.Вывести(ОбластьМакетаПодвал);
		
		Если КоличествоСтрокТЗ > 0 Тогда
			УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, Trip);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ТекстОшибок) Тогда
			Сообщить(СокрЛП(Trip)+ ": 
			|" + СокрЛП(ТекстОшибок));
		КонецЕсли;
		
	КонецЦикла;  // Trip
	
	Возврат ТабличныйДокумент;
	
КонецФункции

Функция ЗагрузитьВТаблицуЗначений(ТаблицаИсточник, ТаблицаПриемник)
	
	//Сформируем массив совпадающих колонок.
	МассивСовпадающихКолонок = Новый Массив();
	Для каждого Колонка Из ТаблицаПриемник.Колонки Цикл
		
		Если ТаблицаИсточник.Колонки.Найти(Колонка.Имя) <> Неопределено Тогда
			
			МассивСовпадающихКолонок.Добавить(Колонка.Имя);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Для каждого СтрокаТаблицыИсточника Из ТаблицаИсточник Цикл
		
		СтрокаТаблицыПриемника = ТаблицаПриемник.Добавить();
		
		// Заполним значения в совпадающих колонках.
		Для каждого ЭлементМассива Из МассивСовпадающихКолонок Цикл
			
			СтрокаТаблицыПриемника[ЭлементМассива] = СтрокаТаблицыИсточника[ЭлементМассива];
			
		КонецЦикла;
		
	КонецЦикла;
	
	возврат ТаблицаПриемник
	
КонецФункции // ЗагрузитьВТаблицуЗначений()

// ТранспортнаяНакладная

Функция ПечатьТранспортнаяНакладная(МассивОбъектов, ОбъектыПечати) Экспорт
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "ТранспортнаяНакладная";
	
	Макет = ПолучитьМакет("ТранспортнаяНакладная");
	
	Для Каждого СсылкаНаДок из МассивОбъектов Цикл 
	ЭтоTR = Ложь;
	ЭтоTRIP = Ложь;
	//ЭтоTR_но_есть_TRIP = Ложь;
	// { RGS AArsentev 09.01.2018 S-I-0004344
	ЕстьTRIP = Ложь;
	// } RGS AArsentev 09.01.2018 S-I-0004344
	Запрос = Новый Запрос;
	Если ТипЗнч(СсылкаНаДок) = Тип("ДокументСсылка.TripNonLawsonCompanies") Тогда
	ЭтоTRIP = Истина;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	TripNonLawsonCompaniesParcels.Parcel,
		|	TripNonLawsonCompaniesParcels.NumOfParcels,
		|	TripNonLawsonCompaniesParcels.Ссылка.Дата КАК TripDate,
		|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider.NameRus КАК ServiceProviderNameRus,
		|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider.Address КАК ServiceProviderAddress,
		|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider.Ссылка КАК ServiceProvider,
		|	TripNonLawsonCompaniesParcels.Ссылка.EquipmentNo,
		|	TripNonLawsonCompaniesParcels.Ссылка.Transport,
		|	TripNonLawsonCompaniesParcels.Ссылка.TypeOfTransport,
		|	TripNonLawsonCompaniesParcels.Ссылка.Driver,
		|	TripNonLawsonCompaniesParcels.Ссылка.ContactPhoneNumberOfTheDriver,
		|	TripNonLawsonCompaniesParcels.Ссылка.Transport.Tonnage,
		|	TripNonLawsonCompaniesParcels.Ссылка.Equipment,
		|	TripNonLawsonCompaniesParcels.Ссылка.Transport.Brand
		|ПОМЕСТИТЬ Parcels
		|ИЗ
		|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		|ГДЕ
		|	TripNonLawsonCompaniesParcels.Ссылка = &Trip
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Parcels.Parcel.TransportRequest.Company.NameRus КАК CompanyNameRus,
		|	Parcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
		|	ВЫРАЗИТЬ(Parcels.Parcel.TransportRequest.LegalEntity.SoldToAddressRus КАК СТРОКА(500)) КАК LegalEntityAddressRus,
		|	Parcels.Parcel.TransportRequest.LegalEntity.NameRus КАК LegalEntityNameRus,
		|	Parcels.Parcel.TransportRequest.DeliverTo.AddressRus КАК DeliverToAddressRus,
		|	Parcels.Parcel.TransportRequest.DeliverToContact КАК DeliverToContact,
		|	Parcels.Parcel.TransportRequest.DeliverToPhone КАК DeliverToPhone,
		|	Parcels.Parcel.TransportRequest.DeliverTo.City КАК DeliverToCity,
		|	Parcels.Parcel.TransportRequest.DeliverTo.RCACountry.Наименование КАК DeliverToRCACountryName,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.City КАК PickUpCity,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.RCACountry.Наименование КАК PickUpRCACountryName,
		|	Parcels.TripDate,
		|	Parcels.ServiceProviderNameRus,
		|	Parcels.ServiceProviderAddress,
		|	Parcels.ServiceProvider,
		|	СУММА(Parcels.NumOfParcels) КАК NumOfParcels,
		|	СУММА(Parcels.Parcel.GrossWeightKG / Parcels.Parcel.NumOfParcels * Parcels.NumOfParcels) КАК ParcelsGrossWeightKG,
		|	СУММА(Parcels.Parcel.CubicMeters / Parcels.Parcel.NumOfParcels * Parcels.NumOfParcels) КАК ParcelsCubicMeters,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse КАК PickUpWarehouse,
		|	Parcels.Parcel.TransportRequest.DeliverTo КАК DeliverTo,
		|	Parcels.Parcel.TransportRequest.DeliverToAddress КАК DeliverToAddress,
		|	Parcels.Parcel.TransportRequest.ConsignTo КАК ConsignTo,
		|	Parcels.Parcel.TransportRequest.ConsignTo.NameRus КАК ConsignToNameRus,
		|	Parcels.Parcel.TransportRequest.PickUpFromContact КАК PickUpFromContact,
		|	Parcels.Parcel.TransportRequest.PickUpFromPhone КАК PickUpFromPhone,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.AddressRus КАК PickUpAddress,
		|	Parcels.EquipmentNo,
		|	Parcels.Transport,
		|	Parcels.Parcel.TransportRequest.CustomUnionTransaction КАК CustomUnionTransaction,
		|	Parcels.Parcel.TransportRequest.PayingEntity КАК PayingEntity,
		|	Parcels.Parcel.TransportRequest.Shipper КАК Shipper,
		|	Parcels.Parcel.TransportRequest КАК TransportRequest,
		|	Parcels.Parcel.TransportRequest.Дата КАК TransportRequestДата,
		|	Parcels.TypeOfTransport,
		|	Parcels.Parcel.TransportRequest,
		|	Parcels.Driver,
		|	Parcels.ContactPhoneNumberOfTheDriver,
		|	Parcels.Equipment,
		|	Parcels.TransportTonnage,
		|	Parcels.TransportBrand
		|ИЗ
		|	Parcels КАК Parcels
		|
		|СГРУППИРОВАТЬ ПО
		|	Parcels.TripDate,
		|	Parcels.ServiceProviderNameRus,
		|	Parcels.ServiceProviderAddress,
		|	Parcels.ServiceProvider,
		|	Parcels.Parcel.TransportRequest.Company.NameRus,
		|	Parcels.Parcel.TransportRequest.LegalEntity,
		|	Parcels.Parcel.TransportRequest.DeliverToContact,
		|	Parcels.Parcel.TransportRequest.DeliverToPhone,
		|	Parcels.Parcel.TransportRequest.DeliverTo.City,
		|	Parcels.Parcel.TransportRequest.DeliverTo.RCACountry.Наименование,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.City,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.RCACountry.Наименование,
		|	Parcels.Parcel.TransportRequest.LegalEntity.NameRus,
		|	ВЫРАЗИТЬ(Parcels.Parcel.TransportRequest.LegalEntity.SoldToAddressRus КАК СТРОКА(500)),
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse,
		|	Parcels.Parcel.TransportRequest.DeliverTo,
		|	Parcels.Parcel.TransportRequest.DeliverTo.AddressRus,
		|	Parcels.Parcel.TransportRequest.DeliverToAddress,
		|	Parcels.Parcel.TransportRequest.ConsignTo,
		|	Parcels.Parcel.TransportRequest.ConsignTo.NameRus,
		|	Parcels.Parcel.TransportRequest.PickUpFromContact,
		|	Parcels.Parcel.TransportRequest.PickUpFromPhone,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.AddressRus,
		|	Parcels.EquipmentNo,
		|	Parcels.Transport,
		|	Parcels.Parcel.TransportRequest.CustomUnionTransaction,
		|	Parcels.Parcel.TransportRequest.PayingEntity,
		|	Parcels.Parcel.TransportRequest.Shipper,
		|	Parcels.Parcel.TransportRequest,
		|	Parcels.Parcel.TransportRequest.Дата,
		|	Parcels.TypeOfTransport,
		|	Parcels.Driver,
		|	Parcels.ContactPhoneNumberOfTheDriver,
		|	Parcels.Equipment,
		|	Parcels.TransportTonnage,
		|	Parcels.Parcel.TransportRequest,
		|	Parcels.TransportBrand
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	МАКСИМУМ(ParcelsДетали.Ссылка.PackingType.CodeRus) КАК PackingTypeCodeRus,
		|	СтрокиИнвойса.TransportRequest.PickUpWarehouse КАК PickUpWarehouse,
		|	СтрокиИнвойса.TransportRequest.DeliverTo КАК DeliverTo,
		|	СтрокиИнвойса.TransportRequest.LegalEntity КАК LegalEntity,
		|	СтрокиИнвойса.TransportRequest.ConsignTo КАК ConsignTo,
		|	ParcelsДетали.Ссылка.LengthCM,
		|	ParcelsДетали.Ссылка.WidthCM,
		|	ParcelsДетали.Ссылка.HeightCM,
		|	ParcelsДетали.Ссылка.GrossWeightKG,
		|	ParcelsДетали.Ссылка.CubicMeters,
		|	ParcelsДетали.Ссылка.TransportRequest,
		|	ParcelsДетали.Ссылка КАК Детали,
		|	Parcels.NumOfParcels
		|ИЗ
		|	Справочник.Parcels.Детали КАК ParcelsДетали
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
		|		ПО ParcelsДетали.СтрокаИнвойса = СтрокиИнвойса.Ссылка
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Parcels КАК Parcels
		|		ПО ParcelsДетали.Ссылка = Parcels.Parcel
		|ГДЕ
		|	ParcelsДетали.Ссылка В
		|			(ВЫБРАТЬ
		|				Parcels.Parcel
		|			ИЗ
		|				Parcels КАК Parcels)
		|	И НЕ СтрокиИнвойса.ПометкаУдаления
		|
		|СГРУППИРОВАТЬ ПО
		|	СтрокиИнвойса.TransportRequest.DeliverTo,
		|	СтрокиИнвойса.TransportRequest.PickUpWarehouse,
		|	СтрокиИнвойса.TransportRequest.LegalEntity,
		|	СтрокиИнвойса.TransportRequest.ConsignTo,
		|	ParcelsДетали.Ссылка.LengthCM,
		|	ParcelsДетали.Ссылка.WidthCM,
		|	ParcelsДетали.Ссылка.HeightCM,
		|	ParcelsДетали.Ссылка.GrossWeightKG,
		|	ParcelsДетали.Ссылка.CubicMeters,
		|	ParcelsДетали.Ссылка.TransportRequest,
		|	ParcelsДетали.Ссылка,
		|	Parcels.NumOfParcels
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	TripNonLawsonCompaniesПрисоединенныеФайлы.Наименование КАК Attachment
		|ИЗ
		|	Справочник.TripNonLawsonCompaniesПрисоединенныеФайлы КАК TripNonLawsonCompaniesПрисоединенныеФайлы
		|ГДЕ
		|	НЕ TripNonLawsonCompaniesПрисоединенныеФайлы.ПометкаУдаления
		|	И TripNonLawsonCompaniesПрисоединенныеФайлы.ВладелецФайла = &Trip
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	BarcodeOfTrip.Barcode КАК ШтрихКод
		|ИЗ
		|	РегистрСведений.BarcodeOfTrip КАК BarcodeOfTrip
		|ГДЕ
		|	BarcodeOfTrip.Trip = &Trip";
		Запрос.УстановитьПараметр("Trip", СсылкаНаДок);
	Иначе
		ЭтоTR = Истина;
		Запрос.Текст = "ВЫБРАТЬ
		|	Parcels.Ссылка КАК Parcel
		|ПОМЕСТИТЬ Parcels
		|ИЗ
		|	Справочник.Parcels КАК Parcels
		|ГДЕ
		|	Parcels.TransportRequest = &TR
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Parcels.Parcel.TransportRequest.Company.NameRus КАК CompanyNameRus,
		|	Parcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
		|	ВЫРАЗИТЬ(Parcels.Parcel.TransportRequest.LegalEntity.SoldToAddressRus КАК СТРОКА(500)) КАК LegalEntityAddressRus,
		|	Parcels.Parcel.TransportRequest.LegalEntity.NameRus КАК LegalEntityNameRus,
		|	Parcels.Parcel.TransportRequest.DeliverTo.AddressRus КАК DeliverToAddressRus,
		|	Parcels.Parcel.TransportRequest.DeliverToContact КАК DeliverToContact,
		|	Parcels.Parcel.TransportRequest.DeliverToPhone КАК DeliverToPhone,
		|	Parcels.Parcel.TransportRequest.DeliverTo.City КАК DeliverToCity,
		|	Parcels.Parcel.TransportRequest.DeliverTo.RCACountry.Наименование КАК DeliverToRCACountryName,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.City КАК PickUpCity,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.RCACountry.Наименование КАК PickUpRCACountryName,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse КАК PickUpWarehouse,
		|	Parcels.Parcel.TransportRequest.DeliverTo КАК DeliverTo,
		|	Parcels.Parcel.TransportRequest.DeliverToAddress КАК DeliverToAddress,
		|	Parcels.Parcel.TransportRequest.ConsignTo КАК ConsignTo,
		|	Parcels.Parcel.TransportRequest.ConsignTo.NameRus КАК ConsignToNameRus,
		|	Parcels.Parcel.TransportRequest.PickUpFromContact КАК PickUpFromContact,
		|	Parcels.Parcel.TransportRequest.PickUpFromPhone КАК PickUpFromPhone,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.AddressRus КАК PickUpAddress,
		|	Parcels.Parcel.TransportRequest.CustomUnionTransaction КАК CustomUnionTransaction,
		|	Parcels.Parcel.TransportRequest.PayingEntity КАК PayingEntity,
		|	Parcels.Parcel.TransportRequest.Shipper КАК Shipper,
		|	Parcels.Parcel.TransportRequest КАК TransportRequest,
		|	Parcels.Parcel.TransportRequest.Дата КАК TransportRequestДата,
		|	СУММА(Parcels.Parcel.NumOfParcels) КАК NumOfParcels,
		|	СУММА(Parcels.Parcel.GrossWeightKG) КАК ParcelsGrossWeightKG
		|ИЗ
		|	Parcels КАК Parcels
		|
		|СГРУППИРОВАТЬ ПО
		|	Parcels.Parcel.TransportRequest.Company.NameRus,
		|	Parcels.Parcel.TransportRequest.LegalEntity,
		|	Parcels.Parcel.TransportRequest.DeliverToContact,
		|	Parcels.Parcel.TransportRequest.DeliverToPhone,
		|	Parcels.Parcel.TransportRequest.DeliverTo.City,
		|	Parcels.Parcel.TransportRequest.DeliverTo.RCACountry.Наименование,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.City,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.RCACountry.Наименование,
		|	Parcels.Parcel.TransportRequest.LegalEntity.NameRus,
		|	ВЫРАЗИТЬ(Parcels.Parcel.TransportRequest.LegalEntity.SoldToAddressRus КАК СТРОКА(500)),
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse,
		|	Parcels.Parcel.TransportRequest.DeliverTo,
		|	Parcels.Parcel.TransportRequest.DeliverTo.AddressRus,
		|	Parcels.Parcel.TransportRequest.DeliverToAddress,
		|	Parcels.Parcel.TransportRequest.ConsignTo,
		|	Parcels.Parcel.TransportRequest.ConsignTo.NameRus,
		|	Parcels.Parcel.TransportRequest.PickUpFromContact,
		|	Parcels.Parcel.TransportRequest.PickUpFromPhone,
		|	Parcels.Parcel.TransportRequest.PickUpWarehouse.AddressRus,
		|	Parcels.Parcel.TransportRequest.CustomUnionTransaction,
		|	Parcels.Parcel.TransportRequest.PayingEntity,
		|	Parcels.Parcel.TransportRequest.Shipper,
		|	Parcels.Parcel.TransportRequest,
		|	Parcels.Parcel.TransportRequest.Дата
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	МАКСИМУМ(ParcelsДетали.Ссылка.PackingType.CodeRus) КАК PackingTypeCodeRus,
		|	СтрокиИнвойса.TransportRequest.PickUpWarehouse КАК PickUpWarehouse,
		|	СтрокиИнвойса.TransportRequest.DeliverTo КАК DeliverTo,
		|	СтрокиИнвойса.TransportRequest.LegalEntity КАК LegalEntity,
		|	СтрокиИнвойса.TransportRequest.ConsignTo КАК ConsignTo,
		|	ParcelsДетали.Ссылка.LengthCM КАК LengthCM,
		|	ParcelsДетали.Ссылка.WidthCM КАК WidthCM,
		|	ParcelsДетали.Ссылка.HeightCM КАК HeightCM,
		|	ParcelsДетали.Ссылка.GrossWeightKG КАК GrossWeightKG,
		|	ParcelsДетали.Ссылка.CubicMeters КАК CubicMeters,
		|	ParcelsДетали.Ссылка.NumOfParcels КАК NumOfParcels,
		|	ParcelsДетали.Ссылка.TransportRequest КАК TransportRequest,
		|	ParcelsДетали.Ссылка КАК Детали
		|ИЗ
		|	Справочник.Parcels.Детали КАК ParcelsДетали
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
		|		ПО ParcelsДетали.СтрокаИнвойса = СтрокиИнвойса.Ссылка
		|ГДЕ
		|	ParcelsДетали.Ссылка В
		|			(ВЫБРАТЬ
		|				Parcels.Parcel
		|			ИЗ
		|				Parcels КАК Parcels)
		|	И НЕ СтрокиИнвойса.ПометкаУдаления
		|
		|СГРУППИРОВАТЬ ПО
		|	СтрокиИнвойса.TransportRequest.DeliverTo,
		|	СтрокиИнвойса.TransportRequest.PickUpWarehouse,
		|	СтрокиИнвойса.TransportRequest.LegalEntity,
		|	СтрокиИнвойса.TransportRequest.ConsignTo,
		|	ParcelsДетали.Ссылка.LengthCM,
		|	ParcelsДетали.Ссылка.WidthCM,
		|	ParcelsДетали.Ссылка.HeightCM,
		|	ParcelsДетали.Ссылка.GrossWeightKG,
		|	ParcelsДетали.Ссылка.CubicMeters,
		|	ParcelsДетали.Ссылка.NumOfParcels,
		|	ParcelsДетали.Ссылка.TransportRequest,
		|	ParcelsДетали.Ссылка";
		Запрос.УстановитьПараметр("TR", СсылкаНаДок);
		
		// { RGS AArsentev 09.01.2018 S-I-0004344
		ЗапросTrip = Новый Запрос;
		ЗапросTrip.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
		                   |	TripNonLawsonCompaniesParcels.Ссылка.Driver КАК Driver,
		                   |	TripNonLawsonCompaniesParcels.Ссылка.ContactPhoneNumberOfTheDriver КАК ContactPhoneNumberOfTheDriver,
		                   |	TripNonLawsonCompaniesParcels.Ссылка.Equipment КАК Equipment,
		                   |	TripNonLawsonCompaniesParcels.Ссылка.Transport.Brand КАК TransportBrand,
		                   |	TripNonLawsonCompaniesParcels.Ссылка.Transport.Tonnage КАК TransportTonnage,
		                   |	TripNonLawsonCompaniesParcels.Ссылка.TypeOfTransport,
		                   |	TripNonLawsonCompaniesParcels.Ссылка.Transport.Код КАК ГосНомер
		                   |ИЗ
		                   |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		                   |ГДЕ
		                   |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest = &TransportRequest
		                   |
		                   |СГРУППИРОВАТЬ ПО
		                   |	TripNonLawsonCompaniesParcels.Ссылка.Driver,
		                   |	TripNonLawsonCompaniesParcels.Ссылка.Equipment,
		                   |	TripNonLawsonCompaniesParcels.Ссылка.Transport.Brand,
		                   |	TripNonLawsonCompaniesParcels.Ссылка.ContactPhoneNumberOfTheDriver,
		                   |	TripNonLawsonCompaniesParcels.Ссылка.Transport.Tonnage,
		                   |	TripNonLawsonCompaniesParcels.Ссылка.TypeOfTransport,
		                   |	TripNonLawsonCompaniesParcels.Ссылка.Transport.Код";
		ЗапросTrip.УстановитьПараметр("TransportRequest", СсылкаНаДок);
		РезультатTrip = ЗапросTrip.Выполнить();
		Если НЕ РезультатTrip.Пустой() Тогда
			
			TR_Driver = "";
			TR_ИнфТранспорт = "";
			TR_ГосНомер = "";
			
			ЕстьTRIP = Истина;
			ВыборкаTrips = РезультатTrip.Выбрать();
			Пока ВыборкаTrips.Следующий() Цикл
				
				Если ЗначениеЗаполнено(TR_Driver) Тогда 
					TR_Driver = TR_Driver + "; "
				КонецЕсли;
				
				Если ЗначениеЗаполнено(TR_ГосНомер) Тогда
					TR_ГосНомер = TR_ГосНомер + ", ";
				КонецЕсли;
				
				TR_ГосНомер = TR_ГосНомер + ВыборкаTrips.ГосНомер;
				
				TR_Driver = TR_Driver + ВыборкаTrips.Driver;
				TR_Driver = "" + TR_Driver + ?(ЗначениеЗаполнено(ВыборкаTrips.Driver) И ЗначениеЗаполнено(ВыборкаTrips.ContactPhoneNumberOfTheDriver), ", " + ВыборкаTrips.ContactPhoneNumberOfTheDriver, ВыборкаTrips.ContactPhoneNumberOfTheDriver);
				
				Если ВыборкаTrips.TypeOfTransport <> Перечисления.TypesOfTransport.CallOut Тогда
					
					Если ЗначениеЗаполнено(TR_ИнфТранспорт) Тогда
						TR_ИнфТранспорт = TR_ИнфТранспорт + "; ";
					КонецЕсли;
					
					TR_ИнфТранспорт = ?(ЗначениеЗаполнено(TR_ИнфТранспорт), TR_ИнфТранспорт + СокрЛП(ВыборкаTrips.Equipment), СокрЛП(ВыборкаTrips.Equipment));
					TR_ИнфТранспорт = TR_ИнфТранспорт + ?(ЗначениеЗаполнено(TR_ИнфТранспорт) И ЗначениеЗаполнено(ВыборкаTrips.TransportBrand), ", " + СокрЛП(ВыборкаTrips.TransportBrand), СокрЛП(ВыборкаTrips.TransportBrand));
					TR_ИнфТранспорт = TR_ИнфТранспорт + ?(ЗначениеЗаполнено(TR_ИнфТранспорт) И ЗначениеЗаполнено(ВыборкаTrips.TransportTonnage), ", " + ВыборкаTrips.TransportTonnage / 1000 + " тонн", СокрЛП(ВыборкаTrips.TransportTonnage));
					
				КонецЕсли;
				
			КонецЦикла;
				
		КонецЕсли;
	// } RGS AArsentev 09.01.2018 S-I-0004344
		
	КонецЕсли;
	
	Результат = Запрос.ВыполнитьПакет();
	
	ТЗLE_WH = Результат[1].Выгрузить();
	ТЗItems = Результат[2].Выгрузить();
	Если ЭтоTRIP Тогда
		ТЗAttachments = Результат[3].Выгрузить();
		ВыборкаШтрихкод = Результат[4].Выбрать();
		ЕстьШтрихкод = ВыборкаШтрихкод.Следующий();
	КонецЕсли;
	НомерLE = 1;
	СтруктураОтбора = Новый Структура("LegalEntity,DeliverTo,PickUpWarehouse,ConsignTo,TransportRequest");
	
	Для Каждого СтрТЗLE_WH из ТЗLE_WH Цикл
		
		Если ТабличныйДокумент.ВысотаТаблицы > 0 Тогда
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
		
		/////////////////////////////////////////////////////////////////////
		// Header
		Лицевая = Макет.ПолучитьОбласть("ГоризонтальнаяЛицеваяСторона");
		
		// Штрих-код
		Если ЭтоTRIP Тогда
			Если ЕстьШтрихкод Тогда
				ОбластьШтрихКода = Лицевая.Рисунки.ШтрихКод;
				Если ЗначениеЗаполнено(ВыборкаШтрихкод.ШтрихКод) Тогда
					ПараметрыШтрихкода = Новый Структура;
					ПараметрыШтрихкода.Вставить("Ширина",			ОбластьШтрихКода.Ширина);
					ПараметрыШтрихкода.Вставить("Высота",			40);
					ПараметрыШтрихкода.Вставить("Штрихкод",			ВыборкаШтрихкод.ШтрихКод);
					ПараметрыШтрихкода.Вставить("ТипКода",			4); // Code 128
					ПараметрыШтрихкода.Вставить("ОтображатьТекст",	Истина);
					ПараметрыШтрихкода.Вставить("РазмерШрифта",		12);
					Попытка
						ОбластьШтрихКода.Картинка = LocalDistributionForNonLawsonСервер.ПолучитьКартинкуШтрихкода(ПараметрыШтрихкода);
					Исключение
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось сформировать ШтрихКод");
					КонецПопытки
				КонецЕсли;
			Иначе
				Лицевая.Рисунки.Удалить(Лицевая.Рисунки.ШтрихКод);
			КонецЕсли;
			
			// Штрих-код пароля
			ПользовательWebDB = LocalDistributionForNonLawsonСервер.НайтиПользователяWebDBПоПоставке(СсылкаНаДок);
			Если ЗначениеЗаполнено(ПользовательWebDB) И Не ПустаяСтрока(ПользовательWebDB.Пароль) Тогда
				
				ОбластьШтрихКода = Лицевая.Рисунки.ШтрихКодПароля;
				
				ПараметрыШтрихкода = Новый Структура;
				ПараметрыШтрихкода.Вставить("Ширина",			ОбластьШтрихКода.Ширина);
				ПараметрыШтрихкода.Вставить("Высота",			40);
				ПараметрыШтрихкода.Вставить("Штрихкод",			ПользовательWebDB.Пароль);
				ПараметрыШтрихкода.Вставить("ТипКода",			4); // Code 128
				ПараметрыШтрихкода.Вставить("ОтображатьТекст",	Истина);
				ПараметрыШтрихкода.Вставить("РазмерШрифта",		12);
				Попытка
					ОбластьШтрихКода.Картинка = LocalDistributionForNonLawsonСервер.ПолучитьКартинкуШтрихкода(ПараметрыШтрихкода);
				Исключение
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось сформировать ШтрихКод");
				КонецПопытки
			Иначе
				Лицевая.Рисунки.Удалить(Лицевая.Рисунки.ШтрихКодПароля);
			КонецЕсли;
		Иначе
			Лицевая.Рисунки.Удалить(Лицевая.Рисунки.ШтрихКод);
			Лицевая.Рисунки.Удалить(Лицевая.Рисунки.ШтрихКодПароля);
		КонецЕсли;
		
		//ПостфиксНомера = СокрЛ(НомерLE);
		//Пока СтрДлина(ПостфиксНомера) < 2 Цикл 
		//	ПостфиксНомера = "0" + СокрЛ(ПостфиксНомера);
		//КонецЦикла;
		
		//Лицевая.Параметры.Number = СокрЛП(Формат(СтрТЗLE_WH.TripDate, "ДФ=""ггММдд""")) + "-" + ПостфиксНомера;
		Если ЭтоTR Тогда
			Лицевая.Параметры.Number = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрТЗLE_WH.TransportRequest, "Номер");
			Лицевая.Параметры.Пункт0_1 = 1;
		Иначе
			ПостфиксНомера = СокрЛ(НомерLE);
			Пока СтрДлина(ПостфиксНомера) < 2 Цикл 
				ПостфиксНомера = "0" + СокрЛ(ПостфиксНомера);
			КонецЦикла;
			Лицевая.Параметры.Number = СтрЗаменить(СсылкаНаДок.Номер, "TRIP", "") + "-" + ПостфиксНомера;
		КонецЕсли;
		Лицевая.Параметры.Пункт0_2 = СтрТЗLE_WH.TransportRequestДата;
		Лицевая.Параметры.Пункт0_3 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрТЗLE_WH.TransportRequest, "Номер");
		
		Если НЕ СтрТЗLE_WH.CustomUnionTransaction Тогда
			Если СтрТЗLE_WH.PayingEntity = Перечисления.PayingEntities.S Тогда
				Лицевая.Параметры.Пункт1_2 = "" + СтрТЗLE_WH.LegalEntityNameRus + ", " + СтрТЗLE_WH.LegalEntityAddressRus;
				//Лицевая.Параметры.Пункт1_2 = СтрТЗLE_WH.PickUpFromContact + ", " + СтрТЗLE_WH.PickUpFromPhone;
			Иначе
				Лицевая.Параметры.Пункт2_2 = "" + СтрТЗLE_WH.LegalEntityNameRus + ", " + СтрТЗLE_WH.LegalEntityAddressRus;
				//Лицевая.Параметры.Пункт2_2 = СтрТЗLE_WH.DeliverToContact + ", " + СтрТЗLE_WH.DeliverToPhone;
			КонецЕсли;
		Иначе
			
			Лицевая.Параметры.Пункт1_2 = "" +  ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрТЗLE_WH.Shipper, "NameRus") + ", " + ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрТЗLE_WH.Shipper, "SoldToAddressRus");
			//Лицевая.Параметры.Пункт1_2 = СтрТЗLE_WH.PickUpFromContact + ", " + СтрТЗLE_WH.PickUpFromPhone;
			Лицевая.Параметры.Пункт2_2 = "" + ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрТЗLE_WH.ConsignTo, "NameRus") + ", " + ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрТЗLE_WH.ConsignTo, "SoldToAddressRus");
			//Лицевая.Параметры.Пункт2_2 = СтрТЗLE_WH.DeliverToContact + ", " + СтрТЗLE_WH.DeliverToPhone;
			
		КонецЕсли;
		// Item 
		ЗаполнитьЗначенияСвойств(СтруктураОтбора, СтрТЗLE_WH);     
		
		ТЗItemsLE = ТЗItems.Скопировать(СтруктураОтбора);
		
		ЗапросItems = новый Запрос;
		ЗапросItems.Текст = "ВЫБРАТЬ
		|	СтрокиИнвойса.DescriptionRus
		|ИЗ
		|	Справочник.Parcels.Детали КАК ParcelsДетали
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
		|		ПО ParcelsДетали.СтрокаИнвойса = СтрокиИнвойса.Ссылка
		|ГДЕ
		|	ParcelsДетали.Ссылка В(&Items)";
		ЗапросItems.УстановитьПараметр("Items", ТЗItemsLE.ВыгрузитьКолонку("Детали"));
		Результат = ЗапросItems.Выполнить().Выгрузить();
		Descriptions = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(
		РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Результат, "DescriptionRus"),", ");
		
		ГрузовыеМеста = ТЗItems.Скопировать(СтруктураОтбора);
		
		ГрузовыеМеста.Свернуть("LengthCM, WidthCM, HeightCM, CubicMeters", "NumOfParcels, GrossWeightKG");
		РазмерыУпаковок = "";
		NumOfParcels = 0;
		ParcelsGrossWeight = СтрТЗLE_WH.ParcelsGrossWeightKG;
		NumOfParcels = NumOfParcels + СтрТЗLE_WH.NumOfParcels;
		Для Каждого ГрузоМесто ИЗ ГрузовыеМеста Цикл
			
			РазмерыУпаковок = РазмерыУпаковок + ?(РазмерыУпаковок = "", "", "; ") +
			ГрузоМесто.NumOfParcels + " " + РГСофт.ФормаМножественногоЧисла("упаковка", "упаковки", "упаковок", ГрузоМесто.NumOfParcels) + ": " + нрег(СокрЛП(ГрузоМесто.GrossWeightKG)) + " кг, " + ГрузоМесто.LengthCM + "x" + ГрузоМесто.WidthCM + "x" + ГрузоМесто.HeightCM + " см, " + Формат(ГрузоМесто.CubicMeters, "ЧДЦ=2") + " м3";
			
			//ParcelsGrossWeight = ParcelsGrossWeight + ГрузоМесто.GrossWeightKG;
			//NumOfParcels = NumOfParcels + ГрузоМесто.NumOfParcels;
		КонецЦикла;
		
		Тары = ТЗItems.Скопировать(СтруктураОтбора);
		Тары.Свернуть("PackingTypeCodeRus", "NumOfParcels");
		ТипыУпаковок = "";
		Для Каждого Тара ИЗ Тары Цикл
			
			ТипыУпаковок = ТипыУпаковок + ?(ТипыУпаковок = "", "", "; ") +
			Тара.NumOfParcels + " " + РГСофт.ФормаМножественногоЧисла("упаковка", "упаковки", "упаковок", Тара.NumOfParcels) + ": тип "  + """" + нрег(СокрЛП(Тара.PackingTypeCodeRus))+ """";
			
		КонецЦикла;
		
		Лицевая.Параметры.Пункт3_1 = СокрЛП(Descriptions);
		
		//PackingTypesCodeRus = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(
		//РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТЗItemsLE, "PackingTypeCodeRus"),", ");
		
		Лицевая.Параметры.Пункт3_2 = ТипыУпаковок;
		
		Лицевая.Параметры.Пункт3_3 = РазмерыУпаковок;
		
		Если ЭтоTRIP Тогда
			Лицевая.Параметры.Пункт4_1 = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(
			РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТЗAttachments, "Attachment"),", ");
		КонецЕсли;
		
		Лицевая.Параметры.Пункт6_1 = СтрТЗLE_WH.PickUpAddress;
		
		Лицевая.Параметры.Пункт6_5 = "" + ParcelsGrossWeight + " кг";
		Лицевая.Параметры.Пункт6_51 = NumOfParcels;
		
		Лицевая.Параметры.Пункт7_1 = СтрТЗLE_WH.DeliverToAddress;
		ТабличныйДокумент.Вывести(Лицевая);
		
		Оборотная = Макет.ПолучитьОбласть("ГоризонтальнаяОборотнаяСторона");
		
		Если ЭтоTRIP Тогда
			Оборотная.Параметры.Пункт10_2 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрТЗLE_WH.ServiceProvider, "NameRus") + ?(ЗначениеЗаполнено(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрТЗLE_WH.ServiceProvider, "Address")),", " + ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрТЗLE_WH.ServiceProvider, "Address"), "");
			Если ЗначениеЗаполнено(ПользовательWebDB) Тогда
				Цифры = "1234567890";
				Если СтрНайти(Цифры, Лев(ПользовательWebDB.Наименование, 1)) = 0 Тогда
					Оборотная.Параметры.Пункт10_3 = ПользовательWebDB.Наименование;
				КонецЕсли;
			// { RGS AArsentev 09.01.2018 S-I-0004344
			Иначе
				Оборотная.Параметры.Пункт10_3 = "" + СтрТЗLE_WH.Driver + ?(ЗначениеЗаполнено(СтрТЗLE_WH.Driver) И ЗначениеЗаполнено(СтрТЗLE_WH.ContactPhoneNumberOfTheDriver), ", " + СтрТЗLE_WH.ContactPhoneNumberOfTheDriver, СтрТЗLE_WH.ContactPhoneNumberOfTheDriver);
			// } RGS AArsentev 09.01.2018 S-I-0004344
			КонецЕсли;
			Если СтрТЗLE_WH.TypeOfTransport <> Перечисления.TypesOfTransport.CallOut Тогда
				// { RGS AArsentev 09.01.2018 S-I-0004344
				//Оборотная.Параметры.Пункт11_1 = СтрТЗLE_WH.Transport;
				ИнфТранспорт = "";
				ИнфТранспорт = ИнфТранспорт + СокрЛП(СтрТЗLE_WH.Equipment);
				ИнфТранспорт = ИнфТранспорт + ?(ЗначениеЗаполнено(ИнфТранспорт) И ЗначениеЗаполнено(СтрТЗLE_WH.TransportBrand), ", " + СокрЛП(СтрТЗLE_WH.TransportBrand), СокрЛП(СтрТЗLE_WH.TransportBrand));
				ИнфТранспорт = ИнфТранспорт + ?(ЗначениеЗаполнено(ИнфТранспорт) И ЗначениеЗаполнено(СтрТЗLE_WH.TransportTonnage), ", " + СтрТЗLE_WH.TransportTonnage / 1000 + " тонн", СокрЛП(СтрТЗLE_WH.TransportTonnage));
				Оборотная.Параметры.Пункт11_1 = ИнфТранспорт;
				// } RGS AArsentev 09.01.2018 S-I-0004344
				Оборотная.Параметры.Пункт11_2 = СтрТЗLE_WH.EquipmentNo;
			КонецЕсли;
		// { RGS AArsentev 09.01.2018 S-I-0004344
		ИначеЕсли ЭтоTR И ЕстьTRIP Тогда
			Оборотная.Параметры.Пункт10_3 = TR_Driver;
			Оборотная.Параметры.Пункт11_1 = TR_ИнфТранспорт;
			Оборотная.Параметры.Пункт11_2 = TR_ГосНомер;
		КонецЕсли;
		// } RGS AArsentev 09.01.2018 S-I-0004344
		
		Оборотная.Параметры.Пункт14_1 = "Устно";
		
		Оборотная.Параметры.Пункт15_1 = "согласно условиям заключенного договора о";
		Оборотная.Параметры.Пункт15_2 = "транспортно-экспедиционной деятельности.";
		
		
		Оборотная.Параметры.Пункт16_1 = СтрТЗLE_WH.LegalEntityNameRus;
		
		ТабличныйДокумент.Вывести(Оборотная);
		
		НомерLE = НомерLE + 1;
	КонецЦикла;
		
	КонецЦикла;  
	
	Возврат ТабличныйДокумент;
	
КонецФункции


Функция ПолучитьPrimaryParcels(PrimaryTrip) Экспорт
	
	ЗапросSecondary = Новый запрос;
	ЗапросSecondary.Текст = "ВЫБРАТЬ
	|	TripNonLawsonCompaniesParcels.Parcel,
	|	TripNonLawsonCompaniesParcels.NumOfParcels
	|ИЗ
	|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	|ГДЕ
	|	TripNonLawsonCompaniesParcels.Ссылка = &Primary";
	ЗапросSecondary.УстановитьПараметр("Primary", PrimaryTrip);
	РезультатSecondary = ЗапросSecondary.Выполнить().Выгрузить();
	
	Возврат РезультатSecondary;
	
КонецФункции

Функция ПолучитьSecondaryTrips(Primary) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	TripNonLawsonCompanies.Ссылка
	|ИЗ
	|	Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|ГДЕ
	|	TripNonLawsonCompanies.Primary = &Primary";
	Запрос.УстановитьПараметр("Primary", Primary);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Возврат Выборка
	
КонецФункции


Функция ПечатьЗаявкаНаТранспортировкуПоРоссии(МассивОбъектов, ОбъектыПечати)
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "ЗаявкаНаТранспортировкуПоРоссии";
	Макет = ПолучитьМакет("ЗаявкаНаТранспортировкуПоРоссии");
	
	Для Каждого Trip из МассивОбъектов Цикл
		
		ЗапросTR = Новый Запрос;
		ЗапросTR.Текст = "ВЫБРАТЬ
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК Ссылка
		|ИЗ
		|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		|ГДЕ
		|	TripNonLawsonCompaniesParcels.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest";
		ЗапросTR.УстановитьПараметр("Ссылка", Trip);
		
		РезультатTR = ЗапросTR.Выполнить().Выбрать();
		Пока РезультатTR.Следующий() Цикл
			
			Запрос = Новый Запрос;
			Запрос.Текст = "ВЫБРАТЬ
			               |	TransportRequest.CustomUnionTransaction,
			               |	TransportRequest.Shipper,
			               |	TransportRequest.ConsignTo,
			               |	TransportRequest.RequestedLocalTime,
			               |	TransportRequest.ReadyToShipLocalTime,
			               |	TransportRequest.RequiredDeliveryLocalTime,
			               |	TransportRequest.Номер,
			               |	TransportRequest.PayingEntity,
			               |	TransportRequest.PickUpWarehouse,
			               |	TransportRequest.PickUpFromContact,
			               |	TransportRequest.PickUpFromPhone,
			               |	TransportRequest.PickUpFromEmail,
			               |	TransportRequest.DeliverTo,
			               |	TransportRequest.DeliverToContact,
			               |	TransportRequest.DeliverToPhone,
			               |	TransportRequest.DeliverToEmail,
			               |	TransportRequest.Comments,
			               |	TransportRequest.CostCenter,
			               |	TransportRequest.LegalEntity.NameRus,
			               |	ВЫРАЗИТЬ(TransportRequest.LegalEntity.SoldToAddressRus КАК СТРОКА(500)) КАК LegalEntityAddressRus,
			               |	TransportRequest.Activity,
			               |	TransportRequest.ActivityLawson,
			               |	TransportRequest.Requestor КАК Alias,
			               |	TransportRequest.Дата,
			               |	TransportRequest.Company,
			               |	TransportRequest.LegalEntity.CostCenter КАК LegalEntityCostCenter,
			               |	TransportRequest.AcceptedBySpecialistLocalTime,
			               |	TransportRequest.Specialist КАК Planner,
			               |	TransportRequest.LegalEntity,
			               |	TransportRequest.LoadingEquipment,
			               |	TransportRequest.LoadingSlinger,
			               |	TransportRequest.UnloadingEquipment,
			               |	TransportRequest.UnloadingSlinger
			               |ИЗ
			               |	Документ.TransportRequest КАК TransportRequest
			               |ГДЕ
			               |	TransportRequest.Ссылка = &TR";
			Запрос.УстановитьПараметр("TR", РезультатTR.Ссылка);
			Результат = Запрос.Выполнить();
			
			НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
			УстановитьПривилегированныйРежим(Истина);
			
			Выборка = Результат.Выбрать();
			Выборка.Следующий();
			ЕстьTRIP = Ложь;
			ЗапросTrip = Новый Запрос;
			ЗапросTrip.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
			                   |	TripNonLawsonCompaniesParcels.Ссылка КАК Trips,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.MOT.Наименование КАК MOT,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.EquipmentNo,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.Driver,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.ContactPhoneNumberOfTheDriver,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.Operator,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.CreationDate,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.TotalCostsSum,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.Currency,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider.NameRus КАК ServiceProvider
			                   |ИЗ
			                   |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
			                   |ГДЕ
			                   |	TripNonLawsonCompaniesParcels.Ссылка.Ссылка = &Trip";
			ЗапросTrip.УстановитьПараметр("Trip", Trip);
			РезультатTrip = ЗапросTrip.Выполнить();
			Если НЕ РезультатTrip.Пустой() Тогда
				
				ЕстьTRIP = Истина;
				ВыборкаTrip = РезультатTrip.Выгрузить();
				СпособДоставки = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ВыборкаTrip, "MOT"),", ");
				
				Перевозчик = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ВыборкаTrip, "ServiceProvider"),", ");
				НомерТС = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ВыборкаTrip, "EquipmentNo"),", ");
				Водитель = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ВыборкаTrip, "Driver"),", ");
				КонтактныйНомерВодителя = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ВыборкаTrip, "ContactPhoneNumberOfTheDriver"),", ");
				Coordinator = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ВыборкаTrip, "Operator"),", ");
				ДатаСозданияТрипа = ВыборкаTrip[0].CreationDate;
				
			КонецЕсли;
			
			Шапка = Макет.ПолучитьОбласть("Шапка");
			
			Шапка.Параметры.Параметр_1 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.LegalEntity, "NameRus");
			Шапка.Параметры.Параметр_2 = "" + Выборка.CostCenter + "/" + Выборка.Activity;
			
			Шапка.Параметры.Параметр_3 = Формат(Выборка.ReadyToShipLocalTime, "ДФ='dd.MM.yyyy ЧЧ:mm'");
			Шапка.Параметры.Параметр_4 = Формат(Выборка.RequiredDeliveryLocalTime, "ДФ='dd.MM.yyyy ЧЧ:mm'");
			Шапка.Параметры.Параметр_5 = "" + Выборка.Номер + "/" + ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip, "Номер");
			Шапка.Параметры.Параметр_6 = Выборка.CostCenter;
			Шапка.Параметры.LoadingEquipment = Выборка.LoadingEquipment;
			Шапка.Параметры.LoadingSlinger = Выборка.LoadingSlinger;
			Шапка.Параметры.UnloadingEquipment = Выборка.UnloadingEquipment;
			Шапка.Параметры.UnloadingSlinger = Выборка.UnloadingSlinger;
			
			
			CompanySettings = Документы.TransportRequest.ПолучитьСтруктуруCompanySettings(Выборка.Company, Выборка.дата);
			Если CompanySettings.UseCostCenterFromLegalEntityForNON_PO Тогда
				Шапка.Параметры.Параметр_6 = СокрЛП(Выборка.LegalEntityCostCenter);
			Иначе
				Шапка.Параметры.Параметр_6 = СокрЛП(Выборка.CostCenter);
			КонецЕсли;
			
			Если ЗначениеЗаполнено(Выборка.Activity) Тогда
				
				Шапка.Параметры.Параметр_7 = Выборка.Activity;
				
			Иначе
				
				Шапка.Параметры.Параметр_7 = Выборка.ActivityLawson;
				
			КонецЕсли;
			
			Если ЕстьTRIP Тогда
				Шапка.Параметры.Перевозчик = Перевозчик;
				Шапка.Параметры.НомерТС = НомерТС;
				Шапка.Параметры.Водитель = Водитель;
				Шапка.Параметры.КонтактныйНомерВодителя = КонтактныйНомерВодителя;
			КонецЕсли;
			
			Шапка.Параметры.Параметр_16 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.PickUpWarehouse, "NameRus");
			Шапка.Параметры.Параметр_17 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.PickUpWarehouse, "AddressRus");
			Шапка.Параметры.Параметр_24 = Выборка.PickUpFromContact;
			Шапка.Параметры.Параметр_25 = Выборка.PickUpFromPhone;
			Шапка.Параметры.Параметр_26 = Выборка.PickUpFromEmail;
			
			Шапка.Параметры.Параметр_20 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.DeliverTo, "NameRus");
			Шапка.Параметры.Параметр_21 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.DeliverTo, "AddressRus");
			Шапка.Параметры.Параметр_27 = Выборка.DeliverToContact;
			Шапка.Параметры.Параметр_28 = Выборка.DeliverToPhone;
			Шапка.Параметры.Параметр_29 = Выборка.DeliverToEmail;
			
			ТабличныйДокумент.Вывести(Шапка);
			
			ШапкаТаблицы = Макет.ПолучитьОбласть("ШапкаТаблицы");
			ТабличныйДокумент.Вывести(ШапкаТаблицы);
			
			ЗапросItems = Новый Запрос;
			ЗапросItems.Текст = "ВЫБРАТЬ
			                    |	ParcelsДетали.Ссылка КАК Ссылка,
			                    |	ParcelsДетали.Ссылка.LengthCM КАК LengthCM,
			                    |	ParcelsДетали.Ссылка.WidthCM КАК WidthCM,
			                    |	ParcelsДетали.Ссылка.HeightCM КАК HeightCM,
			                    |	ВЫРАЗИТЬ(ParcelsДетали.Ссылка.GrossWeightKG / ParcelsДетали.Ссылка.NumOfParcels * TripNonLawsonCompaniesParcels.NumOfParcels КАК ЧИСЛО(12, 3)) КАК GrossWeightKG,
			                    |	ParcelsДетали.Ссылка.HazardClass,
			                    |	TripNonLawsonCompaniesParcels.NumOfParcels КАК NumOfParcels
			                    |ИЗ
			                    |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
			                    |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
			                    |		ПО TripNonLawsonCompaniesParcels.Parcel = ParcelsДетали.Ссылка
			                    |ГДЕ
			                    |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest = &TR
			                    |	И TripNonLawsonCompaniesParcels.Ссылка = &Trip
			                    |
			                    |СГРУППИРОВАТЬ ПО
			                    |	ParcelsДетали.Ссылка,
			                    |	ParcelsДетали.Ссылка.LengthCM,
			                    |	ParcelsДетали.Ссылка.WidthCM,
			                    |	ParcelsДетали.Ссылка.HeightCM,
			                    |	ParcelsДетали.Ссылка.HazardClass,
			                    |	TripNonLawsonCompaniesParcels.NumOfParcels,
			                    |	ВЫРАЗИТЬ(ParcelsДетали.Ссылка.GrossWeightKG / ParcelsДетали.Ссылка.NumOfParcels * TripNonLawsonCompaniesParcels.NumOfParcels КАК ЧИСЛО(12, 3))
			                    |;
			                    |
			                    |////////////////////////////////////////////////////////////////////////////////
			                    |ВЫБРАТЬ
			                    |	ParcelsДетали.СтрокаИнвойса.DescriptionRus КАК DescriptionRus,
			                    |	ParcelsДетали.СтрокаИнвойса.СерийныйНомер КАК СерийныйНомер,
			                    |	ParcelsДетали.Ссылка,
			                    |	ParcelsДетали.СтрокаИнвойса.МеждународныйКодТНВЭД КАК HTC,
			                    |	ParcelsДетали.СтрокаИнвойса.СтранаПроисхождения КАК СтранаПроисхождения,
			                    |	ParcelsДетали.СтрокаИнвойса.Сумма КАК Сумма
			                    |ИЗ
			                    |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
			                    |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
			                    |		ПО TripNonLawsonCompaniesParcels.Parcel = ParcelsДетали.Ссылка
			                    |ГДЕ
			                    |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest = &TR
			                    |	И TripNonLawsonCompaniesParcels.Ссылка = &Trip";
			ЗапросItems.УстановитьПараметр("TR",РезультатTR.Ссылка);
			ЗапросItems.УстановитьПараметр("Trip", Trip);
			РезультатItems = ЗапросItems.ВыполнитьПакет();
			
			Parcels = РезультатItems[0].Выгрузить();
			Item = РезультатItems[1].Выгрузить();
			
			ОбщийВес = 0;
			ОбщееКоличество = 0;
			ОбщаяСумма = 0;
			МассивHTC = Новый ТаблицаЗначений;
			МассивHTC.Колонки.Добавить("HTC");
			МассивСтранПроисхожджения = Новый ТаблицаЗначений;
			МассивСтранПроисхожджения.Колонки.Добавить("СтранаПроисхождения");
			Если Parcels.Количество() <> 0 Тогда
				
				СтрокаТаблицы = Макет.ПолучитьОбласть("СтрокаТаблицы");
				н = 1;
				Для Каждого Строка ИЗ Parcels Цикл
					Отбор = Новый Структура;
					Отбор.Вставить("Ссылка", Строка.Ссылка);
					ItemsПоParcel = Item.Скопировать(Отбор);
					СтрокаТаблицы.Параметры.НомерСтроки = н;
					СтрокаТаблицы.Параметры.НаименованиеТовара = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ItemsПоParcel, "DescriptionRus"),", ");
					СтрокаТаблицы.Параметры.СерийныйНомер = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ItemsПоParcel, "СерийныйНомер"),", ");
					
					Для Каждого СтрокаItem Из ItemsПоParcel Цикл
						СтрокаМассивHTC = МассивHTC.Добавить();
						СтрокаМассивHTC.HTC = СтрокаItem.HTC;
						
						СтрокаМассивСтранПроисхожджения = МассивСтранПроисхожджения.Добавить();
						СтрокаМассивСтранПроисхожджения.СтранаПроисхождения = СтрокаItem.СтранаПроисхождения;
						
						ОбщаяСумма = ОбщаяСумма + СтрокаItem.Сумма;
					КонецЦикла;
					
					СтрокаТаблицы.Параметры.Длина = Строка.LengthCM;
					СтрокаТаблицы.Параметры.Ширина = Строка.WidthCM;
					СтрокаТаблицы.Параметры.Высота = Строка.HeightCM;
					СтрокаТаблицы.Параметры.HazardClass = Строка.HazardClass;
					СтрокаТаблицы.Параметры.ВесЗаЕдиницу = Формат(Строка.GrossWeightKG / Строка.NumOfParcels, "ЧДЦ=3");
					СтрокаТаблицы.Параметры.КолВоМест = Строка.NumOfParcels;
					
					ТабличныйДокумент.Вывести(СтрокаТаблицы);
					н = н + 1;
					ОбщийВес = ОбщийВес + Строка.GrossWeightKG;
					ОбщееКоличество = ОбщееКоличество + Строка.NumOfParcels;
				КонецЦикла;
				
			КонецЕсли;
			
			
			
			ПодвалТаблицы = Макет.ПолучитьОбласть("ПодвалТаблицы");
			Если ЕстьTRIP Тогда
				ПодвалТаблицы.Параметры.Параметр_31 = СпособДоставки;
				
				ТаблицаTrips = ЗапросTrip.Выполнить().Выгрузить();
				ТаблицаВалют = ТаблицаTrips.Скопировать();
				//ТаблицаTrips.Свернуть("Currency");
				Валюты = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаTrips, "Currency");
				Если Валюты.Количество() > 1 Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю("В трипах имеются суммы в разных валютах, таблица 'Оплата' не будет заполнена");
				Иначе
					СтоимостьДоставки = 0;
					ТаблицаTrips.Свернуть("Trips, TotalCostsSum");
					Для каждого СтрокаТрип Из ТаблицаTrips Цикл
						
						СтоимостьДоставки = СтоимостьДоставки + СтрокаТрип.TotalCostsSum;
						
					КонецЦикла;
					
					Если Валюты.Количество() > 0 Тогда
						ПодвалТаблицы.Параметры.Валюта = Валюты[0];
						ПодвалТаблицы.Параметры.СтоимостьПеревозки = СтоимостьДоставки;
						ПодвалТаблицы.Параметры.СуммаБезНДС = СтоимостьДоставки;
					Конецесли;
					
				КонецЕсли;
				
			КонецЕсли;
			
			
			ПодвалТаблицы.Параметры.HTC = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(МассивHTC, "HTC"),", ");
			ПодвалТаблицы.Параметры.Параметр_30 = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(МассивСтранПроисхожджения, "СтранаПроисхождения"),", ");
			ПодвалТаблицы.Параметры.CargoValue = ?(ЗначениеЗаполнено(ОбщаяСумма), ОбщаяСумма, "");
			
			// { RGS AArsentev 24.08.2017 S-I-0003412
			HazardClass = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Parcels, "HazardClass"),", ");
			ПодвалТаблицы.Параметры.Параметр_32 = Выборка.Comments;
			//ПодвалТаблицы.Параметры.Параметр_32 = "Hazard class - " + HazardClass + ?(ЗначениеЗаполнено(Выборка.Comments), ", " + Символы.ПС + Выборка.Comments,"");
			// } RGS AArsentev 24.08.2017 S-I-0003412
			ПодвалТаблицы.Параметры.ОбщийВес = ОбщийВес;
			ПодвалТаблицы.Параметры.ОбщееКоличество = ОбщееКоличество;
			
			
			ТабличныйДокумент.Вывести(ПодвалТаблицы);
			
			Подписи = Макет.ПолучитьОбласть("Подписи");
			Подписи.Параметры.Параметр_33 = Выборка.Alias;
			
			Подписи.Параметры.LogisticsPlanner = Выборка.Planner;
			Подписи.Параметры.ДатаОтправкиВРаботуЗаявкиЛогисту = Формат(Выборка.RequestedLocalTime, "ДФ=dd.MM.yyyy");
			Подписи.Параметры.ДатаПринятияЛогистомВРаботу = Формат(Выборка.AcceptedBySpecialistLocalTime, "ДФ=dd.MM.yyyy");
			
			Если ЕстьTRIP Тогда
				Подписи.Параметры.Coordinator = Coordinator;
				Подписи.Параметры.ДатаСозданияТрипа = Формат(Дата(ДатаСозданияТрипа), "ДФ=dd.MM.yyyy");
			КонецЕсли;
			
			ТабличныйДокумент.Вывести(Подписи);
			
			ТабличныйДокумент.АвтоМасштаб = Истина;
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			
		КонецЦикла;
		
		
	КонецЦикла;
	
	Возврат ТабличныйДокумент;
	
		
		
	
КонецФункции

// { RGS ASeryakov 02.03.18 S-I-0005597
&НаСервере
Функция ЭтоServiceProvidersDHL(Ссылка) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ServiceProviders.Ссылка КАК Ссылка
		|ПОМЕСТИТЬ ServiceProvidersBT
		|ИЗ
		|	Справочник.ServiceProviders КАК ServiceProviders
		|ГДЕ
		|	ServiceProviders.Код В (""RSGD052"", ""GLOD033-KZ1"")
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ServiceProvidersBT.Ссылка
		|ИЗ
		|	ServiceProvidersBT КАК ServiceProvidersBT
		|ГДЕ
		|	ServiceProvidersBT.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка",Ссылка);
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат НЕ РезультатЗапроса.Пустой();
	
КонецФункции // } RGS ASeryakov 02.03.18 S-I-0005597

// { RG Soft LGoncharova Установка UTM дат
Процедура УстановитьUTMДаты(ЭтотОбъект, Перезаписывать = Истина) Экспорт
	ПересчетДлительности = Ложь;
	
	Для Каждого ТекСтрока Из ЭтотОбъект.Stops Цикл
		Warehouse = ТекСтрока.Location;
		
		ПарыРеквизитов = Новый Соответствие;
		ПарыРеквизитов.Вставить("ActualArrivalUniversalTime"	, "ActualArrivalLocalTime");
		ПарыРеквизитов.Вставить("ActualDepartureUniversalTime"	, "ActualDepartureLocalTime");
		ПарыРеквизитов.Вставить("PlannedArrivalUniversalTime"	, "PlannedArrivalLocalTime");
		ПарыРеквизитов.Вставить("PlannedDepartureUniversalTime"	, "PlannedDepartureLocalTime");
		
		ПарыРеквизитовДоп = Новый Соответствие;
		ПарыРеквизитовДоп.Вставить("MaximumReadyToShipUniversalTime"		, "MaximumReadyToShipLocalTime");
		ПарыРеквизитовДоп.Вставить("MinimumRequiredDeliveryUniversalTime"	, "MinimumRequiredDeliveryLocalTime");
		
		Для Каждого Пара Из ПарыРеквизитов Цикл
			Если (НЕ ЗначениеЗаполнено(ТекСтрока[Пара.Ключ]) И ЗначениеЗаполнено(ТекСтрока[Пара.Значение]))
				Или Перезаписывать Тогда
				
				ТекСтрока[Пара.Ключ] = LocalDistributionForNonLawsonСервер.ПолучитьUniversalTime(ТекСтрока[Пара.Значение], Warehouse);
				ПересчетДлительности = Истина;				
				
			КонецЕсли;
		КонецЦикла;
		Для Каждого Пара Из ПарыРеквизитовДоп Цикл
			Если (НЕ ЗначениеЗаполнено(ТекСтрока[Пара.Ключ]) И ЗначениеЗаполнено(ТекСтрока[Пара.Значение]))
				Или Перезаписывать Тогда
				
				ТекСтрока[Пара.Ключ] = LocalDistributionForNonLawsonСервер.ПолучитьUniversalTime(ТекСтрока[Пара.Значение], Warehouse);
				
			КонецЕсли;
		КонецЦикла;		
	КонецЦикла;		
		
	Если Перезаписывать Или ПересчетДлительности Тогда
		// проверим наличие Source
		СтруктураОтбораSource = Новый Структура("Type", Перечисления.StopsTypes.Source);
		МассивСтрокSource = ЭтотОбъект.Stops.НайтиСтроки(СтруктураОтбораSource);

		// проверим наличие Destination
		СтруктураОтбораDestination = Новый Структура("Type", Перечисления.StopsTypes.Destination);
		МассивСтрокDestination = ЭтотОбъект.Stops.НайтиСтроки(СтруктураОтбораDestination);
		
		Если МассивСтрокDestination.Количество() = 1 
			И МассивСтрокSource.Количество() = 1 Тогда
			
			СтрSource 		= МассивСтрокSource[0];
			СтрDestination 	= МассивСтрокDestination[0];
			
			Если ЗначениеЗаполнено(СтрDestination.PlannedArrivalUniversalTime) 
				И ЗначениеЗаполнено(СтрSource.PlannedDepartureUniversalTime) Тогда 
				
				ЭтотОбъект.TotalPlannedDuration = СтрDestination.PlannedArrivalUniversalTime - СтрSource.PlannedDepartureUniversalTime;
			КонецЕсли;
			
			Если ЗначениеЗаполнено(СтрDestination.ActualArrivalUniversalTime) 
				И ЗначениеЗаполнено(СтрSource.ActualDepartureUniversalTime) Тогда 
				
				ЭтотОбъект.TotalActualDuration = СтрDestination.ActualArrivalUniversalTime - СтрSource.ActualDepartureUniversalTime;
			КонецЕсли;
			    		
		КонецЕсли;
	КонецЕсли;

КонецПРоцедуры
// } RG Soft LGoncharova Установка UTM дат