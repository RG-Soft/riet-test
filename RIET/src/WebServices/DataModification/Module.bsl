
Функция ЗаблокироватьДокументДляОбмена(СтруктураПараметровXDTO)
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПараметрыДокумента = СериализаторXDTO.ПрочитатьXDTO(СтруктураПараметровXDTO); 
	
	GUID  = ПараметрыДокумента.GUID;
	Value = ПараметрыДокумента.Value;
	
	ОшибкаЗагрузки = Ложь;
	
	Ссылка = Документы.ЗакрытиеПоставки.ПолучитьСсылку( Новый УникальныйИдентификатор(GUID));
	
	Если ОбщегоНазначения.СсылкаСуществует(Ссылка) Тогда
		
		// { RGS AArsentev 15.12.2017
		ДокЗакрытиеПоставки = Ссылка.ПолучитьОбъект();
		ДокЗакрытиеПоставки.ОбменДанными.Загрузка = Истина;
		ДокЗакрытиеПоставки.ЗапретОбменаРИЕТ = Value;
		ДокЗакрытиеПоставки.Записать();
		// } RGS AArsentev 15.12.2017
		
		Набор = РегистрыСведений.rgsDisableOfExcangeToTB.СоздатьНаборЗаписей();
		Набор.Записывать = Истина;
		Набор.Отбор.Ссылка.Установить(Ссылка);
		Набор.Прочитать();
		
		Попытка
			
			Если Value Тогда
				
				Если Набор.Количество() = 0 Тогда
					
					Запись = Набор.Добавить();
					Запись.Ссылка = Ссылка;
					Набор.Записать(Ложь);
					
				КонецЕсли;
				
			Иначе
				
				Если Набор.Количество() > 0 Тогда
					
					Набор.Удалить(0);
					Набор.Записать();
				КонецЕсли;
				
				
			КонецЕсли;
			
			
			ОписаниеОшибки = "";
			
			
		Исключение
			ОписаниеОшибки =  ОписаниеОшибки();
			ОшибкаЗагрузки = Истина;
		КонецПопытки;
		
	Иначе
		ОписаниеОшибки = "Ссылка в базе РИЕТ не найдена!";
		ОшибкаЗагрузки = Истина;
		ЗаписьЖурналаРегистрации("ОбменWEB.TB-RIET", УровеньЖурналаРегистрации.Предупреждение, Метаданные.Документы.ЗакрытиеПоставки, , "По GUID: " + GUID +" " + ОписаниеОшибки);
	КонецЕсли;
	
	СтруктураПараметров = Новый Структура();
	СтруктураПараметров.Вставить("ОписаниеОшибки", ОписаниеОшибки);
	СтруктураПараметров.Вставить("ОшибкаЗагрузки", ОшибкаЗагрузки);
	
	Возврат СериализаторXDTO.ЗаписатьXDTO(СтруктураПараметров);
	
КонецФункции
