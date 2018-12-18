
Процедура ПередЗаписью(Отказ, Замещение)
	
	Для Каждого Запись Из ЭтотОбъект Цикл
		 
		Если НЕ ЗначениеЗаполнено(Запись.LimitForApprovalLevel1ManualPlanning) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Limit for approval Level 1 manual planning (SLB USD)' is empty!",
			, "LimitForApprovalLevel1ManualPlanning", "Запись", Отказ);			
		КонецЕсли;

		Если НЕ ЗначениеЗаполнено(Запись.LimitForApprovalLevel1AutomaticPlanning) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Limit for approval Level 1 automatic planning (SLB USD)' is empty!",
			, "LimitForApprovalLevel1AutomaticPlanning", "Запись", Отказ);			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры
