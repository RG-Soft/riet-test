
//////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ, Замещение)
	
	Для каждого Запись из ЭтотОбъект Цикл
		
		РГСофтКлиентСервер.УстановитьЗначение(Запись.Text, СокрЛП(Запись.Text));
		ПроверитьЗаполнениеОбязательныхПолейЗаписи(Запись, Отказ);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПроверитьЗаполнениеОбязательныхПолейЗаписи(Запись, Отказ)
	
	КлючЗаписи = Неопределено;
		
	Если НЕ ЗначениеЗаполнено(Запись.LogTo) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Export request"" is empty!",
			ПолучитьКлючЗаписи(Запись, КлючЗаписи), "LogTo", "Запись", Отказ);				
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Запись.Date) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Date"" is empty!",
			ПолучитьКлючЗаписи(Запись, КлючЗаписи), "Date", "Запись", Отказ);
	ИначеЕсли Запись.Date > ТекущаяДата() Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Date"" can not be later than the current date!",
			ПолучитьКлючЗаписи(Запись, КлючЗаписи), "Date", "Запись", Отказ);			
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Запись.User) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""User"" is empty!",
			ПолучитьКлючЗаписи(Запись, КлючЗаписи), "User", "Запись", Отказ);			
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Запись.Text) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Text"" is empty!",
			ПолучитьКлючЗаписи(Запись, КлючЗаписи), "Text", "Запись", Отказ);
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьКлючЗаписи(Запись, КлючЗаписи)
	
	Если КлючЗаписи = Неопределено Тогда
		СтруктураЗаписи = Новый Структура("LogTo, Date");
		ЗаполнитьЗначенияСвойств(СтруктураЗаписи, Запись);
		КлючЗаписи = РегистрыСведений.ExportRequestsLogs.СоздатьКлючЗаписи(СтруктураЗаписи);
	КонецЕсли; 
		
	Возврат КлючЗаписи;
	
КонецФункции 