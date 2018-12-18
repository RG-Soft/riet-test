
Функция ПолучитьПоTMSName(TMSName) Экспорт
	
	Если TMSName = "Low" ИЛИ TMSName = "3" Тогда 
		Возврат Перечисления.Urgencies.Standard;
		
	ИначеЕсли TMSName = "Medium" ИЛИ TMSName = "2" Тогда
		Возврат Перечисления.Urgencies.Urgent;	
		
	ИначеЕсли TMSName = "High" ИЛИ TMSName = "1" Тогда
		Возврат Перечисления.Urgencies.Standard;
		
	Иначе
		Возврат Неопределено;
		
	КонецЕсли;
	
КонецФункции