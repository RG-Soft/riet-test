
//////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ПередЗаписью(Отказ, Замещение)
	
	Для каждого Запись из ЭтотОбъект Цикл
		
		РГСофтКлиентСервер.УстановитьЗначение(Запись.PONoExportRequestNo, СокрЛП(Запись.PONoExportRequestNo));
		
		КлючЗаписи = Неопределено;
		
		Если НЕ ЗначениеЗаполнено(Запись.User) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Fill in the field ""User"" please!",
				ПолучитьКлючЗаписи(Запись, КлючЗаписи), "User", "Запись", Отказ);			
		КонецЕсли;
		
		Если НЕ Запись.ProjectMobilizationSubscribe Тогда
		
			Если НЕ ЗначениеЗаполнено(Запись.PONoExportRequestNo) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Fill in the field ""PO no. / Export request no."" please!",
					ПолучитьКлючЗаписи(Запись, КлючЗаписи), "PONoExportRequestNo", "Запись", Отказ);
			КонецЕсли;
				
		Иначе
			
			// проверим, что заполнены все поля для подписки
			Если НЕ ЗначениеЗаполнено(Запись.ProjectMobilization) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Fill in the field ""Project mobilization"" please!",
					ПолучитьКлючЗаписи(Запись, КлючЗаписи), "ProjectMobilization", "Запись", Отказ);
			КонецЕсли;
				
			Если НЕ ЗначениеЗаполнено(Запись.ProjectMobilization) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Fill in the field ""Frequency"" please!",
					ПолучитьКлючЗаписи(Запись, КлючЗаписи), "Frequency", "Запись", Отказ);
			КонецЕсли;	
				
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьКлючЗаписи(Запись, КлючЗаписи)
	
	Если КлючЗаписи = Неопределено Тогда
		СтруктураЗаписи = Новый Структура("User, PONoExportRequestNo, POLineNo, ProjectMobilization, ProjectMobilizationSubscribe, Frequency");
		ЗаполнитьЗначенияСвойств(СтруктураЗаписи, Запись);
		КлючЗаписи = РегистрыСведений.ImportExportTrackingSubscriptions.СоздатьКлючЗаписи(СтруктураЗаписи);
	КонецЕсли; 
		
	Возврат КлючЗаписи;
	
КонецФункции