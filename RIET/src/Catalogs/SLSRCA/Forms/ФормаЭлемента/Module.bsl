
&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	РГСофт.ЗаполнитьModification(ТекущийОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура КодПриИзменении(Элемент)
	
	Если ЗначениеЗаполнено(СокрЛП(Объект.Код)) И НЕ ЗначениеЗаполнено(СокрЛП(Объект.EMail)) Тогда
		Объект.EMail = СокрЛП(Объект.Код) + "@slb.com";	
	КонецЕсли;
	
КонецПроцедуры
