#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда


Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)

	Если НачалоПериода > КонецПериода Тогда
		ТекстСообщения = НСтр("ru = 'Неправильно задан период формирования отчета!
			|Дата начала больше даты окончания периода.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "Отчет.НачалоПериода",, Отказ);
	КонецЕсли;

КонецПроцедуры

#КонецЕсли