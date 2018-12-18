
//////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ МОДУЛЯ

Процедура ПередЗаписью(Отказ, Замещение)
	
	Для каждого Запись из ЭтотОбъект Цикл
		
		ОбщегоНазначения.УстановитьЗначение(Запись.Text, СокрЛП(Запись.Text));
		ПроверитьЗаполнениеОбязательныхПолейЗаписи(Запись, Отказ);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПроверитьЗаполнениеОбязательныхПолейЗаписи(Запись, Отказ)
	
	КлючЗаписи = Неопределено;
		
	Если НЕ ЗначениеЗаполнено(Запись.LogTo) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""TR"" не заполнено!",
			ПолучитьКлючЗаписи(Запись, КлючЗаписи), "LogTo", "Запись", Отказ);				
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Запись.Date) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Date"" не заполнено!",
			ПолучитьКлючЗаписи(Запись, КлючЗаписи), "Date", "Запись", Отказ);
	ИначеЕсли Запись.Date > ТекущаяДата() Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Date"" больше текущей даты!",
			ПолучитьКлючЗаписи(Запись, КлючЗаписи), "Date", "Запись", Отказ);			
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Запись.User) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""User"" не заполнено!",
			ПолучитьКлючЗаписи(Запись, КлючЗаписи), "User", "Запись", Отказ);
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Запись.LogType) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Log type"" не заполнено!",
			ПолучитьКлючЗаписи(Запись, КлючЗаписи), "LogType", "Запись", Отказ);
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Запись.Text) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Text"" не заполнено!",
			ПолучитьКлючЗаписи(Запись, КлючЗаписи), "Text", "Запись", Отказ);
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьКлючЗаписи(Запись, КлючЗаписи)
	
	Если КлючЗаписи = Неопределено Тогда
		СтруктураЗаписи = Новый Структура("LogTo, LogType, Date");
		ЗаполнитьЗначенияСвойств(СтруктураЗаписи, Запись);
		КлючЗаписи = РегистрыСведений.ShipmentLogs.СоздатьКлючЗаписи(СтруктураЗаписи);
	КонецЕсли; 
		
	Возврат КлючЗаписи;
	
КонецФункции
