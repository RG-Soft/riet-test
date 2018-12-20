
#Если Сервер Или ВнешнееСоединение Тогда 

// Функция готовит таблицу данных для трекинга
// Параметры:
// 		ImportTrackingMainFilter - Тип фильтра, выбранный на форме
// 		ImportTrackingDateFrom(To) - интевал времени (опционально)
//
Функция ПолучитьТаблицуДанных(ImportTrackingMainFilter, 
		ImportTrackingMainFilterValue 	= Неопределено,
		ImportTrackingDateFilter 		= Неопределено,
		ImportTrackingDateFrom			= Неопределено,
		ImportTrackingDateTo			= Неопределено, 
		Country							= Неопределено, 
		Variant 						= "", 
		ВладелецВарианта				= Неопределено, 
		ДопФильтры						= Неопределено,
		// { RGS AARsentev 04.04.2018 S-I-0004271
		Массив_AU_BORGs_POs					= Неопределено,
		// } RGS AARsentev 04.04.2018 S-I-0004271
		ValueInList = Ложь) Экспорт
	
	Запрос = Новый Запрос;
	
	ТекстУсловияItem = "";
	// Установим основной фильтр
	ImportTrackingMainFilters = Перечисления.ImportTrackingMainFilters;
	Если ImportTrackingMainFilter = ImportTrackingMainFilters.PONo Тогда
		
		ТекстУсловияItem = ТекстУсловияItem + "
		// { RGS AArsentev 20.06.2018
		//|	Items.НомерЗаявкиНаЗакупку ПОДОБНО ""%"" + """ + ImportTrackingMainFilterValue + """ + ""%""";
		|	Items.НомерЗаявкиНаЗакупку В (&НомераЗаявок)";
		
		НомераЗаявок = Новый Массив;
		Если НЕ ValueInList Тогда
			НомераЗаявок.Добавить(ImportTrackingMainFilterValue);
		Иначе
			Для Каждого Элемент ИЗ Массив_AU_BORGs_POs Цикл
				НомераЗаявок.Добавить(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Элемент, "Код"));
			КонецЦикла;
		КонецЕсли;
		
		Запрос.УстановитьПараметр("НомераЗаявок", НомераЗаявок);
		// } RGS AArsentev 20.06.2018
		
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.PartNo Тогда
		
		ТекстУсловияItem = ТекстУсловияItem + "
		|	Items.КодПоИнвойсу ПОДОБНО ""%"" + """ + ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.InvoiceNo Тогда
		
		ТекстУсловияItem = ТекстУсловияItem + "
		|	Items.Инвойс.Номер ПОДОБНО ""%"" + """ + ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.DOCNo Тогда
		
		ТекстУсловияItem = ТекстУсловияItem + "
		|	DOCsInvoices.Ссылка.Номер ПОДОБНО ""%"" + """ + ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.CustomsFileNo Тогда
		
		ТекстУсловияItem = ТекстУсловияItem + "
		|	CustomsFilesOfItems.CustomsFile.Номер ПОДОБНО ""%"" + """ + ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.ShipmentWaybills Тогда
		
		ТекстУсловияItem = ТекстУсловияItem + "
		|	ShipmentsDOCs.Ссылка.WBList ПОДОБНО ""%"" + """ + ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.BORG Тогда
		
		// { RGS AARsentev 04.04.2018 S-I-0004271
		//Запрос.УстановитьПараметр("BORG", ImportTrackingMainFilterValue);
		//ТекстУсловияItem = ТекстУсловияItem + "
		//|	Items.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ = &BORG";
		Запрос.УстановитьПараметр("BORGs", Массив_AU_BORGs_POs);
		ТекстУсловияItem = ТекстУсловияItem + "
		|	Items.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ В (&BORGs)";
		// } RGS AARsentev 04.04.2018 S-I-0004271
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.SegmentCode Тогда
		
		ТекстУсловияItem = ТекстУсловияItem + "
		|	Items.КостЦентр.Segment.Код ПОДОБНО ""%"" + """ + ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.SerialNo Тогда
		
		ТекстУсловияItem = ТекстУсловияItem + "
		|	Items.СерийныйНомер ПОДОБНО ""%"" + """+ ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.ProjectMobilization Тогда
		
		Запрос.УстановитьПараметр("ProjectMobilization", ImportTrackingMainFilterValue);
		ТекстУсловияItem = ТекстУсловияItem + "
		|	Items.ProjectMobilization = &ProjectMobilization";
		
	// { RGS AARsentev 04.03.2018 S-I-0004271
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.CostCenter Тогда
		
		Запрос.УстановитьПараметр("AUs", Массив_AU_BORGs_POs);
		ТекстУсловияItem = ТекстУсловияItem + "
		|	Items.КостЦентр В (&AUs)";
	// } RGS AARsentev 04.03.2018 S-I-0004271
	КонецЕсли;
	
	// Установим дополнительный фильтр при необходимости
	Если НеобходимФильтрПоДатеДляImportTracking(ImportTrackingMainFilter) Тогда
		
		ImportTrackingDateFilters = Перечисления.ImportTrackingDateFilters;
		Если ImportTrackingDateFilter = ImportTrackingDateFilters.PODate Тогда
			
			ТекстУсловияItem = ТекстУсловияItem + "
			|	И Items.СтрокаЗаявкиНаЗакупку.Владелец.ДатаЗаявкиНаЗакупку >= &DateFrom
			|	И Items.СтрокаЗаявкиНаЗакупку.Владелец.ДатаЗаявкиНаЗакупку <= &DateTo";
			
		ИначеЕсли ImportTrackingDateFilter = ImportTrackingDateFilters.InvoiceDate Тогда
			
			ТекстУсловияItem = ТекстУсловияItem + "
			|	И Items.Инвойс.Дата >= &DateFrom
			|	И Items.Инвойс.Дата <= &DateTo";
			
		ИначеЕсли ImportTrackingDateFilter = ImportTrackingDateFilters.CollectedFromPortDate Тогда
			
			ТекстУсловияItem = ТекстУсловияItem + "
			|	И ShipmentsDOCs.Ссылка.CollectedFromPort >= &DateFrom
			|	И ShipmentsDOCs.Ссылка.CollectedFromPort <= &DateTo";
			
		КонецЕсли;
		
		Запрос.УстановитьПараметр("DateFrom", ImportTrackingDateFrom);
		Запрос.УстановитьПараметр("DateTo", ImportTrackingDateTo);
		
	КонецЕсли;
	 	
	///////
	// Условия для 
	ТекстУсловияPO = "";
	Если ImportTrackingMainFilter = ImportTrackingMainFilters.PONo Тогда
		
		ТекстУсловияPO = ТекстУсловияPO + "
		|	Items.Владелец.Код ПОДОБНО ""%"" + """ + ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.PartNo Тогда
		
		ТекстУсловияPO = ТекстУсловияPO + "
		|	Items.КодПоставщика ПОДОБНО ""%"" + """ + ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.BORG Тогда
		
		// { RGS AFokin 28.09.2018 23:59:59 - S-I-0006081
		//Запрос.УстановитьПараметр("BORG", ImportTrackingMainFilterValue);
		//ТекстУсловияPO = ТекстУсловияPO + "
		//|	Items.Владелец.БОРГ = &BORG";
		Запрос.УстановитьПараметр("BORGs", Массив_AU_BORGs_POs);
		ТекстУсловияPO = ТекстУсловияPO + "
		|	Items.Владелец.БОРГ  В (&BORGs)";
		// } RGS AFokin 28.09.2018 23:59:59 - S-I-0006081

	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.SegmentCode Тогда
		
		ТекстУсловияPO = ТекстУсловияPO + "
		|	Items.КостЦентр.Segment.Код ПОДОБНО ""%"" + """ + ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.ProjectMobilization Тогда
		
		Запрос.УстановитьПараметр("ProjectMobilization", ImportTrackingMainFilterValue);
		ТекстУсловияPO = ТекстУсловияPO + "
		|	Items.ProjectMobilization = &ProjectMobilization";
		
	КонецЕсли;
	
	Если НеобходимФильтрПоДатеДляImportTracking(ImportTrackingMainFilter) Тогда
		
		ImportTrackingDateFilters = Перечисления.ImportTrackingDateFilters;
		Если ImportTrackingDateFilter = ImportTrackingDateFilters.PODate Тогда
			
			ТекстУсловияPO = ТекстУсловияPO + "
			|	И Items.Владелец.ДатаЗаявкиНаЗакупку >= &DateFrom
			|	И Items.Владелец.ДатаЗаявкиНаЗакупку <= &DateTo";
			
		ИначеЕсли ImportTrackingDateFilter = ImportTrackingDateFilters.InvoiceDate 
			ИЛИ ImportTrackingDateFilter = ImportTrackingDateFilters.CollectedFromPortDate Тогда
			
			ТекстУсловияPO = " ЛОЖЬ ";
			
		КонецЕсли;
		
		Запрос.УстановитьПараметр("DateFrom", ImportTrackingDateFrom);
		Запрос.УстановитьПараметр("DateTo", ImportTrackingDateTo);
		
	КонецЕсли;
	
	ТекстУсловияMI = "";
	
	Если ImportTrackingMainFilter = ImportTrackingMainFilters.PartNo Тогда
		
		ТекстУсловияMI = ТекстУсловияMI + "
		|	ManualItems.Наименование ПОДОБНО ""%"" + """ + ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли ImportTrackingMainFilter = ImportTrackingMainFilters.ProjectMobilization Тогда
		
		Запрос.УстановитьПараметр("ProjectMobilization", ImportTrackingMainFilterValue);
		
		ТекстУсловияMI = ТекстУсловияMI + "
		|	ManualItems.Владелец = &ProjectMobilization";
	
	КонецЕсли;	
		
	//Если НеобходимФильтрПоДатеДляImportTracking(ImportTrackingMainFilter) Тогда
		//
		//ImportTrackingDateFilters = Перечисления.ImportTrackingDateFilters;
		//Если ImportTrackingDateFilter = ImportTrackingDateFilters.PODate Тогда
		//	
		//	ТекстУсловияMI = ТекстУсловияMI + "
		//	|	И Items.SupplierAvailability >= &DateFrom
		//	|	И Items.SupplierAvailability <= &DateTo";
		//				
		//КонецЕсли;
		//
		//Запрос.УстановитьПараметр("DateFrom", 	ImportTrackingDateFrom);
		//Запрос.УстановитьПараметр("DateTo", 	ImportTrackingDateTo);
		//
	//КонецЕсли;
	
	Если ПустаяСтрока(ТекстУсловияPO) Тогда
		ТекстУсловияPO = " ЛОЖЬ ";
	КонецЕсли;
	
	Если ПустаяСтрока(ТекстУсловияMI) Тогда
		ТекстУсловияMI = " ЛОЖЬ ";
	КонецЕсли;
		
	///////
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Items.Ссылка КАК Item,
	// { RGS AFokin 14.08.2018 23:59:59 S-I-0005834
	|	Items.СтранаПроисхождения КАК СтранаПроисхождения,
	// } RGS AFokin 14.08.2018 23:59:59 S-I-0005834
	|	Items.НомерЗаявкиНаЗакупку КАК PONo,
	|	Items.СтрокаЗаявкиНаЗакупку.Владелец.Поставщик КАК Supplier,
	|	Items.СтрокаЗаявкиНаЗакупку.Владелец.ДатаЗаявкиНаЗакупку КАК PODate,
	|	Items.СтрокаЗаявкиНаЗакупку.НомерСтрокиЗаявкиНаЗакупку КАК POLineNo,
	|	Items.СтрокаЗаявкиНаЗакупку.Количество КАК POLineQTY,
	|	Items.СтрокаЗаявкиНаЗакупку.Владелец.ShoppingCartNo КАК ShoppingCartNo,
	|	Items.СтрокаЗаявкиНаЗакупку.Владелец.Комментарий КАК RequisitionName,
	|	МАКСИМУМ(ParcelsДетали.Ссылка.HazardClass) КАК HazardClass,
	|	ВЫБОР
	|		КОГДА НЕ TripFinalDestinations.ATA ЕСТЬ NULL 
	|				И НЕ TripFinalDestinations.ATA = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Delivered to final destination""
	|		КОГДА НЕ TripFinalDestinations.ATA ЕСТЬ NULL 
	|				И TripFinalDestinations.ATA = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Local delivery""
	|		КОГДА НЕ ShipmentsDOCs.Ссылка ЕСТЬ NULL 
	|				И НЕ ShipmentsDOCs.Ссылка.CollectedFromPort = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Collected for local delivery""
	|		КОГДА НЕ DOCsInvoices.Ссылка ЕСТЬ NULL 
	|			ТОГДА ""Logistics/import processing""
	|		КОГДА НЕ ShipmentsDOCs.Ссылка ЕСТЬ NULL 
	|				И (ShipmentsDOCs.Ссылка.CurrentDocumentStage = ЗНАЧЕНИЕ(Перечисление.ShipmentDocumentStages.InCustoms)
	|					ИЛИ ShipmentsDOCs.Ссылка.CurrentDocumentStage = ЗНАЧЕНИЕ(Перечисление.ShipmentDocumentStages.Cleared))
	|			ТОГДА ""Customs processing""
	|		КОГДА НЕ ShipmentsDOCs.Ссылка ЕСТЬ NULL 
	|			ТОГДА ""Logistics/international transit""
	|		КОГДА НЕ Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Order at Supplier""
	|		КОГДА Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Order at Supplier""
	|	КОНЕЦ КАК StageGroupName,
	|	ВЫБОР
	|		КОГДА НЕ TripFinalDestinations.ATA ЕСТЬ NULL 
	|				И НЕ TripFinalDestinations.ATA = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Delivered to final destination""
	|		КОГДА НЕ TripFinalDestinations.ATA ЕСТЬ NULL 
	|				И TripFinalDestinations.ATA = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Local delivery""
	|		КОГДА НЕ ShipmentsDOCs.Ссылка ЕСТЬ NULL 
	|				И НЕ ShipmentsDOCs.Ссылка.CollectedFromPort = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Collected from port""
	|		КОГДА НЕ DOCsInvoices.Ссылка ЕСТЬ NULL 
	|			ТОГДА DOCsInvoices.Ссылка.CurrentStatus
	|		КОГДА НЕ ShipmentsDOCs.Ссылка ЕСТЬ NULL 
	|			ТОГДА ShipmentsDOCs.Ссылка.CurrentDocumentStage
	|		КОГДА НЕ Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Availability date confirmed by supplier""
	|		КОГДА Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Pending supplier confirmation""
	// { RGS DKazanskiy 17.12.2018 14:37:59 - S-I-0006321
	|		КОГДА DOCsInvoices.Ссылка.Отменен
	|			ТОГДА Items.СтрокаЗаявкиНаЗакупку.Status
	// } RGS DKazanskiy 17.12.2018 14:38:08 - S-I-0006321
	|	КОНЕЦ КАК StatusName,
	|	Items.Инвойс КАК Invoice,
	|	Items.Инвойс.Номер КАК InvoiceNo,
	|	Items.Количество КАК InvoiceLineQTY,
	|	Items.КостЦентр.Код КАК AU,
	|	Items.Активити КАК AC,
	|	Items.Сумма КАК InvoiceLineValue,
	|	Items.КодПоИнвойсу КАК PartNo,
	|	Items.ProjectMobilization КАК ProjectMobilization,
	|	ВЫРАЗИТЬ(Items.НаименованиеТовара КАК СТРОКА(1000)) КАК PartDescription,
	|	Items.СерийныйНомер КАК SerialNo,
	|	Items.КостЦентр.Segment.Код КАК SegmentCode,
	|	DOCsInvoices.Ссылка КАК DOC,
	|	DOCsInvoices.Ссылка.Номер КАК DOCNo,
	|	DOCsInvoices.Ссылка.POD.Код КАК PODCode,
	|	DOCsInvoices.Ссылка.RequestedPOA.Код КАК RequestedPOACode,
	|	DOCsInvoices.Ссылка.CurrentComment КАК DOCCurrentComment,
	|	DOCsInvoices.Ссылка.MOT.Код КАК MOTCode,
	|	DOCsInvoices.Ссылка.Дата КАК DOCDate,
	|	DOCsInvoices.Ссылка.Requested КАК GLRequested,
	|	DOCsInvoices.Ссылка.Received КАК GLReceived,
	|	DOCsInvoices.Ссылка.Granted КАК GLGranted,
	|	ShipmentsDOCs.Ссылка КАК Shipment,
	|	ShipmentsDOCs.Ссылка.ActualPOA.Код КАК ActualPOACode,
	|	ShipmentsDOCs.Ссылка.WBList КАК ShipmentWaybills,
	|	ВЫРАЗИТЬ(ShipmentsDOCs.Ссылка.CurrentComment КАК СТРОКА(1000)) КАК ShipmentCurrentComment,
	|	ShipmentsDOCs.Ссылка.PreAlert КАК PreAlert,
	|	ShipmentsDOCs.Ссылка.ETD КАК ETD,
	|	ShipmentsDOCs.Ссылка.ATD КАК ATD,
	|	ShipmentsDOCs.Ссылка.ETA КАК ETA,
	|	ShipmentsDOCs.Ссылка.ATA КАК ATA,
	|	ShipmentsDOCs.Ссылка.DoxRcvd КАК DoxRcvd,
	|	ShipmentsDOCs.Ссылка.InCustoms КАК InCustoms,
	|	ShipmentsDOCs.Ссылка.Cleared КАК Cleared,
	|	ShipmentsDOCs.Ссылка.CollectedFromPort КАК CollectedFromPort,
	|	CustomsFilesOfItems.CustomsFile КАК CustomsFile,
	|	CustomsFilesOfItems.CustomsFile.Номер КАК CustomsFileNo,
	|	CustomsFilesOfItems.CustomsFile.Regime.Код КАК CustomsRegimeCode,
	|	ЕСТЬNULL(DOCsParcels.Parcel.DeliveredToWH, ДАТАВРЕМЯ(1, 1, 1)) КАК DeliveredToWH,
	|	ЕСТЬNULL(TripParcels.Ссылка.ETD, ДАТАВРЕМЯ(1, 1, 1)) КАК LocalDistributionETD,
	|	ЕСТЬNULL(TripParcels.Ссылка.ATD, ДАТАВРЕМЯ(1, 1, 1)) КАК LocalDistributionATD,
	|	МАКСИМУМ(ЕСТЬNULL(TripFinalDestinations.ETA, ДАТАВРЕМЯ(1, 1, 1))) КАК LocalDistributionETA,
	|	МАКСИМУМ(ЕСТЬNULL(TripFinalDestinations.ATA, ДАТАВРЕМЯ(1, 1, 1))) КАК LocalDistributionATA,
	|	МАКСИМУМ(DOCsParcels.Parcel.WarehouseTo) КАК WarehouseTo,
	|	МИНИМУМ(ВЫБОР
	|			КОГДА DOCsParcels.Parcel ЕСТЬ NULL 
	|					ИЛИ DOCsParcels.Parcel.RDD = ДАТАВРЕМЯ(1, 1, 1)
	|				ТОГДА Items.СтрокаЗаявкиНаЗакупку.CurrentRDD
	|			ИНАЧЕ DOCsParcels.Parcel.RDD
	|		КОНЕЦ) КАК RDD,
	|	СУММА(ParcelsДетали.Qty) КАК Qty,
	|	Items.Цена КАК ItemValue,
	|	ЕСТЬNULL(Items.Сумма, 0) КАК TotalItemValue,
	|	СУММА(ЕСТЬNULL(ParcelsДетали.GrossWeightKG, 0)) КАК TotalGrossWeightKG,
	|	СУММА(ЕСТЬNULL(ParcelsДетали.GrossWeightKG, 0)) КАК GrossWeightKG,
	|	СУММА(0) КАК FreightCostPerKG,
	|	СУММА(0) КАК TotalFreightCost,
	|	"""" КАК Comments,
	|	МАКСИМУМ(ЛОЖЬ) КАК isManualItem
	|ПОМЕСТИТЬ XX
	|ИЗ
	|	Справочник.СтрокиИнвойса КАК Items
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК DOCsInvoices
	|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.Поставка.УпаковочныеЛисты КАК ShipmentsDOCs
	|			ПО DOCsInvoices.Ссылка = ShipmentsDOCs.УпаковочныйЛист
	|				И (НЕ ShipmentsDOCs.Ссылка.Отменен)
	|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Parcels КАК DOCsParcels
	|				ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
	|				ПО DOCsParcels.Parcel = ParcelsДетали.Ссылка
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.Trip.Parcels КАК TripParcels
	|					ЛЕВОЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
	|					ПО TripParcels.Ссылка = TripFinalDestinations.Ссылка
	|						И TripParcels.Parcel.WarehouseTo = TripFinalDestinations.WarehouseTo
	|				ПО DOCsParcels.Parcel = TripParcels.Parcel
	|			ПО DOCsInvoices.Ссылка = DOCsParcels.Ссылка
	|		ПО Items.Инвойс = DOCsInvoices.Инвойс
	// { RGS AArsentev 18.07.2018 S-I-0005650 - просили убрать в тикете, но затем AGryzunov попросил вернуть

	// { RGS DKazanskiy 17.12.2018 14:37:59 - S-I-0006321
	//|			И (НЕ DOCsInvoices.Ссылка.Отменен)
	// } RGS DKazanskiy 17.12.2018 14:38:08 - S-I-0006321
	
	// } RGS AArsentev 18.07.2018 S-I-0005650
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.CustomsFilesOfGoods КАК CustomsFilesOfItems
	|		ПО Items.Ссылка = CustomsFilesOfItems.Item
	|ГДЕ
	|	НЕ Items.ПометкаУдаления
	|	И &ТекстУсловияItem
	|	И Items.Ссылка = ЕСТЬNULL(ParcelsДетали.СтрокаИнвойса, Items.Ссылка)
	|
	|СГРУППИРОВАТЬ ПО
	|	Items.Ссылка,
	// { RGS AFokin 14.08.2018 23:59:59 S-I-0005834
	|	Items.СтранаПроисхождения,
	// } RGS AFokin 14.08.2018 23:59:59 S-I-0005834
	|	Items.НомерЗаявкиНаЗакупку,
	|	Items.СтрокаЗаявкиНаЗакупку.Владелец.ДатаЗаявкиНаЗакупку,
	|	Items.СтрокаЗаявкиНаЗакупку.Владелец.Поставщик,
	|	Items.СтрокаЗаявкиНаЗакупку.НомерСтрокиЗаявкиНаЗакупку,
	|	Items.СтрокаЗаявкиНаЗакупку.Количество,
	|	Items.СтрокаЗаявкиНаЗакупку.Владелец.ShoppingCartNo,
	|	Items.СтрокаЗаявкиНаЗакупку.Владелец.Комментарий,
	|	ВЫБОР
	|		КОГДА НЕ TripFinalDestinations.ATA ЕСТЬ NULL 
	|				И НЕ TripFinalDestinations.ATA = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Delivered to final destination""
	|		КОГДА НЕ TripFinalDestinations.ATA ЕСТЬ NULL 
	|				И TripFinalDestinations.ATA = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Local delivery""
	|		КОГДА НЕ ShipmentsDOCs.Ссылка ЕСТЬ NULL 
	|				И НЕ ShipmentsDOCs.Ссылка.CollectedFromPort = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Collected for local delivery""
	|		КОГДА НЕ DOCsInvoices.Ссылка ЕСТЬ NULL 
	|			ТОГДА ""Logistics/import processing""
	|		КОГДА НЕ ShipmentsDOCs.Ссылка ЕСТЬ NULL 
	|				И (ShipmentsDOCs.Ссылка.CurrentDocumentStage = ЗНАЧЕНИЕ(Перечисление.ShipmentDocumentStages.InCustoms)
	|					ИЛИ ShipmentsDOCs.Ссылка.CurrentDocumentStage = ЗНАЧЕНИЕ(Перечисление.ShipmentDocumentStages.Cleared))
	|			ТОГДА ""Customs processing""
	|		КОГДА НЕ ShipmentsDOCs.Ссылка ЕСТЬ NULL 
	|			ТОГДА ""Logistics/international transit""
	|		КОГДА НЕ Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Order at Supplier""
	|		КОГДА Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Order at Supplier""
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА НЕ TripFinalDestinations.ATA ЕСТЬ NULL 
	|				И НЕ TripFinalDestinations.ATA = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Delivered to final destination""
	|		КОГДА НЕ TripFinalDestinations.ATA ЕСТЬ NULL 
	|				И TripFinalDestinations.ATA = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Local delivery""
	|		КОГДА НЕ ShipmentsDOCs.Ссылка ЕСТЬ NULL 
	|				И НЕ ShipmentsDOCs.Ссылка.CollectedFromPort = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Collected from port""
	|		КОГДА НЕ DOCsInvoices.Ссылка ЕСТЬ NULL 
	|			ТОГДА DOCsInvoices.Ссылка.CurrentStatus
	|		КОГДА НЕ ShipmentsDOCs.Ссылка ЕСТЬ NULL 
	|			ТОГДА ShipmentsDOCs.Ссылка.CurrentDocumentStage
	|		КОГДА НЕ Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Availability date confirmed by supplier""
	|		КОГДА Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Pending supplier confirmation""
	// { RGS DKazanskiy 17.12.2018 14:37:59 - S-I-0006321
	|		КОГДА DOCsInvoices.Ссылка.Отменен
	|			ТОГДА Items.СтрокаЗаявкиНаЗакупку.Status
	// } RGS DKazanskiy 17.12.2018 14:38:08 - S-I-0006321
	|	КОНЕЦ,
	|	Items.Инвойс,
	|	Items.Инвойс.Номер,
	|	Items.ProjectMobilization,
	|	Items.Количество,
	|	Items.Сумма,
	|	Items.КостЦентр.Код,
	|	Items.Активити,
	|	Items.КодПоИнвойсу,
	|	ВЫРАЗИТЬ(Items.НаименованиеТовара КАК СТРОКА(1000)),
	|	Items.СерийныйНомер,
	|	Items.КостЦентр.Segment.Код,
	|	DOCsInvoices.Ссылка,
	|	DOCsInvoices.Ссылка.Номер,
	|	DOCsInvoices.Ссылка.POD.Код,
	|	DOCsInvoices.Ссылка.RequestedPOA.Код,
	|	DOCsInvoices.Ссылка.CurrentComment,
	|	DOCsInvoices.Ссылка.MOT.Код,
	|	DOCsInvoices.Ссылка.Дата,
	|	DOCsInvoices.Ссылка.Requested,
	|	DOCsInvoices.Ссылка.Received,
	|	DOCsInvoices.Ссылка.Granted,
	|	ShipmentsDOCs.Ссылка,
	|	ShipmentsDOCs.Ссылка.ActualPOA.Код,
	|	ShipmentsDOCs.Ссылка.WBList,
	|	ВЫРАЗИТЬ(ShipmentsDOCs.Ссылка.CurrentComment КАК СТРОКА(1000)),
	|	ShipmentsDOCs.Ссылка.PreAlert,
	|	ShipmentsDOCs.Ссылка.ETD,
	|	ShipmentsDOCs.Ссылка.ATD,
	|	ShipmentsDOCs.Ссылка.ETA,
	|	ShipmentsDOCs.Ссылка.ATA,
	|	ShipmentsDOCs.Ссылка.DoxRcvd,
	|	ShipmentsDOCs.Ссылка.InCustoms,
	|	ShipmentsDOCs.Ссылка.Cleared,
	|	ShipmentsDOCs.Ссылка.CollectedFromPort,
	|	CustomsFilesOfItems.CustomsFile,
	|	CustomsFilesOfItems.CustomsFile.Номер,
	|	CustomsFilesOfItems.CustomsFile.Regime.Код,
	|	ЕСТЬNULL(DOCsParcels.Parcel.DeliveredToWH, ДАТАВРЕМЯ(1, 1, 1)),
	|	ЕСТЬNULL(TripParcels.Ссылка.ETD, ДАТАВРЕМЯ(1, 1, 1)),
	|	ЕСТЬNULL(TripParcels.Ссылка.ATD, ДАТАВРЕМЯ(1, 1, 1)),
	|	Items.Цена,
	|	ЕСТЬNULL(Items.Сумма, 0)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	Items.Ссылка,
	// { RGS AFokin 14.08.2018 23:59:59 S-I-0005834
	|	ЕстьNull(Items.CountryOfOrigin, СтрокиИнвойса.СтранаПроисхождения),
	// } RGS AFokin 14.08.2018 23:59:59 S-I-0005834
	|	Items.Владелец.Код,
	|	Items.Владелец.Поставщик,
	|	Items.Владелец.ДатаЗаявкиНаЗакупку,
	|	Items.НомерСтрокиЗаявкиНаЗакупку,
	|	Items.Количество,
	|	Items.Владелец.ShoppingCartNo,
	|	Items.Владелец.Комментарий,
	|	NULL,
	|	ВЫБОР
	|		КОГДА НЕ Items.SupplierPromisedDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Order at Supplier""
	|		КОГДА Items.SupplierPromisedDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Order at Supplier""
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА НЕ Items.SupplierPromisedDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Availability date confirmed by supplier""
	|		КОГДА Items.SupplierPromisedDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Pending supplier confirmation""
	|	КОНЕЦ,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	Items.КодПоставщика,
	|	Items.ProjectMobilization,
	|	Items.Наименование,
	|	NULL,
	|	Items.КостЦентр.Segment.Код,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	Items.CurrentRDD,
	|	Items.Количество,
	|	Items.Цена,
	|	Items.Цена * Items.Количество,
	|	0,
	|	0,
	|	0,
	|	0,
	|	"""",
	|	ЛОЖЬ
	|ИЗ
	|	Справочник.СтрокиЗаявкиНаЗакупку КАК Items
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
	|		ПО Items.Ссылка = СтрокиИнвойса.СтрокаЗаявкиНаЗакупку
	|ГДЕ
	|	НЕ Items.ПометкаУдаления
	|	И &ТекстУсловияPO
	|	И СтрокиИнвойса.Ссылка ЕСТЬ NULL 
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ManualItems.Ссылка,
	// { RGS AFokin 14.08.2018 23:59:59 S-I-0005834
	|	NULL,
	// } RGS AFokin 14.08.2018 23:59:59 S-I-0005834
	|	NULL,
	|	ManualItems.Supplier,
	|	NULL,
	|	NULL,
	|	0,
	|	NULL,
	|	NULL,
	|	ManualItems.HazardClass,
	|	ВЫБОР
	|		КОГДА НЕ ManualItems.SupplierAvailability = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Order at Supplier""
	|		КОГДА ManualItems.SupplierAvailability = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Order at Supplier""
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА НЕ ManualItems.SupplierAvailability = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Availability date confirmed by supplier""
	|		КОГДА ManualItems.SupplierAvailability = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ""Pending supplier confirmation""
	|	КОНЕЦ,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	ManualItems.Наименование,
	|	ManualItems.Владелец,
	|	ManualItems.ItemDescription,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	ManualItems.POD.Код,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	ManualItems.RDD,
	|	ManualItems.Qty,
	|	ManualItems.ItemValue,
	|	ManualItems.TotalValue,
	|	ManualItems.TotalGrossWeightKG,
	|	ManualItems.GrossWeightKG,
	|	0,
	|	0,
	|	ManualItems.Comments,
	|	ИСТИНА
	|ИЗ
	|	Справочник.ProjectMobilizationManualItems КАК ManualItems
	|ГДЕ
	|	ManualItems.DomesticInternational = ЗНАЧЕНИЕ(Перечисление.DomesticInternational.International)
	|	И &ТекстУсловияMI
	|	И ManualItems.Item = ЗНАЧЕНИЕ(Справочник.СтрокиИнвойса.ПустаяСсылка)
	|	И ManualItems.POLine = ЗНАЧЕНИЕ(Справочник.СтрокиЗаявкиНаЗакупку.ПустаяСсылка)
	|	И НЕ ManualItems.ПометкаУдаления";
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ТекстУсловияItem", ТекстУсловияItem);
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ТекстУсловияMI", ТекстУсловияMI);
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ТекстУсловияPO", ТекстУсловияPO);
	
	//Если Country = Неопределено Тогда
	//	Запрос.Текст = СтрЗаменить(Запрос.Текст, "И выбор когда Items.Владелец.БОРГ = Значение(Справочник.BORGs.ПустаяСсылка) Тогда Истина иначе  Items.Владелец.БОРГ.Компания.Country = &Country Конец", "");
	//	Запрос.Текст = СтрЗаменить(Запрос.Текст, "И Items.SoldTo.Country = &Country", "");
	//КонецЕсли;
	
	// Установим фильтр по стране
	//Запрос.УстановитьПараметр("Country", Country);
	
	// добавим выборку для планирования в пакетный запрос
	Запрос.Текст = Запрос.Текст + "
	| ;
	| ВЫБРАТЬ
	|	ProjectMobilizationPlanningPerItemСрезПоследних.Item КАК Item,
	|	ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization как ProjectMobilization,
	|	МАКСИМУМ(ProjectMobilizationPlanningPerItemСрезПоследних.Период) КАК ModificationDate
	|ПОМЕСТИТЬ ПоследниеВарианты
	|ИЗ
	|	РегистрСведений.ProjectMobilizationPlanningPerItem.СрезПоследних КАК ProjectMobilizationPlanningPerItemСрезПоследних
	|
	|СГРУППИРОВАТЬ ПО
	|	ProjectMobilizationPlanningPerItemСрезПоследних.Item,
	|	ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization
	|;
	|
	|ВЫБРАТЬ
	|	XX.Item,
	// { RGS AFokin 14.08.2018 23:59:59 S-I-0005770
	|	XX.СтранаПроисхождения,
	// } RGS AFokin 14.08.2018 23:59:59 S-I-0005770
	|	XX.PONo,
	|	XX.Supplier,
	|	XX.PODate,
	|	XX.POLineNo,
	|	XX.POLineQTY,
	|	XX.ShoppingCartNo,
	|	XX.RequisitionName,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization ЕСТЬ NULL 
	|			ТОГДА XX.HazardClass
	|		ИНАЧЕ ProjectMobilizationPlanningPerItemСрезПоследних.HazardClass
	|	КОНЕЦ КАК HazardClass,
	|	XX.StageGroupName,
	|	XX.StatusName,
	|	XX.Invoice,
	|	XX.InvoiceNo,
	|	XX.InvoiceLineQTY,
	|	XX.AU,
	|	XX.AC,
	|	XX.InvoiceLineValue,
	|	XX.PartNo,
	|	XX.ProjectMobilization,
	|	XX.PartDescription,
	|	XX.SerialNo,
	|	XX.SegmentCode,
	|	XX.DOC,
	|	XX.DOCNo,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization ЕСТЬ NULL 
	|			ТОГДА XX.PODCode
	|		ИНАЧЕ ProjectMobilizationPlanningPerItemСрезПоследних.POD.Код
	|	КОНЕЦ КАК PODCode,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization ЕСТЬ NULL 
	|			ТОГДА XX.RequestedPOACode
	|		ИНАЧЕ ProjectMobilizationPlanningPerItemСрезПоследних.POA.Код
	|	КОНЕЦ КАК RequestedPOACode,
	|	XX.DOCCurrentComment,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization ЕСТЬ NULL 
	|			ТОГДА XX.MOTCode
	|		ИНАЧЕ ProjectMobilizationPlanningPerItemСрезПоследних.MOT.Код
	|	КОНЕЦ КАК MOTCode,
	|	XX.DOCDate,
	|	XX.GLRequested,
	|	XX.GLReceived,
	|	XX.GLGranted,
	|	XX.Shipment,
	|	XX.ActualPOACode,
	|	XX.ShipmentWaybills,
	|	XX.ShipmentCurrentComment,
	|	XX.PreAlert,
	|	XX.ETD,
	|	XX.ATD,
	|	XX.ETA,
	|	XX.ATA,
	|	XX.DoxRcvd,
	|	XX.InCustoms,
	|	XX.Cleared,
	|	XX.CollectedFromPort,
	|	XX.CustomsFile,
	|	XX.CustomsFileNo,
	|	XX.CustomsRegimeCode,
	|	XX.DeliveredToWH,
	|	XX.LocalDistributionETD,
	|	XX.LocalDistributionATD,
	|	XX.LocalDistributionETA,
	|	XX.LocalDistributionATA,
	|	XX.WarehouseTo,
	|	XX.RDD,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization ЕСТЬ NULL 
	|			ТОГДА XX.Qty
	|		ИНАЧЕ ProjectMobilizationPlanningPerItemСрезПоследних.Qty
	|	КОНЕЦ КАК Qty,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization ЕСТЬ NULL 
	|			ТОГДА XX.ItemValue
	|		ИНАЧЕ ProjectMobilizationPlanningPerItemСрезПоследних.ItemValue
	|	КОНЕЦ КАК ItemValue,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization ЕСТЬ NULL 
	|			ТОГДА XX.TotalItemValue
	|		ИНАЧЕ ProjectMobilizationPlanningPerItemСрезПоследних.TotalItemValue
	|	КОНЕЦ КАК TotalItemValue,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization ЕСТЬ NULL 
	|			ТОГДА XX.TotalGrossWeightKG
	|		ИНАЧЕ ProjectMobilizationPlanningPerItemСрезПоследних.TotalGrossWeightKG
	|	КОНЕЦ КАК TotalGrossWeightKG,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization ЕСТЬ NULL 
	|			ТОГДА XX.GrossWeightKG
	|		ИНАЧЕ ProjectMobilizationPlanningPerItemСрезПоследних.GrossWeightKG
	|	КОНЕЦ КАК GrossWeightKG,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization ЕСТЬ NULL 
	|			ТОГДА XX.FreightCostPerKG
	|		ИНАЧЕ ProjectMobilizationPlanningPerItemСрезПоследних.FreightCostPerKG
	|	КОНЕЦ КАК FreightCostPerKG,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationPlanningPerItemСрезПоследних.Comments ЕСТЬ NULL 
	|			ТОГДА XX.Comments
	|		ИНАЧЕ ProjectMobilizationPlanningPerItemСрезПоследних.Comments
	|	КОНЕЦ КАК Comments,
	|	XX.isManualItem,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization ЕСТЬ NULL 
	|			ТОГДА XX.TotalFreightCost
	|		ИНАЧЕ ProjectMobilizationPlanningPerItemСрезПоследних.TotalFreightCost
	|	КОНЕЦ КАК TotalFreightCost,
	|	XX.isManualItem,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization ЕСТЬ NULL 
	|			ТОГДА ЛОЖЬ
	|		ИНАЧЕ ИСТИНА
	|	КОНЕЦ КАК isPlanData
	|ИЗ
	|	XX КАК XX
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ProjectMobilizationPlanningPerItem.СрезПоследних КАК ProjectMobilizationPlanningPerItemСрезПоследних";
	
	Если НЕ ЗначениеЗаполнено(Variant) Тогда
	Запрос.Текст = Запрос.Текст + "
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ПоследниеВарианты КАК ПоследниеВарианты
		|		ПО ProjectMobilizationPlanningPerItemСрезПоследних.Item = ПоследниеВарианты.Item
		|			И ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization = ПоследниеВарианты.ProjectMobilization
		|			И ProjectMobilizationPlanningPerItemСрезПоследних.Период = ПоследниеВарианты.ModificationDate";
	КонецЕсли;
	
	Запрос.Текст = Запрос.Текст + "
	|		ПО XX.Item = ProjectMobilizationPlanningPerItemСрезПоследних.Item
	|			И XX.ProjectMobilization = ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization
	|			#УсловиеПользователя
	|			#УсловиеВарианта";
	
	Если НЕ ДопФильтры = Неопределено Тогда
		
		ФильтрПоСтатусу = ДопФильтры.Статус;
		ЗначенияФильтра = Новый Массив;
		ПредУсловие = "";
		Если ФильтрПоСтатусу.ВидСравнения = "Equal" Или ФильтрПоСтатусу.ВидСравнения = "Not equal" Тогда
			ЗначенияФильтра.Добавить(ФильтрПоСтатусу.ЗначениеСтрока);
		Иначе
			ЗначенияФильтра = ФильтрПоСтатусу.ЗначениеСписок.ВыгрузитьЗначения();
		КонецЕсли;
		
		Если СтрНайти(ФильтрПоСтатусу.ВидСравнения, "Not") <> 0 Тогда
			ПредУсловие = " НЕ ";
		КонецЕсли;
		
		Запрос.Текст = Запрос.Текст + "
		|	ГДЕ
		|		" + ПредУсловие + "Выразить(XX.StatusName КАК Строка(50)) В (&ЗначенияФильтраПоСтатусу)";
		
		Запрос.УстановитьПараметр("ЗначенияФильтраПоСтатусу", ЗначенияФильтра);
		
	КонецЕсли;
	
	Запрос.Текст = Запрос.Текст + "
	|	
	|УПОРЯДОЧИТЬ ПО
	|	XX.PODate,
	|	XX.PONo,
	|	XX.POLineNo
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	XX.Invoice, 
	|	МАКСИМУМ(естьNuLL(XX.Invoice.Фрахт, 0)) КАК InvoiceФрахт,
	|	СУММА(естьNULL(ParcelsДетали.GrossWeightKG, 0)) КАК GrossWeightKG
	|ИЗ
	|	XX КАК XX
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
	|	ПО XX.Invoice = ParcelsДетали.СтрокаИнвойса.Инвойс
	|СГРУППИРОВАТЬ ПО
	|	XX.Invoice";
	
	УстановитьПривилегированныйРежим(Истина);
	
	//таблица = ПолучитьСтруктуруХраненияБазыДанных();
	
	Если ЗначениеЗаполнено(ВладелецВарианта) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "#УсловиеПользователя", "И (&User = ProjectMobilizationPlanningPerItemСрезПоследних.User)");
	Иначе
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "#УсловиеПользователя", "");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Variant) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "#УсловиеВарианта", "И (&Variant = ProjectMobilizationPlanningPerItemСрезПоследних.Variant)");
	Иначе
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "#УсловиеВарианта", "");
	КонецЕсли;
	
	Запрос.УстановитьПараметр("User", ВладелецВарианта);
	Запрос.УстановитьПараметр("Variant", Variant);
		
	
	РезультатПакета = Запрос.ВыполнитьПакет();
	
	РезультатОсновной = РезультатПакета[2].Выгрузить();
	
	РезультатФрахт 	  = РезультатПакета[3].Выгрузить(); 
	
	Для каждого текСтрФрахт из РезультатФрахт Цикл
		
		Если текСтрФрахт.GrossWeightKG = 0 или текСтрФрахт.InvoiceФрахт = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		строкиОсновнойТаблицы = РезультатОсновной.НайтиСтроки(Новый Структура("Invoice", текСтрФрахт.Invoice));
		
		Для каждого текСтр из строкиОсновнойТаблицы Цикл
			
			//Если текСтр.isPlanData Тогда
			//	Продолжить;
			//КонецЕсли;
			
			текСтр.FreightCostPerKG = текСтрФрахт.InvoiceФрахт / текСтрФрахт.GrossWeightKG;
			текСтр.TotalFreightCost = текСтр.TotalGrossWeightKG * текСтр.FreightCostPerKG;
			
		КонецЦикла;
		
	КонецЦикла;
	
	//Возврат Запрос.Выполнить().Выгрузить();
	
	Возврат РезультатОсновной;
	
КонецФункции

Функция ПолучитьТаблицуДанныхDomestic(DomesticTrackingMainFilter, 
		DomesticTrackingMainFilterValue = Неопределено,
		DomesticTrackingDateFilter 		= Неопределено,
		DomesticTrackingDateFrom		= Неопределено,
		DomesticTrackingDateTo			= Неопределено, 
		Country							= Неопределено,
		Variant 						= "", 
		ВладелецВарианта				= Неопределено,
		ДопФильтры						= Неопределено,
		// { RGS AARsentev 04.04.2018 S-I-0004271
		МассивAU = Неопределено
		// } RGS AARsentev 04.04.2018 S-I-0004271
		)   Экспорт 
	                         	
	Запрос = Новый Запрос;
	
	ТекстУсловия = "";
	FilterMI = "";
	
	// Установим основной фильтр
	DomesticTrackingMainFilters = Перечисления.DomesticPlanningMainFilters;
	Если DomesticTrackingMainFilter = DomesticTrackingMainFilters.TransportRequestNo Тогда
		
		ТекстУсловия = ТекстУсловия + "
		|	StagesOfTransportRequests.TransportRequest.Номер = """ + DomesticTrackingMainFilterValue + """";
		
	ИначеЕсли DomesticTrackingMainFilter = DomesticTrackingMainFilters.PartNo Тогда
		
		ТекстУсловия = ТекстУсловия + "
		|	Items.СтрокаИнвойса.КодПоИнвойсу ПОДОБНО ""%"" + """ + DomesticTrackingMainFilterValue + """ + ""%""";
		
		FilterMI = FilterMI + "
		|	ProjectMobilizationManualItems.Наименование ПОДОБНО ""%"" + """ + DomesticTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли DomesticTrackingMainFilter = DomesticTrackingMainFilters.TripNo Тогда
		
		ТекстУсловия = ТекстУсловия + "
		|	Trips.Ссылка.Номер = """ + DomesticTrackingMainFilterValue + """";
		
	ИначеЕсли DomesticTrackingMainFilter = DomesticTrackingMainFilters.SegmentCode Тогда
		
		ТекстУсловия = ТекстУсловия + "
		|	StagesOfTransportRequests.TransportRequest.CostCenter.Segment.Код ПОДОБНО ""%"" + """ + DomesticTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли DomesticTrackingMainFilter = DomesticTrackingMainFilters.RequestorAlias Тогда
		
		ТекстУсловия = ТекстУсловия + "
		|	StagesOfTransportRequests.TransportRequest.Requestor.Код ПОДОБНО ""%"" + """ + DomesticTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли DomesticTrackingMainFilter = DomesticTrackingMainFilters.ProjectMobilization Тогда
		
		Запрос.УстановитьПараметр("ProjectMobilization", DomesticTrackingMainFilterValue);
		ТекстУсловия = ТекстУсловия + "
		|	StagesOfTransportRequests.TransportRequest.ProjectMobilization = &ProjectMobilization";
		
		FilterMI = FilterMI + "
		|	ProjectMobilizationManualItems.Владелец = &ProjectMobilization";
	// { RGS AARsentev 04.03.2018 S-I-0004271
	ИначеЕсли DomesticTrackingMainFilter = DomesticTrackingMainFilters.CostCenter Тогда
	
		Запрос.УстановитьПараметр("AUs", МассивAU);
		ТекстУсловия = ТекстУсловия + "
		|	StagesOfTransportRequests.TransportRequest.CostCenter В (&AUs)";
	// } RGS AARsentev 04.03.2018 S-I-0004271
	КонецЕсли;
	
	// Установим дополнительный фильтр при необходимости
	Если НеобходимФильтрПоДатеДляDomesticTracking(DomesticTrackingMainFilter) Тогда
		
		DomesticTrackingDateFilters = Перечисления.DomesticTrackingDateFilters;
		Если DomesticTrackingDateFilter = DomesticTrackingDateFilters.TransportRequestDate Тогда
			
			ТекстУсловия = ТекстУсловия + "
			|	И StagesOfTransportRequests.TransportRequest.Дата >= &DateFrom
			|	И StagesOfTransportRequests.TransportRequest.Дата <= &DateTo";
			
			FilterMI = "";

		ИначеЕсли DomesticTrackingDateFilter = DomesticTrackingDateFilters.TripDate Тогда
			
			ТекстУсловия = ТекстУсловия + "
			|	И Trips.Ссылка.Дата >= &DateFrom
			|	И Trips.Ссылка.Дата <= &DateTo";
			
			FilterMI = "";

		ИначеЕсли DomesticTrackingDateFilter = DomesticTrackingDateFilters.ReadyToShip Тогда
			
			ТекстУсловия = ТекстУсловия + "
			|	И StagesOfTransportRequests.TransportRequest.ReadyToShipLocalTime >= &DateFrom
			|	И StagesOfTransportRequests.TransportRequest.ReadyToShipLocalTime <= &DateTo";
			
			Если FilterMI <> "" Тогда 
				FilterMI = FilterMI + "
				|	И ProjectMobilizationManualItems.ReadyToShip >= &DateFrom
				|	И ProjectMobilizationManualItems.ReadyToShip <= &DateTo";
			КонецЕсли;
				
		КонецЕсли;
		
		Запрос.УстановитьПараметр("DateFrom", DomesticTrackingDateFrom);
		Запрос.УстановитьПараметр("DateTo", DomesticTrackingDateTo);
		
	КонецЕсли;
	
		
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	StagesOfTransportRequests.TransportRequest КАК TransportRequest,
	|	Items.СтрокаИнвойса КАК Item,
	|	StagesOfTransportRequests.TransportRequest.ProjectMobilization КАК ProjectMobilization,
	|	Items.СтрокаИнвойса.КодПоИнвойсу КАК PartNo,
	|	ВЫРАЗИТЬ(Items.СтрокаИнвойса.НаименованиеТовара КАК СТРОКА(200)) КАК PartDescription,
	|	СУММА(ЕСТЬNULL(Items.Qty / Items.Ссылка.NumOfParcels * ЕСТЬNULL(Trips.NumOfParcels, 1), 0)) КАК Qty_Items,
	|	СУММА(ЕСТЬNULL(Items.Ссылка.GrossWeight / Items.Ссылка.NumOfParcels, 0)) КАК GrossWeightKG_Items,
	|	NULL КАК TotalGrossWeightKG_Items,
	|	StagesOfTransportRequests.TransportRequest.Comments КАК Comments,
	|	StagesOfTransportRequests.TransportRequest.PickUpWarehouse КАК LocationFrom,
	|	StagesOfTransportRequests.TransportRequest.DeliverTo КАК LocationTo,
	|	StagesOfTransportRequests.TransportRequest.ReadyToShipLocalTime КАК ReadyToShip,
	|	StagesOfTransportRequests.TransportRequest.Company КАК Company,
	|	StagesOfTransportRequests.Stage КАК StageGroupName,
	|	Items.Ссылка.HazardClass КАК HazardClass,
	|	Trips.Ссылка КАК Trip,
	|	ЕСТЬNULL(TripNonLawsonCompaniesStops.ActualArrivalLocalTime, ДАТАВРЕМЯ(1, 1, 1)) КАК DeliveryToLocation,
	|	Trips.Ссылка.Equipment,
	|	Trips.Ссылка.MOT,
	|	StagesOfTransportRequests.TransportRequest.RequiredDeliveryLocalTime КАК RDD,
	|	ЕСТЬNULL(TripNonLawsonCompaniesStops.PlannedArrivalLocalTime, ДАТАВРЕМЯ(1, 1, 1)) КАК PlannedDeliveryToLocation,
	|	StagesOfTransportRequests.TransportRequest.CostCenter.Segment КАК SegmentCode,
	|	StagesOfTransportRequests.TransportRequest.Номер КАК TransportRequestNo,
	|	Trips.Ссылка.Номер КАК TripNo,
	|	ЕСТЬNULL(TripNonLawsonCompaniesStopsSource.PlannedDepartureLocalTime, ДАТАВРЕМЯ(1, 1, 1)) КАК PlannedDepartureLocalTime,
	|	ЕСТЬNULL(TripNonLawsonCompaniesStopsSource.ActualDepartureLocalTime, ДАТАВРЕМЯ(1, 1, 1)) КАК DepartureFromSource,
	|	Items.СтрокаИнвойса.НомерСтрокиИнвойса КАК LineNo,
	|	TripNonLawsonCompaniesStops.Mileage КАК Milage,
	|	ЛОЖЬ КАК Manual,
	|	Trips.Parcel,
	|	ЕСТЬNULL(Trips.Parcel.GrossWeightKG, 0) КАК TotalGrossWeightKG,
	|	ЕСТЬNULL(Trips.NumOfParcels, 0) КАК Qty,
	|	ВЫБОР
	|		КОГДА ЕСТЬNULL(Trips.Parcel.GrossWeightKG, 0) = 0
	|				ИЛИ ЕСТЬNULL(Trips.Parcel.NumOfParcels, 0) = 0
	|			ТОГДА 0
	|		ИНАЧЕ Trips.Parcel.GrossWeightKG / Trips.Parcel.NumOfParcels * ЕСТЬNULL(Trips.NumOfParcels, 0)
	|	КОНЕЦ КАК GrossWeightKG_Parcel,
	|	ЕСТЬNULL(Trips.Parcel.CubicMeters, 0) КАК CubicMeters,
	|	Trips.Ссылка.GrossWeightKG КАК GrossWeightKG,
	|	Trips.Ссылка.NavigationType
	|ПОМЕСТИТЬ ВТ_Items
	|ИЗ
	|	РегистрСведений.StagesOfTransportRequests КАК StagesOfTransportRequests
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК Items
	|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Parcels КАК Trips
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops
	|				ПО Trips.Ссылка = TripNonLawsonCompaniesStops.Ссылка
	|					И Trips.Parcel.TransportRequest.DeliverTo = TripNonLawsonCompaniesStops.Location
	|					И (TripNonLawsonCompaniesStops.Type <> ЗНАЧЕНИЕ(Перечисление.StopsTypes.Source))
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStopsSource
	|				ПО Trips.Ссылка = TripNonLawsonCompaniesStopsSource.Ссылка
	|					И Trips.Parcel.TransportRequest.PickUpWarehouse = TripNonLawsonCompaniesStopsSource.Location
	|					И (TripNonLawsonCompaniesStopsSource.Type <> ЗНАЧЕНИЕ(Перечисление.StopsTypes.Destination))
	|			ПО Items.Ссылка = Trips.Parcel
	|				И (НЕ Trips.Ссылка.ПометкаУдаления)
	|				И (НЕ Trips.Parcel.ПометкаУдаления)
	|		ПО StagesOfTransportRequests.TransportRequest = Items.Ссылка.TransportRequest
	|			И (НЕ Items.Ссылка.ПометкаУдаления)
	|			И (НЕ Items.СтрокаИнвойса.ПометкаУдаления)
	|ГДЕ
	|	&ТекстУсловия
	|	И НЕ StagesOfTransportRequests.TransportRequest.ПометкаУдаления
	|
	|СГРУППИРОВАТЬ ПО
	|	StagesOfTransportRequests.TransportRequest,
	|	Items.СтрокаИнвойса,
	|	Trips.Ссылка,
	|	Items.Ссылка.HazardClass,
	|	StagesOfTransportRequests.TransportRequest.ProjectMobilization,
	|	Items.СтрокаИнвойса.КодПоИнвойсу,
	|	Trips.Ссылка.Номер,
	|	StagesOfTransportRequests.TransportRequest.PickUpWarehouse,
	|	StagesOfTransportRequests.TransportRequest.DeliverTo,
	|	StagesOfTransportRequests.TransportRequest.ReadyToShipLocalTime,
	|	StagesOfTransportRequests.TransportRequest.Company,
	|	Trips.Ссылка.MOT,
	|	StagesOfTransportRequests.TransportRequest.RequiredDeliveryLocalTime,
	|	StagesOfTransportRequests.TransportRequest.Номер,
	|	ВЫРАЗИТЬ(Items.СтрокаИнвойса.НаименованиеТовара КАК СТРОКА(300)),
	|	Items.СтрокаИнвойса.НомерСтрокиИнвойса,
	|	TripNonLawsonCompaniesStops.Mileage,
	|	ВЫРАЗИТЬ(Items.СтрокаИнвойса.НаименованиеТовара КАК СТРОКА(200)),
	|	StagesOfTransportRequests.Stage,
	|	Trips.Ссылка.Equipment,
	|	ЕСТЬNULL(TripNonLawsonCompaniesStopsSource.PlannedDepartureLocalTime, ДАТАВРЕМЯ(1, 1, 1)),
	|	ЕСТЬNULL(TripNonLawsonCompaniesStopsSource.ActualDepartureLocalTime, ДАТАВРЕМЯ(1, 1, 1)),
	|	ЕСТЬNULL(TripNonLawsonCompaniesStops.PlannedArrivalLocalTime, ДАТАВРЕМЯ(1, 1, 1)),
	|	ЕСТЬNULL(TripNonLawsonCompaniesStops.ActualArrivalLocalTime, ДАТАВРЕМЯ(1, 1, 1)),
	|	StagesOfTransportRequests.TransportRequest.Comments,
	|	StagesOfTransportRequests.TransportRequest.CostCenter.Segment,
	|	Trips.Parcel,
	|	ЕСТЬNULL(Trips.Parcel.GrossWeightKG, 0),
	|	ЕСТЬNULL(Trips.NumOfParcels, 0),
	|	ВЫБОР
	|		КОГДА ЕСТЬNULL(Trips.Parcel.GrossWeightKG, 0) = 0
	|				ИЛИ ЕСТЬNULL(Trips.Parcel.NumOfParcels, 0) = 0
	|			ТОГДА 0
	|		ИНАЧЕ Trips.Parcel.GrossWeightKG / Trips.Parcel.NumOfParcels * ЕСТЬNULL(Trips.NumOfParcels, 0)
	|	КОНЕЦ,
	|	Trips.Ссылка.GrossWeightKG,
	|	ЕСТЬNULL(Trips.Parcel.CubicMeters, 0),
	|	Trips.Ссылка.NavigationType
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	NULL,
	|	ProjectMobilizationManualItems.Ссылка,
	|	ProjectMobilizationManualItems.Владелец,
	|	ProjectMobilizationManualItems.Наименование,
	|	ProjectMobilizationManualItems.ItemDescription,
	|	ProjectMobilizationManualItems.BalanceQty,
	|	ВЫБОР
	|		КОГДА ProjectMobilizationManualItems.BalanceTotalGrossWeightKG > 0
	|				И ProjectMobilizationManualItems.BalanceQty > 0
	|			ТОГДА ProjectMobilizationManualItems.BalanceTotalGrossWeightKG / ProjectMobilizationManualItems.BalanceQty
	|		ИНАЧЕ ProjectMobilizationManualItems.GrossWeightKG
	|	КОНЕЦ,
	|	ProjectMobilizationManualItems.BalanceTotalGrossWeightKG,
	|	ProjectMobilizationManualItems.Comments,
	|	ProjectMobilizationManualItems.PickUpWarehouse,
	|	ProjectMobilizationManualItems.DeliverTo,
	|	ProjectMobilizationManualItems.ReadyToShip,
	|	NULL,
	|	ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.Draft),
	|	ProjectMobilizationManualItems.HazardClass,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	ProjectMobilizationManualItems.RDD,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	ИСТИНА,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL,
	|	NULL
	|ИЗ
	|	Справочник.ProjectMobilizationManualItems КАК ProjectMobilizationManualItems
	|ГДЕ
	|	ProjectMobilizationManualItems.Item = ЗНАЧЕНИЕ(Справочник.СтрокиИнвойса.ПустаяСсылка)
	|	И &FilterMI
	|	И ProjectMobilizationManualItems.DomesticInternational = ЗНАЧЕНИЕ(Перечисление.DomesticInternational.Domestic)
	|	И НЕ ProjectMobilizationManualItems.ПометкаУдаления
	|	И НЕ ProjectMobilizationManualItems.RequestsCompleted
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	МАКСИМУМ(ProjectMobilizationPlanningDomesticСрезПоследних.Период) КАК Period,
	|	ProjectMobilizationPlanningDomesticСрезПоследних.Item,
	|	ProjectMobilizationPlanningDomesticСрезПоследних.ProjectMobilization
	|ПОМЕСТИТЬ ВТ_planning
	|ИЗ
	|	РегистрСведений.ProjectMobilizationPlanningDomestic.СрезПоследних(
	|			&ТекДата,
	|			(ProjectMobilization, Item) В
	|				(ВЫБРАТЬ
	|					ВТ_Items.ProjectMobilization,
	|					ВТ_Items.Item
	|				ИЗ
	|					ВТ_Items КАК ВТ_Items)) КАК ProjectMobilizationPlanningDomesticСрезПоследних
	|
	|СГРУППИРОВАТЬ ПО
	|	ProjectMobilizationPlanningDomesticСрезПоследних.Item,
	|	ProjectMobilizationPlanningDomesticСрезПоследних.ProjectMobilization
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_Items.TransportRequest,
	|	ВТ_Items.ProjectMobilization,
	|	ВТ_Items.HazardClass КАК HazardClass,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.Comments, ВТ_Items.Comments) КАК Comments,
	|	ВЫБОР
	|		КОГДА ВТ_Items.Manual
	|			ТОГДА ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.LocationFrom, ВТ_Items.LocationFrom)
	|		ИНАЧЕ ВТ_Items.LocationFrom
	|	КОНЕЦ КАК LocationFrom,
	|	ВЫБОР
	|		КОГДА ВТ_Items.Manual
	|			ТОГДА ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.LocationTo, ВТ_Items.LocationTo)
	|		ИНАЧЕ ВТ_Items.LocationTo
	|	КОНЕЦ КАК LocationTo,
	|	ВЫБОР
	|		КОГДА ВТ_Items.Manual
	|			ТОГДА ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.Company, ВТ_Items.Company)
	|		ИНАЧЕ ВТ_Items.Company
	|	КОНЕЦ КАК Company,
	|	ВТ_Items.ReadyToShip КАК ReadyToShip,
	|	ВТ_Items.StageGroupName,
	|	ВТ_Items.Trip,
	|	ВТ_Items.DeliveryToLocation,
	|	ВЫБОР
	|		КОГДА ВТ_Items.Manual
	|			ТОГДА ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.Equipment, ВТ_Items.Equipment)
	|		ИНАЧЕ ВТ_Items.Equipment
	|	КОНЕЦ КАК Equipment,
	|	ВЫБОР
	|		КОГДА ВТ_Items.Manual
	|			ТОГДА ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.MOT, ВТ_Items.MOT)
	|		ИНАЧЕ ВТ_Items.MOT
	|	КОНЕЦ КАК MOT,
	|	ВЫБОР
	|		КОГДА ВТ_Items.Manual
	|			ТОГДА ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.RDD, ВТ_Items.RDD)
	|		ИНАЧЕ ВТ_Items.RDD
	|	КОНЕЦ КАК RDD,
	|	ВТ_Items.PlannedDeliveryToLocation,
	|	ВТ_Items.SegmentCode,
	|	ВТ_Items.TransportRequestNo,
	|	ВТ_Items.TripNo,
	|	ВТ_Items.PlannedDepartureLocalTime,
	|	ВТ_Items.DepartureFromSource,
	|	ВТ_Items.Milage,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.FreightCostPerKM, 0) КАК FreightCostPerKM,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.TotalFreightCostKM, 0) КАК TotalFreightCostKM,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.FreightCostPerKG, 0) КАК FreightCostPerKG,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.TotalFreightCostKG, 0) КАК TotalFreightCostKG,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.TonneKilometers, 0) КАК TonneKilometers,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.FreightCostPerTKM, 0) КАК FreightCostPerTKM,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.TotalFreightCostTKM, 0) КАК TotalFreightCostTKM,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.TotalActualDuration, 0) КАК TotalActualDuration,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.NumOfTransport, 1) КАК NumOfTransport,
	|	"""" КАК ПредставлениеDuration,
	|	ВТ_Items.Manual,
	|	ВТ_Items.Parcel,
	|	ЕСТЬNULL(ВТ_Items.TotalGrossWeightKG, 0) КАК GrossWeightKG,
	|	ЕСТЬNULL(ВТ_Items.Qty, 0) КАК Qty,
	|	ВТ_Items.GrossWeightKG КАК TotalGrossWeightKG,
	|	ВТ_Items.CubicMeters,
	|	ВТ_Items.NavigationType,
	|	ВТ_Items.Trip.TotalCostsSumUSD КАК TotalCostsSumUSD
	|ИЗ
	|	ВТ_Items КАК ВТ_Items
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ProjectMobilizationPlanningDomestic.СрезПоследних(
	|				&ТекДата,
	|				(Период, ProjectMobilization, Item) В
	|						(ВЫБРАТЬ
	|							ВТ_planning.Period,
	|							ВТ_planning.ProjectMobilization,
	|							ВТ_planning.Item
	|						ИЗ
	|							ВТ_planning КАК ВТ_planning)
	|					И &Variant) КАК ProjectMobilizationPlanningDomesticСрезПоследних
	|		ПО ВТ_Items.Item = ProjectMobilizationPlanningDomesticСрезПоследних.Item
	|			И ВТ_Items.ProjectMobilization = ProjectMobilizationPlanningDomesticСрезПоследних.ProjectMobilization
	|
	|СГРУППИРОВАТЬ ПО
	|	ВТ_Items.Manual,
	|	ВТ_Items.Parcel,
	|	ВТ_Items.NavigationType,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.Comments, ВТ_Items.Comments),
	|	ВЫБОР
	|		КОГДА ВТ_Items.Manual
	|			ТОГДА ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.LocationFrom, ВТ_Items.LocationFrom)
	|		ИНАЧЕ ВТ_Items.LocationFrom
	|	КОНЕЦ,
	|	ВТ_Items.TransportRequest,
	|	ВТ_Items.HazardClass,
	|	ВЫБОР
	|		КОГДА ВТ_Items.Manual
	|			ТОГДА ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.LocationTo, ВТ_Items.LocationTo)
	|		ИНАЧЕ ВТ_Items.LocationTo
	|	КОНЕЦ,
	|	ВТ_Items.ProjectMobilization,
	|	ВТ_Items.PlannedDepartureLocalTime,
	|	ВТ_Items.PlannedDeliveryToLocation,
	|	ВТ_Items.DepartureFromSource,
	|	ВТ_Items.ReadyToShip,
	|	ВТ_Items.Trip,
	|	ВЫБОР
	|		КОГДА ВТ_Items.Manual
	|			ТОГДА ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.Equipment, ВТ_Items.Equipment)
	|		ИНАЧЕ ВТ_Items.Equipment
	|	КОНЕЦ,
	|	ВТ_Items.StageGroupName,
	|	ВТ_Items.DeliveryToLocation,
	|	ВЫБОР
	|		КОГДА ВТ_Items.Manual
	|			ТОГДА ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.RDD, ВТ_Items.RDD)
	|		ИНАЧЕ ВТ_Items.RDD
	|	КОНЕЦ,
	|	ВТ_Items.SegmentCode,
	|	ВТ_Items.TransportRequestNo,
	|	ВЫБОР
	|		КОГДА ВТ_Items.Manual
	|			ТОГДА ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.Company, ВТ_Items.Company)
	|		ИНАЧЕ ВТ_Items.Company
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА ВТ_Items.Manual
	|			ТОГДА ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.MOT, ВТ_Items.MOT)
	|		ИНАЧЕ ВТ_Items.MOT
	|	КОНЕЦ,
	|	ВТ_Items.TripNo,
	|	ВТ_Items.Milage,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.FreightCostPerKM, 0),
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.TotalFreightCostKM, 0),
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.FreightCostPerKG, 0),
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.TotalFreightCostKG, 0),
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.TonneKilometers, 0),
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.FreightCostPerTKM, 0),
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.TotalFreightCostTKM, 0),
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.TotalActualDuration, 0),
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomesticСрезПоследних.NumOfTransport, 1),
	|	ЕСТЬNULL(ВТ_Items.TotalGrossWeightKG, 0),
	|	ЕСТЬNULL(ВТ_Items.Qty, 0),
	|	ВТ_Items.GrossWeightKG,
	|	ВТ_Items.CubicMeters,
	|	ВТ_Items.Trip.TotalCostsSumUSD"; 
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ТекстУсловия", ТекстУсловия);
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&FilterMI", ?(FilterMI = "", " Ложь", FilterMI));
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "И &Variant", ?(Variant = "", "", " И Variant = &Variant И User = &ВладелецВарианта"));
	
	Если DomesticTrackingMainFilter = DomesticTrackingMainFilters.PartNo Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали", "ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали");
	КонецЕсли;
	
	Если НЕ ДопФильтры = Неопределено И ДопФильтры.Свойство("Статус") Тогда
		
		ФильтрПоСтатусу = ДопФильтры.Статус;
		ЗначенияФильтра = Новый Массив;
		ПредУсловие = "";
		Если ФильтрПоСтатусу.ВидСравнения = "Equal" Или ФильтрПоСтатусу.ВидСравнения = "Not equal" Тогда
			ЗначенияФильтра.Добавить(ФильтрПоСтатусу.ЗначениеСтрока);
		Иначе
			ЗначенияФильтра = ФильтрПоСтатусу.ЗначениеСписок.ВыгрузитьЗначения();
		КонецЕсли;
		
		Если СтрНайти(ФильтрПоСтатусу.ВидСравнения, "Not") <> 0 Тогда
			ПредУсловие = " НЕ ";
		КонецЕсли;
		
		Запрос.Текст = Запрос.Текст + "
		|	ГДЕ
		|		" + ПредУсловие + "ВТ_Items.StageGroupName В (&ЗначенияФильтраПоСтатусу)";
		
		Запрос.УстановитьПараметр("ЗначенияФильтраПоСтатусу", ЗначенияФильтра);
		
		// { RGS AArsentev S-I-0003227 27.06.2017
		Если ДопФильтры.Свойство("NavigationType") Тогда
			
			ФильтрПоNavigationType = ДопФильтры.NavigationType;
			УсловиеNavigationType = "";
			
			Если СтрНайти(ФильтрПоNavigationType.ВидСравнения, "Not") <> 0 Тогда
				УсловиеNavigationType = " И ВТ_Items.NavigationType <> &NavigationType";
			Иначе
				УсловиеNavigationType = " И ВТ_Items.NavigationType = &NavigationType";
			КонецЕсли;
				
			Запрос.Текст = Запрос.Текст + УсловиеNavigationType;
			Запрос.УстановитьПараметр("NavigationType", ФильтрПоNavigationType.ЗначениеСписок);
			
		КонецЕсли;
		
	ИначеЕсли НЕ ДопФильтры = Неопределено И НЕ ДопФильтры.Свойство("Статус") И ДопФильтры.Свойство("NavigationType") Тогда
		
		 	ФильтрПоNavigationType = ДопФильтры.NavigationType;
			УсловиеNavigationType = "";
			
			Если СтрНайти(ФильтрПоNavigationType.ВидСравнения, "Not") <> 0 Тогда
				УсловиеNavigationType = " ГДЕ 
				| ВТ_Items.NavigationType <> &NavigationType";
			Иначе
				УсловиеNavigationType = " ГДЕ
				| ВТ_Items.NavigationType = &NavigationType";
			КонецЕсли;
				
			Запрос.Текст = Запрос.Текст + УсловиеNavigationType;
			Запрос.УстановитьПараметр("NavigationType", ФильтрПоNavigationType.ЗначениеСписок);
		// } RGS AArsentev S-I-0003227 27.06.2017
	КонецЕсли;

	Запрос.УстановитьПараметр("Variant", Variant);
	Запрос.УстановитьПараметр("ВладелецВарианта", ВладелецВарианта);	
	Запрос.УстановитьПараметр("ТекДата", ТекущаяДата());

	// Установим фильтр по стране
	//Если Country = Неопределено Тогда
	//	Запрос.Текст = СтрЗаменить(Запрос.Текст, "И Items.Ссылка.TransportRequest.Country = &Country", "");
	//КонецЕсли;

	//Запрос.УстановитьПараметр("Country", Country);
	
	УстановитьПривилегированныйРежим(Истина);
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Процедура DomesticPlanningFillStatistic(DomesticPlanning, массивСтрокДляПересчета = Неопределено)  Экспорт 
	
	строкиДляАнализа = ?(массивСтрокДляПересчета = Неопределено, DomesticPlanning, массивСтрокДляПересчета);
	
	Для Каждого Строка из строкиДляАнализа Цикл 
		
		Если Не ЗначениеЗаполнено(Строка.Milage) Тогда 
			Milage = ргМодульКартографии.ВычислитьРасстояние(Строка.LocationFrom, Строка.LocationTo, Истина, Ложь);
			Строка.Milage = ?(ЗначениеЗаполнено(Milage), Milage, 0);
		КонецЕсли;
		
		// { RGS AARsentev 04.03.2018 S-I-0004271
		//Строка.TonneKilometers	= Строка.Milage * Строка.TotalGrossWeightKG / 1000;
		Если Не ЗначениеЗаполнено(Строка.Milage) ИЛИ Не ЗначениеЗаполнено(Строка.TotalGrossWeightKG) Тогда
			Строка.TonneKilometers	= 0;
		Иначе
			Строка.TonneKilometers	= Строка.Milage * Строка.TotalGrossWeightKG / 1000;
		КонецЕсли;		
		// } RGS AARsentev 04.03.2018 S-I-0004271
		
		Запрос = Новый Запрос;
		
		Запрос.Текст =
		"ВЫБРАТЬ
		|	LocalDistributionCostsMilageWeightVolumeОбороты.HazardClass,
		|	LocalDistributionCostsMilageWeightVolumeОбороты.MOT,
		|	LocalDistributionCostsMilageWeightVolumeОбороты.MilageOfParcelОборот КАК MilageOfParcel,
		|	LocalDistributionCostsMilageWeightVolumeОбороты.WeightОборот КАК Weight,
		|	LocalDistributionCostsMilageWeightVolumeОбороты.SumOfMilageОборот КАК SumOfMilage,
		|	LocalDistributionCostsMilageWeightVolumeОбороты.TonneKilometersОборот КАК TonneKilometers,
		|	LocalDistributionCostsMilageWeightVolumeОбороты.SumОборот КАК Sum
		|ИЗ
		|	РегистрНакопления.LocalDistributionCostsMilageWeightVolume.Обороты(
		|			&НачалоПериода,
		|			&КонецПериода,
		|			,
		|			HazardClass = &HazardClass
		|				И MOT = &MOT
		|				И SourceLocation = &SourceLocation
		|				И DestinationLocation = &DestinationLocation) КАК LocalDistributionCostsMilageWeightVolumeОбороты";
		
		//Если ЗначениеЗаполнено(Строка.Company) Тогда
		//	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&УсловиеParentCompany", "ParentCompany = &ParentCompany");
		//КонецЕсли;
		
		//Если ЗначениеЗаполнено(Строка.Equipment) Тогда
		//	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&УсловиеEquipment", "Equipment = &Equipment");
		//КонецЕсли;
		
		Запрос.УстановитьПараметр("НачалоПериода",			ДобавитьМесяц(ТекущаяДата(), -24));
		Запрос.УстановитьПараметр("КонецПериода",			ТекущаяДата());
		Запрос.УстановитьПараметр("HazardClass",			Строка.HazardClass);
		//Запрос.УстановитьПараметр("Equipment",				Строка.Equipment);
		Запрос.УстановитьПараметр("MOT",					Строка.MOT);
		Запрос.УстановитьПараметр("SourceLocation",			Строка.LocationFrom);
		Запрос.УстановитьПараметр("DestinationLocation",	Строка.LocationTo);
		//Запрос.УстановитьПараметр("ParentCompany",			Строка.Company);
		//Запрос.УстановитьПараметр("УсловиеEquipment",		Истина);
		//Запрос.УстановитьПараметр("УсловиеParentCompany",	Истина);
		
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			Строка.FreightCostPerKM		= ?(Выборка.MilageOfParcel = 0, 0, Выборка.SumOfMilage / Выборка.MilageOfParcel);
			Строка.TotalFreightCostKM	= (Строка.GrossWeightKG / Строка.TotalGrossWeightKG) * (Строка.NumOfTransport * Строка.Milage * Строка.FreightCostPerKM);
			Строка.FreightCostPerKG		= ?(Строка.GrossWeightKG = 0, 0, Выборка.SumOfMilage / Строка.TotalGrossWeightKG);
			Строка.TotalFreightCostKG	= Строка.TotalGrossWeightKG / Строка.GrossWeightKG * Строка.FreightCostPerKG;
			Строка.FreightCostPerTKM	= ?(Выборка.TonneKilometers = 0, 0, Выборка.Sum / Выборка.TonneKilometers);
			Строка.TotalFreightCostTKM	= (Строка.GrossWeightKG / Строка.TotalGrossWeightKG) * (Строка.TonneKilometers * Строка.FreightCostPerTKM);
		КонецЕсли;
		
		// Total actual duration
		Запрос = Новый Запрос;
		
		Запрос.Текст =
		"ВЫБРАТЬ
		|	TripNonLawsonCompaniesParcels.Ссылка КАК Trip,
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.PickUpWarehouse КАК LocationFrom,
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.DeliverTo КАК LocationTo,
		|	СУММА(TripNonLawsonCompaniesParcels.Parcel.GrossWeight) КАК GrossWeight
		|ПОМЕСТИТЬ ТаблицаParcel
		|ИЗ
		|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		|ГДЕ
		|	TripNonLawsonCompaniesParcels.Ссылка.Дата МЕЖДУ &НачалоПериода И &КонецПериода
		|	И TripNonLawsonCompaniesParcels.Ссылка.Проведен
		|	И TripNonLawsonCompaniesParcels.Ссылка.MOT = &MOT
		|	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest.PickUpWarehouse = &PickUpWarehouse
		|	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest.DeliverTo = &DeliverTo
		|
		|СГРУППИРОВАТЬ ПО
		|	TripNonLawsonCompaniesParcels.Ссылка,
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.DeliverTo,
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.PickUpWarehouse
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТаблицаParcel.Trip,
		|	ТаблицаParcel.LocationFrom,
		|	ТаблицаParcel.LocationTo,
		|	ТаблицаParcel.GrossWeight КАК ItemCount,
		|	TripNonLawsonCompaniesStopsFrom.ActualDepartureLocalTime,
		|	TripNonLawsonCompaniesStopsTo.ActualArrivalLocalTime,
		|	РАЗНОСТЬДАТ(TripNonLawsonCompaniesStopsFrom.ActualDepartureLocalTime, TripNonLawsonCompaniesStopsTo.ActualArrivalLocalTime, СЕКУНДА) КАК Duration
		|ИЗ
		|	ТаблицаParcel КАК ТаблицаParcel
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStopsFrom
		|		ПО ТаблицаParcel.Trip = TripNonLawsonCompaniesStopsFrom.Ссылка
		|			И ТаблицаParcel.LocationFrom = TripNonLawsonCompaniesStopsFrom.Location
		|			И (TripNonLawsonCompaniesStopsFrom.Type В (ЗНАЧЕНИЕ(Перечисление.StopsTypes.Source), ЗНАЧЕНИЕ(Перечисление.StopsTypes.Transit)))
		|			И (TripNonLawsonCompaniesStopsFrom.ActualDepartureLocalTime <> ДАТАВРЕМЯ(1, 1, 1))
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStopsTo
		|		ПО ТаблицаParcel.Trip = TripNonLawsonCompaniesStopsTo.Ссылка
		|			И ТаблицаParcel.LocationTo = TripNonLawsonCompaniesStopsTo.Location
		|			И (TripNonLawsonCompaniesStopsTo.Type В (ЗНАЧЕНИЕ(Перечисление.StopsTypes.Destination), ЗНАЧЕНИЕ(Перечисление.StopsTypes.Transit)))
		|			И (TripNonLawsonCompaniesStopsTo.ActualArrivalLocalTime <> ДАТАВРЕМЯ(1, 1, 1))";
		
		Запрос.УстановитьПараметр("НачалоПериода",		ДобавитьМесяц(ТекущаяДата(), -24));
		Запрос.УстановитьПараметр("КонецПериода",		ТекущаяДата());
		Запрос.УстановитьПараметр("MOT",				Строка.MOT);
		Запрос.УстановитьПараметр("PickUpWarehouse",	Строка.LocationFrom);
		Запрос.УстановитьПараметр("DeliverTo",			Строка.LocationTo);
		
		Таблица = Запрос.Выполнить().Выгрузить();
		
		Строка.TotalActualDuration		= Рассчитать90PercentDuration("Duration", Таблица);
		Если ЗначениеЗаполнено(Строка.TotalActualDuration) Тогда 
			Строка.ПредставлениеDuration	= ПолучитьПредставлениеDuration(Строка.TotalActualDuration);
		КонецЕсли;
	
	КонецЦикла;
	 	
КонецПроцедуры

Функция Рассчитать90PercentDuration(Leg, ТЗLegLeadTime)
	
	ТЗLegLeadTime.Свернуть(Leg, "ItemCount");
	ТЗLegLeadTime.Сортировать(Leg + " Возр");
	ИтогоItemCount = ТЗLegLeadTime.Итог("ItemCount");
	
	ItemCountCumulated = 0;
	CumulativePercent = 0;
	
	Для Каждого Стр из ТЗLegLeadTime Цикл
		
		LegDays = Стр[Leg];
		
		ItemCountCumulated = ItemCountCumulated + Стр.ItemCount;
		
		CumulativePercent = ItemCountCumulated / ИтогоItemCount * 100;

		Если CumulativePercent >= 90 Тогда 
			Прервать;
		КонецЕсли;	
		    				
	КонецЦикла;
	
	Возврат LegDays; 
	
КонецФункции

Функция ПолучитьПредставлениеDuration(Знач Duration)
	
	ПредставлениеDuration = "";
	
	Дней = Цел(Duration/86400);
	Duration = Duration - Дней*86400;
	
	Часов = Цел(Duration/3600);
	Duration = Duration - Часов*3600;
	
	Если Дней > 0 Тогда
		ПредставлениеDuration = СокрЛП(Дней) + " days/дней";
	Иначе
		ПредставлениеDuration = СокрЛП(Часов) + " hours/часов";
	КонецЕсли;
	
	Возврат ПредставлениеDuration;
	
КонецФункции

// Функция расчитывает даты по факту или по процентилю
// Параметры:
//		ImportTracking - Таблица значений\Таблица формы
//
Процедура РассчитатьДаты_OLD(ImportTracking, массивСтрокДляПересчета = Неопределено) Экспорт
	
	//менеджерВременныхТаблиц	 = Новый МенеджерВременныхТаблиц;
	//
	//соответствиеТаблицДанных = ПолучитьТаблицуДанныхДляРасчетаПоказателей(менеджерВременныхТаблиц);
	//
	//массивКалков = Новый Массив;  
	//массивКалков.Добавить("OrderCreatedCalc");
	//массивКалков.Добавить("SupplierAvailabilityCalc");
	//массивКалков.Добавить("ReceivedByHubCalc");
	//массивКалков.Добавить("ShipmentPreparedByHubCalc");
	//массивКалков.Добавить("DestinationGreenLightReleaseCalc");
	//массивКалков.Добавить("ShippedByHubCalc");
	//массивКалков.Добавить("ArrivedAtPortOfEntryCalc");
	//массивКалков.Добавить("CustomsClearanceCalc");
	//массивКалков.Добавить("DeliveryToLocationCalc");
	//массивКалков.Добавить("ReceiptConfirmedByLocationCalc");
	//
	//строкиДляАнализа 	= ?(массивСтрокДляПересчета = Неопределено, ImportTracking, массивСтрокДляПересчета);
	//
	//массивProcessLevels = Новый Массив;
	//массивProcessLevels.Добавить(Справочники.ProcessLevels.RUSM);
	//массивProcessLevels.Добавить(Справочники.ProcessLevels.RUWE);
	//массивProcessLevels.Добавить(Справочники.ProcessLevels.AZ);
	//
	//Для каждого текСтрокаТрекинга из строкиДляАнализа Цикл
	//		
	//	//Order Created
	//	этоPO 			 = (ТипЗнч(текСтрокаТрекинга.item) = Тип("СправочникСсылка.СтрокиЗаявкиНаЗакупку"));
	//	этоMI			 = текСтрокаТрекинга.isManualItem;
	//	этоПлан			 = текСтрокаТрекинга.isPlanData;
	//	
	//	первыйРасчетный  = Ложь;
	//	
	//	текСтрокаТрекинга.OrderCreated = ?(ЗначениеЗаполнено(текСтрокаТрекинга.PODate), текСтрокаТрекинга.PODate, "NA");
	//	
	//	Если НЕ этоPO И НЕ этоMI И НЕ ЗначениеЗаполнено(текСтрокаТрекинга.item.СтрокаЗаявкиНаЗакупку) Тогда
	//		текСтрокаТрекинга.OrderCreated = ?(ЗначениеЗаполнено(текСтрокаТрекинга.DOCDate), текСтрокаТрекинга.DOCDate, "NA");
	//	КонецЕсли;
	//	
	//	Если этоMI И ЗначениеЗаполнено(текСтрокаТрекинга.item.SupplierAvailability) Тогда
	//		текСтрокаТрекинга.OrderCreated = текСтрокаТрекинга.item.SupplierAvailability;
	//	КонецЕсли;
	//	
	//	текСтрокаТрекинга.OrderCreated = ?(ЗначениеЗаполнено(текСтрокаТрекинга.OrderCreated), текСтрокаТрекинга.OrderCreated, "NA");
	//		
	//	
	//	граница = ?(текСтрокаТрекинга.OrderCreated = "NA", ТекущаяДата(), текСтрокаТрекинга.OrderCreated);
	//	
	//	//Supplier Availability
	//	// берем SupplierPromisedDate из строки заявки или PO. Если нет, то считаем процентиль 90
	//	
	//	SupplierPromisedDate = Неопределено;
	//	Если этоPO Тогда
	//		SupplierPromisedDate = текСтрокаТрекинга.item.SupplierPromisedDate;
	//	ИначеЕсли этоMI Тогда
	//		SupplierPromisedDate = текСтрокаТрекинга.item.SupplierAvailability;
	//	Иначе
	//		Если ЗначениеЗаполнено(текСтрокаТрекинга.item.СтрокаЗаявкиНаЗакупку) Тогда
	//			SupplierPromisedDate = текСтрокаТрекинга.item.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate;
	//		Иначе
	//			SupplierPromisedDate = текСтрокаТрекинга.DOCDate;
	//		КонецЕсли;
	//	КонецЕсли;
	//	
	//	расчетный = Ложь;
	//	Если Не ЗначениеЗаполнено(SupplierPromisedDate) Тогда
	//		
	//		КоррекцияГраницы(граница, первыйРасчетный);
	//		
	//		SupplierPromisedDate = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "SupplierAvailability", граница, этоPO, этоMI, этоПлан);
	//		расчетный = Истина;
	//	КонецЕсли;
	//	
	//	текСтрокаТрекинга.SupplierAvailability 		= SupplierPromisedDate;
	//	текСтрокаТрекинга.SupplierAvailabilityCalc 	= расчетный;
	//	
	//	Если ЗначениеЗаполнено(SupplierPromisedDate) Тогда
	//		граница = SupplierPromisedDate;
	//	Иначе
	//		// если даты нет, то ставим предыдущую 
	//		текСтрокаТрекинга.SupplierAvailability 		= граница;
	//		текСтрокаТрекинга.SupplierAvailabilityCalc 	= Истина;			
	//	КонецЕсли;
	//	
	//	//Received by Hub
	//	//Items.СтрокаЗаявкиНаЗакупку.GOLDReceiptDate
	//	GOLDReceiptDate = Неопределено;
	//	Если этоPO Тогда
	//		GOLDReceiptDate = текСтрокаТрекинга.item.GOLDReceiptDate;
	//	ИначеЕсли этоMI Тогда
	//		// просто заглушка, чтобы не выполнился код по умолчанию. 
	//	Иначе
	//		Если ЗначениеЗаполнено(текСтрокаТрекинга.item.СтрокаЗаявкиНаЗакупку) Тогда
	//			GOLDReceiptDate = текСтрокаТрекинга.item.СтрокаЗаявкиНаЗакупку.GOLDReceiptDate;
	//		Иначе
	//			GOLDReceiptDate = текСтрокаТрекинга.DOCDate;
	//		КонецЕсли;
	//	КонецЕсли;
	//	
	//	расчетный = Ложь;
	//	Если НЕ ЗначениеЗаполнено(GOLDReceiptDate) Тогда
	//		
	//		КоррекцияГраницы(граница, первыйРасчетный);
	//		
	//		GOLDReceiptDate = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "ReceivedByHub", граница, этоPO, этоMI, этоПлан);
	//		расчетный = Истина;
	//	КонецЕсли;
	//	
	//	текСтрокаТрекинга.ReceivedByHub 		= GOLDReceiptDate;
	//	текСтрокаТрекинга.ReceivedByHubCalc 	= расчетный;	
	//	
	//	Если ЗначениеЗаполнено(GOLDReceiptDate) Тогда
	//		граница = GOLDReceiptDate;
	//	Иначе
	//		// если даты нет, то ставим предыдущую 
	//		текСтрокаТрекинга.ReceivedByHub 		= граница;
	//		текСтрокаТрекинга.ReceivedByHubCalc 	= Истина;	
	//	КонецЕсли;
	//	
	//	
	//	//Если НЕ этоPO Тогда
	//		//Shipment Prepared by Hub
	//		
	//		ShipmentPreparedByHub = текСтрокаТрекинга.DOCDate;
	//		
	//		расчетный = Ложь;
	//		Если НЕ ЗначениеЗаполнено(ShipmentPreparedByHub) Тогда
	//			
	//			КоррекцияГраницы(граница, первыйРасчетный);
	//		
	//			ShipmentPreparedByHub = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "ShipmentPreparedByHub", граница, этоPO, этоMI, этоПлан);
	//			расчетный = Истина;
	//		КонецЕсли;
	//		
	//		текСтрокаТрекинга.ShipmentPreparedByHub 		= ShipmentPreparedByHub;
	//		текСтрокаТрекинга.ShipmentPreparedByHubCalc 	= расчетный;	
	//		
	//		Если ЗначениеЗаполнено(ShipmentPreparedByHub) Тогда
	//			граница = ShipmentPreparedByHub;
	//		Иначе
	//			// если даты нет, то ставим предыдущую 
	//			текСтрокаТрекинга.ShipmentPreparedByHub 		= граница;
	//			текСтрокаТрекинга.ShipmentPreparedByHubCalc 	= Истина;	
	//		КонецЕсли;
	//		
	//		//Destination Green Light Release
	//		DestinationGreenLightRelease = Неопределено;
	//		Если ЗначениеЗаполнено(текСтрокаТрекинга.DOC) Тогда
	//			DestinationGreenLightRelease = ?(текСтрокаТрекинга.DOC.WithoutGreenLight, текСтрокаТрекинга.ATD, текСтрокаТрекинга.DOC.Granted);
	//		КонецЕсли;
	//		
	//		расчетный = Ложь;
	//		Если НЕ ЗначениеЗаполнено(DestinationGreenLightRelease) Тогда
	//			
	//			КоррекцияГраницы(граница, первыйРасчетный);
	//		
	//			DestinationGreenLightRelease = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "DestinationGreenLightRelease", граница, этоPO, этоMI, этоПлан);
	//			расчетный = Истина;
	//		КонецЕсли;
	//		
	//		текСтрокаТрекинга.DestinationGreenLightRelease 		= DestinationGreenLightRelease;
	//		текСтрокаТрекинга.DestinationGreenLightReleaseCalc 	= расчетный;	
	//		
	//		Если ЗначениеЗаполнено(DestinationGreenLightRelease) Тогда
	//			граница = DestinationGreenLightRelease;
	//		Иначе
	//			текСтрокаТрекинга.DestinationGreenLightRelease 		= граница;
	//			текСтрокаТрекинга.DestinationGreenLightReleaseCalc 	= Истина;	
	//		КонецЕсли;
	//		
	//		//Shipped by Hub
	//		
	//		ShippedByHub = текСтрокаТрекинга.ATD;
	//		
	//		расчетный = Ложь;
	//		Если НЕ ЗначениеЗаполнено(ShippedByHub) Тогда
	//			
	//			КоррекцияГраницы(граница, первыйРасчетный);
	//		
	//			ShippedByHub = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "ShippedByHub", граница, этоPO, этоMI, этоПлан);
	//			расчетный = Истина;
	//		КонецЕсли;
	//		
	//		текСтрокаТрекинга.ShippedByHub 		= ShippedByHub;
	//		текСтрокаТрекинга.ShippedByHubCalc 	= расчетный;	
	//		
	//		Если ЗначениеЗаполнено(ShippedByHub) Тогда
	//			граница = ShippedByHub;
	//		Иначе
	//			текСтрокаТрекинга.ShippedByHub 		= граница;
	//			текСтрокаТрекинга.ShippedByHubCalc 	= Истина;					
	//		КонецЕсли;
	//		
	//		//Arrived At Port Of Entry
	//		
	//		ArrivedAtPortOfEntry = текСтрокаТрекинга.ATA;
	//		
	//		расчетный = Ложь;
	//		Если НЕ ЗначениеЗаполнено(ArrivedAtPortOfEntry) Тогда
	//			
	//			КоррекцияГраницы(граница, первыйРасчетный);
	//		
	//			ArrivedAtPortOfEntry = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "ArrivedAtPortOfEntry", граница, этоPO, этоMI, этоПлан);
	//			расчетный = Истина;
	//		КонецЕсли;
	//		
	//		текСтрокаТрекинга.ArrivedAtPortOfEntry 		= ArrivedAtPortOfEntry;
	//		текСтрокаТрекинга.ArrivedAtPortOfEntryCalc 	= расчетный;	
	//		
	//		Если ЗначениеЗаполнено(ArrivedAtPortOfEntry) Тогда
	//			граница = ArrivedAtPortOfEntry;
	//		Иначе
	//			текСтрокаТрекинга.ArrivedAtPortOfEntry 		= граница;
	//			текСтрокаТрекинга.ArrivedAtPortOfEntryCalc 	= Истина;
	//		КонецЕсли;
	//		
	//		//Customs Clearance
	//		
	//		CustomsClearance = текСтрокаТрекинга.Cleared;
	//		
	//		расчетный = Ложь;
	//		Если НЕ ЗначениеЗаполнено(CustomsClearance) Тогда
	//			
	//			КоррекцияГраницы(граница, первыйРасчетный);
	//		
	//			CustomsClearance = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "CustomsClearance", граница, этоPO, этоMI, этоПлан);
	//			расчетный = Истина;
	//		КонецЕсли;
	//		
	//		текСтрокаТрекинга.CustomsClearance 		= CustomsClearance;
	//		текСтрокаТрекинга.CustomsClearanceCalc 	= расчетный;	
	//		
	//		Если ЗначениеЗаполнено(CustomsClearance) Тогда
	//			граница = CustomsClearance;
	//		Иначе
	//			текСтрокаТрекинга.CustomsClearance 		= граница;
	//			текСтрокаТрекинга.CustomsClearanceCalc 	= Истина;
	//		КонецЕсли;
	//		
	//		//Delivery To Location
	//		DeliveryToLocation = текСтрокаТрекинга.LocalDistributionATA;
	//		
	//		Если ЗначениеЗаполнено(текСтрокаТрекинга.DOC) И ЗначениеЗаполнено(текСтрокаТрекинга.Shipment)
	//			И ЗначениеЗаполнено(текСтрокаТрекинга.CollectedFromPort)
	//			И массивProcessLevels.Найти(текСтрокаТрекинга.Shipment.ProcessLevel) = Неопределено Тогда 
	//			
	//		    DeliveryToLocation = текСтрокаТрекинга.CollectedFromPort;
	//			
	//		КонецЕсли;
	//			
	//		расчетный = Ложь;
	//		Если НЕ ЗначениеЗаполнено(DeliveryToLocation)
	//			И ЗначениеЗаполнено(текСтрокаТрекинга.LocalDistributionETA) Тогда
	//			расчетный = Истина;
	//			DeliveryToLocation = текСтрокаТрекинга.LocalDistributionETA; 
	//		КонецЕсли;
	//		
	//		Если НЕ ЗначениеЗаполнено(DeliveryToLocation) Тогда
	//			
	//			КоррекцияГраницы(граница, первыйРасчетный);
	//		
	//			DeliveryToLocation = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "DeliveryToLocation", граница, этоPO, этоMI, этоПлан);
	//			расчетный = Истина;
	//		КонецЕсли;
	//		
	//		текСтрокаТрекинга.DeliveryToLocation 		= DeliveryToLocation;
	//		текСтрокаТрекинга.DeliveryToLocationCalc 	= расчетный;	
	//		
	//		Если ЗначениеЗаполнено(DeliveryToLocation) Тогда
	//			граница = DeliveryToLocation;
	//		Иначе
	//			текСтрокаТрекинга.DeliveryToLocation 		= граница;
	//			текСтрокаТрекинга.DeliveryToLocationCalc 	= Истина;
	//		КонецЕсли;
	//		
	//		//Receipt Confirmed By Location
	//		
	//		строкаЗаявкиНаЗакупку = Неопределено;
	//		Если НЕ этоMI Тогда
	//			строкаЗаявкиНаЗакупку = ?(этоPO, текСтрокаТрекинга.item, текСтрокаТрекинга.item.СтрокаЗаявкиНаЗакупку);
	//		КонецЕсли;
	//		
	//		ReceiptConfirmedByLocation = Неопределено;
	//		
	//		Если ЗначениеЗаполнено(строкаЗаявкиНаЗакупку) И ЗначениеЗаполнено(строкаЗаявкиНаЗакупку.GoodsReceiptDate) Тогда
	//			ReceiptConfirmedByLocation = строкаЗаявкиНаЗакупку.GoodsReceiptDate;
	//		Иначе 
	//			ReceiptConfirmedByLocation = строкаЗаявкиНаЗакупку.LocalDistributionATA;
	//		КонецЕсли;
	//		
	//		Если НЕ ЗначениеЗаполнено(ReceiptConfirmedByLocation) 
	//			И ЗначениеЗаполнено(текСтрокаТрекинга.DOC) И ЗначениеЗаполнено(текСтрокаТрекинга.Shipment)
	//			И ЗначениеЗаполнено(текСтрокаТрекинга.CollectedFromPort)
	//			И массивProcessLevels.Найти(текСтрокаТрекинга.Shipment.ProcessLevel) = Неопределено Тогда 
	//			
	//		    ReceiptConfirmedByLocation = текСтрокаТрекинга.CollectedFromPort;
	//			
	//		КонецЕсли;
	//		
	//		расчетный = Ложь;
	//		Если НЕ ЗначениеЗаполнено(ReceiptConfirmedByLocation) Тогда
	//			
	//			КоррекцияГраницы(граница, первыйРасчетный);
	//		
	//			//ReceiptConfirmedByLocation = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "ReceiptConfirmedByLocation", граница, этоPO);
	//			ReceiptConfirmedByLocation = граница;
	//			расчетный = Истина;
	//		КонецЕсли;
	//		
	//		текСтрокаТрекинга.ReceiptConfirmedByLocation 		= ReceiptConfirmedByLocation;
	//		текСтрокаТрекинга.ReceiptConfirmedByLocationCalc 	= расчетный;	
	//		
	//		Если НЕ ЗначениеЗаполнено(ReceiptConfirmedByLocation) Тогда
	//			текСтрокаТрекинга.ReceiptConfirmedByLocation 		= граница;
	//			текСтрокаТрекинга.ReceiptConfirmedByLocationCalc 	= Истина;					
	//		КонецЕсли;
	//		
	//	//КонецЕсли;
	//	
	//	//Required Delivery Date
	//	текСтрокаТрекинга.RequiredDeliveryDate = ? (ЗначениеЗаполнено(текСтрокаТрекинга.RDD), текСтрокаТрекинга.RDD, "");
	//			
	//	// Проверим раскраску. Если какая-то дата синяя, то до нее не должно быть желтых
	//	счет = массивКалков.Количество()-1;
	//	Пока счет >= 0 Цикл
	//		
	//		Если НЕ текСтрокаТрекинга[массивКалков[счет]] Тогда
	//			
	//			Для счетУровеньДва = 0 по счет - 1 Цикл
	//				текСтрокаТрекинга[массивКалков[счетУровеньДва]] = Ложь;					
	//			КонецЦикла;
	//			Прервать;
	//			
	//		КонецЕсли;
	//		
	//		счет = счет - 1;
	//		
	//	КонецЦикла;
	//	
	//КонецЦикла;
	
КонецПроцедуры 

Процедура РассчитатьДаты(ImportTracking, массивСтрокДляПересчета = Неопределено) Экспорт
	
	менеджерВременныхТаблиц	 = Новый МенеджерВременныхТаблиц;
	
	соответствиеТаблицДанных = ПолучитьТаблицуДанныхДляРасчетаПоказателей(менеджерВременныхТаблиц);
	
	историяРасчета = Новый Структура;
	
	последовательностьРасчета = Новый Массив;
	последовательностьРасчета.Добавить("OrderCreated");
	последовательностьРасчета.Добавить("SupplierAvailability");
	последовательностьРасчета.Добавить("ReceivedByHub");
	последовательностьРасчета.Добавить("ShipmentPreparedByHub");
	последовательностьРасчета.Добавить("DestinationGreenLightRelease");
	последовательностьРасчета.Добавить("ShippedByHub");
	последовательностьРасчета.Добавить("ArrivedAtPortOfEntry");
	последовательностьРасчета.Добавить("CustomsClearance");
	последовательностьРасчета.Добавить("DeliveryToLocation");
	последовательностьРасчета.Добавить("ReceiptConfirmedByLocation");
	последовательностьРасчета.Добавить("RequiredDeliveryDate");
	
	массивКалков = Новый Массив;  
	массивКалков.Добавить("OrderCreatedCalc");
	массивКалков.Добавить("SupplierAvailabilityCalc");
	массивКалков.Добавить("ReceivedByHubCalc");
	массивКалков.Добавить("ShipmentPreparedByHubCalc");
	массивКалков.Добавить("DestinationGreenLightReleaseCalc");
	массивКалков.Добавить("ShippedByHubCalc");
	массивКалков.Добавить("ArrivedAtPortOfEntryCalc");
	массивКалков.Добавить("CustomsClearanceCalc");
	массивКалков.Добавить("DeliveryToLocationCalc");
	массивКалков.Добавить("ReceiptConfirmedByLocationCalc");
	
	строкиДляАнализа 	= ?(массивСтрокДляПересчета = Неопределено, ImportTracking, массивСтрокДляПересчета);
	
	массивProcessLevels = Новый Массив;
	массивProcessLevels.Добавить(Справочники.ProcessLevels.RUSM);
	массивProcessLevels.Добавить(Справочники.ProcessLevels.RUWE);
	массивProcessLevels.Добавить(Справочники.ProcessLevels.AZ);     
	
	// идея расчета предельно проста
	// рассчитываем каждый показатель отдельно с анализом предыдущих значений
	// если значение расчетное, то нужно считать от текущей даты, а не от последней фактической. 
	// если после расчетной даты встречается фактическая, то нужно совершить возврат в прошлое 
	// и пересчитать все расчетные до фактической не по текущей дате, а по предыдущей фактической. 
	Для каждого текСтрокаТрекинга из строкиДляАнализа Цикл
		
		структураДопПараметров = Новый Структура;
		структураДопПараметров.Вставить("этоPO", 			ТипЗнч(текСтрокаТрекинга.item) = Тип("СправочникСсылка.СтрокиЗаявкиНаЗакупку"));
		структураДопПараметров.Вставить("этоMI", 			текСтрокаТрекинга.isManualItem);
		структураДопПараметров.Вставить("этоПлан", 			текСтрокаТрекинга.isPlanData);
		структураДопПараметров.Вставить("ПервыйРасчетный", 	Ложь);
		структураДопПараметров.Вставить("Пересчет", 		Ложь);
		структураДопПараметров.Вставить("массивProcessLevels", массивProcessLevels);
		
		РассчитатьДату(текСтрокаТрекинга, 
						последовательностьРасчета[0], 
						Неопределено,  
						менеджерВременныхТаблиц, 
						историяРасчета, 
						последовательностьРасчета, 
						структураДопПараметров);
						
		счет = массивКалков.Количество()-1;
		Пока счет >= 0 Цикл
			
			Если НЕ текСтрокаТрекинга[массивКалков[счет]] Тогда
				
				Для счетУровеньДва = 0 по счет - 1 Цикл
					текСтрокаТрекинга[массивКалков[счетУровеньДва]] = Ложь;					
				КонецЦикла;
				Прервать;
				
			КонецЕсли;
			
			счет = счет - 1;
			
		КонецЦикла;				
						
	КонецЦикла;
	
КонецПроцедуры	
	
// функция рассчитывает дату по статистике
// Параметры:
//		текСтрока - строка обрабатываемой таблицы
// 		имяПоказателя - дата, которую надо рассчитать
//		граница - момент, от которого надо считать
//		пересчитатьПоФактической - булево. флаг, что нужно считать по фактической дате
// 		история - история расчета предыдущих дат
//		последовательностьРасчета - массив с порядком расчета показателей
//
Процедура РассчитатьДату(текСтрокаТрекинга, 
						 имяПоказателя, 
						 граница, 
						 менеджерВременныхТаблиц, 
						 история, 
						 последовательностьРасчета, 
						 допПараметры) 
	
	//Order Created	
	массивProcessLevels = допПараметры.массивProcessLevels;
	этоMI				= допПараметры.этоMI;
	этоPO				= допПараметры.этоPO;
	этоПлан				= допПараметры.этоПлан;
	первыйРасчетный		= допПараметры.ПервыйРасчетный;
	пересчет			= допПараметры.Пересчет;
	
	значениеПоказателя 		= Неопределено;
	значениеПоказателяCalc 	= Ложь;
	расчетный				= Ложь;
		
	Если имяПоказателя = "OrderCreated" Тогда
		
		значениеПоказателя = ?(ЗначениеЗаполнено(текСтрокаТрекинга.PODate), текСтрокаТрекинга.PODate, "NA");
		
		Если НЕ этоPO И НЕ этоMI И НЕ ЗначениеЗаполнено(текСтрокаТрекинга.item.СтрокаЗаявкиНаЗакупку) Тогда
			значениеПоказателя = ?(ЗначениеЗаполнено(текСтрокаТрекинга.DOCDate), текСтрокаТрекинга.DOCDate, "NA");
		КонецЕсли;
		
		Если этоMI И ЗначениеЗаполнено(текСтрокаТрекинга.item.SupplierAvailability) Тогда
			значениеПоказателя = текСтрокаТрекинга.item.SupplierAvailability;
		КонецЕсли;
		
		значениеПоказателя = ?(ЗначениеЗаполнено(значениеПоказателя), значениеПоказателя, "NA");
			
		граница = ?(значениеПоказателя = "NA", ТекущаяДата(), значениеПоказателя);
		
	ИначеЕсли имяПоказателя = "SupplierAvailability" Тогда
		
		//Supplier Availability
		// берем SupplierPromisedDate из строки заявки или PO. Если нет, то считаем процентиль 90
		
		SupplierPromisedDate = Неопределено;
		Если этоPO Тогда
			SupplierPromisedDate = текСтрокаТрекинга.item.SupplierPromisedDate;
		ИначеЕсли этоMI Тогда
			SupplierPromisedDate = текСтрокаТрекинга.item.SupplierAvailability;
		Иначе
			Если ЗначениеЗаполнено(текСтрокаТрекинга.item.СтрокаЗаявкиНаЗакупку) Тогда
				SupplierPromisedDate = текСтрокаТрекинга.item.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate;
			Иначе
				SupplierPromisedDate = текСтрокаТрекинга.DOCDate;
			КонецЕсли;
		КонецЕсли;
		
		расчетный = Ложь;
		Если Не ЗначениеЗаполнено(SupplierPromisedDate) Тогда
			
			КоррекцияГраницы(граница, первыйРасчетный, пересчет);
			
			SupplierPromisedDate = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "SupplierAvailability", граница, этоPO, этоMI, этоПлан);
			расчетный = Истина;
		КонецЕсли;
		
		значениеПоказателя 		= SupplierPromisedDate;
		значениеПоказателяCalc 	= расчетный;
		
		Если ЗначениеЗаполнено(SupplierPromisedDate) Тогда
			граница = SupplierPromisedDate;
		Иначе
			// если даты нет, то ставим предыдущую 
			значениеПоказателя 		= граница;
			значениеПоказателяCalc 	= Истина;			
		КонецЕсли;
		
	ИначеЕсли имяПоказателя = "ReceivedByHub" Тогда
		//Received by Hub
		GOLDReceiptDate = Неопределено;
		Если этоPO Тогда
			GOLDReceiptDate = текСтрокаТрекинга.item.GOLDReceiptDate;
		ИначеЕсли этоMI Тогда
			// просто заглушка, чтобы не выполнился код по умолчанию. 
		Иначе
			Если ЗначениеЗаполнено(текСтрокаТрекинга.item.СтрокаЗаявкиНаЗакупку) Тогда
				GOLDReceiptDate = текСтрокаТрекинга.item.СтрокаЗаявкиНаЗакупку.GOLDReceiptDate;
			Иначе
				GOLDReceiptDate = текСтрокаТрекинга.DOCDate;
			КонецЕсли;
		КонецЕсли;
		
		расчетный = Ложь;
		Если НЕ ЗначениеЗаполнено(GOLDReceiptDate) Тогда	
			
			КоррекцияГраницы(граница, первыйРасчетный, пересчет);
			
			GOLDReceiptDate = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "ReceivedByHub", граница, этоPO, этоMI, этоПлан);
			расчетный = Истина;
		КонецЕсли;
		
		значениеПоказателя 		= GOLDReceiptDate;
		значениеПоказателяCalc 	= расчетный;	
		
		Если ЗначениеЗаполнено(GOLDReceiptDate) Тогда
			граница = GOLDReceiptDate;
		Иначе
			// если даты нет, то ставим предыдущую 
			значениеПоказателя 		= граница;
			значениеПоказателяCalc 	= Истина;	
		КонецЕсли;
	ИначеЕсли имяПоказателя = "ShipmentPreparedByHub" Тогда
		ShipmentPreparedByHub = текСтрокаТрекинга.DOCDate;
		
		расчетный = Ложь;
		Если НЕ ЗначениеЗаполнено(ShipmentPreparedByHub) Тогда	
			
			КоррекцияГраницы(граница, первыйРасчетный, пересчет);
			
			ShipmentPreparedByHub = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "ShipmentPreparedByHub", граница, этоPO, этоMI, этоПлан);
			расчетный = Истина;
		КонецЕсли;
		
		значениеПоказателя		= ShipmentPreparedByHub;
		значениеПоказателяCalc 	= расчетный;	
		
		Если ЗначениеЗаполнено(ShipmentPreparedByHub) Тогда
			граница = ShipmentPreparedByHub;
		Иначе
			// если даты нет, то ставим предыдущую 
			значениеПоказателя 		= граница;
			значениеПоказателяCalc 	= Истина;	
		КонецЕсли;
	ИначеЕсли имяПоказателя = "DestinationGreenLightRelease" Тогда
		
		//Destination Green Light Release
		DestinationGreenLightRelease = Неопределено;
		Если ЗначениеЗаполнено(текСтрокаТрекинга.DOC) Тогда
			DestinationGreenLightRelease = ?(текСтрокаТрекинга.DOC.WithoutGreenLight, текСтрокаТрекинга.ATD, текСтрокаТрекинга.DOC.Granted);
		КонецЕсли;
		
		расчетный = Ложь;
		Если НЕ ЗначениеЗаполнено(DestinationGreenLightRelease) Тогда
			
			КоррекцияГраницы(граница, первыйРасчетный, пересчет);
			
			DestinationGreenLightRelease = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "DestinationGreenLightRelease", граница, этоPO, этоMI, этоПлан);
			расчетный = Истина;
		КонецЕсли;
		
		значениеПоказателя 		= DestinationGreenLightRelease;
		значениеПоказателяCalc 	= расчетный;	
		
		Если ЗначениеЗаполнено(DestinationGreenLightRelease) Тогда
			граница = DestinationGreenLightRelease;
		Иначе
			значениеПоказателя 		= граница;
			значениеПоказателяCalc 	= Истина;	
		КонецЕсли;
		
	ИначеЕсли имяПоказателя = "ShippedByHub" Тогда
		
		//Shipped by Hub
		
		ShippedByHub = текСтрокаТрекинга.ATD;
		
		расчетный = Ложь;
		Если НЕ ЗначениеЗаполнено(ShippedByHub) Тогда
			
			КоррекцияГраницы(граница, первыйРасчетный, пересчет);
			
			ShippedByHub = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "ShippedByHub", граница, этоPO, этоMI, этоПлан);
			расчетный = Истина;
		КонецЕсли;
		
		значениеПоказателя 		= ShippedByHub;
		значениеПоказателяCalc 	= расчетный;	
		
		Если ЗначениеЗаполнено(ShippedByHub) Тогда
			граница = ShippedByHub;
		Иначе
			значениеПоказателя 		= граница;
			значениеПоказателяCalc 	= Истина;					
		КонецЕсли;
		
	ИначеЕсли имяПоказателя = "ArrivedAtPortOfEntry" Тогда
		//Arrived At Port Of Entry
		
		ArrivedAtPortOfEntry = текСтрокаТрекинга.ATA;
		
		расчетный = Ложь;
		Если НЕ ЗначениеЗаполнено(ArrivedAtPortOfEntry) Тогда
			
			КоррекцияГраницы(граница, первыйРасчетный, пересчет);
			
			ArrivedAtPortOfEntry = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "ArrivedAtPortOfEntry", граница, этоPO, этоMI, этоПлан);
			расчетный = Истина;
		КонецЕсли;
		
		значениеПоказателя 		= ArrivedAtPortOfEntry;
		значениеПоказателяCalc 	= расчетный;	
		
		Если ЗначениеЗаполнено(ArrivedAtPortOfEntry) Тогда
			граница = ArrivedAtPortOfEntry;
		Иначе
			значениеПоказателя 		= граница;
			значениеПоказателяCalc 	= Истина;
		КонецЕсли;
		
	ИначеЕсли имяПоказателя = "CustomsClearance" Тогда
		
		//Customs Clearance
		
		CustomsClearance = текСтрокаТрекинга.Cleared;
		
		расчетный = Ложь;
		Если НЕ ЗначениеЗаполнено(CustomsClearance) Тогда
			
			КоррекцияГраницы(граница, первыйРасчетный, пересчет);
			
			CustomsClearance = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "CustomsClearance", граница, этоPO, этоMI, этоПлан);
			расчетный = Истина;
		КонецЕсли;
		
		значениеПоказателя 		= CustomsClearance;
		значениеПоказателяCalc 	= расчетный;	
		
		Если ЗначениеЗаполнено(CustomsClearance) Тогда
			граница = CustomsClearance;
		Иначе
			значениеПоказателя 		= граница;
			значениеПоказателяCalc 	= Истина;
		КонецЕсли;
		
	ИначеЕсли имяПоказателя = "DeliveryToLocation" Тогда
		//Delivery To Location
		DeliveryToLocation = текСтрокаТрекинга.LocalDistributionATA;
		
		Если ЗначениеЗаполнено(текСтрокаТрекинга.DOC) И ЗначениеЗаполнено(текСтрокаТрекинга.Shipment)
			И ЗначениеЗаполнено(текСтрокаТрекинга.CollectedFromPort)
			И массивProcessLevels.Найти(текСтрокаТрекинга.Shipment.ProcessLevel) = Неопределено Тогда 
			
			DeliveryToLocation = текСтрокаТрекинга.CollectedFromPort;
			
		КонецЕсли;
		
		расчетный = Ложь;
		Если НЕ ЗначениеЗаполнено(DeliveryToLocation)
			И ЗначениеЗаполнено(текСтрокаТрекинга.LocalDistributionETA) Тогда
			расчетный = Истина;
			DeliveryToLocation = текСтрокаТрекинга.LocalDistributionETA; 
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(DeliveryToLocation) Тогда
			
			КоррекцияГраницы(граница, первыйРасчетный, пересчет);
			
			DeliveryToLocation = ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрокаТрекинга, "DeliveryToLocation", граница, этоPO, этоMI, этоПлан);
			расчетный = Истина;
		КонецЕсли;
		
		значениеПоказателя 		= DeliveryToLocation;
		значениеПоказателяCalc 	= расчетный;	
		
		Если ЗначениеЗаполнено(DeliveryToLocation) Тогда
			граница = DeliveryToLocation;
		Иначе
			значениеПоказателя 		= граница;
			значениеПоказателяCalc 	= Истина;
		КонецЕсли;
		
	ИначеЕсли имяПоказателя = "ReceiptConfirmedByLocation" Тогда
		//Receipt Confirmed By Location
		
		строкаЗаявкиНаЗакупку = Неопределено;
		Если НЕ этоMI Тогда
			строкаЗаявкиНаЗакупку = ?(этоPO, текСтрокаТрекинга.item, текСтрокаТрекинга.item.СтрокаЗаявкиНаЗакупку);
		КонецЕсли;
		
		ReceiptConfirmedByLocation = Неопределено;
		
		Если ЗначениеЗаполнено(строкаЗаявкиНаЗакупку) Тогда
			ReceiptConfirmedByLocation = строкаЗаявкиНаЗакупку.GoodsReceiptDate;
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ReceiptConfirmedByLocation) И ЗначениеЗаполнено(текСтрокаТрекинга.LocalDistributionATA)  Тогда 
			ReceiptConfirmedByLocation = текСтрокаТрекинга.LocalDistributionATA; 			
		КонецЕсли;

		Если НЕ ЗначениеЗаполнено(ReceiptConfirmedByLocation) И ЗначениеЗаполнено(текСтрокаТрекинга.DOC) И ЗначениеЗаполнено(текСтрокаТрекинга.Shipment)
			И ЗначениеЗаполнено(текСтрокаТрекинга.CollectedFromPort)
			И массивProcessLevels.Найти(текСтрокаТрекинга.Shipment.ProcessLevel) = Неопределено Тогда 
			
			ReceiptConfirmedByLocation = текСтрокаТрекинга.CollectedFromPort;
			
		КонецЕсли;
		
		расчетный = Ложь;
		Если НЕ ЗначениеЗаполнено(ReceiptConfirmedByLocation) Тогда
			ReceiptConfirmedByLocation = граница;
			расчетный = Истина;
		КонецЕсли;
		
		значениеПоказателя 		= ReceiptConfirmedByLocation;
		значениеПоказателяCalc 	= расчетный;	
		
		Если НЕ ЗначениеЗаполнено(ReceiptConfirmedByLocation) Тогда
			значениеПоказателя 		= граница;
			значениеПоказателяCalc 	= Истина;					
		КонецЕсли;
	ИначеЕсли имяПоказателя = "RequiredDeliveryDate" Тогда	
		//Required Delivery Date
		значениеПоказателя = ? (ЗначениеЗаполнено(текСтрокаТрекинга.RDD), текСтрокаТрекинга.RDD, "");	
	КонецЕсли;
	
	// после расчета показателя 
	
	// заполним данные в строке
	текСтрокаТрекинга[имяПоказателя] 			= значениеПоказателя;
	Попытка
		текСтрокаТрекинга[имяПоказателя + "Calc"] 	= значениеПоказателяCalc;
	Исключение
	КонецПопытки;
	
	// заполним историю
	элементИстории = ПодготовитьЭлементИстории();
	элементИстории.Показатель 	= имяПоказателя;
	элементИстории.Значение 	= значениеПоказателя;
	элементИстории.Расчетный	= значениеПоказателяCalc;
	элементИстории.Граница		= Граница;
	элементИстории.ПересчетВыполнен = пересчет;
	
	история.Вставить(имяПоказателя, элементИстории);
	
	индексПоказателя = последовательностьРасчета.Найти(имяПоказателя);
	
	// определеяем направление шага
	Если индексПоказателя = последовательностьРасчета.Количество()-1 Тогда
		Возврат; // выход, если рассчитали все показатели
	КонецЕсли;
	
	// если не расчетный, то проверим пред. историю, нет ли там расчетных значений
	Если НЕ значениеПоказателяCalc И индексПоказателя > 0 и не пересчет Тогда
		
		Пересчитать = Ложь;
		точкаНачалаПересчета = -1;
		счет = индексПоказателя-1;
		Пока счет >= 0 Цикл
			элементИстории = история[последовательностьРасчета[счет]];
			Если элементИстории.расчетный и не элементИстории.ПересчетВыполнен Тогда
				точкаНачалаПересчета = счет;
				пересчитать = Истина;
				//Прервать;
			КонецЕсли;
			счет = счет - 1;
		КонецЦикла;
		
		Если Пересчитать Тогда
			
			допПараметры.Пересчет = Истина;
			
			РассчитатьДату(текСтрокаТрекинга, 
							последовательностьРасчета[точкаНачалаПересчета], 
							история[последовательностьРасчета[точкаНачалаПересчета-1]].Граница, 
							менеджерВременныхТаблиц, 
							история, 
							последовательностьРасчета, 
							допПараметры);
			
			Возврат;
			
		КонецЕсли;
		
	КонецЕсли;
	
	допПараметры.ПервыйРасчетный = первыйРасчетный;
	
	Если НЕ значениеПоказателяCalc Тогда
		допПараметры.Пересчет = Ложь;
		допПараметры.ПервыйРасчетный = Ложь;
	КонецЕсли;
	
	
	РассчитатьДату(текСтрокаТрекинга, 
						последовательностьРасчета[индексПоказателя + 1], 
						Граница, 
						менеджерВременныхТаблиц, 
						история, 
						последовательностьРасчета, 
						допПараметры);
	
КонецПроцедуры

Процедура РассчитатьПлановыеПоказатели(ImportTracking, массивСтрокДляПересчета = Неопределено) Экспорт
	
	текущийМомент 		= ТекущаяДата();
	границаСтатистики 	= ДобавитьМесяц(текущийМомент, -24);
	
	строкиДляАнализа 	= ?(массивСтрокДляПересчета = Неопределено, ImportTracking, массивСтрокДляПересчета);
	
	Для каждого текСтр из строкиДляАнализа Цикл
		
		// если загрузили данные для планирования, то не надо пересчитывать т.к. уже есть. 
		//Если текСтр.isPlanData Тогда
		//	Продолжить;
		//КонецЕсли;
		
		Если ЗначениеЗаполнено(текСтр.FreightCostPerKG) Тогда
			Продолжить;
		КонецЕсли;
		
		//Если ЗначениеЗаполнено(текСтр.DOC) Тогда
		//	Продолжить;
		//КонецЕсли;
		
		Если не ЗначениеЗаполнено(текСтр.PODCode) И Не ЗначениеЗаполнено(текСтр.RequestedPOACode) И не ЗначениеЗаполнено(текСтр.MOTCode) Тогда
			Продолжить;
		КонецЕсли;
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	СУММА(ParcelGoods.GrossWeightKG) КАК GrossWeightKG,
		|	ParcelGoods.СтрокаИнвойса
		|ПОМЕСТИТЬ ВТ_ГодныеDOCs
		|ИЗ
		|	Документ.Поставка.УпаковочныеЛисты КАК ПоставкаУпаковочныеЛисты
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Parcels КАК DOCsParcels
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelGoods
		|			ПО DOCsParcels.Parcel = ParcelGoods.Ссылка
		|		ПО (DOCsParcels.Ссылка = ПоставкаУпаковочныеЛисты.УпаковочныйЛист)
		|ГДЕ
		|	ПоставкаУпаковочныеЛисты.Ссылка.CollectedFromPort МЕЖДУ &НачалоПериода И &КонецПериода
		|	И ПоставкаУпаковочныеЛисты.Ссылка.POD.Код = &PODCode
		|	И ПоставкаУпаковочныеЛисты.Ссылка.MOT.Код = &MOTCode
		|	И ПоставкаУпаковочныеЛисты.Ссылка.ActualPOA.Код = &RequestedPOACode
		|	И DOCsParcels.Ссылка.Проведен
		|	И НЕ ParcelGoods.СтрокаИнвойса.ПометкаУдаления
		|	И НЕ ParcelGoods.Ссылка.Отменен
		|	И ParcelGoods.Ссылка.HazardClass = &HazardClass
		|
		|СГРУППИРОВАТЬ ПО
		|	ParcelGoods.СтрокаИнвойса
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СУММА(ВТ_ГодныеDOCs.GrossWeightKG) КАК GrossWeightKG
		|ПОМЕСТИТЬ ВТ_TotalGrossWeight
		|ИЗ
		|	ВТ_ГодныеDOCs КАК ВТ_ГодныеDOCs
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВЫБОР
		|		КОГДА ВТ_TotalGrossWeight.GrossWeightKG = 0
		|			ТОГДА 0
		|		ИНАЧЕ InvoiceLinesCostsОбороты.СуммаОборот / ВТ_TotalGrossWeight.GrossWeightKG
		|	КОНЕЦ КАК ФрахтСтатистика
		|ИЗ
		|	РегистрНакопления.InvoiceLinesCosts.Обороты(
		|			,
		|			,
		|			,
		|			ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ИнвойсПеревозка)
		|				И СтрокаИнвойса В
		|					(ВЫБРАТЬ
		|						ВТ_ГодныеDOCs.СтрокаИнвойса
		|					ИЗ
		|						ВТ_ГодныеDOCs КАК ВТ_ГодныеDOCs)) КАК InvoiceLinesCostsОбороты,
		|	ВТ_TotalGrossWeight КАК ВТ_TotalGrossWeight";
		
		Запрос.УстановитьПараметр("RequestedPOACode", СокрЛП(текСтр.RequestedPOACode)); 
		Запрос.УстановитьПараметр("PODCode",          СокрЛП(текСтр.PODCode));
		Запрос.УстановитьПараметр("MOTCode", 	      СокрЛП(текСтр.MOTCode));
		
		Запрос.УстановитьПараметр("HazardClass", ?(ЗначениеЗаполнено(текСтр.HazardClass), текСтр.HazardClass, Справочники.HazardClasses.NonHazardous));
		
		Запрос.УстановитьПараметр("КонецПериода", КонецДня(текущийМомент));
		Запрос.УстановитьПараметр("НачалоПериода", НачалоДня(границаСтатистики));
		
		УстановитьПривилегированныйРежим(Истина);
		
		Результат = Запрос.Выполнить().Выбрать();
		
		УстановитьПривилегированныйРежим(Ложь);
		
		Если Результат.Следующий() Тогда
			
			Если Результат.ФрахтСтатистика <> 0 Тогда
				
				текСтр.FreightCostPerKG = Результат.ФрахтСтатистика;
				текСтр.TotalFreightCost = текСтр.TotalGrossWeightKG * текСтр.FreightCostPerKG;
				
				текСтр.isStatisticData	= Истина;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Функция расчитывает даты по факту или по процентилю
// Параметры:
//		ImportTracking - Таблица значений\Таблица формы
//
Процедура РассчитатьДатыDomestic(DomesticTracking, массивСтрокДляПересчета = Неопределено) Экспорт
	
	массивКалков = Новый Массив; 
	массивКалков.Добавить("DepartureFromSourceCalc");
	массивКалков.Добавить("DeliveryToLocationCalc");
	
	строкиДляАнализа = ?(массивСтрокДляПересчета = Неопределено, DomesticTracking, массивСтрокДляПересчета);
	
	Для каждого текСтрокаТрекинга из строкиДляАнализа  Цикл
		
		// Ready to ship
		граница = ?(НЕ ЗначениеЗаполнено(текСтрокаТрекинга.ReadyToShip), ТекущаяДата(), текСтрокаТрекинга.ReadyToShip);
		
		// Departure from source
		DepartureFromSource = текСтрокаТрекинга.DepartureFromSource;
		
		расчетный = Ложь;
		Если НЕ ЗначениеЗаполнено(DepartureFromSource) Тогда
			расчетный = Истина;
			граница = ТекущаяДата();
			// { RGS AArsentev 03.07.2017
			PlannedDepartureLocalTime = текСтрокаТрекинга.PlannedDepartureLocalTime;
			Если НЕ ЗначениеЗаполнено(PlannedDepartureLocalTime) Тогда
				PlannedDepartureLocalTime = Дата("01.01.0001 00:00:00");
			КонецЕсли;
			//DepartureFromSource = ?(текСтрокаТрекинга.PlannedDepartureLocalTime < граница, граница, текСтрокаТрекинга.PlannedDepartureLocalTime);
			DepartureFromSource = ?(PlannedDepartureLocalTime < граница, граница, текСтрокаТрекинга.PlannedDepartureLocalTime);
			// } RGS AArsentev 03.07.2017
		КонецЕсли;
		
		текСтрокаТрекинга.DepartureFromSource 		= DepartureFromSource;
		текСтрокаТрекинга.DepartureFromSourceCalc 	= расчетный;	
		
		Если ЗначениеЗаполнено(DepartureFromSource) Тогда
			граница = DepartureFromSource;
		Иначе
			текСтрокаТрекинга.DepartureFromSource 		= граница;
			текСтрокаТрекинга.DepartureFromSourceCalc 	= Истина;
		КонецЕсли;

		// Delivery To Location
		DeliveryToLocation = текСтрокаТрекинга.DeliveryToLocation;
		             		
		расчетный = Ложь;
		Если НЕ ЗначениеЗаполнено(DeliveryToLocation) Тогда
			расчетный = Истина;
			граница = ТекущаяДата();
			Если ЗначениеЗаполнено(текСтрокаТрекинга.PlannedDeliveryToLocation) и текСтрокаТрекинга.PlannedDeliveryToLocation > граница Тогда
				DeliveryToLocation = текСтрокаТрекинга.PlannedDeliveryToLocation;
			иначе	
				DeliveryToLocation = ПолучитьПроцентиль90Domestic(граница, текСтрокаТрекинга.LocationFrom, текСтрокаТрекинга.LocationTo, текСтрокаТрекинга.MOT);
			КонецЕсли;
		КонецЕсли;
		
		текСтрокаТрекинга.DeliveryToLocation 		= DeliveryToLocation;
		текСтрокаТрекинга.DeliveryToLocationCalc 	= расчетный;	
		
		Если НЕ ЗначениеЗаполнено(DeliveryToLocation) Тогда
			текСтрокаТрекинга.DeliveryToLocation 	    = граница;
			текСтрокаТрекинга.DeliveryToLocationCalc 	= Истина;
		КонецЕсли;

		// Проверим раскраску. Если какая-то дата синяя, то до нее не должно быть желтых
		счет = массивКалков.Количество()-1;
		Пока счет >= 0 Цикл
			
			Если НЕ текСтрокаТрекинга[массивКалков[счет]] Тогда
				
				Для счетУровеньДва = 0 по счет - 1 Цикл
					текСтрокаТрекинга[массивКалков[счетУровеньДва]] = Ложь;					
				КонецЦикла;
				Прервать;
				
			КонецЕсли;
			
			счет = счет - 1;
			
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры 

Функция ПолучитьСписокДобавляемыхКолонок() Экспорт
	
	массивКолонок = Новый Массив;
	
	массивКолонок.Добавить("OrderCreatedCalc");
	массивКолонок.Добавить("SupplierAvailabilityCalc");	
	массивКолонок.Добавить("ReceivedByHubCalc");
	массивКолонок.Добавить("ShipmentPreparedByHubCalc");
	массивКолонок.Добавить("DestinationGreenLightReleaseCalc");
	массивКолонок.Добавить("ShippedByHubCalc");
	массивКолонок.Добавить("ArrivedAtPortOfEntryCalc");
	массивКолонок.Добавить("CustomsClearanceCalc");
	массивКолонок.Добавить("DeliveryToLocationCalc");
	массивКолонок.Добавить("ReceiptConfirmedByLocationCalc");
	массивКолонок.Добавить("Supplier");
	массивКолонок.Добавить("WarehouseTo");
	массивКолонок.Добавить("RDD");
	массивКолонок.Добавить("CustomsFile");
	массивКолонок.Добавить("Shipment");
	массивКолонок.Добавить("DOC");
	массивКолонок.Добавить("Invoice");
	массивКолонок.Добавить("Item");
	
	массивКолонок.Добавить("HazardClass");
	массивКолонок.Добавить("isManualData");
	массивКолонок.Добавить("isStatisticData");
	массивКолонок.Добавить("isManualItem");
	
	Возврат массивКолонок;
	
КонецФункции

Процедура ДобавитьРасчетныеКолонки(ImportTracking) Экспорт
	
	ImportTracking.Колонки.Добавить("OrderCreated", 					ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.Дата));
	ImportTracking.Колонки.Добавить("SupplierAvailability", 			ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.Дата));
	ImportTracking.Колонки.Добавить("ReceivedByHub", 					ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.Дата));
	ImportTracking.Колонки.Добавить("ShipmentPreparedByHub", 			ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.Дата));
	ImportTracking.Колонки.Добавить("DestinationGreenLightRelease", 	ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.Дата));
	ImportTracking.Колонки.Добавить("ShippedByHub", 					ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.Дата));
	ImportTracking.Колонки.Добавить("ArrivedAtPortOfEntry", 			ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.Дата));
	ImportTracking.Колонки.Добавить("CustomsClearance", 				ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.Дата));
	ImportTracking.Колонки.Добавить("DeliveryToLocation", 				ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.Дата));
	ImportTracking.Колонки.Добавить("ReceiptConfirmedByLocation", 		ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.Дата));
	ImportTracking.Колонки.Добавить("RequiredDeliveryDate", 			ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.Дата));
	    
	ImportTracking.Колонки.Добавить("OrderCreatedCalc", 				Новый ОписаниеТипов("Булево"));
	ImportTracking.Колонки.Добавить("SupplierAvailabilityCalc", 		Новый ОписаниеТипов("Булево"));
	ImportTracking.Колонки.Добавить("ReceivedByHubCalc", 				Новый ОписаниеТипов("Булево"));
	ImportTracking.Колонки.Добавить("ShipmentPreparedByHubCalc", 		Новый ОписаниеТипов("Булево"));
	ImportTracking.Колонки.Добавить("DestinationGreenLightReleaseCalc", Новый ОписаниеТипов("Булево"));
	ImportTracking.Колонки.Добавить("ShippedByHubCalc", 				Новый ОписаниеТипов("Булево"));
	ImportTracking.Колонки.Добавить("ArrivedAtPortOfEntryCalc", 		Новый ОписаниеТипов("Булево"));
	ImportTracking.Колонки.Добавить("CustomsClearanceCalc", 			Новый ОписаниеТипов("Булево"));
	ImportTracking.Колонки.Добавить("DeliveryToLocationCalc", 			Новый ОписаниеТипов("Булево"));
	ImportTracking.Колонки.Добавить("ReceiptConfirmedByLocationCalc", 	Новый ОписаниеТипов("Булево"));
	
КонецПроцедуры

Функция СформироватьВложениеIntДляПроекта(ProjectMobilization) Экспорт
		
	ТабДок = Новый ТабличныйДокумент;
	// собираем данные в единый таб. док отчет и таблицу
	
	// 1. Сначала отчет по прогрессу
	
	ОтчетОбъект = Отчеты.DPMExecutionProgress.Создать();
	
	СхемаКомпоновки = ОтчетОбъект.ПолучитьМакет("ОсновнаяСхемаКомпоновкиДанных");
	НастройкиПоУмолчанию = СхемаКомпоновки.НастройкиПоУмолчанию;
	
	элемент = НастройкиПоУмолчанию.ПараметрыДанных.Элементы.Найти("ProjectMobilization");
	элемент.Использование 	= Истина; 
	элемент.Значение 		= ProjectMobilization; 
	
	ОтчетОбъект.КомпоновщикНастроек.ЗагрузитьНастройки(НастройкиПоУмолчанию);
	
	ДанныеРасшифровки = Новый ДанныеРасшифровкиКомпоновкиДанных;
	ОтчетОбъект.СкомпоноватьРезультат(ТабДок, ДанныеРасшифровки);	
	
	Диаграмма = ТабДок.Рисунки[0];
	//	ОбластьЛегенды 		= Диаграмма.ОбластьЛегенды;
	//	ОбластьПостроения 	= Диаграмма.ОбластьПостроения;
	
	// добавим подпись оси поверх картинки диаграммы
	Рисунок = ТабДок.Рисунки.Добавить(ТипРисункаТабличногоДокумента.Текст); 
	Рисунок.Текст = "Number of orders";
	Рисунок.ОриентацияТекста = 90;
	
	Рисунок.ГраницаСправа = Ложь;
	Рисунок.ГраницаСверху = Ложь;
	Рисунок.ГраницаСлева  = Ложь;
	Рисунок.ГраницаСнизу  = Ложь;
	
	Рисунок.ГоризонтальноеПоложение = ГоризонтальноеПоложение.Центр;
	Рисунок.ВертикальноеПоложение	= ВертикальноеПоложение.Центр;
	
	Рисунок.Верх 	= Диаграмма.Верх; 
	Рисунок.Высота 	= Диаграмма.Высота-40; 
	Рисунок.Ширина 	= 5; 
	Рисунок.Лево 	= Диаграмма.Лево + 15;
	
	// 2. Потом таблицу с данными по проекту
	
	начало = ТабДок.ВысотаТаблицы + 3;
	
	ТаблицаДанных = Обработки.ImportExportTracking.ПолучитьТаблицуДанных(Перечисления.ImportTrackingMainFilters.ProjectMobilization, ProjectMobilization);
	
	Обработки.ImportExportTracking.ДобавитьРасчетныеКолонки(ТаблицаДанных);
	Обработки.ImportExportTracking.РассчитатьДаты(ТаблицаДанных);
	
	массивДобавленныхКолонок = ПолучитьСписокДобавляемыхКолонок();
	
	макет = ПолучитьМакетТаблицы();
	
	ТабДок.Вывести(Макет.ПолучитьОбласть("ЗаголовокТаблицы"));
	
	Желтый = WebЦвета.Желтый;
	Синий  = WebЦвета.СветлоНебесноГолубой;
	
	Для каждого текСтр из ТаблицаДанных Цикл
		
		счетПараметра = 1;
		
		областьСтрока = макет.ПолучитьОбласть("Строка");
		
		//ЗаполнитьЗначенияСвойств(областьСтрока.Параметры, текСтр);
		областьСтрока.Параметры.НомерСтроки = счетПараметра;
		//
		
		Для каждого текКолонка из ТаблицаДанных.Колонки Цикл
			
			Если НЕ массивДобавленныхКолонок.Найти(текКолонка.Имя) = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			
			значение = текСтр[текКолонка.Имя]; 
			
			Если ЗначениеЗаполнено(значение) Тогда
				Если ТипЗнч(значение) = Тип("Дата") Тогда
					областьСтрока.Параметры[текКолонка.Имя] = Формат(значение, "ДЛФ=D");
				Иначе
					Попытка
						областьСтрока.Параметры[текКолонка.Имя] = значение;
					Исключение
						Продолжить;
					КонецПопытки;
				КонецЕсли;
			КонецЕсли;
			
			имяРасчетного = текКолонка.Имя + "Calc";
			
			Если НЕ ТаблицаДанных.Колонки.Найти(имяРасчетного) = Неопределено Тогда
				
				Область = областьСтрока.Область(текКолонка.Имя);
				Если текСтр[имяРасчетного] Тогда
					Область.ЦветФона = Желтый;
				Иначе
					Область.ЦветФона = Синий;
				КонецЕсли;
				
			КонецЕсли;
						
		КонецЦикла;
		
		ТабДок.Вывести(областьСтрока);
		
	КонецЦикла;
	
	Возврат ТабДок;
	
КонецФункции

Функция СформироватьТабДокDomesticДляПроекта(ProjectMobilization) Экспорт
		
	ТабДок = Новый ТабличныйДокумент;
	
	ВывестиОтчетDomestic(ТабДок, ProjectMobilization);
	                                         	
	// 2. Потом таблицу с данными по проекту
	
	начало = ТабДок.ВысотаТаблицы + 3;
	
	ТаблицаДанных = ПолучитьТаблицуДанныхDomestic(Перечисления.DomesticPlanningMainFilters.ProjectMobilization, ProjectMobilization);
	
	ТаблицаДанных.Колонки.Добавить("DeliveryToLocationCalc", Новый ОписаниеТипов("Булево"));
	ТаблицаДанных.Колонки.Добавить("DepartureFromSourceCalc", Новый ОписаниеТипов("Булево"));

	Обработки.ImportExportTracking.РассчитатьДатыDomestic(ТаблицаДанных);
	
	макет = ПолучитьМакетТаблицыDomestic();
	
	ТабДок.Вывести(Макет.ПолучитьОбласть("ЗаголовокТаблицыDomestic"));
	
	Желтый = WebЦвета.Желтый;
	Синий  = WebЦвета.СветлоНебесноГолубой;
	
	Для каждого текСтр из ТаблицаДанных Цикл
		
		областьСтрока = макет.ПолучитьОбласть("СтрокаDomestic");
		
		ЗаполнитьЗначенияСвойств(областьСтрока.Параметры, текСтр);

		DepartureFromSourceCalc = текСтр["DepartureFromSourceCalc"];
		
		Область = областьСтрока.Область("DepartureFromSource");
		Если DepartureFromSourceCalc Тогда
			Область.ЦветФона = Желтый;	
		Иначе
			Область.ЦветФона = Синий;
		КонецЕсли;

		DeliveryToLocationCalc = текСтр["DeliveryToLocationCalc"];
		
		Область = областьСтрока.Область("DeliveryToLocation");
		Если DeliveryToLocationCalc Тогда
			Область.ЦветФона = Желтый;
		Иначе
			Область.ЦветФона = Синий;
		КонецЕсли;
		           		
		ТабДок.Вывести(областьСтрока);
		
	КонецЦикла;
	
	Возврат ТабДок;
	
КонецФункции

Процедура ВывестиОтчетDomestic(ТабДок, ProjectMobilization) Экспорт 
	
	ОтчетОбъектDomestic = Отчеты.DPMExecutionProgress_Domestic.Создать();

	СхемаКомпоновкиDomestic = ОтчетОбъектDomestic.ПолучитьМакет("ОсновнаяСхемаКомпоновкиДанныхDomestic");
	НастройкиПоУмолчанию = СхемаКомпоновкиDomestic.НастройкиПоУмолчанию;
	
	элемент = НастройкиПоУмолчанию.ПараметрыДанных.Элементы.Найти("ProjectMobilization");
	элемент.Использование 	= Истина; 
	элемент.Значение 		= ProjectMobilization; 
	
	элементНач = НастройкиПоУмолчанию.ПараметрыДанных.Элементы.Найти("ReadyToShipНачало");
	элементНач.Использование 	= Истина; 
	элементНач.Значение 		= Дата(2001,01,01);

	элементКон = НастройкиПоУмолчанию.ПараметрыДанных.Элементы.Найти("ReadyToShipКонец");
	элементКон.Использование 	= Истина; 
	элементКон.Значение 		= Дата(3001,01,01);
	
	ОтчетОбъектDomestic.КомпоновщикНастроек.ЗагрузитьНастройки(НастройкиПоУмолчанию);
	
	ДанныеРасшифровкиDomestic = Новый ДанныеРасшифровкиКомпоновкиДанных;
	ОтчетОбъектDomestic.СкомпоноватьРезультат(ТабДок, ДанныеРасшифровкиDomestic);	
	
	ДиаграммаDomestic = ТабДок.Рисунки[0];
	
	// добавим подпись оси поверх картинки диаграммы
	Рисунок = ТабДок.Рисунки.Добавить(ТипРисункаТабличногоДокумента.Текст); 
	Рисунок.Текст = "Number of orders";
	Рисунок.ОриентацияТекста = 90;
	
	Рисунок.ГраницаСправа = Ложь;
	Рисунок.ГраницаСверху = Ложь;
	Рисунок.ГраницаСлева  = Ложь;
	Рисунок.ГраницаСнизу  = Ложь;
	
	Рисунок.ГоризонтальноеПоложение = ГоризонтальноеПоложение.Центр;
	Рисунок.ВертикальноеПоложение	= ВертикальноеПоложение.Центр;
	
	Рисунок.Верх 	= ДиаграммаDomestic.Верх; 
	Рисунок.Высота 	= ДиаграммаDomestic.Высота-40; 
	Рисунок.Ширина 	= 5; 
	Рисунок.Лево 	= ДиаграммаDomestic.Лево + 15;	
	
КонецПроцедуры

// Вспомогательная функция

// функция считает процентиль для указанного показателя и возвращает дату 
// со смещением на полученое значение от переданной границы. 
Функция ПолучитьПроцентиль90(менеджерВременныхТаблиц, текСтрока, имяПоказателя, границаПериода, этоPO, этоМИ, этоПлан)
		
	СоответствиеИменПоказателей = Новый Соответствие;
	СоответствиеИменПоказателей.Вставить("SupplierAvailability", 		"Leg1Days");
	
	Если этоПлан Тогда	
		
		СоответствиеИменПоказателей.Вставить("ReceivedByHub", 		 		"Leg2DaysPlan");
		СоответствиеИменПоказателей.Вставить("ShipmentPreparedByHub", 		"Leg3DaysPlan");  
		СоответствиеИменПоказателей.Вставить("DestinationGreenLightRelease","Leg4DaysPlan");
		СоответствиеИменПоказателей.Вставить("ShippedByHub", 				"Leg5ADaysPlan");
		СоответствиеИменПоказателей.Вставить("ArrivedAtPortOfEntry", 		"Leg5BDaysPlan");
		СоответствиеИменПоказателей.Вставить("CustomsClearance", 			"Leg6DaysPlan");
		СоответствиеИменПоказателей.Вставить("DeliveryToLocation", 			"Leg7DaysPlan");
		СоответствиеИменПоказателей.Вставить("ReceiptConfirmedByLocation", 	"Leg7DaysPlan");
		
	ИначеЕсли этоPO Тогда
		СоответствиеИменПоказателей.Вставить("ReceivedByHub", 		 		"Leg2DaysPOLine");
		СоответствиеИменПоказателей.Вставить("ShipmentPreparedByHub", 		"Leg3DaysPOLine");  
		СоответствиеИменПоказателей.Вставить("DestinationGreenLightRelease","Leg4DaysPOLine");
		СоответствиеИменПоказателей.Вставить("ShippedByHub", 				"Leg5ADaysPOLine");
		СоответствиеИменПоказателей.Вставить("ArrivedAtPortOfEntry", 		"Leg5BDaysPOLine");
		СоответствиеИменПоказателей.Вставить("CustomsClearance", 			"Leg6DaysPOLine");
		СоответствиеИменПоказателей.Вставить("DeliveryToLocation", 			"Leg7DaysPOLine");
		СоответствиеИменПоказателей.Вставить("ReceiptConfirmedByLocation", 	"Leg7DaysPOLine");
		
	ИначеЕсли этоМИ Тогда
		
		СоответствиеИменПоказателей.Вставить("ReceivedByHub", 		 		"Leg2DaysManualItem");
		СоответствиеИменПоказателей.Вставить("ShipmentPreparedByHub", 		"Leg3DaysManualItem");  
		СоответствиеИменПоказателей.Вставить("DestinationGreenLightRelease","Leg4DaysManualItem");
		СоответствиеИменПоказателей.Вставить("ShippedByHub", 				"Leg5ADaysManualItem");
		СоответствиеИменПоказателей.Вставить("ArrivedAtPortOfEntry", 		"Leg5BDaysManualItem");
		СоответствиеИменПоказателей.Вставить("CustomsClearance", 			"Leg6DaysManualItem");
		СоответствиеИменПоказателей.Вставить("DeliveryToLocation", 			"Leg7DaysManualItem");
		СоответствиеИменПоказателей.Вставить("ReceiptConfirmedByLocation", 	"Leg7DaysManualItem");
					
	Иначе
		СоответствиеИменПоказателей.Вставить("ReceivedByHub", 		 		"Leg2Days");
		СоответствиеИменПоказателей.Вставить("ShipmentPreparedByHub", 		"Leg3Days");  
		СоответствиеИменПоказателей.Вставить("DestinationGreenLightRelease","Leg4Days");
		СоответствиеИменПоказателей.Вставить("ShippedByHub", 				"Leg5ADays");
		СоответствиеИменПоказателей.Вставить("ArrivedAtPortOfEntry", 		"Leg5BDays");
		СоответствиеИменПоказателей.Вставить("CustomsClearance", 			"Leg6Days");
		СоответствиеИменПоказателей.Вставить("DeliveryToLocation", 			"Leg7Days");
		СоответствиеИменПоказателей.Вставить("ReceiptConfirmedByLocation", 	"Leg7Days");
	КонецЕсли;
	
	имяЛега = СоответствиеИменПоказателей.Получить(имяПоказателя);
	
	соответствиеФильтров = ПодготовитьСоответствиеФильтров();
	
	фильтр = соответствиеФильтров.Получить(имяЛега);
	
	структураФильтр = Новый Структура;
	структураФильтр.Вставить("этоРО", этоPO);
	структураФильтр.Вставить("этоMI", этоМИ);
	структураФильтр.Вставить("этоПлан", этоПлан);
				
	Для каждого текЭлементФильтра из фильтр Цикл
			
		Если текЭлементФильтра = "HUB" Тогда
			
			
			значениеФильтра 		= Неопределено;
			
			Если этоPO Тогда   				
				значениеФильтра = СокрЛП(текСтрока.item.hub1);
			Иначе
				значениеФильтра = СокрЛП(текСтрока.item.СтрокаЗаявкиНаЗакупку.hub1);
			КонецЕсли;

			Если ЗначениеЗаполнено(значениеФильтра) Тогда 
				структураФильтр.Вставить(текЭлементФильтра, значениеФильтра);
			иначе
				
				Если ЗначениеЗаполнено(текСтрока.PODCode) Тогда
					
					значениеФильтра = Справочники.CountriesHUBs.НайтиПоКоду(СокрЛП(текСтрока.PODCode));
					Если ЗначениеЗаполнено(значениеФильтра) Тогда 
						структураФильтр.Вставить("POD", значениеФильтра);
					КонецЕсли;
					
				КонецЕсли;

			КонецЕсли;     
						
		ИначеЕсли текЭлементФильтра = "POD" Тогда	
			
			значениеФильтра 		= Неопределено;
			
			Если ЗначениеЗаполнено(текСтрока.DOC) Тогда
				значениеФильтра = текСтрока.DOC[текЭлементФильтра];
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(значениеФильтра) И ЗначениеЗаполнено(текСтрока.PODCode) Тогда			
				значениеФильтра = Справочники.CountriesHUBs.НайтиПоКоду(СокрЛП(текСтрока.PODCode)); 				
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(значениеФильтра) И этоPO Тогда
				
				//искать POD как (#+ Hub1), если POD найден – то использовать фильтр POD. Если POD не найден – то использовать фильтр HUB по Hub1.
				
				Если ЗначениеЗаполнено(текСтрока.item.hub1) Тогда 
					
					значениеФильтра = Справочники.CountriesHUBs.НайтиПоКоду("#" + СокрЛП(текСтрока.item.hub1));
					
					Если Не ЗначениеЗаполнено(значениеФильтра) Тогда 
						структураФильтр.Вставить("HUB", СокрЛП(текСтрока.item.hub1));
					КонецЕсли;
					
				КонецЕсли;
				
			КонецЕсли;
			
			Если ЗначениеЗаполнено(значениеФильтра) Тогда
				структураФильтр.Вставить(текЭлементФильтра, значениеФильтра);
			КонецЕсли;				
		
		ИначеЕсли текЭлементФильтра = "MOT" Тогда
			
			значениеФильтра = Неопределено;
			
			Если ЗначениеЗаполнено(текСтрока.DOC) Тогда
				значениеФильтра = текСтрока.DOC[текЭлементФильтра];
			КонецЕсли;
			
			Если Не ЗначениеЗаполнено(значениеФильтра) Тогда
								
				Если ЗначениеЗаполнено(текСтрока.MOTCode) Тогда
					значениеФильтра = Справочники.MOTs.НайтиПоКоду(текСтрока.MOTCode);	
				КонецЕсли;
				
			КонецЕсли;
			
			Если ЗначениеЗаполнено(значениеФильтра) Тогда
				структураФильтр.Вставить(текЭлементФильтра, значениеФильтра);
			КонецЕсли;
						
		ИначеЕсли текЭлементФильтра = "GeoMarket" Тогда
			
			значениеФильтра = Неопределено;
			
			Если этоPO Тогда
				
				Если ЗначениеЗаполнено(текСтрока.item.КостЦентр) Тогда
					значениеФильтра = текСтрока.item.КостЦентр.GeoMarket;
				КонецЕсли; 
				
			ИначеЕсли этоМИ Тогда
				
				Если ЗначениеЗаполнено(текСтрока.item.Владелец.GeoMarket) Тогда
					значениеФильтра = текСтрока.item.Владелец.GeoMarket;
				КонецЕсли;
				
			КонецЕсли;     			
			
			Если ЗначениеЗаполнено(значениеФильтра) Тогда
				структураФильтр.Вставить(текЭлементФильтра, значениеФильтра);
			КонецЕсли;
			
		ИначеЕсли текЭлементФильтра = "POA" Тогда 	
			
			значениеФильтра = Неопределено;
			
			Если ЗначениеЗаполнено(текСтрока.Shipment) Тогда
				значениеФильтра = текСтрока.Shipment["ActualPOA"];	
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(значениеФильтра) Тогда
				
				Если ЗначениеЗаполнено(текСтрока.DOC) Тогда
					
					значениеФильтра = текСтрока.DOC["RequestedPOA"];	
					
				КонецЕсли; 
				
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(значениеФильтра) И ЗначениеЗаполнено(текСтрока.RequestedPOACode) Тогда
				
				значениеФильтра = Справочники.SeaAndAirPorts.НайтиПоКоду(текСтрока.RequestedPOACode);
				
			КонецЕсли;
			
			Если ЗначениеЗаполнено(значениеФильтра) Тогда
				структураФильтр.Вставить(текЭлементФильтра, значениеФильтра);	
			КонецЕсли;
			
		Иначе
		
			// в фильтр идут только те значения, которые заполнены
			Если ЗначениеЗаполнено(текСтрока[текЭлементФильтра]) Тогда
			
				структураФильтр.Вставить(текЭлементФильтра, текСтрока[текЭлементФильтра]);
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	  	
	// для PO и MI если не заполнен фильтр по MOT, то нужно брать гео. маркет. 
	// данное условие прописано при формировании запроса отбора статистики. 
	// тут лишь признак необходимости расчета. 
	//
	Если Не ЗначениеЗаполнено(текСтрока.DOC) И фильтр.найти("MOT") <> Неопределено И Не структураФильтр.Свойство("MOT") Тогда
		                           				
		// добавить геомаркет
		значениеФильтра = Неопределено;
		
		Если этоPO Тогда
			
			Если ЗначениеЗаполнено(текСтрока.item.КостЦентр) Тогда
				значениеФильтра = текСтрока.item.КостЦентр.GeoMarket;
			КонецЕсли; 
			
		ИначеЕсли этоМИ Тогда
			
			Если ЗначениеЗаполнено(текСтрока.item.Владелец.GeoMarket) Тогда
				значениеФильтра = текСтрока.item.Владелец.GeoMarket;
			КонецЕсли;
			
		КонецЕсли;
				
		Если ЗначениеЗаполнено(значениеФильтра) Тогда
			структураФильтр.Вставить("GeoMarketForMOT", значениеФильтра);
		КонецЕсли;
		
	КонецЕсли;
	
	// если для плановых показателей не удалось вычислить фильтр РОА, то работаем по геомаркету. Иначе, по РОА
	Если этоПлан и (этоPO или этоМИ) И структураФильтр.Свойство("POA") И НЕ ЗначениеЗаполнено(структураФильтр.POA) Тогда
		структураФильтр.Удалить("POA");
	ИначеЕсли этоПлан и (этоPO или этоМИ) И структураФильтр.Свойство("Geomarket") И структураФильтр.Свойство("POA") И ЗначениеЗаполнено(структураФильтр.POA) Тогда 
		структураФильтр.Удалить("Geomarket");
	КонецЕсли;
	
	//сдвиг = Рассчитать90Percent(имяЛега, менеджерВременныхТаблиц, структураФильтр);
	сдвиг = РассчитатьAverageTop10(имяЛега, менеджерВременныхТаблиц, структураФильтр); 
	
	сдвиг = ?(сдвиг = Неопределено, 0, сдвиг); 
	
	// если расчетной даты нет, то просто пустое значение отдаем иначе сдвигаем границу
	Возврат ?(сдвиг = 0, Неопределено, границаПериода + сдвиг * 86400); // количество дней в секундах
	
КонецФункции

// Функция вычисления среднего значения Top10-повторений:
// 	Считаем кол-во повторений (СOUNTIF), например, товары от Supplier на Hub доставляются чаще всего в тот же день, так как для многих товаров Leg 2 - 0;
//	Выбираем наибольшее кол-во повторений (Top 10);
//	Рассчитываем среднее значение (использовала формулу  aggregate, так как фильтровала Top 10).
Функция РассчитатьAverageTop10(Знач Leg, менеджерВременныхТаблиц, фильтр)
	
	Leg = СтрЗаменить(Leg, "POLine", "");
	Leg = СтрЗаменить(Leg, "ManualItem", "");
	Leg = СтрЗаменить(Leg, "Plan", "");
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = менеджерВременныхТаблиц;
	
//ВЫБРАТЬ ПЕРВЫЕ 10
//	LegStatistics.Leg4Days КАК LegDays,
//	Сумма(LegStatistics.ItemCount) КАК ItemCount
//ИЗ
//	РегистрСведений.LegStatistics КАК LegStatistics
//ГДЕ
//	LegStatistics.POD = &POD
//	И LegStatistics.MOT = &MOT
//СГРУППИРОВАТЬ ПО
//	LegStatistics.Leg4Days
//УПОРЯДОЧИТЬ ПО
//	ItemCount УБЫВ
//ИТОГИ
//	СРЕДНЕЕ(LegDays)
//ПО
//	ОБЩИЕ
	
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 10
	|	СУММА(РезультатСборкиЛего.ItemCount) КАК ItemCount #ПоляВыборки
	|ИЗ
	|	РезультатСборкиЛего КАК РезультатСборкиЛего
	|ГДЕ
	|#УсловиеОтбора
	|
	|СГРУППИРОВАТЬ ПО
	|	#ПоляГруппировки
	|
	|УПОРЯДОЧИТЬ ПО
	|	ItemCount УБЫВ
	|ИТОГИ
	|	СРЕДНЕЕ(#ПоляИтогов)
	|ПО
	|	ОБЩИЕ";
	
	Запрос.Текст 	= СтрЗаменить(Запрос.Текст, "#ПоляВыборки",     ", РезультатСборкиЛего." + Leg + " КАК LegDays ");
	Запрос.Текст    = СтрЗаменить(Запрос.Текст, "#ПоляГруппировки", "РезультатСборкиЛего." + Leg);
	Запрос.Текст	= СтрЗаменить(Запрос.Текст, "#ПоляИтогов",  Leg);
	
	УсловиеОтбора = "ИСТИНА";
	
	этоРО = Фильтр.Свойство("этоРО");
	этоMI = Фильтр.Свойство("этоMI");
	этоПлан = Фильтр.Свойство("этоПлан");
	
	кодыГеомаркетов = Новый Массив;
	кодыГеомаркетов.Добавить("RUL");
	кодыГеомаркетов.Добавить("ASG");
	кодыГеомаркетов.Добавить("SKG");
	
	Для каждого текЭлемент из Фильтр Цикл
		
		Если текЭлемент.Ключ = "этоРО" Тогда
			Продолжить;
		КонецЕсли;
		
		Если текЭлемент.Ключ = "этоMI" Тогда
			Продолжить;
		КонецЕсли;
		
		Если текЭлемент.Ключ = "этоПлан" Тогда
			Продолжить;
		КонецЕсли;
		
		// пустые фильтры игнорируем
		Если НЕ ЗначениеЗаполнено(текЭлемент.Значение) Тогда
			Продолжить;
		КонецЕсли;
		
		Если текЭлемент.Ключ = "GeoMarketForMOT" и Leg <> "Leg1Days" и Leg <> "Leg2Days" и Leg <> "Leg7Days" 
			И Не Фильтр.Свойство("MOT") Тогда
			
			Если ЗначениеЗаполнено(текЭлемент.Значение) И 
				НЕ кодыГеомаркетов.Найти(СокрЛП(текЭлемент.Значение.Код)) = Неопределено Тогда
				УсловиеОтбора = УсловиеОтбора + Символы.ПС + "И РезультатСборкиЛего.MOT.КОД = ""SEA"""; 
			Иначе
				УсловиеОтбора = УсловиеОтбора + Символы.ПС + "И НЕ РезультатСборкиЛего.MOT В (Значение(Справочник.MOTs.AIR), Значение(Справочник.MOTs.COURIER))"; 
			КонецЕсли;
			
		иначе
			
			//Если текЭлемент.Ключ = "POD" И ТипЗнч(текЭлемент.Значение) <> Тип("СправочникСсылка.CountriesHUBs") Тогда
			//	УсловиеОтбора = УсловиеОтбора + Символы.ПС + "И РезультатСборкиЛего." + текЭлемент.Ключ + ".Код = &" + текЭлемент.Ключ; 
			//Иначе
				УсловиеОтбора = УсловиеОтбора + Символы.ПС + "И РезультатСборкиЛего." + текЭлемент.Ключ + " = &" + текЭлемент.Ключ; 
			//КонецЕсли;
			
		КонецЕсли;
				
		Запрос.УстановитьПараметр(текЭлемент.Ключ, текЭлемент.Значение);
		
	КонецЦикла;
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "#УсловиеОтбора",  УсловиеОтбора);
	
	ВыборкаИтогов = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Если ВыборкаИтогов.Следующий() Тогда 
		Возврат Окр(ВыборкаИтогов.LegDays);
	иначе 
		Возврат 0;
	КонецЕсли;
	
КонецФункции

// Функция вычисления персентиля. 
// Параметры:
// 		Leg 			- Строка. Параметр, который надо посчитать
//		ТЗLegLeadTime   - Таблица. Данные для расчета. В таблице должны быть колонки Leg и ItemCount
//
Функция Рассчитать90Percent(Знач Leg, менеджерВременныхТаблиц, фильтр)
	
	Leg = СтрЗаменить(Leg, "POLine", "");
	Leg = СтрЗаменить(Leg, "ManualItem", "");
	Leg = СтрЗаменить(Leg, "Plan", "");
	
	ТЗLegLeadTime = ПолучитьТаблицуЛега(менеджерВременныхТаблиц, Leg, фильтр);
	
	ИтогоItemCount = ТЗLegLeadTime.Итог("ItemCount");
	
	ItemCountCumulated = 0;
	CumulativePercent  = 0;
	
	Для Каждого Стр из ТЗLegLeadTime Цикл
		
		LegDays = Стр[Leg];
		
		ItemCountCumulated = ItemCountCumulated + Стр.ItemCount;
		
		CumulativePercent = ItemCountCumulated / ИтогоItemCount * 100;
		
		Если CumulativePercent >= 90 Тогда 
			Прервать;
		КонецЕсли;	
		
	КонецЦикла;
	
	Возврат LegDays; 
	
КонецФункции

// Функция вычисления персентиля. 
// Параметры:
// 		Leg 			- Строка. Параметр, который надо посчитать
//		ТЗLegLeadTime   - Таблица. Данные для расчета. В таблице должны быть колонки Leg и ItemCount
//
Функция ПолучитьПроцентиль90Domestic(границаПериода, LocationFrom, LocationTo, MOT)
	
	// Total actual duration
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	TripNonLawsonCompaniesParcels.Ссылка КАК Trip,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.PickUpWarehouse КАК LocationFrom,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.DeliverTo КАК LocationTo,
	|	СУММА(TripNonLawsonCompaniesParcels.Parcel.GrossWeight) КАК GrossWeight
	|ПОМЕСТИТЬ ТаблицаParcel
	|ИЗ
	|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	|ГДЕ
	|	TripNonLawsonCompaniesParcels.Ссылка.Дата МЕЖДУ &НачалоПериода И &КонецПериода
	|	И TripNonLawsonCompaniesParcels.Ссылка.Проведен
	|	И TripNonLawsonCompaniesParcels.Ссылка.MOT = &MOT
	|	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest.PickUpWarehouse = &PickUpWarehouse
	|	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest.DeliverTo = &DeliverTo
	|
	|СГРУППИРОВАТЬ ПО
	|	TripNonLawsonCompaniesParcels.Ссылка,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.DeliverTo,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.PickUpWarehouse
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицаParcel.Trip,
	|	ТаблицаParcel.LocationFrom,
	|	ТаблицаParcel.LocationTo,
	|	ТаблицаParcel.GrossWeight КАК ItemCount,
	|	TripNonLawsonCompaniesStopsFrom.ActualDepartureUniversalTime,
	|	TripNonLawsonCompaniesStopsTo.ActualArrivalUniversalTime,
	|	РАЗНОСТЬДАТ(TripNonLawsonCompaniesStopsFrom.ActualDepartureUniversalTime, TripNonLawsonCompaniesStopsTo.ActualArrivalUniversalTime, СЕКУНДА) КАК Duration
	|ИЗ
	|	ТаблицаParcel КАК ТаблицаParcel
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStopsFrom
	|		ПО ТаблицаParcel.Trip = TripNonLawsonCompaniesStopsFrom.Ссылка
	|			И ТаблицаParcel.LocationFrom = TripNonLawsonCompaniesStopsFrom.Location
	|			И (TripNonLawsonCompaniesStopsFrom.Type В (ЗНАЧЕНИЕ(Перечисление.StopsTypes.Source), ЗНАЧЕНИЕ(Перечисление.StopsTypes.Transit)))
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStopsTo
	|		ПО ТаблицаParcel.Trip = TripNonLawsonCompaniesStopsTo.Ссылка
	|			И ТаблицаParcel.LocationTo = TripNonLawsonCompaniesStopsTo.Location
	|			И (TripNonLawsonCompaniesStopsTo.Type В (ЗНАЧЕНИЕ(Перечисление.StopsTypes.Destination), ЗНАЧЕНИЕ(Перечисление.StopsTypes.Transit)))
	|ГДЕ
	|	TripNonLawsonCompaniesStopsTo.Ссылка.Closed <> ДАТАВРЕМЯ(1, 1, 1)
	|	И TripNonLawsonCompaniesStopsFrom.Ссылка.Closed <> ДАТАВРЕМЯ(1, 1, 1)";
	
	Запрос.УстановитьПараметр("НачалоПериода",		ДобавитьМесяц(ТекущаяДата(), -24));
	Запрос.УстановитьПараметр("КонецПериода",		ТекущаяДата());
	Запрос.УстановитьПараметр("MOT",				?(Не ЗначениеЗаполнено(MOT), Справочники.MOTs.НайтиПоКоду("TRUCK"), MOT));
	Запрос.УстановитьПараметр("PickUpWarehouse",	LocationFrom);
	Запрос.УстановитьПараметр("DeliverTo",			LocationTo);
	
	УстановитьПривилегированныйРежим(Истина);
	ТЗDuration = Запрос.Выполнить().Выгрузить();
	УстановитьПривилегированныйРежим(Ложь);

	ИтогоItemCount = ТЗDuration.Итог("ItemCount");
	
	ItemCountCumulated = 0;
	CumulativePercent  = 0;
	
	Для Каждого Стр из ТЗDuration Цикл
		
		сдвиг = Стр.Duration;
		
		ItemCountCumulated = ItemCountCumulated + Стр.ItemCount;
		
		CumulativePercent = ItemCountCumulated / ИтогоItemCount * 100;
		
		Если CumulativePercent >= 90 Тогда 
			Прервать;
		КонецЕсли;	
		
	КонецЦикла;
	
	сдвиг = ?(ЗначениеЗаполнено(сдвиг), сдвиг, 0); 
	
	// если расчетной даты нет, то просто пустое значение отдаем иначе сдвигаем границу
	Возврат ?(сдвиг = 0, Неопределено, границаПериода + сдвиг); // количество в секундах
	
КонецФункции

Функция ПолучитьТаблицуДанныхДляРасчетаПоказателей(менеджерВременныхТаблиц)
	
	Запрос = Новый Запрос;
	
	Запрос.МенеджерВременныхТаблиц	= менеджерВременныхТаблиц;
	Запрос.УстановитьПараметр("НачалоПериода", 	ДобавитьМесяц(ТекущаяДата(), -24));
	Запрос.УстановитьПараметр("КонецПериода", 	ТекущаяДата());
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = менеджерВременныхТаблиц;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	LegStatistics.Leg1Days,
	|	LegStatistics.Leg2Days,
	|	LegStatistics.Leg3Days,
	|	LegStatistics.Leg4Days,
	|	LegStatistics.Leg5ADays,
	|	LegStatistics.Leg5BDays,
	|	LegStatistics.Leg6Days,
	|	LegStatistics.Leg7Days,
	|	LegStatistics.Supplier,
	|	LegStatistics.POD,
	|	LegStatistics.MOT,
	|	LegStatistics.POA,
	|	LegStatistics.WarehouseTo,
	|	СУММА(LegStatistics.ItemCount) КАК ItemCount,
	|	LegStatistics.Hub,
	|	LegStatistics.PartNo,
	|	LegStatistics.Geomarket
	|ПОМЕСТИТЬ РезультатСборкиЛего
	|ИЗ
	|	РегистрСведений.LegStatistics КАК LegStatistics
	|
	|СГРУППИРОВАТЬ ПО
	|	LegStatistics.POD,
	|	LegStatistics.POA,
	|	LegStatistics.WarehouseTo,
	|	LegStatistics.MOT,
	|	LegStatistics.Supplier,
	|	LegStatistics.Leg1Days,
	|	LegStatistics.Leg2Days,
	|	LegStatistics.Leg3Days,
	|	LegStatistics.Leg4Days,
	|	LegStatistics.Leg5ADays,
	|	LegStatistics.Leg5BDays,
	|	LegStatistics.Leg6Days,
	|	LegStatistics.Leg7Days,
	|	LegStatistics.Hub,
	|	LegStatistics.PartNo,
	|	LegStatistics.Geomarket";
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос.Выполнить();
	
	УстановитьПривилегированныйРежим(Ложь);
	
	Возврат Неопределено;
	
КонецФункции

Функция ПолучитьТаблицуЛега(менеджерВременныхТаблиц, Знач Лег, Фильтр = Неопределено)
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = менеджерВременныхТаблиц;
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	//|	РезультатСборкиЛего.Leg1Days КАК Leg1Days,
	//|	РезультатСборкиЛего.Leg2Days,
	//|	РезультатСборкиЛего.Leg3Days,
	//|	РезультатСборкиЛего.Leg4Days,
	//|	РезультатСборкиЛего.Leg5ADays,
	//|	РезультатСборкиЛего.Leg5BDays,
	//|	РезультатСборкиЛего.Leg6Days,
	//|	РезультатСборкиЛего.Leg7Days,
	|	СУММА(РезультатСборкиЛего.ItemCount) КАК ItemCount #ПоляВыборки
	|ИЗ
	|	РезультатСборкиЛего КАК РезультатСборкиЛего
	|ГДЕ
	|#УсловиеОтбора
	//|	РезультатСборкиЛего.Supplier = &Supplier
	//|	И РезультатСборкиЛего.POD = &POD
	//|	И РезультатСборкиЛего.MOT = &MOT
	//|	И РезультатСборкиЛего.POA = &POA
	//|	И РезультатСборкиЛего.WarehouseTo = &WarehouseTo
	//|	И РезультатСборкиЛего.Hub = &Hub
	//|	И РезультатСборкиЛего.PartNo = &PartNo
	|
	|СГРУППИРОВАТЬ ПО
	|	#ПоляГруппировки
	//|	РезультатСборкиЛего.Leg1Days,
	//|	РезультатСборкиЛего.Leg3Days,
	//|	РезультатСборкиЛего.Leg2Days,
	//|	РезультатСборкиЛего.Leg4Days,
	//|	РезультатСборкиЛего.Leg5BDays,
	//|	РезультатСборкиЛего.Leg6Days,
	//|	РезультатСборкиЛего.Leg7Days,
	//|	РезультатСборкиЛего.Leg5ADays
	|
	|УПОРЯДОЧИТЬ ПО
	|	#ПоляСортировки";
	
	Запрос.Текст 	= СтрЗаменить(Запрос.Текст, "#ПоляВыборки",     ", РезультатСборкиЛего." + Лег + " КАК " + Лег);
	Запрос.Текст    = СтрЗаменить(Запрос.Текст, "#ПоляГруппировки", "РезультатСборкиЛего." + Лег);
	Запрос.Текст	= СтрЗаменить(Запрос.Текст, "#ПоляСортировки",  Лег);
	
	УсловиеОтбора = "ИСТИНА";
	
	этоРО = Фильтр.Свойство("этоРО");
	этоMI = Фильтр.Свойство("этоMI");
	этоПлан = Фильтр.Свойство("этоПлан");
	
	кодыГеомаркетов = Новый Массив;
	кодыГеомаркетов.Добавить("RUL");
	кодыГеомаркетов.Добавить("ASG");
	кодыГеомаркетов.Добавить("SKG");
	
	Для каждого текЭлемент из Фильтр Цикл
		
		Если текЭлемент.Ключ = "этоРО" Тогда
			Продолжить;
		КонецЕсли;
		
		Если текЭлемент.Ключ = "этоMI" Тогда
			Продолжить;
		КонецЕсли;
		
		Если текЭлемент.Ключ = "этоПлан" Тогда
			Продолжить;
		КонецЕсли;
		
		// пустые фильтры игнорируем
		Если НЕ ЗначениеЗаполнено(текЭлемент.Значение) Тогда
			Продолжить;
		КонецЕсли;
		
		Если текЭлемент.Ключ = "GeoMarketForMOT" и Лег <> "Leg1Days" и Лег <> "Leg2Days" и Лег <> "Leg7Days" 
			И Не Фильтр.Свойство("MOT") Тогда
			
			Если ЗначениеЗаполнено(текЭлемент.Значение) И 
				НЕ кодыГеомаркетов.Найти(СокрЛП(текЭлемент.Значение.Код)) = Неопределено Тогда
				УсловиеОтбора = УсловиеОтбора + Символы.ПС + "И РезультатСборкиЛего.MOT.КОД = ""SEA"""; 
			Иначе
				УсловиеОтбора = УсловиеОтбора + Символы.ПС + "И НЕ РезультатСборкиЛего.MOT В (Значение(Справочник.MOTs.AIR), Значение(Справочник.MOTs.COURIER))"; 
			КонецЕсли;
			
		иначе
			
			//Если текЭлемент.Ключ = "POD" И ТипЗнч(текЭлемент.Значение) <> Тип("СправочникСсылка.CountriesHUBs") Тогда
			//	УсловиеОтбора = УсловиеОтбора + Символы.ПС + "И РезультатСборкиЛего." + текЭлемент.Ключ + ".Код = &" + текЭлемент.Ключ; 
			//Иначе
				УсловиеОтбора = УсловиеОтбора + Символы.ПС + "И РезультатСборкиЛего." + текЭлемент.Ключ + " = &" + текЭлемент.Ключ; 
			//КонецЕсли;
			
		КонецЕсли;
				
		Запрос.УстановитьПараметр(текЭлемент.Ключ, текЭлемент.Значение);
		
	КонецЦикла;
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "#УсловиеОтбора",  УсловиеОтбора);
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Функция ПодготовитьСоответствиеФильтров()
	
	Фильтры = Новый Соответствие;
	
	// DOC's filters
	
	фильтр = Новый Массив;
	фильтр.Добавить("Supplier");
	фильтр.Добавить("POD");
	
	соответствиеФильтров = Новый Соответствие;
	соответствиеФильтров.Вставить("Leg2Days", фильтр);
	
	фильтр = новый Массив;
	фильтр.Добавить("Supplier");
	фильтр.Добавить("PartNo");
	
	соответствиеФильтров.Вставить("Leg1Days", фильтр);
	
	фильтр = новый Массив;
	фильтр.Добавить("POD");
	фильтр.Добавить("MOT");
	фильтр.Добавить("POA");
	
	соответствиеФильтров.Вставить("Leg3Days",  фильтр);
	соответствиеФильтров.Вставить("Leg4Days",  фильтр);
	соответствиеФильтров.Вставить("Leg5ADays", фильтр);
	соответствиеФильтров.Вставить("Leg5BDays", фильтр);
	соответствиеФильтров.Вставить("Leg6Days",  фильтр);
	
	фильтр = новый Массив;
	фильтр.Добавить("POA");
	фильтр.Добавить("WarehouseTo");
	
	соответствиеФильтров.Вставить("Leg7Days",  фильтр);
	
	// PO's filters
	
	фильтр = Новый Массив;
	фильтр.Добавить("Supplier");
	фильтр.Добавить("HUB");
	
	соответствиеФильтров.Вставить("Leg2DaysPOLine", фильтр);

	
	фильтр = новый Массив;
	фильтр.Добавить("HUB");
	фильтр.Добавить("GeoMarket");
	фильтр.Добавить("MOT");
	
	соответствиеФильтров.Вставить("Leg3DaysPOLine",  фильтр);
	соответствиеФильтров.Вставить("Leg4DaysPOLine",  фильтр);
	соответствиеФильтров.Вставить("Leg5ADaysPOLine", фильтр);
	соответствиеФильтров.Вставить("Leg5BDaysPOLine", фильтр);
	соответствиеФильтров.Вставить("Leg6DaysPOLine",  фильтр);
	
	фильтр = новый Массив;
	фильтр.Добавить("GeoMarket");
	
	соответствиеФильтров.Вставить("Leg7DaysPOLine",  фильтр);
	
	// filters for Manual items
	
	фильтр = Новый Массив;
	фильтр.Добавить("Supplier");
	фильтр.Добавить("POD");
	
	соответствиеФильтров.Вставить("Leg2DaysManualItem", фильтр);
	
	фильтр = новый Массив;
	фильтр.Добавить("POD");
	фильтр.Добавить("MOT");
	фильтр.Добавить("GeoMarket");
	
	соответствиеФильтров.Вставить("Leg3DaysManualItem",  фильтр);
	соответствиеФильтров.Вставить("Leg4DaysManualItem",  фильтр);
	соответствиеФильтров.Вставить("Leg5ADaysManualItem", фильтр);
	соответствиеФильтров.Вставить("Leg5BDaysManualItem", фильтр);
	соответствиеФильтров.Вставить("Leg6DaysManualItem",  фильтр);

	фильтр = новый Массив;
	фильтр.Добавить("GeoMarket");
	
	соответствиеФильтров.Вставить("Leg7DaysManualItem",  фильтр);
	
	// planning
	
	фильтр = Новый Массив;
	фильтр.Добавить("Supplier");
	фильтр.Добавить("POD");
	
	соответствиеФильтров.Вставить("Leg2DaysPlan", фильтр);
	
	фильтр = новый Массив;
	фильтр.Добавить("POD");
	фильтр.Добавить("MOT");
	фильтр.Добавить("POA");
	// экстра-фильтр.  
	фильтр.Добавить("GeoMarket");
	
	соответствиеФильтров.Вставить("Leg3DaysPlan",  фильтр);
	соответствиеФильтров.Вставить("Leg4DaysPlan",  фильтр);
	соответствиеФильтров.Вставить("Leg5ADaysPlan", фильтр);
	соответствиеФильтров.Вставить("Leg5BDaysPlan", фильтр);
	соответствиеФильтров.Вставить("Leg6DaysPlan",  фильтр);

	фильтр = новый Массив;
	фильтр.Добавить("GeoMarket");
	
	соответствиеФильтров.Вставить("Leg7DaysPlan",  фильтр);
	
	Возврат соответствиеФильтров;
	
КонецФункции

Функция НеобходимФильтрПоДатеДляImportTracking(ОсновнойФильтр)
	
	ImportTrackingMainFilters = Перечисления.ImportTrackingMainFilters;
	Возврат ОсновнойФильтр = ImportTrackingMainFilters.BORG
	ИЛИ ОсновнойФильтр = ImportTrackingMainFilters.PartNo
	ИЛИ ОсновнойФильтр = ImportTrackingMainFilters.SegmentCode;
	
КонецФункции

Функция НеобходимФильтрПоДатеДляDomesticTracking(ОсновнойФильтр)
	
	DomesticPlanningMainFilters = Перечисления.DomesticPlanningMainFilters;
	Возврат ОсновнойФильтр = DomesticPlanningMainFilters.RequestorAlias
	ИЛИ ОсновнойФильтр = DomesticPlanningMainFilters.PartNo
	ИЛИ ОсновнойФильтр = DomesticPlanningMainFilters.SegmentCode
	ИЛИ ОсновнойФильтр = DomesticPlanningMainFilters.ProjectMobilization
	// { RGS AARsentev 04.03.2018 S-I-0004271
	ИЛИ ОсновнойФильтр = DomesticPlanningMainFilters.CostCenter
	// } RGS AARsentev 04.03.2018 S-I-0004271
	
КонецФункции

Функция ПолучитьМакетТаблицы() 
	
	Возврат Обработки.ImportExportTracking.ПолучитьМакет("Макет");
	
КонецФункции

Функция ПолучитьМакетТаблицыDomestic() 
	
	Возврат Обработки.ImportExportTracking.ПолучитьМакет("МакетDomestic");
	
КонецФункции

Процедура КоррекцияГраницы(граница, первыйРасчетный, пересчет = Ложь) 
	
	Если пересчет тогда
		Возврат;
	КонецЕсли;
	
	// если значение расчитывается, то нужно границу установить на текущую дату и дальше двигаться от нее. 
	Если НЕ первыйРасчетный Тогда
		первыйРасчетный = Истина;
		граница = ТекущаяДата();
	КонецЕсли;
	
КонецПроцедуры

Функция ПодготовитьЭлементИстории()
	Возврат Новый Структура("Показатель, Значение, Граница, Расчетный, ПересчетВыполнен");
КонецФункции

#КонецЕсли
