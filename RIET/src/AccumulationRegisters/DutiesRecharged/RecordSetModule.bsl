
Процедура ПередЗаписью(Отказ, Замещение)
	
	Для Каждого Запись Из ЭтотОбъект Цикл
		
		Запись.Activity = СокрЛП(Запись.Activity);
		
		Если НЕ ЗначениеЗаполнено(Запись.СуммаФискальная) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In register ""Duties recharge"" ""Fiscal sum"" is empty!",
				, "Запись", Отказ);				
		КонецЕсли;
					
	КонецЦикла;
			
КонецПроцедуры