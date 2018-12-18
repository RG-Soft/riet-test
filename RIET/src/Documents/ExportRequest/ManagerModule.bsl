
Функция ПолучитьExportToTMSПоExportRequest(ExportRequest) Экспорт
	
	// возвращает признак того, нужно ли выгружать ExportRequest в TMS, используя ссылку на ExportRequest
	
	Если НЕ ЗначениеЗаполнено(ExportRequest) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	РеквизитыExportRequest = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ExportRequest, 
		"FromCountry, Company, Submitted, LocalMOT, InternationalMOT, InternationalFreightProvider, Incoterms, BORG, CustomUnionTransaction, CreationDate");
	
	Возврат ПолучитьExportDomesticOBToTMS(РеквизитыExportRequest.Company, 
										  РеквизитыExportRequest.Submitted,
										  РеквизитыExportRequest.LocalMOT,
										  РеквизитыExportRequest.BORG,
										  РеквизитыExportRequest.CustomUnionTransaction)
		ИЛИ ПолучитьExportInternationalOBToTMS(РеквизитыExportRequest.FromCountry,
											   РеквизитыExportRequest.Company, 
											   РеквизитыExportRequest.Submitted, 
											   РеквизитыExportRequest.InternationalMOT,
											   РеквизитыExportRequest.InternationalFreightProvider,
											   РеквизитыExportRequest.Incoterms,
										       РеквизитыExportRequest.BORG,
										       РеквизитыExportRequest.CreationDate);
												
КонецФункции

Функция ПолучитьExportDomesticOBToTMS(ParentCompany, Submitted, LocalMOT, BORG, CustomUnionTransaction) Экспорт
	
	// возвращает признако того, нужно ли выгружать Domestic OB в TMS
	
	Если НЕ ЗначениеЗаполнено(ParentCompany) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ParentCompanyStartOfExportToTMS = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ParentCompany, "StartOfExportToTMS");
	Если НЕ ЗначениеЗаполнено(ParentCompanyStartOfExportToTMS) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	// Domestic OB не будет выгружаться для всех экпортных реквестов, где Local MOT is COURIER 	
	Если LocalMOT = Справочники.MOTs.COURIER Тогда
		Возврат Ложь;
	КонецЕсли;
	
	//проверим если заполнен BORG и он не должен выгружаться для parent co
	Если BORGНеДолженВыгружатьсявTCSДляParentCompany(BORG, ParentCompany) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	// если export request еще не submitted - считаем, что он новый, а новые export requests должны выгружаться в TMS
	Если НЕ ЗначениеЗаполнено(Submitted) Тогда
		Возврат Истина;	
	КонецЕсли;
	
	Если CustomUnionTransaction Тогда
		Возврат Ложь;
	КонецЕсли;

	Возврат Submitted >= ParentCompanyStartOfExportToTMS;
	
КонецФункции

Функция ПолучитьExportInternationalOBToTMS(FromCountry, ParentCompany, Submitted, InternationalMOT, InternationalFreightProvider, Incoterms, BORG, CreationDate) Экспорт
	
	// возвращает признак того, нужно ли выгружать International OB в TMS 
	
	Если НЕ ЗначениеЗаполнено(ParentCompany) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ParentCompanyStartOfExportToTMS = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ParentCompany, "StartOfExportToTMS");
	Если НЕ ЗначениеЗаполнено(ParentCompanyStartOfExportToTMS) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	//часть условий отменена для KZ с 01.10.2016
	FromCountryKZfrom2017 = (FromCountry = Справочники.CountriesOfProcessLevels.KZ И CreationDate > Дата('20161001'));
	
	// International OB не будет выгружаться для всех экпортных реквестов, где Int. MOT is COURIER  	
	Если (Не ЗначениеЗаполнено(InternationalMOT) ИЛИ InternationalMOT = Справочники.MOTs.COURIER) 
		И Не FromCountryKZfrom2017 Тогда
		Возврат Ложь;
	КонецЕсли;
	
	// Incoterms FCA не нужно отправлять в TMS
	Если Incoterms = Справочники.Incoterms.FCA И Не FromCountryKZfrom2017 Тогда 
		Возврат Ложь;
	КонецЕсли;
	
	//ВРЕМЕННО!!! Екатерина Брежнева напишет, когда удалить условие
	Если InternationalFreightProvider = Справочники.FreightForwarders.НайтиПоКоду("INTERCARGO") Тогда
		Возврат Ложь;
	КонецЕсли;
    //КОНЕЦ ВРЕМЕННОГО ДОБАВЛЕНИЯ!!!	
	
	//проверим если заполнен BORG и он не должен выгружаться для parent co
	Если BORGНеДолженВыгружатьсявTCSДляParentCompany(BORG, ParentCompany) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	// если export request еще не submitted - считаем, что он новый, а новые export requests должны выгружаться в TMS
	Если НЕ ЗначениеЗаполнено(Submitted) Тогда
		Возврат Истина;	
	КонецЕсли;
	
	Возврат Submitted >= ParentCompanyStartOfExportToTMS;
	         		
КонецФункции

Функция BORGНеДолженВыгружатьсявTCSДляParentCompany(BORG, ParentCompany)
	
	// BORGs 7D, 7S, 7F, 7R и parent company TCS RU
	//Возврат (СокрЛП(BORG) = "7D" 
	//		ИЛИ СокрЛП(BORG) = "7S"
	//		ИЛИ СокрЛП(BORG) = "7F"
	//		ИЛИ СокрЛП(BORG) = "7R")
	//		И СокрЛП(ParentCompany) = "TCS";
	
	Возврат Ложь;
	
КонецФункции

Функция OFSStoreTransactionsRequired(Segment, ExportPurpose) Экспорт 
	
	Если ExportPurpose = Справочники.ExportPurposes.OFS Тогда 
		
		SegmentCode = СокрЛП(Segment);
		
		Если SegmentCode = "SMIS" 
			ИЛИ SegmentCode = "SBIT"
			ИЛИ SegmentCode = "SDTR" тогда
			
			Возврат Ложь; 
			
		Иначе 
			
			Возврат Истина;
			
		КонецЕсли;
		   				
	КонецЕсли;
	
	Возврат Ложь; 	
	
КонецФункции

// { RGS DKazanskiy 02.08.2018 15:35:44 - S-I-0005748
Функция rgsПолучитьКоличествоВерсий(ER) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ERVersionsСрезПоследних.Version КАК Version
	|ИЗ
	|	РегистрСведений.ERVersions.СрезПоследних(, ER = &ER) КАК ERVersionsСрезПоследних";
	Запрос.УстановитьПараметр("ER", ER);
	Результат = Запрос.Выполнить().Выгрузить();
	Если Результат.Количество() > 0 Тогда
		Возврат Результат[0].Version;
	Иначе 
		Возврат Неопределено
	КонецЕсли;
	
КонецФункции

Функция rgsПолучитьАктуальнуюВерсию(ER) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	ERVersions.Version
		|ИЗ
		|	РегистрСведений.ERVersions КАК ERVersions
		|ГДЕ
		|	ERVersions.ER = &ER
		|
		|УПОРЯДОЧИТЬ ПО
		|	ERVersions.Период УБЫВ";
	
	Запрос.УстановитьПараметр("ER", ER);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат 0;
	КонецЕсли;
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	ВыборкаДетальныеЗаписи.Следующий();
	
	Возврат ВыборкаДетальныеЗаписи.Version;
	
КонецФункции

Функция rgsПолучитьМаксимальнуюВерсию(ER) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	ЕСТЬNULL(МАКСИМУМ(ERVersions.Version), 0) КАК Version
		|ИЗ
		|	РегистрСведений.ERVersions КАК ERVersions
		|ГДЕ
		|	ERVersions.ER = &ER";
	
	Запрос.УстановитьПараметр("ER", ER);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат 0;
	КонецЕсли;
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	ВыборкаДетальныеЗаписи.Следующий();
	
	Возврат ВыборкаДетальныеЗаписи.Version;
	
КонецФункции

Функция УстановитьДатыВерсии(ER, CCAGLReceived) Экспорт 
	
	Если НЕ ЗначениеЗаполнено(ER) или 
		ER.Ссылка.Пустая() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ДокОбъект = ER.ПолучитьОбъект();
	ДокОбъект.CCAGLReceived = CCAGLReceived;
	
	ДокОбъект.ОбменДанными.Загрузка = Истина;
	
	ДокОбъект.Записать(РежимЗаписиДокумента.Запись);
	
КонецФункции

Функция ПроверитьВерсию(ER, MOT, CCA, POD, CCAGLRequested) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ЗапросДатаИзменения = Новый Запрос;
	ЗапросДатаИзменения.Текст = "ВЫБРАТЬ
	|	ERVersionsСрезПоследних.Период КАК Период
	|ИЗ
	|	РегистрСведений.ERVersions.СрезПоследних(
	|			,
	|			ER = &ER
	|				И ИзменилсяСостав) КАК ERVersionsСрезПоследних
	|ГДЕ
	|	ERVersionsСрезПоследних.ИзменилсяСостав";
	ЗапросДатаИзменения.УстановитьПараметр("ER", ER);
	РезДатаИзменения = ЗапросДатаИзменения.Выполнить().Выгрузить();
	Если РезДатаИзменения.Количество()>0 Тогда
		ДатаНачалаСреза = РезДатаИзменения[0].Период; 
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ERVersions.ER КАК ER,
	               |	ERVersions.Version КАК Version,
	               |	ERVersions.CCAGLReceived
	               |ИЗ
	               |	РегистрСведений.ERVersions КАК ERVersions
	               |ГДЕ
	               |	ERVersions.CCA = &CCA
	               |	И ERVersions.MOT = &MOT
	               |	И ERVersions.ER = &ER
	               |	И ERVersions.POD = &POD
	               |	И ERVersions.CCAGLRequested = &CCAGLRequested";
	
	Запрос.УстановитьПараметр("ER", 				ER);
	Запрос.УстановитьПараметр("CCA", 				CCA);
	Запрос.УстановитьПараметр("MOT", 				MOT);
	Запрос.УстановитьПараметр("CCAGLRequested", 	CCAGLRequested);
	Запрос.УстановитьПараметр("POD", 				POD);
	
	Если РезДатаИзменения.Количество()>0 Тогда
		Запрос.УстановитьПараметр("Дата1", ДатаНачалаСреза);
		Запрос.УстановитьПараметр("Дата2", ТекущаяДата());
		Запрос.Текст = Запрос.Текст + " и ERVersions.Период МЕЖДУ &Дата1 И &Дата2 УПОРЯДОЧИТЬ ПО ERVersions.Период УБЫВ";
	Иначе
		Запрос.Текст = Запрос.Текст + " УПОРЯДОЧИТЬ ПО ERVersions.Период УБЫВ";
	КонецЕсли;
	
	Результат = Запрос.Выполнить();
	
	Ответ = Новый Структура("Empty, CCAGLReceived, ТекущаяВерсия");
	
	Если Результат.Пустой() Тогда
		Ответ.Empty 		= Истина;
		Ответ.CCAGLReceived = '00010101';
	Иначе
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Ответ.Empty    		= Ложь;
		Ответ.CCAGLReceived =  Выборка.CCAGLReceived;
		Ответ.ТекущаяВерсия = Выборка.Version;
	КонецЕсли;
	
	Возврат Ответ;
	
КонецФункции

// } RGS DKazanskiy 02.08.2018 15:35:46 - S-I-0005748

// ПЕЧАТНЫЕ ФОРМЫ

Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	               		
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "APPLICATIONTOTHEFORWARDER") тогда
		
		ТабДокумент = ПечатьПорученийЭкспедитору(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "APPLICATIONTOTHEFORWARDER",
				"APPLICATION TO THE FORWARDER", ТабДокумент);
				
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "CMR") тогда
		
		ТабДокумент = ПечатьCMR(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "CMR",
				"CMR", ТабДокумент);
	// { RGS DKazanskiy 22.10.2018 12:37:15 - S-I-0005759
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "FORMOFORDER") тогда
		
		ТабДокумент = ПечатьFormOfOrder(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "FORMOFORDER",
				"FORMOFORDER", ТабДокумент);
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "CERTIFICATEOFORIGIN") тогда
		
		ТабДокумент = ПечатьCertificateOfOrigin(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "CERTIFICATEOFORIGIN",
				"CERTIFICATEOFORIGIN", ТабДокумент);
		
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "CERTIFICATEOFQUALITY") тогда
		
		ТабДокумент = ПечатьCertificateOfQuality(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "CERTIFICATEOFQUALITY",
				"CERTIFICATEOFQUALITY", ТабДокумент);
	// } RGS DKazanskiy 22.10.2018 12:40:50 - S-I-0005759	
	КонецЕсли;

КонецПроцедуры

// ПОРУЧЕНИЕ ЭКСПЕДИТОРУ

Функция ПечатьПорученийЭкспедитору(МассивОбъектов, ОбъектыПечати) 
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	ParcelsДетали.Ссылка.ExportRequest.Company КАК ParentCompany,
	|	ParcelsДетали.Ссылка.ExportRequest.Company.NameRus КАК Consignor,
	|	ParcelsДетали.Ссылка.ExportRequest.Company.NameRus КАК Client,
	|	ParcelsДетали.Ссылка.ExportRequest.Номер КАК ExportRequestNumber,
	//|	ParcelsДетали.Ссылка.ExportRequest.LocalFreightApproved КАК LocalFreightApproved,
	|	ParcelsДетали.Ссылка.ExportRequest.InternationalFreightApproved КАК InternationalFreightApproved,
	|	ParcelsДетали.Ссылка.NumOfParcels КАК NumOfParcels,
	|	ParcelsДетали.Ссылка.GrossWeightKG КАК ParcelsGrossWeight,
	|	ParcelsДетали.Ссылка.CubicMeters КАК ParcelsCubicMeters,
	|	ParcelsДетали.Ссылка.PackingType,
	|	ParcelsДетали.Ссылка.ExportRequest.Consignee КАК Consignee,
	|	ВЫБОР
	|		КОГДА ParcelsДетали.Ссылка.ExportRequest.Consignee = ЗНАЧЕНИЕ(Справочник.Warehouses.Other)
	|			ТОГДА """"
	|		ИНАЧЕ ParcelsДетали.Ссылка.ExportRequest.Consignee.CountryCode
	|	КОНЕЦ КАК ConsigneeCountryCode,
	|	ВЫБОР
	|		КОГДА ParcelsДетали.Ссылка.ExportRequest.Consignee = ЗНАЧЕНИЕ(Справочник.Warehouses.Other)
	|			ТОГДА ParcelsДетали.Ссылка.ExportRequest.ConsigneeCompany
	|		ИНАЧЕ ParcelsДетали.Ссылка.ExportRequest.Consignee.Наименование
	|	КОНЕЦ КАК ConsigneeName,
	|	ВЫБОР
	|		КОГДА ParcelsДетали.Ссылка.ExportRequest.Consignee = ЗНАЧЕНИЕ(Справочник.Warehouses.Other)
	|			ТОГДА """"
	|		ИНАЧЕ ParcelsДетали.Ссылка.ExportRequest.Consignee.City
	|	КОНЕЦ КАК ConsigneeCity,
	|	ВЫБОР
	|		КОГДА ParcelsДетали.Ссылка.ExportRequest.Consignee = ЗНАЧЕНИЕ(Справочник.Warehouses.Other)
	|			ТОГДА ParcelsДетали.Ссылка.ExportRequest.ConsigneeAddress
	|		ИНАЧЕ ParcelsДетали.Ссылка.ExportRequest.Consignee.Address1
	|	КОНЕЦ КАК ConsigneeAddress1,
	|	ВЫБОР
	|		КОГДА ParcelsДетали.Ссылка.ExportRequest.Consignee = ЗНАЧЕНИЕ(Справочник.Warehouses.Other)
	|			ТОГДА """"
	|		ИНАЧЕ ParcelsДетали.Ссылка.ExportRequest.Consignee.Address2
	|	КОНЕЦ КАК ConsigneeAddress2,
	|	ВЫБОР
	|		КОГДА ParcelsДетали.Ссылка.ExportRequest.Consignee = ЗНАЧЕНИЕ(Справочник.Warehouses.Other)
	|			ТОГДА """"
	|		ИНАЧЕ ParcelsДетали.Ссылка.ExportRequest.Consignee.Address3
	|	КОНЕЦ КАК ConsigneeAddress3,
	|	ParcelsДетали.Ссылка.ExportRequest.LocalFreightProvider КАК LocalFreightProvider,
	|	ParcelsДетали.Ссылка.ExportRequest.LocalFreightProvider.NameRus КАК LocalForwarder,
	|	ParcelsДетали.Ссылка.ExportRequest.InternationalFreightProvider КАК InternationalFreightProvider,
	|	ParcelsДетали.Ссылка.ExportRequest.InternationalFreightProvider.NameRus КАК InternationalForwarder,
	|	ParcelsДетали.СтрокаИнвойса.СтранаПроисхождения.Наименование КАК CountyOfOrigin,
	|	ParcelsДетали.СтрокаИнвойса.ExportRequest.Comments КАК Comments,
	|	ParcelsДетали.СтрокаИнвойса.ExportRequest.LocalWarehouseTo КАК LocalWarehouseTo,
	|	ParcelsДетали.СтрокаИнвойса.ExportRequest.LocalWarehouseTo.AddressRus КАК LocalWarehouseToAddressRus,
	|	ParcelsДетали.СтрокаИнвойса.ExportRequest.PickUpWarehouse КАК PickUpWarehouse,
	|	ВЫБОР
	|		КОГДА ParcelsДетали.СтрокаИнвойса.ExportRequest.PickUpWarehouse = ЗНАЧЕНИЕ(Справочник.Warehouses.Other)
	|			ТОГДА ParcelsДетали.СтрокаИнвойса.ExportRequest.PickUpFromAddress
	|		ИНАЧЕ ParcelsДетали.СтрокаИнвойса.ExportRequest.PickUpWarehouse.AddressRus
	|	КОНЕЦ КАК PickUpWarehouseAddressRus,
	|	ParcelsДетали.Ссылка.LengthCM,
	|	ParcelsДетали.Ссылка.WidthCM,
	|	ParcelsДетали.Ссылка.HeightCM,
	|	ParcelsДетали.СтрокаИнвойса.Сумма КАК TotalPrice,
	|	ParcelsДетали.СтрокаИнвойса.МеждународныйКодТНВЭД КАК HTCCode,
	|	ParcelsДетали.Ссылка.ExportRequest.LocalATA КАК LocalATA,
	|	ParcelsДетали.Ссылка.ExportRequest.LocalMOT.Код КАК LocalMOT,
	|	ParcelsДетали.Ссылка.ExportRequest.InternationalMOT.Код КАК InternationalMOT,
	|	ParcelsДетали.Ссылка.ExportRequest.POA.Наименование КАК POAName,
	|	ParcelsДетали.Ссылка.ExportRequest,
	|	ParcelsДетали.Ссылка КАК Parcel
	|ИЗ
	|	Справочник.Parcels.Детали КАК ParcelsДетали
	|ГДЕ
	|	ParcelsДетали.Ссылка.ExportRequest В(&МассивОбъектов)
	|	И НЕ ParcelsДетали.Ссылка.Отменен";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("МассивОбъектов", МассивОбъектов);
	
	ТЗ = Запрос.Выполнить().Выгрузить();
	
	СтрокаЗначений = ТЗ[0];
	
	Макет = ПолучитьОбщийМакет("APPLICATIONTOTHEFORWARDER");
	
	ПроверкаПустыхНаименований(ТЗ);
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "APPLICATIONTOTHEFORWARDER";
	
	Макет = ПолучитьОбщийМакет("APPLICATIONTOTHEFORWARDER");
	
	ЗначенияДляIntИLocal = "Consignor,Client,ExportRequestNumber,Comments";
	
	Consignee = СокрЛП(СтрокаЗначений.ConsigneeName) 
		+ ?(ПустаяСтрока(СтрокаЗначений.ConsigneeCountryCode), "", ", " + СокрЛП(СтрокаЗначений.ConsigneeCountryCode))
		+ ?(ПустаяСтрока(СтрокаЗначений.ConsigneeCity), "", ", " + СокрЛП(СтрокаЗначений.ConsigneeCity))
		+ ", " + СокрЛП(СтрокаЗначений.ConsigneeAddress1)
		+ ?(ПустаяСтрока(СтрокаЗначений.ConsigneeAddress2), "", ", " + СокрЛП(СтрокаЗначений.ConsigneeAddress2))
		+ ?(ПустаяСтрока(СтрокаЗначений.ConsigneeAddress3), "", ", " + СокрЛП(СтрокаЗначений.ConsigneeAddress3));
	
	CountyOfOrigin = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(
		РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТЗ, "CountyOfOrigin"));
		
	LocalATA = Формат(СтрокаЗначений.LocalATA, "ДФ = ""dd.MM.yyyy""");
	
	HTCCodes = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(
		РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТЗ, "HTCCode"));
		
	ТЗParcels = ТЗ.Скопировать(, 
		"Parcel,PackingType,NumOfParcels,ParcelsGrossWeight,ParcelsCubicMeters,LengthCM,WidthCM,HeightCM");
	ТЗParcels.Свернуть("Parcel,PackingType,NumOfParcels,ParcelsGrossWeight,ParcelsCubicMeters,LengthCM,WidthCM,HeightCM");

	ParcelsGrossWeight = ТЗParcels.Итог("ParcelsGrossWeight");
	ParcelsCubicMeters = ТЗParcels.Итог("ParcelsCubicMeters");
	
	ItemsTotalPrice = ТЗ.Итог("TotalPrice");
	
	NumOfParcels_PackingType = "";
	ТЗPackingType = ТЗParcels.Скопировать(, "PackingType,NumOfParcels");
	ТЗPackingType.Свернуть("PackingType","NumOfParcels");
	Для Каждого Стр из ТЗPackingType Цикл 
		NumOfParcels_PackingType = NumOfParcels_PackingType + ?(NumOfParcels_PackingType = "", "", "; ")
			+ Стр.NumOfParcels + " " + СокрЛП(Стр.PackingType);	
	КонецЦикла;
	
	DimsPerParcel = "";
	ТЗDIMs = ТЗParcels.Скопировать(, "LengthCM,WidthCM,HeightCM,NumOfParcels");
	ТЗDIMs.Свернуть("LengthCM,WidthCM,HeightCM","NumOfParcels");
	Для Каждого Стр из ТЗDIMs Цикл 
		DimsPerParcel = DimsPerParcel + ?(DimsPerParcel = "", "", "; ") + Стр.NumOfParcels + " " 
		+ СокрЛП(Стр.LengthCM) + "x" + СокрЛП(Стр.WidthCM) + "x" + СокрЛП(Стр.HeightCM) + " CM";	
	КонецЦикла;
	
	// заполним DOMESTIC part
	
	НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
	ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
	ЗаполнитьЗначенияСвойств(ОбластьМакета.Параметры, СтрокаЗначений, ЗначенияДляIntИLocal);
	
	//ОбластьМакета.Параметры.DOCDate = СтрокаЗначений.LocalFreightApproved;
	ОбластьМакета.Параметры.DOCNo = СокрЛП(СтрокаЗначений.ExportRequestNumber) + "/L";
	ОбластьМакета.Параметры.Consignee = Consignee;
	ОбластьМакета.Параметры.Forwarder = СокрЛП(СтрокаЗначений.LocalForwarder);
	ОбластьМакета.Параметры.CountyOfOrigin = CountyOfOrigin;
	ОбластьМакета.Параметры.GoodsReadyForShipmentPlaceDate = СокрЛП(ТЗParcels.Итог("NumOfParcels")) + "," 
		+ СокрЛП(СтрокаЗначений.PickUpWarehouseAddressRus) + "," + СокрЛП(LocalATA);
	ОбластьМакета.Параметры.TransporationType = СокрЛП(СтрокаЗначений.LocalMOT);
	ОбластьМакета.Параметры.PointOfDestination = СокрЛП(СтрокаЗначений.LocalWarehouseToAddressRus);
	ОбластьМакета.Параметры.Insurance = "Not Applicable";
	ОбластьМакета.Параметры.HTCCodes = HTCCodes;
	ОбластьМакета.Параметры.ParcelsGrossWeight = ParcelsGrossWeight;
	ОбластьМакета.Параметры.ParcelsCubicMeters = ParcelsCubicMeters;
	ОбластьМакета.Параметры.ItemsTotalPrice = ItemsTotalPrice;
	ОбластьМакета.Параметры.NumOfParcels_PackingType = NumOfParcels_PackingType;
	ОбластьМакета.Параметры.DimsPerParcel = DimsPerParcel;
	
	ТабличныйДокумент.Вывести(ОбластьМакета);
	
	УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, СтрокаЗначений.ExportRequest);
	
	// заполним INTERNATIONAL part
		
	ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
	НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
	ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
	ЗаполнитьЗначенияСвойств(ОбластьМакета.Параметры, СтрокаЗначений, ЗначенияДляIntИLocal);
	
	ОбластьМакета.Параметры.DOCDate = СтрокаЗначений.InternationalFreightApproved;
	ОбластьМакета.Параметры.DOCNo = СокрЛП(СтрокаЗначений.ExportRequestNumber) + "/I";
	ОбластьМакета.Параметры.Consignee = Consignee;
	ОбластьМакета.Параметры.Forwarder = СокрЛП(СтрокаЗначений.InternationalForwarder);
	ОбластьМакета.Параметры.CountyOfOrigin = CountyOfOrigin;
	ОбластьМакета.Параметры.GoodsReadyForShipmentPlaceDate = СокрЛП(ТЗParcels.Итог("NumOfParcels")) + ","
		+ СокрЛП(СтрокаЗначений.LocalWarehouseToAddressRus) + "," + СокрЛП(LocalATA);
	ОбластьМакета.Параметры.TransporationType = СокрЛП(СтрокаЗначений.InternationalMOT);
	ОбластьМакета.Параметры.PointOfDestination = СокрЛП(СтрокаЗначений.POAName);
	ОбластьМакета.Параметры.Insurance = "Not Applicable";
	ОбластьМакета.Параметры.HTCCodes = HTCCodes;
	ОбластьМакета.Параметры.ParcelsGrossWeight = ParcelsGrossWeight;
	ОбластьМакета.Параметры.ParcelsCubicMeters = ParcelsCubicMeters;
	ОбластьМакета.Параметры.ItemsTotalPrice = ItemsTotalPrice;
	ОбластьМакета.Параметры.NumOfParcels_PackingType = NumOfParcels_PackingType;
	ОбластьМакета.Параметры.DimsPerParcel = DimsPerParcel;
	
	ТабличныйДокумент.Вывести(ОбластьМакета);
	
	УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, СтрокаЗначений.ExportRequest);
	
	
	Возврат ТабличныйДокумент;
	
КонецФункции

Процедура ПроверкаПустыхНаименований(ТЗ)
	
	// Parent company
	ТЗПустыхClient = ТЗ.скопировать(Новый Структура("Client", ""), "ParentCompany,Client");
	ТЗПустыхClient.Свернуть("ParentCompany,Client");
	Для Каждого Стр из ТЗПустыхClient Цикл 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"For Parent company '" + СокрЛП(Стр.ParentCompany) + "' name (rus) is empty!"
		, Стр.ParentCompany);
	КонецЦикла;
	
	// Consignee
	ТЗПустыхConsigneeCity = ТЗ.скопировать(Новый Структура("ConsigneeCity", ""), "Consignee,ConsigneeCity");
	ТЗПустыхConsigneeCity.Свернуть("Consignee,ConsigneeCity");
	Для Каждого Стр из ТЗПустыхConsigneeCity Цикл 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"For Consignee '" + СокрЛП(Стр.Consignee) + "' city is empty!"
		, Стр.Consignee);
	КонецЦикла;
	
	ТЗПустыхConsigneeAddress1 = ТЗ.скопировать(Новый Структура("ConsigneeAddress1", ""), "Consignee,ConsigneeAddress1");
	ТЗПустыхConsigneeAddress1.Свернуть("Consignee,ConsigneeAddress1");
	Для Каждого Стр из ТЗПустыхConsigneeAddress1 Цикл 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"For Consignee '" + СокрЛП(Стр.Consignee) + "' address 1 is empty!"
		, Стр.Consignee);
	КонецЦикла;
	
	// Local Freight Provider
	ТЗПустыхLocalForwarderName = ТЗ.скопировать(Новый Структура("LocalForwarder", ""), "LocalFreightProvider,LocalForwarder");
	ТЗПустыхLocalForwarderName.Свернуть("LocalFreightProvider,LocalForwarder");
	Для Каждого Стр из ТЗПустыхLocalForwarderName Цикл 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"For Local Freight Provider '" + СокрЛП(Стр.LocalFreightProvider) + "' name (rus) is empty!"
		, Стр.LocalFreightProvider);
	КонецЦикла;
	
	// International Freight Provider
	ТЗПустыхIntForwarderName = ТЗ.скопировать(Новый Структура("InternationalForwarder", ""), "InternationalFreightProvider,InternationalForwarder");
	ТЗПустыхIntForwarderName.Свернуть("InternationalFreightProvider,InternationalForwarder");
	Для Каждого Стр из ТЗПустыхIntForwarderName Цикл 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"For International Freight Provider '" + СокрЛП(Стр.InternationalFreightProvider) + "' name (rus) is empty!"
		, Стр.InternationalFreightProvider);
	КонецЦикла;
	
	// PickUp Warehouse
	ТЗПустыхPickUpWarehouseAddresses = ТЗ.скопировать(Новый Структура("PickUpWarehouseAddressRus", ""), "PickUpWarehouse,PickUpWarehouseAddressRus");
	ТЗПустыхPickUpWarehouseAddresses.Свернуть("PickUpWarehouse,PickUpWarehouseAddressRus");
	Для Каждого Стр из ТЗПустыхPickUpWarehouseAddresses Цикл 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"For Pick Up Warehouse '" + СокрЛП(Стр.PickUpWarehouse) + "' address (rus) is empty!"
		, Стр.PickUpWarehouse);
	КонецЦикла;
	
	// Local WarehouseTo
	ТЗПустыхLocalWarehouseToAddress = ТЗ.скопировать(Новый Структура("LocalWarehouseToAddressRus", ""), "LocalWarehouseTo,LocalWarehouseToAddressRus");
	ТЗПустыхLocalWarehouseToAddress.Свернуть("LocalWarehouseTo,LocalWarehouseToAddressRus");
	Для Каждого Стр из ТЗПустыхLocalWarehouseToAddress Цикл 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"For Local Warehouse To '" + СокрЛП(Стр.LocalWarehouseTo) + "' address (rus) is empty!"
		, Стр.LocalWarehouseTo);
	КонецЦикла;
	
КонецПроцедуры

// CMR

Функция ПечатьCMR(МассивОбъектов, ОбъектыПечати) 
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "CMR";
	
	Макет = ПолучитьМакет("CMR");
	
	Для Каждого ExportRequest из МассивОбъектов Цикл 
		
		ТекстОшибок = "";	
		
		ТекстЗапроса = 
		"ВЫБРАТЬ
		|	Parcels.ExportRequest.Номер КАК ERNumber,
		|	Parcels.ExportRequest.Company.NameRus КАК CompanyNameRus,
		|	Parcels.ExportRequest.FromLegalEntity КАК LegalEntity,
		|	ВЫРАЗИТЬ(Parcels.ExportRequest.FromLegalEntity.SoldToAddressRus КАК СТРОКА(500)) КАК LegalEntityAddressRus,
		|	Parcels.ExportRequest.FromLegalEntity.NameRus КАК LegalEntityNameRus,
		|	Parcels.ExportRequest.Consignee КАК Consignee,
		|	Parcels.ExportRequest.Consignee.AddressRus КАК ConsigneeAddressRus,
		|	Parcels.ExportRequest.Consignee.NameRus КАК ConsigneeNameRus,
		|	Parcels.ExportRequest.ConsigneeContact КАК ConsigneeContact,
		|	Parcels.ExportRequest.ConsigneePhone КАК ConsigneePhone,
		|	Parcels.ExportRequest.DeliverTo КАК DeliverTo,
		|	Parcels.ExportRequest.DeliverTo.AddressRus КАК DeliverToAddressRus,
		|	Parcels.ExportRequest.DeliverTo.RCACountry.Наименование КАК DeliverToRCACountryName,
		|	Parcels.ExportRequest.PickUpWarehouse.City КАК PickUpCity,
		|	Parcels.ExportRequest.PickUpWarehouse.RCACountry.Наименование КАК PickUpRCACountryName,
		|	Parcels.ExportRequest.RequiredDeliveryDate КАК RequiredDeliveryDate,
		|	Parcels.ExportRequest.InternationalFreightProvider КАК InternationalFreightProvider,
		|	Parcels.ExportRequest.InternationalFreightProvider.NameRus КАК IntProviderNameRus,
		|	СУММА(Parcels.NumOfParcels) КАК NumOfParcels,
		|	СУММА(Parcels.GrossWeightKG) КАК ParcelsGrossWeight,
		|	СУММА(Parcels.CubicMeters) КАК ParcelsCubicMeters
		|ИЗ
		|	Справочник.Parcels КАК Parcels
		|ГДЕ
		|	Parcels.ExportRequest.Ссылка = &ExportRequest
		|	И НЕ Parcels.ПометкаУдаления
		|
		|СГРУППИРОВАТЬ ПО
		|	Parcels.ExportRequest.Номер,
		|	Parcels.ExportRequest.Company.NameRus,
		|	Parcels.ExportRequest.FromLegalEntity,
		|	ВЫРАЗИТЬ(Parcels.ExportRequest.FromLegalEntity.SoldToAddressRus КАК СТРОКА(500)),
		|	Parcels.ExportRequest.FromLegalEntity.NameRus,
		|	Parcels.ExportRequest.Consignee,
		|	Parcels.ExportRequest.Consignee.AddressRus,
		|	Parcels.ExportRequest.Consignee.NameRus,
		|	Parcels.ExportRequest.ConsigneeContact,
		|	Parcels.ExportRequest.ConsigneePhone,
		|	Parcels.ExportRequest.DeliverTo,
		|	Parcels.ExportRequest.DeliverTo.AddressRus,
		|	Parcels.ExportRequest.DeliverTo.RCACountry.Наименование,
		|	Parcels.ExportRequest.PickUpWarehouse.City,
		|	Parcels.ExportRequest.PickUpWarehouse.RCACountry.Наименование,
		|	Parcels.ExportRequest.RequiredDeliveryDate,
		|	Parcels.ExportRequest.InternationalFreightProvider,
		|	Parcels.ExportRequest.InternationalFreightProvider.NameRus
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВЫРАЗИТЬ(СтрокиИнвойса.НаименованиеТовара КАК СТРОКА(500)) КАК DescriptionEng,
		|	СУММА(ParcelsДетали.Qty) КАК Qty,
		|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ParcelsДетали.QtyUOM.NameRus) КАК QtyUOMNameRus,
		|	СтрокиИнвойса.СерийныйНомер,
		|	МАКСИМУМ(ParcelsДетали.Ссылка.PackingType.CodeRus) КАК PackingTypeCodeRus
		|ИЗ
		|	Справочник.Parcels.Детали КАК ParcelsДетали
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
		|		ПО ParcelsДетали.СтрокаИнвойса = СтрокиИнвойса.Ссылка
		|ГДЕ
		|	ParcelsДетали.Ссылка.ExportRequest = &ExportRequest
		|
		|СГРУППИРОВАТЬ ПО
		|	СтрокиИнвойса.СерийныйНомер,
		|	ВЫРАЗИТЬ(СтрокиИнвойса.НаименованиеТовара КАК СТРОКА(500))
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ExportRequestПрисоединенныеФайлы.Наименование КАК Attachment
		|ИЗ
		|	Справочник.ExportRequestПрисоединенныеФайлы КАК ExportRequestПрисоединенныеФайлы
		|ГДЕ
		|	НЕ ExportRequestПрисоединенныеФайлы.ПометкаУдаления
		|	И ExportRequestПрисоединенныеФайлы.ВладелецФайла = &ExportRequest";
		
		Запрос = Новый Запрос(ТекстЗапроса);
		Запрос.УстановитьПараметр("ExportRequest", ExportRequest);
		
		Результат = Запрос.ВыполнитьПакет();
		
		ВыборкаER = Результат[0].Выбрать();
		ВыборкаER.Следующий();
		
		ТЗItems = Результат[1].Выгрузить();
		ТЗAttachments = Результат[2].Выгрузить();
		            		
		Если ТабличныйДокумент.ВысотаТаблицы > 0 Тогда
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
		
		/////////////////////////////////////////////////////////////////////
		// Header
		ОбластьМакетаHeader = Макет.ПолучитьОбласть("Header");
		        				
		ЗаполнитьЗначенияСвойств(ОбластьМакетаHeader.Параметры, ВыборкаER); 
		
		ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Legal entity name(Rus)", СокрЛП(ВыборкаER.LegalEntityNameRus));
		ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Legal entity address(Rus)", СокрЛП(ВыборкаER.LegalEntityAddressRus));
		
		ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Consignee name(Rus)", СокрЛП(ВыборкаER.ConsigneeNameRus));
		ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Consignee address(Rus)", СокрЛП(ВыборкаER.ConsigneeAddressRus));
		
		ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "Deliver-to address(Rus)", СокрЛП(ВыборкаER.DeliverToAddressRus));
		
		ДобавитьЕслиНеЗаполненРеквизит(ТекстОшибок, "International Freight name (Rus)", СокрЛП(ВыборкаER.IntProviderNameRus));
		
		//////////////////////////////////////////////////////////////////////////////
		// Item 
		
		Descriptions = "";
		Для Каждого СтрTRLE из ТЗItems Цикл 
			
			Descriptions = "
			|" + СокрЛП(СтрTRLE.DescriptionEng) + ", " + СокрЛП(СтрTRLE.Qty) + " " 
			+ СокрЛП(СтрTRLE.QtyUOMNameRus) +"Серийный номер: " + СокрЛП(СтрTRLE.СерийныйНомер);
			
		КонецЦикла;
		
		ОбластьМакетаHeader.Параметры.Description = СокрЛП(Descriptions);
		
		ОбластьМакетаHeader.Параметры.PackingTypesCodeRus = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(
		РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТЗItems, "PackingTypeCodeRus"),", ");
		
		ОбластьМакетаHeader.Параметры.Attachments = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(
		РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТЗAttachments, "Attachment"),", ");
		
		ТабличныйДокумент.Вывести(ОбластьМакетаHeader);
		
		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, ExportRequest);
		
		
		Если ЗначениеЗаполнено(ТекстОшибок) Тогда
			Сообщить(СокрЛП(ExportRequest)+ ": 
			|" + СокрЛП(ТекстОшибок));
		КонецЕсли;
		
	КонецЦикла;  //ER
	
	Возврат ТабличныйДокумент;
	
КонецФункции

// FORM OF ORDER
Функция ПечатьFormOfOrder(МассивОбъектов, ОбъектыПечати) 
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "CMR";
	
	Макет = ПолучитьМакет("FormOfOrder");
	
	Для Каждого ExportRequest из МассивОбъектов Цикл
		
		Если ТабличныйДокумент.ВысотаТаблицы > 0 Тогда
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		Шапка 			= Макет.ПолучитьОбласть("Шапка");
		СтрокаТаблицы 	= Макет.ПолучитьОбласть("Строка");
		Подвал 			= Макет.ПолучитьОбласть("Подвал");
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Ссылка", ExportRequest);
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ExportRequest.CreationDate КАК ДатаСоздания,
		|	ExportRequest.ExportContract.Номер КАК НомерДоговора,
		|	ExportRequest.ExportContract.Дата КАК ДатаДоговора,
		|	ExportRequest.Номер КАК НомерЗаказа,
		|	ExportRequest.ConsigneeCompany,
		|	ExportRequest.ConsigneeAddress,
		|	ExportRequest.ConsigneeContact,
		|	ExportRequest.ConsigneePhone,
		|	ExportRequest.ConsigneeEmail,
		|	ExportRequest.DeliverToCompany,
		|	ExportRequest.DeliverToAddress,
		|	ExportRequest.DeliverToContact,
		|	ExportRequest.DeliverToPhone,
		|	ExportRequest.DeliverToEmail,
		|	ExportRequest.RequiredDeliveryDate КАК СрокПоставки,
		|	ExportRequest.InternationalMOT КАК СпособДоставки,
		|	ExportRequest.Incoterms КАК УсловияПоставки,
		|	ExportRequest.Incoterms КАК УсловияПоставкиRUS,
		|	ExportRequest.Consignee.Address1,
		|	ExportRequest.Consignee.Address2,
		|	ExportRequest.Consignee.Address3,
		|	ExportRequest.DeliverTo.Address1,
		|	ExportRequest.DeliverTo.Address3,
		|	ExportRequest.DeliverTo.Address2,
		|	ExportRequest.InternationalMOT.Наименование КАК СпособДоставкиRus,
		|	ExportRequest.InternationalFreightSum КАК СтоимостьТранспортировки,
		|	ExportRequest.InternationalFreightCurrency,
		|	ExportRequest.City КАК Город,
		|	ExportRequest.City КАК ГородEng,
		|	ExportRequest.Consignee,
		|	ExportRequest.DeliverTo
		|ИЗ
		|	Документ.ExportRequest КАК ExportRequest
		|ГДЕ
		|	ExportRequest.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СтрокиИнвойса.DescriptionRus,
		|	ВЫРАЗИТЬ(СтрокиИнвойса.НаименованиеТовара КАК СТРОКА(1024)) КАК DescriptionEng,
		|	СтрокиИнвойса.КодПоИнвойсу КАК Артикул,
		|	СУММА(СтрокиИнвойса.Количество) КАК Количество,
		|	СтрокиИнвойса.ЕдиницаИзмерения,
		|	СтрокиИнвойса.Цена,
		|	СтрокиИнвойса.Currency,
		|	СУММА(СтрокиИнвойса.Сумма) КАК Сумма
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК СтрокиИнвойса
		|ГДЕ
		|	СтрокиИнвойса.ExportRequest = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	СтрокиИнвойса.DescriptionRus,
		|	СтрокиИнвойса.КодПоИнвойсу,
		|	СтрокиИнвойса.ЕдиницаИзмерения,
		|	СтрокиИнвойса.Цена,
		|	СтрокиИнвойса.Currency,
		|	ВЫРАЗИТЬ(СтрокиИнвойса.НаименованиеТовара КАК СТРОКА(1024))";
		
		Результат = Запрос.ВыполнитьПакет();
		
		РезультатШапка = Результат[0].Выбрать();
		
		РезультатШапка.Следующий();
		
		Шапка.Параметры.Заполнить(РезультатШапка);
		
		Шапка.Параметры.ДатаСоздания = Формат(РезультатШапка.ДатаСоздания, "Л=ru_RU; ДЛФ=DD");
		Шапка.Параметры.ДатаСозданияEng = Формат(РезультатШапка.ДатаСоздания, "Л=en; ДЛФ=DD");
		
		Шапка.Параметры.ДатаДоговора    = Формат(РезультатШапка.ДатаДоговора, "Л=ru_RU; ДЛФ=DD");
		Шапка.Параметры.ДатаДоговораEng = Формат(РезультатШапка.ДатаДоговора, "Л=en; ДЛФ=DD");
		
		ТабличныйДокумент.Вывести(Шапка);
		
		// формируем табличную часть 
		РезультатСтроки = Результат[1].Выбрать();
		
		Тоталь = РезультатШапка.СтоимостьТранспортировки;
		
		Счетчик = 1;
		Пока РезультатСтроки.Следующий() Цикл
			
			СтрокаТаблицы.Параметры.Заполнить(РезультатСтроки);
			СтрокаТаблицы.Параметры.НомерПП = Формат(Счетчик, "ЧГ=0");
			СтрокаТаблицы.Параметры.НаименованиеТовара = РезультатСтроки.DescriptionEng + "//" + РезультатСтроки.DescriptionRus;
			
			Тоталь = Тоталь + РезультатСтроки.Сумма;
			
			ТабличныйДокумент.Вывести(СтрокаТаблицы);
			Счетчик = Счетчик + 1;
		КонецЦикла;
		
		// Подвал
		Подвал.Параметры.Заполнить(РезультатШапка);
		
		Подвал.Параметры.СрокПоставки = "до " + Формат(РезультатШапка.СрокПоставки, "Л=ru_RU; ДЛФ=DD") + "\before " + Формат(РезультатШапка.СрокПоставки, "Л=en; ДЛФ=DD");
		Подвал.Параметры.Грузополучатель = СокрЛП(РезультатШапка.Consignee) + Символы.ПС +	
										  СокрЛП(РезультатШапка.ConsigneeAddress1) + Символы.ПС +	
										  СокрЛП(РезультатШапка.ConsigneeAddress2) + Символы.ПС	+
										  СокрЛП(РезультатШапка.ConsigneeAddress3);
										  
		Подвал.Параметры.МестоДоставки   = СокрЛП(РезультатШапка.DeliverTo) + Символы.ПС +
										  СокрЛП(РезультатШапка.DeliverToAddress1) + Символы.ПС +	
										  СокрЛП(РезультатШапка.DeliverToAddress2) + Символы.ПС	+
										  СокрЛП(РезультатШапка.DeliverToAddress3);
										  
		Подвал.Параметры.Итого = Тоталь;										  
										  
		ТабличныйДокумент.Вывести(Подвал);
		
	КонецЦикла; 
	
	Возврат ТабличныйДокумент;
КонецФункции

// CERTIFICATE OF ORIGIN
Функция ПечатьCertificateOfOrigin(МассивОбъектов, ОбъектыПечати) 
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "CERTIFICATEOFORIGIN";
	ТабличныйДокумент.АвтоМасштаб = Истина;
	ТабличныйДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Портрет;
	
	Макет = ПолучитьМакет("СертификатПроисхожденияДляТуркменистана");
	
	Для Каждого ExportRequest из МассивОбъектов Цикл
		
		Если ТабличныйДокумент.ВысотаТаблицы > 0 Тогда
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		Шапка 			= Макет.ПолучитьОбласть("Шапка");
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Ссылка", ExportRequest);
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ExportRequest.CreationDate КАК ДатаСоздания,
		|	ExportRequest.ExportContract.Номер КАК НомерДоговора,
		|	ExportRequest.ExportContract.Дата КАК ДатаДоговора,
		|	ExportRequest.Номер КАК НомерЗаказа,
		|	ExportRequest.ConsigneeCompany,
		|	ExportRequest.ConsigneeAddress,
		|	ExportRequest.ConsigneeContact,
		|	ExportRequest.ConsigneePhone,
		|	ExportRequest.ConsigneeEmail,
		|	ExportRequest.DeliverToCompany,
		|	ExportRequest.DeliverToAddress,
		|	ExportRequest.DeliverToContact,
		|	ExportRequest.DeliverToPhone,
		|	ExportRequest.DeliverToEmail,
		|	ExportRequest.RequiredDeliveryDate КАК СрокПоставки,
		|	ExportRequest.InternationalMOT КАК СпособДоставки,
		|	ExportRequest.Incoterms КАК УсловияПоставки,
		|	ExportRequest.Incoterms КАК УсловияПоставкиRUS,
		|	ExportRequest.Consignee.Address1,
		|	ExportRequest.Consignee.Address2,
		|	ExportRequest.Consignee.Address3,
		|	ExportRequest.DeliverTo.Address1,
		|	ExportRequest.DeliverTo.Address3,
		|	ExportRequest.DeliverTo.Address2,
		|	ExportRequest.InternationalMOT.Наименование КАК СпособДоставкиRus,
		|	ExportRequest.InternationalFreightSum КАК СтоимостьТранспортировки,
		|	ExportRequest.InternationalFreightCurrency,
		|	ExportRequest.InternationalMOT КАК MOT,
		|	ExportRequest.Consignee,
		|	ExportRequest.DeliverTo
		|ИЗ
		|	Документ.ExportRequest КАК ExportRequest
		|ГДЕ
		|	ExportRequest.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СУММА(СтрокиИнвойса.Количество) КАК ItemNumber,
		|	МАКСИМУМ(СтрокиИнвойса.СтранаПроисхождения) КАК CountryOfOrigin
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК СтрокиИнвойса
		|ГДЕ
		|	СтрокиИнвойса.ExportRequest = &Ссылка";
		
		Результат = Запрос.ВыполнитьПакет();
		
		РезультатШапка = Результат[0].Выбрать();
		
		РезультатШапка.Следующий();
		
		Шапка.Параметры.Заполнить(РезультатШапка);
		
		Шапка.Параметры.InvoiceDate = "dd " + Формат(ТекущаяДата(), "Л=en; ДФ=dd.MM.yyyy");	
		Шапка.Параметры.InvoiceNo   = СокрЛП(Сред(РезультатШапка.НомерЗаказа, СтрНайти(РезультатШапка.НомерЗаказа, "-") + 1, 10));
		Шапка.Параметры.Invoice 	= "Invoice № " + СокрЛП(РезультатШапка.НомерЗаказа) + " dd " + Формат(РезультатШапка.ДатаСоздания, "Л=en; ДФ=dd.MM.yyyy");
		Шапка.Параметры.Consignee	= СокрЛП(РезультатШапка.Consignee) + Символы.ПС +
										  СокрЛП(РезультатШапка.ConsigneeAddress1) + Символы.ПС +	
										  СокрЛП(РезультатШапка.ConsigneeAddress2) + Символы.ПС	+
										  СокрЛП(РезультатШапка.ConsigneeAddress3);
		// формируем табличную часть 
		РезультатСтроки = Результат[1].Выбрать();
		
		Тоталь = РезультатШапка.СтоимостьТранспортировки;
		
		Счетчик = 1;
		Если РезультатСтроки.Следующий() Тогда
			
			Шапка.Параметры.Заполнить(РезультатСтроки);
		КонецЕсли;
		
		ТабличныйДокумент.Вывести(Шапка);
		
	КонецЦикла; 
	
	Возврат ТабличныйДокумент;
КонецФункции

//Certificate of quality

Функция ПечатьCertificateOfQuality(МассивОбъектов, ОбъектыПечати) 
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "CERTIFICATEOFQUALITY";
	ТабличныйДокумент.АвтоМасштаб = Истина;
	ТабличныйДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Портрет;
	
	Макет = ПолучитьМакет("СертификатКачества");
	
	Для Каждого ExportRequest из МассивОбъектов Цикл
		
		Если ТабличныйДокумент.ВысотаТаблицы > 0 Тогда
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		Шапка 			= Макет.ПолучитьОбласть("Шапка");
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Ссылка", ExportRequest);
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ExportRequest.CreationDate КАК ДатаСоздания,
		|	ExportRequest.ExportContract.Номер КАК НомерДоговора,
		|	ExportRequest.ExportContract.Дата КАК ДатаДоговора,
		|	ExportRequest.Номер КАК НомерЗаказа,
		|	ExportRequest.ConsigneeCompany,
		|	ExportRequest.ConsigneeAddress,
		|	ExportRequest.ConsigneeContact,
		|	ExportRequest.ConsigneePhone,
		|	ExportRequest.ConsigneeEmail,
		|	ExportRequest.DeliverToCompany,
		|	ExportRequest.DeliverToAddress,
		|	ExportRequest.DeliverToContact,
		|	ExportRequest.DeliverToPhone,
		|	ExportRequest.DeliverToEmail,
		|	ExportRequest.RequiredDeliveryDate КАК СрокПоставки,
		|	ExportRequest.InternationalMOT КАК СпособДоставки,
		|	ExportRequest.Incoterms КАК УсловияПоставки,
		|	ExportRequest.Incoterms КАК УсловияПоставкиRUS,
		|	ExportRequest.Consignee.Address1,
		|	ExportRequest.Consignee.Address2,
		|	ExportRequest.Consignee.Address3,
		|	ExportRequest.DeliverTo.Address1,
		|	ExportRequest.DeliverTo.Address3,
		|	ExportRequest.DeliverTo.Address2,
		|	ExportRequest.InternationalMOT.Наименование КАК СпособДоставкиRus,
		|	ExportRequest.InternationalFreightSum КАК СтоимостьТранспортировки,
		|	ExportRequest.InternationalFreightCurrency,
		|	ExportRequest.InternationalMOT КАК MOT,
		|	ExportRequest.Company.Наименование КАК ParentCompany,
		|	ExportRequest.Company.Код как ФирменныйБланк
		|ИЗ
		|	Документ.ExportRequest КАК ExportRequest
		|ГДЕ
		|	ExportRequest.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СУММА(СтрокиИнвойса.Количество) КАК ItemNumber,
		|	МАКСИМУМ(СтрокиИнвойса.СтранаПроисхождения) КАК CountryOfOrigin
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК СтрокиИнвойса
		|ГДЕ
		|	СтрокиИнвойса.ExportRequest = &Ссылка";
		
		Результат = Запрос.ВыполнитьПакет();
		
		РезультатШапка = Результат[0].Выбрать();
		
		РезультатШапка.Следующий();
		
		Если ЗначениеЗаполнено(РезультатШапка.ФирменныйБланк) Тогда
			СоответствиеБланков = Новый Соответствие();
			СоответствиеБланков.Вставить("EPU", "EPU");
			СоответствиеБланков.Вставить("PA", "SCP");
			СоответствиеБланков.Вставить("SCP", "SCP");
			СоответствиеБланков.Вставить("SLI RU", "SLI");
			СоответствиеБланков.Вставить("SLI-SMI RU", "SLI");
			СоответствиеБланков.Вставить("TCS", "TCS");
			СоответствиеБланков.Вставить("TCS-MI-RU", "TCS");
			СоответствиеБланков.Вставить("TOEZGP", "TOEZGP");
			СоответствиеБланков.Вставить("TPG", "TPG");
			
			ИмяМакета = СоответствиеБланков.Получить(СокрЛП(РезультатШапка.ФирменныйБланк));
			
			Если НЕ ИмяМакета = Неопределено Тогда	
				ТабличныйДокумент.Вывести(Макет.ПолучитьОбласть(ИмяМакета));
			КонецЕсли;
			
		КонецЕсли;
		
		Шапка.Параметры.Заполнить(РезультатШапка);
		
		Шапка.Параметры.CurrentDate = "dd " + Формат(ТекущаяДата(), "Л=en; ДФ=dd.MM.yyyy");	
		//Шапка.Параметры.InvoiceNo   = СокрЛП(Сред(РезультатШапка.НомерЗаказа, СтрНайти(РезультатШапка.НомерЗаказа, "-") + 1, 10));
		Шапка.Параметры.Invoice 	= "Invoice № " + СокрЛП(РезультатШапка.НомерЗаказа) + " dd " + Формат(РезультатШапка.ДатаСоздания, "Л=en; ДФ=dd.MM.yyyy");
		//Шапка.Параметры.Consignee	= СокрЛП(РезультатШапка.ConsigneeAddress1) + Символы.ПС +	
		//								  СокрЛП(РезультатШапка.ConsigneeAddress2) + Символы.ПС	+
		//								  СокрЛП(РезультатШапка.ConsigneeAddress3);
		// формируем табличную часть 
		РезультатСтроки = Результат[1].Выбрать();
		
		Тоталь = РезультатШапка.СтоимостьТранспортировки;
		
		Счетчик = 1;
		Если РезультатСтроки.Следующий() Тогда
			
			Шапка.Параметры.Заполнить(РезультатСтроки);
		КонецЕсли;
		
		ТабличныйДокумент.Вывести(Шапка);
		
	КонецЦикла; 
	
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

