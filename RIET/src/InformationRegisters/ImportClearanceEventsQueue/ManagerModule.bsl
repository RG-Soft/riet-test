
Процедура ЗарегистрироватьEventПриНеобходимости(Shipment, EventType, OldEventDate, NewEventDate, User) Экспорт
	
	TMSСервер.ЗарегистрироватьClearanceEventПриНеобходимости(СоздатьНаборЗаписей(), Shipment, EventType, OldEventDate, NewEventDate, User);
	
КонецПроцедуры

Функция ПолучитьТаблицуLastModifiedBefore(LastModifiedBefore) Экспорт
	
	// Возвращает таблицу данных регистра, у которых Last modified меньше указанной
	
	Если НЕ ЗначениеЗаполнено(LastModifiedBefore) Тогда
		ВызватьИсключение "Last modified before is empty!";
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("LastModifiedBefore", LastModifiedBefore);
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ImportClearanceEventsQueue.EventType,
		|	ImportClearanceEventsQueue.EventDate,
		|	ImportClearanceEventsQueue.Shipment,
		|	ImportClearanceEventsQueue.User,
		|	ImportClearanceEventsQueue.User.Код КАК Alias
		|ИЗ
		|	РегистрСведений.ImportClearanceEventsQueue КАК ImportClearanceEventsQueue
		|ГДЕ
		|	ImportClearanceEventsQueue.LastModified < &LastModifiedBefore";
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Процедура УдалитьЗапись(Shipment, EventType) Экспорт
		
	TMSСервер.УдалитьЗаписьClearanceEvent(СоздатьНаборЗаписей(), Shipment, EventType);	
	
КонецПроцедуры
