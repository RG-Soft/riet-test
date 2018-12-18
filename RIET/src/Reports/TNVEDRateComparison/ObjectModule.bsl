
Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	// Преобразуем Rate Кодов
	
	TNVEDCodes = Новый ТаблицаЗначений;
	TNVEDCodes.Колонки.Добавить("TNVED", Новый ОписаниеТипов("СправочникСсылка.TNVEDCodes"));
	TNVEDCodes.Колонки.Добавить("TNVEDRate", Новый ОписаниеТипов("Число", , , Новый КвалификаторыЧисла(5,1)));
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	TNVEDCodes.Ссылка КАК TNVED,
		|	TNVEDCodes.Rate КАК TNVEDRate
		|ИЗ
		|	Справочник.TNVEDCodes КАК TNVEDCodes
		|ГДЕ
		|	НЕ TNVEDCodes.Rate = """"";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		СтрокаН = TNVEDCodes.Добавить();
		СтрокаН.TNVED = Выборка.TNVED;
		СтрокаН.TNVEDRate = ImportExportСерверПовтИспВызов.ПреобразоватьЧислоВСтроку(Выборка.TNVEDRate);
		
	КонецЦикла;
	
	TNVEDCodesRate = TNVEDCodes.Скопировать(,"TNVEDRate");
	TNVEDCodesRate.Свернуть("TNVEDRate");
	TNVEDCodesRate.Сортировать("TNVEDRate");
	
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.Текст = 
	
	"ВЫБРАТЬ
	|	Catalog.Код КАК Код,
	|	Catalog.Ссылка КАК Ссылка
	|ПОМЕСТИТЬ Catalogs
	|ИЗ
	|	Справочник.Catalog КАК Catalog
	|	
	|	//%ОтборListPartNo%
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	TNVEDCodes.TNVED,
	|	TNVEDCodes.TNVEDRate
	|ПОМЕСТИТЬ TNVEDCodes
	|ИЗ
	|	&TNVEDCodes КАК TNVEDCodes
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВложенныйЗапрос.InvoiceLine КАК InvoiceLine,
	|	ВложенныйЗапрос.Segment КАК Segment
	|ПОМЕСТИТЬ InvoiceLinesCostsОбороты
	|ИЗ
	|	(ВЫБРАТЬ
	|		InvoiceLinesCostsОбороты.Segment КАК Segment,
	|		InvoiceLinesCostsОбороты.СтрокаИнвойса КАК InvoiceLine
	|	ИЗ
	|		РегистрНакопления.InvoiceLinesCosts.Обороты(
	|				&НачалоПериода,
	|				&КонецПериода,
	|				,
	|				ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ИнвойсПеревозка)
	|					И СтрокаИнвойса.Инвойс <> ЗНАЧЕНИЕ(Документ.Инвойс.ПустаяСсылка)
	|					И СтрокаИнвойса.КодПоИнвойсу В
	|						(ВЫБРАТЬ
	|							Catalogs.Код
	|						ИЗ
	|							Catalogs КАК Catalogs)
	|						И СтрокаИнвойса.Инвойс В
	|	(ВЫБРАТЬ
	|		КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Инвойс
	|	ИЗ
	|		Документ.Поставка.УпаковочныеЛисты КАК ПоставкаУпаковочныеЛисты
	|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы
	|			ПО
	|				ПоставкаУпаковочныеЛисты.УпаковочныйЛист = КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка
	|	ГДЕ
	|		ПоставкаУпаковочныеЛисты.Ссылка.Cleared >= &Cleared))
	|					КАК InvoiceLinesCostsОбороты) КАК ВложенныйЗапрос
	|СГРУППИРОВАТЬ ПО
	|	ВложенныйЗапрос.InvoiceLine,
	|	ВложенныйЗапрос.Segment
	|ИНДЕКСИРОВАТЬ ПО
	|	InvoiceLine
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	CustomsFilesOfGoods.CustomsFile.CCA КАК CCA,
	|	InvoiceLinesCostsОбороты.Segment КАК Segment,
	|	InvoiceLinesCostsОбороты.InvoiceLine.СтрокаЗаявкиНаЗакупку КАК POLine,
	|	InvoiceLinesCostsОбороты.InvoiceLine.Инвойс КАК Invoice,
	|	InvoiceLinesCostsОбороты.InvoiceLine КАК InvoiceLine,
	|	CustomsFilesOfGoods.CustomsFile КАК CCD
	|ПОМЕСТИТЬ ВТ
	|ИЗ
	|	InvoiceLinesCostsОбороты КАК InvoiceLinesCostsОбороты
	|		{ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.CustomsFilesOfGoods КАК CustomsFilesOfGoods
	|		ПО InvoiceLinesCostsОбороты.InvoiceLine = CustomsFilesOfGoods.Item}
	|СГРУППИРОВАТЬ ПО
	|	InvoiceLinesCostsОбороты.InvoiceLine,
	|	CustomsFilesOfGoods.CustomsFile,
	|	InvoiceLinesCostsОбороты.InvoiceLine.Инвойс,
	|	InvoiceLinesCostsОбороты.InvoiceLine.СтрокаЗаявкиНаЗакупку,
	|	CustomsFilesOfGoods.CustomsFile.CCA,
	|	InvoiceLinesCostsОбороты.Segment
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВТ.CCA КАК CCA,
	|	ВТ.Segment КАК Segment,
	|	ВТ.CCD.CustomsPost КАК CustomsPost,
	|	ВТ.POLine КАК POLine,
	|	ВТ.InvoiceLine КАК InvoiceLine,
	|	ВТ.Invoice КАК Invoice,
	|	ВТ.InvoiceLine.КодПоИнвойсу КАК PartNo,
	|	ВТ.CCD КАК CCD,
	|	СтрокиГТД.ТНВЭД КАК TNVED,
	|	TNVEDCodes.TNVEDRate КАК TNVEDRate,
	|	СтрокиГТД.Ссылка КАК CCDLine
	|ПОМЕСТИТЬ TNVEDHistoryП
	|ИЗ
	|	ВТ КАК ВТ
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтрокиГТД КАК СтрокиГТД
	|			ЛЕВОЕ СОЕДИНЕНИЕ TNVEDCodes КАК TNVEDCodes
	|			ПО СтрокиГТД.ТНВЭД = TNVEDCodes.TNVED
	|		ПО ВТ.CCD = СтрокиГТД.ГТД
	|
	|	//%ОтборTNVEDRate%
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	TNVEDHistoryП.CCA КАК CCA,
	|	TNVEDHistoryП.Segment КАК Segment,
	|	TNVEDHistoryП.CustomsPost КАК CustomsPost,
	|	TNVEDHistoryП.POLine КАК POLine,
	|	TNVEDHistoryП.InvoiceLine КАК InvoiceLine,
	|	TNVEDHistoryП.Invoice КАК Invoice,
	|	TNVEDHistoryП.PartNo КАК PartNo,
	|	TNVEDHistoryП.CCD КАК CCD,
	|	TNVEDHistoryП.TNVED КАК TNVED,
	|	TNVEDHistoryП.TNVEDRate КАК TNVEDRate,
	|	TNVEDHistoryП.CCDLine КАК CCDLine,
	|	ТоварыСтрокГТД.МаркировкаТовара КАК МаркировкаТовара
	|ПОМЕСТИТЬ TNVEDHistory
	|ИЗ
	|	TNVEDHistoryП КАК TNVEDHistoryП
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ТоварыСтрокГТД КАК ТоварыСтрокГТД
	|		ПО (TNVEDHistoryП.CCDLine = ТоварыСтрокГТД.Владелец)
	|			И (ТоварыСтрокГТД.МаркировкаТовара ПОДОБНО ""%"" + TNVEDHistoryП.PartNo + ""%"")
	|СГРУППИРОВАТЬ ПО
	|	TNVEDHistoryП.CCA,
	|	TNVEDHistoryП.Segment,
	|	TNVEDHistoryП.CustomsPost,
	|	TNVEDHistoryП.POLine,
	|	TNVEDHistoryП.InvoiceLine,
	|	TNVEDHistoryП.Invoice,
	|	TNVEDHistoryП.PartNo,
	|	TNVEDHistoryП.CCD,
	|	TNVEDHistoryП.TNVED,
	|	TNVEDHistoryП.TNVEDRate,
	|	TNVEDHistoryП.CCDLine,
	|	ТоварыСтрокГТД.МаркировкаТовара
	|ИНДЕКСИРОВАТЬ ПО
	|	PartNo
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	TNVEDTable.PartNo КАК PartNo,
	|	TNVEDTable.TNVED КАК TNVED,
	|	TNVEDTable.TNVEDRate КАК TNVEDRate
	|ПОМЕСТИТЬ TNVEDMinRatePartNo
	|ИЗ
	|	TNVEDHistory КАК TNVEDTable
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	TNVEDMinRatePartNo.PartNo КАК PartNo,
	|	TNVEDMinRatePartNo.TNVED КАК TNVED,
	|	КОЛИЧЕСТВО(TNVEDMinRatePartNo.TNVEDRate) КАК Количество
	|ПОМЕСТИТЬ TNVEDКоличество
	|ИЗ
	|	TNVEDMinRatePartNo КАК TNVEDMinRatePartNo
	|СГРУППИРОВАТЬ ПО
	|	TNVEDMinRatePartNo.PartNo,
	|	TNVEDMinRatePartNo.TNVED
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	TNVEDMinRatePartNo.PartNo КАК PartNo,
	|	TNVEDMinRatePartNo.TNVED КАК TNVED,
	|	TNVEDMinRatePartNo.TNVEDRate КАК TNVEDRate,
	|	TNVEDКоличество.Количество КАК Количество
	|ПОМЕСТИТЬ TNVEDMinRateTOTAL
	|ИЗ
	|	TNVEDMinRatePartNo КАК TNVEDMinRatePartNo
	|		ЛЕВОЕ СОЕДИНЕНИЕ TNVEDКоличество КАК TNVEDКоличество
	|		ПО TNVEDMinRatePartNo.PartNo = TNVEDКоличество.PartNo
	|			И TNVEDMinRatePartNo.TNVED = TNVEDКоличество.TNVED
	|СГРУППИРОВАТЬ ПО
	|	TNVEDMinRatePartNo.TNVED,
	|	TNVEDMinRatePartNo.PartNo,
	|	TNVEDMinRatePartNo.TNVEDRate,
	|	TNVEDКоличество.Количество
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	TNVEDMinRateTOTAL.PartNo КАК PartNo,
	|	МИНИМУМ(TNVEDMinRateTOTAL.TNVEDRate) КАК TNVEDRateMIN
	|ПОМЕСТИТЬ TNVEDMIN
	|ИЗ
	|	TNVEDMinRateTOTAL КАК TNVEDMinRateTOTAL
	|СГРУППИРОВАТЬ ПО
	|	TNVEDMinRateTOTAL.PartNo
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	TNVEDMinRateTOTAL.TNVED КАК TNVED,
	|	TNVEDMinRateTOTAL.PartNo КАК PartNo,
	|	TNVEDMinRateTOTAL.TNVEDRate КАК TNVEDRate,
	|	МАКСИМУМ(TNVEDMinRateTOTAL.Количество) КАК Количество
	|ПОМЕСТИТЬ TOTAL
	|ИЗ
	|	TNVEDMinRateTOTAL КАК TNVEDMinRateTOTAL
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ TNVEDMIN КАК TNVEDMIN
	|		ПО TNVEDMinRateTOTAL.TNVEDRate = TNVEDMIN.TNVEDRateMIN
	|СГРУППИРОВАТЬ ПО
	|	TNVEDMinRateTOTAL.TNVED,
	|	TNVEDMinRateTOTAL.PartNo,
	|	TNVEDMinRateTOTAL.TNVEDRate
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	TOTAL.PartNo КАК PartNo,
	|	TOTAL.TNVEDRate КАК TNVEDRate,
	|	МАКСИМУМ(TOTAL.Количество) КАК Количество
	|ПОМЕСТИТЬ TOTALMAX
	|ИЗ
	|	TOTAL КАК TOTAL
	|СГРУППИРОВАТЬ ПО
	|	TOTAL.PartNo,
	|	TOTAL.TNVEDRate
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	МАКСИМУМ(TOTAL.TNVED) КАК TNVED,
	|	TOTAL.PartNo КАК PartNo,
	|	TOTAL.TNVEDRate КАК TNVEDRate
	|ПОМЕСТИТЬ TNVEDMinRate
	|ИЗ
	|	TOTALMAX КАК TOTALMAX
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ TOTAL КАК TOTAL
	|		ПО TOTALMAX.PartNo = TOTAL.PartNo
	|			И (TOTAL.Количество = TOTALMAX.Количество)
	|СГРУППИРОВАТЬ ПО
	|	TOTAL.PartNo,
	|	TOTAL.TNVEDRate
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	TNVEDMinRate.TNVED КАК TNVED,
	|	TNVEDMinRate.PartNo КАК PartNo,
	|	TNVEDMinRate.TNVEDRate КАК TNVEDRate
	|ПОМЕСТИТЬ TNVEDMinRateFINAL
	|ИЗ
	|	TNVEDMinRate КАК TNVEDMinRate
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ TNVEDMIN КАК TNVEDMIN
	|		ПО (TNVEDMIN.PartNo = TNVEDMinRate.PartNo)
	|			И (TNVEDMIN.TNVEDRateMIN = TNVEDMinRate.TNVEDRate)
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	TNVEDHistory.CCA КАК CCA,
	|	TNVEDHistory.Segment КАК Segment,
	|	TNVEDHistory.CustomsPost КАК CustomsPost,
	|	TNVEDHistory.POLine КАК POLine,
	|	TNVEDHistory.InvoiceLine КАК InvoiceLine,
	|	TNVEDHistory.Invoice КАК Invoice,
	|	TNVEDHistory.CCD КАК CCD,
	|	TNVEDHistory.CCDLine КАК CCDLine,
	|	Catalog.Ссылка КАК Catalog,
	|	TNVEDMinRateFINAL.PartNo КАК PartNo,
	|	TNVEDHistory.TNVED КАК TNVEDImported,
	|	TNVEDHistory.TNVEDRate КАК TNVEDImportedRate,
	|	TNVEDMinRateFINAL.TNVED КАК TNVEDPreferable,
	|	TNVEDMinRateFINAL.TNVEDRate КАК TNVEDPreferableRate,
	|	СтрокиИнвойса.Сумма КАК LineItemTotalPrice,
	|	TNVEDHistory.TNVEDRate - TNVEDMinRateFINAL.TNVEDRate КАК DeltaRate,
	|	СтрокиИнвойса.Сумма * (TNVEDHistory.TNVEDRate - TNVEDMinRateFINAL.TNVEDRate) / 100 КАК TotalOverpayment,
	|	СтрокиИнвойса.Классификатор КАК ERP_Treatment
	|
	|ИЗ
	|	TNVEDMinRateFINAL КАК TNVEDMinRateFINAL
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ TNVEDHistory КАК TNVEDHistory
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
	|			ПО (СтрокиИнвойса.Инвойс = TNVEDHistory.Invoice)
	|				И (СтрокиИнвойса.Ссылка = TNVEDHistory.InvoiceLine)
	|		ПО TNVEDMinRateFINAL.PartNo = TNVEDHistory.PartNo
	|			И (НЕ TNVEDMinRateFINAL.TNVED = TNVEDHistory.TNVED)
	|			И (НЕ TNVEDMinRateFINAL.TNVEDRate = TNVEDHistory.TNVEDRate)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Catalog КАК Catalog
	|		ПО TNVEDMinRateFINAL.PartNo = Catalog.Код";
	
	Запрос.УстановитьПараметр("TNVEDCodes", TNVEDCodes);
	Запрос.УстановитьПараметр("Cleared", Дата("01.01.2017 00:00:00"));
	
	ПользовательскиеНастройки = ЭтотОбъект.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы;
	
	Для каждого Настройка Из ПользовательскиеНастройки Цикл
		
		Если Настройка.Использование И ТипЗнч(Настройка) = Тип("ЭлементОтбораКомпоновкиДанных") И Настройка.ВидСравнения = ВидСравненияКомпоновкиДанных.ВСписке Тогда
			
			СписокPartNo =  Настройка.ПравоеЗначение;
			
			УсловиеОтбора =
			"ГДЕ
			|	(Catalog.Ссылка В (&ListPartNo))";
			
			Запрос.Текст = СтрЗаменить(Запрос.Текст,"//%ОтборListPartNo%", УсловиеОтбора);
			Запрос.УстановитьПараметр("ListPartNo" , СписокPartNo);
			
			
		ИначеЕсли Настройка.Использование И ТипЗнч(Настройка.Значение) = ТИП("СтандартныйПериод") Тогда
			
			Запрос.Текст = СтрЗаменить(Запрос.Текст,"//%НачалоПериода%", "&НачалоПериода");
			Запрос.Текст = СтрЗаменить(Запрос.Текст,"//%КонецПериода%", "&КонецПериода");
			
			Запрос.УстановитьПараметр("НачалоПериода", Настройка.Значение.ДатаНачала);
			Запрос.УстановитьПараметр("КонецПериода", Настройка.Значение.ДатаОкончания);
			
		ИначеЕсли Настройка.Использование И ТипЗнч(Настройка.Значение) = Истина Тогда
			
			ОтборTNVEDRate =
			"ГДЕ
			|	НЕ TNVEDCodes.TNVEDRate = """"";
			
			Запрос.Текст = СтрЗаменить(Запрос.Текст,"//%ОтборTNVEDRate%", ОтборTNVEDRate);
			Запрос.УстановитьПараметр("ListPartNo" , СписокPartNo);
			
		КонецЕсли;
		
	КонецЦикла;
	
	
	Результат = Запрос.Выполнить();
	
	//Программно формируем отчет
	
	Схема = ПолучитьМакет("ОсновнаяСхемаКомпоновкиДанных");
	
	
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	ДанныеРасшифровки = Новый ДанныеРасшифровкиКомпоновкиДанных;
	
	//Создаем компоновщик макета и получаем макет компоновки
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(Схема, Настройки, ДанныеРасшифровки);
	
	ВнешниеНаборыДанных = Новый Структура;
	
	Если НЕ Результат.Пустой() Тогда
		ВнешниеНаборыДанных.Вставить("ТаблицаРезультат",Результат.Выгрузить());
	Иначе
		
		МассивТиповСправочник = Новый Массив;
		МассивТиповСправочник.Добавить(Тип("СправочникСсылка.CustomsPosts"));
		МассивТиповСправочник.Добавить(Тип("СправочникСсылка.Catalog"));
		МассивТиповСправочник.Добавить(Тип("СправочникСсылка.Сегменты"));
		МассивТиповСправочник.Добавить(Тип("СправочникСсылка.Agents"));
		МассивТиповСправочник.Добавить(Тип("СправочникСсылка.СтрокиИнвойса"));
		МассивТиповСправочник.Добавить(Тип("СправочникСсылка.СтрокиГТД"));
		
		МассивТиповДокумент = Новый Массив;
		МассивТиповДокумент.Добавить(Тип("ДокументСсылка.Инвойс"));
		МассивТиповДокумент.Добавить(Тип("ДокументСсылка.ГТД"));
		
		ПустаяТаблица = Новый ТаблицаЗначений;
		ПустаяТаблица.Колонки.Добавить("CCA", Новый ОписаниеТипов(МассивТиповСправочник));
		ПустаяТаблица.Колонки.Добавить("Segment", Новый ОписаниеТипов(МассивТиповСправочник));
		ПустаяТаблица.Колонки.Добавить("CustomsPost", Новый ОписаниеТипов(МассивТиповСправочник));
		ПустаяТаблица.Колонки.Добавить("POLine", Новый ОписаниеТипов(МассивТиповСправочник));
		ПустаяТаблица.Колонки.Добавить("InvoiceLine", Новый ОписаниеТипов(МассивТиповСправочник));
		ПустаяТаблица.Колонки.Добавить("Invoice", Новый ОписаниеТипов(МассивТиповДокумент));
		ПустаяТаблица.Колонки.Добавить("TNVEDImported", Новый ОписаниеТипов(МассивТиповСправочник));
		ПустаяТаблица.Колонки.Добавить("TNVEDImportedRate", Новый ОписаниеТипов("Строка"));
		ПустаяТаблица.Колонки.Добавить("Catalog", Новый ОписаниеТипов(МассивТиповСправочник));
		ПустаяТаблица.Колонки.Добавить("PartNo", Новый ОписаниеТипов("Строка"));
		ПустаяТаблица.Колонки.Добавить("CCD", Новый ОписаниеТипов(МассивТиповДокумент));
		ПустаяТаблица.Колонки.Добавить("CCDLine", Новый ОписаниеТипов(МассивТиповСправочник));
		ПустаяТаблица.Колонки.Добавить("TNVEDPreferable", Новый ОписаниеТипов(МассивТиповСправочник));
		ПустаяТаблица.Колонки.Добавить("TNVEDPreferableRate", Новый ОписаниеТипов("Строка"));
		ПустаяТаблица.Колонки.Добавить("LineItemTotalPrice", Новый ОписаниеТипов("Число"));
		ПустаяТаблица.Колонки.Добавить("DeltaRate", Новый ОписаниеТипов("Число"));
		ПустаяТаблица.Колонки.Добавить("TotalOverpayment", Новый ОписаниеТипов("Число"));
		ПустаяТаблица.Колонки.Добавить("ERP_Treatment", Новый ОписаниеТипов(Тип("ПеречислениеСсылка.ТипыЗаказа")));
		
		ВнешниеНаборыДанных.Вставить("ТаблицаРезультат", ПустаяТаблица);
	КонецЕсли;
	
	//Инициализируем процессор компоновки
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновки, ВнешниеНаборыДанных, ДанныеРасшифровки, Истина);
	
	//Очищаем документ результата
	ДокументРезультат.Очистить();
	
	//Выводим отчет в документ
	ПроцессорВывода = Новый
	ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);
	
КонецПроцедуры
