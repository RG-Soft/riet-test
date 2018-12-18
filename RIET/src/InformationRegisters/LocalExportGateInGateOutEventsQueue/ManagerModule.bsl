
Процедура ЗарегистрироватьEventПриНеобходимости(ExportRequest, EventType, OldEventDate, NewEventDate) Экспорт
	
	Если OldEventDate = NewEventDate Тогда
		Возврат;
	КонецЕсли;
	
	НаборЗаписей = СоздатьНаборЗаписей();
	
	НаборЗаписей.Отбор.ExportRequest.Установить(ExportRequest);
	НаборЗаписей.Отбор.EventType.Установить(EventType);
		
	Если ЗначениеЗаполнено(NewEventDate) Тогда
		
		ТекЗапись = НаборЗаписей.Добавить();
		ТекЗапись.ExportRequest = ExportRequest;
		ТекЗапись.EventType = EventType;		
		ТекЗапись.EventDate = NewEventDate;
		ТекЗапись.LastModified = ТекущаяДата();
				
	КонецЕсли;
	
	НаборЗаписей.Записать(Истина);
	            		
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
		|	LocalExportGateInGateOutEventsQueue.EventType,
		|	LocalExportGateInGateOutEventsQueue.EventDate,
		|	LocalExportGateInGateOutEventsQueue.ExportRequest,
		|	LocalExportGateInGateOutEventsQueue.ExportRequest.Номер КАК ExportRequestNo
		|ИЗ
		|	РегистрСведений.LocalExportGateInGateOutEventsQueue КАК LocalExportGateInGateOutEventsQueue
		|ГДЕ
		|	LocalExportGateInGateOutEventsQueue.LastModified < &LastModifiedBefore";
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Процедура УдалитьЗапись(ExportRequest, EventType) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ExportRequest) Тогда
		ВызватьИсключение "Export request is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(EventType) Тогда
		ВызватьИсключение "Event type is empty!";
	КонецЕсли;
	
	НаборЗаписей = СоздатьНаборЗаписей();
		
	НаборЗаписей.Отбор.ExportRequest.Установить(ExportRequest);
	НаборЗаписей.Отбор.EventType.Установить(EventType);	
	НаборЗаписей.Записать(Истина);
	
КонецПроцедуры