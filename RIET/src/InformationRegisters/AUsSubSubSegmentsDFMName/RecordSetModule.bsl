
Процедура ПередЗаписью(Отказ, Замещение)
	
	Для Каждого Запись Из ЭтотОбъект Цикл
		
		Если НЕ ЗначениеЗаполнено(Запись.DFMName) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле ""DFM name""!",
				, "DFMName", , Отказ);
			
		КонецЕсли;
		
	КонецЦикла;

КонецПроцедуры
