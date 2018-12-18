
// RGS ASeryakov 19/01/2018 12:00:00 AM S-I-0004008

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	АвтоЗаголовок  = Ложь;
	КаталогПолучен = "";
		
	Если Параметры.Свойство("Catalog") И ЗначениеЗаполнено(Параметры.Catalog) Тогда
		
		Catalog = Параметры.Catalog;
		TNVEDSLB = Параметры.TNVEDSLB;
		TNVEDSLBCurrent = Параметры.TNVEDSLB;
		TNVEDSLBRateCurrent = Параметры.TNVEDSLB.Rate;
		
		PartNo = СокрЛП(Строка(Параметры.Catalog));
		PR = Параметры.PR;
		
	Иначе
		КаталогПолучен = " <""Catalog"" не определен!>";
	КонецЕсли;
	
	Заголовок = "TNVEDHistory " + Параметры.PartNoПредставление + КаталогПолучен;
	
	Запрос = Новый Запрос;
	запрос.Текст =
	"ВЫБРАТЬ
	|	ВложенныйЗапрос.ParentCompany КАК ParentCompany,
	|	ВложенныйЗапрос.Segment КАК Segment,
	|	ВложенныйЗапрос.AU КАК AU,
	|	ВложенныйЗапрос.ERPTreatment КАК ERPTreatment,
	|	ВложенныйЗапрос.InvoiceLine КАК InvoiceLine,
	|	ВложенныйЗапрос.CostsAllocationDate КАК CostsAllocationDate
	|ПОМЕСТИТЬ InvoiceLinesCostsОбороты
	|ИЗ
	|	(ВЫБРАТЬ
	|		InvoiceLinesCostsОбороты.SoldTo КАК ParentCompany,
	|		InvoiceLinesCostsОбороты.Segment КАК Segment,
	|		InvoiceLinesCostsОбороты.AU КАК AU,
	|		InvoiceLinesCostsОбороты.ERPTreatment КАК ERPTreatment,
	|		InvoiceLinesCostsОбороты.СтрокаИнвойса КАК InvoiceLine,
	|		InvoiceLinesCostsОбороты.Период КАК CostsAllocationDate
	|	ИЗ
	|		РегистрНакопления.InvoiceLinesCosts.Обороты(
	|				&НачалоПериода,
	|				&КонецПериода,
	|				Регистратор,
	|				ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ИнвойсПеревозка)
	|					И СтрокаИнвойса.Инвойс <> ЗНАЧЕНИЕ(Документ.Инвойс.ПустаяСсылка)
	|					И СтрокаИнвойса.КодПоИнвойсу = &PartNo
	|					И СтрокаИнвойса.Инвойс В
	|						(ВЫБРАТЬ
	|							КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Инвойс
	|						ИЗ
	|							Документ.Поставка.УпаковочныеЛисты КАК ПоставкаУпаковочныеЛисты
	|								ЛЕВОЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы
	|								ПО
	|									ПоставкаУпаковочныеЛисты.УпаковочныйЛист = КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка
	|						ГДЕ
	|							ПоставкаУпаковочныеЛисты.Ссылка.Cleared >= &Cleared)) КАК InvoiceLinesCostsОбороты
	|	{ГДЕ
	|		InvoiceLinesCostsОбороты.SoldTo.* КАК ParentCompany,
	|		InvoiceLinesCostsОбороты.Segment.*,
	|		InvoiceLinesCostsОбороты.AU.*,
	|		InvoiceLinesCostsОбороты.ERPTreatment.*,
	|		InvoiceLinesCostsОбороты.СтрокаИнвойса.* КАК InvoiceLine}) КАК ВложенныйЗапрос
	|
	|СГРУППИРОВАТЬ ПО
	|	ВложенныйЗапрос.InvoiceLine,
	|	ВложенныйЗапрос.Segment,
	|	ВложенныйЗапрос.AU,
	|	ВложенныйЗапрос.ERPTreatment,
	|	ВложенныйЗапрос.CostsAllocationDate,
	|	ВложенныйЗапрос.ParentCompany
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	InvoiceLine
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	InvoiceLinesCostsОбороты.ParentCompany КАК ParentCompany,
	|	InvoiceLinesCostsОбороты.Segment КАК Segment,
	|	InvoiceLinesCostsОбороты.AU КАК AU,
	|	InvoiceLinesCostsОбороты.ERPTreatment КАК ERPTreatment,
	|	InvoiceLinesCostsОбороты.InvoiceLine КАК InvoiceLine,
	|	InvoiceLinesCostsОбороты.InvoiceLine.СтрокаЗаявкиНаЗакупку КАК POLine,
	|	InvoiceLinesCostsОбороты.InvoiceLine.СтрокаЗаявкиНаЗакупку.Владелец КАК PO,
	|	InvoiceLinesCostsОбороты.InvoiceLine.Инвойс КАК Invoice,
	|	CustomsFilesOfGoods.CustomsFile КАК CCD,
	|	InvoiceLinesClassificationClassification.Type КАК Type,
	|	InvoiceLinesClassificationClassification.Translation КАК Translation,
	|	РаспределениеИмпортаПоЗакрытиюПоставкиСопоставлениеInvoiceLinesИDSS.ПроводкаDSSСКП КАК ПроводкаDSSСКП,
	|	РаспределениеИмпортаПоЗакрытиюПоставкиСопоставлениеInvoiceLinesИDSS.Ссылка КАК РИЗП,
	|	InvoiceLinesCostsОбороты.CostsAllocationDate КАК CostsAllocationDate,
	|	InvoiceLinesCostsОбороты.InvoiceLine.НомерЗаявкиНаЗакупку КАК PONo,
	|	ВЫРАЗИТЬ(InvoiceLinesCostsОбороты.InvoiceLine.НаименованиеТовара КАК СТРОКА(300)) КАК DescriptionEng,
	|	СтрокиГТД.Ссылка КАК CCDLine,
	|	СтрокиГТД.ТНВЭД КАК TNVED,
	|	СтрокиГТД.ТНВЭД.Rate КАК TNVEDRate
	|ПОМЕСТИТЬ ВТ
	|ИЗ
	|	InvoiceLinesCostsОбороты КАК InvoiceLinesCostsОбороты
	|		{ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.CustomsFilesOfGoods КАК CustomsFilesOfGoods
	|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтрокиГТД КАК СтрокиГТД
	|			ПО CustomsFilesOfGoods.CustomsFile = СтрокиГТД.ГТД
	|		ПО InvoiceLinesCostsОбороты.InvoiceLine = CustomsFilesOfGoods.Item}
	|		{ЛЕВОЕ СОЕДИНЕНИЕ Документ.InvoiceLinesClassification.Classification КАК InvoiceLinesClassificationClassification
	|		ПО InvoiceLinesCostsОбороты.InvoiceLine = InvoiceLinesClassificationClassification.InvoiceLine
	|			И (НЕ InvoiceLinesClassificationClassification.Ссылка.ПометкаУдаления)}
	|		{ЛЕВОЕ СОЕДИНЕНИЕ Документ.РаспределениеИмпортаПоЗакрытиюПоставки.СопоставлениеInvoiceLinesИDSS КАК РаспределениеИмпортаПоЗакрытиюПоставкиСопоставлениеInvoiceLinesИDSS
	|		ПО InvoiceLinesCostsОбороты.InvoiceLine = РаспределениеИмпортаПоЗакрытиюПоставкиСопоставлениеInvoiceLinesИDSS.InvoiceLine
	|			И (НЕ РаспределениеИмпортаПоЗакрытиюПоставкиСопоставлениеInvoiceLinesИDSS.Ссылка.ПометкаУдаления)}
	|
	|СГРУППИРОВАТЬ ПО
	|	InvoiceLinesCostsОбороты.ParentCompany,
	|	InvoiceLinesCostsОбороты.Segment,
	|	InvoiceLinesCostsОбороты.AU,
	|	InvoiceLinesCostsОбороты.ERPTreatment,
	|	InvoiceLinesCostsОбороты.InvoiceLine,
	|	InvoiceLinesCostsОбороты.InvoiceLine.СтрокаЗаявкиНаЗакупку,
	|	InvoiceLinesCostsОбороты.InvoiceLine.СтрокаЗаявкиНаЗакупку.Владелец,
	|	InvoiceLinesCostsОбороты.InvoiceLine.Инвойс,
	|	CustomsFilesOfGoods.CustomsFile,
	|	InvoiceLinesClassificationClassification.Type,
	|	InvoiceLinesClassificationClassification.Translation,
	|	РаспределениеИмпортаПоЗакрытиюПоставкиСопоставлениеInvoiceLinesИDSS.ПроводкаDSSСКП,
	|	РаспределениеИмпортаПоЗакрытиюПоставкиСопоставлениеInvoiceLinesИDSS.Ссылка,
	|	InvoiceLinesCostsОбороты.CostsAllocationDate,
	|	InvoiceLinesCostsОбороты.InvoiceLine.НомерЗаявкиНаЗакупку,
	|	ВЫРАЗИТЬ(InvoiceLinesCostsОбороты.InvoiceLine.НаименованиеТовара КАК СТРОКА(300)),
	|	СтрокиГТД.Ссылка,
	|	СтрокиГТД.ТНВЭД,
	|	СтрокиГТД.ТНВЭД.Rate
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ.ParentCompany КАК ParentCompany,
	|	ВТ.Segment КАК Segment,
	|	ВТ.AU КАК AU,
	|	ВТ.ERPTreatment КАК ERPTreatment,
	|	ВТ.InvoiceLine КАК InvoiceLine,
	|	ВТ.POLine КАК POLine,
	|	ВТ.PO КАК PO,
	|	ВТ.Invoice КАК Invoice,
	|	ВТ.CCD КАК CCD,
	|	ВТ.Type КАК Type,
	|	ВТ.Translation КАК Translation,
	|	ВТ.ПроводкаDSSСКП КАК ПроводкаDSSСКП,
	|	ВТ.РИЗП КАК РИЗП,
	|	ВТ.CostsAllocationDate КАК CostsAllocationDate,
	|	ВТ.PONo КАК PONo,
	|	ВТ.DescriptionEng КАК DescriptionEng,
	|	ВТ.CCDLine КАК CCDLine,
	|	ВТ.TNVED КАК TNVED,
	|	ВЫБОР
	|		КОГДА НЕ ВТ.TNVEDRate ПОДОБНО """"
	|			ТОГДА ВТ.TNVEDRate
	|		ИНАЧЕ ""0""
	|	КОНЕЦ КАК TNVEDRate
	|ИЗ
	|	ВТ КАК ВТ
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ТоварыСтрокГТД КАК ТоварыСтрокГТД
	|		ПО ВТ.CCDLine = ТоварыСтрокГТД.Владелец
	|			И (ТоварыСтрокГТД.МаркировкаТовара ПОДОБНО ""%"" + ВТ.InvoiceLine.КодПоИнвойсу + ""%"")
	|ГДЕ
	|	НЕ ТоварыСтрокГТД.МаркировкаТовара = """"
	|
	|СГРУППИРОВАТЬ ПО
	|	ВТ.ParentCompany,
	|	ВТ.Segment,
	|	ВТ.AU,
	|	ВТ.ERPTreatment,
	|	ВТ.InvoiceLine,
	|	ВТ.POLine,
	|	ВТ.PO,
	|	ВТ.Invoice,
	|	ВТ.CCD,
	|	ВТ.Type,
	|	ВТ.Translation,
	|	ВТ.ПроводкаDSSСКП,
	|	ВТ.РИЗП,
	|	ВТ.CostsAllocationDate,
	|	ВТ.PONo,
	|	ВТ.DescriptionEng,
	|	ВТ.CCDLine,
	|	ВТ.TNVED,
	|	ВЫБОР
	|		КОГДА НЕ ВТ.TNVEDRate ПОДОБНО """"
	|			ТОГДА ВТ.TNVEDRate
	|		ИНАЧЕ ""0""
	|	КОНЕЦ";
	
	Запрос.УстановитьПараметр("НачалоПериода", Дата("01.01.2015 00:00:00"));
	Запрос.УстановитьПараметр("КонецПериода", ТекущаяДата());
	Запрос.УстановитьПараметр("PartNo", СокрЛП(Параметры.PartNo.Код));
	Запрос.УстановитьПараметр("Cleared", Дата("01.01.2017 00:00:00"));
	
	Результат = Запрос.Выполнить().Выгрузить();
	History.Загрузить(Результат);
	
	HistoryКолВо = History.Количество() > 0;
	Элементы.ФормаУстановитьPriorityTNVED.Доступность =  HistoryКолВо;
	Элементы.ФормаУдалитьPriorityTNVED.Доступность = HistoryКолВо;
	
	ЗаполнитьМинимальныйTNVED();
	
КонецПроцедуры

&НаСервере
Процедура УстановитьPriorityTNVEDНаСервере(TNVED, TNVEDSLBRate)
	
	УстановитьПривилегированныйРежим(Истина);
	
	Набор = РегистрыСведений.rgsPriorityTNVEDOverMinTNVED.СоздатьНаборЗаписей();
	Набор.Записывать = Истина;
	Набор.Отбор.Catalog.Установить(Catalog);			
	Набор.Прочитать();
	
	Если Набор.Количество() > 0 Тогда
		
		Набор[0].TNVED = TNVED;
		Набор.Записать();
	Иначе
		Запись = Набор.Добавить();
		Запись.Catalog = Catalog;
		Запись.TNVED   = TNVED;
		Набор.Записать(Ложь);
		
	КонецЕсли;	
	
	TNVEDSLBRate =  ПолучитьRateПоТНВЭДНаСервере(TNVED);
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьPriorityTNVED(Команда)
	
	TNVED = Элементы.History.ТекущиеДанные.TNVED;
	
	Если НЕ ЗначениеЗаполнено(TNVED) Тогда
		
		ТекстСообщения = НСтр("ru = 'Для текущей строки не задан TNVED '; en = 'For the current row is not set TNVED'");				
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		
	ИначеЕсли ЗначениеЗаполнено(TNVED) И TNVED = TNVEDSLB Тогда
		
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ВернутьСтр("ru = 'Необходимо установить значение TNVED отличное от ""%1""'; en = 'For the current row is not set TNVED'"), Строка(TNVED));				
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		
	Иначе
		
		Попытка
			
			УстановитьPriorityTNVEDНаСервере(TNVED, TNVEDSLBRate);
			TNVEDSLB = ?(TNVED <> TNVEDSLB, TNVED, TNVEDSLB);
			TNVEDSLBRate = ?(TNVED <> TNVEDSLB, TNVED.Rate, TNVEDSLBRate);
			
			ОбновитьЗаголовокФормы(Истина);
			
			СтруктураПараметров = Новый Структура();
			СтруктураПараметров.Вставить("Добавление", Истина);
			СтруктураПараметров.Вставить("TNVEDSLB", TNVEDSLB);
			СтруктураПараметров.Вставить("TNVEDSLBRate", Строка(TNVEDSLBRate));
			
			Оповестить("ОбновитьTNVEDSLB", СтруктураПараметров, ЭтотОбъект);
			
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ОписаниеОшибки());
		КонецПопытки;
		
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УдалитьPriorityTNVEDНаСервере(Catalog)
	
	УстановитьПривилегированныйРежим(Истина);
	
	Набор = РегистрыСведений.rgsPriorityTNVEDOverMinTNVED.СоздатьНаборЗаписей();
	Набор.Записывать = Истина;
	Набор.Отбор.Catalog.Установить(Catalog);			
	Набор.Прочитать();
	
	Если Набор.Количество() > 0 Тогда
		
		Набор.Очистить();
		Набор.Записать();
		
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура УдалитьPriorityTNVED(Команда)
	
	Если  ЗначениеЗаполнено(Catalog) Тогда
		
		Попытка
			УдалитьPriorityTNVEDНаСервере(Catalog);
			ОбновитьЗаголовокФормы(Ложь);
			
			СтруктураПараметров = Новый Структура();
			СтруктураПараметров.Вставить("Добавление", Ложь);
			
			Оповестить("ОбновитьTNVEDSLB", СтруктураПараметров, ЭтотОбъект);
			
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ОписаниеОшибки());
		КонецПопытки;
		
		
	Иначе
		
		ТекстСообщения = НСтр("ru = 'Не задан Catalog '; en = 'Not set TNVED'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		
	КонецЕсли;
	
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьЗаголовокФормы(Заполнение)
	
	Если Заполнение Тогда
		TNVEDSLBName = "TNVEDSLB(PR): ";
		Заголовок = "TNVEDHistory PartNo: " + PartNo + "; " + TNVEDSLBName + СокрЛП(Строка(TNVEDSLB)) + "; " + "Rate: " + TNVEDSLBRate;
	Иначе
		TNVEDSLBName = "TNVEDSLB: ";
		Заголовок = "TNVEDHistory PartNo: " + PartNo + "; " + TNVEDSLBName + СокрЛП(Строка(TNVEDSLBCurrent)) + "; " + "Rate: " + TNVEDSLBRateCurrent;
	КонецЕсли;
	
	
КонецПроцедуры // ПерезаполнитьФормыЗаголовокМинимальнымСтатусомТНВЭД()

&НаСервереБезКонтекста
Функция ПолучитьRateПоТНВЭДНаСервере(Ссылка)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	TNVEDCodes.Rate
	|ИЗ
	|	Справочник.TNVEDCodes КАК TNVEDCodes
	|ГДЕ
	|	TNVEDCodes.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		
		Выборка = РезультатЗапроса.Выбрать();	
		Выборка.Следующий();
		
		Возврат Выборка.Rate;
	Иначе
		Возврат "";
	КонецЕсли;
	
	
	
КонецФункции // ПолучитьРатеПоТНВЭДНаСервере()

&НаСервере
Процедура ЗаполнитьМинимальныйTNVED()
	
	Таблица = History.Выгрузить(, "TNVED,TNVEDRate");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Таблица.TNVED,
	|	Таблица.TNVEDRate
	|ПОМЕСТИТЬ ТаблицаВТ
	|ИЗ
	|	&Таблица КАК Таблица
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицаВТ.TNVED КАК TNVED,
	|	ТаблицаВТ.TNVEDRate КАК TNVEDRate
	|ИЗ
	|	ТаблицаВТ КАК ТаблицаВТ";
	
	Запрос.УстановитьПараметр("Таблица",Таблица);
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		
		Выборка = РезультатЗапроса.Выбрать();
		
		ТаблицаРезультат = РГСофтКлиентСервер.ПодготовитьДанныеGoodsTNVED(РезультатЗапроса);
		
		TNVEDMinHistory = ТаблицаРезультат[0].TNVED;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗаполнитьТекущийRateПоTNVED(Ссылка)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	TNVEDCodes.Rate
	|ИЗ
	|	Справочник.TNVEDCodes КАК TNVEDCodes
	|ГДЕ
	|	TNVEDCodes.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		TNVEDSLBRate = Выборка.Rate;
		
	КонецЕсли;
	
КонецПроцедуры // TNVTNVEDSLB()


