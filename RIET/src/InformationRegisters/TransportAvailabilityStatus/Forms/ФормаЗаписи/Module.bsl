
&НаКлиенте
Процедура StatusНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(Запись.Transport) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"First select 'Transport'!",
			, "Transport", "Запись");
		СтандартнаяОбработка = Ложь;
		Возврат;
	КонецЕсли;
	
	НастроитьСписокВыбораTransportStatuses();
	
КонецПроцедуры

&НаКлиенте
Процедура НастроитьСписокВыбораTransportStatuses()
	      		
	НовыйМассивПараметров = Новый Массив;
	НовыйМассивПараметров.Добавить(Новый ПараметрВыбора("Отбор.Ссылка", 
		ПолучитьМассивСтатусовПоТипуТранспорта(Запись.Transport)));
	НовыеПараметрыВыбора = Новый ФиксированныйМассив(НовыйМассивПараметров);
	Элементы.Status.ПараметрыВыбора = НовыеПараметрыВыбора;
	
КонецПроцедуры	

&НаСервереБезКонтекста
Функция ПолучитьМассивСтатусовПоТипуТранспорта(Transport)
	
	НовыйМассив = Новый Массив;
	TypeOfTransport = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Transport, "TypeOfTransport");
	
	Если TypeOfTransport = Перечисления.TypesOfTransport.Own Тогда
		
		НовыйМассив.Добавить(Перечисления.TransportAvailabilityStatuses.InRepair);
		НовыйМассив.Добавить(Перечисления.TransportAvailabilityStatuses.Decommission);
		
	ИначеЕсли TypeOfTransport = Перечисления.TypesOfTransport.Rental Тогда
		
		НовыйМассив.Добавить(Перечисления.TransportAvailabilityStatuses.StartRental);
		НовыйМассив.Добавить(Перечисления.TransportAvailabilityStatuses.EndOfRental);
				
	КонецЕсли;
	
	НовыйМассив.Добавить(Перечисления.TransportAvailabilityStatuses.Available);
	НовыйМассив.Добавить(Перечисления.TransportAvailabilityStatuses.NotAvailable);
	
	Возврат НовыйМассив;
	
КонецФункции