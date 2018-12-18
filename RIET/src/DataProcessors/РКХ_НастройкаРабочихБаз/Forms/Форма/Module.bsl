
&НаКлиенте
Процедура УстановкаФункциональныхОпций(Команда)
	
	ОткрытьЗначение(Справочники.РКХ_ФункциональныеОпцииРабочихБаз.ЭтаКонфигурация);
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ИдентификаторРабочейБазы = Константы.FiscalParentCompany.Получить();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьИдентификаторРабочейБазы(Команда)
	
	Константы.FiscalParentCompany.Установить(ИдентификаторРабочейБазы);
	Сообщить("Идентификатор рабочей базы установлен");
	
КонецПроцедуры
