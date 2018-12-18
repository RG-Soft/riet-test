
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Параметры.АдресСертификата) Тогда
		ДанныеСертификата = ПолучитьИзВременногоХранилища(Параметры.АдресСертификата);
		Сертификат = Новый СертификатКриптографии(ДанныеСертификата);
		АдресСертификата = ПоместитьВоВременноеХранилище(ДанныеСертификата, УникальныйИдентификатор);
		
	ИначеЕсли ЗначениеЗаполнено(Параметры.Ссылка) Тогда
		АдресСертификата = АдресСертификата(Параметры.Ссылка, УникальныйИдентификатор);
		
		Если АдресСертификата = Неопределено Тогда
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				ВернутьСтр("ru = 'Не удалось открыть сертификат ""%1"",
				           |т.к. он не найден в справочнике.'"), Параметры.Ссылка);
		КонецЕсли;
	Иначе // Отпечаток
		АдресСертификата = АдресСертификата(Параметры.Отпечаток, УникальныйИдентификатор);
		
		Если АдресСертификата = Неопределено Тогда
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				ВернутьСтр("ru = 'Не удалось открыть сертификат, т.к. он не найден
				           |по отпечатку ""%1"".'"), Параметры.Отпечаток);
		КонецЕсли;
	КонецЕсли;
	
	Если ДанныеСертификата = Неопределено Тогда
		ДанныеСертификата = ПолучитьИзВременногоХранилища(АдресСертификата);
		Сертификат = Новый СертификатКриптографии(ДанныеСертификата);
	КонецЕсли;
	
	СтруктураСертификата = ЭлектроннаяПодписьКлиентСервер.ЗаполнитьСтруктуруСертификата(Сертификат);
	
	НазначениеПодписание = Сертификат.ИспользоватьДляПодписи;
	НазначениеШифрование = Сертификат.ИспользоватьДляШифрования;
	
	Отпечаток      = СтруктураСертификата.Отпечаток;
	КомуВыдан      = СтруктураСертификата.КомуВыдан;
	КемВыдан       = СтруктураСертификата.КемВыдан;
	ДействителенДо = СтруктураСертификата.ДействителенДо;
	
	ЗаполнитьКодыНазначенияСертификата(СтруктураСертификата.Назначение, НазначениеКоды);
	
	ЗаполнитьСвойстваСубъекта(Сертификат);
	ЗаполнитьСвойстваИздателя(Сертификат);
	
	ГруппаВнутреннихПолей = "Общие";
	ЗаполнитьВнутренниеПоляСертификата();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ГруппаВнутреннихПолейПриИзменении(Элемент)
	
	ЗаполнитьВнутренниеПоляСертификата();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СохранитьВФайл(Команда)
	
	ЭлектроннаяПодписьСлужебныйКлиент.СохранитьСертификат(Неопределено, АдресСертификата);
	
КонецПроцедуры

&НаКлиенте
Процедура Проверить(Команда)
	
	ЭлектроннаяПодписьКлиент.ПроверитьСертификат(Новый ОписаниеОповещения(
		"ПроверитьЗавершение", ЭтотОбъект), АдресСертификата);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Продолжение процедуры Проверить.
&НаКлиенте
Процедура ПроверитьЗавершение(Результат, Неопределен) Экспорт
	
	Если Результат = Истина Тогда
		ПоказатьПредупреждение(, ВернутьСтр("ru = 'Сертификат действителен.'"));
		
	ИначеЕсли Результат <> Неопределено Тогда
		ПоказатьПредупреждение(, ВернутьСтр("ru = 'Сертификат недействителен по причине:'")
			+ Символы.ПС + Результат);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСвойстваСубъекта(Сертификат)
	
	Коллекция = ЭлектроннаяПодписьКлиентСервер.СвойстваСубъектаСертификата(Сертификат);
	
	ПредставленияСвойств = Новый СписокЗначений;
	ПредставленияСвойств.Добавить("ОбщееИмя",         ВернутьСтр("ru = 'Общее имя'"));
	ПредставленияСвойств.Добавить("Страна",           ВернутьСтр("ru = 'Страна'"));
	ПредставленияСвойств.Добавить("Регион",           ВернутьСтр("ru = 'Регион'"));
	ПредставленияСвойств.Добавить("НаселенныйПункт",  ВернутьСтр("ru = 'Населенный пункт'"));
	ПредставленияСвойств.Добавить("Улица",            ВернутьСтр("ru = 'Улица'"));
	ПредставленияСвойств.Добавить("Организация",      ВернутьСтр("ru = 'Организация'"));
	ПредставленияСвойств.Добавить("Подразделение",    ВернутьСтр("ru = 'Подразделение'"));
	ПредставленияСвойств.Добавить("Должность",        ВернутьСтр("ru = 'Должность'"));
	ПредставленияСвойств.Добавить("ЭлектроннаяПочта", ВернутьСтр("ru = 'Электронная почта'"));
	ПредставленияСвойств.Добавить("ОГРН",             ВернутьСтр("ru = 'ОГРН'"));
	ПредставленияСвойств.Добавить("ОГРНИП",           ВернутьСтр("ru = 'ОГРНИП'"));
	ПредставленияСвойств.Добавить("СНИЛС",            ВернутьСтр("ru = 'СНИЛС'"));
	ПредставленияСвойств.Добавить("ИНН",              ВернутьСтр("ru = 'ИНН'"));
	ПредставленияСвойств.Добавить("Фамилия",          ВернутьСтр("ru = 'Фамилия'"));
	ПредставленияСвойств.Добавить("Имя",              ВернутьСтр("ru = 'Имя'"));
	ПредставленияСвойств.Добавить("Отчество",         ВернутьСтр("ru = 'Отчество'"));
	
	Для каждого ЭлементСписка Из ПредставленияСвойств Цикл
		Если Не ЗначениеЗаполнено(Коллекция[ЭлементСписка.Значение]) Тогда
			Продолжить;
		КонецЕсли;
		Строка = Субъект.Добавить();
		Строка.Свойство = ЭлементСписка.Представление;
		Строка.Значение = Коллекция[ЭлементСписка.Значение];
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСвойстваИздателя(Сертификат)
	
	Коллекция = ЭлектроннаяПодписьКлиентСервер.СвойстваИздателяСертификата(Сертификат);
	
	ПредставленияСвойств = Новый СписокЗначений;
	ПредставленияСвойств.Добавить("ОбщееИмя",         ВернутьСтр("ru = 'Общее имя'"));
	ПредставленияСвойств.Добавить("Страна",           ВернутьСтр("ru = 'Страна'"));
	ПредставленияСвойств.Добавить("Регион",           ВернутьСтр("ru = 'Регион'"));
	ПредставленияСвойств.Добавить("НаселенныйПункт",  ВернутьСтр("ru = 'Населенный пункт'"));
	ПредставленияСвойств.Добавить("Улица",            ВернутьСтр("ru = 'Улица'"));
	ПредставленияСвойств.Добавить("Организация",      ВернутьСтр("ru = 'Организация'"));
	ПредставленияСвойств.Добавить("Подразделение",    ВернутьСтр("ru = 'Подразделение'"));
	ПредставленияСвойств.Добавить("ЭлектроннаяПочта", ВернутьСтр("ru = 'Электронная почта'"));
	ПредставленияСвойств.Добавить("ОГРН",             ВернутьСтр("ru = 'ОГРН'"));
	ПредставленияСвойств.Добавить("ИНН",              ВернутьСтр("ru = 'ИНН'"));
	
	Для каждого ЭлементСписка Из ПредставленияСвойств Цикл
		Если Не ЗначениеЗаполнено(Коллекция[ЭлементСписка.Значение]) Тогда
			Продолжить;
		КонецЕсли;
		Строка = Издатель.Добавить();
		Строка.Свойство = ЭлементСписка.Представление;
		Строка.Значение = Коллекция[ЭлементСписка.Значение];
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьВнутренниеПоляСертификата()
	
	ВнутреннееСодержание.Очистить();
	ДвоичныеДанныеСертификата = ПолучитьИзВременногоХранилища(АдресСертификата);
	Сертификат = Новый СертификатКриптографии(ДвоичныеДанныеСертификата);
	
	Если ГруппаВнутреннихПолей = "Общие" Тогда
		ДобавитьСвойство(Сертификат, "Версия",                    ВернутьСтр("ru = 'Версия'"));
		ДобавитьСвойство(Сертификат, "ДатаНачала",                ВернутьСтр("ru = 'Дата начала'"));
		ДобавитьСвойство(Сертификат, "ДатаОкончания",             ВернутьСтр("ru = 'Дата окончания'"));
		ДобавитьСвойство(Сертификат, "ИспользоватьДляПодписи",    ВернутьСтр("ru = 'Использовать для подписи'"));
		ДобавитьСвойство(Сертификат, "ИспользоватьДляШифрования", ВернутьСтр("ru = 'Использовать для шифрования'"));
		ДобавитьСвойство(Сертификат, "ОткрытыйКлюч",              ВернутьСтр("ru = 'Открытый ключ'"), Истина);
		ДобавитьСвойство(Сертификат, "Отпечаток",                 ВернутьСтр("ru = 'Отпечаток'"), Истина);
		ДобавитьСвойство(Сертификат, "СерийныйНомер",             ВернутьСтр("ru = 'Серийный номер'"), Истина);
	Иначе
		Коллекция = Сертификат[ГруппаВнутреннихПолей];
		Для каждого КлючИЗначение Из Коллекция Цикл
			ДобавитьСвойство(Коллекция, КлючИЗначение.Ключ, КлючИЗначение.Ключ);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьСвойство(ЗначенияСвойств, Свойство, Представление, НижнийРегистр = Неопределено)
	
	Значение = ЗначенияСвойств[Свойство];
	Если ТипЗнч(Значение) = Тип("Дата") Тогда
		Значение = МестноеВремя(Значение, ЧасовойПоясСеанса());
	ИначеЕсли ТипЗнч(Значение) = Тип("ФиксированныйМассив") Тогда
		ФиксированныйМассив = Значение;
		Значение = "";
		Для каждого ЭлементМассива Из ФиксированныйМассив Цикл
			Значение = Значение + ?(Значение = "", "", Символы.ПС) + СокрЛП(ЭлементМассива);
		КонецЦикла;
	КонецЕсли;
	
	Строка = ВнутреннееСодержание.Добавить();
	Строка.Свойство = Представление;
	
	Если НижнийРегистр = Истина Тогда
		Строка.Значение = НРег(Значение);
	Иначе
		Строка.Значение = Значение;
	КонецЕсли;
	
КонецПроцедуры

// Преобразует назначения сертификатов в коды назначения.
//
// Параметры:
//  Назначение    - Строка - многострочное назначение сертификата, например:
//                           "Microsoft Encrypted File System (1.3.6.1.4.1.311.10.3.4)
//                           |E-mail Protection (1.3.6.1.5.5.7.3.4)
//                           |TLS Web Client Authentication (1.3.6.1.5.5.7.3.2)".
//  
//  КодыНазначения - Строка - коды назначения "1.3.6.1.4.1.311.10.3.4, 1.3.6.1.5.5.7.3.4, 1.3.6.1.5.5.7.3.2".
//
&НаСервере
Процедура ЗаполнитьКодыНазначенияСертификата(Назначение, КодыНазначения)
	
	УстановитьПривилегированныйРежим(Истина);
	
	Коды = "";
	
	Для Индекс = 1 По СтрЧислоСтрок(Назначение) Цикл
		
		Строка = СтрПолучитьСтроку(Назначение, Индекс);
		ТекущийКод = "";
		
		Позиция = СтрНайти(Строка, "(", НаправлениеПоиска.СКонца);
		Если Позиция <> 0 Тогда
			ТекущийКод = Сред(Строка, Позиция + 1, СтрДлина(Строка) - Позиция - 1);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ТекущийКод) Тогда
			Коды = Коды + ?(Коды = "", "", ", ") + СокрЛП(ТекущийКод);
		КонецЕсли;
		
	КонецЦикла;
	
	КодыНазначения = Коды;
	
КонецПроцедуры

&НаСервере
Функция АдресСертификата(СсылкаОтпечаток, ИдентификаторФормы = Неопределено)
	
	ДанныеСертификата = Неопределено;
	
	Если ТипЗнч(СсылкаОтпечаток) = Тип("СправочникСсылка.СертификатыКлючейЭлектроннойПодписиИШифрования") Тогда
		Хранилище = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СсылкаОтпечаток, "ДанныеСертификата");
		Если ТипЗнч(Хранилище) = Тип("ХранилищеЗначения") Тогда
			ДанныеСертификата = Хранилище.Получить();
		КонецЕсли;
	Иначе
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Отпечаток", СсылкаОтпечаток);
		Запрос.Текст =
		"ВЫБРАТЬ
		|	Сертификаты.ДанныеСертификата
		|ИЗ
		|	Справочник.СертификатыКлючейЭлектроннойПодписиИШифрования КАК Сертификаты
		|ГДЕ
		|	Сертификаты.Отпечаток = &Отпечаток";
		
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			ДанныеСертификата = Выборка.ДанныеСертификата.Получить();
		Иначе
			Сертификат = ЭлектроннаяПодписьСлужебный.ПолучитьСертификатПоОтпечатку(СсылкаОтпечаток, Ложь, Ложь);
			Если Сертификат <> Неопределено Тогда
				ДанныеСертификата = Сертификат.Выгрузить();
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если ТипЗнч(ДанныеСертификата) = Тип("ДвоичныеДанные") Тогда
		Возврат ПоместитьВоВременноеХранилище(ДанныеСертификата, ИдентификаторФормы);
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

#КонецОбласти
