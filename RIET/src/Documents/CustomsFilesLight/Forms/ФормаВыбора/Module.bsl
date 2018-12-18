
// ДОДЕЛАТЬ
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// ПОДУМАТЬ, МОЖЕТ БЫТЬ НАСТРАИВАТЬ ФОРМЫ ВЫБОРА ПРЯМО ИЗ ФОРМЫ, ОТКУДА ПРОИЗВОДИТСЯ ВЫБОР
	Если Параметры.Свойство("СтруктураНастройки") Тогда
		
		СтруктураНастройки = Параметры.СтруктураНастройки;
		Если СтруктураНастройки.Имя = "ВыборИзCustomsPaymentAllocation" Тогда
			НастроитьДляВыбораИзCustomsPaymentAllocation(СтруктураНастройки);
		ИначеЕсли СтруктураНастройки.Имя = "ВыборИзBoxOfCustomsFiles" Тогда
			НастроитьДляВыбораИзBoxOfCustomsFiles(СтруктураНастройки);
		ИначеЕсли СтруктураНастройки.Имя = "ВыборИзTemporaryImpExpTransactions" Тогда
			НастроитьДляВыбораИзTemporaryImpExpTransactions(СтруктураНастройки);
		КонецЕсли;
		     		
	КонецЕсли;
	
	Отбор = Параметры.Отбор;
	
	Отбор.Вставить("ПометкаУдаления", Ложь);
	
	ImportExportСервер.ДобавитьОтборПоProcessLevelПриНеобходимости(Отбор, "ProcessLevel");
	
КонецПроцедуры
     
&НаСервере
Процедура НастроитьДляВыбораИзCustomsPaymentAllocation(СтруктураНастройки)

	СтруктураПодбора = CustomsСервер.ПолучитьСтруктуруПодбораТПОForAllocation(СтруктураНастройки.CustomsPayment);
			
	Отбор = Параметры.Отбор;
	
	Если ЗначениеЗаполнено(СтруктураПодбора.Customs) Тогда
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
			Список.Отбор,
			"CustomsPost.Customs",
			СтруктураПодбора.Customs,
			ВидСравненияКомпоновкиДанных.Равно);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СтруктураПодбора.CCDReference) Тогда
		Отбор.Вставить("SeqNo", СтруктураПодбора.CCDReference);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СтруктураПодбора.SoldTo) Тогда
		Отбор.Вставить("SoldTo", СтруктураПодбора.SoldTo);
	КонецЕсли;
			
	Отбор.Вставить("Ссылка", СтруктураПодбора.ТПО);
	Если ЗначениеЗаполнено(СтруктураНастройки.CurrentCustomsDocument) Тогда
		Отбор.Ссылка.Добавить(СтруктураНастройки.CurrentCustomsDocument);
	КонецЕсли; 
	
	Отбор.Вставить("Проведен", Истина);
	
КонецПроцедуры

&НаСервере
Процедура НастроитьДляВыбораИзBoxOfCustomsFiles(СтруктураНастройки)
	
	Отбор = Параметры.Отбор;
	
	Отбор.Вставить("ProcessLevel", СтруктураНастройки.ProcessLevel);
	
	Отбор.Вставить("Проведен", Истина);
	
	Отбор.Вставить("ПометкаУдаления", Ложь);
	
	// Отфильтруем по ссылке только те Customs files light, которые еще не вошли в другие Boxes.
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ProcessLevel", СтруктураНастройки.ProcessLevel);
	Запрос.УстановитьПараметр("CurrentBox", СтруктураНастройки.CurrentBox);
	Запрос.УстановитьПараметр("CurrentCustomsFilesLight", СтруктураНастройки.CurrentCustomsFilesLight);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	CustomsFilesLight.Ссылка
		|ИЗ
		|	Документ.CustomsFilesLight КАК CustomsFilesLight
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.BoxesOfCustomsFiles.CustomsFilesLight КАК BoxesOfCustomsFilesCustomsFilesLight
		|		ПО CustomsFilesLight.Ссылка = BoxesOfCustomsFilesCustomsFilesLight.CustomsFileLight
		|			И (НЕ BoxesOfCustomsFilesCustomsFilesLight.Ссылка.ПометкаУдаления)
		|			И (НЕ BoxesOfCustomsFilesCustomsFilesLight.Ссылка = &CurrentBox)
		|ГДЕ
		|	CustomsFilesLight.ProcessLevel = &ProcessLevel
		|	И НЕ CustomsFilesLight.ПометкаУдаления
		|	И CustomsFilesLight.Проведен
		|	И BoxesOfCustomsFilesCustomsFilesLight.Ссылка ЕСТЬ NULL 
		|	И НЕ CustomsFilesLight.Ссылка В (&CurrentCustomsFilesLight)";
	CustomsFiles = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	
	Параметры.Отбор.Вставить("Ссылка", CustomsFiles);
	
	Параметры.МножественныйВыбор = Истина;
	
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
	|	CustomsFilesOfGoods.CustomsFile ССЫЛКА Документ.CustomsFilesLight";
	
	Отбор.Вставить("Ссылка", Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("CustomsFile"));
	
	Если СтруктураНастройки.Свойство("ImportExport") Тогда
		Отбор.Вставить("ImportExport", СтруктураНастройки.ImportExport);
	КонецЕсли;
	
КонецПроцедуры
