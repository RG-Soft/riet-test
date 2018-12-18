
&НаКлиенте
Процедура ImportTrackingLegDaysПриИзменении(Элемент)
	
	Стр = Элементы.ImportTracking.ТекущиеДанные;
	
	Стр.TotalLegsDays = Стр.Leg1Days + Стр.Leg2Days + Стр.Leg3Days + Стр.Leg4Days + Стр.Leg5Days + Стр.Leg6Days;
		
КонецПроцедуры

&НаКлиенте
Процедура ImportTrackingFreightCostPerKGПриИзменении(Элемент)
	
	Стр = Элементы.ImportTracking.ТекущиеДанные;
	
	Стр.TotalFreightCost = Стр.FreightCostPerKG * Стр.GrossWeightKG;
	
КонецПроцедуры

&НаКлиенте
Процедура ImportTrackingQtyПриИзменении(Элемент)
	
	Стр = Элементы.ImportTracking.ТекущиеДанные;
	
	Стр.TotalItemValue = Стр.ItemValue * Стр.Qty;
	
	Стр.TotalGrossWeightKG = Стр.GrossWeightKG * Стр.Qty;

КонецПроцедуры

&НаКлиенте
Процедура ImportTrackingInvoiceLineValueПриИзменении(Элемент)
	
	Стр = Элементы.ImportTracking.ТекущиеДанные;
	
	Стр.TotalItemValue = Стр.ItemValue * Стр.Qty;
	
КонецПроцедуры

&НаКлиенте
Процедура ImportTrackingGrossWeightKGПриИзменении(Элемент)
	
	Стр = Элементы.ImportTracking.ТекущиеДанные;
	
	Стр.TotalGrossWeightKG = Стр.GrossWeightKG * Стр.Qty;
	
	Стр.TotalFreightCost = Стр.FreightCostPerKG * Стр.GrossWeightKG;

КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////
// Fill Statistic

&НаСервере
Процедура FillStatisticНаСервере()
	
	Для Каждого Стр из Объект.ImportTracking Цикл 
		
		Если Не Стр.Флажок Тогда 
			Продолжить;
		КонецЕсли;
		
		Запрос = Новый Запрос;
		
		Запрос.УстановитьПараметр("НачалоПериода", ДобавитьМесяц(ТекущаяДата(), -24));
		Запрос.УстановитьПараметр("КонецПериода", ТекущаяДата());
		
		Запрос.УстановитьПараметр("MOT", Стр.MOT);
		Запрос.УстановитьПараметр("POD", Стр.POD);
		Запрос.УстановитьПараметр("POA", Стр.RequestedPOA);
		
		Запрос.УстановитьПараметр("HazardClass", Стр.HazardClass);
		           		
		Запрос.Текст = "ВЫБРАТЬ
		               |	ImportShipments.Ссылка КАК ImportShipment,
		               |	DOCs.Ссылка КАК DOC,
		               |	Items.Инвойс КАК Invoice,
		               |	Items.Ссылка КАК Item,
		               |	ImportShipments.MOT,
		               |	ImportShipments.POD,
		               |	ImportShipments.ActualPOA КАК POA,
		               |	ВЫБОР
		               |		КОГДА ЕСТЬNULL(Items.СтрокаЗаявкиНаЗакупку.Владелец.ДатаЗаявкиНаЗакупку, ДАТАВРЕМЯ(1, 1, 1)) > ДАТАВРЕМЯ(1, 1, 1)
		               |				И ЕСТЬNULL(Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate, ДАТАВРЕМЯ(1, 1, 1)) > ДАТАВРЕМЯ(1, 1, 1)
		               |			ТОГДА РАЗНОСТЬДАТ(Items.СтрокаЗаявкиНаЗакупку.Владелец.ДатаЗаявкиНаЗакупку, Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate, ДЕНЬ)
		               |		ИНАЧЕ 0
		               |	КОНЕЦ КАК L1BPOReadinessDays,
		               |	ВЫБОР
		               |		КОГДА ЕСТЬNULL(Items.СтрокаЗаявкиНаЗакупку.GOLDReceiptDate, ДАТАВРЕМЯ(1, 1, 1)) > ДАТАВРЕМЯ(1, 1, 1)
		               |				И ЕСТЬNULL(Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate, ДАТАВРЕМЯ(1, 1, 1)) > ДАТАВРЕМЯ(1, 1, 1)
		               |				И ЕСТЬNULL(Items.СтрокаЗаявкиНаЗакупку.GOLDReceiptDate, ДАТАВРЕМЯ(1, 1, 1)) < ЕСТЬNULL(Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate, ДАТАВРЕМЯ(1, 1, 1))
		               |			ТОГДА РАЗНОСТЬДАТ(Items.СтрокаЗаявкиНаЗакупку.GOLDReceiptDate, Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate, ДЕНЬ)
		               |		ИНАЧЕ 0
		               |	КОНЕЦ КАК L2TransportationFromSupplierToHUBDays,
		               |	ВЫБОР
		               |		КОГДА ЕСТЬNULL(Items.СтрокаЗаявкиНаЗакупку.GOLDReceiptDate, ДАТАВРЕМЯ(1, 1, 1)) > ДАТАВРЕМЯ(1, 1, 1)
		               |			ТОГДА РАЗНОСТЬДАТ(Items.СтрокаЗаявкиНаЗакупку.GOLDReceiptDate, DOCs.Дата, ДЕНЬ)
		               |		ИНАЧЕ 0
		               |	КОНЕЦ КАК L3GOLDConsolidationDays,
		               |	ВЫБОР
		               |		КОГДА DOCs.Received > ДАТАВРЕМЯ(1, 1, 1)
		               |			ТОГДА РАЗНОСТЬДАТ(DOCs.Дата, DOCs.Received, ДЕНЬ)
		               |		КОГДА DOCs.Granted > ДАТАВРЕМЯ(1, 1, 1)
		               |				И DOCs.Requested > ДАТАВРЕМЯ(1, 1, 1)
		               |			ТОГДА РАЗНОСТЬДАТ(DOCs.Requested, DOCs.Granted, ДЕНЬ)
		               |		КОГДА DOCs.Requested > ДАТАВРЕМЯ(1, 1, 1)
		               |				И DOCs.Requested < ImportShipments.ATD
		               |			ТОГДА РАЗНОСТЬДАТ(DOCs.Requested, ImportShipments.ATD, ДЕНЬ)
		               |		ИНАЧЕ 0
		               |	КОНЕЦ КАК L4ReceiptGreenLightDays,
		               |	ВЫБОР
		               |		КОГДА DOCs.Granted > ДАТАВРЕМЯ(1, 1, 1)
		               |				И DOCs.Received > ДАТАВРЕМЯ(1, 1, 1)
		               |			ТОГДА РАЗНОСТЬДАТ(DOCs.Received, DOCs.Granted, ДЕНЬ)
		               |		КОГДА DOCs.Requested > ДАТАВРЕМЯ(1, 1, 1)
		               |				И DOCs.Requested < ImportShipments.ATD
		               |			ТОГДА РАЗНОСТЬДАТ(DOCs.Requested, ImportShipments.ATD, ДЕНЬ)
		               |		ИНАЧЕ 0
		               |	КОНЕЦ КАК L4IssueGreenLightDays,
		               |	ВЫБОР
		               |		КОГДА DOCs.Granted > ДАТАВРЕМЯ(1, 1, 1)
		               |				И DOCs.Granted < ImportShipments.ATD
		               |			ТОГДА РАЗНОСТЬДАТ(DOCs.Granted, ImportShipments.ATD, ДЕНЬ)
		               |		ИНАЧЕ 0
		               |	КОНЕЦ КАК L5AConsolidationDays,
		               |	ВЫБОР
		               |		КОГДА ImportShipments.ATD > ДАТАВРЕМЯ(1, 1, 1)
		               |			ТОГДА РАЗНОСТЬДАТ(ImportShipments.ATD, ImportShipments.ATA, ДЕНЬ)
		               |		ИНАЧЕ 0
		               |	КОНЕЦ КАК L5BInTransitDays,
		               |	РАЗНОСТЬДАТ(ImportShipments.ATA, ImportShipments.Cleared, ДЕНЬ) КАК L6CustomsClearanceDays
		               |ПОМЕСТИТЬ ВТ
		               |ИЗ
		               |	Документ.Поставка КАК ImportShipments
		               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Поставка.УпаковочныеЛисты КАК ImportShipmentsDOCs
		               |			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку КАК DOCs
		               |				ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК DOCsInvoices
		               |					ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК Items
		               |					ПО DOCsInvoices.Инвойс = Items.Инвойс
		               |						И (НЕ Items.ПометкаУдаления)
		               |				ПО DOCs.Ссылка = DOCsInvoices.Ссылка
		               |			ПО ImportShipmentsDOCs.УпаковочныйЛист = DOCs.Ссылка
		               |		ПО ImportShipments.Ссылка = ImportShipmentsDOCs.Ссылка
		               |ГДЕ
		               |	ImportShipments.Completed МЕЖДУ &НачалоПериода И &КонецПериода
		               |	И НЕ ImportShipments.Отменен
		               |	И ImportShipments.MOT = &MOT
		               |	И ImportShipments.POD = &POD
		               |	И ImportShipments.ActualPOA = &POA
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ
		               |	ParcelsДетали.Ссылка КАК Parcel,
		               |	ParcelsДетали.Ссылка.WarehouseTo,
		               |	ВТ.POD,
		               |	ВТ.MOT,
		               |	ВТ.DOC,
		               |	ВТ.L5AConsolidationDays,
		               |	ВТ.L5BInTransitDays,
		               |	ВТ.L6CustomsClearanceDays,
		               |	ВТ.Item,
		               |	ВТ.L4ReceiptGreenLightDays,
		               |	ВТ.L4IssueGreenLightDays,
		               |	ВТ.L1BPOReadinessDays,
		               |	ВТ.L2TransportationFromSupplierToHUBDays,
		               |	ВТ.L3GOLDConsolidationDays,
		               |	ВТ.ImportShipment,
		               |	ВТ.Invoice,
		               |	ВТ.POA,
		               |	ParcelsДетали.GrossWeightKG,
		               |	ParcelsДетали.Ссылка.HazardClass
		               |ПОМЕСТИТЬ ВТ_Leg1_6
		               |ИЗ
		               |	ВТ КАК ВТ
		               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
		               |			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Parcels КАК КонсолидированныйПакетЗаявокНаПеревозкуParcels
		               |			ПО ParcelsДетали.Ссылка = КонсолидированныйПакетЗаявокНаПеревозкуParcels.Parcel
		               |				И (КонсолидированныйПакетЗаявокНаПеревозкуParcels.Ссылка В
		               |					(ВЫБРАТЬ
		               |						ВТ.DOC
		               |					ИЗ
		               |						ВТ КАК ВТ))
		               |		ПО ВТ.Item = ParcelsДетали.СтрокаИнвойса
		               |
		               |СГРУППИРОВАТЬ ПО
		               |	ВТ.Item,
		               |	ВТ.MOT,
		               |	ВТ.POD,
		               |	ВТ.DOC,
		               |	ВТ.L5AConsolidationDays,
		               |	ВТ.L5BInTransitDays,
		               |	ВТ.L6CustomsClearanceDays,
		               |	ВТ.L4ReceiptGreenLightDays,
		               |	ВТ.L4IssueGreenLightDays,
		               |	ВТ.L1BPOReadinessDays,
		               |	ВТ.L2TransportationFromSupplierToHUBDays,
		               |	ВТ.L3GOLDConsolidationDays,
		               |	ParcelsДетали.Ссылка.WarehouseTo,
		               |	ВТ.ImportShipment,
		               |	ВТ.Invoice,
		               |	ВТ.POA,
		               |	ParcelsДетали.GrossWeightKG,
		               |	ParcelsДетали.Ссылка.HazardClass,
		               |	ParcelsДетали.Ссылка
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ
		               |	СУММА(ВТ_Leg1_6.Invoice.Фрахт) КАК InvoiceФрахт,
		               |	СУММА(ВТ_Leg1_6.GrossWeightKG) КАК GrossWeightKG
		               |ИЗ
		               |	ВТ_Leg1_6 КАК ВТ_Leg1_6
		               |ГДЕ
		               |	ВТ_Leg1_6.HazardClass = &HazardClass
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ
		               |	ВТ_Leg1_6.L1BPOReadinessDays КАК Leg1Days,
		               |	ВТ_Leg1_6.L2TransportationFromSupplierToHUBDays КАК Leg2Days,
		               |	ВТ_Leg1_6.L3GOLDConsolidationDays КАК Leg3Days,
		               |	ВТ_Leg1_6.L4ReceiptGreenLightDays + ВТ_Leg1_6.L4IssueGreenLightDays КАК Leg4Days,
		               |	ВТ_Leg1_6.L5AConsolidationDays + ВТ_Leg1_6.L5BInTransitDays КАК Leg5Days,
		               |	ВТ_Leg1_6.L6CustomsClearanceDays КАК Leg6Days,
		               |	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВТ_Leg1_6.Item) КАК ItemCount,
		               |	0 КАК ItemCountCumulated,
		               |	0 КАК CumulativePercent
		               |ИЗ
		               |	ВТ_Leg1_6 КАК ВТ_Leg1_6
		               |
		               |СГРУППИРОВАТЬ ПО
		               |	ВТ_Leg1_6.L1BPOReadinessDays,
		               |	ВТ_Leg1_6.L2TransportationFromSupplierToHUBDays,
		               |	ВТ_Leg1_6.L3GOLDConsolidationDays,
		               |	ВТ_Leg1_6.L4ReceiptGreenLightDays,
		               |	ВТ_Leg1_6.L4IssueGreenLightDays,
		               |	ВТ_Leg1_6.L5AConsolidationDays,
		               |	ВТ_Leg1_6.L5BInTransitDays,
		               |	ВТ_Leg1_6.L6CustomsClearanceDays,
		               |	ВТ_Leg1_6.L4ReceiptGreenLightDays + ВТ_Leg1_6.L4IssueGreenLightDays,
		               |	ВТ_Leg1_6.L5AConsolidationDays + ВТ_Leg1_6.L5BInTransitDays";
		
		Результат = Запрос.ВыполнитьПакет();
		
		ВыборкаФрахт = Результат[2].Выбрать();
		Если ВыборкаФрахт.Следующий() Тогда
			
			Если ЗначениеЗаполнено(ВыборкаФрахт.InvoiceФрахт) И ЗначениеЗаполнено(ВыборкаФрахт.GrossWeightKG) Тогда 
				
				Стр.FreightCostPerKG = ВыборкаФрахт.InvoiceФрахт / ВыборкаФрахт.GrossWeightKG;
				Стр.TotalFreightCost = Стр.TotalGrossWeightKG * Стр.FreightCostPerKG;
				
			КонецЕсли;
		
		КонецЕсли;
		
		ТЗLeadTime = Результат[3].Выгрузить();
		Стр.Leg1Days = Рассчитать90Percent("Leg1Days", ТЗLeadTime.Скопировать(,"Leg1Days,ItemCount"));
		Стр.Leg2Days = Рассчитать90Percent("Leg2Days", ТЗLeadTime.Скопировать(,"Leg2Days,ItemCount"));
		Стр.Leg3Days = Рассчитать90Percent("Leg3Days", ТЗLeadTime.Скопировать(,"Leg3Days,ItemCount"));
		Стр.Leg4Days = Рассчитать90Percent("Leg4Days", ТЗLeadTime.Скопировать(,"Leg4Days,ItemCount"));
		Стр.Leg5Days = Рассчитать90Percent("Leg5Days", ТЗLeadTime.Скопировать(,"Leg5Days,ItemCount"));
		Стр.Leg6Days = Рассчитать90Percent("Leg6Days", ТЗLeadTime.Скопировать(,"Leg6Days,ItemCount"));
				
		Стр.TotalLegsDays = Стр.Leg1Days + Стр.Leg2Days + Стр.Leg3Days + Стр.Leg4Days + Стр.Leg5Days + Стр.Leg6Days;
	
	КонецЦикла;
	 	
КонецПроцедуры

Функция Рассчитать90Percent(Leg, ТЗLegLeadTime)
	
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

&НаКлиенте
Процедура ImportTrackingFillStatistic(Команда)
	
	FillStatisticНаСервере();
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////
// Save plan

&НаСервере
Процедура SavePlanНаСервере()
	
	Для Каждого Стр из Объект.ImportTracking Цикл 
		
		Если Не Стр.Флажок Тогда 
			Продолжить;
		КонецЕсли;
		
		PlanPerItem = РегистрыСведений.ProjectMobilizationPlanningPerItem.СоздатьМенеджерЗаписи();
				
		ЗаполнитьЗначенияСвойств(PlanPerItem, Стр);
		
		PlanPerItem.ProjectMobilization = Объект.ProjectMobilization;
		
		PlanPerItem.POA = Стр.RequestedPOA;
				
		PlanPerItem.ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
		
		PlanPerItem.ModificationDate = ТекущаяДата();
		
		PlanPerItem.User = ПараметрыСеанса.ТекущийПользователь;
		
		PlanPerItem.Variant = Объект.ImportTrackingVariant;
		
		Попытка
			PlanPerItem.Записать();
		Исключение
			Сообщить(ОписаниеОшибки());
		КонецПопытки;
				
	КонецЦикла;
	
	Объект.ImportTrackingVariantOwner = ПараметрыСеанса.ТекущийПользователь;
	
КонецПроцедуры

&НаКлиенте
Процедура ImportTrackingSavePlan(Команда)
	
	SavePlanНаСервере();
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	//ТочноеВремяНачала = ОценкаПроизводительностиРГСофт.ТочноеВремя();
	
	//ИнициализироватьTMCDashboards();
	
	ИнициализироватьImportTracking();
	
	ИнициализироватьDomesticPlanning();
	
	//ИнициализироватьExportTracking();
	
	// Скроем динамические списки, чтобы они не считывали данные до того, как пользователь не переключится на них
	//Элементы.MyExportRequests.Видимость = Ложь;
	
	//Элементы.Subscriptions.Видимость = Ложь;
			
	EMailForSupport = "riet-support@slb.com";	
	
	//ОценкаПроизводительностиРГСофт.ЗафиксироватьВремяОкончания(ТочноеВремяНачала, Справочники.КлючевыеОперации.ImportExportTrackingОткрытие);
	
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьTMCDashboards()
	
	ИнициализироватьTMCDashboard(Отчеты.LEG4PendingGreenLight, ОтчетLEG4PendingGreenLight, АдресСхемыКомпоновкиPendingGreenLight, , , "Main");
	
	ИнициализироватьTMCDashboard(Отчеты.LEG6CustomsClearance, ОтчетLEG6CustomsClearance, АдресСхемыКомпоновкиCustomsClearance, , , "Main");
	
	//// { RGS AGorlenko 11.03.2014 13:19:43 - S-I-0000633
	////ТаблицаОтбора = Новый ТаблицаЗначений;
	////ТаблицаОтбора.Колонки.Добавить("ЛевоеЗначение", Новый ОписаниеТипов("ПолеКомпоновкиДанных"));
	////ТаблицаОтбора.Колонки.Добавить("ВидСравнения", Новый ОписаниеТипов("ВидСравненияКомпоновкиДанных"));
	////ТаблицаОтбора.Колонки.Добавить("ПравоеЗначение");
	////ТаблицаОтбора.Колонки.Добавить("РежимОтображения", Новый ОписаниеТипов("РежимОтображенияЭлементаНастройкиКомпоновкиДанных"));
	////
	////СтрокаОтбора = ТаблицаОтбора.Добавить();
	////СтрокаОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Urgency");
	////СтрокаОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	////СтрокаОтбора.ПравоеЗначение = Перечисления.Urgencies.Emergency;
	////СтрокаОтбора.РежимОтображения = РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Недоступный;
	////
	////МассивДопПолейГруппировокLeg4 = Новый Массив;
	////МассивДопПолейГруппировокLeg4.Добавить("DOC.SegmentsList");
	//ПараметрыДанных = Новый Структура;
	//ПараметрыДанных.Вставить("ВыводитьPendingShipment", Истина);
	//ИнициализироватьTMCDashboard(Отчеты.LEG4PendingGreenLight, ОтчетLEG4PendingGreenLightEmergency, АдресСхемыКомпоновкиPendingGreenLightEmergency, , , "Emergency", ПараметрыДанных);
	////МассивДопПолейГруппировокLeg6 = Новый Массив;
	////МассивДопПолейГруппировокLeg6.Добавить("ImportShipment.SegmentsList");
	//ИнициализироватьTMCDashboard(Отчеты.LEG6CustomsClearance, ОтчетLEG6CustomsClearanceEmergency, АдресСхемыКомпоновкиCustomsClearanceEmergency, , , "Emergency");
	//// } RGS AGorlenko 11.03.2014 13:19:45 - S-I-0000633
	//// { RGS AGorlenko 11.09.2014 17:24:35 - S-I-0000863
	//ИнициализироватьTMCDashboard(Отчеты.SanctionsReportHTC, ОтчетSanctionsHTC, АдресСхемыКомпоновкиSanctionsHTC, , , "Dashboard");
	//// } RGS AGorlenko 11.09.2014 17:24:42 - S-I-0000863
	
	ИнициализироватьTMCDashboard(Отчеты.ExportDashboards, ОтчетExportDashboards, АдресСхемыКомпоновкиExportDashboards, , , "Export dashboards");

	СформироватьTMCDashboardsНаСервере();
	
КонецПроцедуры

&НаСервере
// { RGS AGorlenko 11.03.2014 13:41:54 - S-I-0000633
//Процедура ИнициализироватьTMCDashboard(ОтчетМенеджер, ДанныеФормыСтруктура, АдресСхемы)
Процедура ИнициализироватьTMCDashboard(ОтчетМенеджер, ДанныеФормыСтруктура, АдресСхемы, НастройкиОтбора = Неопределено, МассивДопПолейГруппировок = Неопределено, ИмяВарианта = Неопределено, ПараметрыДанных = Неопределено)
// } RGS AGorlenko 11.03.2014 13:42:00 - S-I-0000633
	
	ПолноценныйОтчет = ОтчетМенеджер.Создать();
	СКД = ПолноценныйОтчет.СхемаКомпоновкиДанных;
	АктивизироватьВариантОтчета(СКД, ИмяВарианта);
	АдресСхемы = ПоместитьВоВременноеХранилище(СКД, УникальныйИдентификатор);
	ИсточникДоступныхНастроек = Новый ИсточникДоступныхНастроекКомпоновкиДанных(АдресСхемы);
	ПолноценныйОтчет.КомпоновщикНастроек.Инициализировать(ИсточникДоступныхНастроек);
	// { RGS AGorlenko 11.03.2014 13:43:24 - S-I-0000633
	ИнициализироватьДопПоляГруппировкиTMCDashboard(ПолноценныйОтчет.КомпоновщикНастроек, МассивДопПолейГруппировок);
	ИнициализироватьОтборTMCDashboard(ПолноценныйОтчет.КомпоновщикНастроек, НастройкиОтбора);
	ИнициализироватьПараметрыДанныхTMCDashboard(ПолноценныйОтчет.КомпоновщикНастроек, ПараметрыДанных);
	// } RGS AGorlenko 11.03.2014 13:43:31 - S-I-0000633
	ЗначениеВДанныеФормы(ПолноценныйОтчет, ДанныеФормыСтруктура);
	
КонецПроцедуры

// { RGS AGorlenko 11.03.2014 13:44:25 - S-I-0000633
&НаСервере
Процедура ИнициализироватьПараметрыДанныхTMCDashboard(КомпоновщикНастроек, ПараметрыДанных)
	
	Если ПараметрыДанных = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для каждого ТекПараметр Из ПараметрыДанных Цикл
		Параметр = КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти(ТекПараметр.Ключ);
		Если Параметр <> Неопределено Тогда
			Параметр.Значение = ТекПараметр.Значение;
			Параметр.Использование = Истина;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура АктивизироватьВариантОтчета(СКД, ИмяВарианта)
	
	Если Не ЗначениеЗаполнено(ИмяВарианта) Тогда
		Возврат;
	КонецЕсли;
	
	Вариант = СКД.ВариантыНастроек.Найти(ИмяВарианта);
	
	Если Вариант = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ВариантыДляУдаления = Новый Массив;
	
	Для каждого ТекВариант Из СКД.ВариантыНастроек Цикл
		Если ТекВариант.Имя <> ИмяВарианта Тогда
			ВариантыДляУдаления.Добавить(ТекВариант);
		КонецЕсли;
	КонецЦикла;
	
	Для каждого ТекВариант Из ВариантыДляУдаления Цикл
		СКД.ВариантыНастроек.Удалить(ТекВариант);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьДопПоляГруппировкиTMCDashboard(КомпоновщикНастроек, МассивДопПолейГруппировок)
	
	Если МассивДопПолейГруппировок = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для каждого ДопПолеГруппировки Из МассивДопПолейГруппировок Цикл
		ТиповыеОтчеты.ДобавитьГруппировку(КомпоновщикНастроек, ДопПолеГруппировки);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьОтборTMCDashboard(КомпоновщикНастроек, НастройкиОтбора)
	
	Если НастройкиОтбора = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	КоллекцияЭлементовОтбора = КомпоновщикНастроек.Настройки.Отбор.Элементы;
	
	Для каждого ТекНастройкаОтбора Из НастройкиОтбора Цикл
		НашлиЭлементОтбора = Ложь;
		Для каждого ТекЭлементОтбора Из КоллекцияЭлементовОтбора Цикл
			Если ТекЭлементОтбора.ЛевоеЗначение = ТекНастройкаОтбора.ЛевоеЗначение Тогда
				ЗаполнитьЗначенияСвойств(ТекЭлементОтбора, ТекНастройкаОтбора);
				ТекЭлементОтбора.Использование = Истина;
				НашлиЭлементОтбора = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		Если Не НашлиЭлементОтбора Тогда
			ЭлементОтбора = КоллекцияЭлементовОтбора.Добавить();
			ЗаполнитьЗначенияСвойств(ЭлементОтбора, ТекНастройкаОтбора);
			ЭлементОтбора.Использование = Истина;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры // } RGS AGorlenko 11.03.2014 13:44:32 - S-I-0000633

&НаСервере
Процедура ИнициализироватьImportTracking()
	
	// Вспомогательные переменные, чтобы на клиенте не уходить на сервер
	ImportTrackingMainFilters = Перечисления.ImportTrackingMainFilters;
	ImportTrackingFilterByPartNo = ImportTrackingMainFilters.PartNo;
	ImportTrackingFilterByBORG = ImportTrackingMainFilters.BORG;
	ImportTrackingFilterBySegmentCode = ImportTrackingMainFilters.SegmentCode;
	ImportTrackingFilterByProjectMobilization = ImportTrackingMainFilters.ProjectMobilization;

	НастроитьImportTrackingFiltersНаСервере();
	
	НастроитьImportTrackingVariant();
	
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьExportTracking()
	
	// Вспомогательные переменные, чтобы на клиенте не уходить на сервер
	ExportTrackingMainFilters = Перечисления.ExportTrackingMainFilters;
	ExportTrackingFilterByBORG = ExportTrackingMainFilters.BORG;
	ExportTrackingFilterByFinalDestination = ExportTrackingMainFilters.FinalDestination;
	ExportTrackingFilterByPartDescription = ExportTrackingMainFilters.PartDescription;
	ExportTrackingFilterByPartNo = ExportTrackingMainFilters.PartNo;
	ExportTrackingFilterBySegmentCode = ExportTrackingMainFilters.SegmentCode;
	ExportTrackingFilterBySubmitterAlias = ExportTrackingMainFilters.SubmitterAlias;
	
	НастроитьExportTrackingFiltersНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьDomesticPlanning()
	
	НастроитьDomesticPlanningFiltersНаСервере();
	
	НастроитьСписокВыбораMOTНаСервере();
	
	НастроитьDomesticPlanningVariant();
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	
	// Сразу вытащим нужное значение из настроек, чтобы настроить видимость элементов управления
	Объект.ImportTrackingMainFilter = Настройки["Объект.ImportTrackingMainFilter"];
	НастроитьImportTrackingFiltersНаСервере();
	
	//Объект.ExportTrackingMainFilter = Настройки["Объект.ExportTrackingMainFilter"];
	//НастроитьExportTrackingFiltersНаСервере();
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////////

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	//ПодключитьОбработчикОжидания("Отсчет", 60);
	
КонецПроцедуры

&НаКлиенте
Процедура Отсчет()
	
	MinutesRemaining = MinutesRemaining - 1;
	Если MinutesRemaining = 0 Тогда
		СформироватьTMCDashboardsНаСервере();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ProjectMobilizationПриИзменении(Элемент)
	
	НастроитьDomesticPlanningVariant();
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////////
// СТРАНИЦЫ

&НаКлиенте
Процедура ГруппаСтраницыПриСменеСтраницы(Элемент, ТекущаяСтраница)
	
	//Если ТекущаяСтраница = Элементы.СтраницаMyExportRequests Тогда
	//	
	//	Если НЕ Элементы.MyExportRequests.Видимость Тогда
	//		НастроитьСтраницуMyExportRequests();
	//	КонецЕсли;
	//	
	//ИначеЕсли ТекущаяСтраница = Элементы.СтраницаEmailSubscriptions Тогда
	//	
	//	Если НЕ Элементы.Subscriptions.Видимость Тогда
	//		НастроитьСтраницуEmailSubscriptions();
	//	КонецЕсли;
	//	
	//КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура НастроитьСтраницуMyExportRequests() 
	
	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(
		ExportRequests.Отбор,
		"Submitter",
		ВидСравненияКомпоновкиДанных.Равно,
		ПараметрыСеанса.ТекущийПользователь);	
		
	Элементы.MyExportRequests.Видимость = Истина;
	Элементы.ФиктивнаяНадписьMyExportRequests.Видимость = Ложь;
	
КонецПроцедуры

&НаСервере
Процедура НастроитьСтраницуEmailSubscriptions()
	
	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(
		Subscriptions.Отбор,
		"User",
		ВидСравненияКомпоновкиДанных.Равно,
		ПараметрыСеанса.ТекущийПользователь);
		
	Элементы.Subscriptions.Видимость = Истина;
	Элементы.ФиктивнаяНадписьEMailSubscriptions.Видимость = Ложь;
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////////
// TMC DASHBOARDS

&НаКлиенте
Процедура RefreshNow(Команда)
	
	СформироватьTMCDashboardsНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура СформироватьTMCDashboardsНаСервере()
	
	УстановитьПривилегированныйРежим(Истина);
	
	СформироватьTMCDashboardНаСервере(ТабличныйДокументPendingGreenlight, ОтчетLEG4PendingGreenLight, "LEG4PendingGreenLight", АдресДанныхРасшифровкиPendingGreenLight);
	
	СформироватьTMCDashboardНаСервере(ТабличныйДокументCustomsClearance, ОтчетLEG6CustomsClearance, "LEG6CustomsClearance", АдресДанныхРасшифровкиCustomsClearance);
	
	// { RGS AGorlenko 11.03.2014 13:09:59 - S-I-0000633
	//СформироватьTMCDashboardНаСервере(ТабличныйДокументPendingGreenlightEmergency, ОтчетLEG4PendingGreenLightEmergency, "LEG4PendingGreenLight", АдресДанныхРасшифровкиPendingGreenLightEmergency, Ложь);
	
	//СформироватьTMCDashboardНаСервере(ТабличныйДокументCustomsClearanceEmergency, ОтчетLEG6CustomsClearanceEmergency, "LEG6CustomsClearance", АдресДанныхРасшифровкиCustomsClearanceEmergency, Ложь);
	// } RGS AGorlenko 11.03.2014 13:10:01 - S-I-0000633
	
	// { RGS AGorlenko 11.09.2014 17:10:21 - S-I-0000863
	//СформироватьTMCDashboardНаСервере(ТабличныйДокументSanctionsHTC, ОтчетSanctionsHTC, "SanctionsReportHTC", АдресДанныхРасшифровкиSanctionsHTC, Ложь);
	// } RGS AGorlenko 11.09.2014 17:10:22 - S-I-0000863
	
	СформироватьTMCDashboardНаСервере(ТабличныйДокументExportDashboards, ОтчетExportDashboards, "ExportDashboards", АдресДанныхРасшифровкиExportDashboards);
	
	MinutesRemaining = 60;
	
КонецПроцедуры

&НаСервере
Процедура СформироватьTMCDashboardНаСервере(ТабличныйДокумент, ДанныеФормы, ИмяОтчета, АдресДанныхРасшифровки, СворачиватьГруппировки = Истина)
	
	ТабличныйДокумент.Очистить();
	ПолноценныйОтчет = ДанныеФормыВЗначение(ДанныеФормы, Тип("ОтчетОбъект." + ИмяОтчета));
	ДанныеРасшифровки = Новый ДанныеРасшифровкиКомпоновкиДанных;
	ПолноценныйОтчет.СкомпоноватьРезультат(ТабличныйДокумент, ДанныеРасшифровки);
	АдресДанныхРасшифровки = ПоместитьВоВременноеХранилище(ДанныеРасшифровки, УникальныйИдентификатор);
	Если СворачиватьГруппировки Тогда
		ТабличныйДокумент.ПоказатьУровеньГруппировокСтрок(0);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ShowPendingGreenLightFilters(Команда)
	
	Элементы.ShowPendingGreenLightFilters.Пометка = НЕ Элементы.ShowPendingGreenLightFilters.Пометка;
	Элементы.КомпоновщикНастроекPendingGreenLightПользовательскиеНастройки.Видимость = Элементы.ShowPendingGreenLightFilters.Пометка;
	
КонецПроцедуры

&НаКлиенте
Процедура ShowCustomsClearanceFilters(Команда)
	
	Элементы.ShowCustomsClearanceFilters.Пометка = НЕ Элементы.ShowCustomsClearanceFilters.Пометка;
	Элементы.КомпоновщикНастроекCustomsClearanceПользовательскиеНастройки.Видимость = Элементы.ShowCustomsClearanceFilters.Пометка;
	
КонецПроцедуры

&НаКлиенте
Процедура ТабличныйДокументPendingGreenlightОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ОбработатьРасшифровку(АдресСхемыКомпоновкиPendingGreenLight, АдресДанныхРасшифровкиPendingGreenLight, Расшифровка, "LEG4PendingGreenLight");
	
КонецПроцедуры

&НаКлиенте
Процедура ТабличныйДокументCustomsClearanceОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ОбработатьРасшифровку(АдресСхемыКомпоновкиCustomsClearance, АдресДанныхРасшифровкиCustomsClearance, Расшифровка, "LEG6CustomsClearance");
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьРасшифровку(АдресСхемыКомпоновки, АдресДанныхРасшифровки, Расшифровка, ИмяОтчета)
	
	Перем ВыбранноеДействие;
	Перем ПараметрыВыбранногоДействия;
	
	ИсточникДоступныхНастроек = Новый ИсточникДоступныхНастроекКомпоновкиДанных(АдресСхемыКомпоновки);
	ОбработкаРасшифровки = Новый ОбработкаРасшифровкиКомпоновкиДанных(АдресДанныхРасшифровки, ИсточникДоступныхНастроек);
	
	ДоступныеДействия = Новый Массив;
	// { RGS AGorlenko 12.09.2014 15:25:44 - S-I-0000863
	//ДоступныеДействия.Добавить(ДействиеОбработкиРасшифровкиКомпоновкиДанных.Расшифровать);
	Если ИмяОтчета <> "SanctionsReportHTC" Тогда
		ДоступныеДействия.Добавить(ДействиеОбработкиРасшифровкиКомпоновкиДанных.Расшифровать);
	Иначе
		ДоступныеДействия.Добавить(ДействиеОбработкиРасшифровкиКомпоновкиДанных.ОткрытьЗначение);
	КонецЕсли;
	// } RGS AGorlenko 12.09.2014 15:25:55 - S-I-0000863
	ОбработкаРасшифровки.ПоказатьВыборДействия(
		Новый ОписаниеОповещения("ДействиеОбработкиРасшифровкиКомпоновкиДанныхЗаверешение" ,ЭтаФорма, 
		Новый Структура("ИмяОтчета,Расшифровка,АдресДанныхРасшифровки", ИмяОтчета, Расшифровка, АдресДанныхРасшифровки))
		, Расшифровка, ДоступныеДействия);
	                                            		
КонецПроцедуры

&НаКлиенте
Процедура ДействиеОбработкиРасшифровкиКомпоновкиДанныхЗаверешение(ВыбранноеДействие, ПараметрыВыбранногоДействия, ДополнительныеПараметры) Экспорт
	
	Если ВыбранноеДействие = Неопределено Тогда 
		Возврат;
	КонецЕсли;
		
	Если ВыбранноеДействие <> ДействиеОбработкиРасшифровкиКомпоновкиДанных.Нет Тогда
		 				
		Если ВыбранноеДействие = ДействиеОбработкиРасшифровкиКомпоновкиДанных.ОткрытьЗначение Тогда
			ПоказатьЗначение(, ПараметрыВыбранногоДействия);
		Иначе
			СтруктураПараметров = Новый Структура;
			СтруктураПараметров.Вставить("СформироватьПриОткрытии", Истина);
			СтруктураПараметров.Вставить("Расшифровка", Новый ОписаниеОбработкиРасшифровкиКомпоновкиДанных(ДополнительныеПараметры.АдресДанныхРасшифровки, ДополнительныеПараметры.Расшифровка, ПараметрыВыбранногоДействия));
			ОткрытьФорму("Отчет." + ДополнительныеПараметры.ИмяОтчета + ".Форма", СтруктураПараметров, , Истина);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ShowExportDashboardsFilters(Команда)
	
	Элементы.ShowExportDashboardsFilters.Пометка = НЕ Элементы.ShowExportDashboardsFilters.Пометка;
	Элементы.КомпоновщикНастроекExportDashboardsПользовательскиеНастройки.Видимость = Элементы.ShowExportDashboardsFilters.Пометка;
	
КонецПроцедуры

&НаКлиенте
Процедура ТабличныйДокументExportDashboardsОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ОбработатьРасшифровку(АдресСхемыКомпоновкиExportDashboards, АдресДанныхРасшифровкиExportDashboards, Расшифровка, "ExportDashboards");
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////
// TMC DASHBOARDS Emergency

// { RGS AGorlenko 11.03.2014 13:09:18 - S-I-0000633
&НаКлиенте
Процедура ShowCustomsClearanceEmergencyFilters(Команда)
	
	Элементы.ShowCustomsClearanceEmergencyFilters.Пометка = НЕ Элементы.ShowCustomsClearanceEmergencyFilters.Пометка;
	Элементы.КомпоновщикНастроекCustomsClearanceEmergencyПользовательскиеНастройки.Видимость = Элементы.ShowCustomsClearanceEmergencyFilters.Пометка;
	
КонецПроцедуры

&НаКлиенте
Процедура ShowPendingGreenLightEmergencyFilters(Команда)
	
	Элементы.ShowPendingGreenLightEmergencyFilters.Пометка = НЕ Элементы.ShowPendingGreenLightEmergencyFilters.Пометка;
	Элементы.КомпоновщикНастроекPendingGreenLightEmergencyПользовательскиеНастройки.Видимость = Элементы.ShowPendingGreenLightEmergencyFilters.Пометка;
	
КонецПроцедуры

&НаКлиенте
Процедура ТабличныйДокументPendingGreenlightEmergencyОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ОбработатьРасшифровку(АдресСхемыКомпоновкиPendingGreenLightEmergency, АдресДанныхРасшифровкиPendingGreenLightEmergency, Расшифровка, "LEG4PendingGreenLight");
	
КонецПроцедуры

&НаКлиенте
Процедура ТабличныйДокументCustomsClearanceEmergencyОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ОбработатьРасшифровку(АдресСхемыКомпоновкиCustomsClearanceEmergency, АдресДанныхРасшифровкиCustomsClearanceEmergency, Расшифровка, "LEG6CustomsClearance");
	
КонецПроцедуры // } RGS AGorlenko 11.03.2014 13:09:32 - S-I-0000633

///////////////////////////////////////////////////////////////////////////////////////////
// Sanctions DASHBOARDS
&НаКлиенте
Процедура ShowSanctionsHTCFilters(Команда)
	
	Элементы.ShowSanctionsHTCFilters.Пометка = НЕ Элементы.ShowSanctionsHTCFilters.Пометка;
	Элементы.КомпоновщикНастроекSanctionsHTCПользовательскиеНастройки.Видимость = Элементы.ShowSanctionsHTCFilters.Пометка;
	
КонецПроцедуры

&НаКлиенте
Процедура ТабличныйДокументSanctionsHTCОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ОбработатьРасшифровку(АдресСхемыКомпоновкиSanctionsHTC, АдресДанныхРасшифровкиSanctionsHTC, Расшифровка, "SanctionsReportHTC");
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////
// IMPORT TRACKING

&НаСервере
Процедура НастроитьImportTrackingFiltersНаСервере()
	
	Элементы.ImportTrackingMainFilterValue.Видимость = Истина;

	Если НЕ ЗначениеЗаполнено(Объект.ImportTrackingMainFilter) Тогда
		Объект.ImportTrackingMainFilter = Перечисления.ImportTrackingMainFilters.PONo;
	КонецЕсли;
	
	Если Объект.ImportTrackingMainFilter = ImportTrackingFilterByBORG Тогда
		
		ЗначениеПоУмолчанию = BORGsПустаяСсылка;
		ЗаголовокЗначения = "equals to";
		
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingFilterByProjectMobilization Тогда
		
		Элементы.ImportTrackingMainFilterValue.Видимость = Ложь;

		ЗначениеПоУмолчанию = ProjectMobilizationПустаяСсылка;
		ЗаголовокЗначения = "equals to";
		
	Иначе
		
		ЗначениеПоУмолчанию = "";
		ЗаголовокЗначения = "contains";
		
	КонецЕсли;
	
	Если ТипЗнч(Объект.ImportTrackingMainFilterValue) <> ТипЗнч(ЗначениеПоУмолчанию) Тогда
		
		Объект.ImportTrackingMainFilterValue = ЗначениеПоУмолчанию;
		Элементы.ImportTrackingMainFilterValue.Заголовок = ЗаголовокЗначения;	
		
	КонецЕсли;
	
	//ВидимостьФильтраПоДате = НеобходимФильтрПоДатеДляImportTracking(Объект.ImportTrackingMainFilter);
	//Элементы.ImportTrackingDateFilter.Видимость = ВидимостьФильтраПоДате;
	//Элементы.ImportTrackingDateFrom.Видимость = ВидимостьФильтраПоДате;
	//Элементы.ImportTrackingDateTo.Видимость = ВидимостьФильтраПоДате;
	//
	//Элементы.ImportTrackingUsingBORGFilter.Видимость = Объект.ImportTrackingMainFilter = ImportTrackingFilterByBORG;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция НеобходимФильтрПоДатеДляImportTracking(ОсновнойФильтр)
	
	ImportTrackingMainFilters = Перечисления.ImportTrackingMainFilters;
	Возврат ОсновнойФильтр = ImportTrackingMainFilters.BORG
		ИЛИ ОсновнойФильтр = ImportTrackingMainFilters.PartNo
		ИЛИ ОсновнойФильтр = ImportTrackingMainFilters.SegmentCode;
	
КонецФункции

&НаКлиенте
Процедура НастроитьImportTrackingFiltersНаКлиенте()
	
	Элементы.ImportTrackingMainFilterValue.Видимость = Истина;
	
	Если Объект.ImportTrackingMainFilter = ImportTrackingFilterByBORG Тогда
		
		ЗначениеПоУмолчанию = BORGsПустаяСсылка;
		ЗаголовокЗначения = "equals to";
		//ВидимостьФильтраПоДате = Истина;
		
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingFilterByProjectMobilization Тогда
		
		ЗначениеПоУмолчанию = ProjectMobilizationПустаяСсылка;
		ЗаголовокЗначения = "equals to";
		//ВидимостьФильтраПоДате = Ложь;
		Элементы.ImportTrackingMainFilterValue.Видимость = Ложь;
				
	Иначе
		
		ЗначениеПоУмолчанию = "";
		ЗаголовокЗначения = "contains";
		//ВидимостьФильтраПоДате =
		//	Объект.ImportTrackingMainFilter = ImportTrackingFilterByPartNo
		//	ИЛИ Объект.ImportTrackingMainFilter = ImportTrackingFilterBySegmentCode;
		
	КонецЕсли;
	
	Если ТипЗнч(Объект.ImportTrackingMainFilterValue) <> ТипЗнч(ЗначениеПоУмолчанию) Тогда
		
		Объект.ImportTrackingMainFilterValue = ЗначениеПоУмолчанию;
		Элементы.ImportTrackingMainFilterValue.Заголовок = ЗаголовокЗначения;	
		
	КонецЕсли;
		
	//Элементы.ImportTrackingDateFilter.Видимость = ВидимостьФильтраПоДате;
	//Элементы.ImportTrackingDateFrom.Видимость = ВидимостьФильтраПоДате;
	//Элементы.ImportTrackingDateTo.Видимость = ВидимостьФильтраПоДате;
	//
	//Элементы.ImportTrackingUsingBORGFilter.Видимость = Объект.ImportTrackingMainFilter = ImportTrackingFilterByBORG;
		
КонецПроцедуры 

&НаСервере
Процедура НастроитьImportTrackingVariant()
	
	Объект.ImportTrackingVariantOwner = ПараметрыСеанса.ТекущийПользователь;
	
	Запрос = Новый Запрос;
	
	Запрос.Текст =
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ProjectMobilizationPlanningPerItem.Variant
	|ИЗ
	|	РегистрСведений.ProjectMobilizationPlanningPerItem КАК ProjectMobilizationPlanningPerItem
	|ГДЕ
	|	ProjectMobilizationPlanningPerItem.ProjectMobilization = &ProjectMobilization
	|	И ProjectMobilizationPlanningPerItem.User = &User";
	
	Запрос.УстановитьПараметр("ProjectMobilization",	Объект.ProjectMobilization);
	Запрос.УстановитьПараметр("User",					Объект.ImportTrackingVariantOwner);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Объект.ImportTrackingVariant = Выборка.Variant;
	Иначе
		Объект.ImportTrackingVariant = "My variant";
	КонецЕсли;	
		
КонецПроцедуры

&НаКлиенте
Процедура ImportTrackingVariantНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("ProjectMobilization",		Объект.ProjectMobilization);
	СтруктураПараметров.Вставить("DomesticInternational",	ПредопределенноеЗначение("Перечисление.DomesticInternational.International"));
	
	ОткрытьФорму("Обработка.ProjectMobilizationPlanning.Форма.ФормаВыбораVariant", СтруктураПараметров, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура ImportTrackingVariantОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ТипЗнч(ВыбранноеЗначение) = Тип("Структура") Тогда
		
		СтандартнаяОбработка = Ложь;
		
		Объект.ImportTrackingVariant		= ВыбранноеЗначение.Variant;
		Объект.ImportTrackingVariantOwner	= ВыбранноеЗначение.VariantOwner;
		
	КонецЕсли;
	
КонецПроцедуры

// MAIN FILTER

 &НаКлиенте
Процедура ImportTrackingMainFilterПриИзменении(Элемент)
	
	 НастроитьImportTrackingFiltersНаКлиенте();
	 
КонецПроцедуры 


// SEARCH

&НаКлиенте
Процедура ImportTrackingSearch(Команда)
	
	Если ТипЗнч(Объект.ImportTrackingMainFilterValue) = Тип("Строка") Тогда
		Объект.ImportTrackingMainFilterValue = СокрЛП(Объект.ImportTrackingMainFilterValue);
	КонецЕсли;
	
	Отказ = Ложь;
	
	ПроверитьЗаполнениеImportTrackingFilters(Отказ);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Состояние("Search in progress, please wait...");
	ЗаполнитьImportTrackingНаСервере();
	
	Если Объект.ImportTracking.Количество() = 0 Тогда
		ПоказатьПредупреждение(, 
			"Info incorrectly input or item(s) not yet processed by RCA logistics",
			30);
	КонецЕсли;
		  	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьЗаполнениеImportTrackingFilters(Отказ)
	
	// Проверим заполнение фильтра по стране
	Если НЕ ЗначениеЗаполнено(Объект.ProjectMobilization) Тогда
		Сообщить("Select Project, please!");
		Отказ = Истина;
	КонецЕсли;
	
	// Проверим заполнение основного фильтра
	Если НЕ ЗначениеЗаполнено(Объект.ImportTrackingMainFilter) Тогда
		Сообщить("Fill in the field ""Search by"", please!");
		Отказ = Истина;
	КонецЕсли;
	
	ДлинаMainFilterValue = СтрДлина(Объект.ImportTrackingMainFilterValue);
	Если ДлинаMainFilterValue = 0 И Элементы.ImportTrackingMainFilterValue.Видимость Тогда
		Сообщить("Fill in the field ""contains"", please!");
		Отказ = Истина;
	ИначеЕсли ДлинаMainFilterValue < 3 И Элементы.ImportTrackingMainFilterValue.Видимость Тогда
		Сообщить("The length of the field ""contains"" should be at least 3 characters!");
		Отказ = Истина;
	КонецЕсли;
	
	// При необходимости проверим заполнение дополнительного фильтра
	//Если ЗначениеЗаполнено(Объект.ImportTrackingMainFilter)
	//	И НеобходимФильтрПоДатеДляImportTracking(Объект.ImportTrackingMainFilter) Тогда
	//		
	//	Если НЕ ЗначениеЗаполнено(Объект.ImportTrackingDateFilter) Тогда
	//		Сообщить("Fill in the field ""and by"", please!");
	//		Отказ = Истина;
	//	КонецЕсли;
	//	
	//	Если НЕ ЗначениеЗаполнено(Объект.ImportTrackingDateFrom) Тогда
	//		Сообщить("Fill in the field ""from"", please!");
	//		Отказ = Истина;
	//	КонецЕсли;
	//		
	//	Если НЕ ЗначениеЗаполнено(Объект.ImportTrackingDateTo) Тогда
	//		Сообщить("Fill in the field ""to"", please!");
	//		Отказ = Истина;
	//	КонецЕсли;	
	//	
	//	Если ЗначениеЗаполнено(Объект.ImportTrackingDateFrom)
	//		И ЗначениеЗаполнено(Объект.ImportTrackingDateTo) Тогда
	//		
	//		Если Объект.ImportTrackingDateFrom > Объект.ImportTrackingDateTo Тогда
	//			Сообщить("Date ""from"" should be less than date ""to""!");
	//			Отказ = Истина;
	//		КонецЕсли;
	//		
	//	КонецЕсли;
	//	
	//КонецЕсли;
		
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьImportTrackingНаСервере()
	
	Запрос = Новый Запрос;
	
	ТекстУсловия = "";
	ТекстУсловияManual = "";
	// Установим основной фильтр
	ImportTrackingMainFilters = Перечисления.ImportTrackingMainFilters;
	Если Объект.ImportTrackingMainFilter = ImportTrackingMainFilters.PONo Тогда
		
		ТекстУсловия = ТекстУсловия + "
		|	И Items.НомерЗаявкиНаЗакупку ПОДОБНО ""%"" + """ + Объект.ImportTrackingMainFilterValue + """ + ""%""";
		
		ТекстУсловияManual = ТекстУсловияManual + "
		|	И ProjectMobilizationManualItems.POLine.Код ПОДОБНО ""%"" + """ + Объект.ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingMainFilters.PartNo Тогда
		
		ТекстУсловия = ТекстУсловия + "
		|	И Items.КодПоИнвойсу ПОДОБНО ""%"" + """ + Объект.ImportTrackingMainFilterValue + """ + ""%""";
		
		ТекстУсловияManual = ТекстУсловияManual + "
		|	И ProjectMobilizationManualItems.Наименование ПОДОБНО ""%"" + """ + Объект.ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingMainFilters.InvoiceNo Тогда
		
		ТекстУсловия = ТекстУсловия + "
		|	И Items.Инвойс.Номер ПОДОБНО ""%"" + """ + Объект.ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingMainFilters.DOCNo Тогда
		
		ТекстУсловия = ТекстУсловия + "
		|	И DOCsInvoices.Ссылка.Номер ПОДОБНО ""%"" + """ + Объект.ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingMainFilters.CustomsFileNo Тогда
		
		ТекстУсловия = ТекстУсловия + "
		|	И CustomsFilesOfItems.CustomsFile.Номер ПОДОБНО ""%"" + """ + Объект.ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingMainFilters.ShipmentWaybills Тогда
		
		ТекстУсловия = ТекстУсловия + "
		|	И ShipmentsDOCs.Ссылка.WBList ПОДОБНО ""%"" + """ + Объект.ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingMainFilters.BORG Тогда
		
		Запрос.УстановитьПараметр("BORG", Объект.ImportTrackingMainFilterValue);
		ТекстУсловия = ТекстУсловия + "
		|	И Items.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ = &BORG";
		
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingMainFilters.SegmentCode Тогда
		
		ТекстУсловия = ТекстУсловия + "
		|	И Items.КостЦентр.Segment.Код ПОДОБНО ""%"" + """ + Объект.ImportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingMainFilters.SerialNo Тогда
		
		ТекстУсловия = ТекстУсловия + "
		|	И Items.СерийныйНомер ПОДОБНО ""%"" + """+ Объект.ImportTrackingMainFilterValue + """ + ""%""";
		
	//ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingMainFilters.ProjectMobilization Тогда
	//	
	//	Запрос.УстановитьПараметр("ProjectMobilization", Объект.ImportTrackingMainFilterValue);
	//	ТекстУсловия = ТекстУсловия + "
	//	|	И Items.ProjectMobilization = &ProjectMobilization";
		
	КонецЕсли;
		
	// Установим дополнительный фильтр при необходимости
	//Если НеобходимФильтрПоДатеДляImportTracking(Объект.ImportTrackingMainFilter) Тогда
	//
	//	ImportTrackingDateFilters = Перечисления.ImportTrackingDateFilters;
	//	Если Объект.ImportTrackingDateFilter = ImportTrackingDateFilters.PODate Тогда
	//		
	//		ТекстУсловия = ТекстУсловия + "
	//	    |	И Items.СтрокаЗаявкиНаЗакупку.Владелец.ДатаЗаявкиНаЗакупку >= &DateFrom
	//        |	И Items.СтрокаЗаявкиНаЗакупку.Владелец.ДатаЗаявкиНаЗакупку <= &DateTo";
	//		
	//	ИначеЕсли Объект.ImportTrackingDateFilter = ImportTrackingDateFilters.CollectedFromPortDate Тогда
	//		
	//		ТекстУсловия = ТекстУсловия + "
	//	    |	И ShipmentsDOCs.Ссылка.CollectedFromPort >= &DateFrom
	//        |	И ShipmentsDOCs.Ссылка.CollectedFromPort <= &DateTo";
	//		
	//	КонецЕсли;
	//	
	//    Запрос.УстановитьПараметр("DateFrom", Объект.ImportTrackingDateFrom);
	//	Запрос.УстановитьПараметр("DateTo", Объект.ImportTrackingDateTo);
	//			
	//КонецЕсли;
	
	Запрос.УстановитьПараметр("ProjectMobilization", Объект.ProjectMobilization);
    Запрос.УстановитьПараметр("User",				 Объект.ImportTrackingVariantOwner);
	Запрос.УстановитьПараметр("Variant",			 Объект.ImportTrackingVariant);          
	
	Запрос.Текст =  "ВЫБРАТЬ
	                |	Items.Ссылка КАК Item,
	                |	Items.СтрокаЗаявкиНаЗакупку.Владелец КАК PO,
	                |	Items.СтрокаЗаявкиНаЗакупку КАК POLine,
	                |	Items.Инвойс КАК Invoice,
	                |	Items.Цена КАК ItemValue,
	                |	Items.Сумма КАК TotalItemValue,
	                |	Items.КодПоИнвойсу КАК PartNo,
	                |	Items.ProjectMobilization КАК ProjectMobilization,
	                |	ВЫРАЗИТЬ(Items.НаименованиеТовара КАК СТРОКА(1000)) КАК PartDescription,
	                |	DOCsInvoices.Ссылка КАК DOC,
	                |	DOCsInvoices.Ссылка.POD КАК POD,
	                |	DOCsInvoices.Ссылка.RequestedPOA КАК RequestedPOA,
	                |	DOCsInvoices.Ссылка.MOT КАК MOT,
	                |	ShipmentsDOCs.Ссылка КАК Shipment,
	                |	СУММА(ParcelsДетали.GrossWeightKG) КАК TotalGrossWeightKG,
	                |	0 КАК GrossWeightKG,
	                |	МАКСИМУМ(ParcelsДетали.Ссылка.HazardClass) КАК HazardClass,
	                |	МАКСИМУМ(ВЫБОР
	                |			КОГДА ЕСТЬNULL(ParcelsДетали.Ссылка.RDD, ДАТАВРЕМЯ(1, 1, 1)) = ДАТАВРЕМЯ(1, 1, 1)
	                |				ТОГДА Items.СтрокаЗаявкиНаЗакупку.SupplierPromisedDate
	                |			ИНАЧЕ ЕСТЬNULL(ParcelsДетали.Ссылка.RDD, ДАТАВРЕМЯ(1, 1, 1))
	                |		КОНЕЦ) КАК RDD,
	                |	МАКСИМУМ(ParcelsДетали.Ссылка.Ссылка) КАК Parcel,
	                |	Items.Currency,
	                |	СУММА(ParcelsДетали.Qty) КАК Qty,
	                |	Items.Инвойс.Дата КАК InvoiceDate,
	                |	Items.СтрокаЗаявкиНаЗакупку.Hub1 КАК POLineHub1,
					|   """" КАК Comments
	                |ПОМЕСТИТЬ ТаблицаItem
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
	                |			И (НЕ DOCsInvoices.Ссылка.Отменен)
	                |ГДЕ
	                |	НЕ Items.ПометкаУдаления
	                |	И Items.Ссылка = ЕСТЬNULL(ParcelsДетали.СтрокаИнвойса, Items.Ссылка)
					|	И Items.ProjectMobilization = &ProjectMobilization   "+ТекстУсловия+" 
	                |
	                |СГРУППИРОВАТЬ ПО
	                |	Items.Ссылка,
	                |	Items.СтрокаЗаявкиНаЗакупку.Владелец,
	                |	Items.Инвойс,
	                |	Items.ProjectMobilization,
	                |	Items.Сумма,
	                |	Items.КодПоИнвойсу,
	                |	ВЫРАЗИТЬ(Items.НаименованиеТовара КАК СТРОКА(1000)),
	                |	DOCsInvoices.Ссылка,
	                |	DOCsInvoices.Ссылка.POD,
	                |	DOCsInvoices.Ссылка.RequestedPOA,
	                |	DOCsInvoices.Ссылка.MOT,
	                |	ShipmentsDOCs.Ссылка,
	                |	Items.Currency,
	                |	Items.Инвойс.Дата,
	                |	ВЫБОР
	                |		КОГДА ЕСТЬNULL(ParcelsДетали.Ссылка.WarehouseTo, ЗНАЧЕНИЕ(Справочник.Warehouses.ПустаяСсылка)) = ЗНАЧЕНИЕ(Справочник.Warehouses.ПустаяСсылка)
	                |			ТОГДА Items.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ.DefaultWH
	                |		ИНАЧЕ ЕСТЬNULL(ParcelsДетали.Ссылка.WarehouseTo, ЗНАЧЕНИЕ(Справочник.Warehouses.ПустаяСсылка))
	                |	КОНЕЦ,
	                |	Items.СтрокаЗаявкиНаЗакупку.Hub1,
	                |	Items.СтрокаЗаявкиНаЗакупку,
	                |	Items.Цена
	                |
	                |ОБЪЕДИНИТЬ ВСЕ
	                |
	                |ВЫБРАТЬ
	                |	ProjectMobilizationManualItems.Ссылка,
	                |	ProjectMobilizationManualItems.POLine.Владелец,
	                |	ProjectMobilizationManualItems.POLine,
	                |	NULL,
	                |	ProjectMobilizationManualItems.ItemValue,
	                |	ProjectMobilizationManualItems.ItemValue * ProjectMobilizationManualItems.Qty,
	                |	ProjectMobilizationManualItems.Наименование,
	                |	ProjectMobilizationManualItems.Владелец,
	                |	ProjectMobilizationManualItems.ItemDescription,
	                |	NULL,
	                |	NULL,
	                |	NULL,
	                |	NULL,
	                |	NULL,
	                |	ProjectMobilizationManualItems.GrossWeightKG * ProjectMobilizationManualItems.Qty,
	                |	ProjectMobilizationManualItems.GrossWeightKG,
	                |	ProjectMobilizationManualItems.HazardClass,
	                |	ВЫБОР
	                |		КОГДА ProjectMobilizationManualItems.RDD = ДАТАВРЕМЯ(1, 1, 1)
	                |			ТОГДА ProjectMobilizationManualItems.POLine.SupplierPromisedDate
	                |		ИНАЧЕ ProjectMobilizationManualItems.RDD
	                |	КОНЕЦ,
	                |	NULL,
	                |	NULL,
	                |	ProjectMobilizationManualItems.Qty,
	                |	NULL,
	                |	ProjectMobilizationManualItems.POLine.Hub1,
					|	ProjectMobilizationManualItems.Comments
	                |ИЗ
	                |	Справочник.ProjectMobilizationManualItems КАК ProjectMobilizationManualItems
					|ГДЕ
					|	НЕ ProjectMobilizationManualItems.ПометкаУдаления
					|	И ProjectMobilizationManualItems.DomesticInternational = ЗНАЧЕНИЕ(Перечисление.DomesticInternational.International)
					|	И ProjectMobilizationManualItems.Владелец = &ProjectMobilization  " + 
					?(ТекстУсловияManual = "" И Объект.ImportTrackingMainFilter <> ImportTrackingMainFilters.ProjectMobilization, "И Ложь", ТекстУсловияManual) 
					+ " 
	                |	И ProjectMobilizationManualItems.Item = ЗНАЧЕНИЕ(Справочник.СтрокиИнвойса.ПустаяСсылка)
	                |;
	                |
	                |////////////////////////////////////////////////////////////////////////////////
	                |ВЫБРАТЬ
	                |	ТаблицаItem.Item,
	                |	ТаблицаItem.ProjectMobilization,
	                |	ТаблицаItem.PartNo,
	                |	ТаблицаItem.PartDescription,
	                |	ЕСТЬNULL(ProjectMobilizationPlanningPerItem.HazardClass, ТаблицаItem.HazardClass) КАК HazardClass,
	                |	ЕСТЬNULL(ProjectMobilizationPlanningPerItem.Qty, ТаблицаItem.Qty) КАК Qty,
	                |	ТаблицаItem.GrossWeightKG КАК GrossWeightKG,
	                |	ЕСТЬNULL(ProjectMobilizationPlanningPerItem.TotalGrossWeightKG, ТаблицаItem.TotalGrossWeightKG) КАК TotalGrossWeightKG,
	                |	ЕСТЬNULL(ProjectMobilizationPlanningPerItem.RDD, ТаблицаItem.RDD) КАК RDD,
	                |	ТаблицаItem.PO,
	                |	ТаблицаItem.POLine,
	                |	ТаблицаItem.Invoice,
	                |	ТаблицаItem.ItemValue КАК ItemValue,
	                |	ЕСТЬNULL(ProjectMobilizationPlanningPerItem.TotalItemValue, ТаблицаItem.TotalItemValue) КАК TotalItemValue,
	                |	ЕСТЬNULL(ProjectMobilizationPlanningPerItem.Comments, ТаблицаItem.Comments) КАК Comments,
	                |	ТаблицаItem.DOC,
	                |	ЕСТЬNULL(ProjectMobilizationPlanningPerItem.POD, ТаблицаItem.POD) КАК POD,
	                |	ЕСТЬNULL(ProjectMobilizationPlanningPerItem.POA, ТаблицаItem.RequestedPOA) КАК RequestedPOA,
	                |	ЕСТЬNULL(ProjectMobilizationPlanningPerItem.MOT, ТаблицаItem.MOT) КАК MOT,
	                |	ТаблицаItem.Shipment,
	                |	ТаблицаItem.Parcel,
	                |	ТаблицаItem.Currency,
	                |	ТаблицаItem.InvoiceDate,
	                |	ТаблицаItem.POLineHub1, 				
					|   ProjectMobilizationPlanningPerItem.TotalFreightCost,
					|	ProjectMobilizationPlanningPerItem.Leg1Days,
					|	ProjectMobilizationPlanningPerItem.Leg1Days,
					|	ProjectMobilizationPlanningPerItem.Leg1Days,
					|	ProjectMobilizationPlanningPerItem.Leg2Days,
					|	ProjectMobilizationPlanningPerItem.Leg3Days,
					|	ProjectMobilizationPlanningPerItem.Leg4Days,
					|	ProjectMobilizationPlanningPerItem.Leg5Days,
					|	ProjectMobilizationPlanningPerItem.Leg6Days,
					|	ProjectMobilizationPlanningPerItem.TotalLegsDays
					|ИЗ
					|	ТаблицаItem КАК ТаблицаItem
	                |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ProjectMobilizationPlanningPerItem КАК ProjectMobilizationPlanningPerItem
	                |		ПО ТаблицаItem.ProjectMobilization = ProjectMobilizationPlanningPerItem.ProjectMobilization
	                |			И ТаблицаItem.Item = ProjectMobilizationPlanningPerItem.Item
	                |			И (ProjectMobilizationPlanningPerItem.User = &User)
	                |			И (ProjectMobilizationPlanningPerItem.Variant = &Variant)";
			
	
	УстановитьПривилегированныйРежим(Истина);
	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	Объект.ImportTracking.Очистить();
	
	Для Каждого Стр из РезультатЗапроса Цикл 
		
		НоваяСтрока = Объект.ImportTracking.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Стр);
		
		Если Не ЗначениеЗаполнено(НоваяСтрока.GrossWeightKG) 
			И ЗначениеЗаполнено(НоваяСтрока.TotalGrossWeightKG)
			И ЗначениеЗаполнено(НоваяСтрока.Qty) Тогда 
			НоваяСтрока.GrossWeightKG = НоваяСтрока.TotalGrossWeightKG / НоваяСтрока.Qty;
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(НоваяСтрока.FreightCostPerKG) 
			И ЗначениеЗаполнено(НоваяСтрока.TotalFreightCost)
			И ЗначениеЗаполнено(НоваяСтрока.TotalGrossWeightKG) Тогда 
			НоваяСтрока.FreightCostPerKG = НоваяСтрока.TotalFreightCost / НоваяСтрока.TotalGrossWeightKG;
		КонецЕсли;

		Если Не ЗначениеЗаполнено(НоваяСтрока.GrossWeightKG) 
			И ЗначениеЗаполнено(НоваяСтрока.TotalGrossWeightKG)
			И ЗначениеЗаполнено(НоваяСтрока.Qty) Тогда 
			НоваяСтрока.GrossWeightKG = НоваяСтрока.TotalGrossWeightKG / НоваяСтрока.Qty;
		КонецЕсли;

		Если Не ЗначениеЗаполнено(НоваяСтрока.POD) 
			И ЗначениеЗаполнено(Стр.POLineHub1) Тогда 
			НоваяСтрока.POD = Справочники.CountriesHUBs.НайтиПоКоду("#"+СокрЛП(Стр.POLineHub1));
		КонецЕсли;
		
	КонецЦикла;
	 	
	
КонецПроцедуры


// DOCUMENTS AND ATACHMENTS

&НаКлиенте
Процедура ImportTrackingDocumentsAndAttachments(Команда)
	
	OpenImportDocumentsAndAttachments();
	
КонецПроцедуры

&НаКлиенте
Процедура OpenImportDocumentsAndAttachments()
	
	ТекДанные = Элементы.ImportTracking.ТекущиеДанные;
	
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("Invoice",  ТекДанные.Invoice);
	СтруктураОтбора.Вставить("DOC",      ТекДанные.DOC);
	СтруктураОтбора.Вставить("Shipment", ТекДанные.Shipment);
	СтруктураОтбора.Вставить("CustomsFile", ТекДанные.CustomsFile);
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Отбор", СтруктураОтбора);		
	//!!!ОткрытьФорму("Обработка.ProjectMobilizationPlanning.Форма.DocumentsAndAttachments", ПараметрыФормы, ЭтаФорма, ТекДанные.Invoice);
	
КонецПроцедуры


// SAVE AS .CSV FILE
     
&НаКлиенте
Процедура ImportTrackingSaveAsCsvFile(Команда)
	
	МассивИдентификаторовСтрок = ПолучитьИдентификаторыСтрокСоответствующихОтбору(Объект.ImportTracking, Элементы.ImportTracking);
	Если МассивИдентификаторовСтрок.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	АдресФайлаВоВременномХранилище = ПолучитьАдресCSVФайлаImportTracking(МассивИдентификаторовСтрок);									
	ПолучитьФайл(АдресФайлаВоВременномХранилище, "Import_tracking.csv");
	
КонецПроцедуры

&НаСервере
Функция ПолучитьАдресCSVФайлаImportTracking(МассивИдентификаторовСтрок)
	
	Возврат ПолучитьАдресCSVФайла(Объект.ImportTracking, МассивИдентификаторовСтрок, Элементы.ImportTracking, УникальныйИдентификатор);
	
КонецФункции


// ТАБЛИЦА IMPORT TRACKING

&НаКлиенте
Процедура ImportTrackingУстановитьФлажки(Команда)
	
	Для Каждого СтрокаТаблицы Из Объект.ImportTracking Цикл
		СтрокаТаблицы.флажок = Истина;
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура ImportTrackingСнятьФлажки(Команда)
	
	Для Каждого СтрокаТаблицы Из Объект.ImportTracking Цикл
		СтрокаТаблицы.флажок = Ложь;
	КонецЦикла;

КонецПроцедуры


&НаКлиенте
Процедура ImportTrackingВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	OpenImportDocumentsAndAttachments();
	
КонецПроцедуры

&НаКлиенте
Процедура OpenItem(Команда)
	
	ТекДанные = Элементы.ImportTracking.ТекущиеДанные;
	Если ТекДанные <> Неопределено И ЗначениеЗаполнено(ТекДанные.Item) Тогда 
		ПоказатьЗначение(,ТекДанные.Item);
	КонецЕсли;
	
КонецПроцедуры

// Specify Project Mobilization

&НаКлиенте
Процедура SpecifyProjectMobilization(Команда)
	        	
	МассивВыделенныхGoods = ПолучитьМассивВыделенныхItems();
	Если МассивВыделенныхGoods.Количество() = 0 Тогда
		Предупреждение(
			"Please, select at least one item line!",
			30);
		Возврат;
	КонецЕсли;
	
	ОткрытьФорму("Справочник.ProjectMobilization.ФормаВыбора", , ЭтаФорма, , , , 
		Новый ОписаниеОповещения("ВыполнитьПослеВыбораProjectMobilization", ЭтотОбъект, МассивВыделенныхGoods));
		
КонецПроцедуры

&НаКлиенте
Функция ПолучитьМассивВыделенныхItems()
	
	МассивGoods = Новый Массив;
	ВыделенныеСтроки = Элементы.ImportTracking.ВыделенныеСтроки;
	Для Каждого ВыделеннаяСтрока Из ВыделенныеСтроки Цикл
		
		СтрокаТаблицы = Объект.ImportTracking.НайтиПоИдентификатору(ВыделеннаяСтрока);
		Если ЗначениеЗаполнено(СтрокаТаблицы.Item) Тогда
			МассивGoods.Добавить(СтрокаТаблицы.Item);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат МассивGoods;
	
КонецФункции

&НаКлиенте
Процедура ВыполнитьПослеВыбораProjectMobilization(Результат, МассивВыделенныхGoods)  Экспорт 
	
	Если Не ЗначениеЗаполнено(Результат) Тогда
		Возврат;
	КонецЕсли;
	
	МассивИзмененныхItems = РГСофт.ИзменитьРеквизитВСсылкахВПривилегированномРежиме(МассивВыделенныхGoods, "ProjectMobilization", Результат);

	ОбновитьКолонкуВGoods(МассивИзмененныхItems, "ProjectMobilization", Результат);
 	    	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьКолонкуВGoods(МассивGoods, ИмяКолонки, Значение)
	
	Для Каждого СтрокаТаблицы Из Объект.ImportTracking Цикл
		
		Если МассивGoods.Найти(СтрокаТаблицы.Item) <> Неопределено Тогда
			СтрокаТаблицы[ИмяКолонки] = Значение;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////
// EXPORT TRACKING

&НаСервере
Процедура НастроитьExportTrackingFiltersНаСервере()
	
	Если НЕ ЗначениеЗаполнено(Объект.ExportTrackingMainFilter) Тогда
		Объект.ExportTrackingMainFilter = Перечисления.ExportTrackingMainFilters.ExportRequestNo;
	КонецЕсли;
		
	Если Объект.ExportTrackingMainFilter = ExportTrackingFilterByBORG Тогда
		
		ЗначениеПоУмолчанию = BORGsПустаяСсылка;
		ЗаголовокЗначения = "equals to";	
	
	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingFilterByFinalDestination Тогда
		
		ЗначениеПоУмолчанию = CountriesHUBsПустаяСсылка;
		ЗаголовокЗначения = "equals to";
		
	Иначе
		
		ЗначениеПоУмолчанию = "";
		ЗаголовокЗначения = "contains";
			
	КонецЕсли;
	
	Если ТипЗнч(Объект.ExportTrackingMainFilterValue) <> ТипЗнч(ЗначениеПоУмолчанию) Тогда
		
		Объект.ExportTrackingMainFilterValue = ЗначениеПоУмолчанию;
		Элементы.ExportTrackingMainFilterValue.Заголовок = ЗаголовокЗначения;	
		
	КонецЕсли;
	
	ВидимостьФильтраПоДате = НеобходимФильтрПоДатеДляExportTracking(Объект.ExportTrackingMainFilter);
	Элементы.ExportTrackingDateFilter.Видимость = ВидимостьФильтраПоДате;
	Элементы.ExportTrackingDateFrom.Видимость = ВидимостьФильтраПоДате;
	Элементы.ExportTrackingDateTo.Видимость = ВидимостьФильтраПоДате;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция НеобходимФильтрПоДатеДляExportTracking(ОсновнойФильтр)
	
	ExportTrackingMainFilters = Перечисления.ExportTrackingMainFilters;
	Возврат ОсновнойФильтр = ExportTrackingMainFilters.BORG
		ИЛИ ОсновнойФильтр = ExportTrackingMainFilters.FinalDestination
		ИЛИ ОсновнойФильтр = ExportTrackingMainFilters.PartDescription
		ИЛИ ОсновнойФильтр = ExportTrackingMainFilters.PartNo
		ИЛИ ОсновнойФильтр = ExportTrackingMainFilters.SegmentCode
		ИЛИ ОсновнойФильтр = ExportTrackingMainFilters.SubmitterAlias;
	
КонецФункции

&НаКлиенте
Процедура НастроитьExportTrackingFiltersНаКлиенте()
	
	Если Объект.ExportTrackingMainFilter = ExportTrackingFilterByBORG Тогда
		
		ЗначениеПоУмолчанию = BORGsПустаяСсылка;
		ЗаголовокЗначения = "equals to";
		ВидимостьФильтраПоДате = Истина;
	
	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingFilterByFinalDestination Тогда
		
		ЗначениеПоУмолчанию = CountriesHUBsПустаяСсылка;
		ЗаголовокЗначения = "equals to";
		ВидимостьФильтраПоДате = Истина;
		
	Иначе
		
		ЗначениеПоУмолчанию = "";
		ЗаголовокЗначения = "contains";	
		ВидимостьФильтраПоДате =
			Объект.ExportTrackingMainFilter = ExportTrackingFilterByPartDescription
			ИЛИ Объект.ExportTrackingMainFilter = ExportTrackingFilterByPartNo
			ИЛИ Объект.ExportTrackingMainFilter = ExportTrackingFilterBySegmentCode
			ИЛИ Объект.ExportTrackingMainFilter = ExportTrackingFilterBySubmitterAlias;
		
	КонецЕсли;
	
	Если ТипЗнч(Объект.ExportTrackingMainFilterValue) <> ТипЗнч(ЗначениеПоУмолчанию) Тогда
		
		Объект.ExportTrackingMainFilterValue = ЗначениеПоУмолчанию;
		Элементы.ExportTrackingMainFilterValue.Заголовок = ЗаголовокЗначения;	
		
	КонецЕсли;
	
	Элементы.ExportTrackingDateFilter.Видимость = ВидимостьФильтраПоДате;
	Элементы.ExportTrackingDateFrom.Видимость = ВидимостьФильтраПоДате;
	Элементы.ExportTrackingDateTo.Видимость = ВидимостьФильтраПоДате;
	
КонецПроцедуры


// MAIN FILTER

&НаКлиенте
Процедура ExportTrackingMainFilterПриИзменении(Элемент)
	
	НастроитьExportTrackingFiltersНаКлиенте();
	
КонецПроцедуры


// SEARCH

&НаКлиенте
Процедура ExportTrackingSearch(Команда)
	
	Если ТипЗнч(Объект.ExportTrackingMainFilterValue) = Тип("Строка") Тогда
		Объект.ExportTrackingMainFilterValue = СокрЛП(Объект.ExportTrackingMainFilterValue);
	КонецЕсли;
	
	Отказ = Ложь;
	
	ПроверитьЗаполнениеExportTrackingFilters(Отказ);
	                                  
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Состояние("Search in progress, please wait...");
	ЗаполнитьExportTrackingНаСервере();
	
	Если Объект.ExportTracking.Количество() = 0 Тогда
		ПоказатьПредупреждение(,
			"Info incorrectly input or item(s) not yet processed by RCA logistics",
			30);
	КонецЕсли;
		  	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьЗаполнениеExportTrackingFilters(Отказ)
	
		
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьExportTrackingНаСервере()
			
		
КонецПроцедуры


// DOCUMENTS AND ATTACHMENTS

&НаКлиенте
Процедура ExportTrackingDocumentsAndAttachments(Команда)
	
	OpenExportDocumentsAndAttachments();
	
КонецПроцедуры

&НаКлиенте
Процедура OpenExportDocumentsAndAttachments()
	
	ТекДанные = Элементы.ExportTracking.ТекущиеДанные;
	
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
		
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("ExportRequest", ТекДанные.ExportRequest);
	СтруктураОтбора.Вставить("ExportShipment", ТекДанные.ExportShipment);
	СтруктураОтбора.Вставить("CustomsFile", ТекДанные.CustomsFile);	
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Отбор", СтруктураОтбора);		
	//!!!ОткрытьФорму("Обработка.ProjectMobilizationPlanning.Форма.DocumentsAndAttachments", ПараметрыФормы, ЭтаФорма, ТекДанные.ExportRequest);
	
КонецПроцедуры


// SAVE AS .CSV

// ДОДЕЛАТЬ
&НаКлиенте
Процедура ExportTrackingSaveAsCsvFile(Команда)
	
	МассивИдентификаторовСтрок = ПолучитьИдентификаторыСтрокСоответствующихОтбору(Объект.ExportTracking, Элементы.ExportTracking);
	Если МассивИдентификаторовСтрок.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	АдресФайлаВоВременномХранилище = ПолучитьАдресCSVФайлаExportTracking(МассивИдентификаторовСтрок);									
	ПолучитьФайл(АдресФайлаВоВременномХранилище, "Export_tracking.csv");
	
КонецПроцедуры

&НаСервере
Функция ПолучитьАдресCSVФайлаExportTracking(МассивИдентификаторовСтрок)
	
	Возврат ПолучитьАдресCSVФайла(Объект.ExportTracking, МассивИдентификаторовСтрок, Элементы.ExportTracking, УникальныйИдентификатор);
	
КонецФункции


// ТАБЛИЦА EXPORT TRACKING

&НаКлиенте
Процедура ExportTrackingВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	OpenExportDocumentsAndAttachments();
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////
// DOMESTIC PLANNING

&НаСервере
Процедура НастроитьDomesticPlanningFiltersНаСервере()
	
	Если Не ЗначениеЗаполнено(Объект.DomesticPlanningMainFilter) Тогда
		Объект.DomesticPlanningMainFilter = Перечисления.DomesticPlanningMainFilters.PartNo;
	КонецЕсли;
	
	ЗначениеПоУмолчанию = "";
	ЗаголовокЗначения = "contains";
	
	Если ТипЗнч(Объект.DomesticPlanningMainFilterValue) <> ТипЗнч(ЗначениеПоУмолчанию) Тогда
		
		Объект.DomesticPlanningMainFilterValue = ЗначениеПоУмолчанию;
		Элементы.DomesticPlanningMainFilterValue.Заголовок = ЗаголовокЗначения;	
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура НастроитьDomesticPlanningVariant()
	
	Объект.DomesticPlanningVariantOwner = ПараметрыСеанса.ТекущийПользователь;
	
	Запрос = Новый Запрос;
	
	Запрос.Текст =
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ProjectMobilizationPlanningDomestic.Variant
	|ИЗ
	|	РегистрСведений.ProjectMobilizationPlanningDomestic КАК ProjectMobilizationPlanningDomestic
	|ГДЕ
	|	ProjectMobilizationPlanningDomestic.ProjectMobilization = &ProjectMobilization
	|	И ProjectMobilizationPlanningDomestic.User = &User";
	
	Запрос.УстановитьПараметр("ProjectMobilization",	Объект.ProjectMobilization);
	Запрос.УстановитьПараметр("User",					Объект.DomesticPlanningVariantOwner);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Объект.DomesticPlanningVariant = Выборка.Variant;
	Иначе
		Объект.DomesticPlanningVariant = "My variant";
	КонецЕсли;	
		
КонецПроцедуры

&НаКлиенте
Процедура НастроитьDomesticPlanningFiltersНаКлиенте()
	
	Элементы.DomesticPlanningMainFilterValue.Видимость = Истина;
	
	Если Объект.DomesticPlanningMainFilter = ПредопределенноеЗначение("Перечисление.DomesticPlanningMainFilters.ProjectMobilization") Тогда
		
		ЗначениеПоУмолчанию = ПредопределенноеЗначение("Справочник.ProjectMobilization.ПустаяСсылка");
		ЗаголовокЗначения = "contains";
		Элементы.DomesticPlanningMainFilterValue.Видимость = Ложь;
				
	Иначе
		
		ЗначениеПоУмолчанию = "";
		ЗаголовокЗначения = "contains";
		
	КонецЕсли;
	
	Если ТипЗнч(Объект.DomesticPlanningMainFilterValue) <> ТипЗнч(ЗначениеПоУмолчанию) Тогда
		
		Объект.DomesticPlanningMainFilterValue = ЗначениеПоУмолчанию;
		Элементы.DomesticPlanningMainFilterValue.Заголовок = ЗаголовокЗначения;	
		
	КонецЕсли;
		
КонецПроцедуры 

&НаКлиенте
Процедура DomesticPlanningVariantНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("ProjectMobilization",		Объект.ProjectMobilization);
	СтруктураПараметров.Вставить("DomesticInternational",	ПредопределенноеЗначение("Перечисление.DomesticInternational.Domestic"));
	
	ОткрытьФорму("Обработка.ProjectMobilizationPlanning.Форма.ФормаВыбораVariant", СтруктураПараметров, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningVariantОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ТипЗнч(ВыбранноеЗначение) = Тип("Структура") Тогда
		
		СтандартнаяОбработка = Ложь;
		
		Объект.DomesticPlanningVariant		= ВыбранноеЗначение.Variant;
		Объект.DomesticPlanningVariantOwner	= ВыбранноеЗначение.VariantOwner;
		
	КонецЕсли;
	
КонецПроцедуры

// MAIN FILTER

&НаКлиенте
Процедура DomesticPlanningMainFilterПриИзменении(Элемент)
	
	НастроитьDomesticPlanningFiltersНаКлиенте();
	
КонецПроцедуры

// SEARCH

&НаКлиенте
Процедура DomesticPlanningSearch(Команда)
	
	Если ТипЗнч(Объект.DomesticPlanningMainFilterValue) = Тип("Строка") Тогда
		Объект.DomesticPlanningMainFilterValue = СокрЛП(Объект.DomesticPlanningMainFilterValue);
	КонецЕсли;
	
	Отказ = Ложь;
	
	ПроверитьЗаполнениеDomesticPlanningFilters(Отказ);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Состояние("Search in progress, please wait...");
	ЗаполнитьDomesticPlanningНаСервере();
	
	Если Объект.DomesticPlanning.Количество() = 0 Тогда
		ПоказатьПредупреждение(, 
			"Info incorrectly input or item(s) not yet processed by RCA logistics",
			30);
	КонецЕсли;
		  	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьЗаполнениеDomesticPlanningFilters(Отказ)
	
	// Проверим заполнение фильтра по стране
	Если НЕ ЗначениеЗаполнено(Объект.ProjectMobilization) Тогда
		Сообщить("Select Project, please!");
		Отказ = Истина;
	КонецЕсли;
	
	// Проверим заполнение основного фильтра
	Если НЕ ЗначениеЗаполнено(Объект.DomesticPlanningMainFilter) Тогда
		Сообщить("Fill in the field ""Search by"", please!");
		Отказ = Истина;
	КонецЕсли;
	
	ДлинаMainFilterValue = СтрДлина(Объект.DomesticPlanningMainFilterValue);
	Если ДлинаMainFilterValue = 0 И Элементы.DomesticPlanningMainFilterValue.Видимость Тогда
		Сообщить("Fill in the field ""contains"", please!");
		Отказ = Истина;
	ИначеЕсли ДлинаMainFilterValue < 3 И Элементы.DomesticPlanningMainFilterValue.Видимость Тогда
		Сообщить("The length of the field ""contains"" should be at least 3 characters!");
		Отказ = Истина;
	КонецЕсли;
			
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьDomesticPlanningНаСервере()
	
	Запрос = Новый Запрос;
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ParcelsДетали.Ссылка.TransportRequest КАК TransportRequest,
	|	ParcelsДетали.СтрокаИнвойса КАК Item,
	|	ParcelsДетали.Ссылка.TransportRequest.ProjectMobilization КАК ProjectMobilization,
	|	ParcelsДетали.СтрокаИнвойса.КодПоИнвойсу КАК PartNo,
	|	ParcelsДетали.СтрокаИнвойса.НаименованиеТовара КАК PartDescription,
	|	ParcelsДетали.Ссылка.HazardClass КАК HazardClass,
	|	ParcelsДетали.Qty КАК Qty,
	|	ParcelsДетали.Ссылка.GrossWeight КАК GrossWeightKG,
	|	ParcelsДетали.Ссылка.GrossWeight КАК TotalGrossWeightKG,
	|	ParcelsДетали.Ссылка.TransportRequest.RequestedUniversalTime КАК RDD,
	|	ParcelsДетали.Ссылка.Comment КАК Comments,
	|	ParcelsДетали.Ссылка.TransportRequest.PickUpWarehouse КАК LocationFrom,
	|	ParcelsДетали.Ссылка.TransportRequest.DeliverTo КАК LocationTo
	|ПОМЕСТИТЬ ТаблицаParcels
	|ИЗ
	|	Справочник.Parcels.Детали КАК ParcelsДетали
	|ГДЕ
	|	ParcelsДетали.Ссылка.TransportRequest.ProjectMobilization = &ProjectMobilization
	|	И &MainFilterParcels
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ProjectMobilizationManualItems.Ссылка КАК Item,
	|	ProjectMobilizationManualItems.Владелец КАК ProjectMobilization,
	|	ProjectMobilizationManualItems.Наименование КАК PartNo,
	|	ProjectMobilizationManualItems.ItemDescription КАК PartDescription,
	|	ProjectMobilizationManualItems.HazardClass КАК HazardClass,
	|	ProjectMobilizationManualItems.Qty КАК Qty,
	|	ProjectMobilizationManualItems.GrossWeightKG КАК GrossWeightKG,
	|	ProjectMobilizationManualItems.Qty * ProjectMobilizationManualItems.GrossWeightKG КАК TotalGrossWeightKG,
	|	ProjectMobilizationManualItems.RDD КАК RDD,
	|	ProjectMobilizationManualItems.Comments КАК Comments,
	|	ProjectMobilizationManualItems.PickUpWarehouse КАК LocationFrom,
	|	ProjectMobilizationManualItems.DeliverTo КАК LocationTo,
	|	ProjectMobilizationManualItems.Item КАК СтрокаИнвойса
	|ПОМЕСТИТЬ ТаблицаManualItem
	|ИЗ
	|	Справочник.ProjectMobilizationManualItems КАК ProjectMobilizationManualItems
	|ГДЕ
	|	ProjectMobilizationManualItems.Владелец = &ProjectMobilization
	|	И ProjectMobilizationManualItems.DomesticInternational = ЗНАЧЕНИЕ(Перечисление.DomesticInternational.Domestic)
	|	И &MainFilterManual
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицаParcels.TransportRequest КАК TransportRequest,
	|	ЕСТЬNULL(ТаблицаParcels.Item, ТаблицаManualItem.Item) КАК Item,
	|	ЕСТЬNULL(ТаблицаParcels.ProjectMobilization, ТаблицаManualItem.ProjectMobilization) КАК ProjectMobilization,
	|	ЕСТЬNULL(ТаблицаParcels.PartNo, ТаблицаManualItem.PartNo) КАК PartNo,
	|	ЕСТЬNULL(ТаблицаParcels.PartDescription, ТаблицаManualItem.PartDescription) КАК PartDescription,
	|	ЕСТЬNULL(ТаблицаParcels.HazardClass, ТаблицаManualItem.HazardClass) КАК HazardClass,
	|	ЕСТЬNULL(ТаблицаParcels.Qty, ТаблицаManualItem.Qty) КАК Qty,
	|	ЕСТЬNULL(ТаблицаParcels.GrossWeightKG, ТаблицаManualItem.GrossWeightKG) КАК GrossWeightKG,
	|	ЕСТЬNULL(ТаблицаParcels.TotalGrossWeightKG, ТаблицаManualItem.TotalGrossWeightKG) КАК TotalGrossWeightKG,
	|	ЕСТЬNULL(ТаблицаParcels.RDD, ТаблицаManualItem.RDD) КАК RDD,
	|	ЕСТЬNULL(ТаблицаParcels.Comments, ТаблицаManualItem.Comments) КАК Comments,
	|	ЕСТЬNULL(ТаблицаParcels.LocationFrom, ТаблицаManualItem.LocationFrom) КАК LocationFrom,
	|	ЕСТЬNULL(ТаблицаParcels.LocationTo, ТаблицаManualItem.LocationTo) КАК LocationTo
	|ПОМЕСТИТЬ ТаблицаItem
	|ИЗ
	|	ТаблицаParcels КАК ТаблицаParcels
	|		ПОЛНОЕ СОЕДИНЕНИЕ ТаблицаManualItem КАК ТаблицаManualItem
	|		ПО ТаблицаParcels.Item = ТаблицаManualItem.СтрокаИнвойса
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицаItem.TransportRequest,
	|	ТаблицаItem.Item,
	|	ТаблицаItem.ProjectMobilization,
	|	ТаблицаItem.PartNo,
	|	ТаблицаItem.PartDescription,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomestic.HazardClass, ТаблицаItem.HazardClass) КАК HazardClass,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomestic.Qty, ТаблицаItem.Qty) КАК Qty,
	|	ТаблицаItem.GrossWeightKG КАК GrossWeightKG,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomestic.TotalGrossWeightKG, ТаблицаItem.TotalGrossWeightKG) КАК TotalGrossWeightKG,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomestic.RDD, ТаблицаItem.RDD) КАК RDD,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomestic.Comments, ТаблицаItem.Comments) КАК Comments,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomestic.LocationFrom, ТаблицаItem.LocationFrom) КАК LocationFrom,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomestic.LocationTo, ТаблицаItem.LocationTo) КАК LocationTo,
	|	ProjectMobilizationPlanningDomestic.Company,
	|	ProjectMobilizationPlanningDomestic.Equipment,
	|	ProjectMobilizationPlanningDomestic.MOT,
	|	ProjectMobilizationPlanningDomestic.Milage,
	|	ProjectMobilizationPlanningDomestic.FreightCostPerKM,
	|	ProjectMobilizationPlanningDomestic.TotalFreightCostKM,
	|	ProjectMobilizationPlanningDomestic.FreightCostPerKG,
	|	ProjectMobilizationPlanningDomestic.TotalFreightCostKG,
	|	ProjectMobilizationPlanningDomestic.TonneKilometers,
	|	ProjectMobilizationPlanningDomestic.FreightCostPerTKM,
	|	ProjectMobilizationPlanningDomestic.TotalFreightCostTKM,
	|	ProjectMobilizationPlanningDomestic.TotalActualDuration,
	|	ЕСТЬNULL(ProjectMobilizationPlanningDomestic.NumOfTransport, 1) КАК NumOfTransport
	|ИЗ
	|	ТаблицаItem КАК ТаблицаItem
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ProjectMobilizationPlanningDomestic КАК ProjectMobilizationPlanningDomestic
	|		ПО ТаблицаItem.ProjectMobilization = ProjectMobilizationPlanningDomestic.ProjectMobilization
	|			И ТаблицаItem.Item = ProjectMobilizationPlanningDomestic.Item
	|			И (ProjectMobilizationPlanningDomestic.User = &User)
	|			И (ProjectMobilizationPlanningDomestic.Variant = &Variant)";
	
	Если Объект.DomesticPlanningMainFilter = Перечисления.DomesticPlanningMainFilters.PartNo Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&MainFilterParcels",	"ParcelsДетали.СтрокаИнвойса.КодПоИнвойсу ПОДОБНО &MainFilterValue");
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&MainFilterManual",	"ProjectMobilizationManualItems.Наименование ПОДОБНО &MainFilterValue");
	ИначеЕсли Объект.DomesticPlanningMainFilter = Перечисления.DomesticPlanningMainFilters.TransportRequestNo Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&MainFilterParcels",	"ParcelsДетали.Ссылка.TransportRequest.Номер ПОДОБНО &MainFilterValue");
	Иначе
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&MainFilterParcels",	"Истина");
	КонецЕсли;
	
	Запрос.УстановитьПараметр("ProjectMobilization",	Объект.ProjectMobilization);
	Запрос.УстановитьПараметр("MainFilterValue",		"%"+Объект.DomesticPlanningMainFilterValue+"%");
	Запрос.УстановитьПараметр("MainFilterParcels",		Истина);
	Запрос.УстановитьПараметр("MainFilterManual",		Истина);
	Запрос.УстановитьПараметр("User",					Объект.DomesticPlanningVariantOwner);
	Запрос.УстановитьПараметр("Variant",				Объект.DomesticPlanningVariant);
	
	Таблица = Запрос.Выполнить().Выгрузить();
	
	Объект.DomesticPlanning.Загрузить(Таблица);
	
	Для Каждого Строка Из Объект.DomesticPlanning Цикл
		Строка.ПредставлениеDuration	= ПолучитьПредставлениеDuration(Строка.TotalActualDuration);
	КонецЦикла;
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////
// ОБЩИЕ ПРОЦЕДУРЫ И ФУНКЦИИ

&НаКлиенте
Функция ПолучитьИдентификаторыСтрокСоответствующихОтбору(ДанныеФормыКоллекция, ТаблицаФормы)
	
	МассивИдентификаторовСтрок = Новый Массив;
		
	Для Каждого СтрокаТЧ Из ДанныеФормыКоллекция Цикл 
		
		ИдентификаторСтроки = СтрокаТЧ.ПолучитьИдентификатор();
		 		
		Если ТаблицаФормы.ПроверитьСтроку(ИдентификаторСтроки) Тогда
			МассивИдентификаторовСтрок.Добавить(ИдентификаторСтроки);
		КонецЕсли;
			
	КонецЦикла;	
		
	Возврат МассивИдентификаторовСтрок;
		
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьАдресCSVФайла(ДанныеФормыКоллекция, МассивИдентификаторовСтрок, ТаблицаФормы, УникальныйИдентификатор)
	
	МассивИменИЗаголовковКолонок = ПолучитьМассивИменИЗаголовковВидимыхКолонок(ТаблицаФормы);
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла(".csv");
	                             		
	ЗаписьТекста = Новый ЗаписьТекста(ИмяВременногоФайла);
	
	// Сформируем Заголовок
	ЗаголовокТаблицы = "";
	Для Каждого ИмяИЗаголовок из МассивИменИЗаголовковКолонок Цикл
		ЗаголовокТаблицы = ЗаголовокТаблицы + """" + ИмяИЗаголовок.Заголовок + """,";
	КонецЦикла;
	ЗаголовокТаблицы = Лев(ЗаголовокТаблицы, СтрДлина(ЗаголовокТаблицы)-1);	
    ЗаписьТекста.ЗаписатьСтроку(ЗаголовокТаблицы);
	
	// Сформируем строки файла
	Для Каждого ИдентификаторСтроки из МассивИдентификаторовСтрок Цикл 
		
		СтрокаТЧ = ДанныеФормыКоллекция.НайтиПоИдентификатору(ИдентификаторСтроки);
			
		НоваяСтрокаФайла = "";
		Для Каждого ИмяИЗаголовок Из МассивИменИЗаголовковКолонок Цикл
			
			Значение = СтрокаТЧ[ИмяИЗаголовок.Имя];
			ЗначениеТекстом = ImportExportСервер.ПолучитьЗначениеТекстом(Значение);
			НоваяСтрокаФайла = НоваяСтрокаФайла + """" + ЗначениеТекстом + """,";
			
		КонецЦикла;	
		НоваяСтрокаФайла = Лев(НоваяСтрокаФайла, СтрДлина(НоваяСтрокаФайла)-1);
		ЗаписьТекста.ЗаписатьСтроку(НоваяСтрокаФайла);
				
	КонецЦикла;
	
	ЗаписьТекста.Закрыть();
	
	ДвоичныеДанные = Новый ДвоичныеДанные(ИмяВременногоФайла);
	
	Попытка
		УдалитьФайлы(ИмяВременногоФайла);
	Исключение
		ЗаписьЖурналаРегистрации(
			"Ошибка удаления временного .csv файла в RIET",
			УровеньЖурналаРегистрации.Ошибка,
			//!!!Метаданные.ОбрабProjectMobilizationPlanningtionPlanning,
			,
			"Не удалось удалить """ + ИмяВременногоФайла + """: " + ОписаниеОшибки());
	КонецПопытки;
	
    АдресФайла = ПоместитьВоВременноеХранилище(ДвоичныеДанные, УникальныйИдентификатор);
			
	Возврат АдресФайла;	
    	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьМассивИменИЗаголовковВидимыхКолонок(ТаблицаФормы)
		
	Массив = Новый Массив;
	
	ТипПолеФормы = Тип("ПолеФормы");
	ПодчиненныеЭлементы = ТаблицаФормы.ПодчиненныеЭлементы;
	Для Каждого ЭлементФормы из ПодчиненныеЭлементы Цикл
		
		Если Тип(ЭлементФормы) = ТипПолеФормы
			И ЭлементФормы.Видимость
			И ЗначениеЗаполнено(ЭлементФормы.Заголовок) Тогда 
			
			ИмяКолонки = ПолучитьИмяКолонкиПоПутиКДанным(ЭлементФормы.ПутьКДанным);
			Структура = Новый Структура("Имя, Заголовок", ИмяКолонки, ЭлементФормы.Заголовок); 
			Массив.Добавить(Структура);
					
		КонецЕсли;
		
	КонецЦикла;	
	
	Возврат Массив;
		
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьИмяКолонкиПоПутиКДанным(Знач ПутьКДанным)
	
	Пока Истина Цикл
		
		ПозицияТочки = СтрНайти(ПутьКДанным, ".");
		Если ПозицияТочки = 0 Тогда
			Прервать;
		КонецЕсли;
		ПутьКДанным = Сред(ПутьКДанным, ПозицияТочки+1); 
		
	КонецЦикла;
	
	Возврат ПутьКДанным;
	
КонецФункции

&НаКлиенте
Процедура DomesticPlanningDocumentsAndAttachments(Команда)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningУстановитьФлажки(Команда)

	Для Каждого Строка Из Объект.DomesticPlanning Цикл
		Строка.Флажок = Истина;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningСнятьФлажки(Команда)
	
	Для Каждого Строка Из Объект.DomesticPlanning Цикл
		Строка.Флажок = Ложь;
	КонецЦикла;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьПараметрыВыбораEquipment(MOT)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("MOT", MOT);
	
	Запрос.Текст = "ВЫБРАТЬ
	|	EquipmentsMOTs.Ссылка КАК Equipment
	|ИЗ
	|	Справочник.Equipments.MOTs КАК EquipmentsMOTs
	|ГДЕ
	|	EquipmentsMOTs.MOT = &MOT
	|	И НЕ EquipmentsMOTs.Ссылка.ПометкаУдаления";
	
	МассивEquipments = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Equipment");
	
	НовыйМассивПараметров = Новый Массив;
	НовыйМассивПараметров.Добавить(Новый ПараметрВыбора("Отбор.Ссылка", МассивEquipments));
	
	Возврат Новый ФиксированныйМассив(НовыйМассивПараметров);
		
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьДанныеEquipmentПриИзменении(Equipment)
	
	СтруктураДанных = Новый Структура;
	
	СтруктураДанных.Вставить("Equipment",		Equipment);
	СтруктураДанных.Вставить("EffectiveWeight",	Equipment.EffectiveWeight);
	
	Возврат СтруктураДанных;
	
КонецФункции

&НаСервере
Процедура НастроитьСписокВыбораMOTНаСервере()
	      		
	НовыйМассивПараметров = Новый Массив;
	НовыйМассивПараметров.Добавить(Новый ПараметрВыбора("Отбор.Ссылка", 
		РГСофтСерверПовтИспСеанс.ПолучитьМассивLocalDistributionMOT()));
	НовыеПараметрыВыбора = Новый ФиксированныйМассив(НовыйМассивПараметров);
	Элементы.DomesticPlanningMOT.ПараметрыВыбора = НовыеПараметрыВыбора;
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////
// Fill Statistic

&НаСервереБезКонтекста
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

&НаСервере
Процедура DomesticPlanningFillStatisticНаСервере()
	
	Для Каждого Строка из Объект.DomesticPlanning Цикл 
		
		Если Не Строка.Флажок Тогда 
			Продолжить;
		КонецЕсли;
		
		Строка.Milage			= ргМодульКартографии.ВычислитьРасстояние(Строка.LocationFrom, Строка.LocationTo);
		Строка.TonneKilometers	= Строка.Milage * Строка.TotalGrossWeightKG / 1000;
		
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
		|				И &УсловиеEquipment
		|				И MOT = &MOT
		|				И SourceLocation = &SourceLocation
		|				И DestinationLocation = &DestinationLocation
		|				И &УсловиеParentCompany) КАК LocalDistributionCostsMilageWeightVolumeОбороты";
		
		Если ЗначениеЗаполнено(Строка.Company) Тогда
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "&УсловиеParentCompany", "ParentCompany = &ParentCompany");
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Строка.Equipment) Тогда
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "&УсловиеEquipment", "Equipment = &Equipment");
		КонецЕсли;
		
		Запрос.УстановитьПараметр("НачалоПериода",			ДобавитьМесяц(ТекущаяДата(), -24));
		Запрос.УстановитьПараметр("КонецПериода",			ТекущаяДата());
		Запрос.УстановитьПараметр("HazardClass",			Строка.HazardClass);
		Запрос.УстановитьПараметр("Equipment",				Строка.Equipment);
		Запрос.УстановитьПараметр("MOT",					Строка.MOT);
		Запрос.УстановитьПараметр("SourceLocation",			Строка.LocationFrom);
		Запрос.УстановитьПараметр("DestinationLocation",	Строка.LocationTo);
		Запрос.УстановитьПараметр("ParentCompany",			Строка.Company);
		Запрос.УстановитьПараметр("УсловиеEquipment",		Истина);
		Запрос.УстановитьПараметр("УсловиеParentCompany",	Истина);
		
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			Строка.FreightCostPerKM		= Выборка.SumOfMilage / Выборка.MilageOfParcel;
			Строка.TotalFreightCostKM	= Строка.NumOfTransport * Строка.Milage * Строка.FreightCostPerKM;
			Строка.FreightCostPerKG		= Выборка.SumOfMilage / Выборка.Weight;
			Строка.TotalFreightCostKG	= Строка.TotalGrossWeightKG * Строка.FreightCostPerKG;
			Строка.FreightCostPerTKM	= Выборка.Sum / Выборка.TonneKilometers;
			Строка.TotalFreightCostTKM	= Строка.TonneKilometers * Строка.FreightCostPerTKM;
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
		|			И (TripNonLawsonCompaniesStopsTo.Type В (ЗНАЧЕНИЕ(Перечисление.StopsTypes.Destination), ЗНАЧЕНИЕ(Перечисление.StopsTypes.Transit)))";
		
		Запрос.УстановитьПараметр("НачалоПериода",		ДобавитьМесяц(ТекущаяДата(), -24));
		Запрос.УстановитьПараметр("КонецПериода",		ТекущаяДата());
		Запрос.УстановитьПараметр("MOT",				Строка.MOT);
		Запрос.УстановитьПараметр("PickUpWarehouse",	Строка.LocationFrom);
		Запрос.УстановитьПараметр("DeliverTo",			Строка.LocationTo);
		
		Таблица = Запрос.Выполнить().Выгрузить();
		
		Строка.TotalActualDuration		= Рассчитать90Percent("Duration", Таблица);
		Строка.ПредставлениеDuration	= ПолучитьПредставлениеDuration(Строка.TotalActualDuration);
		
	КонецЦикла;
	 	
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningFillStatistic(Команда)

	DomesticPlanningFillStatisticНаСервере();
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////
// Save plan

&НаСервере
Процедура SaveDomesticPlanНаСервере()
	
	Для Каждого Строка из Объект.DomesticPlanning Цикл 
		
		Если Не Строка.Флажок Тогда 
			Продолжить;
		КонецЕсли;
		
		PlanDomestic = РегистрыСведений.ProjectMobilizationPlanningDomestic.СоздатьМенеджерЗаписи();
		ЗаполнитьЗначенияСвойств(PlanDomestic, Строка);
		
		PlanDomestic.ProjectMobilization	= Объект.ProjectMobilization;
		PlanDomestic.ModifiedBy				= ПараметрыСеанса.ТекущийПользователь;
		PlanDomestic.ModificationDate		= ТекущаяДата();
		PlanDomestic.User					= ПараметрыСеанса.ТекущийПользователь;
		PlanDomestic.Variant				= Объект.DomesticPlanningVariant;
		
		Попытка
			PlanDomestic.Записать();
		Исключение
			Сообщить(ОписаниеОшибки());
		КонецПопытки;
				
	КонецЦикла;
	
	Объект.DomesticPlanningVariantOwner = ПараметрыСеанса.ТекущийПользователь;
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningSavePlan(Команда)
	
	Отказ = Ложь;
	
	// Проверим заполнение фильтра по стране
	Если НЕ ЗначениеЗаполнено(Объект.DomesticPlanningVariant) Тогда
		Сообщить("Select Variant, please!");
		Отказ = Истина;
	КонецЕсли;
	
	Если Не Отказ Тогда
		SaveDomesticPlanНаСервере();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура OpenDomesticItem(Команда)
	
	ТекДанные = Элементы.DomesticPlanning.ТекущиеДанные;
	Если ТекДанные <> Неопределено И ЗначениеЗаполнено(ТекДанные.Item) Тогда 
		ПоказатьЗначение(,ТекДанные.Item);
	КонецЕсли;
	
КонецПроцедуры

// ТАБЛИЦА DOMESTIC PLANNING

&НаКлиенте
Процедура DomesticPlanningПриАктивизацииЯчейки(Элемент)
	
	ТекСтрока = Элементы.DomesticPlanning.ТекущиеДанные;
	
	Если ТекСтрока <> Неопределено И ЗначениеЗаполнено(ТекСтрока.MOT) И Элемент.ТекущийЭлемент = Элементы.DomesticPlanningEquipment Тогда
		Элементы.DomesticPlanningEquipment.ПараметрыВыбора = ПолучитьПараметрыВыбораEquipment(ТекСтрока.MOT);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningQtyПриИзменении(Элемент)
	
	ТекСтрока = Элементы.DomesticPlanning.ТекущиеДанные;
	
	ТекСтрока.TotalGrossWeightKG	= ТекСтрока.Qty * ТекСтрока.GrossWeightKG;
	ТекСтрока.TotalFreightCostKG	= ТекСтрока.TotalGrossWeightKG * ТекСтрока.FreightCostPerKG;
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningGrossWeightKGПриИзменении(Элемент)
	
	ТекСтрока = Элементы.DomesticPlanning.ТекущиеДанные;
	
	ТекСтрока.TotalGrossWeightKG	= ТекСтрока.Qty * ТекСтрока.GrossWeightKG;
	ТекСтрока.TotalFreightCostKG	= ТекСтрока.TotalGrossWeightKG * ТекСтрока.FreightCostPerKG;
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningFreightCostPerKGПриИзменении(Элемент)
	
	ТекСтрока = Элементы.DomesticPlanning.ТекущиеДанные;
	
	ТекСтрока.TotalFreightCostKG	= ТекСтрока.TotalGrossWeightKG * ТекСтрока.FreightCostPerKG;
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningMilageПриИзменении(Элемент)
	
	ТекСтрока = Элементы.DomesticPlanning.ТекущиеДанные;
	
	ТекСтрока.TotalFreightCostKM	= ТекСтрока.NumOfTransport * ТекСтрока.Milage * ТекСтрока.FreightCostPerKM;
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningFreightCostPerKMПриИзменении(Элемент)
	
	ТекСтрока = Элементы.DomesticPlanning.ТекущиеДанные;
	
	ТекСтрока.TotalFreightCostKM	= ТекСтрока.NumOfTransport * ТекСтрока.Milage * ТекСтрока.FreightCostPerKM;
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningEquipmentНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ТекСтрока = Элементы.DomesticPlanning.ТекущиеДанные;
	
	Если Не ЗначениеЗаполнено(ТекСтрока.MOT) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ТекстОшибки = "Сначала выберите 'MOT / Способ перевозки'!";
		Иначе 	
			ТекстОшибки = "Select 'MOT' first!";
		КонецЕсли;
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,
			, "DomesticPlanning[" + (ТекСтрока.НомерСтроки-1) + "].MOT", "Объект");
		СтандартнаяОбработка = Ложь;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningEquipmentПриИзменении(Элемент)
	
	ТекСтрока = Элементы.DomesticPlanning.ТекущиеДанные;
	
	СтруктураДанных = ПолучитьДанныеEquipmentПриИзменении(ТекСтрока.Equipment);
	
	Если ЗначениеЗаполнено(СтруктураДанных.EffectiveWeight) Тогда
		ТекСтрока.NumOfTransport		= Цел(ТекСтрока.TotalGrossWeightKG / СтруктураДанных.EffectiveWeight) + 1;
		ТекСтрока.TotalFreightCostKM	= ТекСтрока.NumOfTransport * ТекСтрока.Milage * ТекСтрока.FreightCostPerKM;
	КонецЕсли;	
		
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningNumOfTransportПриИзменении(Элемент)
	
	ТекСтрока = Элементы.DomesticPlanning.ТекущиеДанные;
	
	ТекСтрока.TotalFreightCostKM	= ТекСтрока.NumOfTransport * ТекСтрока.Milage * ТекСтрока.FreightCostPerKM;
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningПредставлениеDurationНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ТекСтрока = Элементы.DomesticPlanning.ТекущиеДанные;
	
	СтруктураПараметров = Новый Структура("TotalActualDuration", ТекСтрока.TotalActualDuration);
	
	ОткрытьФорму("Обработка.ProjectMobilizationPlanning.Форма.ФормаВыбораDuration", СтруктураПараметров, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticPlanningПредставлениеDurationОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ТекСтрока = Элементы.DomesticPlanning.ТекущиеДанные;
	
	ТекСтрока.TotalActualDuration	= ВыбранноеЗначение;
	ТекСтрока.ПредставлениеDuration	= ПолучитьПредставлениеDuration(ВыбранноеЗначение);
	
КонецПроцедуры
