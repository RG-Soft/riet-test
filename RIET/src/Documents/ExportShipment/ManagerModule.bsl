
Функция ПолучитьItemsOfExportShipment(ExportShipment) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ExportShipment) Тогда
		Возврат Новый Массив;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ExportShipment", ExportShipment);
	
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СтрокиИнвойса.Ссылка КАК СтрокаИнвойса
		|ИЗ
		|	Документ.ExportShipment.ExportRequests КАК ExportShipmentExportRequests
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
		|		ПО ExportShipmentExportRequests.ExportRequest = СтрокиИнвойса.ExportRequest
		|			И ((НЕ СтрокиИнвойса.ПометкаУдаления))
		|ГДЕ
		|	ExportShipmentExportRequests.Ссылка = &ExportShipment";
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("СтрокаИнвойса");
	
КонецФункции

Функция ПолучитьExportRequestsToTMSNo(ExportShipment) Экспорт
	
	// Возвращает массив номеров Export requests, входящих в указанный Export shipment, и предназначенных для выгрузки в TMS
	
	Если НЕ ЗначениеЗаполнено(ExportShipment) Тогда
		ВызватьИсключение "Export shipment is empty!";
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ExportShipment", ExportShipment);
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ExportRequests.Номер КАК ERNo
		|ИЗ
		|	Документ.ExportShipment.ExportRequests КАК ExportShipmentsExportRequests
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ExportRequest КАК ExportRequests
		|		ПО ExportShipmentsExportRequests.ExportRequest = ExportRequests.Ссылка
		|			И (ExportRequests.Company.StartOfExportToTMS <= ExportRequests.Submitted)
		|ГДЕ
		|	ExportShipmentsExportRequests.Ссылка = &ExportShipment";
		
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("ERNo");	
	
КонецФункции
