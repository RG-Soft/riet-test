
Функция СheckPostedRIZP(DocType, GUID)  Экспорт 
	
	УстановитьПривилегированныйРежим(Истина);
	
	Попытка
		
		НовыйGUID = Новый УникальныйИдентификатор(GUID);
		
		Запрос = Новый Запрос;
		
		Если DocType = "ЗакрытиеПоставки" Тогда 
			
			Запрос.УстановитьПараметр("Ссылка", Документы.ЗакрытиеПоставки.ПолучитьСсылку(НовыйGUID));
			
			Запрос.Текст = "ВЫБРАТЬ
				|	РаспределениеИмпортаПоЗакрытиюПоставки.Представление
				|ИЗ
				|	Документ.РаспределениеИмпортаПоЗакрытиюПоставки КАК РаспределениеИмпортаПоЗакрытиюПоставки
				|ГДЕ
				|	РаспределениеИмпортаПоЗакрытиюПоставки.ShipmentСlosing = &Ссылка
				|	И РаспределениеИмпортаПоЗакрытиюПоставки.Проведен";
			
		ИначеЕсли DocType = "InvoiceLinesClassification" Тогда 
			
			Запрос.УстановитьПараметр("Ссылка", Документы.InvoiceLinesClassification.ПолучитьСсылку(НовыйGUID));
			
			Запрос.Текст = "ВЫБРАТЬ
				|	РаспределениеИмпортаПоЗакрытиюПоставки.Представление
				|ИЗ
				|	Документ.InvoiceLinesClassification КАК InvoiceLinesClassification
				|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.РаспределениеИмпортаПоЗакрытиюПоставки КАК РаспределениеИмпортаПоЗакрытиюПоставки
				|		ПО InvoiceLinesClassification.InvoiceLinesMatching = РаспределениеИмпортаПоЗакрытиюПоставки.ShipmentСlosing
				|			И (РаспределениеИмпортаПоЗакрытиюПоставки.Проведен)
				|ГДЕ
				|	InvoiceLinesClassification.Ссылка = &Ссылка";
			
		КонецЕсли;
		
		Выборка = Запрос.Выполнить().Выбрать();
		
		Если Выборка.Следующий() Тогда 
			Возврат Выборка.Представление;
		КонецЕсли;
		
		Возврат "";
		
	Исключение
		
		РГСофт.СообщитьИЗалоггировать("Сheck Posted RIZP", 
			УровеньЖурналаРегистрации.Ошибка, 
			, , "Не удалось выполнить поиск РИЗП по гуиду " + GUID);
			Возврат "Error";
		
	КонецПопытки;

КонецФункции