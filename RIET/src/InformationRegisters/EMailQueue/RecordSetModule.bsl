
Процедура ПередЗаписью(Отказ, Замещение)
	
	Для Каждого Запись Из ЭтотОбъект Цикл
		
		РГСофтКлиентСервер.УстановитьЗначение(Запись.EMail, СокрЛП(Запись.EMail));
		РГСофтКлиентСервер.УстановитьЗначение(Запись.Subject, СокрЛП(Запись.Subject));
		РГСофтКлиентСервер.УстановитьЗначение(Запись.Body, СокрЛП(Запись.Body));
		
		КлючЗаписи = Неопределено;
		
		Если НЕ ЗначениеЗаполнено(Запись.EMail) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				// { RGS ASeryakov 05.06.2015 14:00:00 S-I-0005399
				//"Измерение ""E-mail"" не заполнено!",
				"Ресурс ""E-mail"" не заполнено!",
				// { RGS ASeryakov 05.06.2015 14:00:00 S-I-0005399
				ПолучитьКлючЗаписи(Запись, КлючЗаписи), "EMail", "Запись", Отказ);			
		КонецЕсли;
			
		Если НЕ ЗначениеЗаполнено(Запись.Date) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Измерение ""Date"" не заполнено!",
				ПолучитьКлючЗаписи(Запись, КлючЗаписи), "Date", "Запись", Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Запись.Subject) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Ресурс ""Subject"" не заполнен!",
				ПолучитьКлючЗаписи(Запись, КлючЗаписи), "Subject", "Запись", Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Запись.Body) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Ресурс ""Body"" не заполнен!",
				ПолучитьКлючЗаписи(Запись, КлючЗаписи), "Body", "Запись", Отказ);
		КонецЕсли; 
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьКлючЗаписи(Запись, КлючЗаписи)
	
	Если КлючЗаписи = Неопределено Тогда
		// { RGS ASeryakov 05.06.2015 14:00:00 S-I-0005399
		//СтруктураЗаписи = Новый Структура("EMail, Date");
		СтруктураЗаписи = Новый Структура("GUID, Date");
		// { RGS ASeryakov 05.06.2015 14:00:00 S-I-0005399
		ЗаполнитьЗначенияСвойств(СтруктураЗаписи, Запись);
		КлючЗаписи = РегистрыСведений.EMailQueue.СоздатьКлючЗаписи(СтруктураЗаписи);
	КонецЕсли; 
		
	Возврат КлючЗаписи;
	
КонецФункции