
Процедура ПередЗаписью(Отказ, Замещение)
	
	Для Каждого Запись Из ЭтотОбъект Цикл
					
		КлючЗаписи = Неопределено;
		
		Если НЕ ЗначениеЗаполнено(Запись.Shipment) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Измерение ""Shipment"" не заполнено!",
				ПолучитьКлючЗаписи(Запись, КлючЗаписи), "Shipment", "Запись", Отказ);			
		КонецЕсли;
			
		Если НЕ ЗначениеЗаполнено(Запись.Stage) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Ресурс ""Stage"" не заполнен!",
				ПолучитьКлючЗаписи(Запись, КлючЗаписи), "Stage", "Запись", Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Запись.StageDate) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Ресурс ""Stage date"" не заполнен!",
				ПолучитьКлючЗаписи(Запись, КлючЗаписи), "StageDate", "Запись", Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Запись.LastModified) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Ресурс ""Last modified"" не заполнено!",
				ПолучитьКлючЗаписи(Запись, КлючЗаписи), "LastModified", "Запись", Отказ);
		КонецЕсли; 
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьКлючЗаписи(Запись, КлючЗаписи)
	
	Если КлючЗаписи = Неопределено Тогда
		СтруктураЗаписи = Новый Структура("Shipment");
		ЗаполнитьЗначенияСвойств(СтруктураЗаписи, Запись);
		КлючЗаписи = РегистрыСведений.ShipmentsForSubscriptions.СоздатьКлючЗаписи(СтруктураЗаписи);
	КонецЕсли; 
		
	Возврат КлючЗаписи;
	
КонецФункции