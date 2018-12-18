
Процедура ПередЗаписью(Отказ, Замещение)
	
	Для Каждого Запись Из ЭтотОбъект Цикл
		
		Если НЕ ЗначениеЗаполнено(Запись.CreatedBy) Тогда
			Запись.CreatedBy = ПараметрыСеанса.ТекущийПользователь;
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Запись.CreationDate) Тогда
			Запись.CreationDate = ТекущаяДата();
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры
