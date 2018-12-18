
Функция ПолучитьПоCountryCodeИTMSID(CountryCode, TMSID) Экспорт
	
	// Получает Process level по CountryCode (3х буквенный) и TMSID
	// TMSID недостаточно, так как в TMS есть Corporation KZUZ, а у нас это 2 разных процесс-левела
	// Если Process level не найден или найдено несколько - возвращает Неопределено
	
	Если НЕ ЗначениеЗаполнено(CountryCode) ИЛИ НЕ ЗначениеЗаполнено(TMSID) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("TMSID", TMSID);
	Запрос.УстановитьПараметр("CountryCode", CountryCode);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ProcessLevelsFromTMSIDs.Ссылка
		|ИЗ
		|	Справочник.ProcessLevels.FromTMSIDs КАК ProcessLevelsFromTMSIDs
		|ГДЕ
		|	ProcessLevelsFromTMSIDs.Ссылка.Country.TMSID = &CountryCode
		|	И ProcessLevelsFromTMSIDs.FromTMSID = &TMSID
		|	И НЕ ProcessLevelsFromTMSIDs.Ссылка.ПометкаУдаления";
		
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;

    Выборка = Результат.Выбрать();
	Если Выборка.Количество() > 1 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Выборка.Следующий();
	Возврат Выборка.Ссылка;	
	
КонецФункции

Функция ПолучитьПоRCACountry(RCACountry) Экспорт
		
	Возврат РГСофт.НайтиСсылку("Справочник", "ProcessLevels", "Country", RCACountry);
		
КонецФункции