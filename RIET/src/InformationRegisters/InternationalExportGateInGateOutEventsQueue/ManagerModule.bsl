
Процедура ЗарегистрироватьEventПриНеобходимости(Shipment, EventType, OldEventDate, NewEventDate) Экспорт
	
	Если OldEventDate = NewEventDate Тогда
		Возврат;
	КонецЕсли;
	
	НаборЗаписей = СоздатьНаборЗаписей();
	
	НаборЗаписей.Отбор.Shipment.Установить(Shipment);
	НаборЗаписей.Отбор.EventType.Установить(EventType);
		
	Если ЗначениеЗаполнено(NewEventDate) Тогда
		
		ТекЗапись = НаборЗаписей.Добавить();
		ТекЗапись.Shipment = Shipment;
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
		|	InternationalExportGateInGateOutEventsQueue.EventType,
		|	InternationalExportGateInGateOutEventsQueue.EventDate,
		|	InternationalExportGateInGateOutEventsQueue.Shipment
		|ИЗ
		|	РегистрСведений.InternationalExportGateInGateOutEventsQueue КАК InternationalExportGateInGateOutEventsQueue
		|ГДЕ
		|	InternationalExportGateInGateOutEventsQueue.LastModified < &LastModifiedBefore";
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Процедура УдалитьЗапись(Shipment, EventType) Экспорт
	
	Если НЕ ЗначениеЗаполнено(Shipment) Тогда
		ВызватьИсключение "Shipment is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(EventType) Тогда
		ВызватьИсключение "Event type is empty!";
	КонецЕсли;
	
	НаборЗаписей = СоздатьНаборЗаписей();
		
	НаборЗаписей.Отбор.Shipment.Установить(Shipment);
	НаборЗаписей.Отбор.EventType.Установить(EventType);	
	НаборЗаписей.Записать(Истина);
	
КонецПроцедуры