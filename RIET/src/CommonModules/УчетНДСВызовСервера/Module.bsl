/////////////////////////////////////////////////////////////
//ВЕРСИЯ ПРОЦЕДУР И ФУНКЦИЙ ОБЛАСТИ "ТиповаяБухгалтерия": БУХ. КОРП. 3.0.38.42 бета

#Область ТиповаяБухгалтерия

Функция РеквизитыДляНадписиОСчетеФактуреВыданном(Знач Документ, СтруктураОтбора = Неопределено) Экспорт

	РеквизитыСФ = УчетНДСПереопределяемый.РеквизитыДляНадписиОСчетеФактуреВыданном(Документ, СтруктураОтбора);
	 
	Если РеквизитыСФ = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
		
	Результат = Новый Структура;
	Результат.Вставить("Ссылка",               РеквизитыСФ.Ссылка);
	Результат.Вставить("Представление",        "" + РеквизитыСФ.Ссылка);
	Результат.Вставить("КраткоеПредставление", ПредставлениеСчетФактураВыданный(РеквизитыСФ));
	
	Возврат Результат;
	
КонецФункции 

Функция ПолучитьИдентификаторМакетаРасшифровкиДекларацииПоНДС(Знач ПараметрыОтчета, Знач Показатель, ПользовательскиеНастройки) Экспорт
	
	ИдентификаторМакета = "";
	
	ТаблицаРасшифровок = ПолучитьИзВременногоХранилища(ПараметрыОтчета.АдресВременногоХранилищаРасшифровки);
	
	Если ТипЗнч(ТаблицаРасшифровок) = Тип("ТаблицаЗначений") Тогда
		
		НомерТекущейСтраницы = 0;
		
		ПараметрыОтчета.Свойство("НомерТекущейСтраницы", НомерТекущейСтраницы);
		
		Если НомерТекущейСтраницы = Неопределено ИЛИ НомерТекущейСтраницы = 0 Тогда
			ИмяПоказателя = Показатель;
		Иначе
			ИмяПоказателя = Показатель + "_" + НомерТекущейСтраницы;
		КонецЕсли;
		
		Расшифровка = ТаблицаРасшифровок.Найти(ИмяПоказателя,"ИмяПоказателя");
		
		Если Расшифровка <> Неопределено Тогда
			
			ДополнительныеПараметры = Расшифровка.ДополнительныеПараметры;
			
			ИдентификаторМакета = ДополнительныеПараметры.ИдентификаторМакета;
			
			Если ИдентификаторМакета = "ОткрытьОбъект" Тогда
				
				ДополнительныеПараметры.Свойство("Объект", ИдентификаторМакета);
				
			Иначе
				
				ДополнительныеПараметры.Свойство("ПользовательскиеНастройки", ПользовательскиеНастройки);
				
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат ИдентификаторМакета;
	
КонецФункции  
 
// РеквизитыСФ - Структура, см. УчетНДСПереопределяемый.РеквизитыДляНадписиОСчетеФактуреВыданном
Функция ПредставлениеСчетФактураВыданный(РеквизитыСФ)
	
	ПараметрыСтроки = Новый Структура;
	ПараметрыСтроки.Вставить("НомерСчетаФактуры", ?(ЗначениеЗаполнено(РеквизитыСФ.НомерСчетаФактуры), РеквизитыСФ.НомерСчетаФактуры, "..."));
	ПараметрыСтроки.Вставить("ДатаСчетаФактуры", ?(ЗначениеЗаполнено(РеквизитыСФ.ДатаСчетаФактуры),  Формат(РеквизитыСФ.ДатаСчетаФактуры, "ДЛФ=D"), "..."));
	
	Если РеквизитыСФ.Исправление Тогда
		ШаблонСтроки = ВернутьСтр("ru='[НомерСчетаФактуры] (испр. [НомерИсправления]) от [ДатаИсправления]'");
		ПараметрыСтроки.Вставить("НомерИсправления", ?(ЗначениеЗаполнено(РеквизитыСФ.НомерИсправления), РеквизитыСФ.НомерИсправления, "..."));
		ПараметрыСтроки.Вставить("ДатаИсправления", ?(ЗначениеЗаполнено(РеквизитыСФ.ДатаИсправления),  Формат(РеквизитыСФ.ДатаИсправления, "ДЛФ=D"), "..."));
	Иначе
		ШаблонСтроки = ВернутьСтр("ru='[НомерСчетаФактуры] от [ДатаСчетаФактуры]'");
	КонецЕсли;
	
	Возврат СтроковыеФункцииКлиентСервер.ВставитьПараметрыВСтроку(ШаблонСтроки, ПараметрыСтроки);
	
КонецФункции

Функция РеквизитыДляНадписиОСчетеФактуреПолученном(Знач Документ, СтруктураОтбора = Неопределено) Экспорт

	РеквизитыСФ = УчетНДСПереопределяемый.РеквизитыДляНадписиОСчетеФактуреПолученном(Документ, СтруктураОтбора);
	
	Если РеквизитыСФ = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
		
	Результат = Новый Структура;
	Результат.Вставить("Ссылка",               РеквизитыСФ.Ссылка);
	Результат.Вставить("Представление",        "" + РеквизитыСФ.Ссылка);
	Результат.Вставить("КраткоеПредставление", ПредставлениеСчетФактураПолученный(РеквизитыСФ));
	
	Возврат Результат;
	
КонецФункции 

// РеквизитыСФ - Структура, см. УчетНДСПереопределяемый.РеквизитыДляНадписиОСчетеФактуреПолученном
Функция ПредставлениеСчетФактураПолученный(РеквизитыСФ)
	
	ПараметрыСтроки = Новый Структура;
	ПараметрыСтроки.Вставить("НомерСчетаФактуры", ?(ЗначениеЗаполнено(РеквизитыСФ.НомерСчетаФактуры), РеквизитыСФ.НомерСчетаФактуры, "..."));
	ПараметрыСтроки.Вставить("ДатаСчетаФактуры", ?(ЗначениеЗаполнено(РеквизитыСФ.ДатаСчетаФактуры),  Формат(РеквизитыСФ.ДатаСчетаФактуры, "ДЛФ=D"), "..."));
	
	Если РеквизитыСФ.Исправление Тогда
		ШаблонСтроки = ВернутьСтр("ru='[НомерСчетаФактуры] (испр. [НомерИсправления]) от [ДатаИсправления]'");
		ПараметрыСтроки.Вставить("НомерИсправления", ?(ЗначениеЗаполнено(РеквизитыСФ.НомерИсправления), РеквизитыСФ.НомерИсправления, "..."));
		ПараметрыСтроки.Вставить("ДатаИсправления", ?(ЗначениеЗаполнено(РеквизитыСФ.ДатаИсправления),  Формат(РеквизитыСФ.ДатаИсправления, "ДЛФ=D"), "..."));
	Иначе
		Если НачалоДня(РеквизитыСФ.ДатаСчетаФактуры) = НачалоДня(РеквизитыСФ.Дата) Тогда
			ШаблонСтроки = ВернутьСтр("ru='[НомерСчетаФактуры] от [ДатаСчетаФактуры]'");
		Иначе
			ПараметрыСтроки.Вставить("ДатаПолученияСчетаФактуры", Формат(РеквизитыСФ.Дата, "ДЛФ=D"));
			ШаблонСтроки = ВернутьСтр("ru='[НомерСчетаФактуры] от [ДатаСчетаФактуры], получен [ДатаПолученияСчетаФактуры]'");
		КонецЕсли;
	КонецЕсли;
	
	Возврат СтроковыеФункцииКлиентСервер.ВставитьПараметрыВСтроку(ШаблонСтроки, ПараметрыСтроки);
	
КонецФункции

Функция СоздатьСчетФактуруПолученныйНаОсновании(Основание, НомерСчетаФактурыПолученного, ДатаСчетаФактурыПолученного, Продавец = Неопределено, СтруктураОтбора = Неопределено) Экспорт
	
	СчетФактура = УчетНДСПереопределяемый.НайтиПодчиненныйСчетФактуруПолученный(Основание,,,СтруктураОтбора);
	
	Если СчетФактура = Неопределено Тогда
		
		//Обновление на бух. корп. 3.0.38.43
		//Если ТипЗнч(Основание) = Тип("ДокументСсылка.КорректировкаПоступления") Тогда			
		////убрано				
		//Иначе
		//<=
		// Счет-фактура на поступление
		СчетФактура = УчетНДСПереопределяемый.ДобавитьОснованиеВСчетФактуруПолученный(Основание, НомерСчетаФактурыПолученного, ДатаСчетаФактурыПолученного);
		
		Если СчетФактура = Неопределено Тогда 
			СчетФактура = УчетНДСПереопределяемый.СоздатьСчетФактуруПолученныйНаОсновании(Основание, НомерСчетаФактурыПолученного, ДатаСчетаФактурыПолученного, Продавец);
		КонецЕсли;
		
		//КонецЕсли; //Обновление на бух. корп. 3.0.38.43
		
	КонецЕсли;
	
	Результат = РеквизитыДляНадписиОСчетеФактуреПолученном(СчетФактура);
	
	Возврат Результат;
	
КонецФункции

Функция СоздатьСчетФактуруВыданныйНаОсновании(Основание, СтруктураОтбора = Неопределено) Экспорт
	
	СчетФактура = УчетНДСПереопределяемый.НайтиПодчиненныйСчетФактуруВыданныйНаРеализацию(Основание,,, СтруктураОтбора);
	
	Если СчетФактура = Неопределено Тогда
		СчетФактура = УчетНДСПереопределяемый.СоздатьСчетФактуруВыданныйНаОсновании(Основание);
	КонецЕсли;
	
	Результат = РеквизитыДляНадписиОСчетеФактуреВыданном(СчетФактура);
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти