
Функция ПолучитьОстаткиПоItems(МоментВремени, Items) Экспорт
	
	// Возвращает таблицу остатков, отобранных по Items 		
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени);
	Запрос.УстановитьПараметр("Items", Items);
		
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ExportItemsWithoutCustomsFilesОстатки.Item,
		|	ExportItemsWithoutCustomsFilesОстатки.ExportRequest,
		|	ExportItemsWithoutCustomsFilesОстатки.ExportShipment,
		|	ExportItemsWithoutCustomsFilesОстатки.РесурсОстаток
		|ИЗ
		|	РегистрНакопления.ExportItemsWithoutCustomsFiles.Остатки(&МоментВремени, Item В (&Items)) КАК ExportItemsWithoutCustomsFilesОстатки";
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Функция ПолучитьОстаткиПоExportShipment(МоментВремени, ExportShipment) Экспорт
	
	// Возвращает таблицу остатков, отобранных по Export shipment
		
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени);
	Запрос.УстановитьПараметр("ExportShipment", ExportShipment);
		
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ExportItemsWithoutCustomsFilesОстатки.Item,
		|	ExportItemsWithoutCustomsFilesОстатки.ExportRequest,
		|	ExportItemsWithoutCustomsFilesОстатки.РесурсОстаток
		|ИЗ
		|	РегистрНакопления.ExportItemsWithoutCustomsFiles.Остатки(
		|			&МоментВремени,
		|			ExportShipment = &ExportShipment) КАК ExportItemsWithoutCustomsFilesОстатки";
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции
