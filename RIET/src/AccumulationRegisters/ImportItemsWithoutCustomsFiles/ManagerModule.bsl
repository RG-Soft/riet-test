
Функция ПолучитьОстаткиПоItems(МоментВремени, Items) Экспорт
	
	// Возвращает таблицу остатков, отобранных по Items
		
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени);
	Запрос.УстановитьПараметр("Items", Items);
	
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ImportItemsWithoutCustomsFilesОстатки.Item,
		|	ImportItemsWithoutCustomsFilesОстатки.ImportShipment,
		|	ImportItemsWithoutCustomsFilesОстатки.РесурсОстаток
		|ИЗ
		|	РегистрНакопления.ImportItemsWithoutCustomsFiles.Остатки(
		|			&МоментВремени,
		|			Item В (&Items)) КАК ImportItemsWithoutCustomsFilesОстатки";
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Функция ПолучитьОстаткиПоImportShipment(МоментВремени, ImportShipment) Экспорт
	
	// Возвращает таблицу остатков, отобранных по Import shipment
		
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени);
	Запрос.УстановитьПараметр("ImportShipment", ImportShipment);	
	
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ImportItemsWithoutCustomsFilesОстатки.Item,
		|	ImportItemsWithoutCustomsFilesОстатки.РесурсОстаток
		|ИЗ
		|	РегистрНакопления.ImportItemsWithoutCustomsFiles.Остатки(
		|			&МоментВремени,
		|			ImportShipment = &ImportShipment) КАК ImportItemsWithoutCustomsFilesОстатки";
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции
