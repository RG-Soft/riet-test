
Функция ПроверитьProcessLevelПоCCA(CCA, ProcessLevel) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Leg7ProcessLevels.ProcessLevel
	               |ПОМЕСТИТЬ ProcessLevels
	               |ИЗ
	               |	ПланОбмена.Leg7.ProcessLevels КАК Leg7ProcessLevels
	               |ГДЕ
	               |	Leg7ProcessLevels.Ссылка.CCA = &CCA
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВложенныйЗапрос.ProcessLevel
	               |ИЗ
	               |	(ВЫБРАТЬ
	               |		ProcessLevels.ProcessLevel КАК ProcessLevel
	               |	ИЗ
	               |		ProcessLevels КАК ProcessLevels
	               |	ГДЕ
	               |		ProcessLevels.ProcessLevel = &ProcessLevel) КАК ВложенныйЗапрос";
	
	Запрос.УстановитьПараметр("CCA", CCA);
	Запрос.УстановитьПараметр("ProcessLevel", ProcessLevel);
	Результат = Запрос.Выполнить();
	
	Возврат ?(НЕ Результат.Пустой(), Истина, Ложь);
	
КонецФункции

Функция ПолучитьИспользованиеLeg6ReportДляCCA(CCA) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЕСТЬNULL(Leg7.Leg6Report, Ложь) КАК Leg6Report
	               |ИЗ
	               |	ПланОбмена.Leg7 КАК Leg7
	               |ГДЕ
	               |	НЕ Leg7.ПометкаУдаления
	               |	И Leg7.CCA = &CCA";
	
	Запрос.УстановитьПараметр("CCA", CCA);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Выборка = Результат.Выбрать();
	Выборка.Следующий();
	
	Возврат Выборка.Leg6Report;
	
КонецФункции

// { RGS LHristyc 29.06.2018 17:31:14 - S-I-0004942
Функция ПолучитьИспользованиеExportReportsДляCCA(CCA) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЕСТЬNULL(Leg7.ExportReports, ЛОЖЬ) КАК ExportReports
	               |ИЗ
	               |	ПланОбмена.Leg7 КАК Leg7
	               |ГДЕ
	               |	НЕ Leg7.ПометкаУдаления
	               |	И Leg7.CCA = &CCA";
	
	Запрос.УстановитьПараметр("CCA", CCA);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Выборка = Результат.Выбрать();
	Выборка.Следующий();
	
	Возврат Выборка.ExportReports;
	
КонецФункции // } RGS LHristyc 29.06.2018 17:31:26 - S-I-0004942

Функция РасширенныйСоставРедактируемыхПолейLeg6(CCA) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЕСТЬNULL(Leg7.РасширенныйСоставРедактируемыхПолейLeg6, Ложь) КАК РасширенныйСоставРедактируемыхПолейLeg6
	               |ИЗ
	               |	ПланОбмена.Leg7 КАК Leg7
	               |ГДЕ
	               |	НЕ Leg7.ПометкаУдаления
	               |	И Leg7.CCA = &CCA";
	
	Запрос.УстановитьПараметр("CCA", CCA);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Выборка = Результат.Выбрать();
	Выборка.Следующий();
	
	Возврат Выборка.РасширенныйСоставРедактируемыхПолейLeg6;
	
КонецФункции

Функция ПолучитьНастройкуОбмена(УзелОбмена, ПроверятьГУИД = Ложь) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Leg7.AdditionalInfoReport КАК AdditionalInfoReport,
		|	Leg7.ОтключитьКонтрольЗаполненностиNetWeight,
		|	Leg7.ServiceProvider,
		|	Leg7.КонвертироватьВСтандартныеЕдиницыИзмерения,
		|	Leg7.АрхивироватьФайл,
		|	Leg7.ЕдиницаИзмеренияРазмеров КАК ЕдиницаИзмеренияРазмера,
		|	Leg7.ЕдиницаИзмеренияВеса КАК ЕдиницаИзмеренияВеса,
		|	Leg7.ЕдиницаИзмеренияРазмеров.ConversionFactor КАК КоэффицинтПересчетаРазмера,
		|	Leg7.ЕдиницаИзмеренияВеса.ConversionFactor КАК КоэффицинтПересчетаВеса,
		|	Leg7.ЕдиницаИзмеренияРазмеров.Код КАК КодЕдиницыИзмеренияРазмера,
		|	Leg7.ЕдиницаИзмеренияВеса.Код КАК КодЕдиницыИзмеренияВеса,
		|	Leg7.ВыгружатьТолькоИмпортныеПарсели,
		|	Leg7.ВыгружатьДанные,
		|	Leg7.ЗагружатьДанные,
		|	Leg7.ЗаполнятьLEвТрипах,
		|	Leg7.Leg6Report,
		|	Leg7.Наименование КАК НаименованиеУзла,
		|	Leg7.CCA,
		|	Leg7.ОтправлятьФайлВОтчетеОбОшибках,
		|	Leg7.ЗаменятьСкладUNKN,
		|	Leg7.ЗаменаСкладаUNKN,
		|	Leg7.ОтключитьПроверкуСоставаИмпортныхПарселей,
		// { RGS LKhristyuk 4/23/2018 12:14:44 PM
		|	Leg7.ExportReports
		// } RGS LKhristyuk 4/23/2018 12:14:44 PM 
		|ИЗ
		|	ПланОбмена.Leg7 КАК Leg7
		|ГДЕ
		|	Leg7.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Leg7ИсключаемыеБрокеры.Agent
		|ИЗ
		|	ПланОбмена.Leg7.ИсключаемыеБрокеры КАК Leg7ИсключаемыеБрокеры
		|ГДЕ
		|	Leg7ИсключаемыеБрокеры.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", УзелОбмена);
	
	РезультатПакета = Запрос.ВыполнитьПакет();
	РезультатЗапроса = РезультатПакета[0];
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	ВыборкаДетальныеЗаписи.Следующий();
	
	// { RGS LKhristyuk 4/23/2018 12:20:49 PM
	//// { RGS VShamin 17.07.2015 17:17:58 - S-I-0001168
	////Результат = Новый Структура("ServiceProvider, КонвертироватьВСтандартныеЕдиницыИзмерения, АрхивироватьФайл
	////	|, ЕдиницаИзмеренияРазмера, ЕдиницаИзмеренияВеса, КоэффицинтПересчетаРазмера, КоэффицинтПересчетаВеса
	////	|, КодЕдиницыИзмеренияРазмера, КодЕдиницыИзмеренияВеса, ИсключаемыеБрокеры, ВыгружатьТолькоИмпортныеПарсели
	////	|, ВыгружатьДанные, ЗагружатьДанные, ЗаполнятьLEвТрипах, Leg6Report, НаименованиеУзла, CCA");
	//Результат = Новый Структура("AdditionalInfoReport, ServiceProvider, КонвертироватьВСтандартныеЕдиницыИзмерения, АрхивироватьФайл
	//	|, ЕдиницаИзмеренияРазмера, ЕдиницаИзмеренияВеса, КоэффицинтПересчетаРазмера, КоэффицинтПересчетаВеса
	//	|, КодЕдиницыИзмеренияРазмера, КодЕдиницыИзмеренияВеса, ИсключаемыеБрокеры, ВыгружатьТолькоИмпортныеПарсели
	//	|, ВыгружатьДанные, ЗагружатьДанные, ЗаполнятьLEвТрипах, Leg6Report, НаименованиеУзла, CCA, ОтключитьКонтрольЗаполненностиNetWeight,ОтправлятьФайлВОтчетеОбОшибках
	//	|, ЗаменятьСкладUNKN, ЗаменаСкладаUNKN, ОтключитьПроверкуСоставаИмпортныхПарселей");
	//// } RGS VShamin 17.07.2015 17:17:58 - S-I-0001168
	
	Результат = Новый Структура("AdditionalInfoReport, ServiceProvider, КонвертироватьВСтандартныеЕдиницыИзмерения, АрхивироватьФайл
		|, ЕдиницаИзмеренияРазмера, ЕдиницаИзмеренияВеса, КоэффицинтПересчетаРазмера, КоэффицинтПересчетаВеса
		|, КодЕдиницыИзмеренияРазмера, КодЕдиницыИзмеренияВеса, ИсключаемыеБрокеры, ВыгружатьТолькоИмпортныеПарсели
		|, ВыгружатьДанные, ЗагружатьДанные, ЗаполнятьLEвТрипах, Leg6Report, НаименованиеУзла, CCA, ОтключитьКонтрольЗаполненностиNetWeight,ОтправлятьФайлВОтчетеОбОшибках
		|, ЗаменятьСкладUNKN, ЗаменаСкладаUNKN, ОтключитьПроверкуСоставаИмпортныхПарселей, ExportReports");
	
	// } RGS LKhristyuk 4/23/2018 12:20:49 PM
	
	
	ЗаполнитьЗначенияСвойств(Результат, ВыборкаДетальныеЗаписи);
	// { RGS ASeryakov 24.05.2018 17:00:00 S-I-0005295
	// { RGS AArsentev 21.06.2018 - ошибка при записи дока.
	Если ПроверятьГУИД Тогда
	// } RGS AArsentev 21.06.2018
		objRegExpGUID = Новый COMОбъект("VBScript.RegExp");
		objRegExpGUID.MultiLine = Истина;
		objRegExpGUID.Global = Истина;
		objRegExpGUID.IgnoreCase = Истина;
		objRegExpGUID.Pattern = "[\da-fA-F]{8}\-[\da-fA-F]{4}\-[\da-fA-F]{4}\-[\da-fA-F]{4}\-[\da-fA-F]{12}";
		Результат.Вставить("objRegExpGUID", objRegExpGUID);
	КонецЕсли;
	// { RGS ASeryakov 24.05.2018 17:00:00 S-I-0005295
	
	РезультатЗапросаИсключаемыеБрокеры = РезультатПакета[1];
	Результат.ИсключаемыеБрокеры = РезультатЗапросаИсключаемыеБрокеры.Выгрузить().ВыгрузитьКолонку("Agent");
	
	Возврат Результат;
	
КонецФункции

Функция ПолучитьДатыНачалаВыгрузкиДокументовПоСкладам(УзелОбмена) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Leg7ДатыНачалаВыгрузкиДокументовПоСкладам.Склад,
		|	Leg7ДатыНачалаВыгрузкиДокументовПоСкладам.ДатаНачалаВыгрузкиДокументов
		|ИЗ
		|	ПланОбмена.Leg7.ДатыНачалаВыгрузкиДокументовПоСкладам КАК Leg7ДатыНачалаВыгрузкиДокументовПоСкладам
		|ГДЕ
		|	Leg7ДатыНачалаВыгрузкиДокументовПоСкладам.Ссылка = &УзелОбмена";
	
	Запрос.УстановитьПараметр("УзелОбмена", УзелОбмена);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	СоответствиеСкладовИДат = Новый Соответствие;
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		СоответствиеСкладовИДат.Вставить(ВыборкаДетальныеЗаписи.Склад, ВыборкаДетальныеЗаписи.ДатаНачалаВыгрузкиДокументов);
	КонецЦикла;
	
	Возврат СоответствиеСкладовИДат;

КонецФункции // ()

Функция СервисПровайдерУчаствуетВОбмене(СервисПровайдер) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1 1
		|ИЗ
		|	ПланОбмена.Leg7 КАК Leg7
		|ГДЕ
		|	Leg7.ServiceProvider = &ServiceProvider";

	Запрос.УстановитьПараметр("ServiceProvider", СервисПровайдер);

	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат НЕ РезультатЗапроса.Пустой();
	
КонецФункции

Функция ПолучитьУзелОбменаПоСервисПровайдеру(СервисПровайдер) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	Leg7.Ссылка КАК УзелОбмена
		|ИЗ
		|	ПланОбмена.Leg7 КАК Leg7
		|ГДЕ
		|	НЕ Leg7.ПометкаУдаления
		|	И Leg7.ServiceProvider = &ServiceProvider";
	Запрос.УстановитьПараметр("ServiceProvider", СервисПровайдер);

	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	Возврат Выборка.УзелОбмена;
	
КонецФункции

Функция ПолучитьСоответствиеУзловОбменаИCCA() Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Leg7.CCA,
		|	Leg7.Ссылка КАК УзелОбмена
		|ИЗ
		|	ПланОбмена.Leg7 КАК Leg7
		|ГДЕ
		|	НЕ Leg7.ПометкаУдаления
		|	И Leg7.CCA <> ЗНАЧЕНИЕ(Справочник.Agents.Пустаяссылка)";

	РезультатЗапроса = Запрос.Выполнить();
	Результат = Новый Соответствие;
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		Результат.Вставить(Выборка.CCA, Выборка.УзелОбмена);
	КонецЦикла;
	
	Возврат Результат;

КонецФункции

Функция ПолучитьСоответствиеУзловОбменаИСервисПровайдеров(ТолькоСНастройкойВыгрузки = Истина) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Leg7.ServiceProvider,
		|	Leg7.Ссылка КАК УзелОбмена,
		|	Leg7.ВыгружатьДанные
		|ИЗ
		|	ПланОбмена.Leg7 КАК Leg7
		|ГДЕ
		|	НЕ Leg7.ПометкаУдаления
		|	И Leg7.ServiceProvider <> ЗНАЧЕНИЕ(Справочник.ServiceProviders.Пустаяссылка)";

	РезультатЗапроса = Запрос.Выполнить();
	Результат = Новый Соответствие;
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		Если ТолькоСНастройкойВыгрузки И НЕ Выборка.ВыгружатьДанные Тогда
			Продолжить;
		КонецЕсли;
		Результат.Вставить(Выборка.ServiceProvider, Выборка.УзелОбмена);
	КонецЦикла;
	
	Возврат Результат;

КонецФункции

