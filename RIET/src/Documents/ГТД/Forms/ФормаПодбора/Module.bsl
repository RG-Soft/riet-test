
// ДОДЕЛАТЬ
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// ПОДУМАТЬ, МОЖЕТ БЫТЬ НЕ ПЕРЕДАВАТЬ СЮДА СТРУКТУРУ НАСТРОЙКИ
	// А НАСТРАИВАТЬ ВСЕ ПРЯМО В ФОРМЕ, ОТКУДА ПРОИЗВОДИТСЯ ВЫБОР
	Если Параметры.Свойство("СтруктураНастройки") Тогда
		
		СтруктураНастройки = Параметры.СтруктураНастройки;
		Если СтруктураНастройки.Имя = "ВыборИзBoxOfCustomsFiles" Тогда
			НастроитьДляВыбораИзBoxOfCustomsFiles(СтруктураНастройки);
		ИначеЕсли СтруктураНастройки.Имя = "ВыборИзCustomsPaymentAllocation" Тогда
			НастроитьДляВыбораИзCustomsPaymentAllocation(СтруктураНастройки);
		ИначеЕсли СтруктураНастройки.Имя = "ВыборИзFutureCustomsPayment" Тогда
			НастроитьДляВыбораИзFutureCustomsPayment(СтруктураНастройки);
		ИначеЕсли СтруктураНастройки.Имя = "ВыборИзTemporaryImpExpTransactions" Тогда
			НастроитьДляВыбораИзTemporaryImpExpTransactions(СтруктураНастройки);
		КонецЕсли;
		     		
	КонецЕсли;
	
	Отбор = Параметры.Отбор;
	
	Отбор.Вставить("ПометкаУдаления", Ложь);
		
	Отбор.Вставить("Проведен", Истина);
	
	ImportExportСервер.ДобавитьОтборПоProcessLevelПриНеобходимости(Отбор, "ProcessLevel");
		
КонецПроцедуры

&НаСервере
Процедура НастроитьДляВыбораИзBoxOfCustomsFiles(СтруктураНастройки)
	
	Отбор = Параметры.Отбор;
	
	Отбор.Вставить("ProcessLevel", СтруктураНастройки.ProcessLevel);
	
	Отбор.Вставить("Проведен", Истина);
	
	Отбор.Вставить("ПометкаУдаления", Ложь);
	
	// Отфильтруем по ссылке только те Customs files, которые еще не вошли в другие Boxes.
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ProcessLevel", СтруктураНастройки.ProcessLevel);
	Запрос.УстановитьПараметр("CurrentBox", СтруктураНастройки.CurrentBox);
	Запрос.УстановитьПараметр("CurrentCustomsFiles", СтруктураНастройки.CurrentCustomsFiles);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	CustomsFiles.Ссылка
		|ИЗ
		|	Документ.ГТД КАК CustomsFiles
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.BoxesOfCustomsFiles.CustomsFiles КАК BoxesOfCustomsFilesCustomsFiles
		|		ПО CustomsFiles.Ссылка = BoxesOfCustomsFilesCustomsFiles.CustomsFile
		|			И (НЕ BoxesOfCustomsFilesCustomsFiles.Ссылка.ПометкаУдаления)
		|			И (НЕ BoxesOfCustomsFilesCustomsFiles.Ссылка = &CurrentBox)
		|ГДЕ
		|	CustomsFiles.ProcessLevel = &ProcessLevel
		|	И НЕ CustomsFiles.ПометкаУдаления
		|	И CustomsFiles.Проведен
		|	И BoxesOfCustomsFilesCustomsFiles.Ссылка ЕСТЬ NULL 
		|	И НЕ CustomsFiles.Ссылка В (&CurrentCustomsFiles)";
	CustomsFiles = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	
	Параметры.Отбор.Вставить("Ссылка", CustomsFiles);
	
	Параметры.МножественныйВыбор = Истина;
	
КонецПроцедуры

&НаСервере
Процедура НастроитьДляВыбораИзCustomsPaymentAllocation(СтруктураНастройки)

	СтруктураПодбора = CustomsСервер.ПолучитьСтруктуруПодбораCCDsForAllocation(СтруктураНастройки.CustomsPayment);
			
	Отбор = Параметры.Отбор;
	
	Если ЗначениеЗаполнено(СтруктураПодбора.Customs) Тогда
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
			Список.Отбор,
			"CustomsPost.Customs",
			СтруктураПодбора.Customs,
			ВидСравненияКомпоновкиДанных.Равно);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СтруктураПодбора.CCDReference) Тогда
		Отбор.Вставить("SequenceNo", СтруктураПодбора.CCDReference);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СтруктураПодбора.SoldTo) Тогда
		Отбор.Вставить("SoldTo", СтруктураПодбора.SoldTo);
	КонецЕсли;
			
	Отбор.Вставить("Ссылка", СтруктураПодбора.CCDs);
	Если ЗначениеЗаполнено(СтруктураНастройки.CurrentCustomsDocument) Тогда
		Отбор.Ссылка.Добавить(СтруктураНастройки.CurrentCustomsDocument);
	КонецЕсли; 
	
КонецПроцедуры

&НаСервере
Процедура НастроитьДляВыбораИзFutureCustomsPayment(СтруктураНастройки)
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
		Список.Отбор,
		"Regime.PermanentTemporary",
		Перечисления.PermanentTemporary.Temporary,
		ВидСравненияКомпоновкиДанных.Равно);
	
КонецПроцедуры

&НаСервере
Процедура НастроитьДляВыбораИзTemporaryImpExpTransactions(СтруктураНастройки)
	
	Отбор = Параметры.Отбор;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Дата", СтруктураНастройки.Дата);
	
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	CustomsFilesOfGoods.CustomsFile
	|ИЗ
	|	РегистрСведений.CustomsFilesOfGoods КАК CustomsFilesOfGoods
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрНакопления.QtyOfItemsInTemporaryImpExp.Остатки(&Дата, ) КАК QtyOfItemsInTemporaryImpExpОстатки
	|		ПО (QtyOfItemsInTemporaryImpExpОстатки.Item = CustomsFilesOfGoods.Item)
	|ГДЕ
	|	CustomsFilesOfGoods.CustomsFile ССЫЛКА Документ.ГТД";
	
	Отбор.Вставить("Ссылка", Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("CustomsFile"));
	
	Если СтруктураНастройки.Свойство("ImportExport") Тогда
		Отбор.Вставить("ImportExport", СтруктураНастройки.ImportExport);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ПодобратьГТД(ВыбраннаяСтрока);
			
КонецПроцедуры

&НаКлиенте
Процедура СписокВыборЗначения(Элемент, Значение, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ПодобратьГТД(Значение);
	
КонецПроцедуры

&НаКлиенте
Процедура ПодобратьГТД(МассивСтрок)
	
	Для Каждого Стр из МассивСтрок Цикл 
		
		Если СписокВыбранныхГТД.НайтиПоЗначению(Стр) = Неопределено Тогда 
			СписокВыбранныхГТД.Добавить(Стр);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура AddListToTheBox(Команда)
	
	ОповеститьОВыборе(СписокВыбранныхГТД.ВыгрузитьЗначения());
		
КонецПроцедуры



