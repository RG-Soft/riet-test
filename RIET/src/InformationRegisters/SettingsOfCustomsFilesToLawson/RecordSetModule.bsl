
Процедура ПередЗаписью(Отказ, Замещение)
	
	Для Каждого Запись Из ЭтотОбъект Цикл
		
		// Дозаполним реквизиты
		
		Если Запись.Type = Перечисления.TypesOfCustomsFilesUnloading.FixedParameters Тогда
			
			Запись.Activity = СокрЛП(Запись.Activity);
			Запись.Account = СокрЛП(Запись.Account);
			Запись.SubAccount = СокрЛП(Запись.SubAccount);
		
		Иначе
		
			Запись.AU = Неопределено;
			Запись.Activity = "";
			Запись.Account = "";
			Запись.SubAccount = "";
		
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(Запись.CreatedBy) Тогда 
	    	Запись.CreatedBy = ПараметрыСеанса.ТекущийПользователь;
		КонецЕсли;
		
	    Если Не ЗначениеЗаполнено(Запись.CreationDate) Тогда 
	    	Запись.CreationDate = ТекущаяДата();
		КонецЕсли;
		
		// Проверим реквизиты
		
		Если НЕ ЗначениеЗаполнено(Запись.ParentCompany) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Parent company' is empty!",
				, "Период", "Запись", Отказ);			
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Запись.Период) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Start date' is empty!",
				, "Период", "Запись", Отказ);			
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Запись.Type) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Type' is empty!",
				, "Type", "Запись", Отказ);			
		КонецЕсли;
				
		Если Запись.Type = Перечисления.TypesOfCustomsFilesUnloading.FixedParameters Тогда
			   						
			Если НЕ ЗначениеЗаполнено(Запись.AU) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"'AU' is empty!",
					, "AU", "Запись", Отказ);
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(Запись.Account) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"'Account' is empty!",
					, "Account", "Запись", Отказ);
			КонецЕсли;
							
		КонецЕсли;
				      	           		
	КонецЦикла;
	
КонецПроцедуры
