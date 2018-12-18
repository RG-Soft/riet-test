
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Заголовок = "History of temporary import of Item """ + СокрЛП(Параметры.Item) + """";
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Item", Параметры.Item);
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ЗакрытиеПоставкиСопоставление.Ссылка КАК Ссылка,
		|	ЗакрытиеПоставкиСопоставление.Ссылка.Представление КАК ПредставлениеСсылки,
		|	ВЫБОР
		|		КОГДА ЗакрытиеПоставкиСопоставление.Ссылка.Поставка ССЫЛКА Документ.Поставка
		|			ТОГДА ЗНАЧЕНИЕ(Перечисление.TypesOfTemporaryImpExpTransaction.TemporaryImport)
		|		КОГДА ЗакрытиеПоставкиСопоставление.Ссылка.Поставка ССЫЛКА Документ.ExportShipment
		|			ТОГДА ЗНАЧЕНИЕ(Перечисление.TypesOfTemporaryImpExpTransaction.TemporaryExport)
		|	КОНЕЦ КАК TypeOfTransaction,
		|	ВЫРАЗИТЬ(ЗакрытиеПоставкиСопоставление.Ссылка.Comment КАК СТРОКА(1000)) КАК Comments,
		|	ЗакрытиеПоставкиСопоставление.Ссылка.Дата КАК Дата
		|ИЗ
		|	Документ.ЗакрытиеПоставки.Сопоставление КАК ЗакрытиеПоставкиСопоставление
		|ГДЕ
		|	ЗакрытиеПоставкиСопоставление.СтрокаИнвойса = &Item
		|	И ЗакрытиеПоставкиСопоставление.Ссылка.Проведен
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	CustomsFilesLight.Ссылка,
		|	CustomsFilesLight.Ссылка.Представление,
		|	ВЫБОР
		|		КОГДА CustomsFilesLight.ImportExport = ЗНАЧЕНИЕ(Перечисление.ИмпортЭкспорт.Import)
		|			ТОГДА ЗНАЧЕНИЕ(Перечисление.TypesOfTemporaryImpExpTransaction.TemporaryImport)
		|		КОГДА CustomsFilesLight.ImportExport = ЗНАЧЕНИЕ(Перечисление.ИмпортЭкспорт.Export)
		|			ТОГДА ЗНАЧЕНИЕ(Перечисление.TypesOfTemporaryImpExpTransaction.TemporaryExport)
		|	КОНЕЦ,
		|	ВЫРАЗИТЬ(CustomsFilesLight.Comment КАК СТРОКА(1000)),
		|	CustomsFilesLight.Дата
		|ИЗ
		|	Документ.CustomsFilesLight.Items КАК CustomsFilesLightItems
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.CustomsFilesLight КАК CustomsFilesLight
		|		ПО CustomsFilesLightItems.Ссылка = CustomsFilesLight.Ссылка
		|ГДЕ
		|	CustomsFilesLightItems.Item = &Item
		|	И CustomsFilesLight.Проведен
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	TemporaryImpExpTransactionsItems.Ссылка,
		|	TemporaryImpExpTransactionsItems.Ссылка.Представление,
		|	TemporaryImpExpTransactionsItems.Ссылка.TypeOfTransaction,
		|	ВЫРАЗИТЬ(TemporaryImpExpTransactionsItems.Ссылка.Comments КАК СТРОКА(1000)),
		|	TemporaryImpExpTransactionsItems.Ссылка.Дата
		|ИЗ
		|	Документ.TemporaryImpExpTransactions.Items КАК TemporaryImpExpTransactionsItems
		|ГДЕ
		|	TemporaryImpExpTransactionsItems.Item = &Item
		|	И TemporaryImpExpTransactionsItems.Ссылка.Проведен
		|
		|УПОРЯДОЧИТЬ ПО
		|	Дата";
		
	УстановитьПривилегированныйРежим(Истина);	
	Таблица.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ТекущиеДанные = Элементы.Таблица.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(ТекущиеДанные.Ссылка) Тогда
		Возврат;
	КонецЕсли;
	ПоказатьЗначение(,ТекущиеДанные.Ссылка);
		
КонецПроцедуры
