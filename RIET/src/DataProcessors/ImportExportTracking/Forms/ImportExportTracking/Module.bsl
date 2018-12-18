Перем ТабДок, Секция;
///////////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	//ТочноеВремяНачала = ОценкаПроизводительностиРГСофт.ТочноеВремя();
	
	//ИнициализироватьTMCDashboards();
	
	ИнициализироватьImportTracking();
	
	ИнициализироватьExportTracking();
	
	ИнициализироватьDomesticTracking();

	// Скроем динамические списки, чтобы они не считывали данные до того, как пользователь не переключится на них
	//Элементы.MyExportRequests.Видимость = Ложь;
	
	Элементы.Subscriptions.Видимость = Ложь;
	
	EMailForSupport = "riet-support@slb.com";	
	
	//ОценкаПроизводительностиРГСофт.ЗафиксироватьВремяОкончания(ТочноеВремяНачала, Справочники.КлючевыеОперации.ImportExportTrackingОткрытие);
	// ++ RG-Soft КДС 30.11.2016
	ЗаполнитьДопФильтры();
	ЗаполнитьДопФильтрыDomestic();
	// -- RG-Soft КДС 30.11.2016
	// { RGS AArsentev 19.08.2017
	ЗаполнитьФильрыApproval();
	// } RGS AArsentev 19.08.2017
	
	РасширенияПоддерживающиеПредпросмотр = ФайловыеФункцииСлужебный.СписокРасширенийДляПредпросмотра();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДопФильтры()
	
	СП = Элементы.ВидСравненияStatus.СписокВыбора;
	СП.Добавить("Equal", "Equal");
	СП.Добавить("Not equal", "Not equal");
	СП.Добавить("In list", "In list");
	СП.Добавить("Not in list", "Not in list");
	
	ВидСравненияStatus = СП[0].Значение;
	
	// заполняем список выбора для значения
	СП = Элементы.ЗначениеФильтраStatusСтрока.СписокВыбора;
	СП.Добавить("Pending supplier confirmation", "Pending supplier confirmation");
	СП.Добавить("Availability date confirmed by supplier", "Availability date confirmed by supplier");
	СП.Добавить("Collected from port", "Collected from port");
	СП.Добавить("Local delivery", "Local delivery");
	СП.Добавить("Delivered to final destination", "Delivered to final destination");
	
	Для каждого ТекЗначение из Метаданные.Перечисления.DOCStatuses.ЗначенияПеречисления Цикл
		
		СП.Добавить(ТекЗначение.Синоним, ТекЗначение.Синоним);
		
	КонецЦикла;
	
	СП = Новый СписокЗначений;
	
	//СП = Элементы.ЗначениеФильтраStatusСтрока.СписокВыбора;
	
	СП.Добавить("Pending supplier confirmation", "Pending supplier confirmation");
	СП.Добавить("Availability date confirmed by supplier", "Availability date confirmed by supplier");
	СП.Добавить("Collected from port", "Collected from port");
	СП.Добавить("Local delivery", "Local delivery");
	СП.Добавить("Delivered to final destination", "Delivered to final destination");
	
	Для каждого ТекЗначение из Метаданные.Перечисления.DOCStatuses.ЗначенияПеречисления Цикл
		
		СП.Добавить(ТекЗначение.Синоним, ТекЗначение.Синоним);
		
	КонецЦикла;
	
	ЗначениеФильтраStatusСписок.ДоступныеЗначения = СП;
	
	УстановитьВидимостьДоступностьФильтров(ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДопФильтрыDomestic()
	
	СП = Элементы.ВидСравненияStatusDomestic.СписокВыбора;
	СП.Добавить("Equal", "Equal");
	СП.Добавить("Not equal", "Not equal");
	СП.Добавить("In list", "In list");
	СП.Добавить("Not in list", "Not in list");
	
	ВидСравненияStatusDomestic = СП[0].Значение;
	
	// { RGS AArsentev S-I-0003227 27.06.2017
	СП_NavigationType = Элементы.ВидСравненияNavigationTypeDomestic.СписокВыбора;
	СП_NavigationType.Добавить("Equal", "Equal");
	СП_NavigationType.Добавить("Not equal", "Not equal");
	
	ВидСравненияNavigationTypeDomestic = СП_NavigationType[0].Значение;
	// } RGS AArsentev S-I-0003227 27.06.2017
	              		
	УстановитьВидимостьДоступностьФильтровDomestic(ЭтаФорма);
	
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
	ImportTrackingFilterByPO = ImportTrackingMainFilters.PONo;
	// { RGS AARsentev 04.03.2018 S-I-0004271
	ImportTrackingFilterByCostCenter = ImportTrackingMainFilters.CostCenter;
	// } RGS AARsentev 04.03.2018 S-I-0004271
	НастроитьImportTrackingFiltersНаСервере();
	
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
	// { RGS AARsentev 04.03.2018 S-I-0004271
	ExportTrackingFilterByCostCenter = ExportTrackingMainFilters.CostCenter;
	// } RGS AARsentev 04.03.2018 S-I-0004271
	// { RGS AFokin 07.08.2018 23:59:59 S-I-0005770
	ExportTrackingFilterByProjectMobilization = ExportTrackingMainFilters.ProjectMobilization;
	// } RGS AFokin 07.08.2018 23:59:59 S-I-0005770
	
	НастроитьExportTrackingFiltersНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьDomesticTracking()
	
	// Вспомогательные переменные, чтобы на клиенте не уходить на сервер
	DomesticPlanningMainFilters = Перечисления.DomesticPlanningMainFilters;
	DomesticTrackingFilterByTransportRequestNo = DomesticPlanningMainFilters.TransportRequestNo;
	DomesticTrackingFilterByTripNo = DomesticPlanningMainFilters.TripNo;
	DomesticTrackingFilterByProjectMobilization = DomesticPlanningMainFilters.ProjectMobilization;
	DomesticTrackingFilterByPartNo = DomesticPlanningMainFilters.PartNo;
	DomesticTrackingFilterBySegmentCode = DomesticPlanningMainFilters.SegmentCode;
	DomesticTrackingFilterByRequestorAlias = DomesticPlanningMainFilters.RequestorAlias;
	// { RGS AARsentev 04.03.2018 S-I-0004271
	DomesticTrackingFilterByCostCenter = DomesticPlanningMainFilters.CostCenter;
	// } RGS AARsentev 04.03.2018 S-I-0004271
	
	НастроитьDomesticTrackingFiltersНаСервере();
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	
	// Сразу вытащим нужное значение из настроек, чтобы настроить видимость элементов управления
	Объект.ImportTrackingMainFilter = Настройки["Объект.ImportTrackingMainFilter"];
	НастроитьImportTrackingFiltersНаСервере();
	
	Объект.ExportTrackingMainFilter = Настройки["Объект.ExportTrackingMainFilter"];
	НастроитьExportTrackingFiltersНаСервере();
	
	Объект.DomesticTrackingMainFilter = Настройки["Объект.DomesticTrackingMainFilter"];
	НастроитьDomesticTrackingFiltersНаСервере();
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////////

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	////ПодключитьОбработчикОжидания("Отсчет", 60);
	
	// покажем колонки
	СвернутьРазвернутьDOC(Неопределено);
	СвернутьРазвернутьPO(Неопределено);
	СвернутьРазвернутьShipment(Неопределено);
	СвернутьРазвернутьTrip(Неопределено);
	СвернутьРазвернутьТМО(Неопределено);
	СвернутьРазвернутьDPMPlanning(Неопределено);
	СвернутьРазвернутьDPMPlanningDomestic(Неопределено);
	
	Если Объект.ImportTrackingMainFilter = ImportTrackingFilterByBORG ИЛИ
			Объект.ImportTrackingMainFilter = ImportTrackingFilterByCostCenter ИЛИ
			Объект.ImportTrackingMainFilter = ImportTrackingFilterByPO Тогда
		Элементы.ImportTrackingMainFilterList.Видимость = Истина;
		Элементы.ImportTrackingMainFilterValue.Видимость = Ложь;
	Иначе
		Элементы.ImportTrackingMainFilterList.Видимость = Ложь;
		Элементы.ImportTrackingMainFilterValue.Видимость = Истина;
	КонецЕсли;
	
	Если Объект.ExportTrackingMainFilter = ExportTrackingFilterByBORG ИЛИ
			Объект.ExportTrackingMainFilter = ExportTrackingFilterByCostCenter Тогда
		Элементы.ExportTrackingMainFilterList.Видимость = Истина;
		Элементы.ExportTrackingMainFilterValue.Видимость = Ложь;
	Иначе
		Элементы.ExportTrackingMainFilterList.Видимость = Ложь;
		Элементы.ExportTrackingMainFilterValue.Видимость = Истина;
	КонецЕсли;
	
	// { RGS AFokin 07.08.2018 23:59:59 S-I-0005770
	Если Объект.ExportTrackingMainFilter = ExportTrackingFilterByProjectMobilization Тогда
		Элементы.ExportTrackingMainFilterValue.Заголовок = "equals to";
		Элементы.ExportTrackingMainFilterValue.КнопкаВыбора = Истина;
		//ВидимостьФильтраПоДате = Ложь;
		//Элементы.ExportTrackingMainFilterValue = ProjectMobilizationПустаяСсылка;
	КонецЕсли;		
	// } RGS AFokin 07.08.2018 23:59:59 S-I-0005770
	
	Если Объект.DomesticTrackingMainFilter = DomesticTrackingFilterByCostCenter Тогда
		Элементы.DomesticTrackingMainFilterList.Видимость = Истина;
		Элементы.DomesticTrackingMainFilterValue.Видимость = Ложь;
	Иначе
		Элементы.DomesticTrackingMainFilterList.Видимость = Ложь;
		Элементы.DomesticTrackingMainFilterValue.Видимость = Истина;
	КонецЕсли;
	
	НастроитьImportTrackingFiltersНаКлиенте();
	
КонецПроцедуры

&НаКлиенте
Процедура Отсчет()
	
	MinutesRemaining = MinutesRemaining - 1;
	Если MinutesRemaining = 0 Тогда
		СформироватьTMCDashboardsНаСервере();
	КонецЕсли;
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////////
// СТРАНИЦЫ

&НаКлиенте
Процедура ГруппаСтраницыПриСменеСтраницы(Элемент, ТекущаяСтраница)
	
	Если ТекущаяСтраница = Элементы.СтраницаMyExportRequests Тогда
		
		Если НЕ Элементы.MyExportRequests.Видимость Тогда
			НастроитьСтраницуMyExportRequests();
		КонецЕсли;
		
	ИначеЕсли ТекущаяСтраница = Элементы.СтраницаEmailSubscriptions Тогда
		
		Если НЕ Элементы.Subscriptions.Видимость Тогда
			НастроитьСтраницуEmailSubscriptions();
		КонецЕсли;
		
	ИначеЕсли ТекущаяСтраница = Элементы.СтраницаManualItems Тогда

		НастроитьСтраницуManualItems();
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура НастроитьСтраницуManualItems()
	                	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		ManualItems,
		"Владелец",
		,
		ВидСравненияКомпоновкиДанных.Равно,
		,
		Ложь,
		РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
		      		
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		ManualItems,
		"DomesticInternational",
		,
		ВидСравненияКомпоновкиДанных.равно,
		,
		Ложь,
		РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
		
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		ManualItems,
		"ПометкаУдаления",
		Ложь,
		ВидСравненияКомпоновкиДанных.Равно,
		,
		Истина,
		РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Обычный);

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
	
	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(
	PMSubscriptions.Отбор,
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
	
	Если НЕ ЗначениеЗаполнено(Объект.ImportTrackingMainFilter) Тогда
		Объект.ImportTrackingMainFilter = Перечисления.ImportTrackingMainFilters.PONo;
	КонецЕсли;
	
	Если Объект.ImportTrackingMainFilter = ImportTrackingFilterByBORG Тогда
		
		ЗначениеПоУмолчанию = BORGsПустаяСсылка;
		ЗаголовокЗначения = "equals to";
		
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingFilterByProjectMobilization Тогда
		
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
	
	ВидимостьФильтраПоДате = НеобходимФильтрПоДатеДляImportTracking(Объект.ImportTrackingMainFilter);
	Элементы.ImportTrackingDateFilter.Видимость = ВидимостьФильтраПоДате;
	Элементы.ImportTrackingDateFrom.Видимость = ВидимостьФильтраПоДате;
	Элементы.ImportTrackingDateTo.Видимость = ВидимостьФильтраПоДате;
	
	Элементы.ImportTrackingUsingBORGFilter.Видимость = Объект.ImportTrackingMainFilter = ImportTrackingFilterByBORG;
	
	Элементы.ValueInList.Видимость = (Объект.ImportTrackingMainFilter = ImportTrackingFilterByPO);
	
	
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
	
	Если Объект.ImportTrackingMainFilter = ImportTrackingFilterByBORG Тогда
		
		ЗначениеПоУмолчанию = BORGsПустаяСсылка;
		ЗаголовокЗначения = "equals to";
		ВидимостьФильтраПоДате = Истина;
		
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingFilterByProjectMobilization Тогда
		
		ЗначениеПоУмолчанию = ProjectMobilizationПустаяСсылка;
		ЗаголовокЗначения = "equals to";
		ВидимостьФильтраПоДате = Ложь;
		
	Иначе
		
		ЗначениеПоУмолчанию = "";
		ЗаголовокЗначения = "contains";
		ВидимостьФильтраПоДате =
		Объект.ImportTrackingMainFilter = ImportTrackingFilterByPartNo
		ИЛИ Объект.ImportTrackingMainFilter = ImportTrackingFilterBySegmentCode;
		
	КонецЕсли;
	
	Если ТипЗнч(Объект.ImportTrackingMainFilterValue) <> ТипЗнч(ЗначениеПоУмолчанию) Тогда
		
		Объект.ImportTrackingMainFilterValue = ЗначениеПоУмолчанию;
		Элементы.ImportTrackingMainFilterValue.Заголовок = ЗаголовокЗначения;	
		
	КонецЕсли;
	
	Элементы.ImportTrackingDateFilter.Видимость = ВидимостьФильтраПоДате;
	Элементы.ImportTrackingDateFrom.Видимость = ВидимостьФильтраПоДате;
	Элементы.ImportTrackingDateTo.Видимость = ВидимостьФильтраПоДате;
	
	Элементы.ImportTrackingUsingBORGFilter.Видимость = Объект.ImportTrackingMainFilter = ImportTrackingFilterByBORG;
	
	Элементы.ValueInList.Видимость = (Объект.ImportTrackingMainFilter = ImportTrackingFilterByPO);
	
	Если Объект.ImportTrackingMainFilter = ImportTrackingFilterByBORG ИЛИ
		Объект.ImportTrackingMainFilter = ImportTrackingFilterByCostCenter ИЛИ
		(Объект.ImportTrackingMainFilter = ImportTrackingFilterByPO И ValueInList)
		Тогда
		Элементы.ImportTrackingMainFilterList.Видимость = Истина;
		Элементы.ImportTrackingMainFilterValue.Видимость = Ложь;
	Иначе
		Элементы.ImportTrackingMainFilterList.Видимость = Ложь;
		Элементы.ImportTrackingMainFilterValue.Видимость = Истина;
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
	
	// добавим проверку на ручную правку данных
	естьРучныеЭлементы = Ложь;
	Для каждого текСтр из Объект.ImportTracking Цикл
		
		естьРучныеЭлементы = естьРучныеЭлементы ИЛИ текСтр.isModified;
		Если естьРучныеЭлементы Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Если естьРучныеЭлементы Тогда
		
		ПоказатьВопрос(Новый ОписаниеОповещения("ОтветНаВопросОСохраненииДанных", ЭтаФорма), "There are unsaved data. Do you want to save them?", РежимДиалогаВопрос.ДаНетОтмена,, КодВозвратаДиалога.Нет, "Search"); 
		
	Иначе
		
		ImportTrackingSearch_Step2(Команда);		
		
	КонецЕсли;                             	
	
	
КонецПроцедуры

&НаКлиенте
Процедура ОтветНаВопросОСохраненииДанных(Ответ, ДопПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Нет Тогда
		ImportTrackingSearch_Step2(Неопределено);
	ИначеЕсли Ответ = КодВозвратаДиалога.Да Тогда
		ImportTrackingSavePlan(Неопределено);	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ImportTrackingSearch_Step2(Команда)
	
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
	//Если НЕ ЗначениеЗаполнено(Объект.Country) Тогда
	//	Сообщить("Fill in the field ""To country"", please!");
	//	Отказ = Истина;
	//КонецЕсли;
	
	// Проверим заполнение основного фильтра
	Если НЕ ЗначениеЗаполнено(Объект.ImportTrackingMainFilter) Тогда
		Сообщить("Fill in the field ""Search by"", please!");
		Отказ = Истина;
	КонецЕсли;
	
	Если Объект.ImportTrackingMainFilter = ImportTrackingFilterByBORG ИЛИ Объект.ImportTrackingMainFilter = ImportTrackingFilterByCostCenter ИЛИ (Объект.ImportTrackingMainFilter = ImportTrackingFilterByPO И ValueInList) Тогда
		Если ImportTrackingMainFilterList.Количество() = 0 Тогда
			Сообщить("Fill in the field ""in list"", please!");
			Отказ = Истина;
		КонецЕсли;
	Иначе
		ДлинаMainFilterValue = СтрДлина(Объект.ImportTrackingMainFilterValue);
		Если ДлинаMainFilterValue = 0 Тогда
			Сообщить("Fill in the field ""contains"", please!");
			Отказ = Истина;
		ИначеЕсли ДлинаMainFilterValue < 3 Тогда
			Сообщить("The length of the field ""contains"" should be at least 3 characters!");
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;
	
	// При необходимости проверим заполнение дополнительного фильтра
	Если ЗначениеЗаполнено(Объект.ImportTrackingMainFilter)
		И НеобходимФильтрПоДатеДляImportTracking(Объект.ImportTrackingMainFilter) Тогда
		
		Если НЕ ЗначениеЗаполнено(Объект.ImportTrackingDateFilter) Тогда
			Сообщить("Fill in the field ""and by"", please!");
			Отказ = Истина;
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Объект.ImportTrackingDateFrom) Тогда
			Сообщить("Fill in the field ""from"", please!");
			Отказ = Истина;
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Объект.ImportTrackingDateTo) Тогда
			Сообщить("Fill in the field ""to"", please!");
			Отказ = Истина;
		КонецЕсли;	
		
		Если ЗначениеЗаполнено(Объект.ImportTrackingDateFrom)
			И ЗначениеЗаполнено(Объект.ImportTrackingDateTo) Тогда
			
			Если Объект.ImportTrackingDateFrom > Объект.ImportTrackingDateTo Тогда
				Сообщить("Date ""from"" should be less than date ""to""!");
				Отказ = Истина;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьImportTrackingНаСервере()
	
	ДопФильтры = Неопределено;
	Если ФильтрStatusИспользовать Тогда
		
		 ДопФильтры = Новый Структура;
		
		СтруктураФильтраСтатус = Новый Структура;
		СтруктураФильтраСтатус.Вставить("ВидСравнения", ВидСравненияStatus);
		СтруктураФильтраСтатус.Вставить("ЗначениеСтрока", ЗначениеФильтраStatusСтрока);
		СтруктураФильтраСтатус.Вставить("ЗначениеСписок", ЗначениеФильтраStatusСписок);
		
		ДопФильтры.Вставить("Статус", СтруктураФильтраСтатус);
	КонецЕсли;
	
	ТаблицаДанных = Обработки.ImportExportTracking.ПолучитьТаблицуДанных(
		Объект.ImportTrackingMainFilter, 
		Объект.ImportTrackingMainFilterValue,
		Объект.ImportTrackingDateFilter,
		Объект.ImportTrackingDateFrom,
		Объект.ImportTrackingDateTo, 
		Объект.Country, 
		ImportTrackingVariant, 
		ImportTrackingVariantOwner, 
		ДопФильтры,
		// { RGS AArsentev 04.04.2018 S-I-0004271
		ImportTrackingMainFilterList.ВыгрузитьЗначения(),
		ValueInList
		// } RGS AArsentev 04.04.2018 S-I-0004271
		);
		
	// { RGS AArsentev 04.04.2018 S-I-0004271
	ТаблицаДляЗагрузки = ДозаполнитьТаблицуЗатрат(ТаблицаДанных, "Import");
	// } RGS AArsentev 04.04.2018 S-I-0004271
		
	Объект.ImportTracking.Загрузить(ТаблицаДляЗагрузки);
		
	// рассчитаем даты
	Обработки.ImportExportTracking.РассчитатьДаты(Объект.ImportTracking);
	
	// рассчитаем значения планового фрахта
	Обработки.ImportExportTracking.РассчитатьПлановыеПоказатели(Объект.ImportTracking);
		
	// если строка 1, то добавим еще одну и сделаем ее активной
	Если Объект.ImportTracking.Количество() = 1 Тогда
		стр = Объект.ImportTracking.Добавить();
		элементы.ImportTracking.ТекущаяСтрока = стр.ПолучитьИдентификатор(); 
	КонецЕсли;
	
КонецПроцедуры


// IMPORT VARIANTS

&НаКлиенте
Процедура ImportTrackingFillStatistic(Команда)
	
	// просто перезаполняем с учетом выбранного варианта
	ImportTrackingSearch(Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура ImportTrackingSavePlan(Команда)
	
	Если ПустаяСтрока(ImportTrackingVariant) Тогда
		ПоказатьПредупреждение(, "Please fill out a variant name");
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ImportTrackingVariantOwner) И ПользователиКлиентСервер.ТекущийПользователь() <> ImportTrackingVariantOwner Тогда
		
		// если используем вариант, который принадлежит другому пользователю, то не даем его перезаписать. 
		ПоказатьПредупреждение(, "The variant owner differs from the session user. Please choose another variant name to save plan.");
		Возврат;
		
	КонецЕсли;
	
	SavePlanНаСервере();	
	
КонецПроцедуры

&НаСервере
Процедура SavePlanНаСервере()
	
	текДата 		= ТекущаяДата();
	текПользователь = Пользователи.ТекущийПользователь();
	
	Для Каждого Стр из Объект.ImportTracking Цикл 
		
		Если Не Стр.isModified Тогда 
			Продолжить;
		КонецЕсли;
		
		PlanPerItem = РегистрыСведений.ProjectMobilizationPlanningPerItem.СоздатьМенеджерЗаписи();
		
		ЗаполнитьЗначенияСвойств(PlanPerItem, Стр);
		
		PlanPerItem.POA 				= Справочники.SeaAndAirPorts.НайтиПоКоду(Стр.RequestedPOACode);
		PlanPerItem.MOT 				= Справочники.MOTs.НайтиПоКоду(Стр.MOTCode);
		PlanPerItem.POD 				= Справочники.CountriesHUBs.НайтиПоКоду(Стр.PODCode);
				
		PlanPerItem.Период				= текДата;		
		
		PlanPerItem.User 				= текПользователь;
		
		PlanPerItem.Variant 			= ImportTrackingVariant;
		
		Попытка
			PlanPerItem.Записать(Истина);			
			
			// Снимаем признак изменения при успешной записи в регистр. 
			Если Стр.isModified Тогда 
				Стр.isModified = Ложь;
			КонецЕсли;
			
		Исключение
			Сообщить(ОписаниеОшибки());
		КонецПопытки;
		
	КонецЦикла;
		
	ImportTrackingVariantOwner = текПользователь;
	
КонецПроцедуры

&НаКлиенте
Процедура ImportTrackingVariantОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ТипЗнч(ВыбранноеЗначение) = Тип("Структура") Тогда
		
		СтандартнаяОбработка = Ложь;
		
		ImportTrackingVariant		= ВыбранноеЗначение.Variant;
		ImportTrackingVariantOwner	= ВыбранноеЗначение.VariantOwner;
		
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура ImportTrackingVariantНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("DomesticInternational", ПредопределенноеЗначение("Перечисление.DomesticInternational.International"));
	
	Если Объект.ImportTrackingMainFilter = ImportTrackingFilterByProjectMobilization И ЗначениеЗаполнено(Объект.ImportTrackingMainFilterValue) Тогда
		СтруктураПараметров.Вставить("ProjectMobilization",	Объект.ImportTrackingMainFilterValue);
	иначе
		СтруктураПараметров.Вставить("ProjectMobilization",	ПредопределенноеЗначение("Справочник.ProjectMobilization.ПустаяСсылка"));
	КонецЕсли;
	  
	ОткрытьФорму("Обработка.ImportExportTracking.Форма.ФормаВыбораVariant", СтруктураПараметров, Элемент);
	
КонецПроцедуры

// DOMESTIC VARIANTS

&НаКлиенте
Процедура DomesticTrackingSavePlan(Команда)
	
	Если ПустаяСтрока(DomesticTrackingVariant) Тогда
		ПоказатьПредупреждение(, "Please fill out a variant name");
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(DomesticTrackingVariantOwner) И ПользователиКлиентСервер.ТекущийПользователь() <> DomesticTrackingVariantOwner Тогда
		
		// если используем вариант, который принадлежит другому пользователю, то не даем его перезаписать. 
		ПоказатьПредупреждение(, "The variant owner differs from the session user. Please choose another variant name to save plan.");
		Возврат;
		
	КонецЕсли;
	
	SaveDomesticPlanНаСервере();	
	
КонецПроцедуры

&НаСервере
Процедура SaveDomesticPlanНаСервере()
	
	текДата 		= ТекущаяДата();
	текПользователь = Пользователи.ТекущийПользователь();
	
	Для Каждого Стр из Объект.DomesticTracking Цикл 
		
		Если Не Стр.isModified Тогда 
			Продолжить;
		КонецЕсли;
		
		PlanPerItem = РегистрыСведений.ProjectMobilizationPlanningDomestic.СоздатьМенеджерЗаписи();
		
		ЗаполнитьЗначенияСвойств(PlanPerItem, Стр);
		
		PlanPerItem.Период				= текДата;		
		
		PlanPerItem.User 				= текПользователь;
		
		PlanPerItem.Variant 			= DomesticTrackingVariant;
		
		Попытка
			PlanPerItem.Записать(Истина);			
			
			// Снимаем признак изменения при успешной записи в регистр. 
			Если Стр.isModified Тогда 
				Стр.isModified = Ложь;
			КонецЕсли;
			
		Исключение
			Сообщить(ОписаниеОшибки());
		КонецПопытки;
		
	КонецЦикла;
		
	DomesticTrackingVariantOwner = текПользователь;
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticTrackingVariantОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ТипЗнч(ВыбранноеЗначение) = Тип("Структура") Тогда
		
		СтандартнаяОбработка = Ложь;
		
		DomesticTrackingVariant			= ВыбранноеЗначение.Variant;
		DomesticTrackingVariantOwner	= ВыбранноеЗначение.VariantOwner;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticTrackingVariantНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("DomesticInternational",	ПредопределенноеЗначение("Перечисление.DomesticInternational.Domestic"));
	
	Если Объект.DomesticTrackingMainFilter = DomesticTrackingFilterByProjectMobilization И ЗначениеЗаполнено(Объект.DomesticTrackingMainFilterValue) Тогда
		СтруктураПараметров.Вставить("ProjectMobilization",	Объект.DomesticTrackingMainFilterValue);
	иначе
		СтруктураПараметров.Вставить("ProjectMobilization",	ПредопределенноеЗначение("Справочник.ProjectMobilization.ПустаяСсылка"));
	КонецЕсли;
	
	ОткрытьФорму("Обработка.ImportExportTracking.Форма.ФормаВыбораVariant", СтруктураПараметров, Элемент);
	
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
	ОткрытьФорму("Обработка.ImportExportTracking.Форма.DocumentsAndAttachments", ПараметрыФормы, ЭтаФорма, ТекДанные.Invoice);
	
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


////////////////// ОБРАБОТЧИКИ КОМАНД СВЕРТКИ\ОТКРЫТИЯ ГРУПП КОЛОНОК

&НаКлиенте
Процедура СвернутьРазвернутьDOC(Команда)
	
	РазвернутьСкрытьКолонку(Элементы.ImportTrackingDOC, Элементы.СвернутьРазвернутьDOC); 	
	
КонецПроцедуры

&НаКлиенте
Процедура СвернутьРазвернутьShipment(Команда)
	
	РазвернутьСкрытьКолонку(Элементы.ImportTrackingShipment, Элементы.СвернутьРазвернутьShipment); 	
	
КонецПроцедуры

&НаКлиенте
Процедура СвернутьРазвернутьТМО(Команда)
	
	РазвернутьСкрытьКолонку(Элементы.ImportTrackingTMO, Элементы.СвернутьРазвернутьТМО); 	
	
КонецПроцедуры

&НаКлиенте
Процедура СвернутьРазвернутьPO(Команда)
	
	РазвернутьСкрытьКолонку(Элементы.ImportTrackingPO, Элементы.СвернутьРазвернутьPO);
	
КонецПроцедуры

&НаКлиенте
Процедура СвернутьРазвернутьTrip(Команда)
	
	РазвернутьСкрытьКолонку(Элементы.ImportTrackingTrip, Элементы.СвернутьРазвернутьTrip); 
	
КонецПроцедуры

&НаКлиенте
Процедура СвернутьРазвернутьDPMPlanning(Команда)
	
	РазвернутьСкрытьКолонку(Элементы.ImportTrackingDPMPlanning, Элементы.СвернутьРазвернутьDPMPlanning); 
	
КонецПроцедуры

&НаКлиенте
Процедура СвернутьРазвернутьDPMPlanningDomestic(Команда)
	
	РазвернутьСкрытьКолонку(Элементы.DomesticPlanningDPMPlanning, Элементы.СвернутьРазвернутьDPMPlanningDomestic); 
	
КонецПроцедуры

&НаКлиенте
Процедура РазвернутьСкрытьКолонку(Группа, Кнопка)
	
	Кнопка.Пометка = НЕ Кнопка.Пометка;
	
	имяГруппы = СтрЗаменить(Кнопка.Имя, "СвернутьРазвернуть", "");
	
	Если имяГруппы = "DPMPlanning" или имяГруппы = "DPMPlanningDomestic" Тогда
		имяГруппы = "DPM planning";
	КонецЕсли;
	
	Если Кнопка.Пометка Тогда
		Кнопка.Картинка = БиблиотекаКартинок.PM_Minus;
		Кнопка.Заголовок = "Hide " + имяГруппы;
		Группа.Видимость = Истина;
	Иначе
		Кнопка.Картинка = БиблиотекаКартинок.PM_Plus;
		Кнопка.Заголовок = "Show " + имяГруппы;
		Группа.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

// ТАБЛИЦА IMPORT TRACKING

&НаКлиенте
Процедура ImportTrackingВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	// { RGS AArsentev 14.06.2018
	//OpenImportDocumentsAndAttachments();
	ТекДанные = Элементы.ImportTracking.ТекущиеДанные;
	Если ТекДанные <> Неопределено И ЗначениеЗаполнено(ТекДанные.Item) Тогда 
		ПоказатьЗначение(,ТекДанные.Item);
	КонецЕсли;
	// } RGS AArsentev 14.06.2018
	
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
		
	ИмяТаблицы = ЭтаФорма.ТекущийЭлемент.Имя;
	
	Если ЭтаФорма.ТекущийЭлемент.Имя = "ImportTracking" Тогда
		ИмяКолонкиПоиска = "Item";
		МассивВыделенныхGoods = ПолучитьМассивВыделенныхGoods(ИмяКолонкиПоиска, ИмяТаблицы);
	ИначеЕсли ЭтаФорма.ТекущийЭлемент.Имя = "DomesticTracking" Тогда 
		ИмяКолонкиПоиска = "TransportRequest";  
		МассивВыделенныхGoods = ПолучитьМассивВыделенныхGoods(ИмяКолонкиПоиска, ИмяТаблицы);
	иначе
		Возврат;
	КонецЕсли;

	Если МассивВыделенныхGoods.Количество() = 0 Тогда
		Предупреждение(
		"Please, select at least one item line!",
		30);
		Возврат;
	КонецЕсли;
	
	СтруктураДопПараметров = Новый Структура("ИмяТаблицы, МассивGoods, ИмяКолонкиПоиска");
	СтруктураДопПараметров.ИмяТаблицы = ИмяТаблицы;
	СтруктураДопПараметров.ИмяКолонкиПоиска = ИмяКолонкиПоиска;
	СтруктураДопПараметров.МассивGoods = МассивВыделенныхGoods;
	
	ОткрытьФорму("Справочник.ProjectMobilization.ФормаВыбора", , ЭтаФорма, , , , 
	Новый ОписаниеОповещения("ВыполнитьПослеВыбораProjectMobilization", ЭтотОбъект, СтруктураДопПараметров));	
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьМассивВыделенныхGoods(ИмяКолонкиПоиска, ИмяТаблицы)
	
	МассивGoods = Новый Массив;
	ВыделенныеСтроки = Элементы[ИмяТаблицы].ВыделенныеСтроки;
	Для Каждого ВыделеннаяСтрока Из ВыделенныеСтроки Цикл
		
		СтрокаТаблицы = Объект[ИмяТаблицы].НайтиПоИдентификатору(ВыделеннаяСтрока);
		Если ЗначениеЗаполнено(СтрокаТаблицы[ИмяКолонкиПоиска]) И МассивGoods.Найти(СтрокаТаблицы[ИмяКолонкиПоиска]) = Неопределено Тогда
			МассивGoods.Добавить(СтрокаТаблицы[ИмяКолонкиПоиска]);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат МассивGoods;
	
КонецФункции

&НаКлиенте
Процедура ВыполнитьПослеВыбораProjectMobilization(Результат, ДополнительныеПараметры)  Экспорт 
		
	Если Не ЗначениеЗаполнено(Результат) Тогда
		Возврат;
	КонецЕсли;
	 		
	Если ДополнительныеПараметры.ИмяКолонкиПоиска = "TransportRequest" Тогда
		МассивИзмененныхItems = ИзменитьProjectMobilizationВTRs(ДополнительныеПараметры.МассивGoods, Результат);	
	Иначе 
		МассивИзмененныхItems = РГСофт.ИзменитьРеквизитВСсылкахВПривилегированномРежиме(ДополнительныеПараметры.МассивGoods, 
			"ProjectMobilization", Результат);
	КонецЕсли;
		
	ОбновитьКолонкуВGoods(ДополнительныеПараметры.МассивGoods, ДополнительныеПараметры.ИмяТаблицы, 
		ДополнительныеПараметры.ИмяКолонкиПоиска, "ProjectMobilization", Результат);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьКолонкуВGoods(МассивGoods, ИмяТаблицы, ИмяКолонкиПоиска, ИмяКолонки, Значение)
	
	Для Каждого СтрокаТаблицы Из Объект[ИмяТаблицы] Цикл
		
		Если МассивGoods.Найти(СтрокаТаблицы[ИмяКолонкиПоиска]) <> Неопределено Тогда
			СтрокаТаблицы[ИмяКолонки] = Значение;
		КонецЕсли;
		 
	КонецЦикла;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ИзменитьProjectMobilizationВTRs(МассивСсылок, ProjectMobilization) Экспорт
	
	ProjectClient = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ProjectMobilization, "ProjectClient");  
	
	МассивИзмененныхСсылок = Новый Массив;
	
	Для Каждого Ссылка Из МассивСсылок Цикл
		
		НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
		
		Объект = Ссылка.ПолучитьОбъект();
		
		Если Объект.ProjectMobilization = ProjectMobilization Тогда
			ЗафиксироватьТранзакцию();
			МассивИзмененныхСсылок.Добавить(Ссылка);
			Продолжить;
		КонецЕсли;
		
		Объект.ProjectMobilization = ProjectMobilization;
		Объект.ProjectClient = ProjectClient;
		
		Попытка
			Объект.ОбменДанными.Загрузка = Истина;
			Объект.Записать();
		Исключение
			ОтменитьТранзакцию();
			Сообщить(
				"Failed to save " + СокрЛП(Объект) + "!
				|See errors above.
				|" + ОписаниеОшибки());
			Продолжить;
		КонецПопытки;
		
		ЗафиксироватьТранзакцию();
		МассивИзмененныхСсылок.Добавить(Ссылка);
		
	КонецЦикла;
	
	Возврат МассивИзмененныхСсылок;
	
КонецФункции

// Record RDD

&НаКлиенте
Процедура ImportRecordRDD(Команда)
	
	ИмяТаблицы = ЭтаФорма.ТекущийЭлемент.Имя;
	
	Если ЭтаФорма.ТекущийЭлемент.Имя = "ImportTracking" Тогда
		ИмяКолонкиПоиска = "Item";
		МассивВыделенныхGoods = ПолучитьМассивВыделенныхGoods(ИмяКолонкиПоиска, ИмяТаблицы);
	КонецЕсли;

	Если МассивВыделенныхGoods.Количество() = 0 Тогда
		Предупреждение(
		"Please, select at least one item line!",
		30);
		Возврат;
	КонецЕсли;
	
	СтруктураДопПараметров = Новый Структура("ИмяТаблицы, МассивGoods, ИмяКолонкиПоиска");
	СтруктураДопПараметров.ИмяТаблицы = ИмяТаблицы;
	СтруктураДопПараметров.ИмяКолонкиПоиска = ИмяКолонкиПоиска;
	СтруктураДопПараметров.МассивGoods = МассивВыделенныхGoods;
	
	ОткрытьФорму("ОбщаяФорма.ВыборДаты", , ЭтаФорма, , , , 
		Новый ОписаниеОповещения("ВыполнитьПослеВыбораRDD", ЭтотОбъект, СтруктураДопПараметров));
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПослеВыбораRDD(Результат, ДополнительныеПараметры)  Экспорт 
	
	Если Не ЗначениеЗаполнено(Результат) Тогда
		Возврат;
	КонецЕсли;
	
	МассивItems = Новый Массив;
	МассивPOLines = Новый Массив;
	
	Для Каждого Good из ДополнительныеПараметры.МассивGoods	Цикл 
		
		Если ТипЗнч(Good) = Тип("СправочникСсылка.СтрокиИнвойса") Тогда
			МассивItems.Добавить(Good);
		ИначеЕсли ТипЗнч(Good) = Тип("СправочникСсылка.СтрокиЗаявкиНаЗакупку") Тогда
			МассивPOLines.Добавить(Good);
		КонецЕсли;
		
	КонецЦикла;
	
	Если МассивItems.Количество() > 0 Тогда 
		МассивИзмененныхItems = ИзменитьRDDВParcels(МассивItems, Результат);
		ОбновитьКолонкуВGoods(МассивИзмененныхItems, ДополнительныеПараметры.ИмяТаблицы, 
			ДополнительныеПараметры.ИмяКолонкиПоиска, "RequiredDeliveryDate", Результат);
	КонецЕсли;
	
	Если МассивPOLines.Количество() > 0 Тогда 
		МассивИзмененныхItems = ИзменитьRDDВPOLiness(МассивPOLines, Результат);
		ОбновитьКолонкуВGoods(МассивИзмененныхItems, ДополнительныеПараметры.ИмяТаблицы, 
			ДополнительныеПараметры.ИмяКолонкиПоиска, "RequiredDeliveryDate", Результат);
	КонецЕсли;

КонецПроцедуры

&НаСервереБезКонтекста
Функция ИзменитьRDDВParcels(МассивСсылок, Результат, БылиОшибки = Ложь) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	МассивИзмененныхСсылок = Новый Массив;
	
	Для Каждого Ссылка Из МассивСсылок Цикл
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		
		Запрос.Текст = "ВЫБРАТЬ
		|	ParcelsДетали.Ссылка КАК Parcel,
		|	ParcelsДетали.Ссылка.RDD КАК RDD
		|ИЗ
		|	Справочник.Parcels.Детали КАК ParcelsДетали
		|ГДЕ
		|	ParcelsДетали.СтрокаИнвойса = &Ссылка
		|	И НЕ ParcelsДетали.Ссылка.Отменен";
		
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		
		НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
		
		Выборка = Запрос.Выполнить().Выбрать();
		Пока Выборка.Следующий() Цикл
			
			Если Выборка.RDD = Результат Тогда
				Продолжить;
			КонецЕсли;
			
			Объект = Выборка.Parcel.ПолучитьОбъект();
			Объект.RDD = Результат;
			Объект.ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
			Объект.ModificationDate = ТекущаяДата();
			
			Попытка
				Объект.ОбменДанными.Загрузка = Истина;
				Объект.Записать();
			Исключение
				ОтменитьТранзакцию();
				Сообщить(
				"Failed to save " + СокрЛП(Объект) + "!
				|See errors above.
				|" + ОписаниеОшибки());
				БылиОшибки = Истина;
				Продолжить;
			КонецПопытки;   
			
		КонецЦикла;
		     			
		ЗафиксироватьТранзакцию();
		МассивИзмененныхСсылок.Добавить(Ссылка);
		
	КонецЦикла;
	
	УстановитьПривилегированныйРежим(Ложь);

	Возврат МассивИзмененныхСсылок;
	
КонецФункции

&НаСервереБезКонтекста
Функция ИзменитьRDDВPOLiness(МассивСсылок, Результат, БылиОшибки = Ложь) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);

	МассивИзмененныхСсылок = Новый Массив;
	
	Для Каждого Ссылка Из МассивСсылок Цикл
		
		НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
		
		Объект = Ссылка.ПолучитьОбъект();
		
		Если Объект.CurrentRDD = Результат Тогда
			ЗафиксироватьТранзакцию();
			МассивИзмененныхСсылок.Добавить(Ссылка);
			Продолжить;
		КонецЕсли;
		
		Объект.CurrentRDD = Результат;
		Объект.ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
		Объект.ModificationDate = ТекущаяДата();
	
		Попытка
			Объект.ОбменДанными.Загрузка = Истина;
			Объект.Записать();
		Исключение
			ОтменитьТранзакцию();
			Сообщить(
				"Failed to save " + СокрЛП(Объект) + "!
				|See errors above.
				|" + ОписаниеОшибки());
				БылиОшибки = Истина;
			Продолжить;
		КонецПопытки;
		
		ЗафиксироватьТранзакцию();
		МассивИзмененныхСсылок.Добавить(Ссылка);
		
	КонецЦикла;
	
	УстановитьПривилегированныйРежим(Ложь);

	Возврат МассивИзмененныхСсылок;    
	
КонецФункции

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
	// { RGS AFokin 07.08.2018 23:59:59 S-I-0005770
	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingFilterByProjectMobilization Тогда
		ЗначениеПоУмолчанию = ProjectMobilizationПустаяСсылка;
		ЗаголовокЗначения = "equals to";
		ВидимостьФильтраПоДате = Ложь;
		Элементы.ExportTrackingMainFilterValue.КнопкаВыбора = Истина;
	// } RGS AFokin 07.08.2018 23:59:59 S-I-0005770
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
	
	Если Объект.ExportTrackingMainFilter = ExportTrackingFilterByBORG ИЛИ
		Объект.ExportTrackingMainFilter = ExportTrackingFilterByCostCenter Тогда
		Элементы.ExportTrackingMainFilterList.Видимость = Истина;
		Элементы.ExportTrackingMainFilterValue.Видимость = Ложь;
	Иначе
		Элементы.ExportTrackingMainFilterList.Видимость = Ложь;
		Элементы.ExportTrackingMainFilterValue.Видимость = Истина;
	КонецЕсли;
	
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
	
	// Проверим заполнение фильтра по стране
	//Если НЕ ЗначениеЗаполнено(Объект.Country) Тогда
	//	Сообщить("Fill in the field ""From country"", please!");
	//	Отказ = Истина;
	//КонецЕсли;
	
	// Проверим заполнение основного фильтра
	Если НЕ ЗначениеЗаполнено(Объект.ExportTrackingMainFilter) Тогда
		Сообщить("Fill in the field ""Search by"", please!");
		Отказ = Истина;
	КонецЕсли;
	
	Если Объект.ExportTrackingMainFilter = ExportTrackingFilterByBORG ИЛИ Объект.ExportTrackingMainFilter = ExportTrackingFilterByCostCenter Тогда
		Если ExportTrackingMainFilterList.Количество() = 0 Тогда
			Сообщить("Fill in the field ""in list"", please!");
			Отказ = Истина;
		КонецЕсли;
	Иначе
		ДлинаMainFilterValue = СтрДлина(Объект.ExportTrackingMainFilterValue);
		Если ДлинаMainFilterValue = 0 Тогда
			Сообщить("Fill in the field ""contains"", please!");
			Отказ = Истина;
		ИначеЕсли ДлинаMainFilterValue < 3 Тогда
			Сообщить("The length of the field ""contains"" should be at least 3 characters!");
			Отказ = Истина;	
		КонецЕсли;
	КонецЕсли;
	
	// При необходимости проверим заполнение дополнительного фильтра
	Если ЗначениеЗаполнено(Объект.ExportTrackingMainFilter)
		И НеобходимФильтрПоДатеДляExportTracking(Объект.ExportTrackingMainFilter) Тогда
		
		Если НЕ ЗначениеЗаполнено(Объект.ExportTrackingDateFilter) Тогда
			Сообщить("Fill in the field ""and by"", please!");
			Отказ = Истина;
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Объект.ExportTrackingDateFrom) Тогда
			Сообщить("Fill in the field ""from"", please!");
			Отказ = Истина;
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Объект.ExportTrackingDateTo) Тогда
			Сообщить("Fill in the field ""to"", please!");
			Отказ = Истина;
		КонецЕсли;	
		
		Если ЗначениеЗаполнено(Объект.ExportTrackingDateFrom)
			И ЗначениеЗаполнено(Объект.ExportTrackingDateTo) Тогда
			
			Если Объект.ExportTrackingDateFrom > Объект.ExportTrackingDateTo Тогда
				Сообщить("Date ""from"" should be less than date ""to""!");
				Отказ = Истина;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьExportTrackingНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	StagesOfExportRequests.ExportRequest КАК ExportRequest,
	|	StagesOfExportRequests.ExportRequest.Номер КАК ExportRequestNo,
	|	StagesOfExportRequests.ExportRequest.Дата КАК ExportRequestDate,
	|	StagesOfExportRequests.Stage КАК Stage,
	|	Items.КодПоИнвойсу КАК PartNo,
	|	Items.СерийныйНомер КАК SerialNo,
	|	Items.RAN КАК RAN,
	|	Items.НаименованиеТовара КАК PartDescription,
	|	StagesOfExportRequests.ExportRequest.Segment.Код КАК SegmentCode,
	|	StagesOfExportRequests.ExportRequest.POA.Наименование КАК FinalDestinationName,
	|	StagesOfExportRequests.ExportRequest.RequiredDeliveryDate КАК RequiredDeliveryDate,
	|	StagesOfExportRequests.ExportRequest.Submitted КАК ExportRequestSubmitted,
	|	StagesOfExportRequests.ExportRequest.Submitter.Код КАК ExportRequestSubmitterAlias,
	|	StagesOfExportRequests.ExportRequest.AcceptedBySpecialist КАК ExportRequestAcceptedBySpecialist,
	|	StagesOfExportRequests.ExportRequest.shippercontact.Код КАК ExportSpecialistAlias,
	|	StagesOfExportRequests.ExportRequest.Comments КАК ExportRequestComments,
	|	StagesOfExportRequests.ExportRequest.Urgency КАК Urgency,
	|	StagesOfExportRequests.ExportRequest.Company.Код КАК CompanyCode,
	|	StagesOfExportRequests.ExportRequest.Shipper.Код КАК ShipperCode,
	|	StagesOfExportRequests.ExportRequest.BORG.Код КАК BORGCode,
	|	StagesOfExportRequests.ExportRequest.AU.Код КАК AUCode,
	|	StagesOfExportRequests.ExportRequest.LocalFreightProvider.Код КАК LocalFreightProviderCode,
	|	StagesOfExportRequests.ExportRequest.LocalFreightSubmittedForApproval КАК LocalFreightSubmittedForApproval,
	//|	StagesOfExportRequests.ExportRequest.LocalFreightApproved КАК LocalFreightApproved,
	|	StagesOfExportRequests.ExportRequest.LocalMOT.Код КАК LocalMOTCode,
	|	StagesOfExportRequests.ExportRequest.LocalWB КАК LocalWB,
	|	StagesOfExportRequests.ExportRequest.ReadyToShipDate КАК ReadyToShipDate,
	|	StagesOfExportRequests.ExportRequest.ActualAvailabilityDate КАК ActualAvailabilityDate,
//	|	StagesOfExportRequests.ExportRequest.LocalETD КАК LocalETD,
	|	StagesOfExportRequests.ExportRequest.LocalATD КАК LocalATD,
//	|	StagesOfExportRequests.ExportRequest.LocalETA КАК LocalETA,
	|	StagesOfExportRequests.ExportRequest.LocalATA КАК LocalATA,
	|	StagesOfExportRequests.ExportRequest.CCA.Код КАК CCACode,
	|	StagesOfExportRequests.ExportRequest.CCAGLReceived КАК CCAGLReceived,
	|	StagesOfExportRequests.ExportRequest.ConsigneeGLReceived КАК ConsigneeGLReceived,
	|	StagesOfExportRequests.ExportRequest.PermitsRequired КАК PermitsRequired,
	|	StagesOfExportRequests.ExportRequest.PermitsObtained КАК PermitsObtained,
	|	StagesOfExportRequests.ExportRequest.FumigationRequired КАК FumigationRequired,
	//|	StagesOfExportRequests.ExportRequest.FumigationCertificateRequired КАК FumigationCertificateRequired,
	//|	StagesOfExportRequests.ExportRequest.FumigationDone КАК FumigationDone,
	|	ExportShipmentsExportRequests.Ссылка.SubmittedToCustoms КАК SubmittedToCustoms,
	|	ExportShipmentsExportRequests.Ссылка.ReleasedFromCustoms КАК ReleasedFromCustoms,
	|	CustomsFilesOfGoods.CustomsFile КАК CutomsFile,
	|	CustomsFilesOfGoods.CustomsFile.Номер КАК CustomsFileNo,
	|	StagesOfExportRequests.ExportRequest.InternationalFreightProvider.Код КАК InternationalFreightProviderCode,
	|	StagesOfExportRequests.ExportRequest.InternationalFreightSubmittedForApproval КАК InternationalFreightSubmittedForApproval,
	|	StagesOfExportRequests.ExportRequest.InternationalFreightApproved КАК InternationalFreightApproved,
	|	StagesOfExportRequests.ExportRequest.InternationalMOT.Код КАК InternationalMOTCode,
	|	StagesOfExportRequests.ExportRequest.POD.Код КАК PODCode,
	|	StagesOfExportRequests.ExportRequest.TransitionalCountry.Код КАК TransitionalCountryКод,
	|	ExportShipmentsExportRequests.Ссылка.Ссылка КАК ExportShipment,
	|	ExportShipmentsExportRequests.Ссылка.InternationalWBList КАК InternationalWB,
	|	ExportShipmentsExportRequests.Ссылка.InternationalETD КАК InternationalETD,
	|	ExportShipmentsExportRequests.Ссылка.InternationalATD КАК InternationalATD,
	|	ExportShipmentsExportRequests.Ссылка.InternationalETA КАК InternationalETA,
	|	ExportShipmentsExportRequests.Ссылка.InternationalATA КАК InternationalATA,
	|	CustomsFilesOfGoods.CustomsFile.Regime.Код КАК CustomsRegimeCode,
	|	Items.Ссылка КАК Item
	|ИЗ
	|	РегистрСведений.StagesOfExportRequests КАК StagesOfExportRequests
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК Items
	|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.ExportShipment.ExportRequests КАК ExportShipmentsExportRequests
	|			ПО Items.ExportRequest = ExportShipmentsExportRequests.ExportRequest
	|				И (НЕ ExportShipmentsExportRequests.Ссылка.ПометкаУдаления)
	|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.CustomsFilesOfGoods КАК CustomsFilesOfGoods
	|			ПО Items.Ссылка = CustomsFilesOfGoods.Item
	|		ПО StagesOfExportRequests.ExportRequest = Items.ExportRequest
	|			И (НЕ Items.ПометкаУдаления)
	|ГДЕ";
	
	// Установим фильтр по стране
	//|	И Items.ExportRequest.FromCountry = &Country";
	//Запрос.УстановитьПараметр("Country", Объект.Country);
	
	// Установим основной фильтр
	ExportTrackingMainFilters = Перечисления.ExportTrackingMainFilters;
	Если Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.BORG Тогда
		
		// { RGS AARsentev 04.04.2018 S-I-0004271
		//Запрос.УстановитьПараметр("BORG", Объект.ExportTrackingMainFilterValue);
		//Запрос.Текст = Запрос.Текст + "
		//|	StagesOfExportRequests.ExportRequest.BORG = &BORG";
		Запрос.УстановитьПараметр("BORGs", ExportTrackingMainFilterList.ВыгрузитьЗначения());
		Запрос.Текст = Запрос.Текст + "
		|	StagesOfExportRequests.ExportRequest.BORG В (&BORGs)";
		// } RGS AARsentev 04.04.2018 S-I-0004271
		
 	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.CustomsFileNo Тогда
		
		Запрос.Текст = Запрос.Текст + "
		|	CustomsFilesOfGoods.CustomsFile.Номер ПОДОБНО ""%"" + """ + Объект.ExportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.ExportRequestNo Тогда
		
		Запрос.Текст = Запрос.Текст + "
		|	StagesOfExportRequests.ExportRequest.Номер ПОДОБНО ""%"" + """ + Объект.ExportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.FinalDestination Тогда
		
		Запрос.УстановитьПараметр("POA", Объект.ExportTrackingMainFilterValue);
		Запрос.Текст = Запрос.Текст + "
		|	StagesOfExportRequests.ExportRequest.POA = &POA";
		
 	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.InternationalWaybill Тогда
		
		Запрос.Текст = Запрос.Текст + "
		|	ExportShipmentsExportRequests.Ссылка.InternationalWBList ПОДОБНО ""%"" + """ + Объект.ExportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.PartDescription Тогда
		
		Запрос.Текст = Запрос.Текст + "
		|	Items.НаименованиеТовара ПОДОБНО ""%"" + """ + Объект.ExportTrackingMainFilterValue + """ + ""%""";	
		
	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.PartNo Тогда
		
		Запрос.Текст = Запрос.Текст + "
		|	Items.КодПоИнвойсу ПОДОБНО ""%"" + """ + Объект.ExportTrackingMainFilterValue + """ + ""%""";	
		
	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.RAN Тогда
		
		Запрос.Текст = Запрос.Текст + "
		|	Items.RAN ПОДОБНО ""%"" + """ + Объект.ExportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.SegmentCode Тогда
		
		Запрос.Текст = Запрос.Текст + "
		|	StagesOfExportRequests.ExportRequest.Segment.Код ПОДОБНО ""%"" + """ + Объект.ExportTrackingMainFilterValue + """ + ""%""";
		
 	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.SerialNo Тогда
		
		Запрос.Текст = Запрос.Текст + "
		|	Items.СерийныйНомер ПОДОБНО ""%"" + """ + Объект.ExportTrackingMainFilterValue + """ + ""%""";
		
	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.SubmitterAlias Тогда
		
		Запрос.Текст = Запрос.Текст + "
		|	StagesOfExportRequests.ExportRequest.Submitter.Код ПОДОБНО ""%"" + """ + Объект.ExportTrackingMainFilterValue + """ + ""%""";
		
	// { RGS AARsentev 04.03.2018 S-I-0004271
	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.CostCenter Тогда
		
		Запрос.УстановитьПараметр("AUs", ExportTrackingMainFilterList.ВыгрузитьЗначения());
		Запрос.Текст = Запрос.Текст + "
		|	StagesOfExportRequests.ExportRequest.AU В (&AUs) ";
	// } RGS AARsentev 04.03.2018 S-I-0004271
	// { RGS AFokin 07.08.2018 23:59:59 S-I-0005770
	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.ProjectMobilization Тогда
		Запрос.УстановитьПараметр("ProjectMobilization", Объект.ExportTrackingMainFilterValue);
		Запрос.Текст = Запрос.Текст + "
		|	Items.ProjectMobilization = &ProjectMobilization";
	// } RGS AFokin 07.08.2018 23:59:59 S-I-0005770
 	КонецЕсли;
	
	// Установим дополнительный фильтр при необходимости
	Если НеобходимФильтрПоДатеДляExportTracking(Объект.ExportTrackingMainFilter) Тогда
		
		Запрос.УстановитьПараметр("DateFrom", Объект.ExportTrackingDateFrom);
		Запрос.УстановитьПараметр("DateTo", Объект.ExportTrackingDateTo);
		
		ExportTrackingDateFilters = Перечисления.ExportTrackingDateFilters;
		Если Объект.ExportTrackingDateFilter = ExportTrackingDateFilters.ExportRequestDate Тогда
			
			Запрос.Текст = Запрос.Текст + "
			|	И StagesOfExportRequests.ExportRequest.Дата >= &DateFrom
			|	И StagesOfExportRequests.ExportRequest.Дата <= &DateTo";
			
		ИначеЕсли Объект.ExportTrackingDateFilter = ExportTrackingDateFilters.ActualTimeOfDeparture Тогда
			
			Запрос.Текст = Запрос.Текст + "
			|	И ExportShipmentsExportRequests.Ссылка.InternationalATD >= &DateFrom
			|	И ExportShipmentsExportRequests.Ссылка.InternationalATD <= &DateTo";
			
		КонецЕсли;
		
	КонецЕсли;
	
	Запрос.Текст = Запрос.Текст + "
	|
	|УПОРЯДОЧИТЬ ПО
	|	ExportRequestNo";
	
	Если Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.PartNo 
		ИЛИ Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.RAN
		ИЛИ Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.PartDescription
		ИЛИ Объект.ExportTrackingMainFilter = ExportTrackingMainFilters.SerialNo Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса", "ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса");
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	// { RGS AArsentev 04.04.2018 S-I-0004271
	ТаблицаДляЗагрузки = ДозаполнитьТаблицуЗатрат(Запрос.Выполнить().Выгрузить(), "Export");
	Объект.ExportTracking.Загрузить(ТаблицаДляЗагрузки)
	// } RGS AArsentev 04.04.2018 S-I-0004271
	
	//Объект.ExportTracking.Загрузить();
	
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
	ОткрытьФорму("Обработка.ImportExportTracking.Форма.DocumentsAndAttachments", ПараметрыФормы, ЭтаФорма, ТекДанные.ExportRequest);
	
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
	
	// { RGS AArsentev 14.06.2018
	//OpenImportDocumentsAndAttachments();
	ТекДанные = Элементы.ImportTracking.ТекущиеДанные;
	Если ТекДанные <> Неопределено И ЗначениеЗаполнено(ТекДанные.Item) Тогда 
		ПоказатьЗначение(,ТекДанные.Item);
	КонецЕсли;
	// } RGS AArsentev 14.06.2018
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////////
// ОБЩИЕ ПРОЦЕДУРЫ И ФУНКЦИИ

&НаКлиенте
Функция ПолучитьИдентификаторыСтрокСоответствующихОтбору(ДанныеФормыКоллекция, ТаблицаФормы)
	
	МассивИдентификаторовСтрок = Новый Массив;
	
	Для Каждого СтрокаТЧ Из ДанныеФормыКоллекция Цикл 
		
		// заглушка на случай, что есть одна значащая строка и вторая пустая строка.
		// { RGS AARsentev 04.03.2018 S-I-0004271
		Если ТаблицаФормы <> Элементы.DomesticTracking Тогда
		// } RGS AARsentev 04.03.2018 S-I-0004271
			Если ПустаяСтрока(СтрокаТЧ.PartNo) Тогда
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		
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
		"Ошибка удаления временного .csv файла в RITA",
		УровеньЖурналаРегистрации.Ошибка,
		Метаданные.Обработки.ImportExportTracking,
		,
		"Не удалось удалить """ + ИмяВременногоФайла + """: " + ОписаниеОшибки());
	КонецПопытки;
	
	АдресФайла = ПоместитьВоВременноеХранилище(ДвоичныеДанные, УникальныйИдентификатор);
	
	Возврат АдресФайла;	
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьМассивИменИЗаголовковВидимыхКолонок(ТаблицаФормы)
	
	Массив = Новый Массив;
	
	
	ПодчиненныеЭлементы = ТаблицаФормы.ПодчиненныеЭлементы;
	
	СобратьЗаголовки(Массив, ПодчиненныеЭлементы);
	//Для Каждого ЭлементФормы из ПодчиненныеЭлементы Цикл
	//	
	//	Если Тип(ЭлементФормы) = ТипПолеФормы
	//		И ЭлементФормы.Видимость
	//		И ЗначениеЗаполнено(ЭлементФормы.Заголовок) Тогда 
	//		
	//		ИмяКолонки = ПолучитьИмяКолонкиПоПутиКДанным(ЭлементФормы.ПутьКДанным);
	//		Структура = Новый Структура("Имя, Заголовок", ИмяКолонки, ЭлементФормы.Заголовок); 
	//		Массив.Добавить(Структура);
	//		
	//	КонецЕсли;
	//	
	//КонецЦикла;	
	
	Возврат Массив;
	
КонецФункции

&НаСервереБезКонтекста
Процедура СобратьЗаголовки(Массив, ПодчиненныеЭлементы)
	
	ТипПолеФормы = Тип("ПолеФормы");
	ТипГруппаФормы = Тип("ГруппаФормы");
	
	Для Каждого ЭлементФормы из ПодчиненныеЭлементы Цикл
		
		Если Тип(ЭлементФормы) = ТипПолеФормы
			И ЭлементФормы.Видимость
			И ЗначениеЗаполнено(ЭлементФормы.Заголовок) Тогда 
			
			ИмяКолонки = ПолучитьИмяКолонкиПоПутиКДанным(ЭлементФормы.ПутьКДанным);
			Структура = Новый Структура("Имя, Заголовок", ИмяКолонки, ЭлементФормы.Заголовок); 
			Массив.Добавить(Структура);
			
		КонецЕсли;
		
		Если Тип(ЭлементФормы) = ТипГруппаФормы Тогда
			СобратьЗаголовки(Массив, ЭлементФормы.ПодчиненныеЭлементы);
		КонецЕсли;
		
	КонецЦикла;	
	
КонецПроцедуры

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

///////////////////////////////////////////////////////////////////////////////////////////
// DPM Execution progress summary

&НаКлиенте
Процедура ProjectMobilizationПриИзменении(Элемент)
		
	Если НЕ ЗначениеЗаполнено(ProjectMobilization) Тогда
		ПоказатьПредупреждение(, "Project mobilization is empty!");
		Возврат;
	КонецЕсли;
	
	СформироватьОтчетDPMСервер();
	
КонецПроцедуры

&НаКлиенте
Процедура RefreshDPM(Команда)
	
	Если НЕ ЗначениеЗаполнено(ProjectMobilization) Тогда
		ПоказатьПредупреждение(, "Project mobilization is empty!");
		Возврат;
	КонецЕсли;
	
	СформироватьОтчетDPMСервер();
	
КонецПроцедуры

&НаСервере
Процедура СформироватьОтчетDPMСервер() 
	
	УстановитьПривилегированныйРежим(Истина);
	
	ТабличныйДокументDPMExecutionProgress.Очистить();
	
	ОтчетОбъект = РеквизитФормыВЗначение("ОтчетDPMExecutionProgress");
	
	СхемаКомпоновки = ОтчетОбъект.ПолучитьМакет("ОсновнаяСхемаКомпоновкиДанных");
	НастройкиПоУмолчанию = СхемаКомпоновки.НастройкиПоУмолчанию;
	
	элемент = НастройкиПоУмолчанию.ПараметрыДанных.Элементы.Найти("ProjectMobilization");
	элемент.Использование 	= Истина; 
	элемент.Значение 		= ProjectMobilization; 
	            		
	ОтчетОбъект.КомпоновщикНастроек.ЗагрузитьНастройки(НастройкиПоУмолчанию);
	
	ДанныеРасшифровки = Новый ДанныеРасшифровкиКомпоновкиДанных;
	ОтчетОбъект.СкомпоноватьРезультат(ТабличныйДокументDPMExecutionProgress, ДанныеРасшифровки);	
	
	Диаграмма = ТабличныйДокументDPMExecutionProgress.Рисунки[0];
	//	ОбластьЛегенды 		= Диаграмма.ОбластьЛегенды;
	//	ОбластьПостроения 	= Диаграмма.ОбластьПостроения;
	
	// добавим подпись оси поверх картинки диаграммы
	Рисунок = ТабличныйДокументDPMExecutionProgress.Рисунки.Добавить(ТипРисункаТабличногоДокумента.Текст); 
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
	
	///////////////////////////////////////////////////////////////////////////////
	//выводим диаграмму domestic
	
	ТабличныйДокументDPMExecutionProgressDomestic.Очистить();      
	
	ОтчетОбъектDomestic = РеквизитФормыВЗначение("ОтчетDPMExecutionProgressDomestic");

	СхемаКомпоновкиDomestic = ОтчетОбъектDomestic.ПолучитьМакет("ОсновнаяСхемаКомпоновкиДанныхDomestic");
	НастройкиПоУмолчанию = СхемаКомпоновкиDomestic.НастройкиПоУмолчанию;
	
	элементPM = НастройкиПоУмолчанию.ПараметрыДанных.Элементы.Найти("ProjectMobilization");
	элементPM.Использование 	= Истина; 
	элементPM.Значение 		= ProjectMobilization; 
	
	элементНач = НастройкиПоУмолчанию.ПараметрыДанных.Элементы.Найти("ReadyToShipНачало");
	элементНач.Использование 	= Истина; 
	элементНач.Значение 		= DomesticReadyToShip.ДатаНачала;

	элементКон = НастройкиПоУмолчанию.ПараметрыДанных.Элементы.Найти("ReadyToShipКонец");
	элементКон.Использование 	= Истина; 
	элементКон.Значение 		= DomesticReadyToShip.ДатаОкончания;
	
	ОтчетОбъектDomestic.КомпоновщикНастроек.ЗагрузитьНастройки(НастройкиПоУмолчанию);
	
	ДанныеРасшифровкиDomestic = Новый ДанныеРасшифровкиКомпоновкиДанных;
	ОтчетОбъектDomestic.СкомпоноватьРезультат(ТабличныйДокументDPMExecutionProgressDomestic, ДанныеРасшифровкиDomestic);	
	
	ДиаграммаDomestic = ТабличныйДокументDPMExecutionProgressDomestic.Рисунки[0];
	//	ОбластьЛегенды 		= Диаграмма.ОбластьЛегенды;
	//	ОбластьПостроения 	= Диаграмма.ОбластьПостроения;
	
	// добавим подпись оси поверх картинки диаграммы
	Рисунок = ТабличныйДокументDPMExecutionProgressDomestic.Рисунки.Добавить(ТипРисункаТабличногоДокумента.Текст); 
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
	
	УстановитьПривилегированныйРежим(Ложь);

КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////
// DOMESTIC

&НаКлиенте
Процедура OpenDomesticPlanningItem(Команда)
	
	ТекДанные = Элементы.DomesticTracking.ТекущиеДанные;
	Если ТекДанные <> Неопределено И ЗначениеЗаполнено(ТекДанные.Item) Тогда 
		ПоказатьЗначение(,ТекДанные.Item);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура SpecifyProjectMobilizationDomestic(Команда)
	
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticTrackingMainFilterПриИзменении(Элемент)
	
	НастроитьDomesticTrackingFiltersНаКлиенте();
	
КонецПроцедуры

&НаСервере
Процедура НастроитьDomesticTrackingFiltersНаСервере()
	
	Если Объект.DomesticTrackingMainFilter = DomesticTrackingFilterByProjectMobilization Тогда
		
		ЗначениеПоУмолчанию = ProjectMobilizationПустаяСсылка;
		ЗаголовокЗначения = "equals to";
		ПроверкаФильтраПоДате = Ложь;
		
	Иначе
		
		ЗначениеПоУмолчанию = "";
		ЗаголовокЗначения = "contains";
		ПроверкаФильтраПоДате = Истина;

	КонецЕсли;
	
	Если ТипЗнч(Объект.DomesticTrackingMainFilterValue) <> ТипЗнч(ЗначениеПоУмолчанию) Тогда
		
		Объект.DomesticTrackingMainFilterValue = ЗначениеПоУмолчанию;
		Элементы.DomesticTrackingMainFilterValue.Заголовок = ЗаголовокЗначения;	
		
	КонецЕсли;
	
	ВидимостьФильтраПоДате = НеобходимФильтрПоДатеДляDomesticTracking(Объект.DomesticTrackingMainFilter);
	Элементы.DomesticTrackingDateFilter.Видимость = ВидимостьФильтраПоДате;
	Элементы.DomesticTrackingDateFrom.Видимость = ВидимостьФильтраПоДате;
	Элементы.DomesticTrackingDateTo.Видимость = ВидимостьФильтраПоДате;
	
	Элементы.DomesticTrackingDateFilter.АвтоОтметкаНезаполненного = ПроверкаФильтраПоДате;
	Элементы.DomesticTrackingDateFrom.АвтоОтметкаНезаполненного = ПроверкаФильтраПоДате;
	Элементы.DomesticTrackingDateTo.АвтоОтметкаНезаполненного = ПроверкаФильтраПоДате;

КонецПроцедуры

&НаСервереБезКонтекста
Функция НеобходимФильтрПоДатеДляDomesticTracking(ОсновнойФильтр)
	
	DomesticPlanningMainFilters = Перечисления.DomesticPlanningMainFilters;
	Возврат ОсновнойФильтр = DomesticPlanningMainFilters.RequestorAlias
	ИЛИ ОсновнойФильтр = DomesticPlanningMainFilters.PartNo
	ИЛИ ОсновнойФильтр = DomesticPlanningMainFilters.SegmentCode
	ИЛИ ОсновнойФильтр = DomesticPlanningMainFilters.ProjectMobilization
	// { RGS AARsentev 04.03.2018 S-I-0004271
	ИЛИ ОсновнойФильтр = DomesticPlanningMainFilters.CostCenter;
	// } RGS AARsentev 04.03.2018 S-I-0004271
	
КонецФункции

&НаКлиенте
Процедура НастроитьDomesticTrackingFiltersНаКлиенте()
	
	Если Объект.DomesticTrackingMainFilter = DomesticTrackingFilterByProjectMobilization Тогда
		
		ЗначениеПоУмолчанию = ProjectMobilizationПустаяСсылка;
		ЗаголовокЗначения = "equals to";
		ПроверкаФильтраПоДате = Ложь;		
		
	Иначе
		
		ЗначениеПоУмолчанию = "";
		ЗаголовокЗначения = "contains";
		ПроверкаФильтраПоДате = Истина;
		
	КонецЕсли;
	
	Если ТипЗнч(Объект.DomesticTrackingMainFilterValue) <> ТипЗнч(ЗначениеПоУмолчанию) Тогда
		
		Объект.DomesticTrackingMainFilterValue = ЗначениеПоУмолчанию;
		Элементы.DomesticTrackingMainFilterValue.Заголовок = ЗаголовокЗначения;	
		
	КонецЕсли;
	
	ВидимостьФильтраПоДате = Объект.DomesticTrackingMainFilter = DomesticTrackingFilterByPartNo
		ИЛИ Объект.DomesticTrackingMainFilter = DomesticTrackingFilterByRequestorAlias
		ИЛИ Объект.DomesticTrackingMainFilter = DomesticTrackingFilterBySegmentCode
		ИЛИ Объект.DomesticTrackingMainFilter = DomesticTrackingFilterByProjectMobilization
		// { RGS AARsentev 04.03.2018 S-I-0004271
		ИЛИ Объект.DomesticTrackingMainFilter = DomesticTrackingFilterByCostCenter;
		// } RGS AARsentev 04.03.2018 S-I-0004271
		
	Элементы.DomesticTrackingDateFilter.Видимость = ВидимостьФильтраПоДате;
	Элементы.DomesticTrackingDateFrom.Видимость = ВидимостьФильтраПоДате;
	Элементы.DomesticTrackingDateTo.Видимость = ВидимостьФильтраПоДате;
	
	Элементы.DomesticTrackingDateFilter.АвтоОтметкаНезаполненного = ПроверкаФильтраПоДате;
	Элементы.DomesticTrackingDateFrom.АвтоОтметкаНезаполненного = ПроверкаФильтраПоДате;
	Элементы.DomesticTrackingDateTo.АвтоОтметкаНезаполненного = ПроверкаФильтраПоДате;
	
	Если Объект.DomesticTrackingMainFilter = DomesticTrackingFilterByCostCenter Тогда
		Элементы.DomesticTrackingMainFilterList.Видимость = Истина;
		Элементы.DomesticTrackingMainFilterValue.Видимость = Ложь;
	Иначе
		Элементы.DomesticTrackingMainFilterList.Видимость = Ложь;
		Элементы.DomesticTrackingMainFilterValue.Видимость = Истина;
	КонецЕсли;
	
	Если Объект.DomesticTrackingMainFilter = DomesticTrackingFilterByCostCenter Тогда
		Элементы.DomesticTrackingMainFilterList.Видимость = Истина;
		Элементы.DomesticTrackingMainFilterValue.Видимость = Ложь;
	Иначе
		Элементы.DomesticTrackingMainFilterList.Видимость = Ложь;
		Элементы.DomesticTrackingMainFilterValue.Видимость = Истина;
	КонецЕсли;
	
КонецПроцедуры 

&НаКлиенте
Процедура DomesticTrackingSearch(Команда)
	
	Если ТипЗнч(Объект.DomesticTrackingMainFilterValue) = Тип("Строка") Тогда
		Объект.DomesticTrackingMainFilterValue = СокрЛП(Объект.DomesticTrackingMainFilterValue);
	КонецЕсли;
	
	Отказ = Ложь;
	
	ПроверитьЗаполнениеDomesticTrackingFilters(Отказ);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
		// добавим проверку на ручную правку данных
	естьРучныеЭлементы = Ложь;
	Для каждого текСтр из Объект.DomesticTracking Цикл
		
		естьРучныеЭлементы = естьРучныеЭлементы ИЛИ текСтр.isModified;
		Если естьРучныеЭлементы Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Если естьРучныеЭлементы Тогда
		
		ПоказатьВопрос(Новый ОписаниеОповещения("ОтветНаВопросОСохраненииДанныхDomestic", ЭтаФорма), "There are unsaved data. Do you want to save them?", РежимДиалогаВопрос.ДаНетОтмена,, КодВозвратаДиалога.Нет, "Search"); 
		
	Иначе
		
		DomesticTrackingSearch_Step2(Команда);		
		
	КонецЕсли;                             	
	
	
КонецПроцедуры

&НаКлиенте
Процедура ОтветНаВопросОСохраненииДанныхDomestic(Ответ, ДопПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Нет Тогда
		DomesticTrackingSearch_Step2(Неопределено);
	ИначеЕсли Ответ = КодВозвратаДиалога.Да Тогда
		DomesticTrackingSavePlan(Неопределено);	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticTrackingSearch_Step2(Команда)
	
	Состояние("Search in progress, please wait...");
	ЗаполнитьDomesticTrackingНаСервере();
	
	Если Объект.DomesticTracking.Количество() = 0 Тогда
		ПоказатьПредупреждение(, 
		"Info incorrectly input or item(s) not yet processed by RCA logistics",
		30);
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура ПроверитьЗаполнениеDomesticTrackingFilters(Отказ)
	
	// Проверим заполнение фильтра по стране
	//Если НЕ ЗначениеЗаполнено(Объект.Country) Тогда
	//	Сообщить("Fill in the field ""To country"", please!");
	//	Отказ = Истина;
	//КонецЕсли;
	
	// Проверим заполнение основного фильтра
	Если НЕ ЗначениеЗаполнено(Объект.DomesticTrackingMainFilter) Тогда
		Сообщить("Fill in the field ""Search by"", please!");
		Отказ = Истина;
	КонецЕсли;
	
	Если Объект.DomesticTrackingMainFilter = DomesticTrackingFilterByCostCenter Тогда
		Если DomesticTrackingMainFilterList.Количество() = 0 Тогда
			Сообщить("Fill in the field ""in list"", please!");
			Отказ = Истина;
		КонецЕсли;
	Иначе
		ДлинаMainFilterValue = СтрДлина(Объект.DomesticTrackingMainFilterValue);
		Если ДлинаMainFilterValue = 0 Тогда
			Сообщить("Fill in the field ""contains"", please!");
			Отказ = Истина;
		ИначеЕсли ДлинаMainFilterValue < 3 Тогда
			Сообщить("The length of the field ""contains"" should be at least 3 characters!");
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;
	
	// При необходимости проверим заполнение дополнительного фильтра
	Если ЗначениеЗаполнено(Объект.DomesticTrackingMainFilter)
		И НеобходимФильтрПоДатеДляDomesticTracking(Объект.DomesticTrackingMainFilter) Тогда
		
		Если Объект.DomesticTrackingMainFilter <> DomesticTrackingFilterByProjectMobilization Тогда
			
			Если НЕ ЗначениеЗаполнено(Объект.DomesticTrackingDateFilter) Тогда
				Сообщить("Fill in the field ""and by"", please!");
				Отказ = Истина;
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(Объект.DomesticTrackingDateFrom) Тогда
				Сообщить("Fill in the field ""from"", please!");
				Отказ = Истина;
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(Объект.DomesticTrackingDateTo) Тогда
				Сообщить("Fill in the field ""to"", please!");
				Отказ = Истина;
			КонецЕсли;	
			
		КонецЕсли;

		Если ЗначениеЗаполнено(Объект.DomesticTrackingDateFrom)
			И ЗначениеЗаполнено(Объект.DomesticTrackingDateTo) Тогда
			
			Если Объект.DomesticTrackingDateFrom > Объект.DomesticTrackingDateTo Тогда
				Сообщить("Date ""from"" should be less than date ""to""!");
				Отказ = Истина;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьDomesticTrackingНаСервере()
	
	ДопФильтры = Неопределено;
	Если ФильтрStatusDomesticИспользовать Тогда
		
		ДопФильтры = Новый Структура;
		
		СтруктураФильтраСтатус = Новый Структура;
		СтруктураФильтраСтатус.Вставить("ВидСравнения", ВидСравненияStatusDomestic);
		СтруктураФильтраСтатус.Вставить("ЗначениеСтрока", ЗначениеФильтраStatusDomestic);
		СтруктураФильтраСтатус.Вставить("ЗначениеСписок", ЗначениеФильтраStatusDomesticСписок);
		
		ДопФильтры.Вставить("Статус", СтруктураФильтраСтатус);
	КонецЕсли;
	
	// { RGS AArsentev S-I-0003227 27.06.2017
	Если ФильтрПоNavigationTypeИспользовать Тогда
		
		Если ДопФильтры = Неопределено Тогда
			ДопФильтры = Новый Структура;
		КонецЕсли;
		
		СтруктураФильтраNavigationType = Новый Структура;
		СтруктураФильтраNavigationType.Вставить("ВидСравнения", ВидСравненияNavigationTypeDomestic);
		СтруктураФильтраNavigationType.Вставить("ЗначениеСписок", ЗначениеФильтраNavigationType);
		
		ДопФильтры.Вставить("NavigationType", СтруктураФильтраNavigationType);
	КонецЕсли;
	// } RGS AArsentev S-I-0003227 27.06.2017
	
	// { RGS AARsentev 04.03.2018 S-I-0004271
	Элементы.DomesticTrackingTotalTripCostUSD.Видимость = CombineTrips;
	// } RGS AARsentev 04.03.2018 S-I-0004271
	
	ТаблицаДанных = Обработки.ImportExportTracking.ПолучитьТаблицуДанныхDomestic(
		Объект.DomesticTrackingMainFilter, 
		Объект.DomesticTrackingMainFilterValue,
		Объект.DomesticTrackingDateFilter,
		Объект.DomesticTrackingDateFrom,
		Объект.DomesticTrackingDateTo, 
		Объект.Country,
		DomesticTrackingVariant,
		DomesticTrackingVariantOwner,
		ДопФильтры,
		// { RGS AARsentev 04.04.2018 S-I-0004271
		DomesticTrackingMainFilterList.ВыгрузитьЗначения()
		// } RGS AARsentev 04.04.2018 S-I-0004271
		);
		
	Обработки.ImportExportTracking.DomesticPlanningFillStatistic(ТаблицаДанных);
	
	Если CombineTrips Тогда
		ТаблицаДанных.Свернуть("TransportRequest,ProjectMobilization,HazardClass,Comments,LocationFrom,LocationTo,Company,ReadyToShip,StageGroupName,Trip,DeliveryToLocation,Equipment,
		|MOT, RDD, PlannedDeliveryToLocation, SegmentCode,TransportRequestNo,TripNo, PlannedDepartureLocalTime, DepartureFromSource, Milage, Manual, NavigationType, TotalCostsSumUSD,FreightCostPerKM,
		|FreightCostPerKG,FreightCostPerTKM, TonneKilometers, TotalActualDuration, NumOfTransport, ПредставлениеDuration", "TotalFreightCostKM, TotalFreightCostKG, TotalFreightCostTKM,GrossWeightKG, Qty");
	КонецЕсли;
		
	Объект.DomesticTracking.Загрузить(ТаблицаДанных);
	 	
	// рассчитаем даты
	Обработки.ImportExportTracking.РассчитатьДатыDomestic(Объект.DomesticTracking);
	                              	
	// если строка 1, то добавим еще одну и сделаем ее активной
	Если Объект.DomesticTracking.Количество() = 1 Тогда
		стр = Объект.DomesticTracking.Добавить();
		элементы.DomesticTracking.ТекущаяСтрока = стр.ПолучитьИдентификатор(); 
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ChangeSelected(Команда)
	
	МассивВыделенныхGoods = ПолучитьМассивВыделенныхGoods("Item", "ImportTracking");
		
	Если МассивВыделенныхGoods.Количество() = 0 Тогда
		Предупреждение(
		"Please, select at least one item line!",
		30);
		Возврат;
	КонецЕсли;
	
	СтруктураДопПараметров = Новый Структура("ИмяТаблицы, МассивGoods, ИмяКолонкиПоиска");
	СтруктураДопПараметров.ИмяТаблицы = "ImportTracking";
	СтруктураДопПараметров.МассивGoods = МассивВыделенныхGoods;
	
	СтруктураПараметров = Новый Структура;
	МассивComments = ПолучитьМассивВыделенныхGoods("Comments", "ImportTracking");
	Если МассивComments.Количество() = 1 Тогда 
		СтруктураПараметров.Вставить("Comments", МассивComments[0]);
	КонецЕсли;
	
	ОткрытьФорму("Обработка.ImportExportTracking.Форма.ModifyPlanningData", СтруктураПараметров, ЭтаФорма, , , , 
		Новый ОписаниеОповещения("ВыполнитьПослеВыбораЗначений", ЭтаФорма, СтруктураДопПараметров), РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
		    		
КонецПроцедуры

&НаКлиенте
Процедура ChangeSelectedDomestic(Команда)
	
	МассивВыделенныхGoods = ПолучитьМассивВыделенныхGoods("Item", "DomesticTracking");
		
	Если МассивВыделенныхGoods.Количество() = 0 Тогда
		Предупреждение(
		"Please, select at least one item line!",
		30);
		Возврат;
	КонецЕсли;
	
	СтруктураДопПараметров = Новый Структура("ИмяТаблицы, МассивGoods, ИмяКолонкиПоиска");
	СтруктураДопПараметров.ИмяТаблицы = "DomesticTracking";
	СтруктураДопПараметров.МассивGoods = МассивВыделенныхGoods;
	
	СтруктураПараметров = Новый Структура;
	МассивComments = ПолучитьМассивВыделенныхGoods("Comments", "DomesticTracking");
	Если МассивComments.Количество() = 1 Тогда 
		СтруктураПараметров.Вставить("Comments", МассивComments[0]);
	КонецЕсли;
	
	ОткрытьФорму("Обработка.ImportExportTracking.Форма.ModifyPlanningDataDomestic", СтруктураПараметров, ЭтаФорма, , , , 
		Новый ОписаниеОповещения("ВыполнитьПослеВыбораЗначенийDomestic", ЭтаФорма, СтруктураДопПараметров), РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
		       
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПослеВыбораЗначений(Результат, ДополнительныеПараметры)  Экспорт 
		
	Если Не ЗначениеЗаполнено(Результат) ИЛИ Результат = КодВозвратаДиалога.Отмена Тогда
		Возврат;
	КонецЕсли;
	
	количествоПолей = Результат.Количество();
	
	Если Результат.Свойство("ProjectMobilization") Тогда
		
		МассивИзмененныхItems = Новый Массив;
		МассивИзмененныхMI    = Новый Массив;

		количествоПолей = количествоПолей - 1;
		
	КонецЕсли;	
	
	строкаЗаполняемыхПолей_МИ = "ProjectMobilization, HazardClass, Qty, Value, GrossWeightKG, FreightCostPerKG, RequestedPOACode, PODCode, MOTCode, Comments";
	строкаЗаполняемыхПолей_все = "ProjectMobilization, HazardClass, GrossWeightKG, FreightCostPerKG, RequestedPOACode, PODCode, MOTCode, Comments";
	
	массивИндексовСтрокДляПересчета = Новый Массив;
	
	Для каждого текСтрокаТаблицы из Элементы[ДополнительныеПараметры.ИмяТаблицы].ВыделенныеСтроки Цикл
				
		текСтрока = Объект[ДополнительныеПараметры.ИмяТаблицы].НайтиПоИдентификатору(текСтрокаТаблицы);
		
		Если Результат.Свойство("ProjectMobilization") Тогда
			Если ТипЗнч(текСтрока.Item) = Тип("СправочникСсылка.ProjectMobilizationManualItems") Тогда
				МассивИзмененныхMI.Добавить(текСтрока.Item);
			иначе
				МассивИзмененныхItems.Добавить(текСтрока.Item);
			КонецЕсли;
		КонецЕсли;

		Если ЗначениеЗаполнено(текСтрока.DOC) Тогда
			строкаЗаполняемыхПолей_шаблон = "Comments";
		иначе		
			строкаЗаполняемыхПолей_шаблон = ?(текСтрока.isManualItem, строкаЗаполняемыхПолей_МИ, строкаЗаполняемыхПолей_все);
		КонецЕсли;

		строкаЗаполняемыхПолей = "";
		
		Для каждого текЭлемент из Результат Цикл
			
			Если СтрНайти(строкаЗаполняемыхПолей_шаблон, текЭлемент.Ключ) <> 0 Тогда
				строкаЗаполняемыхПолей = строкаЗаполняемыхПолей + ?(ПустаяСтрока(строкаЗаполняемыхПолей), "", ", ") + текЭлемент.Ключ;
			КонецЕсли;
			
		КонецЦикла;
		
		// ничего не изменилось, ничего не делаем
		Если ПустаяСтрока(строкаЗаполняемыхПолей) Тогда
			Продолжить;
		КонецЕсли;
		       				
		ЗаполнитьЗначенияСвойств(текСтрока, Результат, строкаЗаполняемыхПолей);	
		
		// метим строку как измененную
		текСтрока.isModified = Истина;
		// то, что изменили вручную, считаем плановыми данными
		текСтрока.isPlanData = Истина;
		
		// посчитаем итоговые строки
		текСтрока.TotalGrossWeightKG 	= текСтрока.Qty * текСтрока.GrossWeightKG;
		текСтрока.TotalFreightCost 		= текСтрока.TotalGrossWeightKG * текСтрока.FreightCostPerKG;
		
		//Если количествоПолей > 0 Тогда
		//	текСтрока.isManualData = Истина;
		//КонецЕсли;
		
		массивИндексовСтрокДляПересчета.Добавить(текСтрокаТаблицы);
		
	КонецЦикла;
	
	Если Результат.Свойство("ProjectMobilization") Тогда
	
		Если МассивИзмененныхItems.Количество() > 0 Тогда
			МассивИзмененныхItems = ИзменитьРеквизитВСсылкахВПривилегированномРежиме(МассивИзмененныхItems, 
			"ProjectMobilization", Результат.ProjectMobilization);
		КонецЕсли;
		
		Если МассивИзмененныхMI.Количество() > 0 Тогда
			МассивИзмененныхMI = ИзменитьРеквизитВСсылкахВПривилегированномРежиме(МассивИзмененныхMI, 
			"Владелец", Результат.ProjectMobilization);
		КонецЕсли;
		
		ОбновитьКолонкуВGoods(ДополнительныеПараметры.МассивGoods, ДополнительныеПараметры.ИмяТаблицы, 
			"Item", "ProjectMobilization", Результат.ProjectMobilization);
	           
	КонецЕсли;

	Если массивИндексовСтрокДляПересчета.Количество() > 0 Тогда
		РассчитатьСтатистику(массивИндексовСтрокДляПересчета);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура РассчитатьСтатистику(массивИндексовСтрокДляПересчета)
	
	массивСтрокДляПересчета = Новый Массив;
	Для каждого текИндекс из массивИндексовСтрокДляПересчета Цикл
		массивСтрокДляПересчета.Добавить(Объект.ImportTracking.НайтиПоИдентификатору(текИндекс));	
	КонецЦикла;
	
	Обработки.ImportExportTracking.РассчитатьПлановыеПоказатели(Объект.ImportTracking, массивСтрокДляПересчета);
	Обработки.ImportExportTracking.РассчитатьДаты(Объект.ImportTracking, массивСтрокДляПересчета);
	
КонецПроцедуры

&НаКлиенте
Процедура ImportTrackingVariantОкончаниеВводаТекста(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ДанныеВыбора = Текст;
	ImportTrackingVariantOwner	= ПользователиКлиентСервер.ТекущийПользователь();
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПослеВыбораЗначенийDomestic(Результат, ДополнительныеПараметры)  Экспорт 
		
	Если Не ЗначениеЗаполнено(Результат) ИЛИ Результат = КодВозвратаДиалога.Отмена Тогда
		Возврат;
	КонецЕсли;
	
	количествоПолей = Результат.Количество();
	
	Если Результат.Свойство("ProjectMobilization") Тогда
		
		МассивИзмененныхTRs   = Новый Массив;
		МассивИзмененныхItems = Новый Массив;
		МассивИзмененныхMI    = Новый Массив;

		количествоПолей = количествоПолей - 1;
		
	КонецЕсли;	
	
	строкаЗаполняемыхПолей_МИ = "ProjectMobilization, HazardClass, Qty, GrossWeightKG, FreightCostPerKG, Company, MOT, Equipment, LocationFrom, LocationTo, Comments";
	строкаЗаполняемыхПолей_TR = "ProjectMobilization, HazardClass, FreightCostPerKG, MOT, Equipment, Comments";
		
	массивИндексовСтрокДляПересчета = Новый Массив;
	
	Для каждого текСтрокаТаблицы из Элементы[ДополнительныеПараметры.ИмяТаблицы].ВыделенныеСтроки Цикл
				
		текСтрока = Объект[ДополнительныеПараметры.ИмяТаблицы].НайтиПоИдентификатору(текСтрокаТаблицы);
		
		//Если ЗначениеЗаполнено(текСтрока.Trip) Тогда
		//	Продолжить;
		//КонецЕсли;
		
		Если Результат.Свойство("ProjectMobilization") Тогда
			Если ЗначениеЗаполнено(текСтрока.TransportRequest) Тогда
				МассивИзмененныхTRs.Добавить(текСтрока.TransportRequest);
				МассивИзмененныхItems.Добавить(текСтрока.Item);
			иначе
				МассивИзмененныхMI.Добавить(текСтрока.Item);
			КонецЕсли;
		КонецЕсли;	
			
		строкаЗаполняемыхПолей_шаблон = ?(текСтрока.Manual, строкаЗаполняемыхПолей_МИ, строкаЗаполняемыхПолей_TR);
		
		строкаЗаполняемыхПолей = "";
		
		Для каждого текЭлемент из Результат Цикл
			
			Если СтрНайти(строкаЗаполняемыхПолей_шаблон, текЭлемент.Ключ) <> 0 Тогда
				строкаЗаполняемыхПолей = строкаЗаполняемыхПолей + ?(ПустаяСтрока(строкаЗаполняемыхПолей), "", ", ") + текЭлемент.Ключ;
			КонецЕсли;
			
		КонецЦикла;
		
		// ничего не изменилось, ничего не делаем
		Если ПустаяСтрока(строкаЗаполняемыхПолей) Тогда
			Продолжить;
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(текСтрока, Результат, строкаЗаполняемыхПолей);	
		
		// метим строку как измененную
		текСтрока.isModified = Истина;
		// то, что изменили вручную, считаем плановыми данными
		текСтрока.isPlanData = Истина;
		
		// посчитаем итоговые строки
		текСтрока.TotalGrossWeightKG 	= текСтрока.Qty * текСтрока.GrossWeightKG;
		текСтрока.TotalFreightCostKG	= текСтрока.TotalGrossWeightKG * текСтрока.FreightCostPerKG;
		   				
		массивИндексовСтрокДляПересчета.Добавить(текСтрокаТаблицы);
		
	КонецЦикла;
	
	Если Результат.Свойство("ProjectMobilization") Тогда
	
		Если МассивИзмененныхTRs.Количество() > 0 Тогда
			МассивИзмененныхTRs = ИзменитьProjectMobilizationВTRs(МассивИзмененныхTRs, Результат.ProjectMobilization);	
		КонецЕсли;
		
		Если МассивИзмененныхItems.Количество() > 0 Тогда
			МассивИзмененныхItems = ИзменитьРеквизитВСсылкахВПривилегированномРежиме(МассивИзмененныхItems, 
			"ProjectMobilization", Результат.ProjectMobilization);
		КонецЕсли;
		
		Если МассивИзмененныхMI.Количество() > 0 Тогда
			МассивИзмененныхMI = ИзменитьРеквизитВСсылкахВПривилегированномРежиме(МассивИзмененныхMI, 
			"Владелец", Результат.ProjectMobilization);
		КонецЕсли;
		
		ОбновитьКолонкуВGoods(ДополнительныеПараметры.МассивGoods, ДополнительныеПараметры.ИмяТаблицы, 
			"Item", "ProjectMobilization", Результат.ProjectMobilization);

	КонецЕсли;        	          	
		
	Если массивИндексовСтрокДляПересчета.Количество() > 0 Тогда
		РассчитатьСтатистикуDomestic(массивИндексовСтрокДляПересчета);
	КонецЕсли;  	  
	
КонецПроцедуры

&НаСервере
Процедура РассчитатьСтатистикуDomestic(массивИндексовСтрокДляПересчета)
	
	массивСтрокДляПересчета = Новый Массив;
	Для каждого текИндекс из массивИндексовСтрокДляПересчета Цикл
		массивСтрокДляПересчета.Добавить(Объект.DomesticTracking.НайтиПоИдентификатору(текИндекс));	
	КонецЦикла;
	
	Обработки.ImportExportTracking.DomesticPlanningFillStatistic(Объект.DomesticTracking, массивСтрокДляПересчета);
	Обработки.ImportExportTracking.РассчитатьДатыDomestic(Объект.DomesticTracking, массивСтрокДляПересчета);
	
КонецПроцедуры

&НаСервере
Функция ИзменитьРеквизитВСсылкахВПривилегированномРежиме(МассивСсылок, ИмяРеквизита, НовоеЗначение) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	МассивИзмененныхСсылок = Новый Массив;
	
	Для Каждого Ссылка Из МассивСсылок Цикл
		
		НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
		
		ОбъектДляИзменения = Ссылка.ПолучитьОбъект();
		
		Если Ссылка[ИмяРеквизита] = НовоеЗначение Тогда
			ЗафиксироватьТранзакцию();
			МассивИзмененныхСсылок.Добавить(Ссылка);
			Продолжить;
		КонецЕсли;
		
		ОбъектДляИзменения[ИмяРеквизита] = НовоеЗначение;
		
		Попытка
			ОбъектДляИзменения.ОбменДанными.Загрузка = Истина;
			ОбъектДляИзменения.Записать();
		Исключение
			ОтменитьТранзакцию();
			Сообщить(
				"Failed to save " + СокрЛП(ОбъектДляИзменения) + "!
				|See errors above.
				|" + ОписаниеОшибки());
			Продолжить;
		КонецПопытки;
		
		ЗафиксироватьТранзакцию();
		МассивИзмененныхСсылок.Добавить(Ссылка);
		
	КонецЦикла;
	
	Возврат МассивИзмененныхСсылок;
	
КонецФункции

&НаКлиенте
Процедура DomesticTrackingВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	// { RGS AArsentev 14.06.2018
	//OpenImportDocumentsAndAttachments();
	ТекДанные = Элементы.ImportTracking.ТекущиеДанные;
	Если ТекДанные <> Неопределено И ЗначениеЗаполнено(ТекДанные.Item) Тогда 
		ПоказатьЗначение(,ТекДанные.Item);
	КонецЕсли;
	// } RGS AArsentev 14.06.2018
	
КонецПроцедуры

&НаКлиенте
Процедура SaveToExcel(Команда)
	
	Если Объект.ImportTracking.Количество() = 0 Тогда
		Сообщить("No items for loading!");
		Возврат;
	КонецЕсли;
	
	МассивПолей = ПодготовитьМассивПолей();
	
	ТабДок = Новый ТабличныйДокумент;
	
	Линия = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1, Ложь);
	
	Для Счет = 1 По МассивПолей.Количество() Цикл
		
		Область = ТабДок.Область("R1C" + Формат(Счет, "ЧГ=0"));
		Область.Текст = Элементы[МассивПолей[Счет-1]].Заголовок; 
		
		Область.ГраницаСверху 	= Линия;
		Область.ГраницаСлева	= Линия;
		Область.ГраницаСнизу	= Линия;
		Область.ГраницаСправа	= Линия;
		
		Если Счет = 6 ИЛИ Счет = 10 Тогда
			Область.ЦветФона = WebЦвета.СеребристоСерый;
		КонецЕсли;
		
	КонецЦикла;
	
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Фильтр = "*.xlsx|*.xlsx";
	
	Если НЕ Диалог.Выбрать() Тогда
		Возврат;
	КонецЕсли;
	
	СчетСтрок = 2;
	Для каждого ТекСтрока из Объект.ImportTracking Цикл
		
		Если ТекСтрока.isManualItem Тогда
			Продолжить;
		КонецЕсли;
		
		Если ПустаяСтрока(ТекСтрока.PartNo) Тогда
			Продолжить;
		КонецЕсли;
		
		Для Счет = 1 По МассивПолей.Количество() Цикл
		
			ИмяПоля = СтрЗаменить(МассивПолей[счет-1], "ImportTracking", "");
			
		   	Область = ТабДок.Область("R" + Формат(СчетСтрок, "ЧГ=0") + "C" + Формат(Счет, "ЧГ=0"));
			Значение = ТекСтрока[ИмяПоля];
			Если ТипЗнч(Значение) = Тип("Дата") Тогда
				Значение = Формат(Значение, "ДФ=dd.MM.yyyy");
			КонецЕсли;
			Область.Текст = Значение;
			
			Если Счет = 6 ИЛИ Счет = 10 Тогда
				Область.ЦветФона = WebЦвета.СеребристоСерый;
			КонецЕсли;
			
		КонецЦикла;
		                                        
		СчетСтрок = СчетСтрок + 1;
		
	КонецЦикла; 
	
	ТабДок.Записать(Диалог.ПолноеИмяФайла, ТипФайлаТабличногоДокумента.XLSX);
	
	
КонецПроцедуры

&НаКлиенте
Функция ПодготовитьМассивПолей()
	
	МассивПолей = Новый Массив;
	
	МассивПолей.Добавить("ImportTrackingItem");
	МассивПолей.Добавить("ImportTrackingPartNo");
	МассивПолей.Добавить("ImportTrackingPartDescription");
	МассивПолей.Добавить("ImportTrackingSerialNo");
	МассивПолей.Добавить("ImportTrackingSegmentCode");
	МассивПолей.Добавить("ImportTrackingProjectMobilization");
	МассивПолей.Добавить("ImportTrackingPONo");
	МассивПолей.Добавить("ImportTrackingPOLineNo");
	МассивПолей.Добавить("ImportTrackingInvoiceNo");
	МассивПолей.Добавить("ImportTrackingRequiredDeliveryDate");
	МассивПолей.Добавить("ImportTrackingDOC");
	МассивПолей.Добавить("ImportTrackingPODCode");
	МассивПолей.Добавить("ImportTrackingPODate");
	МассивПолей.Добавить("ImportTrackingMOTCode");
	МассивПолей.Добавить("ImportTrackingDOCCurrentComment");
	
	Возврат МассивПолей;
	
КонецФункции

&НаКлиенте
Процедура LoadFromExcel(Команда)
	
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Фильтр = "*.xlsx|*.xlsx";
	
	Если НЕ Диалог.Выбрать() Тогда
		Возврат;
	КонецЕсли;
	
	МассивПолей = ПодготовитьМассивПолей();
	
	Excel = Новый COMОбъект("Excel.Application");
	Excel.WorkBooks.Open(Диалог.ПолноеИмяФайла); 
	Состояние("Loading file Microsoft Excel...");
	
	Попытка
		ExcelЛист = Excel.Sheets(1); 
	Исключение
		Сообщить("Error. Please check Excel sheet number.");
		Возврат;
	КонецПопытки;
	
	ActiveCell 	= Excel.ActiveCell.SpecialCells(11);
	RowCount 	= ActiveCell.Row; //Строчек
	ColumnCount = ActiveCell.Column; //Столбцов
	
	ЧислоКолонокМакс = МассивПолей.Количество();
	
	Ответ = Новый Массив;
	
	Для Row = 2 По RowCount Цикл 
		
		СтруктураСтроки = Новый Структура;
		
		Для СчетКолонок = 1 по ЧислоКолонокМакс Цикл
			Значение =	СокрЛП(Excel.Cells(Row, СчетКолонок).Text);
			СтруктураСтроки.Вставить(МассивПолей[СчетКолонок-1], Значение);
		КонецЦикла;		
		
		Ответ.Добавить(СтруктураСтроки);
		
	КонецЦикла; 
	
	Excel.DisplayAlerts = 0; 
	Excel.Quit();
	Excel.DisplayAlerts = 1;
	
	ОбработатьЗагруженныеДанные(Ответ);
	
	// программно выполним Search
	ImportTrackingSearch(Неопределено);	
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОбработатьЗагруженныеДанные(Ответ)
	
	СоответствиеПроектов = Новый Соответствие;
	БылиОшибки = Ложь;
	
	Для каждого ТекСтрокаОтвета из Ответ Цикл
		
		ПроектТ	= ТекСтрокаОтвета["ImportTrackingProjectMobilization"];
		RDD		= ТекСтрокаОтвета["ImportTrackingRequiredDeliveryDate"]; 
		
		//Если ПустаяСтрока(ПроектТ) и ПустаяСтрока(RDD) Тогда
		//	Продолжить;
		//КонецЕсли;
		      		
		ДатаРДД = Неопределено;
		
		Если ЗначениеЗаполнено(RDD) Тогда 
			
			Попытка 
				ДатаРДД = Дата(RDD + " 00:00:00");
			Исключение
				Сообщить("Failed to convert date: " + RDD);
				БылиОшибки = Истина;
			КонецПопытки;
			
		КонецЕсли;
		
		Проект = Неопределено;
		Если ЗначениеЗаполнено(ПроектТ) Тогда
			Проект = СоответствиеПроектов.Получить(ПроектТ);
			Если Проект = Неопределено Тогда
				Проект = Справочники.ProjectMobilization.НайтиПоНаименованию(ПроектТ);
				Если ЗначениеЗаполнено(Проект) Тогда
					СоответствиеПроектов.Вставить(ПроектТ, Проект);
				Иначе
					Сообщить("Failed to find project: " + ПроектТ);
					БылиОшибки = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ТекСтрокаОтвета["ImportTrackingItem"]) Тогда
			
			СтрокаИнвойса = Справочники.СтрокиИнвойса.НайтиПоНаименованию(ТекСтрокаОтвета["ImportTrackingItem"]);
			Если ЗначениеЗаполнено(СтрокаИнвойса) Тогда			
				//Если ЗначениеЗаполнено(Проект) Тогда
				СтрокаИнвойсаОбъект = СтрокаИнвойса.ПолучитьОбъект();
				РГСофтКлиентСервер.УстановитьЗначение(СтрокаИнвойсаОбъект.ProjectMobilization, Проект);
				Если СтрокаИнвойсаОбъект.Модифицированность() Тогда 
					Попытка
						СтрокаИнвойсаОбъект.ОбменДанными.Загрузка = Истина;
						СтрокаИнвойсаОбъект.Записать();
					Исключение
						ОтменитьТранзакцию();
						Сообщить(
						"Failed to save " + СокрЛП(СтрокаИнвойсаОбъект) + "!
						|See errors above.
						|" + ОписаниеОшибки());
						БылиОшибки = Истина;
					КонецПопытки; 
				КонецЕсли;
				//КонецЕсли;
				
				//Если ЗначениеЗаполнено(ДатаРДД) Тогда
				МассивItems = Новый Массив;
				МассивItems.Добавить(СтрокаИнвойса);
				
				ИзменитьRDDВParcels(МассивItems, ДатаРДД); 
				//КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ТекСтрокаОтвета["ImportTrackingPONo"]) и ЗначениеЗаполнено(ТекСтрокаОтвета["ImportTrackingPOLineNo"]) Тогда
			
			Запрос = Новый Запрос;
			Запрос.Текст = 
			"ВЫБРАТЬ
			|	СтрокиЗаявкиНаЗакупку.Ссылка
			|ИЗ
			|	Справочник.СтрокиЗаявкиНаЗакупку КАК СтрокиЗаявкиНаЗакупку
			|ГДЕ
			|	СтрокиЗаявкиНаЗакупку.НомерСтрокиЗаявкиНаЗакупку = &НомерСтрокиЗаявкиНаЗакупку
			|	И СтрокиЗаявкиНаЗакупку.Владелец.Код = &Код";
			
			Запрос.УстановитьПараметр("Код", ТекСтрокаОтвета["ImportTrackingPONo"]);
			Запрос.УстановитьПараметр("НомерСтрокиЗаявкиНаЗакупку", Число(ТекСтрокаОтвета["ImportTrackingPOLineNo"]));
			
			Результат = Запрос.Выполнить().Выбрать();
			
			Если Результат.Следующий() Тогда
				СтрокаПО  = Результат.Ссылка;
				
				//Если ЗначениеЗаполнено(Проект) Тогда
				СтрокаПООбъект = СтрокаПО.ПолучитьОбъект();
				РГСофтКлиентСервер.УстановитьЗначение(СтрокаПООбъект.ProjectMobilization, Проект);
				Если СтрокаПООбъект.Модифицированность() Тогда
					Попытка
						СтрокаПООбъект.ОбменДанными.Загрузка = Истина;
						СтрокаПООбъект.Записать();
					Исключение
						ОтменитьТранзакцию();
						Сообщить(
						"Failed to save " + СокрЛП(СтрокаПООбъект) + "!
						|See errors above.
						|" + ОписаниеОшибки());
						БылиОшибки = Истина;
					КонецПопытки;
				КонецЕсли;
				//КонецЕсли;
				
				//Если ЗначениеЗаполнено(ДатаРДД) Тогда
				МассивPOLines = Новый Массив;
				МассивPOLines.Добавить(СтрокаПО);
				
				ИзменитьRDDВPOLiness(МассивPOLines, ДатаРДД);	
				//КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;

	Если БылиОшибки Тогда 
		Сообщить("File was loaded with errors.");
	иначе
		Сообщить("File was successfully loaded.");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ФильтрStatusИспользоватьПриИзменении(Элемент)
	
	УстановитьВидимостьДоступностьФильтров(ЭтаФорма);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьВидимостьДоступностьФильтров(Форма)
	
	Элементы = Форма.Элементы;
	
	//Import
	Элементы.ГруппаOtherFilters.Видимость = Элементы.OtherFilters.Пометка;
	
	Элементы.ГруппаСтатусДоступность.Доступность = Форма.ФильтрStatusИспользовать;
	
	ЗначениеВСтроке = (Форма.ВидСравненияStatus = "Equal" ИЛИ Форма.ВидСравненияStatus = "Not equal");
	
	Элементы.ЗначениеФильтраStatus.Видимость 		= НЕ ЗначениеВСтроке;
	Элементы.ЗначениеФильтраStatusСтрока.Видимость = ЗначениеВСтроке;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьВидимостьДоступностьФильтровDomestic(Форма)
	
	Элементы = Форма.Элементы;
	                      		
	//Domestic
	Элементы.ГруппаOtherFiltersDomestic.Видимость = Элементы.OtherFiltersDomestic.Пометка;
	
	Элементы.ГруппаСтатусДоступностьDomestic.Доступность = Форма.ФильтрStatusDomesticИспользовать;
	
	ЗначениеВСтрокеDomestic = (Форма.ВидСравненияStatusDomestic = "Equal" ИЛИ Форма.ВидСравненияStatusDomestic = "Not equal");
	
	Элементы.ЗначениеФильтраStatusDomestic.Видимость 		= НЕ ЗначениеВСтрокеDomestic;
	Элементы.ЗначениеФильтраStatusDomesticСтрока.Видимость = ЗначениеВСтрокеDomestic;
	
	// { RGS AArsentev S-I-0003227 27.06.2017
	Элементы.ГруппаNavigationTypeДоступностьDomestic.Доступность = Форма.ФильтрПоNavigationTypeИспользовать;
	ЗначениеВСтрокеDomestic_NavigationType = (Форма.ВидСравненияNavigationTypeDomestic = "Equal" ИЛИ Форма.ВидСравненияNavigationTypeDomestic = "Not equal");
	// } RGS AArsentev S-I-0003227 27.06.2017
	
КонецПроцедуры

&НаКлиенте
Процедура ВидСравненияStatusПриИзменении(Элемент)
	
	УстановитьВидимостьДоступностьФильтров(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура OtherFilters(Команда)
	
	Элементы.OtherFilters.Пометка = НЕ Элементы.OtherFilters.Пометка;
	
	УстановитьВидимостьДоступностьФильтров(ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура ПриСохраненииДанныхВНастройкахНаСервере(Настройки)
	
	//ПОДУМАТЬ!!!
	//АктивнаяСтраница = Элементы.ГруппаСтраницы.ТекущаяСтраница;
	//Настройки.Вставить("Объект.АктивнаяСтраница", АктивнаяСтраница);
	
КонецПроцедуры

// Create new Export Request

&НаКлиенте
Процедура CreateExportRequest(Команда)
	
	Оповещение = Новый ОписаниеОповещения("ПослеЗакрытияВопросаCreateExportRequest", ЭтаФорма);
	
	ПоказатьВопрос(Оповещение, "Search filter can be changed, continue?", РежимДиалогаВопрос.ДаНет,,, "Creating new export request");
		
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗакрытияВопросаCreateExportRequest(Результат, Параметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
        Возврат;
    КонецЕсли;

    ОткрытьФорму("Документ.ExportRequest.ФормаОбъекта", , ЭтаФорма, , , , 
		Новый ОписаниеОповещения("ВыполнитьПослеЗакрытияNewExportRequest", ЭтотОбъект),
		РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПослеЗакрытияNewExportRequest(Результат, Параметры) Экспорт
	
	Объект.ExportTrackingMainFilter = ExportTrackingFilterBySubmitterAlias;
	Объект.ExportTrackingMainFilterValue = СокрЛП(ПользователиКлиентСервер.ТекущийПользователь());
	
	Объект.ExportTrackingDateFilter = ПредопределенноеЗначение("Перечисление.ExportTrackingDateFilters.ExportRequestDate");
	Объект.ExportTrackingDateFrom = ДобавитьМесяц(ТекущаяДата(), -1);
	Объект.ExportTrackingDateTo = КонецДня(ТекущаяДата())+1;
	
	Элементы.ExportTrackingDateFilter.Видимость = Истина;
	Элементы.ExportTrackingDateFrom.Видимость = Истина;
	Элементы.ExportTrackingDateTo.Видимость = Истина;

	ЗаполнитьExportTrackingНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура OpenExportItem(Команда)
	
	ТекДанные = Элементы.ExportTracking.ТекущиеДанные;
	Если ТекДанные <> Неопределено И ЗначениеЗаполнено(ТекДанные.Item) Тогда 
		ПоказатьЗначение(,ТекДанные.Item);
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура OpenExportRequest(Команда)
	
	ТекДанные = Элементы.ExportTracking.ТекущиеДанные;
	Если ТекДанные <> Неопределено И ЗначениеЗаполнено(ТекДанные.ExportRequest) Тогда 
		ПоказатьЗначение(,ТекДанные.ExportRequest);
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура DomesticReadyToShipПриИзменении(Элемент)
	
	Если НЕ ЗначениеЗаполнено(ProjectMobilization) Тогда
		ПоказатьПредупреждение(, "Project mobilization is empty!");
		Возврат;
	КонецЕсли;
	
	СформироватьОтчетDPMСервер();

КонецПроцедуры

&НаКлиенте
Процедура DomesticTrackingDocumentsAndAttachments(Команда)
	
	OpenDomesticDocumentsAndAttachments();
	
КонецПроцедуры

&НаКлиенте
Процедура OpenDomesticDocumentsAndAttachments()
	
	ТекДанные = Элементы.DomesticTracking.ТекущиеДанные;
	
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("TransportRequest", ТекДанные.TransportRequest);
		
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Отбор", СтруктураОтбора);		
	ОткрытьФорму("Обработка.ImportExportTracking.Форма.DocumentsAndAttachments", ПараметрыФормы, ЭтаФорма, ТекДанные.TransportRequest);
	
КонецПроцедуры

&НаКлиенте
Процедура OpenTransportRequest(Команда)
	
	ТекДанные = Элементы.DomesticTracking.ТекущиеДанные;
	Если ТекДанные <> Неопределено И ЗначениеЗаполнено(ТекДанные.TransportRequest) Тогда 
		ПоказатьЗначение(,ТекДанные.TransportRequest);
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура CreateTransportRequest(Команда)
	
	Оповещение = Новый ОписаниеОповещения("ПослеЗакрытияВопросаCreateTransportRequest", ЭтаФорма);
	
	ПоказатьВопрос(Оповещение, НСтр("ru = 'Настройки поиска могут быть сброшены, продолжить создание?'; en = 'Search filter can be changed, continue?'"), РежимДиалогаВопрос.ДаНет,,, "Creating new transport request");
	
КонецПроцедуры                                     

&НаКлиенте
Процедура ПослеЗакрытияВопросаCreateTransportRequest(Результат, Параметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
        Возврат;
    КонецЕсли;

    ОткрытьФорму("Документ.TransportRequest.ФормаОбъекта", , ЭтаФорма, , , , 
		Новый ОписаниеОповещения("ВыполнитьПослеЗакрытияNewTransportRequest", ЭтотОбъект),
		РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПослеЗакрытияNewTransportRequest(Результат, Параметры) Экспорт
	
	Объект.DomesticTrackingMainFilter = DomesticTrackingFilterByRequestorAlias;
	Объект.DomesticTrackingMainFilterValue = СокрЛП(ПользователиКлиентСервер.ТекущийПользователь());
	
	Объект.DomesticTrackingDateFilter = ПредопределенноеЗначение("Перечисление.DomesticTrackingDateFilters.TransportRequestDate");
	Объект.DomesticTrackingDateFrom = ДобавитьМесяц(ТекущаяДата(), -1);
	Объект.DomesticTrackingDateTo = КонецДня(ТекущаяДата())+1;
	
	Элементы.DomesticTrackingDateFilter.Видимость = Истина;
	Элементы.DomesticTrackingDateFrom.Видимость = Истина;
	Элементы.DomesticTrackingDateTo.Видимость = Истина;

	ЗаполнитьDomesticTrackingНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура OtherFiltersDomestic(Команда)
	
	Элементы.OtherFiltersDomestic.Пометка = НЕ Элементы.OtherFiltersDomestic.Пометка;
	
	УстановитьВидимостьДоступностьФильтровDomestic(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ВидСравненияStatusDomesticПриИзменении(Элемент)
	
	УстановитьВидимостьДоступностьФильтровDomestic(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ФильтрStatusDomesticИспользоватьПриИзменении(Элемент)
	
	УстановитьВидимостьДоступностьФильтровDomestic(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ФильтрПоNavigationTypeИспользоватьПриИзменении(Элемент)
	
	УстановитьВидимостьДоступностьФильтровDomestic(ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНаСервере()
	
	Запрос = Новый Запрос;
	
	//Соберем Фильтры
	Фильтры = "";
	Если НЕ РольДоступна("ImportExportSpecialist") Тогда
		ТекущийЮзер = ПараметрыСеанса.ТекущийПользователь;
		ДоступныйДляРаботыМассивБоргов = ТекущийЮзер.Borgs.Выгрузить().ВыгрузитьКолонку("Borg");
		
		Если ДоступныйДляРаботыМассивБоргов.Количество() = 0 Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Нет доступных для работы боргов, заполните пожалуйста список в настройках пользователя");
			Возврат;
		Иначе
			Фильтры = Фильтры + "
			|	И Items.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ В(&БоргиДляРаботы)";
			Запрос.УстановитьПараметр("БоргиДляРаботы", ДоступныйДляРаботыМассивБоргов);
		КонецЕсли;
	КонецЕсли;
	
	БоргиИсключения = Новый Массив;
	БоргиИсключения.Добавить(Справочники.BORGs.НайтиПоКоду("ARU2"));
	БоргиИсключения.Добавить(Справочники.BORGs.НайтиПоКоду("ARUF"));
	Запрос.УстановитьПараметр("БоргиИсключения", БоргиИсключения);
	
	Фильтры = Фильтры + "
		|	И НЕ DOCs.GL_FromSegment";
		
	Фильтры = Фильтры + "
		|	И НЕ DOCs.CurrentStage В (&Stages)";
		Stages = Новый Массив;
		Stages.Добавить(Перечисления.DOCStages.Booked);
		Stages.Добавить(Перечисления.DOCStages.Granted);
		Запрос.УстановитьПараметр("Stages", Stages);
	
	Если ФильтрSegmentИспользовать Тогда
		Если ВидСравненияSegment = "Equal" Тогда
			Фильтры = Фильтры + "
			|	И Items.КостЦентр.Segment = &Segment";
		ИначеЕсли ВидСравненияSegment = "Not equal" Тогда
			Фильтры = Фильтры + "
			|	И Items.КостЦентр.Segment <> &Segment";	
		ИначеЕсли ВидСравненияSegment = "In list" Тогда
			Фильтры = Фильтры + "
			|	И Items.КостЦентр.Segment В (&Segment)";	
		ИначеЕсли ВидСравненияSegment = "Not In list" Тогда
			Фильтры = Фильтры + "
			|	И НЕ Items.КостЦентр.Segment В (&Segment)";	
		КонецЕсли;
		Запрос.УстановитьПараметр("Segment", ЗначениеФильтраSegment);
	КонецЕсли;
	
	Если ФильтрSubSegmentИспользовать Тогда
		Если ВидСравненияSubSegment = "Equal" Тогда
			Фильтры = Фильтры + "
			|	И Items.КостЦентр.SubSegment = &SubSegment";
		ИначеЕсли ВидСравненияSubSegment = "Not equal" Тогда
			Фильтры = Фильтры + "
			|	И Items.КостЦентр.SubSegment <> &SubSegment";	
		ИначеЕсли ВидСравненияSubSegment = "In list" Тогда
			Фильтры = Фильтры + "
			|	И Items.КостЦентр.SubSegment В (&SubSegment)";	
		ИначеЕсли ВидСравненияSubSegment = "Not In list" Тогда
			Фильтры = Фильтры + "
			|	И НЕ Items.КостЦентр.SubSegment В (&SubSegment)";	
		КонецЕсли;
		Запрос.УстановитьПараметр("SubSegment", ЗначениеФильтраSubSegment);
	КонецЕсли;
	
	Если ФильтрProcessLevelИспользовать Тогда
		Если ВидСравненияProcessLevel = "Equal" Тогда
			Фильтры = Фильтры + "
			|	И DOCs.ProcessLevel = &ProcessLevel";
		ИначеЕсли ВидСравненияProcessLevel = "Not equal" Тогда
			Фильтры = Фильтры + "
			|	И DOCs.ProcessLevel <> &ProcessLevel";	
		ИначеЕсли ВидСравненияProcessLevel = "In list" Тогда
			Фильтры = Фильтры + "
			|	И DOCs.ProcessLevel В (&ProcessLevel)";	
		ИначеЕсли ВидСравненияProcessLevel = "Not In list" Тогда
			Фильтры = Фильтры + "
			|	И НЕ DOCs.ProcessLevel В (&ProcessLevel)";	
		КонецЕсли;
		Запрос.УстановитьПараметр("ProcessLevel", ЗначениеФильтраProcessLevel);
	КонецЕсли;
	
	Если ФильтрBORGsИспользовать Тогда
		Если ВидСравненияBORGs = "Equal" Тогда
			Фильтры = Фильтры + "
			|	И Items.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ = &BORGs";
		ИначеЕсли ВидСравненияBORGs = "Not equal" Тогда
			Фильтры = Фильтры + "
			|	И Items.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ <> &BORGs";
		ИначеЕсли ВидСравненияBORGs = "In list" Тогда
			Фильтры = Фильтры + "
			|	И Items.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ В (&BORGs)";
		ИначеЕсли ВидСравненияBORGs = "Not In list" Тогда
			Фильтры = Фильтры + "
			|	И Items.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ В (&BORGs)";
		КонецЕсли;
		Запрос.УстановитьПараметр("BORGs", ЗначениеФильтраBORGs);
	КонецЕсли;
	
	Если ФильтрPOИспользовать Тогда
		Если ВидСравненияPO = "Equal" Тогда
			Фильтры = Фильтры + "
			|	И Items.СтрокаЗаявкиНаЗакупку.Владелец = &PO";
		ИначеЕсли ВидСравненияPO = "Not equal" Тогда
			Фильтры = Фильтры + "
			|	И Items.СтрокаЗаявкиНаЗакупку.Владелец <> &PO";
		ИначеЕсли ВидСравненияPO = "In list" Тогда
			Фильтры = Фильтры + "
			|	И Items.СтрокаЗаявкиНаЗакупку.Владелец В (&PO)";
		ИначеЕсли ВидСравненияPO = "Not In list" Тогда
			Фильтры = Фильтры + "
			|	И Items.СтрокаЗаявкиНаЗакупку.Владелец В (&PO)";
		КонецЕсли;
		Запрос.УстановитьПараметр("PO", ЗначениеФильтраPO);
	КонецЕсли;
	
	Если ФильтрPartNoИспользовать Тогда
		Если ВидСравненияPartNo = "Equal" Тогда
			Фильтры = Фильтры + "
			|	И Items.КодПоИнвойсу = &PartNo";
		ИначеЕсли ВидСравненияPartNo = "Not equal" Тогда
			Фильтры = Фильтры + "
			|	И Items.КодПоИнвойсу <> &PartNo";
		ИначеЕсли ВидСравненияPartNo = "In list" Тогда
			Фильтры = Фильтры + "
			|	И Items.КодПоИнвойсу В (&PartNo)";
		ИначеЕсли ВидСравненияPartNo = "Not In list" Тогда
			Фильтры = Фильтры + "
			|	И Items.КодПоИнвойсу В (&PartNo)";
		КонецЕсли;
		Запрос.УстановитьПараметр("PartNo", ЗначениеФильтраPartNo);
	КонецЕсли;
	
	Запрос.Текст = "ВЫБРАТЬ
	|	ЛОЖЬ КАК Флаг,
	|	DOCs.Ссылка КАК Doc,
	|	Items.Ссылка КАК Item,
	|	Items.НомерЗаявкиНаЗакупку КАК PONo,
	|	Items.СтрокаЗаявкиНаЗакупку КАК POLine,
	|	Items.СтрокаЗаявкиНаЗакупку.Владелец.Комментарий КАК RequisitionName,
	|	Items.КодПоИнвойсу КАК PartNo,
	|	Items.НаименованиеТовара КАК DescriptionEng,
	|	Items.Классификатор КАК ERPtreatment,
	|	Items.Сумма КАК TotalPrice,
	|	Items.Currency КАК Currency,
	|	DOCs.Дата КАК DOCDate,
	|	DOCs.CurrentStatus КАК CurrentStatus,
	|	DOCs.GOLD КАК GOLD,
	|	DOCs.RequestedPOA КАК RequestedPOA,
	|	DOCs.MOT,
	|	ВЫБОР
	|		КОГДА Items.Классификатор = ЗНАЧЕНИЕ(Перечисление.ТипыЗаказа.E)
	|			ТОГДА ВЫБОР
	|					КОГДА DOCs.GL_FromSegment = ИСТИНА
	|						ТОГДА ""Yes""
	|					ИНАЧЕ ""No""
	|				КОНЕЦ
	|		ИНАЧЕ ""Not required""
	|	КОНЕЦ КАК GL_FromSegment,
	|	DOCs.CurrentComment КАК CurrentComment,
	|	DOCs.Urgency КАК Urgency,
	|	Items.КостЦентр.Segment КАК Segment,
	|	Items.КостЦентр.SubSegment КАК SubSegment,
	|	DOCs.ProcessLevel,
	|	Items.Количество КАК Quantity,
	|	Items.Цена КАК PricePerUnit
	|ИЗ
	|	Документ.КонсолидированныйПакетЗаявокНаПеревозку КАК DOCs
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК DOCsInvoices
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК Items
	|			ПО DOCsInvoices.Инвойс = Items.Инвойс
	|				И (НЕ Items.ПометкаУдаления)
	|		ПО DOCs.Ссылка = DOCsInvoices.Ссылка
	|ГДЕ
	|	НЕ DOCs.Отменен
	|	И НЕ DOCs.HouseKeeping
	|	И DOCs.ИмпортЭкспорт = ЗНАЧЕНИЕ(Перечисление.ИмпортЭкспорт.Import)
	|	И НЕ Items.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ В(&БоргиИсключения)
	|	//&Фильтры
	|
	|УПОРЯДОЧИТЬ ПО
	|	DOCDate
	|ИТОГИ ПО
	|	Doc ИЕРАРХИЯ";
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&Фильтры", Фильтры);
	
	Дерево = Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией);
	ЗначениеВРеквизитФормы(Дерево, "ApprovalModule");
	
КонецПроцедуры

&НаКлиенте
Процедура Заполнить(Команда)
	ЗаполнитьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьФильрыApproval()
	
	//Элементы.Filters.Видимость = Ложь;
	
	ФильтрGL_FromSegmentИспользовать = Истина;
	ЗначениеФильтраGL_FromSegment = Перечисления.YesNo.No;
	
	СП_GL_FromSegment = Элементы.ВидСравненияGL_FromSegment.СписокВыбора;
	СП_GL_FromSegment.Добавить("Equal", "Equal");
	СП_GL_FromSegment.Добавить("Not equal", "Not equal");
	
	ВидСравненияGL_FromSegment = СП_GL_FromSegment[0].Значение;
	
	ФильтрDocDateИспользовать = Истина;
	DocDateFrom = НачалоМесяца(ТекущаяДата());
	
	СП_Segment = Элементы.ВидСравненияSegment.СписокВыбора;
	СП_Segment.Добавить("In list", "In list");
	СП_Segment.Добавить("Not in list", "Not in list");
	
	ВидСравненияSegment = СП_Segment[0].Значение;
	
	СП_SubSegment = Элементы.ВидСравненияSubSegment.СписокВыбора;
	СП_SubSegment.Добавить("In list", "In list");
	СП_SubSegment.Добавить("Not in list", "Not in list");
	
	ВидСравненияSubSegment = СП_SubSegment[0].Значение;
	
	СП_ProcessLevel = Элементы.ВидСравненияProcessLevel.СписокВыбора;
	СП_ProcessLevel.Добавить("In list", "In list");
	СП_ProcessLevel.Добавить("Not in list", "Not in list");
	
	ВидСравненияProcessLevel = СП_ProcessLevel[0].Значение;
	
	СП_BORGs = Элементы.ВидСравненияBORGs.СписокВыбора;
	СП_BORGs.Добавить("In list", "In list");
	СП_BORGs.Добавить("Not in list", "Not in list");
	
	ВидСравненияBORGs = СП_BORGs[0].Значение;
	
	СП_PartNo = Элементы.ВидСравненияPartNo.СписокВыбора;
	СП_PartNo.Добавить("Equal", "Equal");
	СП_PartNo.Добавить("Not equal", "Not equal");
	
	ВидСравненияPartNo = СП_PartNo[0].Значение;
	
	СП_PO = Элементы.ВидСравненияPO.СписокВыбора;
	СП_PO.Добавить("In list", "In list");
	СП_PO.Добавить("Not in list", "Not in list");
	
	ВидСравненияPO = СП_PO[0].Значение;
	
	СП_POLine = Элементы.ВидСравненияPOLine.СписокВыбора;
	СП_POLine.Добавить("In list", "In list");
	СП_POLine.Добавить("Not in list", "Not in list");
	
	ВидСравненияPOLine = СП_POLine[0].Значение;
	
	СП_PO1 = Элементы.ВидСравненияPO1.СписокВыбора;
	СП_PO1.Добавить("In list", "In list");
	СП_PO1.Добавить("Not in list", "Not in list");
	
	ВидСравненияPO1 = СП_PO1[0].Значение;
	
КонецПроцедуры

&НаКлиенте
Процедура Approve(Команда)
	
	ДопПараметры = Новый Массив;
	
	ВыделенныеСтроки = Элементы.ApprovalModule.ВыделенныеСтроки;
	Если ВыделенныеСтроки.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого Стр Из ВыделенныеСтроки Цикл
		ДанныеСтроки = Элементы.ApprovalModule.ДанныеСтроки(Стр);
		Если ДанныеСтроки.Флаг Тогда
			ДопПараметры.Добавить(ДанныеСтроки.Doc);
		КонецЕсли;
	КонецЦикла;
	
	ОбщаяСумма = ОпределитьОбщуюподтвержденнуюСумму(ДопПараметры);
	
	ПоказатьВопрос(
	Новый ОписаниеОповещения("ApproveDocs", 
	ЭтотОбъект, ДопПараметры),
	"Are you sure you want to approve "+ ОбщаяСумма +" USD for M&S?", 
	РежимДиалогаВопрос.ДаНет,
	60,
	КодВозвратаДиалога.Нет,
	,
	КодВозвратаДиалога.Нет);
	
КонецПроцедуры

&НаСервере
Функция ОпределитьОбщуюподтвержденнуюСумму(DOCs)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	СУММА(КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Инвойс.ОбщаяСумма) КАК ИнвойсОбщаяСумма
	|ИЗ
	|	Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы
	|ГДЕ
	|	КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка В(&DOCs)";
	Запрос.УстановитьПараметр("DOCs", DOCs);
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат 0
	Иначе
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Возврат Выборка.ИнвойсОбщаяСумма
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура ApproveDocs(Результат, Параметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьApprove(Параметры);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьApprove(Параметры)
	
	Документы.КонсолидированныйПакетЗаявокНаПеревозку.УстановитьApprove(Параметры);
	
КонецПроцедуры

&НаКлиенте
Процедура ReRoute(Команда)
	
	ДопПараметры = Новый Массив;
	
	ВыделенныеСтроки = Элементы.ApprovalModule.ВыделенныеСтроки;
	Если ВыделенныеСтроки.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого Стр Из ВыделенныеСтроки Цикл
		ДанныеСтроки = Элементы.ApprovalModule.ДанныеСтроки(Стр);
		ДопПараметры.Добавить(ДанныеСтроки.Doc);
	КонецЦикла;
	
	ПоказатьВопрос(
	Новый ОписаниеОповещения("ReRouteDocs", 
	ЭтотОбъект, ДопПараметры),
	"Сhange status to 'Re-route'?", 
	РежимДиалогаВопрос.ДаНет,
	60,
	КодВозвратаДиалога.Нет,
	,
	КодВозвратаДиалога.Нет);
	
КонецПроцедуры

&НаКлиенте
Процедура ReRouteDocs(Результат, Параметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьReRoute(Параметры);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьReRoute(СписокDoc)
	
	НачатьТранзакцию();
	Для Каждого Элемент Из СписокDoc Цикл
		
		Если НЕ Элемент.ReRoute Тогда
			Док = Элемент.ПолучитьОбъект();
			Док.ReRoute = Истина;
			Попытка
				Док.Записать();
			Исключение
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось установить статус 'Re-route' для DOC - "+Элемент+"!");
			КонецПопытки
		КонецЕсли;
		
	КонецЦикла;
	ЗафиксироватьТранзакцию();
	
КонецПроцедуры

&НаКлиенте
Процедура ShowFilters(Команда)
	
	Если Элементы.Filters.Видимость Тогда
		Элементы.Filters.Видимость = Ложь;
	Иначе
		Элементы.Filters.Видимость = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДеревоРазвернуть(Команда)
	
	КоллекцияЭлементовДерева=ApprovalModule.ПолучитьЭлементы();
	
	Для Каждого Строка Из КоллекцияЭлементовДерева Цикл
		ИдентификаторСтроки = Строка.ПолучитьИдентификатор();
		Элементы.ApprovalModule.Развернуть(ИдентификаторСтроки);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ДеревоСвернуть(Команда)
	
	КоллекцияЭлементовДерева=ApprovalModule.ПолучитьЭлементы();
	
	Для Каждого Строка Из КоллекцияЭлементовДерева Цикл
		ИдентификаторСтроки = Строка.ПолучитьИдентификатор();
		Элементы.ApprovalModule.Свернуть(ИдентификаторСтроки);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура SaveAsExcel(Команда)
	
	Адрес = СформироватьДерево();
	Если Адрес <> Неопределено Тогда
		ИмяФайла = "ApprovalModule " + Формат( ТекущаяДата(), "ДФ = 'гггг-ММ-дд_чч-мм-сс'") + ".xls";
		ПолучитьФайл(Адрес, ИмяФайла);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПечатьДерева(СтрокаДерева, Уровень = 0,Колонки)
	
	Для Каждого стр Из СтрокаДерева.Строки Цикл
		//НомерКолонки = 0;
		отступ = "";
		Для н = 1 По Уровень Цикл
			отступ = отступ + " ";
		КонецЦикла;
		Для Каждого КЛ Из Колонки Цикл
			
			//НомерКолонки = НомерКолонки + 1;
			
			Если КЛ.Имя = "Doc" Тогда
				КолонкаПорядок = 1;
			ИначеЕсли КЛ.Имя = "DOCDate" Тогда
				КолонкаПорядок = 2;
			ИначеЕсли КЛ.Имя = "CurrentStatus" Тогда
				КолонкаПорядок = 3;
			ИначеЕсли КЛ.Имя = "ProcessLevel" Тогда
				КолонкаПорядок = 4;
			ИначеЕсли КЛ.Имя = "GOLD" Тогда
				КолонкаПорядок = 5;
			ИначеЕсли КЛ.Имя = "RequestedPOA" Тогда
				КолонкаПорядок = 6;
			ИначеЕсли КЛ.Имя = "MOT" Тогда
				КолонкаПорядок = 7;
			ИначеЕсли КЛ.Имя = "Urgency" Тогда
				КолонкаПорядок = 8;
			ИначеЕсли КЛ.Имя = "Segment" Тогда
				КолонкаПорядок = 9;
			ИначеЕсли КЛ.Имя = "SubSegment" Тогда
				КолонкаПорядок = 10;
			ИначеЕсли КЛ.Имя = "PONo" Тогда
				КолонкаПорядок = 11;
			ИначеЕсли КЛ.Имя = "POLine" Тогда
				КолонкаПорядок = 12;
			ИначеЕсли КЛ.Имя = "RequisitionName" Тогда
				КолонкаПорядок = 13;
			ИначеЕсли КЛ.Имя = "PartNo" Тогда
				КолонкаПорядок = 14;
			ИначеЕсли КЛ.Имя = "DescriptionEng" Тогда
				КолонкаПорядок = 15;
			ИначеЕсли КЛ.Имя = "ERPtreatment" Тогда
				КолонкаПорядок = 16;
			ИначеЕсли КЛ.Имя = "Quantity" Тогда
				КолонкаПорядок = 17;
			ИначеЕсли КЛ.Имя = "PricePerUnit" Тогда
				КолонкаПорядок = 18;
			ИначеЕсли КЛ.Имя = "TotalPrice" Тогда
				КолонкаПорядок = 19;
			ИначеЕсли КЛ.Имя = "Currency" Тогда
				КолонкаПорядок = 20;
			Иначе
				КолонкаПорядок = 99;
			КонецЕсли;
			
			//Секция.Область(1, НомерКолонки).Текст = ?(НомерКолонки = 1, отступ+стр[КЛ.Имя], стр[КЛ.Имя]);
			Если КолонкаПорядок <> 99 Тогда
				Секция.Область(1, КолонкаПорядок).Текст = ?(КолонкаПорядок = 1, отступ+стр[КЛ.Имя], стр[КЛ.Имя]);
			КонецЕсли;
		КонецЦикла;
		ТабДок.Вывести(Секция,Уровень+1);
		ПечатьДерева(стр,Уровень+1,Колонки);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция СформироватьДерево()
	
	Дерево = ДанныеФормыВЗначение(ApprovalModule, Тип("ДеревоЗначений"));
	ТабДок = Новый ТабличныйДокумент;
	Макет = Обработки.ImportExportTracking.ПолучитьМакет("МакетApproval");
	ОбластьШапки = Макет.ПолучитьОбласть("Шапка");
	ТабДок.Вывести(ОбластьШапки);
	Секция = ТабДок.ПолучитьОбласть("R1");
	ТабДок.НачатьАвтогруппировкуСтрок();
	ПечатьДерева(Дерево,, Дерево.Колонки);
	ТабДок.ЗакончитьАвтогруппировкуСтрок();
	ВременныйКаталог = КаталогВременныхФайлов();
	ИмяФайла = "ApprovalModule " + Формат( ТекущаяДата(), "ДФ = 'гггг-ММ-дд_чч-мм-сс'") + ".xls";
	ИмяВременногоФайла = ВременныйКаталог + ИмяФайла;
	ТабДок.Записать(ИмяВременногоФайла , ТипФайлаТабличногоДокумента.XLS);
	
	Двоичное = Новый ДвоичныеДанные(ИмяВременногоФайла);
	Адрес = ПоместитьВоВременноеХранилище(Двоичное);
	
	Попытка 
		УдалитьФайлы(ИмяВременногоФайла);
	Исключение
	КонецПопытки;
	
	Возврат Адрес;
	
КонецФункции

&НаКлиенте
Процедура DomesticTrackingSaveAsCsvFile(Команда)
	
	МассивИдентификаторовСтрок = ПолучитьИдентификаторыСтрокСоответствующихОтбору(Объект.DomesticTracking, Элементы.DomesticTracking);
	Если МассивИдентификаторовСтрок.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	АдресФайлаВоВременномХранилище = ПолучитьАдресCSVФайлаDomesticTracking(МассивИдентификаторовСтрок);
	ПолучитьФайл(АдресФайлаВоВременномХранилище, "Domestic_tracking.csv");
	
КонецПроцедуры

&НаСервере
Функция ПолучитьАдресCSVФайлаDomesticTracking(МассивИдентификаторовСтрок)
	
	Возврат ПолучитьАдресCSVФайла(Объект.DomesticTracking, МассивИдентификаторовСтрок, Элементы.DomesticTracking, УникальныйИдентификатор);
	
КонецФункции

&НаСервере
Функция ДозаполнитьТаблицуЗатрат(ТаблицаДанных, I_E)
	
	ТаблицаДанных.Колонки.Добавить("FreightCosts");
	ТаблицаДанных.Колонки.Добавить("CustomsClearanceCost");
	ТаблицаДанных.Колонки.Добавить("FreightCostsUSD");
	ТаблицаДанных.Колонки.Добавить("CustomsClearanceCostUSD");
	ТаблицаДанных.Колонки.Добавить("CurrentStatusPendingDays");
	
	УстановитьПривилегированныйРежим(Истина);
	
	Для Каждого Элемент Из ТаблицаДанных Цикл
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	ВложенныйЗапрос.Segment КАК Segment,
		|	ВложенныйЗапрос.AU КАК AU,
		|	ВложенныйЗапрос.InvoiceLine КАК InvoiceLine,
		|	СУММА(ВложенныйЗапрос.ИнвойсПеревозкаФискальная) КАК FreightCosts,
		|	СУММА(ЕСТЬNULL(ВложенныйЗапрос.СборыФискальные, 0) + ЕСТЬNULL(ВложенныйЗапрос.ПошлиныФискальные, 0) + ЕСТЬNULL(ВложенныйЗапрос.ServicesCostsRub, 0)) КАК CustomsClearanceCost
		|ИЗ
		|	(ВЫБРАТЬ
		|		InvoiceLinesCostsОбороты.SoldTo КАК ParentCompany,
		|		InvoiceLinesCostsОбороты.Segment КАК Segment,
		|		InvoiceLinesCostsОбороты.AU КАК AU,
		|		InvoiceLinesCostsОбороты.ERPTreatment КАК ERPTreatment,
		|		InvoiceLinesCostsОбороты.СтрокаИнвойса КАК InvoiceLine,
		|		InvoiceLinesCostsОбороты.СуммаФискальнаяОборот КАК ИнвойсПеревозкаФискальная,
		|		0 КАК СборыФискальные,
		|		0 КАК ПошлиныФискальные,
		|		0 КАК ServicesCostsRub,
		|		InvoiceLinesCostsОбороты.Период КАК CostsAllocationDate
		|	ИЗ
		|		РегистрНакопления.InvoiceLinesCosts.Обороты(
		|				{(&НачалоПериода)},
		|				{(&КонецПериода)},
		|				Регистратор,
		|				ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ИнвойсПеревозка)
		|					//ДопОтбор
		|					И СтрокаИнвойса = &СтрокаИнвойса
		|					И Segment.Код = &Segment
		|					И AU.Код = &AU) КАК InvoiceLinesCostsОбороты
		|	{ГДЕ
		|		InvoiceLinesCostsОбороты.SoldTo.* КАК ParentCompany,
		|		InvoiceLinesCostsОбороты.Segment.*,
		|		InvoiceLinesCostsОбороты.AU.*,
		|		InvoiceLinesCostsОбороты.ERPTreatment.*,
		|		InvoiceLinesCostsОбороты.СтрокаИнвойса.* КАК InvoiceLine}
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		InvoiceLinesCostsОбороты.SoldTo,
		|		InvoiceLinesCostsОбороты.Segment,
		|		InvoiceLinesCostsОбороты.AU,
		|		InvoiceLinesCostsОбороты.ERPTreatment,
		|		InvoiceLinesCostsОбороты.СтрокаИнвойса,
		|		0,
		|		0,
		|		InvoiceLinesCostsОбороты.СуммаФискальнаяОборот,
		|		0,
		|		InvoiceLinesCostsОбороты.Период
		|	ИЗ
		|		РегистрНакопления.InvoiceLinesCosts.Обороты(
		|				,
		|				,
		|				Регистратор,
		|				ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняПошлины)
		|					//ДопОтбор
		|					И СтрокаИнвойса = &СтрокаИнвойса
		|					И Segment.Код = &Segment
		|					И AU.Код = &AU) КАК InvoiceLinesCostsОбороты
		|	{ГДЕ
		|		InvoiceLinesCostsОбороты.SoldTo.* КАК ParentCompany,
		|		InvoiceLinesCostsОбороты.Segment.*,
		|		InvoiceLinesCostsОбороты.AU.*,
		|		InvoiceLinesCostsОбороты.ERPTreatment.*,
		|		InvoiceLinesCostsОбороты.СтрокаИнвойса.* КАК InvoiceLine}
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		InvoiceLinesCostsОбороты.SoldTo,
		|		InvoiceLinesCostsОбороты.Segment,
		|		InvoiceLinesCostsОбороты.AU,
		|		InvoiceLinesCostsОбороты.ERPTreatment,
		|		InvoiceLinesCostsОбороты.СтрокаИнвойса,
		|		0,
		|		InvoiceLinesCostsОбороты.СуммаФискальнаяОборот,
		|		0,
		|		0,
		|		InvoiceLinesCostsОбороты.Период
		|	ИЗ
		|		РегистрНакопления.InvoiceLinesCosts.Обороты(
		|				,
		|				,
		|				Регистратор,
		|				ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняСборы)
		|					//ДопОтбор
		|					И СтрокаИнвойса = &СтрокаИнвойса
		|					И Segment.Код = &Segment
		|					И AU.Код = &AU) КАК InvoiceLinesCostsОбороты
		|	{ГДЕ
		|		InvoiceLinesCostsОбороты.SoldTo.* КАК ParentCompany,
		|		InvoiceLinesCostsОбороты.Segment.*,
		|		InvoiceLinesCostsОбороты.AU.*,
		|		InvoiceLinesCostsОбороты.ERPTreatment.*,
		|		InvoiceLinesCostsОбороты.СтрокаИнвойса.* КАК InvoiceLine}
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		InvoiceLinesCostsОбороты.SoldTo,
		|		InvoiceLinesCostsОбороты.Segment,
		|		InvoiceLinesCostsОбороты.AU,
		|		InvoiceLinesCostsОбороты.ERPTreatment,
		|		InvoiceLinesCostsОбороты.СтрокаИнвойса,
		|		0,
		|		0,
		|		0,
		|		InvoiceLinesCostsОбороты.СуммаФискальнаяОборот,
		|		InvoiceLinesCostsОбороты.Период
		|	ИЗ
		|		РегистрНакопления.InvoiceLinesCosts.Обороты(
		|				,
		|				,
		|				Регистратор,
		|				ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ПрочиеУслуги)
		|					//ДопОтбор
		|					И СтрокаИнвойса = &СтрокаИнвойса
		|					И Segment.Код = &Segment
		|					И AU.Код = &AU) КАК InvoiceLinesCostsОбороты
		|	{ГДЕ
		|		InvoiceLinesCostsОбороты.SoldTo.* КАК ParentCompany,
		|		InvoiceLinesCostsОбороты.Segment.*,
		|		InvoiceLinesCostsОбороты.AU.*,
		|		InvoiceLinesCostsОбороты.ERPTreatment.*,
		|		InvoiceLinesCostsОбороты.СтрокаИнвойса.* КАК InvoiceLine}) КАК ВложенныйЗапрос
		|
		|СГРУППИРОВАТЬ ПО
		|	ВложенныйЗапрос.Segment,
		|	ВложенныйЗапрос.AU,
		|	ВложенныйЗапрос.InvoiceLine";
		Запрос.УстановитьПараметр("СтрокаИнвойса",Элемент.Item);
		Запрос.УстановитьПараметр("Segment", Элемент.SegmentCode);
		Если I_E = "Import" Тогда
			Запрос.УстановитьПараметр("AU", Элемент.AU);
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "//ДопОтбор", " И СтрокаИнвойса.Инвойс <> ЗНАЧЕНИЕ(Документ.Инвойс.ПустаяСсылка) ");
		ИначеЕсли I_E = "Export" Тогда
			Запрос.УстановитьПараметр("AU", Элемент.AUCode);
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "//ДопОтбор", " И СтрокаИнвойса.ExportRequest <> ЗНАЧЕНИЕ(Документ.ExportRequest.ПустаяСсылка) ");
		КонецЕсли;
			
		Результат = Запрос.Выполнить();
		Если НЕ Результат.Пустой() Тогда
			Выборка = Результат.Выбрать();
			Выборка.Следующий();
			Элемент.FreightCosts = Выборка.FreightCosts;
			Элемент.CustomsClearanceCost = Выборка.CustomsClearanceCost;
			Если I_E = "Import" Тогда
				
				CurrencyRUB = CustomsСерверПовтИсп.ПолучитьВалютуПоНаименованию("RUB");
				CurrencyUSD = CustomsСерверПовтИсп.ПолучитьВалютуПоНаименованию("USD");
				
				СтруктураCurrencyRUB = ОбщегоНазначения.ПолучитьКурсВалюты(CurrencyRUB, Элемент.Cleared);
				СтруктураCurrencyUSD = ОбщегоНазначения.ПолучитьКурсВалюты(CurrencyUSD, Элемент.Cleared);
				
				Если ЗначениеЗаполнено(Элемент.FreightCosts) Тогда
					Элемент.FreightCostsUSD = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(Элемент.FreightCosts, CurrencyRUB, CurrencyUSD, СтруктураCurrencyRUB.Курс, СтруктураCurrencyUSD.Курс, СтруктураCurrencyRUB.Кратность, СтруктураCurrencyUSD.Кратность);
				КонецЕсли;
				Если ЗначениеЗаполнено(Элемент.CustomsClearanceCost) Тогда
					Элемент.CustomsClearanceCostUSD = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(Элемент.CustomsClearanceCost, CurrencyRUB, CurrencyUSD, СтруктураCurrencyRUB.Курс, СтруктураCurrencyUSD.Курс, СтруктураCurrencyRUB.Кратность, СтруктураCurrencyUSD.Кратность);
				КонецЕсли;
				
			КонецЕсли
		КонецЕсли;
		// { RGS AArsentev 20.06.2018
		Если I_E = "Import" Тогда
			
			Если ЗначениеЗаполнено(Элемент.DOC) Тогда
				Элемент.CurrentStatusPendingDays = ОпределитьCurrentStatusPendingDays(Элемент.DOC);
			КонецЕсли;
			
		КонецЕсли;
		// } RGS AArsentev 20.06.2018
	КонецЦикла;
	
	УстановитьПривилегированныйРежим(Ложь);
	
	Возврат ТаблицаДанных;
	
КонецФункции


&НаКлиенте
Процедура ImportTrackingMainFilterListНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если Объект.ImportTrackingMainFilter = ImportTrackingFilterByBORG Тогда
		ОписаниеТипа = Новый ОписаниеТипов("СправочникСсылка.BORGS");
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingFilterByCostCenter Тогда
		ОписаниеТипа = Новый ОписаниеТипов("СправочникСсылка.КостЦентры");
	ИначеЕсли Объект.ImportTrackingMainFilter = ImportTrackingFilterByPO Тогда
		ОписаниеТипа = Новый ОписаниеТипов("СправочникСсылка.ЗаявкиНаЗакупку");
	КонецЕсли;
	ЭтаФорма.ImportTrackingMainFilterList.ТипЗначения = ОписаниеТипа;
	
КонецПроцедуры


&НаКлиенте
Процедура ExportTrackingMainFilterListНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если Объект.ExportTrackingMainFilter = ExportTrackingFilterByBORG Тогда
		ОписаниеТипа = Новый ОписаниеТипов("СправочникСсылка.BORGS");
	ИначеЕсли Объект.ExportTrackingMainFilter = ExportTrackingFilterByCostCenter Тогда
		ОписаниеТипа = Новый ОписаниеТипов("СправочникСсылка.КостЦентры");
	КонецЕсли;
	ЭтаФорма.ExportTrackingMainFilterList.ТипЗначения = ОписаниеТипа;
	
КонецПроцедуры


&НаКлиенте
Процедура DomesticTrackingMainFilterListНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если Объект.DomesticTrackingMainFilter = DomesticTrackingFilterByCostCenter Тогда
		ОписаниеТипа = Новый ОписаниеТипов("СправочникСсылка.КостЦентры");
	КонецЕсли;
	ЭтаФорма.DomesticTrackingMainFilterList.ТипЗначения = ОписаниеТипа;
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////////////////
// Страница Technical Description

&НаКлиенте
Процедура CatalogAttachmentsВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ОткрытьФайл();
	
КонецПроцедуры  

&НаКлиенте
Процедура ОткрытьФайл()
	
	ТекущиеДанные = Элементы.CatalogAttachments.ТекущиеДанные;
	                                            		
	ДанныеФайла = ДанныеФайла(ТекущиеДанные.Ссылка, ЭтаФорма.УникальныйИдентификатор);
	         		
	ПрисоединенныеФайлыКлиент.ОткрытьФайл(ДанныеФайла, Ложь);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ДанныеФайла(Знач ПрисоединенныйФайл, Знач ИдентификаторФормы = Неопределено, 
	Знач ПолучатьСсылкуНаДвоичныеДанные = Истина)
	
	Возврат ПрисоединенныеФайлы.ПолучитьДанныеФайла(ПрисоединенныйФайл, ИдентификаторФормы, ПолучатьСсылкуНаДвоичныеДанные);
	
КонецФункции

&НаКлиенте
Процедура CatalogAttachmentsПриАктивизацииСтроки(Элемент)
	
	ОбновитьПредпросмотр();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьПредпросмотр()
	    	
	ТекущиеДанные = Элементы.CatalogAttachments.ТекущиеДанные;
	Если ТекущиеДанные <> Неопределено И РасширенияПоддерживающиеПредпросмотр.НайтиПоЗначению(ТекущиеДанные.Расширение) <> Неопределено Тогда
		ДанныеФайла = ДанныеФайла(ТекущиеДанные.Ссылка, УникальныйИдентификатор);
		АдресДанныхФайла = ДанныеФайла.СсылкаНаДвоичныеДанныеФайла;
	Иначе
		АдресДанныхФайла = Неопределено;
		Элементы.АдресДанныхФайла.ТекстНевыбраннойКартинки = ВернутьСтр("ru = 'Нет данных для предварительного просмотра'");
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура PartNumbersListПриАктивизацииСтроки(Элемент)
	
	ТекДанные = Элементы.PartNumbersList.ТекущиеДанные;
	
	Если ТекДанные <> Неопределено Тогда 
		
		//TDRequests.Параметры.УстановитьЗначениеПараметра("PartNo", ТекДанные.Ссылка);
				
		
		CatalogAttachments.Параметры.УстановитьЗначениеПараметра("ВладелецФайла", ТекДанные.Ссылка);
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура CreateNewRequest(Команда)
	
	ОткрытьФорму("РегистрСведений.TDStatuses.Форма.ФормаЗаписиTD", , ЭтаФорма);	
	
КонецПроцедуры

&НаКлиенте
Процедура ShowShipmentsPendingCustomsBSReceiptDateFilters(Команда)
	
	Элементы.ShowShipmentsPendingCustomsBSReceiptDateFilters.Пометка = НЕ Элементы.ShowShipmentsPendingCustomsBSReceiptDateFilters.Пометка;
	Элементы.КомпоновщикНастроекShipmentsPendingCustomsBSReceiptDateПользовательскиеНастройки.Видимость = Элементы.ShowShipmentsPendingCustomsBSReceiptDateFilters.Пометка;
	
КонецПроцедуры

// { RGS AArsentev 20.06.2018
&НаСервере
Функция ОпределитьCurrentStatusPendingDays(DOC)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	DOCs.Ссылка КАК DOC
	|ИЗ
	|	Документ.КонсолидированныйПакетЗаявокНаПеревозку КАК DOCs
	|ГДЕ
	|	НЕ DOCs.Отменен
	|	И (DOCs.CurrentStage = ЗНАЧЕНИЕ(Перечисление.DocStages.Requested)
	|			ИЛИ DOCs.CurrentStage = ЗНАЧЕНИЕ(Перечисление.DocStages.Opened)
	|			ИЛИ DOCs.CurrentStage = ЗНАЧЕНИЕ(Перечисление.DocStages.PendingTS))
	|	И DOCs.CurrentStatus <> ЗНАЧЕНИЕ(Перечисление.DocStatuses.Disposal)
	|	И НЕ DOCs.HouseKeeping
	|	И DOCs.Ссылка = &DOC";
	Запрос.УстановитьПараметр("DOC",DOC);
	Результат = Запрос.Выполнить().Выбрать();
	Если Результат.Следующий() Тогда
		Возврат РГСофт.КоличествоРабочихДнейДляТекущегоСтатуса(DOC, Истина, КонецДня(ТекущаяДата()));
	Иначе
		Возврат 0
	КонецЕсли;
	
КонецФункции // } RGS AArsentev 20.06.2018

&НаКлиенте
Процедура TDRequestsEMailBodyПриНажатии(Элемент, ДанныеСобытия, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если СтрЧислоВхождений(ДанныеСобытия.Href,"#") = 1 Тогда
		
		МногострочнаяСтрока = СтрЗаменить(ДанныеСобытия.Href, "#",Символы.ПС);
		ПерейтиПоНавигационнойСсылке(СтрПолучитьСтроку(МногострочнаяСтрока,2));
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьВсе(Команда)
	
	Для Каждого Элемент Из ApprovalPOs Цикл
		
		Элемент.Выбран = Истина;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура СнятьВсе(Команда)
	
	Для Каждого Элемент Из ApprovalPOs Цикл
		
		Элемент.Выбран = Ложь;
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура SearchPOНаСервере()
	
	ApprovalPOs.Очистить();
	
	ФильтрPOLine = " ГДЕ
	|	НЕ СтрокиЗаявкиНаЗакупку.ПометкаУдаления";
	
	Запрос = Новый Запрос;
	
	Если ФильтрPOИспользовать Тогда
		Если ВидСравненияPO = "Equal" Тогда
			ФильтрPOLineФильтрPOLine= ФильтрPOLine + "
			|	И СтрокиЗаявкиНаЗакупку.Владелец = &POs";
		ИначеЕсли ВидСравненияPO = "Not equal" Тогда
			ФильтрPOLine = ФильтрPOLine + "
			|	И СтрокиЗаявкиНаЗакупку.Владелец <> &POs";
		ИначеЕсли ВидСравненияPO = "In list" Тогда
			ФильтрPOLine = ФильтрPOLine + "
			|	И СтрокиЗаявкиНаЗакупку.Владелец В (&POs)";
		ИначеЕсли ВидСравненияPO = "Not In list" Тогда
			ФильтрPOLine = ФильтрPOLine + "
			|	И СтрокиЗаявкиНаЗакупку.Владелец В (&POs)";
		КонецЕсли;
		Запрос.УстановитьПараметр("POs", ЗначениеФильтраPO);
	КонецЕсли;
	
	Если ФильтрPOLineИспользовать Тогда
		Если ВидСравненияPO = "Equal" Тогда
			ФильтрPOLine = ФильтрPOLine + "
			|	И СтрокиЗаявкиНаЗакупку.Ссылка = &PO_Lines";
		ИначеЕсли ВидСравненияPO = "Not equal" Тогда
			ФильтрPOLine = ФильтрPOLine + "
			|	И СтрокиЗаявкиНаЗакупку.Ссылка <> &PO_Lines";
		ИначеЕсли ВидСравненияPO = "In list" Тогда
			ФильтрPOLine = ФильтрPOLine + "
			|	И СтрокиЗаявкиНаЗакупку.Ссылка В (&PO_Lines)";
		ИначеЕсли ВидСравненияPO = "Not In list" Тогда
			ФильтрPOLine = ФильтрPOLine + "
			|	И СтрокиЗаявкиНаЗакупку.Ссылка В (&PO_Lines)";
		КонецЕсли;
		Запрос.УстановитьПараметр("PO_Lines", ЗначениеФильтраPOLine);
	КонецЕсли;
	
	Если Не ФильтрPOИспользовать И Не ФильтрPOLineИспользовать Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Select PO or PO line");
	Иначе
		
		Запрос.Текст = "ВЫБРАТЬ
		|	СтрокиЗаявкиНаЗакупку.Владелец КАК PO,
		|	СтрокиЗаявкиНаЗакупку.Ссылка КАК POLine
		|ИЗ
		|	Справочник.СтрокиЗаявкиНаЗакупку КАК СтрокиЗаявкиНаЗакупку
		|	//&ФильтрPOLine";
		
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "//&ФильтрPOLine", ФильтрPOLine);
		
		Результат = Запрос.Выполнить().Выгрузить();
		
		Если Результат.Количество() > 0 Тогда
			
			НайтиДокиПоСтрокам(Результат);
			
			ApprovalPOs.Загрузить(Результат);
			
		Иначе
			//ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Select PO or PO line")
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура SearchPO(Команда)
	SearchPOНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ApproveModuleПриСменеСтраницы(Элемент, ТекущаяСтраница)
	ФильтрPOИспользовать = Ложь;
	ЗначениеФильтраPO.Очистить();
КонецПроцедуры

&НаСервере
Процедура НайтиДокиПоСтрокам(ТаблицаВыборки)
	
	ТаблицаВыборки.Колонки.Добавить("DOCs");
	
	Для Каждого Элемент Из ТаблицаВыборки Цикл
		
		Если ЗначениеЗаполнено(Элемент.POLine) Тогда
			
			Запрос = Новый Запрос;
			Запрос.Текст = "ВЫБРАТЬ
			|	КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка.Номер КАК DOC
			|ИЗ
			|	Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
			|		ПО КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Инвойс = СтрокиИнвойса.Инвойс
			|ГДЕ
			|	СтрокиИнвойса.СтрокаЗаявкиНаЗакупку = &POLine
			|
			|СГРУППИРОВАТЬ ПО
			|	КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка.Номер";
			Запрос.УстановитьПараметр("POLine", Элемент.POLine);
			
			Результат = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("DOC");
			Элемент.DOCs = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(Результат,", ");
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура LoadFromExcelPoLines(Команда)
	
	ТекстВопроса = "Вы действительно хотите загрузить данные из Excel?";
	Ответ = Вопрос(ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Да);
	Если Ответ = КодВозвратаДиалога.Да Тогда
		
		НастройкиДиалога = Новый Структура;
		НастройкиДиалога.Вставить("Фильтр", НСтр("ru = 'Файлы xlsx (*.xlsx)'") + "|*.xlsx" );
		НастройкиДиалога.Вставить("Budgets", ЭтотОбъект);
		
		Оповещение = Новый ОписаниеОповещения("LoadFile", ЭтотОбъект);
		ОбменДаннымиКлиент.ВыбратьИПередатьФайлНаСервер(Оповещение, НастройкиДиалога, Новый УникальныйИдентификатор);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура LoadData(Результат, Параметр) Экспорт 
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	НастройкиДиалога = Новый Структура;
	НастройкиДиалога.Вставить("Фильтр", НСтр("ru = 'Файлы xlsx (*.xlsx)'") + "|*.xlsx" );
	НастройкиДиалога.Вставить("Approve", ЭтотОбъект);
	
	Оповещение = Новый ОписаниеОповещения("LoadFile", ЭтотОбъект);
	ОбменДаннымиКлиент.ВыбратьИПередатьФайлНаСервер(Оповещение, НастройкиДиалога, Новый УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура LoadFile(Знач РезультатПомещенияФайлов, Знач ДополнительныеПараметры) Экспорт
	
	АдресФайла = РезультатПомещенияФайлов.Хранение;
	РасширениеФайла = "xlsx";
	ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла, ДополнительныеПараметры);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла, AP)
	
	ПолноеИмяXLSФайла = ПолучитьИмяВременногоФайла(РасширениеФайла);
	
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
	ДвоичныеДанные.Записать(ПолноеИмяXLSФайла);
	
	ЗагрузитьДанныеИзФайла(ПолноеИмяXLSФайла, AP);
	
	УдалитьФайлы(ПолноеИмяXLSФайла);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьДанныеИзФайла(ПолноеИмяФайла, AP)  
	
	ТекстОшибок = "";
	
	ТаблицаExcel = ПолучитьТаблицуExcel(ТекстОшибок, ПолноеИмяФайла);
	
	Если ПустаяСтрока(ТекстОшибок) Тогда
		ЗагрузитьОбъекты(ТекстОшибок, ТаблицаExcel, AP);
	Иначе
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("" + ТекстОшибок);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТаблицуExcel(ТекстОшибок, ПолноеИмяФайла)
	
	Connection = Новый COMОбъект("ADODB.Connection");
	СтрокаПодключения = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + ПолноеИмяФайла + ";Extended Properties=""Excel 12.0;HDR=No;IMEX=1""";	
	
	Попытка 
		Connection.Open(СтрокаПодключения);	
	Исключение
		Попытка
			СтрокаПодключения = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + ПолноеИмяФайла + ";Extended Properties=""Excel 8.0;HDR=No;IMEX=1""";
			Connection.Open(СтрокаПодключения);
		Исключение
			ТекстОшибок = ТекстОшибок + ОписаниеОшибки();
		КонецПопытки;
	КонецПопытки;
	
	rs = Новый COMObject("ADODB.RecordSet");
	rs.ActiveConnection = Connection;
	rs = Connection.OpenSchema(20);
	
	МассивЛистов = Новый Массив;
	Лист = Неопределено;
	
	Пока rs.EOF() = 0 Цикл
		
		Если ЗначениеЗаполнено(Лист) И СтрНайти(rs.Fields("TABLE_NAME").Value, Лист) > 0 Тогда
			rs.MoveNext();
			Продолжить;
		КонецЕсли;
		
		Лист = rs.Fields("TABLE_NAME").Value;
		МассивЛистов.Добавить(Лист);
		
		rs.MoveNext();
		
	КонецЦикла;  
	
	ТаблицаExcel = Новый ТаблицаЗначений();
	ТаблицаExcel.Колонки.Добавить("НомерСтрокиФайла", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(5, 0)),"НомерСтрокиФайла");
	
	Для Каждого ЛистЭксель из МассивЛистов Цикл 
		
		sqlString = "select * from [" + ЛистЭксель + "]";
		rs.Close();
		rs.Open(sqlString);
		
		rs.MoveFirst();
		
		СвойстваСтруктуры = "PO, Line, DOCNumber";
		
		НомерСтроки = 0;
		Пока rs.EOF = 0 Цикл
			
			НомерСтроки = НомерСтроки + 1;
			
			Если НомерСтроки = 1 Тогда 
				
				СтруктураИменИНомеровКолонок = ПолучитьСтруктуруИменИНомеровКолонок(rs, СвойстваСтруктуры, ТаблицаExcel, ТекстОшибок);
				
				Если Не ПустаяСтрока(ТекстОшибок) Тогда 
					Прервать;
				КонецЕсли;
				
				rs.MoveNext();
				Продолжить;
				
			КонецЕсли;
			
			СтруктураЗначенийСтроки = Новый Структура(СвойстваСтруктуры);
			
			//добавляем значение каждой ячейки файла в структуру значений
			Для Каждого ЭлементСтруктуры из СтруктураИменИНомеровКолонок Цикл 
				
				ЗначениеЯчейки = rs.Fields(ЭлементСтруктуры.Значение-1).Value;
				СтруктураЗначенийСтроки[ЭлементСтруктуры.Ключ] = СокрЛП(ЗначениеЯчейки);
				
			КонецЦикла;     			        						
			
			//добавляем новую структуру и пытаемся заполнить	
			Попытка
				
				НоваяСтрокаТаблицы = ТаблицаExcel.Добавить();
				
				ЗаполнитьЗначенияСвойств(НоваяСтрокаТаблицы, СтруктураЗначенийСтроки, СвойстваСтруктуры);
				
				НоваяСтрокаТаблицы.НомерСтрокиФайла = НомерСтроки;
				
			Исключение
				ТекстОшибок = ТекстОшибок + "
				|не удалось прочитать данные в строке №" + НомерСтроки + "'!";
			КонецПопытки;
			
			rs.MoveNext();
			
		КонецЦикла;
		
		Прервать;
		
	КонецЦикла;
	
	rs.Close();
	Connection.Close();
	
	Возврат ТаблицаExcel;
	
КонецФункции

&НаСервере
Функция ПолучитьСтруктуруИменИНомеровКолонок(rs, СвойстваСтруктуры, ТаблицаExcel, ТекстОшибок)
	
	СтруктураКолонокИИндексов = Новый Структура(СвойстваСтруктуры);
	
	НомерКолонки = 1;
	Для Каждого Field из rs.Fields Цикл 
		
		ТекстЯчейки = СокрЛП(Field.Value);
		Если НЕ ЗначениеЗаполнено(ТекстЯчейки) Тогда
			Прервать;
		КонецЕсли;
		
		Если ТекстЯчейки = "PO Number" Тогда
			СтруктураКолонокИИндексов.PO = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "PO Line" Тогда
			СтруктураКолонокИИндексов.Line = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "DOC Number" Тогда
			СтруктураКолонокИИндексов.DOCNumber = НомерКолонки;
		КонецЕсли;
		
		НомерКолонки = НомерКолонки + 1;
		
	КонецЦикла; 
	
	Для Каждого КлючИЗначение Из СтруктураКолонокИИндексов Цикл
		
		Если КлючИЗначение.Значение = Неопределено Тогда
			ТекстОшибок = ТекстОшибок + "
			|необходимо проверить наличие колонки с данными '" + СтрЗаменить(КлючИЗначение.Ключ, "_", " ") + "'!";
		иначе
			ТаблицаExcel.Колонки.Добавить(КлючИЗначение.Ключ,,КлючИЗначение.Ключ);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СтруктураКолонокИИндексов;
	
КонецФункции

&НаСервере	
Процедура ЗагрузитьОбъекты(ТекстОшибок, ТаблицаExcel, AP) 
	
	ApprovalPOs.Очистить();
	ApproveDOCs.Очистить();
	
	ТаблицаApprovePOLines = Новый ТаблицаЗначений;
	ТаблицаApprovePOLines.Колонки.Добавить("PO");
	ТаблицаApprovePOLines.Колонки.Добавить("POLine");
	
	Для Каждого Элемент Из ТаблицаExcel Цикл
		
		Если ЗначениеЗаполнено(Элемент.PO) И ЗначениеЗаполнено(Элемент.Line) Тогда
			
			Запрос = Новый Запрос;
			Запрос.Текст = "ВЫБРАТЬ
			|	СтрокиЗаявкиНаЗакупку.Владелец КАК PO,
			|	СтрокиЗаявкиНаЗакупку.Ссылка КАК POLine
			|ИЗ
			|	Справочник.СтрокиЗаявкиНаЗакупку КАК СтрокиЗаявкиНаЗакупку
			|ГДЕ
			|	СтрокиЗаявкиНаЗакупку.НомерСтрокиЗаявкиНаЗакупку = &НомерСтрокиЗаявкиНаЗакупку
			|	И СтрокиЗаявкиНаЗакупку.Владелец.Код = &Код";
			Запрос.УстановитьПараметр("Код", Элемент.PO);
			Запрос.УстановитьПараметр("НомерСтрокиЗаявкиНаЗакупку", Число(Элемент.Line));
			Результат = Запрос.Выполнить().Выбрать();
			
			Если Результат.Следующий() Тогда
				СтрокаТаблицы = ТаблицаApprovePOLines.Добавить();
				СтрокаТаблицы.PO = Результат.PO;
				СтрокаТаблицы.POLine = Результат.POLine;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
		
	ЗапросDOCs = Новый Запрос;
	ЗапросDOCs.Текст = "ВЫБРАТЬ
	|	КонсолидированныйПакетЗаявокНаПеревозку.Ссылка КАК DOC
	|ИЗ
	|	Документ.КонсолидированныйПакетЗаявокНаПеревозку КАК КонсолидированныйПакетЗаявокНаПеревозку
	|ГДЕ
	|	КонсолидированныйПакетЗаявокНаПеревозку.Номер В(&DOC_Numbers)";
	ЗапросDOCs.УстановитьПараметр("DOC_Numbers", РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаExcel, "DOCNumber"));
	
	РезультатDOCs = ЗапросDOCs.Выполнить().Выгрузить();
	Если РезультатDOCs.Количество() > 0 Тогда
		ApproveDOCs.Загрузить(РезультатDOCs);
	КонецЕсли;
	
	Если ТаблицаApprovePOLines.Количество() > 0 Тогда
		НайтиДокиПоСтрокам(ТаблицаApprovePOLines);
		ApprovalPOs.Загрузить(ТаблицаApprovePOLines);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ШаблонExcelPoLines(Команда)
	
	Адрес = ПолучитьАдрес();
	ИмяФайла = "Exemption Request Template.xlsx";
	ПолучитьФайл(Адрес, ИмяФайла);

КонецПроцедуры

&НаСервере
Функция ПолучитьАдрес()
	
	Возврат ПоместитьВоВременноеХранилище(Обработки.ImportExportTracking.ПолучитьМакет("ШаблонЗагрузкиPOLines"));
	
КонецФункции

&НаКлиенте
Процедура ApprovePO(Команда)
	
	Для Каждого Строка Из ApprovalPOs Цикл
		
		Если Строка.Выбран Тогда
			Если Не ОбщегоНазначения.ПолучитьЗначениеРеквизита(Строка.PoLine, "GL_From_Segment") Тогда
				ТекстСообщения = ПроставитьGL_в_DOCs(Строка.POLine);
				ОповеститьОбИзменении(Строка.POLine);
				Если ЗначениеЗаполнено(ТекстСообщения) Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
				КонецЕсли;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ПроставитьGL_в_DOCs(POLine)
	
	НачатьТранзакцию();
	
	УстановитьПривилегированныйРежим(Истина);
	
	Line = PoLine.ПолучитьОбъект();
	Line.GL_From_Segment = Истина;
	Line.GL_Date = ТекущаяДата();
	
	Попытка
		Line.Записать();
	Исключение
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось проставить GL в PO line " + POLine);
	КонецПопытки;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка КАК DOC_ссылка
	               |ПОМЕСТИТЬ вDOC
	               |ИЗ
	               |	Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
	               |		ПО КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Инвойс = СтрокиИнвойса.Инвойс
	               |ГДЕ
	               |	СтрокиИнвойса.СтрокаЗаявкиНаЗакупку.Ссылка = &Ссылка
	               |	И СтрокиИнвойса.Классификатор = ЗНАЧЕНИЕ(Перечисление.ТипыЗаказа.E)
	               |	И КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка.Дата МЕЖДУ &ДатаНачалаДействия И &ДатаОкончанияДействия
	               |	И КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка.CurrentStatus = ЗНАЧЕНИЕ(Перечисление.DOCStatuses.PendingApprovalFromSegment)
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	вDOC.DOC_ссылка,
	               |	МИНИМУМ(вDOC.DOC_ссылка.GL_FromSegment) КАК DOC_GL,
	               |	МИНИМУМ(КонсолидированныйПакетЗаявокНаПеревозкуApprovalBorgs.Approve) КАК ApprovalBorgs,
	               |	МИНИМУМ(СтрокиИнвойса.СтрокаЗаявкиНаЗакупку.GL_From_Segment) КАК Проверка
	               |ИЗ
	               |	вDOC КАК вDOC
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.ApprovalBorgs КАК КонсолидированныйПакетЗаявокНаПеревозкуApprovalBorgs
	               |		ПО вDOC.DOC_ссылка = КонсолидированныйПакетЗаявокНаПеревозкуApprovalBorgs.Ссылка
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы
	               |			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
	               |			ПО КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Инвойс = СтрокиИнвойса.Инвойс
	               |				И (СтрокиИнвойса.Классификатор = ЗНАЧЕНИЕ(Перечисление.ТипыЗаказа.E))
	               |		ПО вDOC.DOC_ссылка = КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	вDOC.DOC_ссылка";
	Запрос.УстановитьПараметр("Ссылка", POLine);	
	// { RGS EParshina 21.09.2018 15:21:50 S-I-0005913
	//Запрос.УстановитьПараметр("ДатаНачалаДействия", Дата("25.07.2018 00:00:00"));
	Запрос.УстановитьПараметр("ДатаНачалаДействия", ФильтрПоПериодуДляApprovePOs.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончанияДействия", ?(ЗначениеЗаполнено(ФильтрПоПериодуДляApprovePOs.ДатаОкончания),ФильтрПоПериодуДляApprovePOs.ДатаОкончания,ТекущаяДата()));
	// } RGS RGS EParshina 21.09.2018 15:21:53 S-I-0005913
		
	Результат = Запрос.Выполнить().Выбрать();
	ТекстСообщения = "";
	Пока Результат.Следующий() Цикл
		
		Если Результат.Проверка И (Не Результат.ApprovalBorgs Или Не Результат.DOC_GL)  Тогда
			
			Док = Результат.DOC_ссылка.ПолучитьОбъект();
			Док.GL_FromSegment = Истина;			
			Для Каждого СтрокаApprovalBorgs из Док.ApprovalBorgs Цикл
				СтрокаApprovalBorgs.Approve = Истина;
			КонецЦикла;
						
			Попытка
				Док.Записать();
				ТекстСообщения =  ТекстСообщения + ?(ЗначениеЗаполнено(ТекстСообщения),"
				|" , "Changed " + ?(Не Результат.DOC_GL,"'GL from segment'","") + ?(Не Результат.DOC_GL и Не Результат.ApprovalBorgs,", ","") + ?(Не Результат.ApprovalBorgs,"'Approved Borgs'","") + "  in " + Док);
			Исключение
				ТекстСообщения =  ТекстСообщения + ?(ЗначениеЗаполнено(ТекстСообщения),"
				|" , "Not changed " + ?(Не Результат.DOC_GL,"'GL from segment'","") + ?(Не Результат.DOC_GL и Не Результат.ApprovalBorgs,", ","") + ?(Не Результат.ApprovalBorgs,"'Approved Borgs'","") + "  in " + Док);
			КонецПопытки;
		КонецЕсли;
		
	КонецЦикла;
	
	УстановитьПривилегированныйРежим(Ложь);
	
	ЗафиксироватьТранзакцию();
	
	Возврат ТекстСообщения;
	
КонецФункции

Функция ПроверитьGLПоСтрокам(DOC)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ЕСТЬNULL(СтрокиИнвойса.СтрокаЗаявкиНаЗакупку.GL_From_Segment, ЛОЖЬ) КАК GL,
	|	СтрокиИнвойса.СтрокаЗаявкиНаЗакупку КАК PoLine
	|ИЗ
	|	Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
	|		ПО КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Инвойс = СтрокиИнвойса.Инвойс
	|ГДЕ
	|	СтрокиИнвойса.Классификатор = ЗНАЧЕНИЕ(Перечисление.ТипыЗаказа.E)
	|	И КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка = &DOC";
	Запрос.УстановитьПараметр("DOC", DOC);
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат Ложь;
	Иначе
		Выборка = Результат.Выбрать();
		Пока Выборка.Следующий() Цикл
			Если Не Выборка.GL Тогда
				Возврат Ложь;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		Возврат Истина;
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура ВыбратьВсеApproveDOCs(Команда)
	
	Для Каждого Элемент Из ApproveDOCs Цикл
		
		Элемент.Выбран = Истина;
		
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура СнятьВсеApproveDOCs(Команда)
	
	Для Каждого Элемент Из ApproveDOCs Цикл
		
		Элемент.Выбран = Ложь;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ApproveDOC(Команда)
	
	Для Каждого Строка Из ApproveDOCs Цикл
		
		Если Строка.Выбран Тогда
			Если Не ОбщегоНазначения.ПолучитьЗначениеРеквизита(Строка.DOC, "GL_FromSegment") Тогда
				ТекстСообщения = ПроставитьGL(Строка.DOC);
				ОповеститьОбИзменении(Строка.DOC);
				Если ЗначениеЗаполнено(ТекстСообщения) Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
				КонецЕсли;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ПроставитьGL(DOC)
	
	НачатьТранзакцию();
	
	Док = DOC.ПолучитьОбъект();
	Док.GL_FromSegment = Истина;
	
	Попытка
		Док.Записать();
		ТекстСообщения = ?(ЗначениеЗаполнено(ТекстСообщения), ТекстСообщения + "
		|Changed 'GL from segment' in " + Док,
		"Changed 'GL from segment' in " + Док);
	Исключение
		ТекстСообщения = ?(ЗначениеЗаполнено(ТекстСообщения), ТекстСообщения + "
		|Not changed 'GL from segment' in " + Док,
		"Not changed 'GL from segment' in " + Док);
	КонецПопытки;
	
	ЗафиксироватьТранзакцию();
	
КонецФункции

// { RGS DKazanskiy 12.12.2018 14:59:35 - S-I-0006451
&НаКлиенте
Процедура PoLineRestock(Команда)
	Для Каждого Строка Из ApprovalPOs Цикл
		
		Если Строка.Выбран Тогда
			Если Не ОбщегоНазначения.ПолучитьЗначениеРеквизита(Строка.PoLine, "Restock") Тогда
				ИзменитьРесток(Строка.PoLine, Истина);
				ОповеститьОбИзменении(Строка.POLine);
			КонецЕсли;			
		КонецЕсли;
		
	КонецЦикла;
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ИзменитьРесток(PoLine, Restock)
	НачатьТранзакцию();
	
	УстановитьПривилегированныйРежим(Истина);
	
	Line = PoLine.ПолучитьОбъект();
	Line.Restock 		= Restock;
	Line.Restock_Date 	= ТекущаяДата();
	
	Попытка
		Line.Записать();
		ЗафиксироватьТранзакцию();
		
		Документы.КонсолидированныйПакетЗаявокНаПеревозку.ОбновитьСтатусПоPOLineRestock(PoLine, Restock);
		
	Исключение
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось проставить Restock в PO line " + POLine);
		ОтменитьТранзакцию();
	КонецПопытки;	
КонецПроцедуры
// } RGS DKazanskiy 12.12.2018 14:59:37 - S-I-0006451




