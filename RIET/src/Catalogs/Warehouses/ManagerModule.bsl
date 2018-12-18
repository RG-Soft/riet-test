
Функция НайтиСоздатьПоTMSID(TMSID) Экспорт
	
	// Находит или создает Location по TMSID
	// Может выбросить исключения, если не удалось запросить данные из TMS или если не удалось записать Location
	
	// Начнем транзакцию, чтобы избежать грязного чтения и прочих сюрпризов
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	Location = НайтиПоTMSID(TMSID);
	
	Если ЗначениеЗаполнено(Location) Тогда
		ЗафиксироватьТранзакцию();
		Возврат Location;	
	КонецЕсли;
	     		
	Location = СоздатьИзTMSID(TMSID);
	
	ЗафиксироватьТранзакцию();
	
	Возврат Location;
	
КонецФункции

Функция НайтиПоTMSID(TMSID) Экспорт
	
	Если НЕ ЗначениеЗаполнено(TMSID) Тогда
		Возврат Неопределено;	
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("TMSID", TMSID);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Locations.Ссылка
		|ИЗ
		|	Справочник.Warehouses КАК Locations
		|ГДЕ
		|	НЕ Locations.ПометкаУдаления
		|	И Locations.InTMS
		|	И Locations.Код = &TMSID";
		
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Выборка = Результат.Выбрать();
	Выборка.Следующий();
	Возврат Выборка.Ссылка;
		
КонецФункции

Функция СоздатьИзTMSID(TMSID)
	
	// Создает элемент справочника по TMS ID
	// При этом вначале получает данные из TMS
	// Потом создает элемент справочника по этим данным
	
	Если НЕ ЗначениеЗаполнено(TMSID) Тогда
		ВызватьИсключение "TMS ID is empty!";
	КонецЕсли;
	
	СтруктураTMS = Обработки.PullMasterDataFromTMS.ПолучитьРеквизитыLocation(TMSID);
		
	Возврат СоздатьИзСтруктурыTMS(СтруктураTMS);
	
КонецФункции

Функция СоздатьИзСтруктурыTMS(СтруктураTMS)
	
	// Создает TMS Location из структуры данных TMS
	УстановитьПривилегированныйРежим(Истина);
	
	СправочникОбъект = СоздатьЭлемент();
	
	ОбновитьИзСтруктурыTMS(СправочникОбъект, СтруктураTMS);
	         		
	СправочникОбъект.Записать();
	
	Возврат СправочникОбъект.Ссылка;
	
КонецФункции

Процедура ОбновитьИзСтруктурыTMS(СправочникОбъект, СтруктураTMS)
	
	// Обновим реквизиты шапки
	ОбщегоНазначения.УстановитьЗначение(СправочникОбъект.InTMS, Истина);
	
	Если СокрЛП(СправочникОбъект.Код) <> СтруктураTMS.Code Тогда
		СправочникОбъект.Код = СтруктураTMS.Code;
	КонецЕсли;
	
	ОбщегоНазначения.УстановитьЗначение(СправочникОбъект.Наименование, СтруктураTMS.Name);
	// Если в TMS наименование не прописано - подставим вместо него код
	Если НЕ ЗначениеЗаполнено(СправочникОбъект.Наименование) Тогда
		СправочникОбъект.Наименование = СправочникОбъект.Код;	
	КонецЕсли;
	
	ОбщегоНазначения.УстановитьЗначение(СправочникОбъект.CountryCode, СтруктураTMS.CountryCode);	
	
	ProcessLevel = ImportExportСерверПовтИспСеанс.ПолучитьProcessLevelПоCountryCodeИTMSID(СтруктураTMS.CountryCode, СтруктураTMS.ProcessLevel);
	Если ЗначениеЗаполнено(ProcessLevel) Тогда
		ОбщегоНазначения.УстановитьЗначение(СправочникОбъект.ProcessLevel, ProcessLevel);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СокрЛП(СтруктураTMS.City)) Тогда 
		
		CityСсылка = Справочники.Cities.НайтиПоКоду(СокрЛП(СтруктураTMS.City));
		
		Если Не ЗначениеЗаполнено(CityСсылка) Тогда 
			CityОбъект = Справочники.Cities.СоздатьЭлемент();
			CityОбъект.Код = СокрЛП(СокрЛП(СтруктураTMS.City));
			CityОбъект.Записать();
			CityСсылка = CityОбъект.Ссылка;
		КонецЕсли;
		
		ОбщегоНазначения.УстановитьЗначение(СправочникОбъект.City, CityСсылка);
		
	КонецЕсли;

	ОбщегоНазначения.УстановитьЗначение(СправочникОбъект.Address1, СтруктураTMS.Address1);
	
	ОбщегоНазначения.УстановитьЗначение(СправочникОбъект.Address2, СтруктураTMS.Address2);
	
	ОбщегоНазначения.УстановитьЗначение(СправочникОбъект.Address3, СтруктураTMS.Address3);
	
	ОбщегоНазначения.УстановитьЗначение(СправочникОбъект.ContactName, СтруктураTMS.ContactName);
	
	ОбщегоНазначения.УстановитьЗначение(СправочникОбъект.ContactPhone, СтруктураTMS.ContactPhone);
	
	ОбщегоНазначения.УстановитьЗначение(СправочникОбъект.ContactEMail, СтруктураTMS.ContactEMail);
	
	// Обновим ТЧ Roles
	ИндексСтрокиТЧ = 0;
	Для Каждого Role Из СтруктураTMS.Roles Цикл
		
		Если ИндексСтрокиТЧ < СправочникОбъект.Roles.Количество() Тогда
			СтрокаТЧ = СправочникОбъект.Roles[ИндексСтрокиТЧ];
		Иначе
			СтрокаТЧ = СправочникОбъект.Roles.Добавить();
		КонецЕсли;
		
		ОбщегоНазначения.УстановитьЗначение(СтрокаТЧ.Role, Role);
		
		ИндексСтрокиТЧ = ИндексСтрокиТЧ + 1;
		
	КонецЦикла;

	Пока ИндексСтрокиТЧ < СправочникОбъект.Roles.Количество() Цикл
		СправочникОбъект.Roles.Удалить(ИндексСтрокиТЧ);	
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбновитьTMSLocations() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Warehouses.Ссылка
		|ИЗ
		|	Справочник.Warehouses КАК Warehouses
		|ГДЕ
		|	Warehouses.InTMS
		|	И НЕ Warehouses.ПометкаУдаления";
		
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
		
		СправочникОбъект = Выборка.Ссылка.ПолучитьОбъект();
		
		// ТУТ НЕПОНЯТНО, ОШИБКА ВЫВАЛИВАЕТСЯ ПОТОМУ ЧТО TMS УПАЛ, ИЛИ ПОТОМУ ЧТО НЕТ ТАКОГО ЭЛЕМЕНТА
		Попытка
			СтруктураTMS = Обработки.PullMasterDataFromTMS.ПолучитьРеквизитыLocation(СокрЛП(СправочникОбъект.Код));
		Исключение
			ОтменитьТранзакцию();
			Продолжить;
		КонецПопытки;
		
		ОбновитьИзСтруктурыTMS(СправочникОбъект, СтруктураTMS);
		
		Если СправочникОбъект.Модифицированность() Тогда
			СправочникОбъект.Записать();	
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка)
	
	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
		СтандартнаяОбработка = Ложь;
		Поля.Добавить("NameRus");
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	
	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
		СтандартнаяОбработка = Ложь;
	  	Представление = Данные.NameRus;
	КонецЕсли;
	 	       
КонецПроцедуры

Процедура ОбработкаПолученияДанныхВыбора(ДанныеВыбора, Параметры, СтандартнаяОбработка)
	
	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() 
		И ЗначениеЗаполнено(Параметры.СтрокаПоиска) Тогда
		
		СтандартнаяОбработка = Ложь;
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("NameRus", Параметры.СтрокаПоиска + "%");
		
		Запрос.Текст = "ВЫБРАТЬ
		|	Warehouses.Ссылка
		|ИЗ
		|	Справочник.Warehouses КАК Warehouses
		|ГДЕ
		|	Warehouses.NameRus ПОДОБНО &NameRus
		|	И НЕ Warehouses.ПометкаУдаления";
		           		
		Если Параметры.Отбор.Свойство("RCACountry") Тогда
			Запрос.Текст = Запрос.Текст + "
				|И Warehouses.RCACountry = &RCACountry";
			Запрос.УстановитьПараметр("RCACountry", Параметры.Отбор.RCACountry);
		КонецЕсли;
		
		ТаблицаРезультатов = Запрос.Выполнить().Выгрузить();
		МассивСсылок = ТаблицаРезультатов.ВыгрузитьКолонку("Ссылка");
		ДанныеВыбора = Новый СписокЗначений;
		ДанныеВыбора.ЗагрузитьЗначения(МассивСсылок);
		
	КонецЕсли;
	
КонецПроцедуры

