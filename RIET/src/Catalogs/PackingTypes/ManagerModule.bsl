
Функция ПолучитьПоКоду(Код) Экспорт
	
	// Возвращает ссылку, ищет по Коду
	// Отсекает помеченные на удаление, если найдено несколько возвращает Неопределено
	// Рекомендуется вызывать из модуля с повторным использованием значений
	
	Возврат РГСофт.НайтиСсылку("Справочник", "PackingTypes", "Код", Код);
	
КонецФункции

Функция ПолучитьПоTMSID(TMSID) Экспорт
	
	// Возвращает ссылку, ищет по TMS ID, причем только те, которые InTMS
	// Отсекает помеченные на удаление, если найдено несколько возвращает Неопределено
	// Рекомендуется вызывать из модуля с повторным использованием значений
	
	СтруктураОтборов = Новый Структура;
	СтруктураОтборов.Вставить("InTMS", Истина);
	СтруктураОтборов.Вставить("TMSID", TMSID);
	СтруктураОтборов.Вставить("ПометкаУдаления", Ложь);
	
	Выборка = РГСофт.ПолучитьВыборку("Справочник", "PackingTypes", "Ссылка", СтруктураОтборов); 
	
	Если Выборка.Количество() = 1 Тогда
		Выборка.Следующий();
		Возврат Выборка.Ссылка;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции

Функция СоздатьНовыйPackingType(PackingType)  Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	НовыйPackingType = Справочники.PackingTypes.СоздатьЭлемент();
	НовыйPackingType.Код = PackingType;
	
	НовыйPackingType.Записать();
		
	Возврат НовыйPackingType.Ссылка;
	
КонецФункции

Процедура ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка)
	
	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
		СтандартнаяОбработка = Ложь;
		Поля.Добавить("CodeRus");
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	
	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
		СтандартнаяОбработка = Ложь;
	  	Представление = Данные.CodeRus;
	КонецЕсли;
	 	       
КонецПроцедуры

Процедура ОбработкаПолученияДанныхВыбора(ДанныеВыбора, Параметры, СтандартнаяОбработка)
	
	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() 
		И ЗначениеЗаполнено(Параметры.СтрокаПоиска) Тогда 
		
		СтандартнаяОбработка = Ложь;
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("CodeRus", Параметры.СтрокаПоиска + "%");
		
		Запрос.Текст = "ВЫБРАТЬ
		               |	PackingTypes.Ссылка
		               |ИЗ
		               |	Справочник.PackingTypes КАК PackingTypes
		               |ГДЕ
		               |	PackingTypes.CodeRus ПОДОБНО &CodeRus
		               |	И НЕ PackingTypes.ПометкаУдаления
		               |	И PackingTypes.InTMS";
		
		ТаблицаРезультатов = Запрос.Выполнить().Выгрузить();
		МассивСсылок = ТаблицаРезультатов.ВыгрузитьКолонку("Ссылка");
		ДанныеВыбора = Новый СписокЗначений;
		ДанныеВыбора.ЗагрузитьЗначения(МассивСсылок);
		
	КонецЕсли;
	
КонецПроцедуры
