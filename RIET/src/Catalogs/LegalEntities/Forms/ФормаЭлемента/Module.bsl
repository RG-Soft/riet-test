
&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	ТекущийОбъект.ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
	ТекущийОбъект.ModificationDate = ТекущаяДата();
	
КонецПроцедуры
