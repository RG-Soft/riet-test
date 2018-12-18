#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

	
#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	КонтекстЭДО = ДокументооборотСКОВызовСервера.ПолучитьОбработкуЭДО();
	КонтекстЭДО.ПередЗаписьюОбъекта(ЭтотОбъект, Отказ);
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(СообщениеОснование)
	
	КонтекстЭДО = ДокументооборотСКОВызовСервера.ПолучитьОбработкуЭДО();
	КонтекстЭДО.ОбработкаЗаполненияОбъекта(ЭтотОбъект, СообщениеОснование);
	
	ДатаСообщения = ТекущаяДатаСеанса();
	
	Если ТипЗнч(СообщениеОснование) = Тип("Структура")
		И СообщениеОснование.Свойство("Отправитель")
		И ТипЗнч(СообщениеОснование.Отправитель) = Тип("СправочникСсылка.Организации") Тогда
		Организация = СообщениеОснование.Отправитель;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	
	ИдентификаторОснования = Неопределено;
	ДатаОтправки = Неопределено;
	ДатаСообщения = ТекущаяДатаСеанса();
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли


