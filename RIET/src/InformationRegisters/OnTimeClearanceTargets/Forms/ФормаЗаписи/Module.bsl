
&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	РГСофтКлиент.ПроверитьНеобходимостьЗаписиСправочника(Модифицированность, Отказ);
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	ТекущийОбъект.ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
	ТекущийОбъект.ModificationDate = ТекущаяДата();
	
КонецПроцедуры

