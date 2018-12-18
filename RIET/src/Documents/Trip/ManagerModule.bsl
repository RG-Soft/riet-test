
Функция ПолучитьНеобходимостьDomesticOBToTMS(Final, МассивParcel, DomesticOB, ServiceProvider)  Экспорт
	
	// возвращает признако того, нужно ли выгружать Domestic OB в TMS, используя Parent Company из Parcel lines и дату Final
	
	Если МассивParcel.Количество() = 0 Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если DomesticOB.Количество() = 0 Тогда
		Возврат Ложь;
	КонецЕсли;

	// не выгружаем для DHL
	Если РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(ServiceProvider, "Код") = "RSGD052" Тогда 
		Возврат Ложь;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивParcel", МассивParcel);
		
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ParcelsДетали.СтрокаИнвойса.SoldTo.StartOfExportToTMS КАК StartOfExportToTMS
	|ИЗ
	|	Справочник.Parcels.Детали КАК ParcelsДетали
	|ГДЕ
	|	ParcelsДетали.Ссылка В(&МассивParcel)
	|	И ParcelsДетали.СтрокаИнвойса.SoldTo.StartOfExportToTMS <> ДАТАВРЕМЯ(1, 1, 1)";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда 
		
		Если Не ЗначениеЗаполнено(Final)
			ИЛИ Final >= Выборка.StartOfExportToTMS Тогда 
			Возврат Истина;
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

Функция ПолучитьМассивServiceProviders(Draft, WarehouseFrom = Неопределено) Экспорт 
	       	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Location", WarehouseFrom);
	Запрос.УстановитьПараметр("Draft", Draft);
	Запрос.Текст = "ВЫБРАТЬ
		|	ServiceProviders.Ссылка КАК ServiceProvider
		|ИЗ
		|	Справочник.ServiceProviders КАК ServiceProviders
		|ГДЕ
		|	НЕ ServiceProviders.ПометкаУдаления
		|	И ServiceProviders.StartOfLeg7Reports <= &Draft";
	
	Если WarehouseFrom <> Неопределено Тогда 
		Запрос.Текст = Запрос.Текст + "
			|	И ServiceProviders.Location = &Location";
	КонецЕсли;
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("ServiceProvider");
	
КонецФункции

Функция ПолучитьМассивParcels(Trip) Экспорт
	
	МассивПарселей = Новый Массив;
	Если Не ЗначениеЗаполнено(Trip) Тогда
		Возврат МассивПарселей;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	TripParcels.Parcel
		|ИЗ
		|	Документ.Trip.Parcels КАК TripParcels
		|ГДЕ
		|	TripParcels.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Trip);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		МассивПарселей.Добавить(ВыборкаДетальныеЗаписи.Parcel);
	КонецЦикла;
	
	Возврат МассивПарселей;
	
КонецФункции

////////////////////////////////////////////////////////////////////
// ВЫГРУЗКА OB В TMS

Процедура PushTripToTMS(Trip, ТаблицаDomesticOB) Экспорт
	
	WSСсылка = ПолучитьWSСсылку();
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	
	МассивTransOrder = ПолучитьМассивTransOrder(ФабрикаXDTOTMS, Trip, ТаблицаDomesticOB);
	
	Если МассивTransOrder = Неопределено Тогда
		ВызватьИсключение "Failed to push Trip to TMS: failed to create TransOrder!";
	КонецЕсли;
		
	TransmissionAck = CallTMS(WSСсылка, ФабрикаXDTOTMS, МассивTransOrder);
	
	Если TransmissionAck.TransmissionAckStatus = "ERROR" Тогда
		ВызватьИсключение "Failed to push Trip to TMS:
			|Unfortunately we do not already know how to show error description :-(";	
	КонецЕсли;
			   		
КонецПроцедуры
 
Функция ПолучитьМассивTransOrder(ФабрикаXDTOTMS, Trip, ТаблицаDomesticOB) Экспорт
	
	// Получим данные все данные из базы
	СтруктураДанных = ПолучитьСтруктуруДанных(Trip);
	
	Если Не TMSСервер.СтруктураДанныхДляTMSПроверена(СтруктураДанных) Тогда
		ВызватьИсключение "Failed to push Trip to TMS!";
	КонецЕсли;
	
	МассивTransOrder = Новый Массив;
	
	СтруктураОтбора = Новый Структура("Gold,LegalEntity,AU,Activity,WarehouseTo");
		
	Для Каждого СтрокаDomesticOB из ТаблицаDomesticOB Цикл 
		
		СтруктураДанныхOB = Новый Структура("TripOB,Items,Parcels");
		
		СтруктураДанныхOB.TripOB = СтруктураДанных.TripOB;
		
		ЗаполнитьЗначенияСвойств(СтруктураОтбора, СтрокаDomesticOB);
		СтруктураДанныхOB.Items = СтруктураДанных.Items.Скопировать(СтруктураОтбора);
		СтруктураДанныхOB.Parcels = СтруктураДанных.Parcels.Скопировать(СтруктураОтбора);		
		
		// Сформируем узел TransOrderHeader
		TransOrderHeader = ПолучитьTransOrderHeader(ФабрикаXDTOTMS, СтруктураДанныхOB, СтрокаDomesticOB);
		
		// Сформируем узел ShipUnitDetail
		ShipUnitDetail = ПолучитьShipUnitDetail(ФабрикаXDTOTMS, СтруктураДанныхOB, СтрокаDomesticOB);
		
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
    
Функция ПолучитьСтруктуруДанных(Trip)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Trip", Trip);
	// { RGS AGorlenko 10.11.2015 18:36:57 - поддержка периодичночти AUs and Legal entities
	Запрос.УстановитьПараметр("Период", ?(ЗначениеЗаполнено(Trip.Final), Trip.Final, Trip.Draft));
	// } RGS AGorlenko 10.11.2015 18:36:58 - поддержка периодичночти AUs and Legal entities
			
	Запрос.Текст =
	// { RGS AGorlenko 04.09.2015 12:34:34 - оптимизация запроса и поддержка периодичночти AUs and Legal entities
		//"ВЫБРАТЬ РАЗЛИЧНЫЕ
		//|	TripDomesticOB.WarehouseTo КАК WarehouseTo,
		//|	TripDomesticOB.Gold КАК Gold,
		//|	TripDomesticOB.LegalEntity КАК LegalEntity,
		//|	TripDomesticOB.AU КАК AU,
		//|	TripDomesticOB.Activity КАК Activity
		//|ПОМЕСТИТЬ ВТ_ДанныеDomesticOB
		//|ИЗ
		//|	Документ.Trip.DomesticOB КАК TripDomesticOB
		//|ГДЕ
		//|	TripDomesticOB.Ссылка = &Trip
		//|
		//|ИНДЕКСИРОВАТЬ ПО
		//|	WarehouseTo,
		//|	Gold,
		//|	LegalEntity,
		//|	AU,
		//|	Activity
		//|;
		//|
		//|////////////////////////////////////////////////////////////////////////////////
		//|ВЫБРАТЬ
		//|	Trip.ETD,
		//|	Trip.WarehouseFrom.Код КАК WarehouseFromCode,
		//|	Trip.Comment
		//|ИЗ
		//|	Документ.Trip КАК Trip
		//|ГДЕ
		//|	Trip.Ссылка = &Trip
		//|;
		//|
		//|////////////////////////////////////////////////////////////////////////////////
		//|ВЫБРАТЬ РАЗЛИЧНЫЕ
		//|	TripParcels.Parcel.Ссылка КАК Parcel,
		//|	TripParcels.Parcel.Код КАК ParcelNo,
		//|	ВЫБОР
		//|		КОГДА TripParcels.Parcel.PackingType.TMSID = """"
		//|			ТОГДА ""EACH""
		//|		ИНАЧЕ TripParcels.Parcel.PackingType.TMSID
		//|	КОНЕЦ КАК PackingTypeTMSID,
		//|	TripParcels.Parcel.SerialNo КАК SerialNo,
		//|	ВЫБОР
		//|		КОГДА TripParcels.Parcel.LengthCMCorrected = 0
		//|			ТОГДА TripParcels.Parcel.LengthCM
		//|		ИНАЧЕ TripParcels.Parcel.LengthCMCorrected
		//|	КОНЕЦ КАК LengthCM,
		//|	ВЫБОР
		//|		КОГДА TripParcels.Parcel.WidthCMCorrected = 0
		//|			ТОГДА TripParcels.Parcel.WidthCM
		//|		ИНАЧЕ TripParcels.Parcel.WidthCMCorrected
		//|	КОНЕЦ КАК WidthCM,
		//|	ВЫБОР
		//|		КОГДА TripParcels.Parcel.HeightCMCorrected = 0
		//|			ТОГДА TripParcels.Parcel.HeightCM
		//|		ИНАЧЕ TripParcels.Parcel.HeightCMCorrected
		//|	КОНЕЦ КАК HeightCM,
		//|	ВЫБОР
		//|		КОГДА TripParcels.Parcel.CubicMetersCorrected = 0
		//|			ТОГДА TripParcels.Parcel.CubicMeters
		//|		ИНАЧЕ TripParcels.Parcel.CubicMetersCorrected
		//|	КОНЕЦ КАК CubicMeters,
		//|	ВЫБОР
		//|		КОГДА TripParcels.Parcel.GrossWeightKGCorrected = 0
		//|			ТОГДА TripParcels.Parcel.GrossWeightKG
		//|		ИНАЧЕ TripParcels.Parcel.GrossWeightKGCorrected
		//|	КОНЕЦ КАК GrossWeightKG,
		//|	TripParcels.Parcel.NumOfParcels КАК NumOfParcels,
		//|	TripFinalDestinations.ETA,
		//|	ВЫБОР
		//|		КОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
		//|			ТОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.LegalEntityForLeg7
		//|		ИНАЧЕ AUsAndLegalEntities.LegalEntity
		//|	КОНЕЦ КАК LegalEntity,
		//|	ЕСТЬNULL(ParcelsДетали.СтрокаИнвойса.Инвойс.Голд, ЛОЖЬ) КАК Gold,
		//|	ParcelsДетали.СтрокаИнвойса.КостЦентр КАК AU,
		//|	ParcelsДетали.СтрокаИнвойса.Активити КАК Activity,
		//|	TripFinalDestinations.WarehouseTo КАК WarehouseTo,
		//|	TripParcels.Parcel.HazardClass КАК HazardClass
		//|ИЗ
		//|	Документ.Trip.Parcels КАК TripParcels
		//|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
		//|		ПО TripParcels.Parcel.WarehouseTo = TripFinalDestinations.WarehouseTo
		//|			И TripParcels.Ссылка = TripFinalDestinations.Ссылка
		//|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
		//|		ПО TripParcels.Parcel = ParcelsДетали.Ссылка
		//|			И (ParcelsДетали.СтрокаИнвойса.SoldTo.StartOfExportToTMS <= TripParcels.Ссылка.Final)
		//|			И (ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining <> ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.ПустаяСсылка))
		//|			И (ParcelsДетали.СтрокаИнвойса.SoldTo.StartOfExportToTMS <> ДАТАВРЕМЯ(1, 1, 1))
		//|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.AUsAndLegalEntities КАК AUsAndLegalEntities
		//|		ПО (ParcelsДетали.СтрокаИнвойса.SoldTo = AUsAndLegalEntities.ParentCompany)
		//|			И (ParcelsДетали.СтрокаИнвойса.КостЦентр = AUsAndLegalEntities.AU)
		//|ГДЕ
		//|	TripParcels.Ссылка = &Trip
		//|	И TripFinalDestinations.Ссылка = &Trip
		//|	И (TripFinalDestinations.WarehouseTo, ЕСТЬNULL(ParcelsДетали.СтрокаИнвойса.Инвойс.Голд, ЛОЖЬ), ВЫБОР
		//|			КОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
		//|				ТОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.LegalEntityForLeg7
		//|			ИНАЧЕ AUsAndLegalEntities.LegalEntity
		//|		КОНЕЦ, ParcelsДетали.СтрокаИнвойса.КостЦентр, ParcelsДетали.СтрокаИнвойса.Активити) В
		//|			(ВЫБРАТЬ
		//|				ВТ_ДанныеDomesticOB.WarehouseTo,
		//|				ВТ_ДанныеDomesticOB.Gold,
		//|				ВТ_ДанныеDomesticOB.LegalEntity,
		//|				ВТ_ДанныеDomesticOB.AU,
		//|				ВТ_ДанныеDomesticOB.Activity
		//|			ИЗ
		//|				ВТ_ДанныеDomesticOB КАК ВТ_ДанныеDomesticOB)
		//|;
		//|
		//|////////////////////////////////////////////////////////////////////////////////
		//|ВЫБРАТЬ
		//|	ParcelsДетали.Ссылка КАК Parcel,
		//|	ParcelsДетали.НомерСтроки,
		//|	ParcelsДетали.СтрокаИнвойса.КодПоИнвойсу КАК PartNo,
		//|	ParcelsДетали.Qty,
		//|	ВЫБОР
		//|		КОГДА ParcelsДетали.QtyUOM.TMSIdForItemUOM = """"
		//|			ТОГДА ""EACH""
		//|		ИНАЧЕ ParcelsДетали.QtyUOM.TMSIdForItemUOM
		//|	КОНЕЦ КАК QtyUOMTMSIdForItemUOM,
		//|	ParcelsДетали.СерийныйНомер,
		//|	ParcelsДетали.СтрокаИнвойса.RAN КАК RAN,
		//|	ParcelsДетали.СтрокаИнвойса.СтранаПроисхождения.TMSID КАК CountryOfOrigin,
		//|	ParcelsДетали.СтрокаИнвойса.Currency.НаименованиеEng КАК Currency,
		//|	ParcelsДетали.СтрокаИнвойса.Сумма КАК Value,
		//|	ВЫРАЗИТЬ(ParcelsДетали.СтрокаИнвойса.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ.Код КАК СТРОКА(4)) КАК BORG,
		//|	ParcelsДетали.НомерЗаявкиНаЗакупку КАК PONo,
		//|	ParcelsДетали.СтрокаЗаявкиНаЗакупку КАК POLineNo,
		//|	ВЫБОР
		//|		КОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
		//|			ТОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.LegalEntityForLeg7
		//|		ИНАЧЕ AUsAndLegalEntities.LegalEntity
		//|	КОНЕЦ КАК LegalEntity,
		//|	ЕСТЬNULL(ParcelsДетали.СтрокаИнвойса.Инвойс.Голд, ЛОЖЬ) КАК Gold,
		//|	ParcelsДетали.СтрокаИнвойса.КостЦентр КАК AU,
		//|	ParcelsДетали.СтрокаИнвойса.КостЦентр.NonLawson КАК AUNonLawson,
		//|	ParcelsДетали.СтрокаИнвойса.Активити КАК Activity,
		//|	ParcelsДетали.Ссылка.WarehouseTo КАК WarehouseTo,
		//|	ParcelsДетали.СтрокаИнвойса КАК Item,
		//|	ParcelsДетали.СтрокаИнвойса.Наименование КАК ItemName,
		//|	ВЫРАЗИТЬ(ParcelsДетали.СтрокаИнвойса.НаименованиеТовара КАК СТРОКА(300)) КАК ItemDescription,
		//|	ParcelsДетали.СтрокаИнвойса.Классификатор КАК ERPTreatment
		//|ИЗ
		//|	Документ.Trip.Parcels КАК TripParcels
		//|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
		//|		ПО (ParcelsДетали.Ссылка = TripParcels.Parcel)
		//|			И (ParcelsДетали.СтрокаИнвойса.SoldTo.StartOfExportToTMS <= TripParcels.Ссылка.Final)
		//|			И (ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining <> ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.ПустаяСсылка))
		//|			И (ParcelsДетали.СтрокаИнвойса.SoldTo.StartOfExportToTMS <> ДАТАВРЕМЯ(1, 1, 1))
		//|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.AUsAndLegalEntities КАК AUsAndLegalEntities
		//|		ПО (ParcelsДетали.СтрокаИнвойса.SoldTo = AUsAndLegalEntities.ParentCompany)
		//|			И (ParcelsДетали.СтрокаИнвойса.КостЦентр = AUsAndLegalEntities.AU)
		//|ГДЕ
		//|	TripParcels.Ссылка = &Trip
		//|	И НЕ ParcelsДетали.Ссылка ЕСТЬ NULL 
		//|	И (ParcelsДетали.Ссылка.WarehouseTo, ЕСТЬNULL(ParcelsДетали.СтрокаИнвойса.Инвойс.Голд, ЛОЖЬ), ВЫБОР
		//|			КОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
		//|				ТОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.LegalEntityForLeg7
		//|			ИНАЧЕ AUsAndLegalEntities.LegalEntity
		//|		КОНЕЦ, ParcelsДетали.СтрокаИнвойса.КостЦентр, ParcelsДетали.СтрокаИнвойса.Активити) В
		//|			(ВЫБРАТЬ
		//|				ВТ_ДанныеDomesticOB.WarehouseTo,
		//|				ВТ_ДанныеDomesticOB.Gold,
		//|				ВТ_ДанныеDomesticOB.LegalEntity,
		//|				ВТ_ДанныеDomesticOB.AU,
		//|				ВТ_ДанныеDomesticOB.Activity
		//|			ИЗ
		//|				ВТ_ДанныеDomesticOB КАК ВТ_ДанныеDomesticOB)";
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	TripDomesticOB.WarehouseTo КАК WarehouseTo,
		|	TripDomesticOB.Gold КАК Gold,
		|	TripDomesticOB.LegalEntity КАК LegalEntity,
		|	TripDomesticOB.AU КАК AU,
		|	TripDomesticOB.Activity КАК Activity
		|ПОМЕСТИТЬ ВТ_ДанныеDomesticOB
		|ИЗ
		|	Документ.Trip.DomesticOB КАК TripDomesticOB
		|ГДЕ
		|	TripDomesticOB.Ссылка = &Trip
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	WarehouseTo,
		|	Gold,
		|	LegalEntity,
		|	AU,
		|	Activity
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ParcelsДетали.СтрокаИнвойса.КостЦентр КАК AU,
		|	ParcelsДетали.СтрокаИнвойса.SoldTo КАК SoldTo
		|ПОМЕСТИТЬ ВТ_AUsAndSoldTo
		|ИЗ
		|	Документ.Trip.Parcels КАК TripParcels
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
		|		ПО (ParcelsДетали.Ссылка = TripParcels.Parcel)
		|			И (TripParcels.Ссылка = &Trip)
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	AU,
		|	SoldTo
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Trip.ETD,
		|	Trip.WarehouseFrom.Код КАК WarehouseFromCode,
		|	Trip.Comment
		|ИЗ
		|	Документ.Trip КАК Trip
		|ГДЕ
		|	Trip.Ссылка = &Trip
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	TripParcels.Parcel.Ссылка КАК Parcel,
		|	TripParcels.Parcel.Код КАК ParcelNo,
		|	ВЫБОР
		|		КОГДА TripParcels.Parcel.PackingType.TMSID = """"
		|			ТОГДА ""EACH""
		|		ИНАЧЕ TripParcels.Parcel.PackingType.TMSID
		|	КОНЕЦ КАК PackingTypeTMSID,
		|	TripParcels.Parcel.SerialNo КАК SerialNo,
		|	ВЫБОР
		|		КОГДА TripParcels.Parcel.LengthCMCorrected = 0
		|			ТОГДА TripParcels.Parcel.LengthCM
		|		ИНАЧЕ TripParcels.Parcel.LengthCMCorrected
		|	КОНЕЦ КАК LengthCM,
		|	ВЫБОР
		|		КОГДА TripParcels.Parcel.WidthCMCorrected = 0
		|			ТОГДА TripParcels.Parcel.WidthCM
		|		ИНАЧЕ TripParcels.Parcel.WidthCMCorrected
		|	КОНЕЦ КАК WidthCM,
		|	ВЫБОР
		|		КОГДА TripParcels.Parcel.HeightCMCorrected = 0
		|			ТОГДА TripParcels.Parcel.HeightCM
		|		ИНАЧЕ TripParcels.Parcel.HeightCMCorrected
		|	КОНЕЦ КАК HeightCM,
		|	ВЫБОР
		|		КОГДА TripParcels.Parcel.CubicMetersCorrected = 0
		|			ТОГДА TripParcels.Parcel.CubicMeters
		|		ИНАЧЕ TripParcels.Parcel.CubicMetersCorrected
		|	КОНЕЦ КАК CubicMeters,
		|	ВЫБОР
		|		КОГДА TripParcels.Parcel.GrossWeightKGCorrected = 0
		|			ТОГДА TripParcels.Parcel.GrossWeightKG
		|		ИНАЧЕ TripParcels.Parcel.GrossWeightKGCorrected
		|	КОНЕЦ КАК GrossWeightKG,
		|	TripParcels.Parcel.NumOfParcels КАК NumOfParcels,
		|	TripFinalDestinations.ETA,
		|	ВЫБОР
		|		КОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
		|			ТОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.LegalEntityForLeg7
		|		ИНАЧЕ AUsAndLegalEntitiesСрезПоследних.LegalEntity
		|	КОНЕЦ КАК LegalEntity,
		|	ЕСТЬNULL(ParcelsДетали.СтрокаИнвойса.Инвойс.Голд, ЛОЖЬ) КАК Gold,
		|	ParcelsДетали.СтрокаИнвойса.КостЦентр КАК AU,
		|	ParcelsДетали.СтрокаИнвойса.Активити КАК Activity,
		|	ПОДСТРОКА(ParcelsДетали.СтрокаИнвойса.НомерЗаявкиНаЗакупку, 1, 2) КАК BORGcode,
		|	TripFinalDestinations.WarehouseTo КАК WarehouseTo,
		|	TripParcels.Parcel.HazardClass КАК HazardClass
		|ИЗ
		|	Документ.Trip.Parcels КАК TripParcels
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
		|		ПО TripParcels.Parcel.WarehouseTo = TripFinalDestinations.WarehouseTo
		|			И TripParcels.Ссылка = TripFinalDestinations.Ссылка
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
		|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.AUsAndLegalEntities.СрезПоследних(
		|					&Период,
		|					(AU, ParentCompany) В
		|						(ВЫБРАТЬ РАЗЛИЧНЫЕ
		|							ВТ_AUsAndSoldTo.AU,
		|							ВТ_AUsAndSoldTo.SoldTo
		|						ИЗ
		|							ВТ_AUsAndSoldTo КАК ВТ_AUsAndSoldTo)) КАК AUsAndLegalEntitiesСрезПоследних
		|			ПО ParcelsДетали.СтрокаИнвойса.SoldTo = AUsAndLegalEntitiesСрезПоследних.ParentCompany
		|				И ParcelsДетали.СтрокаИнвойса.КостЦентр = AUsAndLegalEntitiesСрезПоследних.AU
		|		ПО TripParcels.Parcel = ParcelsДетали.Ссылка
		|			И (ParcelsДетали.СтрокаИнвойса.SoldTo.StartOfExportToTMS <= TripParcels.Ссылка.Final)
		|			И (ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining <> ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.ПустаяСсылка))
		|			И (ParcelsДетали.СтрокаИнвойса.SoldTo.StartOfExportToTMS <> ДАТАВРЕМЯ(1, 1, 1))
		|ГДЕ
		|	TripParcels.Ссылка = &Trip
		|	И TripFinalDestinations.Ссылка = &Trip
		|	И (TripFinalDestinations.WarehouseTo, ЕСТЬNULL(ParcelsДетали.СтрокаИнвойса.Инвойс.Голд, ЛОЖЬ), ВЫБОР
		|			КОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
		|				ТОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.LegalEntityForLeg7
		|			ИНАЧЕ AUsAndLegalEntitiesСрезПоследних.LegalEntity
		|		КОНЕЦ, ParcelsДетали.СтрокаИнвойса.КостЦентр, ParcelsДетали.СтрокаИнвойса.Активити) В
		|			(ВЫБРАТЬ
		|				ВТ_ДанныеDomesticOB.WarehouseTo,
		|				ВТ_ДанныеDomesticOB.Gold,
		|				ВТ_ДанныеDomesticOB.LegalEntity,
		|				ВТ_ДанныеDomesticOB.AU,
		|				ВТ_ДанныеDomesticOB.Activity
		|			ИЗ
		|				ВТ_ДанныеDomesticOB КАК ВТ_ДанныеDomesticOB)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ParcelsДетали.Ссылка КАК Parcel,
		|	ParcelsДетали.НомерСтроки,
		|	ParcelsДетали.СтрокаИнвойса.КодПоИнвойсу КАК PartNo,
		|	ParcelsДетали.Qty,
		|	ВЫБОР
		|		КОГДА ParcelsДетали.QtyUOM.TMSIdForItemUOM = """"
		|			ТОГДА ""EACH""
		|		ИНАЧЕ ParcelsДетали.QtyUOM.TMSIdForItemUOM
		|	КОНЕЦ КАК QtyUOMTMSIdForItemUOM,
		|	ParcelsДетали.СерийныйНомер,
		|	ParcelsДетали.СтрокаИнвойса.RAN КАК RAN,
		|	ParcelsДетали.СтрокаИнвойса.СтранаПроисхождения.TMSID КАК CountryOfOrigin,
		|	ParcelsДетали.СтрокаИнвойса.Currency.НаименованиеEng КАК Currency,
		|	ParcelsДетали.СтрокаИнвойса.Сумма КАК Value,
		|	ВЫРАЗИТЬ(ParcelsДетали.СтрокаИнвойса.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ.Код КАК СТРОКА(4)) КАК BORG,
		|	ParcelsДетали.НомерЗаявкиНаЗакупку КАК PONo,
		|	ParcelsДетали.СтрокаЗаявкиНаЗакупку КАК POLineNo,
		|	ВЫБОР
		|		КОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
		|			ТОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.LegalEntityForLeg7
		|		ИНАЧЕ AUsAndLegalEntitiesСрезПоследних.LegalEntity
		|	КОНЕЦ КАК LegalEntity,
		|	ЕСТЬNULL(ParcelsДетали.СтрокаИнвойса.Инвойс.Голд, ЛОЖЬ) КАК Gold,
		|	ParcelsДетали.СтрокаИнвойса.КостЦентр КАК AU,
		|	ParcelsДетали.СтрокаИнвойса.КостЦентр.NonLawson КАК AUNonLawson,
		|	ParcelsДетали.СтрокаИнвойса.Активити КАК Activity,
		|	ПОДСТРОКА(ParcelsДетали.СтрокаИнвойса.НомерЗаявкиНаЗакупку, 1, 2) КАК BORGcode,
		|	ParcelsДетали.Ссылка.WarehouseTo КАК WarehouseTo,
		|	ParcelsДетали.СтрокаИнвойса КАК Item,
		|	ParcelsДетали.СтрокаИнвойса.Наименование КАК ItemName,
		|	ВЫРАЗИТЬ(ParcelsДетали.СтрокаИнвойса.НаименованиеТовара КАК СТРОКА(300)) КАК ItemDescription,
		|	ParcelsДетали.СтрокаИнвойса.Классификатор КАК ERPTreatment
		|ИЗ
		|	Документ.Trip.Parcels КАК TripParcels
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
		|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.AUsAndLegalEntities.СрезПоследних(
		|					&Период,
		|					(AU, ParentCompany) В
		|						(ВЫБРАТЬ РАЗЛИЧНЫЕ
		|							ВТ_AUsAndSoldTo.AU,
		|							ВТ_AUsAndSoldTo.SoldTo
		|						ИЗ
		|							ВТ_AUsAndSoldTo КАК ВТ_AUsAndSoldTo)) КАК AUsAndLegalEntitiesСрезПоследних
		|			ПО ParcelsДетали.СтрокаИнвойса.SoldTo = AUsAndLegalEntitiesСрезПоследних.ParentCompany
		|				И ParcelsДетали.СтрокаИнвойса.КостЦентр = AUsAndLegalEntitiesСрезПоследних.AU
		|		ПО (ParcelsДетали.Ссылка = TripParcels.Parcel)
		|			И (ParcelsДетали.СтрокаИнвойса.SoldTo.StartOfExportToTMS <= TripParcels.Ссылка.Final)
		|			И (ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining <> ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.ПустаяСсылка))
		|			И (ParcelsДетали.СтрокаИнвойса.SoldTo.StartOfExportToTMS <> ДАТАВРЕМЯ(1, 1, 1))
		|ГДЕ
		|	TripParcels.Ссылка = &Trip
		|	И НЕ ParcelsДетали.Ссылка ЕСТЬ NULL 
		|	И (ParcelsДетали.Ссылка.WarehouseTo, ЕСТЬNULL(ParcelsДетали.СтрокаИнвойса.Инвойс.Голд, ЛОЖЬ), ВЫБОР
		|			КОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
		|				ТОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.LegalEntityForLeg7
		|			ИНАЧЕ AUsAndLegalEntitiesСрезПоследних.LegalEntity
		|		КОНЕЦ, ParcelsДетали.СтрокаИнвойса.КостЦентр, ParcelsДетали.СтрокаИнвойса.Активити) В
		|			(ВЫБРАТЬ
		|				ВТ_ДанныеDomesticOB.WarehouseTo,
		|				ВТ_ДанныеDomesticOB.Gold,
		|				ВТ_ДанныеDomesticOB.LegalEntity,
		|				ВТ_ДанныеDomesticOB.AU,
		|				ВТ_ДанныеDomesticOB.Activity
		|			ИЗ
		|				ВТ_ДанныеDomesticOB КАК ВТ_ДанныеDomesticOB)";
	// } RGS AGorlenko 04.09.2015 12:39:43 - оптимизация запроса и поддержка периодичночти AUs and Legal entities
		
	Результаты = Запрос.ВыполнитьПакет();	
		
	СтруктураДанных = Новый Структура("TripOB, Parcels, Items");

	ТаблицаTripOB = Результаты[2].Выгрузить();
	СтруктураДанных.TripOB = ТаблицаTripOB[0];
	
	СтруктураДанных.Parcels = Результаты[3].Выгрузить();
	
	СтруктураДанных.Items = Результаты[4].Выгрузить();
	СтруктураДанных.Items.Индексы.Добавить("PartNo");
	
	Возврат СтруктураДанных;
	
КонецФункции

Функция ПолучитьTransOrderHeader(ФабрикаXDTOTMS, СтруктураДанных, СтрокаDomesticOB)

	TripOB = СтруктураДанных.TripOB;
	TransOrderHeader = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransOrderHeader");
	
	// Номер
	TransOrderHeader.TransOrderGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransOrderGid");
	TransOrderHeader.TransOrderGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, СокрЛП(СтрокаDomesticOB.OBNo));
	TransOrderHeader.TransOrderGid.Gid.DomainName = "SLB";
                 		
	// TransactionCode and other fixed stuff
	TransOrderHeader.TransactionCode = "IU";
	
	TransOrderHeader.ReleaseMethodGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ReleaseMethodGid");
	TransOrderHeader.ReleaseMethodGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "SHIP_UNITS");
	
	OrderTypeGidGid = "SHIP UNIT DOMESTIC";
		
	TransOrderHeader.OrderTypeGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "OrderTypeGid");
	TransOrderHeader.OrderTypeGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, OrderTypeGidGid);
	TransOrderHeader.OrderTypeGid.Gid.DomainName = "SLB";
	
	// From (there is also from part in ship units)
	TransOrderHeader.StuffLocation = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "StuffLocation");
	TransOrderHeader.StuffLocation.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, СокрЛП(TripOB.WarehouseFromCode));
	   	
	// To (there is also to part in ship units)
	TransOrderHeader.DestuffLocation = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "DestuffLocation");
	TransOrderHeader.DestuffLocation.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, СокрЛП(РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(СтрокаDomesticOB.WarehouseTo, "Код")));	
	    	
	// Legal entity, AU, Activity, Comment, etc
	МассивOrderRefnum = ПолучитьМассивOrderRefnum(ФабрикаXDTOTMS, TripOB, СтруктураДанных, СтрокаDomesticOB);
	Для Каждого OrderRefnum из МассивOrderRefnum Цикл 
		TransOrderHeader.OrderRefnum.Добавить(OrderRefnum);
	КонецЦикла;
		
	// Priority
	Urgencies = Перечисления.Urgencies;
	Если СтрокаDomesticOB.Urgency = Urgencies.Standard Тогда 
		TransOrderHeader.OrderPriority = "3";
	иначеЕсли СтрокаDomesticOB.Urgency = Urgencies.Urgent Тогда 
		TransOrderHeader.OrderPriority = "2";
	иначеЕсли СтрокаDomesticOB.Urgency = Urgencies.Emergency Тогда 
		TransOrderHeader.OrderPriority = "1";
	КонецЕсли;
	    	                       	
	// Total Net Weight Volume KG
	TransOrderHeader.TotalNetWeightVolume = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TotalNetWeightVolume");
	TransOrderHeader.TotalNetWeightVolume.Weight = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Weight");
	TransOrderHeader.TotalNetWeightVolume.Weight.WeightValue = СтруктураДанных.Parcels.Итог("GrossWeightKG");
	TransOrderHeader.TotalNetWeightVolume.Weight.WeightUOMGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "WeightUOMGid");
	TransOrderHeader.TotalNetWeightVolume.Weight.WeightUOMGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Справочники.UOMs.KG, "TMSId"));
	       		
	// Involved Party
	МассивInvolvedParty = ПолучитьМассивInvolvedParty(ФабрикаXDTOTMS);
	Для Каждого InvolvedParty из МассивInvolvedParty Цикл 
		TransOrderHeader.InvolvedParty.Добавить(InvolvedParty);
	КонецЦикла;
	
	HazardousComment = "";
	Сч = 1;
	Для Каждого СтрокаТабParcels из СтруктураДанных.Parcels Цикл
		
		Если СтрокаТабParcels.HazardClass = Справочники.HazardClasses.NonHazardous Тогда 
			Продолжить;
		КонецЕсли;
		
		HazardousComment = ?(HazardousComment = "", "Request contains hazardous parcels: ", ", ") + СокрЛП(СтрокаDomesticOB.OBNo) + "-" + ?(Сч < 10, "0", "") + СокрЛП(Сч);
		
	КонецЦикла;
	
	// Comments
	Если ЗначениеЗаполнено(TripOB.Comment) ИЛИ ЗначениеЗаполнено(HazardousComment) Тогда
		
		Remark = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Remark");
		Remark.RemarkText = СокрЛП(TripOB.Comment + ?(ЗначениеЗаполнено(TripOB.Comment), Символы.ПС, "") + HazardousComment);
				
		Remark.RemarkQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "RemarkQualifierGid");
		Remark.RemarkQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "REM");
		TransOrderHeader.Remark.Добавить(Remark);
		
	КонецЕсли;
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "REM", TripOB.Comment));
	
	Возврат TransOrderHeader;
		         	
КонецФункции

Функция ПолучитьМассивOrderRefnum(ФабрикаXDTOTMS, TripOB, СтруктураДанных, СтрокаDomesticOB)
	
	МассивOrderRefnum = Новый Массив;
	 		
	// Pickup and delivery date
	ФорматДаты = "ДФ='гггг-ММ-дд чч:мм:сс'";
	
	PickupDateText = Формат(TripOB.ETD, ФорматДаты);
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_PICKUP_DT", PickupDateText));	
	
	DeliveryDateText = Формат(СтруктураДанных.Parcels[0].ETA, ФорматДаты);
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_DELIVERY_DT", DeliveryDateText));
	
	// Legal entity
	// { RGS AGorlenko 02.08.2018 13:14:31 - S-I-0005696
	//СтруктураLE = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(СтрокаDomesticOB.LegalEntity, "Наименование,CountryCode,CompanyCode,ERPID,FinanceLocCode,FinanceProcess");
	СтруктураLE = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(СтрокаDomesticOB.LegalEntity, "Наименование,CountryCode,CompanyCode,ERPID,FinanceLocCode,FinanceProcess,RechargeToLegalEntity,RechargeToAU,RechargeToActivity");
	// } RGS AGorlenko 02.08.2018 13:15:06 - S-I-0005696
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_COMP_NAME", СтруктураLE.Наименование));
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_COUNTRY_CODE", СтруктураLE.CountryCode));  
		
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_LEGAL_ENTITY", СтруктураLE.CompanyCode));  

	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_ERP_ID", СтруктураLE.ERPID));  

   	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_FIN_LOC_CODE", СтруктураLE.FinanceLocCode));
	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_FIN_PROCESS", СтруктураLE.FinanceProcess));
	
	// Paying Entity
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_PAYING_ENTITY", "S"));
	
	// AU	
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_COST_CENTER", СокрЛП(РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(СтрокаDomesticOB.AU, "Код"))));

	// Segment
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_SEGMENT", СокрЛП(РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(СтрокаDomesticOB.AU, "Segment"))));

	// Activity
	МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_ACT_CODE", СокрЛП(СтрокаDomesticOB.Activity)));
	
	// Recharge
	// { RGS AGorlenko 02.08.2018 13:16:25 - S-I-0005696
	//МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_RECHARGE_FLAG", "N"));
	Если НЕ ЗначениеЗаполнено(СтруктураLE.RechargeToLegalEntity) Тогда
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_RECHARGE_FLAG", "N"));
		
	Иначе
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_RECHARGE_FLAG", "I"));
		
		// Recharge Legal entity
		СтруктураRechargeLE = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(СтруктураLE.RechargeToLegalEntity, "Наименование, ERPID, CompanyCode, CountryCode, FinanceLocCode, FinanceProcess");
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_COMP_NAME", СтруктураRechargeLE.Наименование));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_ERP_ID", СтруктураRechargeLE.ERPID));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_LEGAL_ENTITY", СтруктураRechargeLE.CompanyCode));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_COUNTRY_CODE", СтруктураRechargeLE.CountryCode));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_FIN_LOC_CODE", СтруктураRechargeLE.FinanceLocCode));
		
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_FIN_PROCESS", СтруктураRechargeLE.FinanceProcess));
		
		// Recharge AU	
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_COST_CENTER", СокрЛП(РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(СтруктураLE.RechargeToAU, "Код"))));

		// Recharge Activity	
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_R_ACT_CODE", СокрЛП(СтруктураLE.RechargeToActivity)));
		
	КонецЕсли;
	// } RGS AGorlenko 02.08.2018 13:16:30 - S-I-0005696
	
	// PO no
	ТаблицаBORGsPONo = СтруктураДанных.Items.Скопировать( , "BORG,PONo");
	ТаблицаBORGsPONo.Свернуть("BORG,PONo");
	РГСофтКлиентСервер.СокрЛПКолонокВТаблице(ТаблицаBORGsPONo, "BORG,PONo");
	
	МассивBORGs = Новый Массив;
	Для Каждого СтрBORG из ТаблицаBORGsPONo Цикл 
		Если МассивBORGs.Найти(СтрBORG.BORG) = Неопределено Тогда
			МассивBORGs.Добавить(СтрBORG.BORG);
		КонецЕсли;
	КонецЦикла;
	
	СтрокаPOno = "";
	
	СтруктураПоискаBORG = Новый Структура("BORG");
	ПревышенЛимит = Ложь;
	Для Каждого BORG из МассивBORGs Цикл 
		
		Если ПревышенЛимит Тогда
			Прервать;
		КонецЕсли;
			
		СтруктураПоискаBORG.BORG = BORG;
		СтрокаPOno = СтрокаPOno + ?(СтрокаPOno = "", "", ";") + BORG + ":";
		
		МассивСтрокItems = ТаблицаBORGsPONo.НайтиСтроки(СтруктураПоискаBORG);
		Для Каждого СтрокаItem из МассивСтрокItems Цикл 
			
			Если СтрокаPOno = "" ИЛИ Прав(СтрокаPOno, 1) = ":" Тогда 
				РазделительPOno = "";
			иначе
				РазделительPOno = ",";
			КонецЕсли;
			
			НоваяСтрокаPOno = СтрокаPOno + РазделительPOno + ?(ПустаяСтрока(BORG), СтрокаItem.PONo, Сред(СтрокаItem.PONo, СтрДлина(BORG) + 1));
			
			Если СтрДлина(НоваяСтрокаPOno) > 240 Тогда
				ПревышенЛимит = Истина;
				Прервать;
			КонецЕсли;
			
			СтрокаPOno = НоваяСтрокаPOno;

		КонецЦикла;
	
	КонецЦикла;
	
	Если Не ПустаяСтрока(СтрокаPOno) Тогда 
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_JOB_NO", СтрокаPOno));
		МассивOrderRefnum.Добавить(ПолучитьOrderRefnum(ФабрикаXDTOTMS, "OB_PO_NUMBER", Лев(СтрокаPOno,30)));
	КонецЕсли;
	
	Возврат МассивOrderRefnum;
	
КонецФункции
   
Функция ПолучитьМассивInvolvedParty(ФабрикаXDTOTMS)
	
	МассивInvolvedParty = Новый Массив;
	
	Alias = СокрЛП(РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(ПараметрыСеанса.ТекущийПользователь, "Код"));	
	
	// REQUESTER
	RequestorInvolvedParty = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "", "REQUESTER", , Alias);
	МассивInvolvedParty.Добавить(RequestorInvolvedParty);
	
	// ORIGIN SLS
	ShipperContact = ПолучитьInvolvedParty(ФабрикаXDTOTMS, "SLB", "ORIGIN_SLS", , Alias);
	МассивInvolvedParty.Добавить(ShipperContact);
		    			
    Возврат МассивInvolvedParty;
	
КонецФункции

Функция ПолучитьShipUnitDetail(ФабрикаXDTOTMS, СтруктураДанных, СтрокаDomesticOB)
	
	TripOB = СтруктураДанных.TripOB;
	ТаблицаParcels = СтруктураДанных.Parcels;
	ТаблицаItems = СтруктураДанных.Items;
	
	// Prepare stuff fixed for all ship units
	
	// Earlist pick up and required delivery dates
	TimeWindow = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TimeWindow");
	
	TimeWindow.EarlyPickupDt = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogDateTimeType");
	TimeWindow.EarlyPickupDt.GLogDate = Формат(TripOB.ETD, TMSСервер.ПолучитьФорматДатыTMS());
	
	TimeWindow.LateDeliveryDt = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogDateTimeType");
	TimeWindow.LateDeliveryDt.GLogDate = Формат(ТаблицаParcels[0].ETA, TMSСервер.ПолучитьФорматДатыTMS());
	 		
	// Source location
	ShipFromLocationRefValue = СокрЛП(TripOB.WarehouseFromCode);
	ShipFromLocationRef = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipFromLocationRef");
	ShipFromLocationRef.LocationRef = ПолучитьLocationRef(ФабрикаXDTOTMS, ShipFromLocationRefValue);
	
	// Destination location
	ShipToLocationRefValue = СокрЛП(РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(СтрокаDomesticOB.WarehouseTo, "Код"));
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
		ShipUnitNo = СокрЛП(СтрокаDomesticOB.OBNo) + "-" + ?(Сч < 10, "0", "") + СокрЛП(Сч);
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
		ПроверитьИЗаполнитьShipUnitContent(Отказ, ФабрикаXDTOTMS, ShipUnit, ТаблицаParcelItems);
		Если Отказ Тогда 
			Возврат Неопределено;
		КонецЕсли;
						                    		
		ShipUnitDetail.ShipUnit.Добавить(ShipUnit);
		
		Сч = Сч + 1;
		
	КонецЦикла;
	          		
	Возврат ShipUnitDetail;
		         	
КонецФункции

Процедура ПроверитьИЗаполнитьShipUnitContent(Отказ, ФабрикаXDTOTMS, ShipUnit, ТаблицаParcelItems)
	
	МассивERPTreatment = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаParcelItems, "ERPTreatment");
	
	// ERP treatment
	//ShipUnit.TagInfo.ItemTag3 = "EXPENSE";
	ShipUnit.TagInfo.ItemTag3 = ?(МассивERPTreatment.Количество() = 1, Перечисления.ТипыЗаказа.ПолучитьTMSId(МассивERPTreatment[0], Истина), "EXPENSE");
	
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

// ПЕЧАТНЫЕ ФОРМЫ

// ПОРУЧЕНИЕ ЭКСПЕДИТОРУ

Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	               		
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "APPLICATIONTOTHEFORWARDER") тогда
		
		ТабДокумент = ПечатьПорученийЭкспедитору(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "APPLICATIONTOTHEFORWARDER",
				"APPLICATION TO THE FORWARDER", ТабДокумент);
				
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "NonPO") тогда
		
		ТабДокумент = ПечатьNonPO(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "NonPO",
				"Non-PO", ТабДокумент);
				
	КонецЕсли;

КонецПроцедуры

Функция ПечатьПорученийЭкспедитору(МассивОбъектов, ОбъектыПечати) 
	
	ТекстЗапроса = 
	// { RGS AGorlenko 10.11.2015 19:07:47 - поддержка периодичночти AUs and Legal entities
	//"ВЫБРАТЬ РАЗЛИЧНЫЕ
	//|	ВЫБОР
	//|		КОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
	//|			ТОГДА ParcelsДетали.СтрокаИнвойса.SoldTo.LegalEntityForLeg7
	//|		ИНАЧЕ AUsAndLegalEntities.LegalEntity
	//|	КОНЕЦ КАК LegalEntity,
	//|	ParcelsДетали.СтрокаИнвойса.SoldTo КАК ParentCompany,
	//|	TripParcels.Ссылка.Draft,
	//|	TripParcels.Ссылка.Номер КАК TripNo,
	//|	TripParcels.Ссылка.Equipment,
	//|	ParcelsДетали.Ссылка.NumOfParcels,
	//|	ParcelsДетали.Ссылка.GrossWeightKG КАК ParcelsGrossWeight,
	//|	ParcelsДетали.Ссылка.CubicMeters КАК ParcelsCubicMeters,
	//|	TripParcels.Ссылка КАК Trip,
	//|	ParcelsДетали.Ссылка.WarehouseTo,
	//|	ParcelsДетали.Ссылка.WarehouseFrom,
	//|	TripParcels.Ссылка.ServiceProvider,
	//|	TripParcels.Parcel
	//|ПОМЕСТИТЬ ВТ
	//|ИЗ
	//|	Документ.Trip.Parcels КАК TripParcels
	//|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
	//|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.AUsAndLegalEntities КАК AUsAndLegalEntities
	//|			ПО ParcelsДетали.СтрокаИнвойса.SoldTo = AUsAndLegalEntities.ParentCompany
	//|				И ParcelsДетали.СтрокаИнвойса.КостЦентр = AUsAndLegalEntities.AU
	//|		ПО TripParcels.Parcel = ParcelsДетали.Ссылка
	//|ГДЕ
	//|	ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining <> ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.ПустаяСсылка)
	//|	И TripParcels.Ссылка В(&МассивОбъектов)
	//|;
	//|
	//|////////////////////////////////////////////////////////////////////////////////
	//|ВЫБРАТЬ
	//|	ВТ.WarehouseTo.AddressRus КАК PointOfDestination,
	//|	ВТ.LegalEntity.NameRus КАК Consignee,
	//|	ВТ.LegalEntity,
	//|	ВТ.WarehouseFrom.NameRus КАК Consignor,
	//|	ВТ.WarehouseFrom,
	//|	ВТ.ParentCompany.NameRus КАК Client,
	//|	ВТ.ParentCompany,
	//|	ВТ.Draft КАК DOCDate,
	//|	ВТ.TripNo КАК DOCNo,
	//|	ВТ.Equipment.NameRus КАК TransporationType,
	//|	ВТ.Equipment,
	//|	СУММА(ВТ.NumOfParcels) КАК NumOfParcels_PackingType,
	//|	СУММА(ВТ.ParcelsGrossWeight) КАК ParcelsGrossWeight,
	//|	СУММА(ВТ.ParcelsCubicMeters) КАК ParcelsCubicMeters,
	//|	ВТ.Trip КАК Trip,
	//|	ВТ.WarehouseTo,
	//|	ВТ.ServiceProvider.NameRus КАК Forwarder,
	//|	ВТ.ServiceProvider
	//|ИЗ
	//|	ВТ КАК ВТ
	//|
	//|СГРУППИРОВАТЬ ПО
	//|	ВТ.WarehouseTo.AddressRus,
	//|	ВТ.LegalEntity.NameRus,
	//|	ВТ.LegalEntity,
	//|	ВТ.WarehouseFrom.NameRus,
	//|	ВТ.WarehouseFrom,
	//|	ВТ.ParentCompany.NameRus,
	//|	ВТ.ParentCompany,
	//|	ВТ.Draft,
	//|	ВТ.TripNo,
	//|	ВТ.Equipment.NameRus,
	//|	ВТ.Equipment,
	//|	ВТ.Trip,
	//|	ВТ.WarehouseTo,
	//|	ВТ.ServiceProvider.NameRus,
	//|	ВТ.ServiceProvider
	//|
	//|УПОРЯДОЧИТЬ ПО
	//|	Trip";
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ParcelsДетали.СтрокаИнвойса.SoldTo КАК ParentCompany,
	|	TripParcels.Ссылка.Draft,
	|	TripParcels.Ссылка.Номер КАК TripNo,
	|	TripParcels.Ссылка.Equipment,
	|	ParcelsДетали.Ссылка.NumOfParcels,
	|	ВЫБОР
	|		КОГДА TripParcels.Parcel.GrossWeight <> TripParcels.Parcel.GrossWeightKGCorrected
	|				И TripParcels.Parcel.GrossWeightKGCorrected <> 0
	|			ТОГДА TripParcels.Parcel.GrossWeightKGCorrected
	|		ИНАЧЕ TripParcels.Parcel.GrossWeight
	|	КОНЕЦ КАК ParcelsGrossWeight,
	|	ParcelsДетали.Ссылка.CubicMeters КАК ParcelsCubicMeters,
	|	TripParcels.Ссылка КАК Trip,
	|	ParcelsДетали.Ссылка.WarehouseTo,
	|	ParcelsДетали.Ссылка.WarehouseFrom,
	|	TripParcels.Ссылка.ServiceProvider,
	|	TripParcels.Parcel,
	|	ParcelsДетали.СтрокаИнвойса.КостЦентр КАК КостЦентр
	|ПОМЕСТИТЬ ВТ
	|ИЗ
	|	Документ.Trip.Parcels КАК TripParcels
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
	|		ПО TripParcels.Parcel = ParcelsДетали.Ссылка
	|ГДЕ
	|	ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining <> ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.ПустаяСсылка)
	|	И TripParcels.Ссылка В(&МассивОбъектов)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ.TripNo,
	|	ВТ.ParentCompany,
	|	ВТ.КостЦентр,
	|	МАКСИМУМ(AUsAndLegalEntities.Период) КАК Период
	|ПОМЕСТИТЬ ВТ_МаксимальныеДаты
	|ИЗ
	|	ВТ КАК ВТ
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.AUsAndLegalEntities КАК AUsAndLegalEntities
	|		ПО ВТ.ParentCompany = AUsAndLegalEntities.ParentCompany
	|			И ВТ.КостЦентр = AUsAndLegalEntities.AU
	|			И ВТ.Draft >= AUsAndLegalEntities.Период
	|
	|СГРУППИРОВАТЬ ПО
	|	ВТ.TripNo,
	|	ВТ.ParentCompany,
	|	ВТ.КостЦентр
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_МаксимальныеДаты.TripNo,
	|	ВТ_МаксимальныеДаты.ParentCompany,
	|	ВТ_МаксимальныеДаты.КостЦентр,
	|	AUsAndLegalEntities.LegalEntity
	|ПОМЕСТИТЬ ВТ_LegalEntity
	|ИЗ
	|	ВТ_МаксимальныеДаты КАК ВТ_МаксимальныеДаты
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.AUsAndLegalEntities КАК AUsAndLegalEntities
	|		ПО ВТ_МаксимальныеДаты.ParentCompany = AUsAndLegalEntities.ParentCompany
	|			И ВТ_МаксимальныеДаты.КостЦентр = AUsAndLegalEntities.AU
	|			И ВТ_МаксимальныеДаты.Период = AUsAndLegalEntities.Период
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВТ.Parcel,
	|	ВТ.WarehouseTo.AddressRus КАК PointOfDestination,
	|	ВТ.WarehouseFrom.NameRus КАК Consignor,
	|	ВТ.WarehouseFrom,
	|	ВТ.ParentCompany.NameRus КАК Client,
	|	ВТ.ParentCompany,
	|	ВТ.Draft КАК DOCDate,
	|	ВТ.TripNo КАК DOCNo,
	|	ВТ.Equipment.NameRus КАК TransporationType,
	|	ВТ.Equipment,
	|	ВТ.NumOfParcels КАК NumOfParcels_PackingType,
	|	ВТ.ParcelsGrossWeight КАК ParcelsGrossWeight,
	|	ВТ.ParcelsCubicMeters КАК ParcelsCubicMeters,
	|	ВТ.Trip КАК Trip,
	|	ВТ.WarehouseTo,
	|	ВТ.ServiceProvider.NameRus КАК Forwarder,
	|	ВТ.ServiceProvider,
	|	ВЫБОР
	|		КОГДА ВТ.ParentCompany.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
	|			ТОГДА ВТ.ParentCompany.LegalEntityForLeg7
	|		ИНАЧЕ ВТ_LegalEntity.LegalEntity
	|	КОНЕЦ КАК LegalEntity,
	|	ВЫБОР
	|		КОГДА ВТ.ParentCompany.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
	|			ТОГДА ВТ.ParentCompany.LegalEntityForLeg7.NameRus
	|		ИНАЧЕ ВТ_LegalEntity.LegalEntity.NameRus
	|	КОНЕЦ КАК Consignee
	|ПОМЕСТИТЬ результат
	|ИЗ
	|	ВТ КАК ВТ
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_LegalEntity КАК ВТ_LegalEntity
	|		ПО ВТ.TripNo = ВТ_LegalEntity.TripNo
	|			И ВТ.ParentCompany = ВТ_LegalEntity.ParentCompany
	|			И ВТ.КостЦентр = ВТ_LegalEntity.КостЦентр
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	результат.PointOfDestination,
	|	результат.Consignor,
	|	результат.WarehouseFrom,
	|	результат.Client,
	|	результат.ParentCompany,
	|	результат.DOCDate,
	|	результат.DOCNo,
	|	результат.TransporationType,
	|	результат.Equipment,
	|	СУММА(результат.NumOfParcels_PackingType) КАК NumOfParcels_PackingType,
	|	СУММА(результат.ParcelsGrossWeight) КАК ParcelsGrossWeight,
	|	СУММА(результат.ParcelsCubicMeters) КАК ParcelsCubicMeters,
	|	результат.Trip,
	|	результат.WarehouseTo,
	|	результат.Forwarder,
	|	результат.ServiceProvider,
	|	результат.LegalEntity,
	|	результат.Consignee
	|ИЗ
	|	результат КАК результат
	|
	|СГРУППИРОВАТЬ ПО
	|	результат.PointOfDestination,
	|	результат.Consignor,
	|	результат.WarehouseFrom,
	|	результат.Client,
	|	результат.ParentCompany,
	|	результат.DOCDate,
	|	результат.DOCNo,
	|	результат.TransporationType,
	|	результат.Equipment,
	|	результат.Trip,
	|	результат.WarehouseTo,
	|	результат.Forwarder,
	|	результат.ServiceProvider,
	|	результат.LegalEntity,
	|	результат.Consignee";
	// } RGS AGorlenko 10.11.2015 19:07:50 - поддержка периодичночти AUs and Legal entities
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("МассивОбъектов", МассивОбъектов);
	
	ТЗ = Запрос.Выполнить().Выгрузить();
	
	ПроверкаПустыхНаименований(ТЗ);
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "APPLICATIONTOTHEFORWARDER";
	
	Макет = ПолучитьОбщийМакет("APPLICATIONTOTHEFORWARDER");
	
	// { RGS AGorlenko 28.12.2015 19:16:15 - поддержка печати комплекта
	ПервыйДокумент = Истина;
	КоличествоСтрокТЗ = ТЗ.Количество();
	ПредыдущийТрип = ?(КоличествоСтрокТЗ = 0, Неопределено, ТЗ[0].Trip);
	НомерСтрокиНачало = Неопределено;
	// } RGS AGorlenko 28.12.2015 19:16:24 - поддержка печати комплекта
	
	Для Каждого СтрокаТЗ из ТЗ Цикл
		
		Если ТабличныйДокумент.ВысотаТаблицы > 0 Тогда
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		// { RGS AGorlenko 28.12.2015 19:16:15 - поддержка печати комплекта
		Если Не ПервыйДокумент И СтрокаТЗ.Trip <> ПредыдущийТрип Тогда
			УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, ПредыдущийТрип);
		КонецЕсли;
		// } RGS AGorlenko 28.12.2015 19:16:24 - поддержка печати комплекта
		
		// { RGS AGorlenko 28.12.2015 19:16:15 - поддержка печати комплекта
		//НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
		Если ПервыйДокумент ИЛИ СтрокаТЗ.Trip <> ПредыдущийТрип Тогда
			НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
			Если ПервыйДокумент Тогда
				ПервыйДокумент = Ложь;
			КонецЕсли;
			Если СтрокаТЗ.Trip <> ПредыдущийТрип Тогда
				ПредыдущийТрип = СтрокаТЗ.Trip;
			КонецЕсли;
		КонецЕсли;
		// } RGS AGorlenko 28.12.2015 19:16:24 - поддержка печати комплекта
		
		ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
		ЗаполнитьЗначенияСвойств(ОбластьМакета.Параметры, СтрокаТЗ);
		
		ОбластьМакета.Параметры.GoodsReadyForShipmentPlaceDate = "Список в приложении";
		
		ТабличныйДокумент.Вывести(ОбластьМакета);
		
		// { RGS AGorlenko 28.12.2015 19:32:02 - поддержка печати комплекта, перенесено выше
		//УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, СтрокаТЗ.Trip);
		// } RGS AGorlenko 28.12.2015 19:32:03 - поддержка печати комплекта, перенесено выше
	
	КонецЦикла;
	
	// { RGS AGorlenko 28.12.2015 19:32:02 - поддержка печати комплекта, перенесено выше
	Если КоличествоСтрокТЗ > 0 Тогда
		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, СтрокаТЗ.Trip);
	КонецЕсли;
	// } RGS AGorlenko 28.12.2015 19:32:03 - поддержка печати комплекта, перенесено выше
	
	Возврат ТабличныйДокумент;
	
КонецФункции

Процедура ПроверкаПустыхНаименований(ТЗ)
	
	// Service provider
	ТЗПустыхForwarder = ТЗ.скопировать(Новый Структура("Forwarder", ""), "ServiceProvider,Forwarder");
	ТЗПустыхForwarder.Свернуть("ServiceProvider,Forwarder");
	Для Каждого Стр из ТЗПустыхForwarder Цикл 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"For Service provider '" + СокрЛП(Стр.ServiceProvider) + "' name (rus) is empty!"
		, Стр.ServiceProvider);
	КонецЦикла;
	
	// Warehouse To
	ТЗПустыхWarehouseAddresses = ТЗ.скопировать(Новый Структура("PointOfDestination", ""), "WarehouseTo,PointOfDestination");
	ТЗПустыхWarehouseAddresses.Свернуть("WarehouseTo,PointOfDestination");
	Для Каждого Стр из ТЗПустыхWarehouseAddresses Цикл 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"For Warehouse '" + СокрЛП(Стр.WarehouseTo) + "' address (rus) is empty!"
		, Стр.WarehouseTo);
	КонецЦикла;
	
	// Warehouse From
	ТЗПустыхWarehouseNames = ТЗ.скопировать(Новый Структура("Consignor", ""), "WarehouseFrom,Consignor");
	ТЗПустыхWarehouseNames.Свернуть("WarehouseFrom,Consignor");
	Для Каждого Стр из ТЗПустыхWarehouseNames Цикл 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"For Warehouse '" + СокрЛП(Стр.WarehouseFrom) + "' Name (rus) for ""consignor"" is empty!"
		, Стр.WarehouseFrom);
	КонецЦикла;
	
	// Legal entity
	ТЗПустыхConsignee = ТЗ.скопировать(Новый Структура("Consignee", ""), "LegalEntity,Consignee");
	ТЗПустыхConsignee.Свернуть("LegalEntity,Consignee");
	Для Каждого Стр из ТЗПустыхConsignee Цикл 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"For Legal entity '" + СокрЛП(Стр.LegalEntity) + "' name (rus) is empty!"
		, Стр.LegalEntity);
	КонецЦикла;
	
	// Parent company
	ТЗПустыхClient = ТЗ.скопировать(Новый Структура("Client", ""), "ParentCompany,Client");
	ТЗПустыхClient.Свернуть("ParentCompany,Client");
	Для Каждого Стр из ТЗПустыхClient Цикл 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"For Parent company '" + СокрЛП(Стр.ParentCompany) + "' name (rus) is empty!"
		, Стр.ParentCompany);
	КонецЦикла;

	// Equipment
	ТЗПустыхTransporationType = ТЗ.скопировать(Новый Структура("TransporationType", ""), "Equipment,TransporationType");
	ТЗПустыхTransporationType.Свернуть("Equipment,TransporationType");
	Для Каждого Стр из ТЗПустыхTransporationType Цикл 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"For Equipment '" + СокрЛП(Стр.Equipment) + "' name (rus) is empty!"
		, Стр.Equipment);
	КонецЦикла;

КонецПроцедуры

// Non-PO

Функция ПечатьNonPO(МассивОбъектов, ОбъектыПечати) 
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "NonPO";
	
	Макет = ПолучитьМакет("NonPO");

	Для Каждого Trip из МассивОбъектов Цикл 
		
	ТекстОшибок = "";	
		
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	Trip.Номер КАК TripNo,
	|	Trip.Дата КАК TripDate,
	|	Trip.WarehouseFrom КАК PickUpWarehouse,
	|	Trip.ATD КАК ActualDepartureLocalTime,
	|	Trip.ServiceProvider.ContactName КАК SPContactName,
	|	Trip.ServiceProvider.ContactPhone КАК SPContactPhone,
	|	Trip.ServiceProvider.ContactEMail КАК SPContactEmail,
	|	Trip.ServiceProvider.NameRus КАК SPNameRus,
	|	Trip.ServiceProvider.Наименование КАК SPNameEng,
	|	Trip.Specialist КАК Specialist,
	|	Trip.Specialist.Код КАК SpecialistName,
	|	Trip.Specialist.EMail КАК SpecialistEmail
	|ИЗ
	|	Документ.Trip КАК Trip
	|ГДЕ
	|	Trip.Ссылка = &Trip
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ParcelsДетали.СтрокаИнвойса.SoldTo КАК ParentCompany,
	|	TripParcels.Ссылка.Final,
	|	TripParcels.Parcel.WarehouseTo КАК WarehouseTo,
	|	TripParcels.Parcel,
	|	ParcelsДетали.СтрокаИнвойса.КостЦентр КАК КостЦентр
	|ПОМЕСТИТЬ ВТ
	|ИЗ
	|	Документ.Trip.Parcels КАК TripParcels
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
	|		ПО TripParcels.Parcel = ParcelsДетали.Ссылка
	|ГДЕ
	|	ParcelsДетали.СтрокаИнвойса.SoldTo.Leg7LegalEntityDetermining <> ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.ПустаяСсылка)
	|	И TripParcels.Ссылка = &Trip
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ.ParentCompany,
	|	ВТ.КостЦентр,
	|	МАКСИМУМ(AUsAndLegalEntities.Период) КАК Период
	|ПОМЕСТИТЬ ВТ_МаксимальныеДаты
	|ИЗ
	|	ВТ КАК ВТ
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.AUsAndLegalEntities КАК AUsAndLegalEntities
	|		ПО ВТ.ParentCompany = AUsAndLegalEntities.ParentCompany
	|			И ВТ.КостЦентр = AUsAndLegalEntities.AU
	|			И ВТ.Final >= AUsAndLegalEntities.Период
	|
	|СГРУППИРОВАТЬ ПО
	|	ВТ.ParentCompany,
	|	ВТ.КостЦентр
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_МаксимальныеДаты.ParentCompany,
	|	ВТ_МаксимальныеДаты.КостЦентр,
	|	AUsAndLegalEntities.LegalEntity
	|ПОМЕСТИТЬ ВТ_LegalEntity
	|ИЗ
	|	ВТ_МаксимальныеДаты КАК ВТ_МаксимальныеДаты
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.AUsAndLegalEntities КАК AUsAndLegalEntities
	|		ПО ВТ_МаксимальныеДаты.ParentCompany = AUsAndLegalEntities.ParentCompany
	|			И ВТ_МаксимальныеДаты.КостЦентр = AUsAndLegalEntities.AU
	|			И ВТ_МаксимальныеДаты.Период = AUsAndLegalEntities.Период
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ.Parcel,
	|	ВТ.WarehouseTo КАК DeliverTo,
	|	ВТ.ParentCompany,
	|	ВЫБОР
	|		КОГДА ВТ.ParentCompany.Leg7LegalEntityDetermining = ЗНАЧЕНИЕ(Перечисление.Leg7LegalEntityDetermining.DefaultLegalEntity)
	|			ТОГДА ВТ.ParentCompany.LegalEntityForLeg7
	|		ИНАЧЕ ВТ_LegalEntity.LegalEntity
	|	КОНЕЦ КАК LegalEntity
	|ПОМЕСТИТЬ результат
	|ИЗ
	|	ВТ КАК ВТ
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_LegalEntity КАК ВТ_LegalEntity
	|		ПО ВТ.ParentCompany = ВТ_LegalEntity.ParentCompany
	|			И ВТ.КостЦентр = ВТ_LegalEntity.КостЦентр
	|ГДЕ
	|	НЕ ВТ.ParentCompany.Lawson
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	результат.DeliverTo,
	|	результат.ParentCompany,
	|	результат.ParentCompany.PostalAddressForInvoiceAndSupportingDocuments КАК FinancialAddressEng,
	|	результат.ParentCompany.PostalAddressForInvoiceAndSupportingDocumentsRus КАК FinancialAddressRus,
	|	результат.LegalEntity,
	|	результат.ParentCompany.NameRus КАК ParentCompanyNameRus,
	|	результат.ParentCompany.Наименование КАК ParentCompanyNameEng,
	|	результат.ParentCompany.Код КАК ParentCompanyCode,
	|	результат.ParentCompany.Lawson КАК LawsonCompany,
	|	результат.LegalEntity.NameRus КАК LegalEntityNameRus,
	|	результат.LegalEntity.Наименование КАК LegalEntityNameEng,
	|	ParcelsДетали.СтрокаИнвойса.КодПоИнвойсу КАК PartNo,
	|	ВЫРАЗИТЬ(ParcelsДетали.СтрокаИнвойса.НаименованиеТовара КАК СТРОКА(500)) КАК DescriptionEng,
	|	результат.Parcel.LengthCM КАК LengthCM,
	|	результат.Parcel.WidthCM КАК WidthCM,
	|	результат.Parcel.HeightCM КАК HeightCM,
	|	результат.Parcel.GrossWeightKG КАК GrossWeightKG,
	|	TripFinalDestinations.ATA КАК DeliverToActualArrivalLocalTime
	|ИЗ
	|	результат КАК результат
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
	|		ПО результат.DeliverTo = TripFinalDestinations.WarehouseTo
	|			И результат.LegalEntity = TripFinalDestinations.LegalEntity
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
	|		ПО результат.Parcel = ParcelsДетали.Ссылка
	|ГДЕ
	|	TripFinalDestinations.Ссылка = &Trip";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Trip", Trip);
	
	Результат = Запрос.ВыполнитьПакет();
	
	ВыборкаTrip = Результат[0].Выбрать();
	ВыборкаTrip.Следующий();
	
	ТЗLegalEntities = Результат[5].Выгрузить();
	
	МассивLegalEntities = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТЗLegalEntities, "LegalEntity");
	
	НомерLE = 1;
	СтруктураОтбораLE = Новый Структура("LegalEntity");
	СтруктураОтбораDeliverTo = Новый Структура("DeliverTo");
	
	Для Каждого LegalEntity из МассивLegalEntities Цикл
		
		Если ТабличныйДокумент.ВысотаТаблицы > 0 Тогда
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;

		СтруктураОтбораLE.LegalEntity = LegalEntity;
		
		ТЗHeader = ТЗLegalEntities.Скопировать(СтруктураОтбораLE);
		
		РеквизитыLE = ТЗHeader[0];
		
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
		
		ТабличныйДокумент.Вывести(ОбластьМакетаHeader);
		
		//////////////////////////////////////////////////////////////////////////////
		// TableLine 
		ОбластьМакетаTableLine = Макет.ПолучитьОбласть("TableLine");
		
		МассивDeliverTo = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТЗHeader, "DeliverTo");

		Для Каждого DeliverTo из МассивDeliverTo Цикл 
			
			СтруктураОтбораDeliverTo.DeliverTo = DeliverTo;
			
			ТЗDeliverTo = ТЗHeader.Скопировать(СтруктураОтбораDeliverTo);
			
			СтрDeliverTo = ТЗDeliverTo[0];
			
			ОбластьМакетаTableLine.Параметры.TripNo = СокрЛП(ВыборкаTrip.TripNo);
			ОбластьМакетаTableLine.Параметры.PickUp = СокрЛП(ВыборкаTrip.PickUpWarehouse);
			ОбластьМакетаTableLine.Параметры.DeliverTo = СокрЛП(DeliverTo);
			ОбластьМакетаTableLine.Параметры.GrossWeight = СокрЛП(ТЗDeliverTo.Итог("GrossWeightKG"));
			ОбластьМакетаTableLine.Параметры.TimeOfDeparture = СокрЛП(ВыборкаTrip.ActualDepartureLocalTime);
			ОбластьМакетаTableLine.Параметры.TimeOfArrival = СокрЛП(СтрDeliverTo.DeliverToActualArrivalLocalTime);
			
			ТЗDimsLE = ТЗDeliverTo.Скопировать(, "LengthCM,WidthCM,HeightCM");
			ТЗDimsLE.Свернуть("LengthCM,WidthCM,HeightCM");
			
			ТЗItemsLE = ТЗDeliverTo.Скопировать(, "PartNo,DescriptionEng");
			ТЗItemsLE.Свернуть("PartNo,DescriptionEng");

			CargoDescription = "";
			сч = 1;
			Для Каждого СтрItemsLE из ТЗItemsLE Цикл 
				Если сч > 3 Тогда 
					Прервать;
				КонецЕсли;
				CargoDescription = СокрЛП(СтрItemsLE.PartNo) + ": " + СокрЛП(СтрItemsLE.DescriptionEng); 
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
			    						             						
			ТабличныйДокумент.Вывести(ОбластьМакетаTableLine);
			
		КонецЦикла;
		 		
		//////////////////////////////////////////////////////////////////////////////
		// Footer 
		ОбластьМакетаFooter = Макет.ПолучитьОбласть("Footer");
		
		ОбластьМакетаFooter.Параметры.SpecialistName = ВыборкаTrip.SpecialistName;
		ОбластьМакетаFooter.Параметры.SpecialistEmail = ВыборкаTrip.SpecialistEmail;
		
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
		Сообщить(СокрЛП(Trip) + ": Non-PO can be generated only for Non-Lawson companies!", СтатусСообщения.Внимание);
	КонецЕсли;
	
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

